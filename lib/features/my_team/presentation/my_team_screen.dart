import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/application/auth_controller.dart';
import '../application/my_team_providers.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(myTeamDetailProvider);
    final budget = ref.watch(myTeamBudgetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: team,
        data: (t) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.team.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Car level ${t.team.carLevel} · Base ${t.team.baseLevel} · '
                'Engineer ${t.team.engineer} · Sim ${t.team.simLevel} · Tube ${t.team.tubeLevel}'),
            const Divider(height: 24),
            ListTile(
              title: Text(t.pilot1.name),
              trailing: Text('R ${t.pilot1.rating} · Q ${t.pilot1.qualifyingRating}'),
            ),
            ListTile(
              title: Text(t.pilot2.name),
              trailing: Text('R ${t.pilot2.rating} · Q ${t.pilot2.qualifyingRating}'),
            ),
            const Divider(height: 24),
            ListTile(
              title: Text('Principal: ${t.principal.name}'),
              trailing: Text('Level ${t.principal.level}'),
            ),
            const Divider(height: 24),
            budget.when(
              data: (b) => Text('Budget ${b.budget} · Tokens ${b.tokens}'),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
