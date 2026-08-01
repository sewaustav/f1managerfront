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
