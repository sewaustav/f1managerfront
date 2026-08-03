import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../inter_season/model/my_team_summary.dart';
import '../application/info_providers.dart';

String _squadSubtitle(MyTeamSummary s) {
  final pilots = [s.pilot1, s.pilot2].where((p) => p.id != 0).map((p) => p.name).join(' / ');
  final principal = s.principal.id == 0 ? 'руководитель не выбран' : s.principal.name;
  return pilots.isEmpty ? principal : '$pilots · $principal';
}

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Справка'),
          bottom: const TabBar(
              tabs: [Tab(text: 'Трассы'), Tab(text: 'Составы'), Tab(text: 'Пилоты')]),
        ),
        body: TabBarView(children: [
          AsyncValueView(
            value: ref.watch(tracksProvider),
            data: (tracks) => ListView(children: [
              for (final t in tracks)
                ListTile(
                  title: Text(t.name),
                  subtitle: Text('тип ${t.type} · сложность ${t.difficulty} · дождь ${t.rainPossibility}%'),
                ),
            ]),
          ),
          AsyncValueView(
            value: ref.watch(squadsProvider),
            data: (squads) => ListView(children: [
              for (final s in squads)
                ListTile(
                  title: Text(s.team.id == 0 ? 'Команда ещё не выбрана' : s.team.name),
                  subtitle: Text(_squadSubtitle(s)),
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
