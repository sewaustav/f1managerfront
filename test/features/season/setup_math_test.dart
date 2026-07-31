import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/features/season/application/setup_math.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';

void main() {
  test('spent = sum of 6 fields, remaining = pool - spent', () {
    const v = SetupValues(aeroDynamic: 5, engine: 5, chassis: 5, floor: 5, tyres: 5, reliability: 5);
    expect(setupSpent(v), 30);
    expect(setupRemaining(v, 35), 5);
    expect(setupValid(v, 35), isTrue);
    expect(setupValid(v, 25), isFalse);
  });

  test('settingsAngle does not count toward spend', () {
    const v = SetupValues(aeroDynamic: 1, settingsAngle: 1);
    expect(setupSpent(v), 1);
  });

  test('presetTotal sums the 6 setup fields and excludes settingsAngle', () {
    const p = SetupPreset(
      name: 'x', aeroDynamic: 5, engine: 5, chassis: 5,
      floor: 5, tyres: 5, reliability: 5, settingsAngle: 1,
    );
    expect(presetTotal(p), 30);
  });

  test('presetTotal vs pool guard decision', () {
    const fits = SetupPreset(name: 'fits', aeroDynamic: 5, engine: 5);
    const overPool = SetupPreset(name: 'over', aeroDynamic: 20, engine: 20);
    expect(presetTotal(fits) > 10, isFalse);
    expect(presetTotal(overPool) > 10, isTrue);
  });
}
