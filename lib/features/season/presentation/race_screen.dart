import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/season_controller.dart';
import '../application/setup_math.dart';
import '../data/season_repository.dart';
import '../data/setup_preset_store.dart';
import '../model/race_result.dart';
import '../model/setup_payload.dart';
import '../model/setup_preset.dart';
import '../model/track_info.dart';
import 'token_setup_screen.dart';
import 'widgets/setup_form.dart';
import 'widgets/track_card.dart';
import 'widgets/update_window.dart';

final tracksProvider =
    FutureProvider.autoDispose<List<TrackInfo>>((ref) => ref.watch(seasonRepositoryProvider).getTracks());

class RaceScreen extends ConsumerStatefulWidget {
  const RaceScreen({super.key});
  @override
  ConsumerState<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends ConsumerState<RaceScreen> {
  SetupValues _values = const SetupValues();
  int _trackIndex = 0;

  @override
  Widget build(BuildContext context) {
    final season = ref.watch(seasonControllerProvider);

    ref.listen(seasonControllerProvider.select((s) => s.error), (_, err) {
      if (err != null) showErrorSnackbar(context, err);
    });
    ref.listen(seasonControllerProvider.select((s) => s.result), (prev, result) {
      if (result != null && _isUpdateStage(result.stage)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowUpdate(result.stage));
      }
    });

    if (season.result != null) {
      return _ResultsView(
        result: season.result!,
        onNext: () => ref.read(seasonControllerProvider.notifier).reset(),
      );
    }
    if (season.waiting) {
      return const Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Waiting for other players…'),
        ])),
      );
    }

    final tracks = ref.watch(tracksProvider);
    final pool = ref.watch(tokenPoolProvider);
    final presets = ref.watch(setupPresetStoreProvider).load();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Race setup'),
        actions: [
          if (presets.isNotEmpty)
            PopupMenuButton<int>(
              key: const Key('race_presets'),
              icon: const Icon(Icons.folder_open),
              onSelected: (i) => _loadPreset(presets[i], pool.valueOrNull ?? 0),
              itemBuilder: (_) => [
                for (var i = 0; i < presets.length; i++)
                  PopupMenuItem(value: i, child: Text(presets[i].name)),
              ],
            ),
        ],
      ),
      body: AsyncValueView<List<TrackInfo>>(
        value: tracks,
        onRetry: () => ref.invalidate(tracksProvider),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No track data'));
          final idx = _trackIndex.clamp(0, list.length - 1);
          return Column(
            children: [
              TrackCard(list[idx]),
              if (list.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: idx > 0 ? () => setState(() => _trackIndex = idx - 1) : null,
                        icon: const Icon(Icons.chevron_left)),
                    Text('Track ${idx + 1}/${list.length}'),
                    IconButton(onPressed: idx < list.length - 1 ? () => setState(() => _trackIndex = idx + 1) : null,
                        icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              Expanded(
                child: pool.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(errorMessage(e))),
                  data: (poolValue) => SetupForm(
                    pool: poolValue,
                    initial: _values,
                    onChanged: (v) => setState(() => _values = v),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  key: const Key('confirm_setup'),
                  onPressed: pool.maybeWhen(
                    data: (poolValue) => setupValid(_values, poolValue)
                        ? () => ref.read(seasonControllerProvider.notifier).submitSetup(_payload())
                        : null,
                    orElse: () => null,
                  ),
                  child: const Text('Confirm setup'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _loadPreset(SetupPreset p, int pool) {
    if (presetTotal(p) > pool) {
      showErrorSnackbar(context, 'Preset exceeds the available $pool tokens');
      return;
    }
    setState(() => _values = SetupValues(
          aeroDynamic: p.aeroDynamic, engine: p.engine, chassis: p.chassis,
          floor: p.floor, tyres: p.tyres, reliability: p.reliability, settingsAngle: p.settingsAngle,
        ));
  }

  SetupPayload _payload() => SetupPayload(
        name: 'race',
        aeroDynamic: _values.aeroDynamic, engine: _values.engine, chassis: _values.chassis,
        floor: _values.floor, tyres: _values.tyres, reliability: _values.reliability,
        settingsAngle: _values.settingsAngle,
      );

  bool _isUpdateStage(int stage) => stage == 3 || stage == 8 || stage == 13;

  Future<void> _maybeShowUpdate(int stage) async {
    if (!mounted) return;
    await showUpdateWindow(context, stage: stage, onSubmit: (type, coast) async {
      try {
        await ref
            .read(seasonRepositoryProvider)
            .makeUpdate(type: type, coast: coast, stage: stage);
      } catch (e) {
        if (mounted) showErrorSnackbar(context, e);
      }
    });
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.result, required this.onNext});
  final RaceResultResponse result;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results — stage ${result.stage}')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Pos')),
                    DataColumn(label: Text('Pilot')),
                    DataColumn(label: Text('Team')),
                    DataColumn(label: Text('Quali')),
                    DataColumn(label: Text('Pts')),
                    DataColumn(label: Text('DNF')),
                  ],
                  rows: [
                    for (final r in result.results)
                      DataRow(cells: [
                        DataCell(Text('${r.racePosition}')),
                        DataCell(Text(r.pilotName)),
                        DataCell(Text(r.teamName)),
                        DataCell(Text('${r.qualiPosition}')),
                        DataCell(Text('${r.points}')),
                        DataCell(Text(r.isDnf ? r.dnfReason.isEmpty ? 'DNF' : r.dnfReason : '')),
                      ]),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('next_stage'),
              onPressed: onNext,
              child: const Text('Next stage'),
            ),
          ),
        ],
      ),
    );
  }
}
