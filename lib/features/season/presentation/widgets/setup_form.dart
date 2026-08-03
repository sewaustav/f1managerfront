import 'package:flutter/material.dart';

import '../../application/setup_math.dart';

class SetupForm extends StatefulWidget {
  const SetupForm({
    super.key,
    required this.pool,
    required this.initial,
    required this.onChanged,
  });

  final int pool;
  final SetupValues initial;
  final ValueChanged<SetupValues> onChanged;

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  late SetupValues _v = widget.initial;

  @override
  void didUpdateWidget(SetupForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resync when the parent hands us a new `initial` (e.g. loading a preset)
    // so the sliders reflect the loaded values instead of the stale capture.
    if (!identical(widget.initial, oldWidget.initial)) {
      _v = widget.initial;
    }
  }

  void _update(SetupValues next) {
    setState(() => _v = next);
    widget.onChanged(next);
  }

  Widget _slider(String label, String key, int value, ValueChanged<int> onChange) {
    final remaining = setupRemaining(_v, widget.pool);
    // This slider's own ceiling is its current value plus whatever the pool has
    // left. When nothing is left (maxVal == value == 0), the slider is pinned at
    // 0 (disabled, no divisions) so the total can never exceed the pool.
    final maxVal = (value + remaining).clamp(0, widget.pool).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        Slider(
          key: Key(key),
          value: value.toDouble(),
          min: 0,
          max: maxVal,
          divisions: maxVal > 0 ? maxVal.toInt() : null,
          label: '$value',
          onChanged: maxVal > 0 ? (d) => onChange(d.round()) : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = setupRemaining(_v, widget.pool);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Осталось токенов: $remaining из ${widget.pool}',
          key: const Key('tokens_remaining'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _slider('Аэродинамика', 'slider_aero', _v.aeroDynamic, (x) => _update(_v.copyWith(aeroDynamic: x))),
        _slider('Мотор', 'slider_engine', _v.engine, (x) => _update(_v.copyWith(engine: x))),
        _slider('Шасси', 'slider_chassis', _v.chassis, (x) => _update(_v.copyWith(chassis: x))),
        _slider('Днище', 'slider_floor', _v.floor, (x) => _update(_v.copyWith(floor: x))),
        _slider('Шины', 'slider_tyres', _v.tyres, (x) => _update(_v.copyWith(tyres: x))),
        _slider(
          'Надёжность',
          'slider_reliability',
          _v.reliability,
          (x) => _update(_v.copyWith(reliability: x)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Прижимная сила:'),
            const SizedBox(width: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Зад')),
                ButtonSegment(value: 1, label: Text('Перёд')),
              ],
              selected: {_v.settingsAngle},
              onSelectionChanged: (s) => _update(_v.copyWith(settingsAngle: s.first)),
            ),
          ],
        ),
      ],
    );
  }
}
