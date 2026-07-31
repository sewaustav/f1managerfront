import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/features/season/application/setup_math.dart';

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
}
