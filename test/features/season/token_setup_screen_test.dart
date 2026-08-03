import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/data/setup_preset_store.dart';
import 'package:f1manager/features/season/model/setup_payload.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';
import 'package:f1manager/features/season/presentation/token_setup_screen.dart';

class _MockRepo extends Mock implements SeasonRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const SetupPayload(name: 'x')));

  testWidgets('submits a token setup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = _MockRepo();
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));
    when(() => repo.submitTokenSetup(any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: TokenSetupScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tokens_remaining')), findsOneWidget);
    await tester.tap(find.byKey(const Key('submit_token_setup')));
    await tester.pumpAndSettle();

    verify(() => repo.submitTokenSetup(any())).called(1);
  });

  testWidgets('rejects an over-pool preset with a snackbar and leaves values unchanged', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    await store.add(const SetupPreset(name: 'Too big', aeroDynamic: 20, engine: 20));
    final repo = _MockRepo();
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 10));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: TokenSetupScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_open));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Too big'));
    await tester.pumpAndSettle();

    expect(find.text('Пресет не влезает в доступные 10 токенов'), findsOneWidget);
    expect(find.text('Осталось токенов: 10 из 10'), findsOneWidget);
  });
}
