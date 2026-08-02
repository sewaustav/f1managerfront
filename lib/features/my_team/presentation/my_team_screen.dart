import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/application/auth_controller.dart';
import '../../lobby/application/lobby_controller.dart';
import '../../season/application/season_state_provider.dart';
import '../application/my_team_providers.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(myTeamDetailProvider);
    final budget = ref.watch(myTeamBudgetProvider);
    final groupId = ref.watch(myGroupIdProvider);
    final myId = ref.watch(currentUserIdProvider);
    final isOrganizer = groupId != null && myId != null && myId == groupId;
    final ctrl = ref.read(lobbyControllerProvider.notifier);

    Future<void> confirmAndReset() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('End the game early?'),
          content: const Text(
              'This wipes everyone\'s draft picks, teams, and budget back to a fresh lobby. '
              'This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('End game'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ctrl.resetGroup();
      ref.invalidate(seasonStateProvider);
      ref.invalidate(myTeamDetailProvider);
      ref.invalidate(myTeamBudgetProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        actions: [
          if (isOrganizer)
            IconButton(
              key: const Key('end_game_early_button'),
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: 'End game early',
              onPressed: confirmAndReset,
            ),
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
            Text(t.team.id == 0 ? 'No team picked yet' : t.team.name,
                style: Theme.of(context).textTheme.headlineSmall),
            if (t.team.id != 0) ...[
              const SizedBox(height: 8),
              Text('Car level ${t.team.carLevel} · Base ${t.team.baseLevel} · '
                  'Engineer ${t.team.engineer} · Sim ${t.team.simLevel} · Tube ${t.team.tubeLevel}'),
            ],
            const Divider(height: 24),
            if (t.pilot1.id == 0 && t.pilot2.id == 0)
              const ListTile(title: Text('No pilots picked yet'))
            else ...[
              if (t.pilot1.id != 0)
                ListTile(
                  title: Text(t.pilot1.name),
                  trailing: Text('R ${t.pilot1.rating} · Q ${t.pilot1.qualifyingRating}'),
                ),
              if (t.pilot2.id != 0)
                ListTile(
                  title: Text(t.pilot2.name),
                  trailing: Text('R ${t.pilot2.rating} · Q ${t.pilot2.qualifyingRating}'),
                ),
            ],
            const Divider(height: 24),
            ListTile(
              title: Text(t.principal.id == 0
                  ? 'No principal picked yet'
                  : 'Principal: ${t.principal.name}'),
              trailing: t.principal.id == 0 ? null : Text('Level ${t.principal.level}'),
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
