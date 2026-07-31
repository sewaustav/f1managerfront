import 'package:flutter/material.dart';

/// Car update window for stages 3/8/13. type 0 = car improvement (coast <= 15),
/// type 1 = pilot-car synergy.
Future<void> showUpdateWindow(
  BuildContext context, {
  required int stage,
  required void Function(int type, int coast) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      int type = 0;
      final coast = TextEditingController(text: '0');
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Car update — stage $stage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Improve car')),
                  ButtonSegment(value: 1, label: Text('Synergy')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('update_amount'),
                controller: coast,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: type == 0 ? 'Amount (max 15M)' : 'Amount',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
            FilledButton(
              key: const Key('confirm_update'),
              onPressed: () {
                final amount = int.tryParse(coast.text.trim()) ?? 0;
                onSubmit(type, type == 0 ? amount.clamp(0, 15) : amount);
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      );
    },
  );
}
