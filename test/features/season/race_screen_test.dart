import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';
import 'package:f1manager/features/season/data/setup_preset_store.dart';
import 'package:f1manager/features/season/model/setup_payload.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';
import 'package:f1manager/features/season/model/track_info.dart';
import 'package:f1manager/features/season/presentation/race_screen.dart';
import 'package:f1manager/features/season/presentation/token_setup_screen.dart';

class _MockRepo extends Mock implements SeasonRepository {}

class _FakeSeasonStateRepo extends SeasonStateRepository {
  _FakeSeasonStateRepo(this.value) : super(Dio());
  final SeasonState value;
  @override
  Future<SeasonState> getSeasonState() async => value;
}

void main() {
  setUpAll(() => registerFallbackValue(const SetupPayload(name: 'x')));


  testWidgets('renders track and a confirm-setup button', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async =>
        [const TrackInfo(id: 1, name: 'Monaco', difficulty: 80, rainPossibility: 40, tyre: 2, type: 1)]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Monaco'), findsOneWidget);
    expect(find.byKey(const Key('confirm_setup')), findsOneWidget);
    // No saved presets yet, so the preset picker action is hidden.
    expect(find.byKey(const Key('race_presets')), findsNothing);
  });

  testWidgets('shows the preset picker menu when a preset is saved', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async =>
        [const TrackInfo(id: 1, name: 'Monaco', difficulty: 80, rainPossibility: 40, tyre: 2, type: 1)]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    await store.add(const SetupPreset(name: 'Wet setup', aeroDynamic: 5, engine: 5));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('race_presets')), findsOneWidget);

    await tester.tap(find.byKey(const Key('race_presets')));
    await tester.pumpAndSettle();
    expect(find.text('Wet setup'), findsOneWidget);

    await tester.tap(find.text('Wet setup'));
    await tester.pumpAndSettle();

    expect(find.text('Tokens remaining: 25 / 35'), findsOneWidget);
  });

  testWidgets('rejects an over-pool preset with a snackbar and leaves values unchanged', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async =>
        [const TrackInfo(id: 1, name: 'Monaco', difficulty: 80, rainPossibility: 40, tyre: 2, type: 1)]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 10));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    await store.add(const SetupPreset(name: 'Too big', aeroDynamic: 20, engine: 20));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 10),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('race_presets')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Too big'));
    await tester.pumpAndSettle();

    expect(find.text('Пресет не влезает в доступные 10 токенов'), findsOneWidget);
    expect(find.text('Tokens remaining: 10 / 10'), findsOneWidget);
  });

  testWidgets('selects the track for the current stage instead of the manual pick', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async => const [
          TrackInfo(id: 1, name: 'Monaco', type: 1),
          TrackInfo(id: 2, name: 'Silverstone'),
          TrackInfo(id: 3, name: 'Spa'),
          TrackInfo(id: 4, name: 'Suzuka'),
          TrackInfo(id: 5, name: 'Interlagos'),
        ]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => true),
        hasGroupProvider.overrideWith((ref) => true),
        seasonRepositoryProvider.overrideWithValue(repo),
        seasonStateRepositoryProvider.overrideWithValue(
          _FakeSeasonStateRepo(const SeasonState(phase: SeasonPhase.racing, stage: 5)),
        ),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    // Stage 5 maps to the 5th track (1-based stage -> tracks[stage - 1]).
    expect(find.text('Interlagos'), findsOneWidget);
    expect(find.text('Monaco'), findsNothing);
    // The manual picker is superseded once the season state resolves the track.
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('falls back to the manual track picker when season state is unavailable', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async => const [
          TrackInfo(id: 1, name: 'Monaco', type: 1),
          TrackInfo(id: 2, name: 'Silverstone'),
        ]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        // isAuthenticatedProvider/hasGroupProvider left at their defaults
        // (false): seasonStateProvider's session gate short-circuits to
        // SeasonPhase.unknown/stage 0 without hitting the repo, which is the
        // degraded mode this test exercises.
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Monaco'), findsOneWidget);
    expect(find.text('Трасса 1 из 2'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('shows an N of M submitted waiting indicator', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async =>
        [const TrackInfo(id: 1, name: 'Monaco', difficulty: 80, rainPossibility: 40, tyre: 2, type: 1)]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));
    when(() => repo.submitSetup(any())).thenAnswer((_) async {});

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => true),
        hasGroupProvider.overrideWith((ref) => true),
        seasonRepositoryProvider.overrideWithValue(repo),
        seasonStateRepositoryProvider.overrideWithValue(
          _FakeSeasonStateRepo(const SeasonState(
            phase: SeasonPhase.racing,
            stage: 1,
            submittedSetups: [1, 2],
            totalPlayers: 4,
          )),
        ),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm_setup')));
    await tester.pump();

    expect(find.text('Ожидаем других игроков…'), findsOneWidget);
    expect(find.text('Отправили: 2 из 4'), findsOneWidget);
  });
}
