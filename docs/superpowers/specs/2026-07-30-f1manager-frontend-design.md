# F1 Manager — Flutter Frontend (Design Spec)

Date: 2026-07-30
Status: Approved for planning
Backend: `/Users/maks/f1manager` (Go, Gin), default `HTTP_PORT=8080`

## 1. Goal & scope

Build a complete Flutter application (iOS / Android / Web) for the existing
F1 Manager Go backend. The app drives the full game loop over REST + WebSocket:
Auth → Lobby → Draft → Token Setup → Season (races, car updates) → Inter-Season,
plus always-available tabs (My Team, Info, Standings).

Scope of this effort: **the whole application at once** — full foundation
(networking, WS, storage, theme, routing, models) and all nine feature modules
with working screens. Backend PRs for the missing endpoints are **in scope**.

The frontend stores no server game state locally except setup presets (max 3).
Auth tokens live in `FlutterSecureStorage`.

## 2. Tech stack (decided)

| Concern | Choice | Notes |
|---|---|---|
| State management | **Riverpod 2.x** (`flutter_riverpod` + `riverpod_annotation`) | One style across the whole app. |
| Navigation | **GoRouter** | Phase-driven redirect guard. |
| HTTP | **Dio** + interceptors | `Authorization: Bearer` + auto-refresh on 401. |
| WebSocket | **`web_socket_channel`** + custom reconnect layer | Exponential backoff 1→2→4→…→30s. |
| Models / DTO | **`freezed` + `json_serializable`** | Immutable models, safe `copyWith`. |
| Token storage | **`flutter_secure_storage`** | access + refresh tokens. |
| Setup presets | **`shared_preferences`** (JSON, ≤3) | No DB needed for 3 presets. |
| Codegen | `build_runner` | freezed / json_serializable / riverpod_generator. |

Dev defaults: base URL `http://localhost:8080/api/v1`, WS
`ws://localhost:8080/api/v1/ws`. Host is configurable via a compile-time
`--dart-define=API_HOST=...` (default `localhost:8080`, scheme auto: http/ws
for localhost, https/wss otherwise).

## 3. Project structure

```
lib/
├── core/
│   ├── api/          # Dio client, interceptors (auth, refresh, error), ApiConfig
│   ├── ws/           # WsService: connect, reconnect (backoff), typed message stream
│   ├── storage/      # SecureTokenStore (tokens), SetupPresetStore (shared_prefs)
│   ├── models/       # shared DTOs (pilot, team, principal, track, standing, ...)
│   ├── router/       # GoRouter + phase redirect guard
│   └── error/        # AppException, error → snackbar mapping
├── features/
│   ├── auth/         # login, register, token refresh
│   ├── lobby/        # create/join group, players list, season status
│   ├── draft/        # draft board, turn indicator, engine modal, budget bar, pick history
│   ├── season/       # token setup + race setup + race result + car update windows
│   ├── inter_season/ # transfers, base investment, fire, ready
│   ├── standings/    # WDC / WCC tables
│   ├── info/         # next track, all squads, all pilots (public)
│   └── my_team/      # car, pilots, principal, budget/tokens, base
├── shared/
│   ├── widgets/      # reusable components (BudgetBar, StatBar, LoadingView, ErrorView...)
│   └── theme/        # colors, typography, light + dark, F1 red accent
└── main.dart
```

Each `features/<x>/` module is self-contained: `data/` (repository over Dio),
`application/` (Riverpod providers/notifiers), `presentation/` (screens/widgets),
`model/`. Adding a feature = add a folder + register a route.

## 4. Networking layer

- **Dio client** with base URL from `ApiConfig`.
- **AuthInterceptor**: attaches `Authorization: Bearer <access>` to every request
  except `/auth/*`.
- **RefreshInterceptor**: on 401, calls `POST /auth/refresh` once (single-flight,
  queues concurrent 401s), retries the original request; on refresh failure →
  clears tokens, routes to login.
- **ErrorInterceptor**: normalizes Dio errors into `AppException{message}` so the
  UI can show a snackbar with the cause.
- Repositories per feature wrap endpoints and return typed models.

### Endpoint map (verified against backend router)

Existing (in `internal/server/router.go` + `internal/auth/handler`):
`/auth/register|login|refresh|logout`, `/groups`, `/groups/join`,
`/pilots`, `/teams`, `/principals`, `/track`, `/my-team`, `/players`,
`/players/squads`, `/draft/start|pick|bots/swap`, `/setup`, `/token-setup`,
`/race-result`, `/standing`, `/rounds/:stage/init`, `/updates`, `/base`,
`/transfers/pilot`, `/transfers/principal`, `/ws`.

Verified request DTOs (from `internal/web/dto/validation.go`,
`internal/auth/model/model.go`):
- `POST /auth/register` `{email, username, password}` → `{access_token, refresh_token}`
- `POST /auth/login` `{login, password}` → `{access_token, refresh_token}`
- `POST /auth/refresh` `{refresh_token}` → `{access_token, refresh_token}`
- `POST /draft/pick` `{pick: 0|1|2, item_id, engine?}`
- `POST /draft/bots/swap` `{team_a, team_b, pilot_a, pilot_b}`
- `POST /groups` / `POST /groups/join` `{id?, name?, password}`
- `POST /setup` and `POST /token-setup` `{name, aero_dynamic, engine, chassis,
  floor, tyres, reliability, settings_angle}` (`ChooseSetup` binds full `dto.Setup`)
- `POST /updates` `{type: 0|1, coast, stage}`
- `POST /base` `{base, engineer, tube, sim}`
- `POST /transfers/pilot` `{pilot_id, price}`; `POST /transfers/principal` `{principal_id, price}`

Missing (NOT in router — added via backend PR, see §7):
`GET /season/state`, `GET /engines`, `GET /budget`, `POST /ready`, `POST /fire`.

### JSON casing (verified — IMPORTANT)

Data handlers serialize raw `internal/models` structs directly via `c.JSON`.
Structs **without** json tags therefore emit **PascalCase, Go-field-name keys**,
while a few structs carry explicit tags. Client DTOs must map the ACTUAL casing
per endpoint (use `@JsonKey(name: ...)`), NOT assume snake_case. We do **not**
reshape backend response models (would break the CLI and other consumers, and is
outside the agreed backend-PR scope).

- PascalCase (untagged models): `GET /pilots` (`Pilot`: `ID,Name,Garage,Team,
  Rating,QualifyingRating,DrivingStyle,Experience,Adaptiveness,Emotions,Stability,
  Rain,SettingsAngle,Starting,TyreManagement,MistakePossibility,Price,Sponsors,
  CarFit`), `GET /teams` (`Team`: `ID,Name,ICE,CarLevel,BaseLevel,Engineer,
  SimLevel,TubeLevel,UpdateRating,Tokens,Budget,IsManufacturer,CarSettings`),
  `GET /principals` (`TeamPrincipal`: `ID,Name,Price,TeamID,Level`),
  `GET /track` (`Track`: `ID,Name,DownForceLevel,Type,Difficulty,QualifyingImpact,
  RainPossibility,Tyre`), `GET /players` (`Player`: `ID,Name,TeamPrincipal,Team,
  Budget,Tokens`), `GET /players/squads` (`PlayerProfile`: `ID,Name,TeamPrincipal,
  Team,Pilot1,Pilot2,Budget,Tokens`).
- Tagged: `GET /my-team` outer keys `{id, pilot1, pilot2, team, team_principal}`
  with PascalCase INSIDE the nested `Pilot`/`Team`/`TeamPrincipal`;
  `GET /race-result` → `{stage, results:[{pilot_id, garage_id, pilot_name,
  team_name, quali_position, race_position, points, is_dnf, dnf_reason}]}`;
  auth `{access_token, refresh_token}`; `GET /standing` → `{drivers, teams}`
  (verify handler once implemented — `standing` currently stubbed).
- All enums (`DrivingStyle`, `SettingsAngle`, `ICEName`, `IsManufacturer`,
  `TrackType`, `DownForce`, `QualifyingImpact`, `DriverEmotion`, `DriverStability`,
  `RainDriving`) serialize as their **integer** iota value.

Each DTO's `fromJson` MUST be verified field-by-field against the Go struct
during implementation.

## 5. WebSocket layer

`WsService` connects immediately after login and reconnects with exponential
backoff (1s → 2s → 4s → … → max 30s). On every (re)connect it triggers a fresh
`GET /season/state` so the app resynchronizes phase.

Incoming messages (verified shapes from `internal/web/dispatcher`):
- `draft_turn {round}` — your turn
- `draft_retry {round, error}` — pick rejected, retry
- `draft_pick_made {user_id, pick, item_id}` — broadcast
- `draft_finished {}` — draft over → token setup
- `transfer_request {pilot_id, price}` — incoming transfer offer
- `race_finished {status, stage}` — simulation done → fetch `/race-result`
- `season_started {}` — (added via backend PR) all players ready → new season

Outgoing:
- `transfer_response {type:"transfer_response", pilot_id, accept:bool}`

`WsService` exposes a typed broadcast stream; each feature subscribes to the
message kinds it cares about via a Riverpod provider.

### WS auth + connect timing (verified against backend — IMPORTANT)

`GET /ws` (`HandleWs`) is behind the JWT middleware, which reads the token
**only from the `Authorization: Bearer` header** (`pkg/middleware/jwt/middleware.go`
— no query-param fallback), and additionally rejects the handshake with 400 if
the user is **not in a group** (`GetUserGroup` must be non-nil).

Consequences:
- **Connect timing:** open the WS only AFTER the user has a group (after
  lobby create/join), not immediately after login. Pre-group phases (auth,
  lobby) run over REST only.
- **Mobile/desktop:** `IOWebSocketChannel.connect(url, headers: {'Authorization':
  'Bearer <access>'})` works — send the header.
- **Web:** browser `WebSocket` cannot set custom headers, so the header path is
  impossible on Web. Web support (a hard ТЗ requirement) therefore needs a
  **backend PR** making the WS endpoint also accept the access token via a
  `?token=` query param (or `Sec-WebSocket-Protocol`). Added to §7. Until then,
  Web WS is degraded/unavailable; mobile/desktop are unaffected.
- `WsService` sends the token BOTH ways (header on IO via a platform-conditional
  channel factory, and `?token=` query on the URL) so it works on IO now and on
  Web as soon as the backend PR lands.

## 6. Phase-driven navigation

`GoRouter` with a redirect guard backed by a `seasonStateProvider`
(`GET /season/state`). On app start and on each WS reconnect, the app reads state
and routes:

```
phase == "draft"        → /draft
phase == "token_setup"  → /token-setup
phase == "racing"       → /season (race setup / result)
phase == "inter_season" → /inter-season
no group                → /lobby
not authenticated       → /auth
```

`season/state` also carries `stage`, `submitted_setups`, `total_players` for the
"waiting for other players" indicator. While the endpoint is unavailable
(pre-PR), the guard degrades to: authenticated + has group → lobby.

Always-available tabs (My Team, Info, Standings) are presented in a shell route
(bottom nav / rail) layered over the active game phase where applicable.

## 7. Backend PRs (in scope, via PR — never to main directly)

Add to the backend repo, each on its own branch/PR:
- `GET /season/state` → `{phase:"draft"|"token_setup"|"racing"|"inter_season", stage:int, submitted_setups:[user_id], total_players:int}`
- `GET /engines` → `[{id, name, price, base_level}]`
- `GET /budget` → `{budget:int, tokens:int}`
- `POST /ready` → inter-season: player is ready for the new season
- `POST /fire` → `{who:"pilot"|"principal", id:int}`
- WS `season_started` broadcast when all players are ready
- **WS token via query (needed for Web):** make `GET /ws` accept the access
  token via `?token=<jwt>` (validated the same way as the `Authorization`
  header) so browsers — which cannot set WS headers — can authenticate. Without
  this, the Web platform cannot open the WebSocket. Higher priority than the
  other PRs because it blocks a core platform requirement.

Frontend consumes these contracts. Where an endpoint is not yet merged, the
corresponding provider runs a documented degraded mode (manual input / stub)
so the app still builds and runs.

## 8. Feature module behavior (summary)

- **auth (5.1)**: login/register forms; on success store tokens, open WS, redirect to lobby.
- **lobby (5.2)**: no group → create/join by password; has group → players list + season status + "Start draft".
- **draft (5.3)**: filterable/sortable lists of pilots/teams/principals; turn indicator from `draft_turn`; pick buttons enabled only on your turn; team pick opens engine modal (prices from `/engines`, team type respected); real-time budget bar (starts 110); pick history from `draft_pick_made`; `draft_finished` → token setup.
- **token setup (5.4)**: 6 sliders (Aero, Engine, Chassis, Floor, Tyres, Reliability) + remaining-token counter (base = team's token pool); Settings Angle toggle (0=rear,1=front); save as preset (≤3, local); submit → `POST /token-setup`; wait for all via `season/state`/WS.
- **race (5.5)**: next-track card (name, type, difficulty, rain %, tyre wear); pick preset or manual entry; confirm → `POST /setup`; waiting indicator (poll `season/state` every 5s or WS); `race_finished` → `GET /race-result` → results table (pos, pilot, team, quali, race, points, DNF); "Next stage".
- **car update windows (5.6)**: on stages 3/8/13 a modal appears post-race; choose car improvement (≤15M) or pilot-car synergy; amount input, effect preview → `POST /updates {type, coast, stage}`.
- **inter_season (5.7)**: transfers of free/other-players' pilots with prices → `POST /transfers/pilot`; incoming `transfer_request` → respond via WS; fire pilot/principal → `POST /fire`; hire principal → `POST /transfers/principal`; base investment sliders (base ≤10, engineer ≤5, tube ≤5, sim ≤5) → `POST /base`; current base state from `/my-team`; `POST /ready` + `season_started`.
- **standings (5.8)**: WDC (drivers) + WCC (teams) from `/standing {drivers:{id:pts}, teams:{id:pts}}`; refresh after each race.
- **my_team (5.9)**: car (level, components, settings), pilots (all stats), principal (level), budget/tokens (`/budget`), base (all levels) from `/my-team`.
- **info (5.10)**: next track full info (`/track`), all squads (`/players/squads`, no car detail), all pilots public ratings (`/pilots`).

## 9. Non-functional requirements

- **Modularity**: each `feature/` is independent (own providers/repo/models); new
  feature = new folder + route registration.
- **WS reconnect**: exponential backoff 1→2→4→…→max 30s; re-fetch `season/state`
  on reconnect.
- **Errors**: all network errors show a snackbar with the cause; 401 → automatic
  token refresh via interceptor.
- **Theme**: minimalist dark + light, F1 styling, red accent.
- **Platforms**: iOS, Android, Web; responsive, min-width 320px.

## 10. Testing & verification

- Unit tests for repositories and key providers using a mocked Dio (`http_mock_adapter`
  or manual `MockDio`).
- Widget tests for critical screens (auth form, draft board turn logic, token
  setup token accounting, race result table).
- `flutter analyze` clean; `flutter build web` succeeds. Backend PRs include Go
  tests mirroring existing handler test style.

## 11. Out of scope

- Persisting any game state on the client beyond setup presets.
- Push notifications, deep links beyond phase routing, localization (Russian/
  English) beyond default strings, analytics.
