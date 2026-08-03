import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/setup_math.dart';
import '../data/season_repository.dart';
import '../data/setup_preset_store.dart';
import '../model/setup_payload.dart';
import '../model/setup_preset.dart';
import 'widgets/setup_form.dart';

final tokenPoolProvider = FutureProvider.autoDispose<int>(
    (ref) async => (await ref.watch(seasonRepositoryProvider).getBudget()).tokens);

class TokenSetupScreen extends ConsumerStatefulWidget {
  const TokenSetupScreen({super.key});
  @override
  ConsumerState<TokenSetupScreen> createState() => _TokenSetupScreenState();
}

class _TokenSetupScreenState extends ConsumerState<TokenSetupScreen> {
  SetupValues _values = const SetupValues();
  bool _submitting = false;
  bool _submitted = false;

  Future<void> _submit(int pool) async {
    if (!setupValid(_values, pool)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(seasonRepositoryProvider).submitTokenSetup(SetupPayload(
            name: 'token-setup',
            aeroDynamic: _values.aeroDynamic,
            engine: _values.engine,
            chassis: _values.chassis,
            floor: _values.floor,
            tyres: _values.tyres,
            reliability: _values.reliability,
            settingsAngle: _values.settingsAngle,
          ));
      setState(() => _submitted = true);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _savePreset() async {
    final store = ref.read(setupPresetStoreProvider);
    final name = await _promptName();
    if (name == null || name.isEmpty) return;
    try {
      await store.add(SetupPreset(
        name: name,
        aeroDynamic: _values.aeroDynamic, engine: _values.engine, chassis: _values.chassis,
        floor: _values.floor, tyres: _values.tyres, reliability: _values.reliability,
        settingsAngle: _values.settingsAngle,
      ));
      setState(() {});
    } on StateError catch (e) {
      if (mounted) showErrorSnackbar(context, e.message);
    }
  }

  Future<String?> _promptName() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Название пресета'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Сохранить')),
        ],
      ),
    );
  }

  void _loadPreset(SetupPreset p, int pool) {
    if (presetTotal(p) > pool) {
      showErrorSnackbar(context, 'Пресет не влезает в доступные $pool токенов');
      return;
    }
    setState(() => _values = SetupValues(
          aeroDynamic: p.aeroDynamic, engine: p.engine, chassis: p.chassis,
          floor: p.floor, tyres: p.tyres, reliability: p.reliability, settingsAngle: p.settingsAngle,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final pool = ref.watch(tokenPoolProvider);
    final presets = ref.watch(setupPresetStoreProvider).load();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Распределение токенов'),
        actions: [
          if (presets.isNotEmpty)
            PopupMenuButton<int>(
              icon: const Icon(Icons.folder_open),
              onSelected: (i) => _loadPreset(presets[i], pool.valueOrNull ?? 0),
              itemBuilder: (_) => [
                for (var i = 0; i < presets.length; i++)
                  PopupMenuItem(value: i, child: Text(presets[i].name)),
              ],
            ),
          IconButton(
            key: const Key('save_preset'),
            onPressed: _savePreset,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _submitted
          ? const Center(child: Text('Настройки отправлены — ждём старта сезона…'))
          : AsyncValueView<int>(
              value: pool,
              onRetry: () => ref.invalidate(tokenPoolProvider),
              data: (poolValue) => Column(
                children: [
                  Expanded(
                    child: SetupForm(
                      pool: poolValue,
                      initial: _values,
                      onChanged: (v) => setState(() => _values = v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      key: const Key('submit_token_setup'),
                      onPressed: _submitting || !setupValid(_values, poolValue)
                          ? null
                          : () => _submit(poolValue),
                      child: const Text('Отправить'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
