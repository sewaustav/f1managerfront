import 'package:flutter/material.dart';
import '../../../../core/models/pilot.dart';

class MyPilotsList extends StatelessWidget {
  const MyPilotsList({super.key, required this.pilots, required this.onFire});

  final List<Pilot> pilots;
  final void Function(Pilot) onFire;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final p in pilots)
            ListTile(
              key: ValueKey(p.id),
              title: Text(p.name),
              trailing: OutlinedButton(
                onPressed: () => onFire(p),
                child: const Text('Уволить'),
              ),
            ),
        ],
      );
}
