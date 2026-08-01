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
