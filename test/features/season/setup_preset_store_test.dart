import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f1manager/features/season/data/setup_preset_store.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SetupPreset preset(String name) => SetupPreset(
        name: name, aeroDynamic: 5, engine: 5, chassis: 5,
        floor: 5, tyres: 5, reliability: 10, settingsAngle: 0,
      );

  test('add + load round-trips', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    expect(store.load(), isEmpty);
    await store.add(preset('Aggressive'));
    final loaded = store.load();
    expect(loaded.single.name, 'Aggressive');
    expect(loaded.single.reliability, 10);
  });

  test('cannot exceed 3 presets', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    await store.add(preset('a'));
    await store.add(preset('b'));
    await store.add(preset('c'));
    expect(() => store.add(preset('d')), throwsStateError);
  });

  test('removeAt drops the preset', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = SetupPresetStore(prefs);
    await store.add(preset('a'));
    await store.add(preset('b'));
    await store.removeAt(0);
    expect(store.load().single.name, 'b');
  });
}
