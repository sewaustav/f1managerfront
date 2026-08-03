import 'package:flutter/material.dart';

class DraftItemList<T> extends StatefulWidget {
  const DraftItemList({
    super.key,
    required this.items,
    required this.title,
    required this.subtitle,
    required this.searchText,
    required this.enabled,
    required this.onPick,
  });

  final List<T> items;
  final String Function(T) title;
  final String Function(T) subtitle;
  final String Function(T) searchText;
  final bool enabled;
  final void Function(T) onPick;

  @override
  State<DraftItemList<T>> createState() => _DraftItemListState<T>();
}

class _DraftItemListState<T> extends State<DraftItemList<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((e) => widget.searchText(e).toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск'),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _query.isEmpty ? 'Свободных вариантов не осталось' : 'Ничего не найдено',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final t = widget.title(item);
                return Card(
                  child: ListTile(
                    title: Text(t),
                    subtitle: Text(widget.subtitle(item)),
                    trailing: FilledButton(
                      key: Key('pick_$t'),
                      onPressed: widget.enabled ? () => widget.onPick(item) : null,
                      child: const Text('Выбрать'),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
