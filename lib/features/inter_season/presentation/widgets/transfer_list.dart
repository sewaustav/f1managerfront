import 'package:flutter/material.dart';
import '../../../../core/models/pilot.dart';

class TransferList extends StatelessWidget {
  const TransferList({
    super.key,
    required this.pilots,
    required this.onBuy,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Pilot> pilots;
  final void Function(Pilot pilot, int price) onBuy;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: pilots.length,
        itemBuilder: (_, i) => _TransferRow(
          key: ValueKey(pilots[i].id),
          pilot: pilots[i],
          onBuy: onBuy,
        ),
      );
}

class _TransferRow extends StatefulWidget {
  const _TransferRow({super.key, required this.pilot, required this.onBuy});
  final Pilot pilot;
  final void Function(Pilot pilot, int price) onBuy;

  @override
  State<_TransferRow> createState() => _TransferRowState();
}

class _TransferRowState extends State<_TransferRow> {
  late final TextEditingController _price =
      TextEditingController(text: widget.pilot.price.toString());

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(widget.pilot.name),
        subtitle: SizedBox(
          width: 120,
          child: TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Цена'),
          ),
        ),
        trailing: FilledButton(
          onPressed: () =>
              widget.onBuy(widget.pilot, int.tryParse(_price.text) ?? widget.pilot.price),
          child: const Text('Купить'),
        ),
      );
}
