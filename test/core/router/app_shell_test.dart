import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:f1manager/core/router/app_shell.dart';

GoRouter _buildRouter() {
  return GoRouter(
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
}

void main() {
  testWidgets(
      'narrow layout renders NavigationBar with four destinations and switches branch',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Standings'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('My Team'), findsOneWidget);

    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('Standings'));
    await tester.pumpAndSettle();
    expect(find.text('STAND'), findsOneWidget);
  });

  testWidgets(
      'wide layout renders NavigationRail with four destinations and switches branch',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Standings'), findsWidgets); // nav label

    await tester.tap(find.text('Standings').last);
    await tester.pumpAndSettle();
    expect(find.text('STAND'), findsOneWidget);
  });
}
