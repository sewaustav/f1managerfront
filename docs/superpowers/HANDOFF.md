# HANDOFF — F1 Manager Flutter frontend

Date: 2026-08-01. Branch: **`feat/frontend`** (HEAD `9510e45`, 78 commits above `main`).
Status: **ALL 7 plans complete.** 147 tests green, `flutter analyze` clean, `flutter build web` passes. Ready for `superpowers:finishing-a-development-branch` — branch NOT pushed/PR'd; confirm with owner.

You are continuing a multi-plan build of the F1 Manager Flutter app (iOS/Android/Web) against an existing Go backend. Work proceeds as a **series of 7 plans**, each built with the **superpowers:subagent-driven-development** (SDD) workflow: write a plan → dispatch a fresh implementer subagent per task (TDD) → per-task review subagent → integrate → final whole-branch integration review → fix findings.

## 0. First actions on resume

1. Read this file fully.
2. Read the durable ledger: `cat .superpowers/sdd/progress.md` (git-ignored; the authoritative record of what's done, per-task commit SHAs, and deferred items). Trust it + `git log` over any assumption.
3. Read the project memory index: `/Users/maks/.claude/projects/-Users-maks-f1managerfront/memory/MEMORY.md` and the three memory files it points to (git workflow, model floor, build progress).
4. Read the spec: `docs/superpowers/specs/2026-07-30-f1manager-frontend-design.md` (single source of truth for contracts; §4 JSON casing and §5 WS auth are critical).
5. Confirm state: `git -C /Users/maks/f1managerfront log --oneline -5` and `export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze && flutter test --concurrency=1`.

## 1. Hard conventions (do not deviate)

- **Git:** The owner authorized Claude to `git commit` **and** `git push` directly in this frontend repo (this OVERRIDES the global `~/.claude/CLAUDE.md` "user commits himself" rule). Backend changes go **via PR** (branch + PR, never straight to main), also authored by Claude. End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Subagent model floor:** code-writing subagents use **at least Sonnet** (never Haiku). Reviewers: Sonnet. Final whole-branch review: the most capable available (this session used Sonnet to conserve after session-limit pressure — Opus is ideal if budget allows).
- **Flutter env:** SDK at `$HOME/development/flutter`. Shell env vars DO NOT persist between tool calls — **prefix every** flutter/dart command with `export PATH="$HOME/development/flutter/bin:$PATH" &&`. Work from `/Users/maks/f1managerfront`.
- **Test flake:** the default-concurrency `flutter test` is flaky in this sandbox (drops/dupes shards). Always use `flutter test --concurrency=1` for the full suite. Focused single-file runs are fine as-is.
- **iOS pod side-effect:** running `flutter test`/`build` sometimes modifies tracked `ios/Flutter/Debug.xcconfig`/`Release.xcconfig` and creates untracked `ios/Podfile` (CocoaPods). ALWAYS revert before committing: `git checkout -- ios/Flutter/*.xcconfig 2>/dev/null; rm -f ios/Podfile`. Never commit these.
- **State mgmt:** Riverpod everywhere. **Navigation:** GoRouter. **Models:** freezed + json_serializable; DTOs map ACTUAL server casing via `@JsonKey`; enums serialize as ints; commit generated `*.g.dart`/`*.freezed.dart`. Codegen: `dart run build_runner build --delete-conflicting-outputs`.
- **Every task** ends `flutter analyze` clean + `flutter test --concurrency=1` passing + committed. The last task of each plan also runs `flutter build web --dart-define=API_HOST=localhost:8080`.

## 2. SDD workflow mechanics that worked here

- Skill scripts live at `/Users/maks/.claude/plugins/cache/claude-plugins-official/superpowers/6.0.3/skills/subagent-driven-development/scripts/`:
  - `task-brief PLAN_FILE N` → writes `.superpowers/sdd/task-N-brief.md` (the implementer's requirements). Dispatch prompts point at this absolute path.
  - `review-package BASE HEAD` → writes a diff package the reviewer reads in one call.
- **Per-task loop:** record BASE (current HEAD) → dispatch implementer (brief path + context + report-file path) → on DONE run `review-package BASE HEAD` → dispatch task reviewer → fix Critical/Important via a fix subagent → mark complete in the ledger with the commit SHA.
- **Parallelization (big speedup):** independent tasks (disjoint files, no dependency) run **in parallel via `isolation: "worktree"` background agents**. Mechanics learned the hard way:
  - Worktrees start at the repo ROOT commit (`35a5363`), NOT at `feat/frontend` tip. Each worktree agent must FIRST run `git merge --ff-only feat/frontend`. Tell them explicitly.
  - `.superpowers/` is git-ignored, so it does NOT exist in a fresh worktree — agents read their brief via the **absolute main-tree path** and write reports in-worktree (or you read the SHA from the completion notification).
  - Worktree agents commit on their own branch; the commit object is in the shared `.git`, so from the main tree you **cherry-pick the reported SHA** onto `feat/frontend` (disjoint files → clean). Tell each agent to stage ONLY its task's files (never `git add -A`) and to report the full 40-char SHA.
  - Before each cherry-pick, clear stray untracked collisions: `git status --short | grep '^??' | awk '{print $2}' | grep -E '<paths>' | xargs -I{} rm -rf {}`.
  - After integrating a wave, run analyze+test, then `git worktree remove --force .claude/worktrees/agent-<id>` + `git branch -D worktree-agent-<id>` + `git worktree prune`.
  - Tasks that touch a SHARED file (esp. `lib/core/router/app_router.dart`) must be SEQUENTIAL, in the main tree. Reviews (read-only) can always run in parallel with an implementer.
  - Dispatch background agents; you're notified on completion. Never predict results before the notification.

## 3. Backend

- Location: `/Users/maks/f1manager` (Go, Gin). Default `HTTP_PORT=8080`. Currently on branch `feature/draft-module`.
- **Verify every contract against the Go source** before building a DTO — casing bit us repeatedly. Data handlers serialize raw `internal/models` structs, so **untagged structs emit PascalCase keys** (`ID`, `Name`, `QualifyingRating`…). Tagged ones (auth `TokenPair`, `MyTeam` outer, `RaceResult`, our new `/budget`) use snake_case/explicit tags. Enums are integers. Full casing table is in spec §4.
- **WS auth (verified):** `GET /ws` is behind JWT middleware that reads the token **only from the `Authorization: Bearer` header** and rejects the handshake unless the user is already in a group. Browsers can't set WS headers → Web needs a backend PR to accept `?token=` (spec §7, Plan 7). We connect WS **only after** a group exists; `WsService` already sends both header (IO) and `?token=` (Web).
- **Open backend PR:** #3 — https://github.com/sewaustav/f1manager/pull/3 — adds `GET /engines` + `GET /budget` (base `feature/draft-module`; that branch is 28+ commits ahead of main and unmerged, hence the base choice — flag to the owner if a different base is wanted).

## 4. What each completed plan delivered

- **Plan 1 Foundation** (`plans/2026-07-30-01-foundation.md`): core/api (Dio + AuthInterceptor + single-flight RefreshInterceptor on 401), core/ws (`WsService` typed messages + exp-backoff reconnect, attempt clamped), core/storage (`SecureTokenStore`), core/models (`TokenPair`, `SeasonState`), core/router (phase-driven `redirectLogic`), shared/theme (F1 red light+dark), shared/widgets later.
- **Plan 2 Auth+Lobby** (`…-02-auth-lobby.md`): features/auth (repo/controller/screen), features/lobby (repo/controller/create-join+group screens), WS starts post-group (platform-conditional auth), router reads real `hasGroupProvider`. shared/widgets: `error_snackbar` + `AsyncValueView`.
- **Plan 3 Draft** (`…-03-draft.md`): shared models (Pilot/Team/Principal), features/draft (repo, WS draft events, DraftController turn/history/finish, budget bar, filterable lists, team-type-aware engine modal, DraftScreen → `/token-setup` on `draft_finished`). Backend PR #3 for `/engines`+`/budget`.
- **Plan 4 Season** (`…-04-season.md`): features/season — SetupPreset + shared_preferences store (≤3), models (SetupPayload/TrackInfo/RaceResult+Response/Standing), SeasonRepository, race_finished WS + SeasonController, `SetupForm` (6 sliders bounded to token pool + angle), TokenSetupScreen + RaceScreen (track picker, results table, car-update window on stages 3/8/13, guarded preset load). `main.dart` wires `sharedPrefsProvider`; routes `/token-setup`, `/season`.

## 5. Deferred items (tracked; wire when their dependency lands)

- **`GET /season/state` backend PR (Plan 7)** unblocks: auto next-track by stage, "N of M submitted" waiting counter, and **phase-based router redirect** (router `phase` is still `null`). Until then Season is degraded: manual track pick + generic waiting spinner.
- **Logout cleanup (Plan 6, when logout UI lands):** `AuthController.logout()` doesn't reset `hasGroupProvider` or tear down WS providers → stale cross-session state. A background task chip was spawned for this (`task_c2656a95`).
- `currentUserIdProvider` not yet wired from the JWT `sub` (draft history "mine" highlighting).
- Organizer-only actions (draft `bots/swap`, `rounds/:stage/init`) have repo methods but no UI — add when an organizer role is modelled.
- Minor deferred polish is listed at the end of `.superpowers/sdd/progress.md`.

## 6. Remaining work

### Plan 5 — Inter-season ✅ DONE
Plan: `plans/2026-07-31-05-inter-season.md`. Feature `lib/features/inter_season/` (transfers of free + peer-owned pilots, incoming-offer dialog via WS, hire/fire principal, fire pilot via a MyPilotsList roster, base sliders, ready-for-new-season, budget in AppBar). InterSeasonScreen (Transfers/Principal/Base/Ready tabs) replaces the placeholder. **Backend PR #5** — https://github.com/sewaustav/f1manager/pull/5 — `POST /fire`, `POST /ready`, WS `season_started` (base `feature/draft-module`; adds `DynamicRepo.Fire` to `new_storage` + a `ReadyTracker` dispatcher). Degraded until Plan 7: `season_started` → manual `context.go('/token-setup')` (no `GET /season/state` yet).

### Plan 6 — Standings + Info + My Team + shell nav + logout ✅ DONE
Plan: `plans/2026-08-01-06-standings-info-myteam.md`. `features/standings/` (WDC/WCC from `/standing`, joined with pilot/team names), `features/info/` (Tracks/Squads/Pilots; `/players/squads` returns **`[]MyTeam`** not PlayerProfile → reuse `MyTeamSummary`), `features/my_team/` (team/pilots/principal/budget + Logout). Router restructured to **`StatefulShellRoute.indexedStack`** (`lib/core/router/app_shell.dart`, responsive NavigationBar/Rail): `/auth`+`/lobby` top-level; branches Play + Standings + Info + My-Team. Logout-state cleanup FIXED (resets `hasGroupProvider` + WS).

### Plan 7 — season/state + WS ?token= + wiring ✅ DONE
Plan: `plans/2026-08-01-07-season-state-wiring.md`. Backend **PR #6** (`GET /season/state` via in-memory `PhaseTracker`; WS `?token=` auth; base `feat/fire-ready-endpoints`). Frontend: `SeasonStateRepository`+`seasonStateProvider`, phase-driven router redirect (guarded off the always-available tabs), offstage-nav guard, next-track-by-stage + "N of M submitted" counter, and (final-review fix) live season-state refresh on phase WS events + 5s poll gated on session. Backend deferred: `inter_season` phase not emitted (no final-stage trigger; `PhaseInterSeason` ready); `RoundState` empty right after a round closes.

<!-- original Plan 7 heading retained below for detail -->
### Plan 7 detail — Backend PRs + wiring
`GET /season/state` backend PR (the big one — unifies phase across draft/setup/inter-season; see spec §7 for the response shape), WS `?token=` query auth (Web WS). Then wire the router `phase` redirect, next-track-by-stage, the "N of M submitted" waiting counter, and render enum ints as labels. **Two carry-overs from Plan 6's final review that Plan 7 MUST handle:** (a) the shell/tabs are currently **unreachable** in the running app (lobby has no manual link in; nothing navigates into a shell route) — wiring `seasonStateProvider → routeForPhase → a shell route` fixes this; (b) the `StatefulShellRoute.indexedStack` keeps **offstage game screens (Draft/InterSeason) mounted**, and their `ref.listen(wsMessages) → context.go('/token-setup'|...)` will hijack navigation away from Standings/Info/My-Team when a WS phase event fires — guard those screen-level `context.go` transitions (and the phase redirect) on the user actually being in the Play branch (`navigationShell.currentIndex`/current route), not just on `redirectLogic`.

## 7. Immediate next step

Continue with **Plan 7** (final): author `plans/2026-08-XX-07-*.md` via `superpowers:writing-plans`, then execute via `superpowers:subagent-driven-development`. It is **backend-PR-heavy** — `GET /season/state` needs a Go handler unifying phase/stage/submitted-setups/total-players (discover how phase is tracked across the draft dispatcher, setup dispatcher, and the new ReadyTracker before designing it; it may need new state) and the WS `?token=` change is small but blocks Web WS. Base backend PRs on `feature/draft-module` (per owner, as PRs #3/#5). Frontend wiring: `seasonStateProvider` + router `phase` redirect + the offstage-nav guard (P6 item b) + next-track-by-stage + waiting counter. Execution that worked for Plans 5–6: tasks **sequentially in the main tree**, backend PR task as a background agent, per-task reviewers in background, and a **final Opus integration review** (it caught real bugs both plans — e.g. an entire subsystem being UI-unreachable in Plan 5, and a mis-targeted breakpoint test in Plan 6). Keep the ledger + build-progress memory updated as you go.

## 8. Finishing

When all 7 plans are done: run the final whole-branch review, then `superpowers:finishing-a-development-branch` to decide merge/PR for `feat/frontend`. The branch has NOT been pushed or PR'd yet — confirm with the owner before opening a frontend PR.
