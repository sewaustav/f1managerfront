import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/ws/ws_providers.dart';
import '../../season/application/season_state_provider.dart';
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
      appBar: AppBar(title: const Text('Лобби')),
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
        Text('Создать группу', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(key: const Key('group_name_field'), controller: _name,
            decoration: const InputDecoration(labelText: 'Название группы')),
        const SizedBox(height: 8),
        TextField(key: const Key('create_password_field'), controller: _createPw, obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль')),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('create_group_button'),
          onPressed: loading ? null : () => ctrl.create(_name.text.trim(), _createPw.text),
          child: const Text('Создать'),
        ),
        const Divider(height: 48),
        Text('Войти в группу', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(key: const Key('group_id_field'), controller: _joinId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID группы')),
        const SizedBox(height: 8),
        TextField(key: const Key('join_password_field'), controller: _joinPw, obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль')),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('join_group_button'),
          onPressed: loading
              ? null
              : () => ctrl.join(int.tryParse(_joinId.text.trim()) ?? -1, _joinPw.text),
          child: const Text('Войти'),
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
    final myId = ref.watch(currentUserIdProvider);
    final isOrganizer = groupId != null && myId != null && myId == groupId;
    final ctrl = ref.read(lobbyControllerProvider.notifier);

    Future<void> confirmAndKick(Player p) async {
      final name = p.name.isEmpty ? 'Игрок ${p.id}' : p.name;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text('Удалить $name?'),
          content: const Text(
              'Его пилоты вернутся в общий пул, а открытые предложения по '
              'трансферам будут отозваны. Он сможет зайти обратно по ID группы.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ctrl.kickPlayer(p.id);
    }

    Future<void> confirmAndLeave() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Выйти из группы?'),
          content: const Text(
              'Ваши пилоты вернутся в общий пул, а открытые предложения по трансферам '
              'будут отозваны. Вернуться можно по ID группы.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Выйти'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ctrl.leaveGroup();
      ref.invalidate(seasonStateProvider);
    }

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
                    'ID группы: $groupId  (сообщите его друзьям)',
                  ),
                ),
                IconButton(
                  key: const Key('copy_group_id_button'),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Скопировать ID группы',
                  onPressed: () => Clipboard.setData(ClipboardData(text: '$groupId')),
                ),
              ],
            ),
          ),
        Expanded(
          child: AsyncValueView<List<Player>>(
            value: players,
            onRetry: () => ref.invalidate(playersProvider),
            data: (list) => list.isEmpty
                ? const Center(child: Text('Пока никого нет'))
                : ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    children: [
                      for (final p in list)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Text(
                                p.name.isEmpty ? '?' : p.name.characters.first.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            title: Text(p.name.isEmpty ? 'Игрок ${p.id}' : p.name),
                            subtitle:
                                Text('Бюджет ${p.budget}  •  Токены ${p.tokens}'),
                            trailing: p.id == groupId
                                ? const _OrganizerBadge()
                                : (isOrganizer
                                    ? IconButton(
                                        key: Key('kick_${p.id}'),
                                        icon: const Icon(Icons.person_remove_outlined),
                                        tooltip: 'Удалить из группы',
                                        onPressed: () => confirmAndKick(p),
                                      )
                                    : null),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FilledButton(
                key: const Key('start_draft_button'),
                onPressed: () => ctrl.startDraft(),
                child: const Text('Начать драфт'),
              ),
              const SizedBox(height: 8),
              // Завершение игры живёт на экране команды: в лобби оно лишнее,
              // а вот выйти из группы нужно уметь всем, включая организатора.
              OutlinedButton(
                key: const Key('leave_group_button'),
                onPressed: confirmAndLeave,
                child: const Text('Выйти из группы'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Метка организатора: у него единственного есть право завершить игру,
/// поэтому в составе полезно видеть, кто это.
class _OrganizerBadge extends StatelessWidget {
  const _OrganizerBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'организатор',
        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
