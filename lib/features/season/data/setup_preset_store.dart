import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/setup_preset.dart';

class SetupPresetStore {
  SetupPresetStore(this._prefs);

  final SharedPreferences _prefs;

  static const maxPresets = 3;
  static const _key = 'setup_presets';

  List<SetupPreset> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(SetupPreset.fromJson).toList();
  }

  Future<void> saveAll(List<SetupPreset> presets) => _prefs.setString(
        _key,
        jsonEncode(presets.map((p) => p.toJson()).toList()),
      );

  Future<void> add(SetupPreset p) async {
    final current = load();
    if (current.length >= maxPresets) {
      throw StateError('Maximum $maxPresets presets reached');
    }
    await saveAll([...current, p]);
  }

  Future<void> removeAt(int i) async {
    final current = [...load()]..removeAt(i);
    await saveAll(current);
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main'),
);

final setupPresetStoreProvider = Provider<SetupPresetStore>(
  (ref) => SetupPresetStore(ref.watch(sharedPrefsProvider)),
);
