# Inter-Season Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the F1 Manager inter-season phase: pilot transfers (free agents + peer offers over WS), hire/fire principals, fire pilots, base-investment sliders, and "ready for new season" — including the backend PR that adds the endpoints this needs.

**Architecture:** New `lib/features/inter_season/` module following the established feature layout (`model/`, `data/`, `application/`, `presentation/`). HTTP actions go through `InterSeasonRepository` (Dio); real-time transfer negotiation goes through the existing `WsService` (incoming `transfer_request`, outgoing `transfer_response`) and `season_started`. Base state and fire targets come from `GET /my-team`. A separate backend PR (Go repo, base `feature/draft-module`) adds `POST /fire`, `POST /ready`, and the `season_started` broadcast, mirroring how Plan 3 added `/engines` + `/budget`.

**Tech Stack:** Flutter, Riverpod, GoRouter, Dio, freezed + json_serializable, web_socket_channel; backend: Go + Gin, redis dynamic store, gorilla/websocket.

## Global Constraints

- **Git:** Claude commits **and** pushes directly in this frontend repo (overrides global "user commits himself"). Backend changes go **via a PR** (branch + PR, never straight to main), authored by Claude. End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Subagent model floor:** code-writing subagents use **at least Sonnet** (never Haiku). Reviewers: Sonnet. Final whole-branch review: most capable available.
- **Flutter env:** SDK at `$HOME/development/flutter`. Shell env does NOT persist between tool calls — **prefix every** flutter/dart command with `export PATH="$HOME/development/flutter/bin:$PATH" &&`. Work from `/Users/maks/f1managerfront`.
- **Test flake:** always run the full suite with `flutter test --concurrency=1` (default concurrency is flaky in this sandbox). Focused single-file runs are fine as-is.
- **iOS pod side-effect:** `flutter test`/`build` may modify tracked `ios/Flutter/*.xcconfig` and create untracked `ios/Podfile`. ALWAYS revert before committing: `git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile`. Never commit these.
- **State mgmt:** Riverpod everywhere. **Navigation:** GoRouter. **Models:** freezed + json_serializable; DTOs map ACTUAL server casing via `@JsonKey`; enums serialize as ints; commit generated `*.g.dart`/`*.freezed.dart`. Codegen: `dart run build_runner build --delete-conflicting-outputs`.
- **Verified casing (spec §4):** untagged `internal/models` structs emit **PascalCase** keys (`Pilot`, `Team`, `TeamPrincipal`). `GET /my-team` outer keys are lowercase `{id, pilot1, pilot2, team, team_principal}` with **PascalCase inside** each nested object. Enums are integers.
- **Every task** ends `flutter analyze` clean + `flutter test --concurrency=1` passing + committed. The last frontend task also runs `flutter build web --dart-define=API_HOST=localhost:8080`.

---

## File Structure

Frontend (all new unless noted):
- `lib/features/inter_season/model/transfer_events.dart` — WS event parsing (`transfer_request`, `season_started`) + outgoing `transfer_response` payload builder.
- `lib/features/inter_season/model/my_team_summary.dart` — `MyTeamSummary.fromJson` over `GET /my-team` (reuses core `Pilot`/`Team`/`Principal`).
- `lib/features/inter_season/data/inter_season_repository.dart` — HTTP: `getMyTeam`, `buyPilot`, `hirePrincipal`, `fire`, `updateBase`, `markReady`.
- `lib/features/inter_season/application/inter_season_data_providers.dart` — FutureProviders: my-team, free pilots, other players' pilots, principals, budget.
- `lib/features/inter_season/application/inter_season_controller.dart` — WS state: incoming offers queue, `season_started` flag; `respondToOffer`, `markReady`.
- `lib/features/inter_season/presentation/widgets/transfer_list.dart` — buyable pilot list with price input + buy.
- `lib/features/inter_season/presentation/widgets/incoming_offer_dialog.dart` — accept/decline a `transfer_request`.
- `lib/features/inter_season/presentation/widgets/base_investment_form.dart` — 4 sliders (base≤10, engineer≤5, tube≤5, sim≤5) + submit.
- `lib/features/inter_season/presentation/widgets/principal_hire_list.dart` — hire principal list + hire/fire.
- `lib/features/inter_season/presentation/inter_season_screen.dart` — tabbed shell wiring it together + offer listener + ready → new season.
- Modify: `lib/core/router/app_router.dart` — replace the `/inter-season` placeholder with `InterSeasonScreen`.

Backend PR (Go repo `/Users/maks/f1manager`, base `feature/draft-module`):
- `internal/web/dto/validation.go` — add `Fire` DTO.
- `internal/new_storage/storage.go` — add `Fire` to `DynamicRepo`.
- `internal/new_storage/redis/dynamic.go` + `internal/new_storage/stub/stub.go` — implement `Fire`.
- `internal/service/cross_season.go` (or `service.go`) — `Service.Fire`; `internal/web/handler/http/cross_season.go` — add `Fire` to interface.
- `internal/web/dispatcher/ready.go` — `ReadyTracker` (all-ready → ResetSeason + broadcast `season_started`).
- `internal/web/handler/http/handler.go` — `Fire`, `Ready` handlers; extend `Manager` with `BroadcastGroup`.
- `internal/server/router.go` + `internal/server/server.go` — routes + wiring.

---

## Task 1: Backend PR — `POST /fire`, `POST /ready`, WS `season_started`

**Repo:** `/Users/maks/f1manager` (Go). **Base branch:** `feature/draft-module` (same base as PR #3). Create a new branch off it, e.g. `feat/fire-ready-endpoints`. This task produces a **GitHub PR**, not a commit on `feat/frontend`. It is independent of all frontend tasks and runs in parallel.

**Files:**
- Create: `internal/web/dispatcher/ready.go`, `internal/web/dispatcher/ready_test.go`
- Modify: `internal/web/dto/validation.go`, `internal/new_storage/storage.go`, `internal/new_storage/redis/dynamic.go`, `internal/new_storage/stub/stub.go`, `internal/web/handler/http/cross_season.go`, `internal/web/handler/http/user.go`, `internal/web/handler/http/handler.go`, `internal/service/service.go` (or a new `internal/service/fire.go`), `internal/server/router.go`, `internal/server/server.go`

**Interfaces:**
- Produces (frontend consumes these contracts): `POST /api/v1/fire` body `{"who":"pilot"|"principal","id":<int>}` → 200 on success, 400 `{"error":...}` on failure. `POST /api/v1/ready` → 200; when the last player in the group readies, server calls `ResetSeason` then broadcasts WS `{"type":"season_started"}` to the group. Both are under the JWT+group middleware.

- [ ] **Step 1: Branch off the correct base**

```bash
cd /Users/maks/f1manager
git fetch origin
git checkout feature/draft-module && git pull --ff-only
git checkout -b feat/fire-ready-endpoints
```

- [ ] **Step 2: Add the `Fire` request DTO**

In `internal/web/dto/validation.go` append:

```go
type Fire struct {
	Who string `json:"who"` // "pilot" | "principal"
	ID  int64  `json:"id"`
}
```

- [ ] **Step 3: Add `Fire` to the `DynamicRepo` interface**

In `internal/new_storage/storage.go`, under the `// Межсезонье` group of `DynamicRepo`:

```go
	// Fire убирает пилота (who=="pilot") или тим-принципала (who=="principal") у игрока
	// и возвращает деньги в бюджет (пилот: +price-sponsors; принципал: +price).
	Fire(ctx context.Context, userID, groupID int64, who string, id int64) error
```

- [ ] **Step 4: Write the failing redis `Fire` test**

Study the existing redis test setup (look for `redis_test.go` / miniredis usage in `internal/new_storage/redis/`). Following that harness, add a test asserting: firing a pilot detaches it (owner/garage/team nil via `SetPilotOwner`) and credits `price - sponsors` to the player's budget; firing a principal clears `player.TeamPrincipal` and credits `price`. If the redis package has no existing test harness, write the equivalent test in `internal/new_storage/stub/stub_test.go` against the stub implementation instead, and cover redis by manual `go build` + reasoning. Run:

```bash
cd /Users/maks/f1manager && go test ./internal/new_storage/... 2>&1 | tail -20
```
Expected: FAIL (Fire undefined).

- [ ] **Step 5: Implement `Fire` in redis + stub**

In `internal/new_storage/redis/dynamic.go` (mirror the transaction logic of `internal/storage/sqlite_repo/sqlite.go:595` `Fire`, but using the redis helpers `GetPlayer`/`SavePlayer`/`SetPilotOwner`/`UpdateBudget`/`GetPilotByGroup` and the static `GetTeamPrincipal` where needed — note `TeamPrincipal.Price` comes from the static repo):

```go
func (d *Dynamic) Fire(ctx context.Context, userID, groupID int64, who string, id int64) error {
	switch who {
	case "pilot":
		pilot, err := d.GetPilotByGroup(ctx, id, groupID)
		if err != nil {
			return err
		}
		if err := d.SetPilotOwner(ctx, id, groupID, nil, nil); err != nil {
			return err
		}
		return d.UpdateBudget(ctx, userID, groupID, pilot.Price-pilot.Sponsors)
	case "principal":
		player, err := d.GetPlayer(ctx, userID, groupID)
		if err != nil {
			return err
		}
		// principal price is static data — resolve via the static repo in Service.Fire
		// and pass it down, OR store it; simplest: clear here, refund in Service.
		player.TeamPrincipal = nil
		if err := d.UpdatePlayer(ctx, userID, groupID, player); err != nil {
			return err
		}
		return nil
	default:
		return fmt.Errorf("unknown who: %s", who)
	}
}
```

Note: principal price is static (`StaticRepo.GetTeamPrincipal`). Since `DynamicRepo` has no static access, do the principal **refund** in `Service.Fire` (Step 7) after calling `dynamic.Fire`, or extend the signature to accept a resolved `refund int`. Pick the cleaner option and keep it consistent between redis and stub. Add the matching `Fire` to `internal/new_storage/stub/stub.go` (in-memory equivalent).

- [ ] **Step 6: Run redis/stub tests to green**

```bash
cd /Users/maks/f1manager && go test ./internal/new_storage/... 2>&1 | tail -20
```
Expected: PASS.

- [ ] **Step 7: Add `Service.Fire` + interface method**

In `internal/web/handler/http/cross_season.go` add to the `CrossSeason` interface:

```go
	Fire(ctx context.Context, userID int64, req dto.Fire) error
```

Implement `Service.Fire` (in `internal/service/service.go` or new `internal/service/fire.go`): resolve group via `s.getUserGroup`; validate `who`; for `principal`, resolve price via `s.static.GetTeamPrincipal(ctx, id)`; call `s.dynamic.Fire(...)` (passing the refund if you chose that signature); for principal, refund with `s.dynamic.UpdateBudget(ctx, userID, groupID, principal.Price)`.

- [ ] **Step 8: Add the `Fire` HTTP handler**

In `internal/web/handler/http/handler.go`, mirror `PilotTransfer` (handler.go:223):

```go
func (h *HttpHandler) Fire(c *gin.Context) {
	ctx := c.Request.Context()
	user, exist := h.getUser(c)
	if !exist {
		c.JSON(403, gin.H{"error": "user not found"})
		return
	}
	var req dto.Fire
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	if err := h.crossSeason.Fire(ctx, user, req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	c.Status(200)
}
```

- [ ] **Step 9: Write the failing `ReadyTracker` test**

Create `internal/web/dispatcher/ready_test.go`. Model it on the existing `Dispatcher` all-ready logic (`dispatcher.go` `groupState`/`Submit`). Test: with `totalPlayers=2`, the first `Ready` returns `allReady=false` and does NOT broadcast; the second returns `allReady=true`, calls `ResetSeason(groupID)` once, and broadcasts exactly one `{"type":"season_started"}` to the group. Use fake `Notifier` + fake reset func capturing calls. Run:

```bash
cd /Users/maks/f1manager && go test ./internal/web/dispatcher/... 2>&1 | tail -20
```
Expected: FAIL (ReadyTracker undefined).

- [ ] **Step 10: Implement `ReadyTracker`**

Create `internal/web/dispatcher/ready.go`:

```go
package dispatcher

import (
	"context"
	"sync"
)

type seasonStartedMsg struct {
	Type string `json:"type"`
}

// ResetService — сброс сезона (токены/бюджет) при готовности всех игроков.
type ResetService interface {
	ResetSeason(ctx context.Context, groupID int64) error
}

type readyState struct {
	mu       sync.Mutex
	ready    map[int64]struct{}
	launched bool
}

// ReadyTracker собирает готовность игроков; когда готовы все — сбрасывает сезон
// и рассылает season_started ровно один раз.
type ReadyTracker struct {
	mu       sync.Mutex
	groups   map[int64]*readyState
	reset    ResetService
	notifier Notifier
}

func NewReady(reset ResetService, notifier Notifier) *ReadyTracker {
	return &ReadyTracker{groups: make(map[int64]*readyState), reset: reset, notifier: notifier}
}

// Ready регистрирует готовность игрока. totalPlayers — размер группы на момент вызова.
func (r *ReadyTracker) Ready(ctx context.Context, groupID, userID int64, totalPlayers int) error {
	r.mu.Lock()
	st, ok := r.groups[groupID]
	if !ok {
		st = &readyState{ready: make(map[int64]struct{})}
		r.groups[groupID] = st
	}
	r.mu.Unlock()

	st.mu.Lock()
	st.ready[userID] = struct{}{}
	allReady := totalPlayers > 0 && len(st.ready) >= totalPlayers && !st.launched
	if allReady {
		st.launched = true
	}
	st.mu.Unlock()

	if !allReady {
		return nil
	}

	r.mu.Lock()
	delete(r.groups, groupID)
	r.mu.Unlock()

	if err := r.reset.ResetSeason(ctx, groupID); err != nil {
		return err
	}
	r.notifier.BroadcastGroup(groupID, mustMarshal(seasonStartedMsg{Type: "season_started"}))
	return nil
}
```

Run the test again — expected PASS.

- [ ] **Step 11: Add the `Ready` HTTP handler + extend `Manager`**

In `internal/web/handler/http/user.go`, add `BroadcastGroup(groupID int64, msg []byte)` to the `Manager` interface (the concrete `connection.Manager` already implements it — see `internal/web/connection/manager.go:62`). Add a `ready ReadyDispatcher` field + interface to `HttpHandler`:

```go
type ReadyDispatcher interface {
	Ready(ctx context.Context, groupID, userID int64, totalPlayers int) error
}
```

Handler (mirror `InitRound`, handler.go:483):

```go
func (h *HttpHandler) Ready(c *gin.Context) {
	ctx := c.Request.Context()
	user, exist := h.getUser(c)
	if !exist {
		c.JSON(403, gin.H{"error": "user not found"})
		return
	}
	groupID, err := h.userData.GetUserGroup(ctx, user)
	if err != nil || groupID == nil {
		c.JSON(400, gin.H{"error": "group not found"})
		return
	}
	total := h.manager.GroupSize(*groupID)
	if err := h.ready.Ready(ctx, *groupID, user, total); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	c.Status(200)
}
```

Update `NewHttpHandler` to accept and store the `ready` dependency.

- [ ] **Step 12: Register routes + wire dependencies**

In `internal/server/router.go`, in the `game` group under `// межсезонье`:

```go
		game.POST("/fire", h.Fire)
		game.POST("/ready", h.Ready)
```

In `internal/server/server.go`, construct `ready := dispatcher.NewReady(svc, manager)` (near `disp := dispatcher.New(svc, manager)`, server.go:70) and pass it into `NewHttpHandler`.

- [ ] **Step 13: Build + full backend test suite**

```bash
cd /Users/maks/f1manager && go build ./... && go test ./... 2>&1 | tail -30
```
Expected: build OK, all tests PASS.

- [ ] **Step 14: Commit + push + open PR**

```bash
cd /Users/maks/f1manager
git add internal/ && git commit -m "feat(cross-season): POST /fire, POST /ready + season_started broadcast

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git push -u origin feat/fire-ready-endpoints
gh pr create --base feature/draft-module --title "feat(cross-season): /fire, /ready, season_started" \
  --body "$(cat <<'EOF'
Adds the endpoints the Flutter inter-season screen needs.

- POST /fire {who,id} — release a pilot (refund price-sponsors) or principal (refund price)
- POST /ready — mark player ready; when all in the group are ready, ResetSeason + broadcast WS season_started
- Extends DynamicRepo with Fire (redis + stub), adds ReadyTracker dispatcher

Base is feature/draft-module (same as PR #3) because transfers/base live there and it is unmerged; flag if a different base is wanted.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Record the PR URL in the ledger. **Frontend tasks proceed against this documented contract regardless of merge status.**

---

## Task 2: Inter-season models (WS events + MyTeamSummary)

**Files:**
- Create: `lib/features/inter_season/model/transfer_events.dart`
- Create: `lib/features/inter_season/model/my_team_summary.dart`
- Test: `test/features/inter_season/inter_season_models_test.dart`

**Interfaces:**
- Consumes: `WsMessage` (`lib/core/ws/ws_message.dart`, fields `type`, `data`); core models `Pilot`, `Team`, `Principal` (`lib/core/models/`).
- Produces:
  - `class TransferRequest { final int pilotId; final int price; }`
  - `TransferRequest? transferRequestFromMessage(WsMessage m)` — null unless `m.type == 'transfer_request'`.
  - `bool isSeasonStarted(WsMessage m)` — true iff `m.type == 'season_started'`.
  - `Map<String,dynamic> transferResponsePayload({required int pilotId, required bool accept})` → `{'type':'transfer_response','pilot_id':pilotId,'accept':accept}`.
  - `class MyTeamSummary { final int id; final Pilot pilot1; final Pilot pilot2; final Team team; final Principal principal; }` with `MyTeamSummary.fromJson(Map<String,dynamic>)`.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/inter_season_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/inter_season/model/transfer_events.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';

void main() {
  test('transferRequestFromMessage parses pilot_id + price', () {
    final m = WsMessage('transfer_request', {'type': 'transfer_request', 'pilot_id': 7, 'price': 40});
    final r = transferRequestFromMessage(m)!;
    expect(r.pilotId, 7);
    expect(r.price, 40);
  });

  test('transferRequestFromMessage returns null for other types', () {
    expect(transferRequestFromMessage(WsMessage('draft_turn', {'type': 'draft_turn'})), isNull);
  });

  test('isSeasonStarted true only for season_started', () {
    expect(isSeasonStarted(WsMessage('season_started', {'type': 'season_started'})), isTrue);
    expect(isSeasonStarted(WsMessage('race_finished', {'type': 'race_finished'})), isFalse);
  });

  test('transferResponsePayload shape', () {
    expect(transferResponsePayload(pilotId: 7, accept: true),
        {'type': 'transfer_response', 'pilot_id': 7, 'accept': true});
  });

  test('MyTeamSummary.fromJson maps nested PascalCase', () {
    final s = MyTeamSummary.fromJson({
      'id': 1,
      'pilot1': {'ID': 10, 'Name': 'Max', 'Price': 50, 'Sponsors': 5},
      'pilot2': {'ID': 11, 'Name': 'Lando', 'Price': 30},
      'team': {'ID': 3, 'Name': 'RB', 'BaseLevel': 4, 'Engineer': 2, 'TubeLevel': 3, 'SimLevel': 1},
      'team_principal': {'ID': 9, 'Name': 'Toto', 'Price': 20, 'Level': 5},
    });
    expect(s.pilot1.id, 10);
    expect(s.pilot1.sponsors, 5);
    expect(s.team.baseLevel, 4);
    expect(s.principal.level, 5);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_models_test.dart`
Expected: FAIL (files/symbols not found).

- [ ] **Step 3: Implement `transfer_events.dart`**

```dart
import '../../../core/ws/ws_message.dart';

class TransferRequest {
  const TransferRequest(this.pilotId, this.price);
  final int pilotId;
  final int price;
}

int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);

TransferRequest? transferRequestFromMessage(WsMessage m) {
  if (m.type != 'transfer_request') return null;
  return TransferRequest(_int(m.data['pilot_id']), _int(m.data['price']));
}

bool isSeasonStarted(WsMessage m) => m.type == 'season_started';

Map<String, dynamic> transferResponsePayload({required int pilotId, required bool accept}) =>
    {'type': 'transfer_response', 'pilot_id': pilotId, 'accept': accept};
```

- [ ] **Step 4: Implement `my_team_summary.dart`**

`MyTeam` outer keys are lowercase; nested objects are PascalCase. Do NOT use freezed here — it is a thin hand-mapped aggregate over existing core models (avoids a codegen round-trip for a 5-field wrapper):

```dart
import '../../../core/models/pilot.dart';
import '../../../core/models/team.dart';
import '../../../core/models/principal.dart';

class MyTeamSummary {
  const MyTeamSummary({
    required this.id,
    required this.pilot1,
    required this.pilot2,
    required this.team,
    required this.principal,
  });

  final int id;
  final Pilot pilot1;
  final Pilot pilot2;
  final Team team;
  final Principal principal;

  factory MyTeamSummary.fromJson(Map<String, dynamic> json) => MyTeamSummary(
        id: (json['id'] as num?)?.toInt() ?? 0,
        pilot1: Pilot.fromJson((json['pilot1'] as Map).cast<String, dynamic>()),
        pilot2: Pilot.fromJson((json['pilot2'] as Map).cast<String, dynamic>()),
        team: Team.fromJson((json['team'] as Map).cast<String, dynamic>()),
        principal: Principal.fromJson((json['team_principal'] as Map).cast<String, dynamic>()),
      );
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_models_test.dart`
Expected: PASS.

- [ ] **Step 6: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/model test/features/inter_season/inter_season_models_test.dart
git commit -m "feat(inter-season): WS transfer events + MyTeamSummary model

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: InterSeasonRepository (HTTP actions)

**Files:**
- Create: `lib/features/inter_season/data/inter_season_repository.dart`
- Test: `test/features/inter_season/inter_season_repository_test.dart`

**Interfaces:**
- Consumes: `dioProvider` (`lib/core/api/auth_state.dart`), `MyTeamSummary` (Task 2).
- Produces: `class InterSeasonRepository` with
  - `Future<MyTeamSummary> getMyTeam()` — `GET /my-team`.
  - `Future<void> buyPilot({required int pilotId, required int price})` — `POST /transfers/pilot {pilot_id, price}`.
  - `Future<void> hirePrincipal({required int principalId, required int price})` — `POST /transfers/principal {principal_id, price}`.
  - `Future<void> fire({required String who, required int id})` — `POST /fire {who, id}`.
  - `Future<void> updateBase({required int base, required int engineer, required int tube, required int sim})` — `POST /base {base, engineer, tube, sim}`.
  - `Future<void> markReady()` — `POST /ready`.
  - `final interSeasonRepositoryProvider = Provider<InterSeasonRepository>(...)`.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/inter_season_repository_test.dart` (matches the `http_mock_adapter` style used in `test/features/season/season_repository_test.dart`):

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InterSeasonRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = InterSeasonRepository(dio);
  });

  test('getMyTeam parses nested my-team', () async {
    adapter.onGet('/my-team', (s) => s.reply(200, {
          'id': 1,
          'pilot1': {'ID': 10, 'Name': 'Max'},
          'pilot2': {'ID': 11, 'Name': 'Lando'},
          'team': {'ID': 3, 'Name': 'RB', 'BaseLevel': 4},
          'team_principal': {'ID': 9, 'Name': 'Toto'},
        }));
    final t = await repo.getMyTeam();
    expect(t.pilot1.id, 10);
    expect(t.team.baseLevel, 4);
  });

  test('buyPilot posts pilot_id + price', () async {
    adapter.onPost('/transfers/pilot', (s) => s.reply(200, {'ok': true}),
        data: {'pilot_id': 7, 'price': 40});
    await repo.buyPilot(pilotId: 7, price: 40);
  });

  test('hirePrincipal posts principal_id + price', () async {
    adapter.onPost('/transfers/principal', (s) => s.reply(200, {'ok': true}),
        data: {'principal_id': 9, 'price': 20});
    await repo.hirePrincipal(principalId: 9, price: 20);
  });

  test('fire posts who + id', () async {
    adapter.onPost('/fire', (s) => s.reply(200, {'ok': true}), data: {'who': 'pilot', 'id': 10});
    await repo.fire(who: 'pilot', id: 10);
  });

  test('updateBase posts all four levels', () async {
    adapter.onPost('/base', (s) => s.reply(200, {'ok': true}),
        data: {'base': 8, 'engineer': 3, 'tube': 2, 'sim': 4});
    await repo.updateBase(base: 8, engineer: 3, tube: 2, sim: 4);
  });

  test('markReady posts to /ready', () async {
    adapter.onPost('/ready', (s) => s.reply(200, {'ok': true}));
    await repo.markReady();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_repository_test.dart`
Expected: FAIL (InterSeasonRepository not found).

- [ ] **Step 3: Implement the repository**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../model/my_team_summary.dart';

class InterSeasonRepository {
  InterSeasonRepository(this._dio);
  final Dio _dio;

  Future<MyTeamSummary> getMyTeam() async {
    final res = await _dio.get('/my-team');
    return MyTeamSummary.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<void> buyPilot({required int pilotId, required int price}) =>
      _dio.post('/transfers/pilot', data: {'pilot_id': pilotId, 'price': price});

  Future<void> hirePrincipal({required int principalId, required int price}) =>
      _dio.post('/transfers/principal', data: {'principal_id': principalId, 'price': price});

  Future<void> fire({required String who, required int id}) =>
      _dio.post('/fire', data: {'who': who, 'id': id});

  Future<void> updateBase({
    required int base,
    required int engineer,
    required int tube,
    required int sim,
  }) =>
      _dio.post('/base', data: {'base': base, 'engineer': engineer, 'tube': tube, 'sim': sim});

  Future<void> markReady() => _dio.post('/ready');
}

final interSeasonRepositoryProvider =
    Provider<InterSeasonRepository>((ref) => InterSeasonRepository(ref.watch(dioProvider)));
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/data test/features/inter_season/inter_season_repository_test.dart
git commit -m "feat(inter-season): InterSeasonRepository (transfers/fire/base/ready)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 4: Inter-season data providers

**Files:**
- Create: `lib/features/inter_season/application/inter_season_data_providers.dart`
- Test: `test/features/inter_season/inter_season_data_providers_test.dart`

**Interfaces:**
- Consumes: `interSeasonRepositoryProvider` (Task 3), `draftRepositoryProvider` (`lib/features/draft/data/draft_repository.dart`, has `getPilots`, `getPrincipals`, `getBudget`), core `Pilot`/`Principal`, `Budget` (`lib/features/draft/model/budget.dart`).
- Produces:
  - `myTeamProvider` — `FutureProvider.autoDispose<MyTeamSummary>`.
  - `interSeasonBudgetProvider` — `FutureProvider.autoDispose<Budget>` (reuses draft repo `getBudget`).
  - `freePilotsProvider` — `FutureProvider.autoDispose<List<Pilot>>` = pilots with `team == null`.
  - `ownedPilotsProvider` — `FutureProvider.autoDispose<List<Pilot>>` = pilots with `team != null` (peer-owned; buying triggers a WS offer).
  - `interSeasonPrincipalsProvider` — `FutureProvider.autoDispose<List<Principal>>`.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/inter_season_data_providers_test.dart`. Override `draftRepositoryProvider` with a fake returning pilots with mixed `team` values, and assert `freePilotsProvider` keeps only `team == null` and `ownedPilotsProvider` keeps the rest:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/inter_season/application/inter_season_data_providers.dart';

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [
        Pilot(id: 1, name: 'Free', team: null),
        Pilot(id: 2, name: 'Owned', team: 3),
      ];
}

void main() {
  test('freePilotsProvider keeps team==null; owned keeps rest', () async {
    final c = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
    ]);
    addTearDown(c.dispose);
    final free = await c.read(freePilotsProvider.future);
    final owned = await c.read(ownedPilotsProvider.future);
    expect(free.map((p) => p.id), [1]);
    expect(owned.map((p) => p.id), [2]);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_data_providers_test.dart`
Expected: FAIL (providers not found).

- [ ] **Step 3: Implement the providers**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/principal.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/model/budget.dart';
import '../data/inter_season_repository.dart';
import '../model/my_team_summary.dart';

final myTeamProvider = FutureProvider.autoDispose<MyTeamSummary>(
    (ref) => ref.watch(interSeasonRepositoryProvider).getMyTeam());

final interSeasonBudgetProvider = FutureProvider.autoDispose<Budget>(
    (ref) => ref.watch(draftRepositoryProvider).getBudget());

final freePilotsProvider = FutureProvider.autoDispose<List<Pilot>>((ref) async {
  final pilots = await ref.watch(draftRepositoryProvider).getPilots();
  return pilots.where((p) => p.team == null).toList();
});

final ownedPilotsProvider = FutureProvider.autoDispose<List<Pilot>>((ref) async {
  final pilots = await ref.watch(draftRepositoryProvider).getPilots();
  return pilots.where((p) => p.team != null).toList();
});

final interSeasonPrincipalsProvider = FutureProvider.autoDispose<List<Principal>>(
    (ref) => ref.watch(draftRepositoryProvider).getPrincipals());
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_data_providers_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/application/inter_season_data_providers.dart test/features/inter_season/inter_season_data_providers_test.dart
git commit -m "feat(inter-season): data providers (my-team, budget, free/owned pilots, principals)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 5: InterSeasonController (WS offers + ready state)

**Files:**
- Create: `lib/features/inter_season/application/inter_season_controller.dart`
- Test: `test/features/inter_season/inter_season_controller_test.dart`

**Interfaces:**
- Consumes: `wsMessagesProvider` (`lib/core/ws/ws_providers.dart`), `wsServiceProvider` (same file, exposes `send(Map<String,dynamic>)`), `interSeasonRepositoryProvider` (Task 3), `transferRequestFromMessage`/`isSeasonStarted`/`transferResponsePayload` (Task 2).
- Produces:
  - `class InterSeasonState { final List<TransferRequest> incomingOffers; final bool seasonStarted; final bool ready; final bool busy; final String? error; }` with `copyWith` (sentinel for nullable `error`).
  - `class InterSeasonController extends AutoDisposeNotifier<InterSeasonState>` with:
    - `void respondToOffer(TransferRequest offer, {required bool accept})` — sends `transfer_response` via WsService, removes the offer from the queue.
    - `Future<void> markReady()` — POST `/ready` via repo, sets `ready = true` on success (`busy` during, `error` on failure).
    - `void clearError()`.
  - `final interSeasonControllerProvider = AutoDisposeNotifierProvider<InterSeasonController, InterSeasonState>(...)`.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/inter_season_controller_test.dart`. Drive WS via a `StreamController<WsMessage>` overriding `wsMessagesProvider`; capture `send` via a fake WsService; override the repo. (See `test/features/season/season_controller_test.dart` for the `wsMessagesProvider` override pattern.)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/application/inter_season_controller.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  final sent = <Map<String, dynamic>>[];
  @override
  void send(Map<String, dynamic> json) => sent.add(json);
}

class _FakeRepo extends InterSeasonRepository {
  _FakeRepo() : super(Dio());
  bool readyCalled = false;
  @override
  Future<void> markReady() async => readyCalled = true;
}

void main() {
  test('incoming transfer_request appears; respond sends transfer_response + dequeues', () async {
    final ws = StreamController<WsMessage>.broadcast();
    final fakeWs = _FakeWs();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => ws.stream),
      wsServiceProvider.overrideWithValue(fakeWs),
      interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
    ]);
    addTearDown(c.dispose);
    c.read(interSeasonControllerProvider); // start listening

    ws.add(WsMessage('transfer_request', {'type': 'transfer_request', 'pilot_id': 7, 'price': 40}));
    await Future<void>.delayed(Duration.zero);
    final offer = c.read(interSeasonControllerProvider).incomingOffers.single;
    expect(offer.pilotId, 7);

    c.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: true);
    expect(fakeWs.sent.single, {'type': 'transfer_response', 'pilot_id': 7, 'accept': true});
    expect(c.read(interSeasonControllerProvider).incomingOffers, isEmpty);
  });

  test('season_started sets flag', () async {
    final ws = StreamController<WsMessage>.broadcast();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => ws.stream),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
    ]);
    addTearDown(c.dispose);
    c.read(interSeasonControllerProvider);
    ws.add(WsMessage('season_started', {'type': 'season_started'}));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(interSeasonControllerProvider).seasonStarted, isTrue);
  });

  test('markReady calls repo and sets ready', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => const Stream.empty()),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      interSeasonRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    await c.read(interSeasonControllerProvider.notifier).markReady();
    expect(repo.readyCalled, isTrue);
    expect(c.read(interSeasonControllerProvider).ready, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_controller_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the controller**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ws/ws_providers.dart';
import '../data/inter_season_repository.dart';
import '../model/transfer_events.dart';

class InterSeasonState {
  const InterSeasonState({
    this.incomingOffers = const [],
    this.seasonStarted = false,
    this.ready = false,
    this.busy = false,
    this.error,
  });

  final List<TransferRequest> incomingOffers;
  final bool seasonStarted;
  final bool ready;
  final bool busy;
  final String? error;

  static const _sentinel = Object();

  InterSeasonState copyWith({
    List<TransferRequest>? incomingOffers,
    bool? seasonStarted,
    bool? ready,
    bool? busy,
    Object? error = _sentinel,
  }) =>
      InterSeasonState(
        incomingOffers: incomingOffers ?? this.incomingOffers,
        seasonStarted: seasonStarted ?? this.seasonStarted,
        ready: ready ?? this.ready,
        busy: busy ?? this.busy,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );
}

class InterSeasonController extends AutoDisposeNotifier<InterSeasonState> {
  @override
  InterSeasonState build() {
    ref.listen(wsMessagesProvider, (_, next) {
      final msg = next.valueOrNull;
      if (msg == null) return;
      final offer = transferRequestFromMessage(msg);
      if (offer != null) {
        state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
        return;
      }
      if (isSeasonStarted(msg)) {
        state = state.copyWith(seasonStarted: true);
      }
    });
    return const InterSeasonState();
  }

  void respondToOffer(TransferRequest offer, {required bool accept}) {
    ref.read(wsServiceProvider).send(transferResponsePayload(pilotId: offer.pilotId, accept: accept));
    state = state.copyWith(
      incomingOffers: state.incomingOffers.where((o) => o.pilotId != offer.pilotId).toList(),
    );
  }

  Future<void> markReady() async {
    state = state.copyWith(busy: true, error: null);
    try {
      await ref.read(interSeasonRepositoryProvider).markReady();
      state = state.copyWith(ready: true, busy: false);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final interSeasonControllerProvider =
    AutoDisposeNotifierProvider<InterSeasonController, InterSeasonState>(InterSeasonController.new);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/application/inter_season_controller.dart test/features/inter_season/inter_season_controller_test.dart
git commit -m "feat(inter-season): controller (WS offers, transfer_response, ready, season_started)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: Base-investment form widget

**Files:**
- Create: `lib/features/inter_season/presentation/widgets/base_investment_form.dart`
- Test: `test/features/inter_season/base_investment_form_test.dart`

**Interfaces:**
- Consumes: `MyTeamSummary` / `Team` (initial levels via `team.baseLevel`, `team.engineer`, `team.tubeLevel`, `team.simLevel`).
- Produces: `class BaseInvestmentForm extends StatefulWidget` with `final Team initial;` and `final void Function({required int base, required int engineer, required int tube, required int sim}) onSubmit;`. Four sliders clamped **base 0–10, engineer 0–5, tube 0–5, sim 0–5**, pre-filled from `initial` (clamped into range), and a Submit button that calls `onSubmit` with the current values.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/base_investment_form_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/base_investment_form.dart';

void main() {
  testWidgets('prefills from team and submits current values', (tester) async {
    Map<String, int>? submitted;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BaseInvestmentForm(
          initial: const Team(id: 1, name: 'RB', baseLevel: 6, engineer: 3, tubeLevel: 2, simLevel: 4),
          onSubmit: ({required base, required engineer, required tube, required sim}) =>
              submitted = {'base': base, 'engineer': engineer, 'tube': tube, 'sim': sim},
        ),
      ),
    ));
    // sliders render with prefilled values
    expect(find.byType(Slider), findsNWidgets(4));
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(submitted, {'base': 6, 'engineer': 3, 'tube': 2, 'sim': 4});
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/base_investment_form_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/models/team.dart';

class BaseInvestmentForm extends StatefulWidget {
  const BaseInvestmentForm({super.key, required this.initial, required this.onSubmit});

  final Team initial;
  final void Function({required int base, required int engineer, required int tube, required int sim})
      onSubmit;

  @override
  State<BaseInvestmentForm> createState() => _BaseInvestmentFormState();
}

class _BaseInvestmentFormState extends State<BaseInvestmentForm> {
  late int _base = widget.initial.baseLevel.clamp(0, 10);
  late int _engineer = widget.initial.engineer.clamp(0, 5);
  late int _tube = widget.initial.tubeLevel.clamp(0, 5);
  late int _sim = widget.initial.simLevel.clamp(0, 5);

  Widget _slider(String label, int value, int max, ValueChanged<int> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value / $max'),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: max.toDouble(),
            divisions: max,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _slider('Base', _base, 10, (v) => setState(() => _base = v)),
          _slider('Engineer', _engineer, 5, (v) => setState(() => _engineer = v)),
          _slider('Tube', _tube, 5, (v) => setState(() => _tube = v)),
          _slider('Simulator', _sim, 5, (v) => setState(() => _sim = v)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                widget.onSubmit(base: _base, engineer: _engineer, tube: _tube, sim: _sim),
            child: const Text('Submit'),
          ),
        ],
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/base_investment_form_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/presentation/widgets/base_investment_form.dart test/features/inter_season/base_investment_form_test.dart
git commit -m "feat(inter-season): base-investment slider form (base<=10, others<=5)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 7: Transfer list + incoming-offer dialog widgets

**Files:**
- Create: `lib/features/inter_season/presentation/widgets/transfer_list.dart`
- Create: `lib/features/inter_season/presentation/widgets/incoming_offer_dialog.dart`
- Test: `test/features/inter_season/transfer_widgets_test.dart`

**Interfaces:**
- Consumes: core `Pilot`, `TransferRequest` (Task 2).
- Produces:
  - `class TransferList extends StatelessWidget` — `final List<Pilot> pilots;` `final void Function(Pilot pilot, int price) onBuy;`. Each row shows pilot name + price and a price `TextField` (defaulting to `pilot.price`) + a "Buy" button calling `onBuy(pilot, enteredPrice)`.
  - `Future<bool?> showIncomingOfferDialog(BuildContext context, TransferRequest offer)` — returns `true` (accept) / `false` (decline) / `null` (dismissed). Shows pilot id + price.

- [ ] **Step 1: Write the failing test**

Create `test/features/inter_season/transfer_widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/features/inter_season/model/transfer_events.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/transfer_list.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/incoming_offer_dialog.dart';

void main() {
  testWidgets('TransferList Buy calls onBuy with default price', (tester) async {
    Pilot? bought;
    int? price;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TransferList(
          pilots: const [Pilot(id: 5, name: 'Checo', price: 33)],
          onBuy: (p, pr) {
            bought = p;
            price = pr;
          },
        ),
      ),
    ));
    await tester.tap(find.text('Buy'));
    await tester.pump();
    expect(bought!.id, 5);
    expect(price, 33);
  });

  testWidgets('showIncomingOfferDialog returns true on Accept', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async =>
                result = await showIncomingOfferDialog(ctx, const TransferRequest(7, 40)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/transfer_widgets_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `transfer_list.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../../core/models/pilot.dart';

class TransferList extends StatelessWidget {
  const TransferList({super.key, required this.pilots, required this.onBuy});

  final List<Pilot> pilots;
  final void Function(Pilot pilot, int price) onBuy;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: pilots.length,
        itemBuilder: (_, i) => _TransferRow(pilot: pilots[i], onBuy: onBuy),
      );
}

class _TransferRow extends StatefulWidget {
  const _TransferRow({required this.pilot, required this.onBuy});
  final Pilot pilot;
  final void Function(Pilot pilot, int price) onBuy;

  @override
  State<_TransferRow> createState() => _TransferRowState();
}

class _TransferRowState extends State<_TransferRow> {
  late final TextEditingController _price =
      TextEditingController(text: widget.pilot.price.toString());

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(widget.pilot.name),
        subtitle: SizedBox(
          width: 120,
          child: TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price'),
          ),
        ),
        trailing: FilledButton(
          onPressed: () =>
              widget.onBuy(widget.pilot, int.tryParse(_price.text) ?? widget.pilot.price),
          child: const Text('Buy'),
        ),
      );
}
```

- [ ] **Step 4: Implement `incoming_offer_dialog.dart`**

```dart
import 'package:flutter/material.dart';
import '../../model/transfer_events.dart';

Future<bool?> showIncomingOfferDialog(BuildContext context, TransferRequest offer) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer offer'),
        content: Text('A player offers ${offer.price} for your pilot #${offer.pilotId}.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Decline')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Accept')),
        ],
      ),
    );
```

- [ ] **Step 5: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/transfer_widgets_test.dart`
Expected: PASS.

- [ ] **Step 6: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/presentation/widgets/transfer_list.dart lib/features/inter_season/presentation/widgets/incoming_offer_dialog.dart test/features/inter_season/transfer_widgets_test.dart
git commit -m "feat(inter-season): transfer list + incoming-offer dialog

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 8: InterSeasonScreen + route wiring

**Files:**
- Create: `lib/features/inter_season/presentation/inter_season_screen.dart`
- Create: `lib/features/inter_season/presentation/widgets/principal_hire_list.dart`
- Modify: `lib/core/router/app_router.dart` (replace the `/inter-season` placeholder; this is a SHARED file — this task MUST be sequential, in the main tree)
- Test: `test/features/inter_season/inter_season_screen_test.dart`

**Interfaces:**
- Consumes: all Task 2–7 outputs; `AsyncValueView` (`lib/shared/widgets/async_value_view.dart`), `showErrorSnackbar` (`lib/shared/widgets/error_snackbar.dart`).
- Produces:
  - `class PrincipalHireList extends StatelessWidget` — `final List<Principal> principals; final int? currentPrincipalId; final void Function(Principal) onHire; final void Function(Principal) onFire;` (a row's action is "Fire" when its id == currentPrincipalId, else "Hire").
  - `class InterSeasonScreen extends ConsumerWidget` — a `DefaultTabController` with tabs **Transfers / Principal / Base / Ready**; listens to `interSeasonControllerProvider` to (a) pop an offer dialog when a new offer arrives and route the result into `respondToOffer`, and (b) navigate to `/token-setup` when `seasonStarted` becomes true (degraded new-season entry until `GET /season/state` lands in Plan 7). Buy/hire/fire/base actions call the repository and surface success/failure via snackbar, then invalidate the relevant providers.

- [ ] **Step 1: Write the failing screen test**

Create `test/features/inter_season/inter_season_screen_test.dart`. Override the providers so all lists resolve immediately (fake draft repo + fake inter-season repo + empty WS). Assert the four tab labels render.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/inter_season/presentation/inter_season_screen.dart';
import 'package:f1manager/core/models/team.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  @override
  void send(Map<String, dynamic> json) {}
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [Pilot(id: 1, name: 'Free', team: null)];
  @override
  Future<List<Principal>> getPrincipals() async => const [Principal(id: 9, name: 'Toto')];
}

class _FakeRepo extends InterSeasonRepository {
  _FakeRepo() : super(Dio());
  @override
  Future<MyTeamSummary> getMyTeam() async => const MyTeamSummary(
        id: 1,
        pilot1: Pilot(id: 10, name: 'Max'),
        pilot2: Pilot(id: 11, name: 'Lando'),
        team: Team(id: 3, name: 'RB'),
        principal: Principal(id: 9, name: 'Toto'),
      );
}

void main() {
  testWidgets('renders four tabs', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Transfers'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `principal_hire_list.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../../core/models/principal.dart';

class PrincipalHireList extends StatelessWidget {
  const PrincipalHireList({
    super.key,
    required this.principals,
    required this.currentPrincipalId,
    required this.onHire,
    required this.onFire,
  });

  final List<Principal> principals;
  final int? currentPrincipalId;
  final void Function(Principal) onHire;
  final void Function(Principal) onFire;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          for (final p in principals)
            ListTile(
              title: Text(p.name),
              subtitle: Text('Level ${p.level} · ${p.price}'),
              trailing: p.id == currentPrincipalId
                  ? OutlinedButton(onPressed: () => onFire(p), child: const Text('Fire'))
                  : FilledButton(onPressed: () => onHire(p), child: const Text('Hire')),
            ),
        ],
      );
}
```

- [ ] **Step 4: Implement `inter_season_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/inter_season_controller.dart';
import '../application/inter_season_data_providers.dart';
import '../data/inter_season_repository.dart';
import 'widgets/base_investment_form.dart';
import 'widgets/incoming_offer_dialog.dart';
import 'widgets/principal_hire_list.dart';
import 'widgets/transfer_list.dart';

class InterSeasonScreen extends ConsumerStatefulWidget {
  const InterSeasonScreen({super.key});
  @override
  ConsumerState<InterSeasonScreen> createState() => _InterSeasonScreenState();
}

class _InterSeasonScreenState extends ConsumerState<InterSeasonScreen> {
  bool _dialogOpen = false;

  Future<void> _drainOffers() async {
    if (_dialogOpen) return;
    final offers = ref.read(interSeasonControllerProvider).incomingOffers;
    if (offers.isEmpty) return;
    _dialogOpen = true;
    final offer = offers.first;
    final accept = await showIncomingOfferDialog(context, offer);
    _dialogOpen = false;
    if (accept != null) {
      ref.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: accept);
    } else {
      // dismissed → decline so the queue drains
      ref.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: false);
    }
    if (mounted) _drainOffers();
  }

  Future<void> _act(Future<void> Function() action, String ok) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
      ref.invalidate(myTeamProvider);
      ref.invalidate(interSeasonBudgetProvider);
      ref.invalidate(freePilotsProvider);
      ref.invalidate(ownedPilotsProvider);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(interSeasonControllerProvider, (prev, next) {
      if (next.incomingOffers.isNotEmpty) _drainOffers();
      if (next.seasonStarted && (prev?.seasonStarted != true)) {
        context.go('/token-setup');
      }
      if (next.error != null && prev?.error != next.error) {
        showErrorSnackbar(context, next.error!);
        ref.read(interSeasonControllerProvider.notifier).clearError();
      }
    });

    final repo = ref.read(interSeasonRepositoryProvider);
    final myTeam = ref.watch(myTeamProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inter-Season'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Transfers'),
            Tab(text: 'Principal'),
            Tab(text: 'Base'),
            Tab(text: 'Ready'),
          ]),
        ),
        body: TabBarView(
          children: [
            // Transfers: free + owned pilots
            Consumer(builder: (_, r, __) {
              final free = r.watch(freePilotsProvider);
              return AsyncValueView(
                value: free,
                data: (pilots) => TransferList(
                  pilots: pilots,
                  onBuy: (p, price) =>
                      _act(() => repo.buyPilot(pilotId: p.id, price: price), 'Offer sent'),
                ),
              );
            }),
            // Principal hire/fire
            Consumer(builder: (_, r, __) {
              final principals = r.watch(interSeasonPrincipalsProvider);
              return AsyncValueView(
                value: principals,
                data: (list) => PrincipalHireList(
                  principals: list,
                  currentPrincipalId: myTeam.valueOrNull?.principal.id,
                  onHire: (p) =>
                      _act(() => repo.hirePrincipal(principalId: p.id, price: p.price), 'Hired'),
                  onFire: (p) => _act(() => repo.fire(who: 'principal', id: p.id), 'Fired'),
                ),
              );
            }),
            // Base sliders
            AsyncValueView(
              value: myTeam,
              data: (t) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: BaseInvestmentForm(
                  initial: t.team,
                  onSubmit: ({required base, required engineer, required tube, required sim}) => _act(
                    () => repo.updateBase(base: base, engineer: engineer, tube: tube, sim: sim),
                    'Base updated',
                  ),
                ),
              ),
            ),
            // Ready
            Center(
              child: Consumer(builder: (_, r, __) {
                final st = r.watch(interSeasonControllerProvider);
                return FilledButton(
                  onPressed: st.ready || st.busy
                      ? null
                      : () => r.read(interSeasonControllerProvider.notifier).markReady(),
                  child: Text(st.ready ? 'Waiting for other players…' : 'Ready for new season'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
```

Verify the `AsyncValueView` constructor signature against `lib/shared/widgets/async_value_view.dart` and adjust the `value:`/`data:` argument names if they differ.

- [ ] **Step 5: Wire the route**

In `lib/core/router/app_router.dart`, add the import and replace the placeholder:

```dart
import '../../features/inter_season/presentation/inter_season_screen.dart';
```
```dart
      GoRoute(path: '/inter-season', builder: (_, __) => const InterSeasonScreen()),
```

- [ ] **Step 6: Run the screen test + full suite**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/inter_season_screen_test.dart && flutter test --concurrency=1
```
Expected: PASS.

- [ ] **Step 7: Web build + analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze && flutter build web --dart-define=API_HOST=localhost:8080
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/inter_season/presentation lib/core/router/app_router.dart test/features/inter_season/inter_season_screen_test.dart
git commit -m "feat(inter-season): screen (transfers/principal/base/ready) + route

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 9: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Analyze clean**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze`
Expected: "No issues found!"

- [ ] **Step 2: Full test suite**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test --concurrency=1`
Expected: all tests PASS (≈ 92 prior + the new inter-season tests).

- [ ] **Step 3: Web build**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter build web --dart-define=API_HOST=localhost:8080`
Expected: build succeeds.

- [ ] **Step 4: Clean tree**

```bash
git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile
git status --short
```
Expected: clean (no stray `ios/Podfile` / xcconfig changes).

---

## Degraded modes (documented; wire when their backend dependency lands)

- **`season_started` navigation** currently sends the user to `/token-setup`. Once `GET /season/state` lands (Plan 7), the phase-based router redirect supersedes this manual navigation.
- **Buying an owned pilot** shows "Offer sent" — the actual accept/decline round-trips over WS to the owner and completes server-side (60s timeout). We do not yet reflect the owner's response back to the buyer's UI (no such WS message exists); a follow-up could add a `transfer_result` broadcast.
- If the backend PR (Task 1) is not merged when the frontend runs, `/fire` and `/ready` return 404/errors surfaced via snackbar; transfers and base already work against the merged endpoints.

## Self-Review

- **Spec §5.7 coverage:** free/peer pilot transfers (T3 `buyPilot`, T7 `TransferList`, T4 free/owned split) ✓; incoming `transfer_request` → WS `transfer_response` (T2 events, T5 controller, T7 dialog, T8 wiring) ✓; hire principal (T3 `hirePrincipal`, T8 `PrincipalHireList`) ✓; fire pilot/principal (T1 backend `/fire`, T3 `fire`, T8) ✓; base sliders base≤10/others≤5 → `/base` (T6, T3 `updateBase`) ✓; current base from `/my-team` (T2 `MyTeamSummary`, T3 `getMyTeam`, T4 `myTeamProvider`) ✓; `/ready` + `season_started` (T1 backend, T3 `markReady`, T5, T8) ✓.
- **Placeholder scan:** every code step contains full code; no TBD/TODO.
- **Type consistency:** `MyTeamSummary` fields (`pilot1/pilot2/team/principal`) consistent across T2/T3/T8; `respondToOffer(offer, {required accept})`, `markReady()`, `transferResponsePayload({pilotId, accept})`, `BaseInvestmentForm.onSubmit({base,engineer,tube,sim})`, `TransferList.onBuy(pilot, price)` used identically wherever referenced.
