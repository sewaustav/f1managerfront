import '../../../core/models/pilot.dart';
import '../../../core/models/team.dart';
import '../../../core/models/principal.dart';

class MyTeamSummary {
  const MyTeamSummary({
    required this.id,
    required this.pilot1,
    required this.pilot2,
    required this.team,
    required this.principal,
  });

  final int id;
  final Pilot pilot1;
  final Pilot pilot2;
  final Team team;
  final Principal principal;

  factory MyTeamSummary.fromJson(Map<String, dynamic> json) => MyTeamSummary(
        id: (json['id'] as num?)?.toInt() ?? 0,
        pilot1: Pilot.fromJson((json['pilot1'] as Map).cast<String, dynamic>()),
        pilot2: Pilot.fromJson((json['pilot2'] as Map).cast<String, dynamic>()),
        team: Team.fromJson((json['team'] as Map).cast<String, dynamic>()),
        principal: Principal.fromJson((json['team_principal'] as Map).cast<String, dynamic>()),
      );
}
