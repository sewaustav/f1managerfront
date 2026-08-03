import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/nav_guard.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../../lobby/application/lobby_controller.dart' show playersProvider;
import '../../lobby/model/player.dart';
import '../application/draft_controller.dart';
import '../application/draft_data_providers.dart';
import 'widgets/budget_bar.dart';
import 'widgets/draft_item_list.dart';
import 'widgets/engine_modal.dart';

class DraftScreen extends ConsumerWidget {
  const DraftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftControllerProvider);
    final players = ref.watch(playersProvider).valueOrNull ?? const <Player>[];

    ref.listen(draftControllerProvider.select((s) => s.lastError), (_, err) {
      if (err != null) {
        showErrorSnackbar(context, err);
        ref.read(draftControllerProvider.notifier).clearError();
      }
    });
    ref.listen(draftControllerProvider.select((s) => s.finished), (_, finished) {
      if (finished && isCurrentLocation(context, '/draft')) context.go('/token-setup');
    });

    final canPick = draft.isMyTurn && !draft.submitting;

    final takenTeamIds = players.map((p) => p.team).where((t) => t != 0).toSet();
    final takenPrincipalIds = players.map((p) => p.teamPrincipal).whereType<int>().toSet();

    String turnTitle() {
      if (draft.isMyTurn) return 'Ваш выбор (круг ${draft.round + 1})';
      final currentId = draft.currentUserId;
      if (currentId != null) {
        for (final p in players) {
          if (p.id == currentId) return 'Выбирает ${p.name} (круг ${draft.round + 1})';
        }
      }
      return 'Ожидаем других игроков';
    }

    Future<void> pickPilot(int id) async {
      await ref.read(draftControllerProvider.notifier).submitPick(pick: 0, itemId: id);
      ref.invalidate(budgetProvider);
    }

    Future<void> pickPrincipal(int id) async {
      await ref.read(draftControllerProvider.notifier).submitPick(pick: 2, itemId: id);
      ref.invalidate(budgetProvider);
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(turnTitle()),
          actions: [
            IconButton(
              key: const Key('refresh_turn_button'),
              icon: const Icon(Icons.refresh),
              tooltip: 'Обновить состояние хода',
              onPressed: () => ref.read(draftControllerProvider.notifier).refreshTurnState(),
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Пилоты'), Tab(text: 'Команды'), Tab(text: 'Руководители')]),
        ),
        body: Column(
          children: [
            const BudgetBar(),
            Expanded(
              child: TabBarView(
                children: [
                  AsyncValueView(
                    value: ref.watch(pilotsProvider),
                    onRetry: () => ref.invalidate(pilotsProvider),
                    data: (pilots) => DraftItemList(
                      items: pilots.where((p) => p.team == null).toList(),
                      title: (p) => p.name,
                      subtitle: (p) => 'Rating ${p.rating} • ${p.price - p.sponsors}M',
                      searchText: (p) => p.name,
                      enabled: canPick,
                      onPick: (p) => pickPilot(p.id),
                    ),
                  ),
                  AsyncValueView(
                    value: ref.watch(teamsProvider),
                    onRetry: () => ref.invalidate(teamsProvider),
                    data: (teams) => DraftItemList(
                      items: teams.where((t) => !takenTeamIds.contains(t.id)).toList(),
                      title: (t) => t.name,
                      subtitle: (t) => 'Budget ${t.budget}M',
                      searchText: (t) => t.name,
                      enabled: canPick,
                      onPick: (t) async {
                        final engines = await ref.read(enginesProvider.future);
                        if (!context.mounted) return;
                        final engine = await showEngineModal(context, team: t, engines: engines);
                        if (engine == null) return; // cancelled
                        // "Self / default" (kIceSelf) must be sent as an omitted
                        // engine field so the backend takes the self path.
                        await ref.read(draftControllerProvider.notifier)
                            .submitPick(pick: 1, itemId: t.id, engine: engineArgForPick(engine));
                        ref.invalidate(budgetProvider);
                      },
                    ),
                  ),
                  AsyncValueView(
                    value: ref.watch(principalsProvider),
                    onRetry: () => ref.invalidate(principalsProvider),
                    data: (principals) => DraftItemList(
                      items: principals.where((p) => !takenPrincipalIds.contains(p.id)).toList(),
                      title: (p) => p.name,
                      subtitle: (p) => 'Level ${p.level} • ${p.price}M',
                      searchText: (p) => p.name,
                      enabled: canPick,
                      onPick: (p) => pickPrincipal(p.id),
                    ),
                  ),
                ],
              ),
            ),
            _History(count: draft.history.length),
          ],
        ),
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text('Выборов сделано: $count'),
      );
}
