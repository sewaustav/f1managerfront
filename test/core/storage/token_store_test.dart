import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/storage/token_store.dart';

void main() {
  test('save/read/clear round-trips', () async {
    final store = InMemoryTokenStore();
    expect(await store.readAccess(), isNull);
    await store.save(access: 'a', refresh: 'r');
    expect(await store.readAccess(), 'a');
    expect(await store.readRefresh(), 'r');
    await store.clear();
    expect(await store.readAccess(), isNull);
    expect(await store.readRefresh(), isNull);
  });
}
