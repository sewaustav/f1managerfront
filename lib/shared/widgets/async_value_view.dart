import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_snackbar.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({super.key, required this.value, required this.data, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage(e), textAlign: TextAlign.center),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton(onPressed: onRetry, child: const Text('Повторить')),
              ),
          ],
        ),
      ),
      data: data,
    );
  }
}
