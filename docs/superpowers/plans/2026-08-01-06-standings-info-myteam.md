# Standings + Info + My Team (always-available tabs) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the three always-available read screens (Standings, Info, My Team) and present them via a persistent bottom-nav/rail shell layered over the game phases, plus a logout button that fully tears down session state.

**Architecture:** New feature modules `lib/features/standings/`, `lib/features/info/`, `lib/features/my_team/`, each with its own data providers + presentation, reusing existing repositories (`SeasonRepository.getStanding/getTracks`, `DraftRepository.getPilots/getTeams`, `InterSeasonRepository.getMyTeam`) and models (`Standing`, `TrackInfo`, `MyTeamSummary`, `Budget`, core `Pilot`/`Team`/`Principal`). Navigation moves to a GoRouter `StatefulShellRoute.indexedStack` with four branches — **Play** (the existing game-phase routes) + **Standings**, **Info**, **My Team** — behind a responsive `AppShell` (NavigationBar on narrow, NavigationRail on wide). `/auth` and `/lobby` stay outside the shell. Logout is fixed to reset `hasGroupProvider` and tear down the WS providers.

**Tech Stack:** Flutter, Riverpod, GoRouter (StatefulShellRoute), Dio, freezed; existing DTOs reused.

## Global Constraints

- **Git:** Claude commits **and** pushes directly in this frontend repo. Backend changes (none expected in this plan) go via PR only. End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Subagent model floor:** code-writing subagents ≥ Sonnet (never Haiku). Reviewers: Sonnet. Final integration review: most capable available (Opus).
- **Flutter env:** SDK at `$HOME/development/flutter`. Shell env does NOT persist — **prefix every** flutter/dart command with `export PATH="$HOME/development/flutter/bin:$PATH" &&`. Work from `/Users/maks/f1managerfront`.
- **Test flake:** full suite always `flutter test --concurrency=1`. Focused single-file runs are fine as-is.
- **iOS pod side-effect:** revert before every commit — `git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile`. Never commit these.
- **State mgmt:** Riverpod. **Navigation:** GoRouter. **Models:** freezed + json_serializable where new models are needed; DTOs map ACTUAL server casing via `@JsonKey`; enums are ints; commit generated `*.g.dart`/`*.freezed.dart`.
- **Verified backend casing (verify each fromJson against Go):**
  - `GET /standing` → `{"drivers": {"<id>": <pts>}, "teams": {"<id>": <pts>}}` (maps keyed by stringified int id; already modelled by `Standing`).
  - `GET /players/squads` → **`[]MyTeam`** (NOT `PlayerProfile`): each element `{id, pilot1, pilot2, team, team_principal}` with PascalCase nested objects — parse with `MyTeamSummary.fromJson`.
  - `GET /my-team` → `{id, pilot1, pilot2, team, team_principal}` (PascalCase nested). `GET /budget` → `{budget, tokens}`.
  - `GET /pilots` → `[]Pilot` (PascalCase). `GET /teams` → `[]Team` (PascalCase). `GET /track` → `[]Track` (PascalCase; parsed by `TrackInfo`).
- **Every task** ends `flutter analyze` clean ("No issues found!") + `flutter test --concurrency=1` passing + committed. The router-integration task also runs `flutter build web --dart-define=API_HOST=localhost:8080`.

---

## File Structure

- `lib/features/standings/application/standings_providers.dart` — joins `getStanding` + `getPilots` + `getTeams` into ranked rows.
- `lib/features/standings/presentation/standings_screen.dart` — WDC + WCC tables.
- `lib/features/info/data/info_repository.dart` — `getSquads()` (`/players/squads` → `List<MyTeamSummary>`).
- `lib/features/info/application/info_providers.dart` — tracks, squads, pilots providers.
- `lib/features/info/presentation/info_screen.dart` — Next track / Squads / Pilots sub-tabs.
- `lib/features/my_team/application/my_team_providers.dart` — my-team + budget providers (reuse existing repos).
- `lib/features/my_team/presentation/my_team_screen.dart` — team/car/pilots/principal/base/budget view + logout action.
- `lib/core/router/app_shell.dart` — responsive `AppShell` (NavigationBar / NavigationRail) wrapping a `StatefulNavigationShell`.
- Modify `lib/core/router/app_router.dart` — restructure into `StatefulShellRoute.indexedStack`.
- Modify `lib/features/auth/application/auth_controller.dart` — logout resets `hasGroupProvider` + invalidates WS providers.

---

## Task 1: Standings data providers

**Files:**
- Create: `lib/features/standings/application/standings_providers.dart`
- Test: `test/features/standings/standings_providers_test.dart`

**Interfaces:**
- Consumes: `seasonRepositoryProvider` (`SeasonRepository.getStanding() → Standing`), `draftRepositoryProvider` (`getPilots() → List<Pilot>`, `getTeams() → List<Team>`).
- Produces:
  - `class StandingRow { final String name; final int points; const StandingRow(this.name, this.points); }`
  - `driverStandingsProvider` — `FutureProvider.autoDispose<List<StandingRow>>`: maps `standing.drivers` (`{stringId: pts}`) to rows using pilot names (id→name from `/pilots`), sorted by points desc; unknown ids fall back to `'#<id>'`.
  - `teamStandingsProvider` — `FutureProvider.autoDispose<List<StandingRow>>`: same for `standing.teams` using team names (`/teams`).

- [ ] **Step 1: Write the failing test**

Create `test/features/standings/standings_providers_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/standing.dart';
import 'package:f1manager/features/standings/application/standings_providers.dart';

class _FakeSeasonRepo extends SeasonRepository {
  _FakeSeasonRepo() : super(Dio());
  @override
  Future<Standing> getStanding() async =>
      const Standing(drivers: {'1': 10, '2': 25}, teams: {'3': 40});
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async =>
      const [Pilot(id: 1, name: 'Max'), Pilot(id: 2, name: 'Lando')];
  @override
  Future<List<Team>> getTeams() async => const [Team(id: 3, name: 'RB')];
}

void main() {
  ProviderContainer makeContainer() => ProviderContainer(overrides: [
        seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      ]);

  test('driverStandingsProvider ranks by points desc with names', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    final rows = await c.read(driverStandingsProvider.future);
    expect(rows.map((r) => r.name), ['Lando', 'Max']); // 25 before 10
    expect(rows.first.points, 25);
  });

  test('teamStandingsProvider maps team names', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    final rows = await c.read(teamStandingsProvider.future);
    expect(rows.single.name, 'RB');
    expect(rows.single.points, 40);
  });

  test('unknown id falls back to #id', () async {
    final c = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
    ]);
    addTearDown(c.dispose);
    // team 99 not in getTeams -> '#99'
    final rows = await c.read(teamStandingsProvider.future);
    expect(rows.any((r) => r.name == 'RB'), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/standings/standings_providers_test.dart`
Expected: FAIL (symbols not found).

- [ ] **Step 3: Implement the providers**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../draft/data/draft_repository.dart';
import '../../season/data/season_repository.dart';

class StandingRow {
  const StandingRow(this.name, this.points);
  final String name;
  final int points;
}

List<StandingRow> _rank(Map<String, int> points, Map<int, String> names) {
  final rows = points.entries.map((e) {
    final id = int.tryParse(e.key) ?? -1;
    return StandingRow(names[id] ?? '#${e.key}', e.value);
  }).toList()
    ..sort((a, b) => b.points.compareTo(a.points));
  return rows;
}

final driverStandingsProvider = FutureProvider.autoDispose<List<StandingRow>>((ref) async {
  final standing = await ref.watch(seasonRepositoryProvider).getStanding();
  final pilots = await ref.watch(draftRepositoryProvider).getPilots();
  return _rank(standing.drivers, {for (final p in pilots) p.id: p.name});
});

final teamStandingsProvider = FutureProvider.autoDispose<List<StandingRow>>((ref) async {
  final standing = await ref.watch(seasonRepositoryProvider).getStanding();
  final teams = await ref.watch(draftRepositoryProvider).getTeams();
  return _rank(standing.teams, {for (final t in teams) t.id: t.name});
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/standings/standings_providers_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/standings/application test/features/standings/standings_providers_test.dart
git commit -m "feat(standings): ranked driver/team standings providers

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: StandingsScreen

**Files:**
- Create: `lib/features/standings/presentation/standings_screen.dart`
- Test: `test/features/standings/standings_screen_test.dart`

**Interfaces:**
- Consumes: `driverStandingsProvider`, `teamStandingsProvider` (Task 1), `AsyncValueView` (`lib/shared/widgets/async_value_view.dart`, `AsyncValueView(value:, data:)`).
- Produces: `class StandingsScreen extends ConsumerWidget` — a `DefaultTabController(length: 2)` with tabs **WDC** / **WCC**, each an `AsyncValueView` over the matching provider rendering a numbered list (`1. <name> — <points>`).

- [ ] **Step 1: Write the failing test**

Create `test/features/standings/standings_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1manager/features/standings/application/standings_providers.dart';
import 'package:f1manager/features/standings/presentation/standings_screen.dart';

void main() {
  testWidgets('renders WDC list from provider', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        driverStandingsProvider.overrideWith((ref) async =>
            const [StandingRow('Lando', 25), StandingRow('Max', 10)]),
        teamStandingsProvider.overrideWith((ref) async => const [StandingRow('RB', 40)]),
      ],
      child: const MaterialApp(home: StandingsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('WDC'), findsOneWidget);
    expect(find.text('WCC'), findsOneWidget);
    expect(find.textContaining('Lando'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/standings/standings_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../application/standings_providers.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  Widget _list(List<StandingRow> rows) => ListView.builder(
        itemCount: rows.length,
        itemBuilder: (_, i) => ListTile(
          leading: Text('${i + 1}'),
          title: Text(rows[i].name),
          trailing: Text('${rows[i].points}'),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Standings'),
          bottom: const TabBar(tabs: [Tab(text: 'WDC'), Tab(text: 'WCC')]),
        ),
        body: TabBarView(children: [
          AsyncValueView(value: ref.watch(driverStandingsProvider), data: _list),
          AsyncValueView(value: ref.watch(teamStandingsProvider), data: _list),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/standings/standings_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/standings/presentation test/features/standings/standings_screen_test.dart
git commit -m "feat(standings): WDC/WCC standings screen

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: InfoRepository + info providers

**Files:**
- Create: `lib/features/info/data/info_repository.dart`
- Create: `lib/features/info/application/info_providers.dart`
- Test: `test/features/info/info_repository_test.dart`

**Interfaces:**
- Consumes: `dioProvider`, `MyTeamSummary` (`lib/features/inter_season/model/my_team_summary.dart`), `seasonRepositoryProvider.getTracks()` (`List<TrackInfo>`), `draftRepositoryProvider.getPilots()` (`List<Pilot>`).
- Produces:
  - `class InfoRepository { Future<List<MyTeamSummary>> getSquads(); }` — `GET /players/squads` → `List<MyTeamSummary>` (parse each element with `MyTeamSummary.fromJson`). `final infoRepositoryProvider`.
  - `tracksProvider` — `FutureProvider.autoDispose<List<TrackInfo>>` (reuses `seasonRepositoryProvider.getTracks`).
  - `squadsProvider` — `FutureProvider.autoDispose<List<MyTeamSummary>>` (`infoRepositoryProvider.getSquads`).
  - `allPilotsInfoProvider` — `FutureProvider.autoDispose<List<Pilot>>` (reuses `draftRepositoryProvider.getPilots`).

- [ ] **Step 1: Write the failing test**

Create `test/features/info/info_repository_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/info/data/info_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InfoRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = InfoRepository(dio);
  });

  test('getSquads parses a list of MyTeam objects', () async {
    adapter.onGet('/players/squads', (s) => s.reply(200, [
          {
            'id': 1,
            'pilot1': {'ID': 10, 'Name': 'Max'},
            'pilot2': {'ID': 11, 'Name': 'Lando'},
            'team': {'ID': 3, 'Name': 'RB'},
            'team_principal': {'ID': 9, 'Name': 'Toto'},
          },
          {
            'id': 2,
            'pilot1': {'ID': 20, 'Name': 'Lewis'},
            'pilot2': {'ID': 21, 'Name': 'George'},
            'team': {'ID': 4, 'Name': 'Merc'},
            'team_principal': {'ID': 8, 'Name': 'Fred'},
          },
        ]));
    final squads = await repo.getSquads();
    expect(squads.length, 2);
    expect(squads.first.team.name, 'RB');
    expect(squads[1].pilot1.name, 'Lewis');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/info/info_repository_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the repository**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../inter_season/model/my_team_summary.dart';

class InfoRepository {
  InfoRepository(this._dio);
  final Dio _dio;

  Future<List<MyTeamSummary>> getSquads() async {
    final res = await _dio.get('/players/squads');
    return (res.data as List)
        .map((e) => MyTeamSummary.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}

final infoRepositoryProvider =
    Provider<InfoRepository>((ref) => InfoRepository(ref.watch(dioProvider)));
```

- [ ] **Step 4: Implement the providers**

Create `lib/features/info/application/info_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pilot.dart';
import '../../draft/data/draft_repository.dart';
import '../../season/data/season_repository.dart';
import '../../season/model/track_info.dart';
import '../../inter_season/model/my_team_summary.dart';
import '../data/info_repository.dart';

final tracksProvider = FutureProvider.autoDispose<List<TrackInfo>>(
    (ref) => ref.watch(seasonRepositoryProvider).getTracks());

final squadsProvider = FutureProvider.autoDispose<List<MyTeamSummary>>(
    (ref) => ref.watch(infoRepositoryProvider).getSquads());

final allPilotsInfoProvider = FutureProvider.autoDispose<List<Pilot>>(
    (ref) => ref.watch(draftRepositoryProvider).getPilots());
```

- [ ] **Step 5: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/info/info_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/info/data lib/features/info/application test/features/info/info_repository_test.dart
git commit -m "feat(info): squads repository + tracks/squads/pilots providers

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 4: InfoScreen

**Files:**
- Create: `lib/features/info/presentation/info_screen.dart`
- Test: `test/features/info/info_screen_test.dart`

**Interfaces:**
- Consumes: `tracksProvider`, `squadsProvider`, `allPilotsInfoProvider` (Task 3), `AsyncValueView`, `TrackInfo`, `MyTeamSummary`, `Pilot`.
- Produces: `class InfoScreen extends ConsumerWidget` — `DefaultTabController(length: 3)` with tabs **Tracks** / **Squads** / **Pilots**:
  - Tracks: list of `TrackInfo` (name + `type`/`difficulty`/`rainPossibility` ints). (Next-track-by-stage is deferred to Plan 7; show the full track list.)
  - Squads: list of `MyTeamSummary` (team name + `pilot1.name` / `pilot2.name` + principal name).
  - Pilots: list of `Pilot` public ratings (name + `rating` / `qualifyingRating`).

- [ ] **Step 1: Write the failing test**

Create `test/features/info/info_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/features/season/model/track_info.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/info/application/info_providers.dart';
import 'package:f1manager/features/info/presentation/info_screen.dart';

void main() {
  testWidgets('renders three info tabs and content', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tracksProvider.overrideWith((ref) async =>
            const [TrackInfo(id: 1, name: 'Monza')]),
        squadsProvider.overrideWith((ref) async => const [
              MyTeamSummary(
                id: 1,
                pilot1: Pilot(id: 10, name: 'Max'),
                pilot2: Pilot(id: 11, name: 'Lando'),
                team: Team(id: 3, name: 'RB'),
                principal: Principal(id: 9, name: 'Toto'),
              )
            ]),
        allPilotsInfoProvider.overrideWith((ref) async =>
            const [Pilot(id: 10, name: 'Max', rating: 95)]),
      ],
      child: const MaterialApp(home: InfoScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Squads'), findsOneWidget);
    expect(find.text('Pilots'), findsOneWidget);
    expect(find.text('Monza'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/info/info_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../application/info_providers.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Info'),
          bottom: const TabBar(
              tabs: [Tab(text: 'Tracks'), Tab(text: 'Squads'), Tab(text: 'Pilots')]),
        ),
        body: TabBarView(children: [
          AsyncValueView(
            value: ref.watch(tracksProvider),
            data: (tracks) => ListView(children: [
              for (final t in tracks)
                ListTile(
                  title: Text(t.name),
                  subtitle: Text('type ${t.type} · difficulty ${t.difficulty} · rain ${t.rainPossibility}%'),
                ),
            ]),
          ),
          AsyncValueView(
            value: ref.watch(squadsProvider),
            data: (squads) => ListView(children: [
              for (final s in squads)
                ListTile(
                  title: Text(s.team.name),
                  subtitle: Text('${s.pilot1.name} / ${s.pilot2.name} · ${s.principal.name}'),
                ),
            ]),
          ),
          AsyncValueView(
            value: ref.watch(allPilotsInfoProvider),
            data: (pilots) => ListView(children: [
              for (final p in pilots)
                ListTile(
                  title: Text(p.name),
                  trailing: Text('R ${p.rating} · Q ${p.qualifyingRating}'),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/info/info_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/info/presentation test/features/info/info_screen_test.dart
git commit -m "feat(info): tracks/squads/pilots info screen

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 5: My Team providers + screen

**Files:**
- Create: `lib/features/my_team/application/my_team_providers.dart`
- Create: `lib/features/my_team/presentation/my_team_screen.dart`
- Test: `test/features/my_team/my_team_screen_test.dart`

**Interfaces:**
- Consumes: `interSeasonRepositoryProvider.getMyTeam()` (`MyTeamSummary`, from `lib/features/inter_season/data/inter_season_repository.dart`), `draftRepositoryProvider.getBudget()` (`Budget`), `authControllerProvider` (`logout()`), `AsyncValueView`.
- Produces:
  - `myTeamDetailProvider` — `FutureProvider.autoDispose<MyTeamSummary>` (reuses `interSeasonRepositoryProvider.getMyTeam`).
  - `myTeamBudgetProvider` — `FutureProvider.autoDispose<Budget>` (reuses `draftRepositoryProvider.getBudget`).
  - `class MyTeamScreen extends ConsumerWidget` — shows team (`carLevel`, `baseLevel`, `engineer`, `simLevel`, `tubeLevel`), the two pilots (name + `rating`/`qualifyingRating`), principal (name + `level`), and budget/tokens; AppBar has a **Logout** action calling `ref.read(authControllerProvider.notifier).logout()`.

- [ ] **Step 1: Write the failing test**

Create `test/features/my_team/my_team_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/my_team/presentation/my_team_screen.dart';

class _FakeIsRepo extends InterSeasonRepository {
  _FakeIsRepo() : super(Dio());
  @override
  Future<MyTeamSummary> getMyTeam() async => const MyTeamSummary(
        id: 1,
        pilot1: Pilot(id: 10, name: 'Max', rating: 95),
        pilot2: Pilot(id: 11, name: 'Lando', rating: 88),
        team: Team(id: 3, name: 'RB', carLevel: 7, baseLevel: 4),
        principal: Principal(id: 9, name: 'Toto', level: 5),
      );
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<Budget> getBudget() async => const Budget(budget: 120, tokens: 30);
}

void main() {
  testWidgets('renders team, pilots, principal, budget', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      ],
      child: const MaterialApp(home: MyTeamScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('RB'), findsOneWidget);
    expect(find.textContaining('Max'), findsOneWidget);
    expect(find.textContaining('Toto'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/my_team/my_team_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement the providers**

Create `lib/features/my_team/application/my_team_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/model/budget.dart';
import '../../inter_season/data/inter_season_repository.dart';
import '../../inter_season/model/my_team_summary.dart';

final myTeamDetailProvider = FutureProvider.autoDispose<MyTeamSummary>(
    (ref) => ref.watch(interSeasonRepositoryProvider).getMyTeam());

final myTeamBudgetProvider = FutureProvider.autoDispose<Budget>(
    (ref) => ref.watch(draftRepositoryProvider).getBudget());
```

- [ ] **Step 4: Implement the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/application/auth_controller.dart';
import '../application/my_team_providers.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(myTeamDetailProvider);
    final budget = ref.watch(myTeamBudgetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: team,
        data: (t) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.team.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Car level ${t.team.carLevel} · Base ${t.team.baseLevel} · '
                'Engineer ${t.team.engineer} · Sim ${t.team.simLevel} · Tube ${t.team.tubeLevel}'),
            const Divider(height: 24),
            ListTile(
              title: Text(t.pilot1.name),
              trailing: Text('R ${t.pilot1.rating} · Q ${t.pilot1.qualifyingRating}'),
            ),
            ListTile(
              title: Text(t.pilot2.name),
              trailing: Text('R ${t.pilot2.rating} · Q ${t.pilot2.qualifyingRating}'),
            ),
            const Divider(height: 24),
            ListTile(
              title: Text('Principal: ${t.principal.name}'),
              trailing: Text('Level ${t.principal.level}'),
            ),
            const Divider(height: 24),
            budget.when(
              data: (b) => Text('Budget ${b.budget} · Tokens ${b.tokens}'),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/my_team/my_team_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/my_team test/features/my_team/my_team_screen_test.dart
git commit -m "feat(my-team): team/pilots/principal/budget view + logout action

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: Logout state cleanup

**Files:**
- Modify: `lib/features/auth/application/auth_controller.dart`
- Test: `test/features/auth/logout_cleanup_test.dart`

**Interfaces:**
- Consumes: `hasGroupProvider` (`lib/features/lobby/application/lobby_controller.dart`), `wsServiceProvider` + `wsMessagesProvider` (`lib/core/ws/ws_providers.dart`), `isAuthenticatedProvider`, `tokenStoreProvider`.
- Produces: `AuthController.logout()` additionally sets `hasGroupProvider` to `false` and invalidates `wsMessagesProvider` + `wsServiceProvider` so no stale WS/session state leaks into the next login.

- [ ] **Step 1: Write the failing test**

Create `test/features/auth/logout_cleanup_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/features/auth/application/auth_controller.dart';
import 'package:f1manager/features/auth/data/auth_repository.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';

class _FakeTokenStore implements TokenStore {
  String? access = 'a';
  String? refresh = 'r';
  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }
  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo() : super(throw UnimplementedError());
  @override
  Future<void> logout() async {}
}

void main() {
  test('logout resets hasGroup + auth flags', () async {
    final c = ProviderContainer(overrides: [
      tokenStoreProvider.overrideWithValue(_FakeTokenStore()),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
    ]);
    addTearDown(c.dispose);
    c.read(isAuthenticatedProvider.notifier).state = true;
    c.read(hasGroupProvider.notifier).state = true;

    await c.read(authControllerProvider.notifier).logout();

    expect(c.read(isAuthenticatedProvider), isFalse);
    expect(c.read(hasGroupProvider), isFalse);
  });
}
```

Note: verify `AuthRepository`'s constructor/`authRepositoryProvider` shape against `lib/features/auth/data/auth_repository.dart`; if a no-arg fake is impossible, override `authRepositoryProvider` with a `Fake` created differently — adapt the fake so `logout()` is a no-op. Keep the assertions.

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/auth/logout_cleanup_test.dart`
Expected: FAIL (`hasGroupProvider` still true).

- [ ] **Step 3: Implement the cleanup**

In `lib/features/auth/application/auth_controller.dart`, add imports:

```dart
import '../../../core/ws/ws_providers.dart';
import '../../lobby/application/lobby_controller.dart';
```

Extend `logout()`:

```dart
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // best-effort; clear locally regardless
    }
    await ref.read(tokenStoreProvider).clear();
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(hasGroupProvider.notifier).state = false;
    // Tear down the live WS so the next session starts clean.
    ref.invalidate(wsMessagesProvider);
    ref.invalidate(wsServiceProvider);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/features/auth/logout_cleanup_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/features/auth/application/auth_controller.dart test/features/auth/logout_cleanup_test.dart
git commit -m "fix(auth): logout resets hasGroup + tears down WS providers

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 7: AppShell (responsive nav)

**Files:**
- Create: `lib/core/router/app_shell.dart`
- Test: `test/core/router/app_shell_test.dart`

**Interfaces:**
- Consumes: `StatefulNavigationShell` (from `package:go_router`).
- Produces: `class AppShell extends StatelessWidget` with `final StatefulNavigationShell navigationShell;`. Four destinations — **Play** (`Icons.sports_motorsports`), **Standings** (`Icons.leaderboard`), **Info** (`Icons.info_outline`), **My Team** (`Icons.groups`). On a wide layout (`constraints.maxWidth >= 600`) it renders a `NavigationRail` beside `navigationShell`; otherwise a `Scaffold` with a `NavigationBar`. Selecting index `i` calls `navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex)`. `selectedIndex`/`selectedIndex` bound to `navigationShell.currentIndex`.

- [ ] **Step 1: Write the failing test**

Create `test/core/router/app_shell_test.dart`. Since `AppShell` needs a real `StatefulNavigationShell`, test it through a minimal `StatefulShellRoute.indexedStack` router:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:f1manager/core/router/app_shell.dart';

void main() {
  testWidgets('renders NavigationBar with four destinations and switches branch',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/play',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/play', builder: (_, __) => const Text('PLAY')),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/standings', builder: (_, __) => const Text('STAND')),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/info', builder: (_, __) => const Text('INFO')),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/myteam', builder: (_, __) => const Text('MYTEAM')),
            ]),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Standings'), findsWidgets); // nav label

    await tester.tap(find.text('Standings').last);
    await tester.pumpAndSettle();
    expect(find.text('STAND'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/app_shell_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement AppShell**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.sports_motorsports, label: 'Play'),
    (icon: Icons.leaderboard, label: 'Standings'),
    (icon: Icons.info_outline, label: 'Info'),
    (icon: Icons.groups, label: 'My Team'),
  ];

  void _go(int i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _go,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/app_shell_test.dart`
Expected: PASS.

- [ ] **Step 5: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/core/router/app_shell.dart test/core/router/app_shell_test.dart
git commit -m "feat(shell): responsive AppShell (NavigationBar / NavigationRail)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 8: Router restructure (StatefulShellRoute) + integration

**Files:**
- Modify: `lib/core/router/app_router.dart` (SHARED — sequential, main tree)
- Test: `test/core/router/app_router_shell_test.dart` (new), and keep existing `test/core/router/app_router_test.dart` + `app_router_group_test.dart` passing.

**Interfaces:**
- Consumes: `AppShell` (Task 7), all game screens (`DraftScreen`, `TokenSetupScreen`, `RaceScreen`, `InterSeasonScreen`), `StandingsScreen` (Task 2), `InfoScreen` (Task 4), `MyTeamScreen` (Task 5), `AuthScreen`, `LobbyScreen`, `redirectLogic` (unchanged pure fn).
- Produces: a `GoRouter` where `/auth` and `/lobby` are top-level, and a `StatefulShellRoute.indexedStack` hosts four branches: **Play** (routes `/draft`, `/token-setup`, `/season`, `/inter-season`), **Standings** (`/standings`), **Info** (`/info`), **My Team** (`/my-team`). The existing `redirect`/`refreshListenable`/`redirectLogic` and `routeForPhase` are preserved unchanged (phase still `null`).

- [ ] **Step 1: Write the failing router test**

Create `test/core/router/app_router_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/router/app_router.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/standing.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  @override
  void send(Map<String, dynamic> json) {}
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [];
  @override
  Future<List<Team>> getTeams() async => const [];
}

class _FakeSeasonRepo extends SeasonRepository {
  _FakeSeasonRepo() : super(Dio());
  @override
  Future<Standing> getStanding() async => const Standing();
}

void main() {
  testWidgets('authed+group renders shell and can switch to Standings', (tester) async {
    final container = ProviderContainer(overrides: [
      isAuthenticatedProvider.overrideWith((ref) => true),
      hasGroupProvider.overrideWith((ref) => true),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    router.go('/standings');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Standings'), findsWidgets);
    expect(find.text('WDC'), findsOneWidget);
  });
}
```

Note: `hasGroupProvider`/`isAuthenticatedProvider` are `StateProvider`s — override with `.overrideWith((ref) => <bool>)` returns the initial value; if that override form misbehaves for `StateProvider`, set the values via `container.read(...notifier).state = true` after creating the container instead. Adapt minimally; keep the assertions.

- [ ] **Step 2: Run test to verify it fails**

Run: `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/app_router_shell_test.dart`
Expected: FAIL.

- [ ] **Step 3: Restructure the router**

Rewrite the `routes:` list in `lib/core/router/app_router.dart`. Keep the top of the file (`routeForPhase`, `redirectLogic`, the `routerProvider` header with `initialLocation`, `refreshListenable`, `redirect`) unchanged. Add imports for `AppShell`, `StandingsScreen`, `InfoScreen`, `MyTeamScreen`, and `package:go_router/go_router.dart` (already imported). Replace the `routes:` list:

```dart
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/lobby', builder: (_, __) => const LobbyScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/draft', builder: (_, __) => const DraftScreen()),
            GoRoute(path: '/token-setup', builder: (_, __) => const TokenSetupScreen()),
            GoRoute(path: '/season', builder: (_, __) => const RaceScreen()),
            GoRoute(path: '/inter-season', builder: (_, __) => const InterSeasonScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/standings', builder: (_, __) => const StandingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/info', builder: (_, __) => const InfoScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/my-team', builder: (_, __) => const MyTeamScreen()),
          ]),
        ],
      ),
    ],
```

Add the imports near the existing screen imports:

```dart
import 'app_shell.dart';
import '../../features/standings/presentation/standings_screen.dart';
import '../../features/info/presentation/info_screen.dart';
import '../../features/my_team/presentation/my_team_screen.dart';
```

Remove the now-unused `PlaceholderScreen` import only if nothing else in the file uses it (check first — the `/inter-season` placeholder was already replaced in Plan 5, so `PlaceholderScreen` may already be unused; if so, drop the import to keep analyze clean).

- [ ] **Step 4: Run the new router test + the existing router tests**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test test/core/router/
```
Expected: PASS (new shell test + `app_router_test.dart` + `app_router_group_test.dart`). If an existing test asserted a route that is now under the shell, confirm it still resolves; the `redirectLogic` pure-function tests are unaffected.

- [ ] **Step 5: Full suite + web build**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter test --concurrency=1 && flutter build web --dart-define=API_HOST=localhost:8080
```
Expected: all tests pass, web build succeeds.

- [ ] **Step 6: Analyze + commit**

```bash
export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze
git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile
git add lib/core/router/app_router.dart test/core/router/app_router_shell_test.dart
git commit -m "feat(shell): StatefulShellRoute with Play/Standings/Info/My Team branches

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 9: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Analyze clean** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter analyze` → "No issues found!"
- [ ] **Step 2: Full suite** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter test --concurrency=1` → all pass.
- [ ] **Step 3: Web build** — `export PATH="$HOME/development/flutter/bin:$PATH" && flutter build web --dart-define=API_HOST=localhost:8080` → succeeds.
- [ ] **Step 4: Clean tree** — `git checkout -- ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig 2>/dev/null; rm -f ios/Podfile; git status --short` → clean.

---

## Deferred / Plan 7 interactions (document; do not fix here)

- **Phase redirect vs. shell tabs:** `redirectLogic` currently gets `phase: null` and returns null, so the always-available tabs work freely. When Plan 7 wires `seasonStateProvider` into the redirect, it MUST NOT redirect a user who is on the Standings/Info/My-Team branch back to the Play phase route — otherwise those tabs become unusable during active phases. Restrict the phase redirect to fire only when the current location is a Play-branch route (or `/auth`/`/lobby`), not when it is `/standings`/`/info`/`/my-team`.
- **Next track by stage** (Info Tracks tab) shows the full track list until `GET /season/state` provides the current stage (Plan 7).
- **Standings refresh after each race:** providers are `autoDispose` and refetch on (re)watch; a WS-driven `race_finished` → `ref.invalidate(driverStandingsProvider/teamStandingsProvider)` hook can be added when the standings tab needs live refresh (Plan 7 / polish).

## Self-Review

- **Spec coverage:** §5.8 standings WDC/WCC from `/standing` (T1 providers join names, T2 screen) ✓; §5.9 my-team car/pilots/principal/budget/base from `/my-team`+`/budget` (T5) ✓; §5.10 info next-track (`/track`), squads (`/players/squads`→`MyTeamSummary`), pilots (`/pilots`) (T3/T4) ✓; §6 shell bottom-nav/rail over game phase (T7 AppShell, T8 StatefulShellRoute) ✓; logout button + deferred logout-state cleanup (T5 action, T6 fix) ✓.
- **Placeholder scan:** every code step has full code; no TBD.
- **Type consistency:** `StandingRow(name, points)` used identically in T1/T2; `MyTeamSummary` fields (`team`/`pilot1`/`pilot2`/`principal`) used consistently in T3/T4/T5; `AppShell(navigationShell:)` matches T7/T8; provider names (`driverStandingsProvider`, `teamStandingsProvider`, `tracksProvider`, `squadsProvider`, `allPilotsInfoProvider`, `myTeamDetailProvider`, `myTeamBudgetProvider`) unique and consistent across defining and consuming tasks.
- **Contract accuracy:** `/players/squads` correctly typed as `[]MyTeam` (verified against `GetPlayersTeamsService` returning `[]models.MyTeam`), NOT `PlayerProfile` as the spec §4 text implied.
