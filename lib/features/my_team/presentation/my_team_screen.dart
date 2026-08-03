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
          title: const Text('Завершить игру досрочно?'),
          content: const Text(
              'Все выборы драфта, команды и бюджеты сбросятся до пустого лобби. '
              'Отменить это будет нельзя.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Завершить'),
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

    Future<void> confirmAndLeave() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Выйти из группы?'),
          content: const Text(
              'Ваши пилоты вернутся в общий пул, а открытые предложения по трансферам '
              'будут отозваны. Вернуться можно по ID группы.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Выйти'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ctrl.leaveGroup();
      ref.invalidate(seasonStateProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя команда'),
        actions: [
          if (isOrganizer)
            IconButton(
              key: const Key('end_game_early_button'),
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: 'Завершить игру',
              onPressed: confirmAndReset,
            )
          else if (groupId != null)
            IconButton(
              key: const Key('leave_group_button'),
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Выйти из группы',
              onPressed: confirmAndLeave,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти из аккаунта',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: team,
        data: (t) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.team.id == 0 ? 'Команда ещё не выбрана' : t.team.name,
                style: Theme.of(context).textTheme.headlineSmall),
            if (t.team.id != 0) ...[
              const SizedBox(height: 8),
              Text('Болид ${t.team.carLevel} · База ${t.team.baseLevel} · '
                  'Инженеры ${t.team.engineer} · Симулятор ${t.team.simLevel} · Труба ${t.team.tubeLevel}'),
            ],
            const Divider(height: 24),
            if (t.pilot1.id == 0 && t.pilot2.id == 0)
              const ListTile(title: Text('Пилоты ещё не выбраны'))
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
                  ? 'Руководитель ещё не выбран'
                  : 'Руководитель: ${t.principal.name}'),
              trailing: t.principal.id == 0 ? null : Text('Уровень ${t.principal.level}'),
            ),
            const Divider(height: 24),
            budget.when(
              data: (b) => Text('Бюджет ${b.budget} · Токены ${b.tokens}'),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
