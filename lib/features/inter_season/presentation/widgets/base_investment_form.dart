import 'package:flutter/material.dart';
import '../../../../core/models/team.dart';

class BaseInvestmentForm extends StatefulWidget {
  const BaseInvestmentForm({super.key, required this.initial, required this.onSubmit});

  final Team initial;
  final void Function({required int base, required int engineer, required int tube, required int sim})
      onSubmit;

  @override
  State<BaseInvestmentForm> createState() => _BaseInvestmentFormState();
}

class _BaseInvestmentFormState extends State<BaseInvestmentForm> {
  late int _base = widget.initial.baseLevel.clamp(0, 10);
  late int _engineer = widget.initial.engineer.clamp(0, 5);
  late int _tube = widget.initial.tubeLevel.clamp(0, 5);
  late int _sim = widget.initial.simLevel.clamp(0, 5);

  Widget _slider(String label, int value, int max, ValueChanged<int> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value / $max'),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: max.toDouble(),
            divisions: max,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _slider('Base', _base, 10, (v) => setState(() => _base = v)),
          _slider('Engineer', _engineer, 5, (v) => setState(() => _engineer = v)),
          _slider('Tube', _tube, 5, (v) => setState(() => _tube = v)),
          _slider('Simulator', _sim, 5, (v) => setState(() => _sim = v)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                widget.onSubmit(base: _base, engineer: _engineer, tube: _tube, sim: _sim),
            child: const Text('Отправить'),
          ),
        ],
      );
}
