import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../application/standings_providers.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  Widget _list(List<StandingRow> rows) => ListView.builder(
        itemCount: rows.length,
        itemBuilder: (_, i) => ListTile(
          leading: Text('${i + 1}'),
          title: Text(rows[i].name),
          trailing: Text('${rows[i].points}'),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Standings'),
          bottom: const TabBar(tabs: [Tab(text: 'WDC'), Tab(text: 'WCC')]),
        ),
        body: TabBarView(children: [
          AsyncValueView(value: ref.watch(driverStandingsProvider), data: _list),
          AsyncValueView(value: ref.watch(teamStandingsProvider), data: _list),
        ]),
      ),
    );
  }
}
