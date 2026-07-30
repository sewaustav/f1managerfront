import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
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

    ref.listen(draftControllerProvider.select((s) => s.lastError), (_, err) {
      if (err != null) {
        showErrorSnackbar(context, err);
        ref.read(draftControllerProvider.notifier).clearError();
      }
    });
    ref.listen(draftControllerProvider.select((s) => s.finished), (_, finished) {
      if (finished) context.go('/token-setup');
    });

    final canPick = draft.isMyTurn && !draft.submitting;

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
          title: Text(draft.isMyTurn ? 'Your pick (round ${draft.round + 1})' : 'Waiting for other players'),
          bottom: const TabBar(tabs: [Tab(text: 'Pilots'), Tab(text: 'Teams'), Tab(text: 'Principals')]),
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
                      items: pilots,
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
                      items: teams,
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
                      items: principals,
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
        child: Text('Picks made: $count'),
      );
}
