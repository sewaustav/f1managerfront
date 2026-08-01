import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../../../core/ws/ws_providers.dart';
import '../application/lobby_controller.dart';
import '../model/player.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(lobbyControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) showErrorSnackbar(context, next.error!);
    });
    final hasGroup = ref.watch(hasGroupProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: hasGroup ? const _GroupLobby() : const _CreateJoin(),
    );
  }
}

class _CreateJoin extends ConsumerStatefulWidget {
  const _CreateJoin();
  @override
  ConsumerState<_CreateJoin> createState() => _CreateJoinState();
}

class _CreateJoinState extends ConsumerState<_CreateJoin> {
  final _name = TextEditingController();
  final _createPw = TextEditingController();
  final _joinId = TextEditingController();
  final _joinPw = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _createPw.dispose();
    _joinId.dispose();
    _joinPw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(lobbyControllerProvider).isLoading;
    final ctrl = ref.read(lobbyControllerProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Create a group', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(key: const Key('group_name_field'), controller: _name,
            decoration: const InputDecoration(labelText: 'Group name')),
        const SizedBox(height: 8),
        TextField(key: const Key('create_password_field'), controller: _createPw, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('create_group_button'),
          onPressed: loading ? null : () => ctrl.create(_name.text.trim(), _createPw.text),
          child: const Text('Create'),
        ),
        const Divider(height: 48),
        Text('Join a group', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(key: const Key('group_id_field'), controller: _joinId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Group ID')),
        const SizedBox(height: 8),
        TextField(key: const Key('join_password_field'), controller: _joinPw, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('join_group_button'),
          onPressed: loading
              ? null
              : () => ctrl.join(int.tryParse(_joinId.text.trim()) ?? -1, _joinPw.text),
          child: const Text('Join'),
        ),
      ],
    );
  }
}

class _GroupLobby extends ConsumerWidget {
  const _GroupLobby();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the authenticated WebSocket alive while the user is in a group.
    ref.watch(wsMessagesProvider);
    final players = ref.watch(playersProvider);
    final groupId = ref.watch(myGroupIdProvider);
    final ctrl = ref.read(lobbyControllerProvider.notifier);
    return Column(
      children: [
        if (groupId != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    key: const Key('group_id_display'),
                    'Group ID: $groupId  (share this to invite others)',
                  ),
                ),
                IconButton(
                  key: const Key('copy_group_id_button'),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy group ID',
                  onPressed: () => Clipboard.setData(ClipboardData(text: '$groupId')),
                ),
              ],
            ),
          ),
        Expanded(
          child: AsyncValueView<List<Player>>(
            value: players,
            onRetry: () => ref.invalidate(playersProvider),
            data: (list) => ListView(
              children: [
                for (final p in list)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p.name),
                    subtitle: Text('Budget ${p.budget}  •  Tokens ${p.tokens}'),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('start_draft_button'),
            onPressed: () => ctrl.startDraft(),
            child: const Text('Start draft'),
          ),
        ),
      ],
    );
  }
}
