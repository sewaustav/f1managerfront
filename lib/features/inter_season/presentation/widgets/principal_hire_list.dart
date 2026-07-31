import 'package:flutter/material.dart';
import '../../../../core/models/principal.dart';

class PrincipalHireList extends StatelessWidget {
  const PrincipalHireList({
    super.key,
    required this.principals,
    required this.currentPrincipalId,
    required this.onHire,
    required this.onFire,
  });

  final List<Principal> principals;
  final int? currentPrincipalId;
  final void Function(Principal) onHire;
  final void Function(Principal) onFire;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          for (final p in principals)
            ListTile(
              title: Text(p.name),
              subtitle: Text('Level ${p.level} · ${p.price}'),
              trailing: p.id == currentPrincipalId
                  ? OutlinedButton(onPressed: () => onFire(p), child: const Text('Fire'))
                  : FilledButton(onPressed: () => onHire(p), child: const Text('Hire')),
            ),
        ],
      );
}
