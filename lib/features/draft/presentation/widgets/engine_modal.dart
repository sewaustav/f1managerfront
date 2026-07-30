import 'package:flutter/material.dart';
import '../../../../core/models/team.dart';
import '../../model/engine.dart';

// IsManufacturer int values (models.IsManufacturer iota): 0=Manufacture,1=Semi,2=Client.
const int _manufacture = 0;
const int _client = 2;

List<int> allowedEngineChoices(Team team, List<Engine> engines) {
  final all = engines.map((e) => e.engine).toList();
  switch (team.isManufacturer) {
    case _manufacture:
      return [team.ice];
    case _client:
      return [...all, kIceSelf];
    default: // Semi
      return all;
  }
}

String engineLabel(int ice) => ice == kIceSelf ? 'Self / default' : 'Engine #$ice';

Future<int?> showEngineModal(
  BuildContext context, {
  required Team team,
  required List<Engine> engines,
}) {
  final choices = allowedEngineChoices(team, engines);
  // Manufacture: single forced engine, confirm directly.
  if (team.isManufacturer == _manufacture) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Engine'),
        content: Text('This is a works team — engine is ${engineLabel(team.ice)}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, team.ice), child: const Text('Confirm')),
        ],
      ),
    );
  }
  final priceOf = {for (final e in engines) e.engine: e.price};
  return showDialog<int>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Choose engine'),
      children: [
        for (final ice in choices)
          SimpleDialogOption(
            key: Key('engine_$ice'),
            onPressed: () => Navigator.pop(ctx, ice),
            child: Text(ice == kIceSelf
                ? 'Self / default'
                : '${engineLabel(ice)}  (${priceOf[ice] ?? '?'})'),
          ),
      ],
    ),
  );
}
