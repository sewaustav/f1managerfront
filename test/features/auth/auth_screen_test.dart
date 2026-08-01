import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/features/auth/data/auth_repository.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/core/models/token_pair.dart';
import 'package:f1manager/features/auth/model/auth_requests.dart';
import 'package:f1manager/features/auth/presentation/auth_screen.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const LoginRequest(login: 'x', password: 'y')));

  testWidgets('entering credentials and tapping Sign in calls login', (tester) async {
    final repo = _MockRepo();
    when(() => repo.login(any()))
        .thenAnswer((_) async => const TokenPair(accessToken: 'A', refreshToken: 'R'));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: const MaterialApp(home: AuthScreen()),
    ));

    await tester.enterText(find.byKey(const Key('login_field')), 'joe');
    await tester.enterText(find.byKey(const Key('password_field')), 'secretpw');
    await tester.tap(find.byKey(const Key('sign_in_button')));
    await tester.pumpAndSettle();

    verify(() => repo.login(const LoginRequest(login: 'joe', password: 'secretpw'))).called(1);
  });
}
