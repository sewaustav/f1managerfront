import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/draft_repository.dart';
import '../../model/budget.dart';

final budgetProvider = FutureProvider.autoDispose<Budget>(
    (ref) => ref.watch(draftRepositoryProvider).getBudget());

class BudgetBar extends ConsumerWidget {
  const BudgetBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: budget.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Budget unavailable'),
        data: (b) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget: ${b.budget}   Tokens: ${b.tokens}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: (b.budget / 110).clamp(0.0, 1.0)),
          ],
        ),
      ),
    );
  }
}
