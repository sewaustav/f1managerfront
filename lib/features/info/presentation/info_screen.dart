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
