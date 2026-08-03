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

/// Maps a chosen engine value to the `engine` argument for `POST /draft/pick`.
/// The backend's `resolveEngine` only takes the Client self/default path when
/// the `engine` field is OMITTED (nil) — an explicit `Self` (kIceSelf) value is
/// not a real engine row and would be rejected. So "self" must be sent as null.
int? engineArgForPick(int chosen) => chosen == kIceSelf ? null : chosen;

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
        title: const Text('Мотор'),
        content: Text('Это заводская команда — мотор ${engineLabel(team.ice)}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, team.ice), child: const Text('Подтвердить')),
        ],
      ),
    );
  }
  final priceOf = {for (final e in engines) e.engine: e.price};
  return showDialog<int>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Выбор мотора'),
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
