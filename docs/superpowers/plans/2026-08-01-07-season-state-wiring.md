# Season State + Phase Wiring (final plan) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the backend `GET /season/state` + WS `?token=` query auth, then wire the frontend so navigation is phase-driven (router redirect + reconnect refresh), the shell/tabs become reachable, offstage game screens can't hijack navigation, and the race flow shows next-track-by-stage + an "N of M submitted" waiting counter.

**Architecture:** Backend adds an in-memory `PhaseTracker` (keyed by groupID) that the draft/setup/ready dispatchers write to at their existing transition points; a `GET /season/state` handler assembles `{phase, stage, submitted_setups, total_players}` from the tracker + the setup dispatcher's live round state. The JWT middleware gains a `?token=` fallback so browsers can authenticate the WS. Frontend adds `SeasonStateRepository` + a `seasonStateProvider` (fetch + refresh on WS reconnect/phase events), wires the router `redirect` to the real phase (restricted so it never yanks a user off an always-available tab), guards offstage game-screen `context.go` transitions, and reads `stage`/`submitted_setups`/`total_players` for next-track + waiting UI.

**Tech Stack:** Backend: Go + Gin, gorilla/websocket, redis. Frontend: Flutter, Riverpod, GoRouter, Dio, freezed (the `SeasonState` DTO already exists at `lib/core/models/season_state.dart`).

## Global Constraints

- **Git:** Claude commits **and** pushes directly in the frontend repo. Backend changes go **via a PR** (branch + PR, never straight to main). End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Backend PR base:** `feat/fire-ready-endpoints` (the PR #5 branch), NOT `feature/draft-module` — because `season/state`'s `inter_season` phase must wire the `ReadyTracker`/`season_started` that only exists on the PR #5 branch. This stacks PR#7 on #5 on #3 (all unmerged); flag to the owner so the stack is merged/rebased in order.
- **Subagent model floor:** code-writing subagents ≥ Sonnet. Reviewers: Sonnet. Final integration review: Opus.
- **Flutter env:** SDK at `$HOME/development/flutter`. Prefix every flutter/dart command with `export PATH="$HOME/development/flutter/bin:$PATH" &&`. Work from `/Users/maks/f1managerfront`.
- **Test flake:** full suite `flutter test --concurrency=1`. iOS pod side-effect: revert before every commit — `git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile`.
- **Contract (spec §7):** `GET /season/state` → `{"phase":"draft"|"token_setup"|"racing"|"inter_season", "stage":int, "submitted_setups":[user_id...], "total_players":int}`. The frontend `SeasonState`/`SeasonPhase` DTO (`lib/core/models/season_state.dart`) already maps this exactly (`@JsonValue` enum + `submitted_setups`/`total_players` `@JsonKey`s). Unknown phase → `SeasonPhase.unknown`.
- **Every task** ends `flutter analyze` clean + `flutter test --concurrency=1` passing + committed. The last frontend task also runs `flutter build web --dart-define=API_HOST=localhost:8080`.

---

## File Structure

Backend PR (`/Users/maks/f1manager`, base `feat/fire-ready-endpoints`):
- Modify: `pkg/middleware/jwt/middleware.go` — `?token=` fallback.
- Create: `internal/web/dispatcher/phase.go` (+ `phase_test.go`) — `PhaseTracker`.
- Modify: `internal/web/dispatcher/draft.go`, `dispatcher.go`, `ready.go` — call `PhaseTracker.Set(...)` at transitions; expose setup round state.
- Modify: `internal/web/handler/http/handler.go` (+ interface file), `internal/server/router.go`, `internal/server/server.go` — `GET /season/state` handler + wiring.

Frontend (`feat/frontend`):
- Create: `lib/features/season/data/season_state_repository.dart` — `getSeasonState()`.
- Create: `lib/features/season/application/season_state_provider.dart` — `SeasonStateController` (fetch + refresh) + `seasonStateProvider`.
- Modify: `lib/core/router/app_router.dart` — feed real phase into `redirectLogic`; restrict redirect to Play-branch/auth/lobby; keep pure fn testable.
- Modify: `lib/core/ws/ws_providers.dart` — wire `onReconnect` to refresh season state.
- Modify: `lib/features/draft/presentation/draft_screen.dart`, `lib/features/season/presentation/race_screen.dart`, `lib/features/inter_season/presentation/inter_season_screen.dart` — guard `context.go` on being in the Play branch (offstage-nav fix).
- Modify: `lib/features/season/presentation/race_screen.dart` (+ token setup) — next-track-by-stage + "N of M submitted".

---

## Task 1: Backend PR — `GET /season/state` + WS `?token=`

**Repo:** `/Users/maks/f1manager`. **Base branch:** `feat/fire-ready-endpoints`. New branch e.g. `feat/season-state`. Produces a **GitHub PR**, independent of all frontend tasks — run it as a background agent.

**Interfaces produced (frontend consumes):**
- `GET /api/v1/season/state` → `{phase, stage, submitted_setups, total_players}` (200; under the JWT+group middleware).
- `GET /api/v1/ws?token=<jwt>` authenticates when the `Authorization` header is absent.

- [ ] **Step 1: Branch off the PR #5 branch**

```bash
cd /Users/maks/f1manager
git fetch origin
git checkout feat/fire-ready-endpoints && git pull --ff-only 2>/dev/null || true
git checkout -b feat/season-state
```

- [ ] **Step 2: Write the failing middleware test (`?token=` fallback)**

Add a test in `pkg/middleware/jwt/` (mirror any existing middleware test; if none, create `middleware_test.go`) asserting that a request with **no** `Authorization` header but a valid `?token=<jwt>` query param passes the middleware (sets `UserIDKey`), and that an invalid `?token=` is rejected 401. Run:

```bash
cd /Users/maks/f1manager && go test ./pkg/middleware/jwt/... 2>&1 | tail -20
```
Expected: FAIL.

- [ ] **Step 3: Implement the `?token=` fallback**

In `pkg/middleware/jwt/middleware.go` `Handler()`, before rejecting on a missing/!Bearer header, fall back to the query param:

```go
		var raw string
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" {
			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				m.logger.Warn("invalid auth header format")
				unauthorized(c)
				return
			}
			raw = parts[1]
		} else if q := c.Query("token"); q != "" {
			raw = q // browsers cannot set WS headers; accept ?token= (same validation)
		} else {
			m.logger.Debug("missing authorization header and token query", "path", c.Request.URL.Path)
			unauthorized(c)
			return
		}

		claims, err := m.verifyToken(raw)
		// ... unchanged from here
```

Run the middleware test → expected PASS.

- [ ] **Step 4: Write the failing `PhaseTracker` test**

Create `internal/web/dispatcher/phase_test.go`: a new `PhaseTracker`, `Set(groupID, phase, stage)` then `Get(groupID)` returns them; `Get` on an unknown group returns `("", 0, false)`. Concurrency-safe (guarded by a mutex). Run:

```bash
cd /Users/maks/f1manager && go test ./internal/web/dispatcher/... 2>&1 | tail -20
```
Expected: FAIL.

- [ ] **Step 5: Implement `PhaseTracker`**

Create `internal/web/dispatcher/phase.go`:

```go
package dispatcher

import "sync"

// Phase constants for GET /season/state.
const (
	PhaseDraft       = "draft"
	PhaseTokenSetup  = "token_setup"
	PhaseRacing      = "racing"
	PhaseInterSeason = "inter_season"
)

type phaseEntry struct {
	phase string
	stage int64
}

// PhaseTracker holds the current phase+stage per group (in-memory).
type PhaseTracker struct {
	mu     sync.RWMutex
	groups map[int64]phaseEntry
}

func NewPhaseTracker() *PhaseTracker {
	return &PhaseTracker{groups: make(map[int64]phaseEntry)}
}

func (p *PhaseTracker) Set(groupID int64, phase string, stage int64) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.groups[groupID] = phaseEntry{phase: phase, stage: stage}
}

// Get returns the current phase+stage and whether the group is tracked.
func (p *PhaseTracker) Get(groupID int64) (string, int64, bool) {
	p.mu.RLock()
	defer p.mu.RUnlock()
	e, ok := p.groups[groupID]
	return e.phase, e.stage, ok
}
```

Run the test → PASS.

- [ ] **Step 6: Wire `PhaseTracker` into the dispatchers at transition points**

Inject a `*PhaseTracker` into `DraftDispatcher`, the setup `Dispatcher`, and `ReadyTracker` (add a field + constructor param; update `server.go` construction in Step 8). Call `Set` at the existing transition points (do NOT change any other behavior):
- `DraftDispatcher.StartDraft` (after building the order): `d.phase.Set(groupID, PhaseDraft, 0)`.
- `DraftDispatcher` where it broadcasts `draft_finished` (`draft.go`, the `finished` branch): `d.phase.Set(groupID, PhaseTokenSetup, 0)`.
- setup `Dispatcher.InitRound(groupID, stage, totalPlayers)`: `d.phase.Set(groupID, PhaseRacing, stage)`.
- `ReadyTracker.Ready` when all-ready fires (after `ResetSeason`, before/after broadcasting `season_started`): `r.phase.Set(groupID, PhaseTokenSetup, 0)` (a new season resets to token setup). Also, right after a race finishes and the season's final stage is reached you MAY set `PhaseInterSeason` — if there is no clean "final stage" signal available, leave the transition into `inter_season` to be set wherever the inter-season flow is actually initiated on the backend; if none exists, document that `inter_season` is only reachable once that trigger is added, and keep `racing` as the post-race phase. Prefer correctness over inventing a signal.

Make the `PhaseTracker` param optional-safe: guard each call with `if d.phase != nil`.

- [ ] **Step 7: Expose the setup dispatcher's live round state**

Add to the setup `Dispatcher` a read-only method:

```go
// RoundState returns the submitted user ids and total players for the group's
// active round, and whether a round is currently open.
func (d *Dispatcher) RoundState(groupID int64) (submitted []int64, total int, ok bool) {
	d.mu.RLock()
	st, exists := d.groups[groupID]
	d.mu.RUnlock()
	if !exists {
		return nil, 0, false
	}
	st.mu.Lock()
	defer st.mu.Unlock()
	ids := make([]int64, 0, len(st.received))
	for id := range st.received {
		ids = append(ids, id)
	}
	return ids, st.totalPlayers, true
}
```

(Verify field names `received`/`totalPlayers`/`groups` against `dispatcher.go` and adapt.)

- [ ] **Step 8: Add the `GET /season/state` handler + wiring**

Add a handler dependency interface the handler can consult (phase tracker + setup dispatcher round state + manager group size). In `internal/web/handler/http/handler.go`:

```go
func (h *HttpHandler) GetSeasonState(c *gin.Context) {
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
	phase, stage, _ := h.phase.Get(*groupID)
	submitted, total, ok := h.dispatcher.RoundState(*groupID)
	if !ok {
		submitted = []int64{}
		total = h.manager.GroupSize(*groupID)
	}
	c.JSON(200, gin.H{
		"phase":            phase,
		"stage":            stage,
		"submitted_setups": submitted,
		"total_players":    total,
	})
}
```

Add a `phase` field (typed to a small interface `PhaseReader interface { Get(int64) (string, int64, bool) }`) to `HttpHandler` + `NewHttpHandler`, and extend the `SetupDispatcher` interface (in `internal/web/handler/http/sim.go`) with `RoundState(int64) ([]int64, int, bool)`. Register the route in `internal/server/router.go` (data section): `game.GET("/season/state", h.GetSeasonState)`. Construct the shared `PhaseTracker` in `internal/server/server.go`, pass it to `dispatcher.New`, `dispatcher.NewDraft`, `dispatcher.NewReady`, and `NewHttpHandler`.

- [ ] **Step 9: Build + full backend test suite**

```bash
cd /Users/maks/f1manager && go build ./... && go test ./... 2>&1 | tail -30
```
Expected: build OK, tests PASS (a pre-existing flaky `TestFullDraftCycle` may need a re-run — note it if it flakes, as prior PRs did).

- [ ] **Step 10: Commit + push + open PR**

```bash
cd /Users/maks/f1manager
git add pkg/ internal/ && git commit -m "feat(season): GET /season/state (PhaseTracker) + WS ?token= auth

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git push -u origin feat/season-state
gh pr create --base feat/fire-ready-endpoints --title "feat(season): /season/state + WS ?token=" --body "$(cat <<'EOF'
Adds the phase/state endpoint the Flutter router needs, and browser WS auth.

- GET /season/state {phase,stage,submitted_setups,total_players} via an in-memory PhaseTracker written at draft/setup/ready transitions
- WS ?token= query fallback in the JWT middleware (browsers can't set WS headers)

Base is feat/fire-ready-endpoints (PR #5) because season_started/inter_season wiring depends on the ReadyTracker from #5. Stacked PR #3 <- #5 <- this; merge/rebase in order.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Record the PR URL in the ledger.

---

## Task 2: SeasonStateRepository + provider

**Files:**
- Create: `lib/features/season/data/season_state_repository.dart`
- Create: `lib/features/season/application/season_state_provider.dart`
- Test: `test/features/season/season_state_repository_test.dart`, `test/features/season/season_state_provider_test.dart`

**Interfaces:**
- Consumes: `dioProvider`, `SeasonState`/`SeasonPhase` (`lib/core/models/season_state.dart`).
- Produces:
  - `class SeasonStateRepository { Future<SeasonState> getSeasonState(); }` (`GET /season/state`) + `seasonStateRepositoryProvider`.
  - `class SeasonStateController extends AutoDisposeAsyncNotifier<SeasonState>` whose `build()` fetches once and exposes `Future<void> refresh()` (re-fetch). `final seasonStateProvider = AutoDisposeAsyncNotifierProvider<SeasonStateController, SeasonState>(...)`.

- [ ] **Step 1: Write the failing repository test**

Create `test/features/season/season_state_repository_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';

void main() {
  test('getSeasonState parses phase/stage/submitted/total', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/season/state', (s) => s.reply(200, {
          'phase': 'racing',
          'stage': 3,
          'submitted_setups': [1, 2],
          'total_players': 4,
        }));
    final st = await SeasonStateRepository(dio).getSeasonState();
    expect(st.phase, SeasonPhase.racing);
    expect(st.stage, 3);
    expect(st.submittedSetups, [1, 2]);
    expect(st.totalPlayers, 4);
  });

  test('unknown phase string maps to SeasonPhase.unknown', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/season/state', (s) => s.reply(200, {'phase': 'weird'}));
    final st = await SeasonStateRepository(dio).getSeasonState();
    expect(st.phase, SeasonPhase.unknown);
  });
}
```

- [ ] **Step 2: Run → FAIL**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/season/season_state_repository_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the repository**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/season_state.dart';

class SeasonStateRepository {
  SeasonStateRepository(this._dio);
  final Dio _dio;

  Future<SeasonState> getSeasonState() async {
    final res = await _dio.get('/season/state');
    return SeasonState.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

final seasonStateRepositoryProvider =
    Provider<SeasonStateRepository>((ref) => SeasonStateRepository(ref.watch(dioProvider)));
```

- [ ] **Step 4: Write the failing provider test**

Create `test/features/season/season_state_provider_test.dart`: override `seasonStateRepositoryProvider` with a fake returning a known `SeasonState`; assert `seasonStateProvider.future` resolves to it; call `refresh()` after changing the fake's return and assert the new value.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';
import 'package:f1manager/features/season/application/season_state_provider.dart';

class _FakeRepo extends SeasonStateRepository {
  _FakeRepo() : super(Dio());
  SeasonState value = const SeasonState(phase: SeasonPhase.draft);
  @override
  Future<SeasonState> getSeasonState() async => value;
}

void main() {
  test('provider fetches then refresh re-fetches', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: [
      seasonStateRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    expect((await c.read(seasonStateProvider.future)).phase, SeasonPhase.draft);
    repo.value = const SeasonState(phase: SeasonPhase.racing, stage: 2);
    await c.read(seasonStateProvider.notifier).refresh();
    expect(c.read(seasonStateProvider).value!.phase, SeasonPhase.racing);
  });
}
```

- [ ] **Step 5: Implement the controller/provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/season_state.dart';
import '../data/season_state_repository.dart';

class SeasonStateController extends AutoDisposeAsyncNotifier<SeasonState> {
  @override
  Future<SeasonState> build() =>
      ref.watch(seasonStateRepositoryProvider).getSeasonState();

  Future<void> refresh() async {
    state = const AsyncLoading<SeasonState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(seasonStateRepositoryProvider).getSeasonState());
  }
}

final seasonStateProvider =
    AutoDisposeAsyncNotifierProvider<SeasonStateController, SeasonState>(
        SeasonStateController.new);
```

- [ ] **Step 6: Run both tests → PASS, analyze, commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/season/season_state_repository_test.dart test/features/season/season_state_provider_test.dart && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/season/data/season_state_repository.dart lib/features/season/application/season_state_provider.dart test/features/season/season_state_repository_test.dart test/features/season/season_state_provider_test.dart
git commit -m "feat(season): SeasonStateRepository + seasonStateProvider

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: Wire phase into the router redirect (+ offstage-nav guard)

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Test: `test/core/router/app_router_phase_test.dart` (new); keep `app_router_test.dart`, `app_router_group_test.dart`, `app_router_shell_test.dart` green.

**Interfaces:**
- Consumes: `seasonStateProvider` (Task 2), `SeasonPhase`, existing `redirectLogic`/`routeForPhase`.
- Produces: the router `redirect` reads the current phase from `seasonStateProvider` (`valueOrNull?.phase`) and passes it to `redirectLogic`, BUT only redirects toward a phase route when the current location is a Play-branch route or `/auth`/`/lobby` — never when the user is on `/standings`, `/info`, or `/my-team`. `redirectLogic` stays a pure, unit-tested function; add the "always-available location" guard either inside it (new param) or in the caller.

- [ ] **Step 1: Write the failing pure-logic test**

Add to a new `test/core/router/app_router_phase_test.dart` cases for the updated pure function. Decide the signature: extend `redirectLogic` with `bool onAlwaysAvailableTab` (true when location ∈ {`/standings`,`/info`,`/my-team`}); when true and authed+group, it returns `null` regardless of phase. Test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/router/app_router.dart';

void main() {
  test('authed+group phase=racing redirects to /season from a play route', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: SeasonPhase.racing,
          location: '/draft', onAlwaysAvailableTab: false),
      '/season',
    );
  });

  test('does NOT redirect when on an always-available tab', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: SeasonPhase.racing,
          location: '/standings', onAlwaysAvailableTab: true),
      isNull,
    );
  });

  test('not authed still forced to /auth even on a tab', () {
    expect(
      redirectLogic(authed: false, hasGroup: false, phase: null,
          location: '/standings', onAlwaysAvailableTab: true),
      '/auth',
    );
  });
}
```

- [ ] **Step 2: Run → FAIL**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/app_router_phase_test.dart`
Expected: FAIL (signature mismatch).

- [ ] **Step 3: Update `redirectLogic` + the router `redirect`**

In `lib/core/router/app_router.dart`, extend the pure function (keep the existing auth/group precedence):

```dart
String? redirectLogic({
  required bool authed,
  required bool hasGroup,
  required SeasonPhase? phase,
  required String location,
  bool onAlwaysAvailableTab = false,
}) {
  if (!authed) return location == '/auth' ? null : '/auth';
  if (!hasGroup) return location == '/lobby' ? null : '/lobby';
  if (onAlwaysAvailableTab) return null; // never yank the user off a tab
  if (phase == null) return null;
  final target = routeForPhase(phase);
  return location == target ? null : target;
}
```

In the `redirect` callback, compute the phase + tab flag and pass them:

```dart
    redirect: (context, state) {
      final authed = ref.read(isAuthenticatedProvider);
      final hasGroup = ref.read(hasGroupProvider);
      final phase = ref.read(seasonStateProvider).valueOrNull?.phase;
      final loc = state.uri.path;
      const tabs = {'/standings', '/info', '/my-team'};
      return redirectLogic(
        authed: authed,
        hasGroup: hasGroup,
        phase: phase,
        location: loc,
        onAlwaysAvailableTab: tabs.contains(loc),
      );
    },
```

Add `seasonStateProvider` to `_AuthListenable` so a phase change refreshes routing:

```dart
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
    ref.listen(hasGroupProvider, (_, __) => notifyListeners());
    ref.listen(seasonStateProvider, (_, __) => notifyListeners());
  }
}
```

Add the import for `seasonStateProvider`.

- [ ] **Step 4: Run the new test + all router tests**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/
```
Expected: PASS. If `app_router_test.dart` called `redirectLogic` positionally/without the new named param, the default (`false`) keeps it compiling; confirm those tests still pass unchanged.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/core/router/app_router.dart test/core/router/app_router_phase_test.dart
git commit -m "feat(router): phase-driven redirect (guarded off always-available tabs)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 4: Offstage-nav guard in game screens

**Files:**
- Modify: `lib/features/draft/presentation/draft_screen.dart`, `lib/features/season/presentation/race_screen.dart`, `lib/features/inter_season/presentation/inter_season_screen.dart`
- Test: extend the relevant screen tests (or add `test/features/*/offstage_nav_test.dart`) to prove no navigation happens when offstage.

**Interfaces:**
- Consumes: `GoRouterState.of(context)` (current location) or `GoRouter.of(context).routerDelegate.currentConfiguration` — a way to read whether this screen's own route is the active location.
- Produces: each screen's `ref.listen(... → context.go(...))` transition fires ONLY when this screen's route is the current location (i.e., the Play branch is on-screen), so a WS event received while the screen is offstage (user on another tab) does not steal navigation.

- [ ] **Step 1: Write the failing test**

For `InterSeasonScreen` (it has the clearest transition: `season_started → context.go('/token-setup')`), write a widget test placing it under a `StatefulShellRoute` where the active branch is a DIFFERENT branch (e.g. `/standings`), deliver `season_started` via the WS stream, and assert the location does NOT change to `/token-setup`. Then a second test with the InterSeason branch active asserts it DOES navigate. (Mirror the existing `inter_season_screen_test.dart` fakes.)

- [ ] **Step 2: Run → FAIL** (currently it navigates regardless).

- [ ] **Step 3: Add the guard helper + apply it**

Add a small helper (e.g. in each screen or a shared `lib/core/router/nav_guard.dart`):

```dart
bool isCurrentLocation(BuildContext context, String path) =>
    GoRouterState.of(context).uri.path == path;
```

In each screen's `ref.listen` navigation block, wrap the `context.go(...)` call:

```dart
      if (next.seasonStarted && (prev?.seasonStarted != true)) {
        if (isCurrentLocation(context, '/inter-season')) context.go('/token-setup');
      }
```

Apply the analogous guard in `draft_screen.dart` (its `draft_finished → /token-setup`) and `race_screen.dart` (any `context.go`). Only wrap the WS-driven auto-navigation; leave user-initiated button navigation as-is.

- [ ] **Step 4: Run tests → PASS, analyze, commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/inter_season/ test/features/draft/ test/features/season/ && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/draft/presentation/draft_screen.dart lib/features/season/presentation/race_screen.dart lib/features/inter_season/presentation/inter_season_screen.dart lib/core/router/nav_guard.dart test/
git commit -m "fix(nav): offstage game screens no longer hijack navigation

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 5: WS-reconnect refresh + next-track + waiting counter

**Files:**
- Modify: `lib/core/ws/ws_providers.dart` (wire `onReconnect`)
- Modify: `lib/features/season/presentation/race_screen.dart` (next-track-by-stage + "N of M submitted")
- Test: extend `test/features/season/race_screen_test.dart`; add a ws_providers reconnect test if feasible.

**Interfaces:**
- Consumes: `seasonStateProvider` (`.refresh()`, `stage`, `submittedSetups`, `totalPlayers`), `WsService.onReconnect`.
- Produces: on WS (re)connect the app refreshes season state; the race screen selects the track for `seasonState.stage` (instead of manual pick) and shows a "waiting: N of M submitted" indicator from `submittedSetups.length`/`totalPlayers`.

- [ ] **Step 1: Wire `onReconnect`**

In `lib/core/ws/ws_providers.dart`, pass an `onReconnect` that refreshes season state. Because `WsService` is created in a `Provider`, use the `ref` to read the season controller lazily:

```dart
final wsServiceProvider = Provider<WsService>((ref) {
  final config = ref.watch(apiConfigProvider);
  final store = ref.watch(tokenStoreProvider);
  return WsService(
    wsUrl: config.wsUrl,
    accessToken: store.readAccess,
    connect: (uri) => connectWithAuth(config.wsUrl, uri.queryParameters['token']),
    onReconnect: () => ref.read(seasonStateProvider.notifier).refresh(),
  );
});
```

- [ ] **Step 2: Next-track-by-stage + waiting counter in RaceScreen**

Write failing widget tests: (a) with `seasonStateProvider` overridden to `stage: 5`, the race screen shows the track whose stage/index corresponds to 5 (adapt to how `getTracks()` is indexed — stage→track mapping; if 1-based, `tracks[stage-1]`); (b) with `submittedSetups:[1,2]`, `totalPlayers:4` and the user having submitted, a "2 / 4 submitted" waiting indicator renders. Then implement by reading `ref.watch(seasonStateProvider).valueOrNull` in `race_screen.dart`, replacing/augmenting the manual track picker with the stage-driven selection (keep manual pick as a fallback when season state is unavailable — the degraded mode) and adding the counter to the waiting state.

Run the focused tests → PASS.

- [ ] **Step 3: Full suite + analyze + web build**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test --concurrency=1 && flutter analyze && flutter build web --dart-define=API_HOST=localhost:8080
```
Expected: all pass, analyze clean, web build OK.

- [ ] **Step 4: Commit**

```bash
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/core/ws/ws_providers.dart lib/features/season/presentation/race_screen.dart test/
git commit -m "feat(season): reconnect refresh + next-track-by-stage + waiting counter

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: Final verification

- [ ] **Step 1: Analyze** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze` → "No issues found!"
- [ ] **Step 2: Full suite** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test --concurrency=1` → all pass.
- [ ] **Step 3: Web build** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter build web --dart-define=API_HOST=localhost:8080` → succeeds.
- [ ] **Step 4: Clean tree** — revert iOS pod artifacts; `git status --short` → clean.

---

## Notes / degraded modes

- If the backend PR (Task 1) is not merged when the frontend runs, `GET /season/state` 404s → `seasonStateProvider` errors → `redirectLogic` receives `phase == null` (via `valueOrNull`) → falls back to today's behavior (authed+group with no phase stays put; manual track pick; generic waiting). The app still builds and runs.
- `inter_season` phase is only emitted if the backend has a real trigger into the inter-season flow (see Task 1 Step 6); otherwise post-race stays `racing` until then — document whatever the backend actually does.
- The in-memory `PhaseTracker` loses phase on backend restart; the frontend re-fetches on reconnect and degrades gracefully to `unknown` (→ lobby) until the next transition re-populates it. Acceptable for this game.

## Self-Review

- **Spec §7 coverage:** `GET /season/state {phase,stage,submitted_setups,total_players}` (T1 backend) ✓; WS `?token=` (T1) ✓; router `phase` redirect (T3) ✓; next-track-by-stage + waiting counter (T5) ✓. Plan-6 carry-overs: shell reachable via phase redirect (T3) ✓; offstage-nav guard (T4) ✓.
- **Placeholder scan:** all steps carry concrete code; backend Step 6/7 name the exact transition points + method and tell the implementer to verify field names against the real files (bounded, not a placeholder).
- **Type consistency:** frontend `SeasonState`/`SeasonPhase` reused from `lib/core/models/season_state.dart` (already matches the contract); `redirectLogic`'s new `onAlwaysAvailableTab` param used consistently in T3 caller + tests; `seasonStateProvider` (`refresh()`) used consistently across T2/T3/T5.
