import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/draft/model/engine.dart';
import 'package:f1manager/features/draft/presentation/widgets/engine_modal.dart';

void main() {
  final engines = [
    const Engine(id: 1, engine: 0, price: 10, baseLevel: 5),
    const Engine(id: 2, engine: 1, price: 8, baseLevel: 4),
  ];

  test('Manufacture team forces its own ICE', () {
    const t = Team(id: 1, name: 'M', ice: 1, isManufacturer: 0);
    expect(allowedEngineChoices(t, engines), [1]);
  });

  test('Semi team may choose any engine', () {
    const t = Team(id: 1, name: 'S', ice: 0, isManufacturer: 1);
    expect(allowedEngineChoices(t, engines), [0, 1]);
  });

  test('Client team may choose any engine or self', () {
    const t = Team(id: 1, name: 'C', ice: 0, isManufacturer: 2);
    expect(allowedEngineChoices(t, engines), [0, 1, kIceSelf]);
  });

  test('engineArgForPick omits engine (null) for self, keeps real engines', () {
    expect(engineArgForPick(kIceSelf), isNull); // backend self path needs field omitted
    expect(engineArgForPick(0), 0);
    expect(engineArgForPick(3), 3);
  });
}
