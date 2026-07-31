import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/data/setup_preset_store.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';
import 'package:f1manager/features/season/model/track_info.dart';
import 'package:f1manager/features/season/presentation/race_screen.dart';
import 'package:f1manager/features/season/presentation/token_setup_screen.dart';

class _MockRepo extends Mock implements SeasonRepository {}

void main() {
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

    expect(find.text('Preset exceeds the available 10 tokens'), findsOneWidget);
    expect(find.text('Tokens remaining: 10 / 10'), findsOneWidget);
  });
}
