import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_channel_factory.dart';

void main() {
  test('authWsUri appends token query param', () {
    final uri = authWsUri('ws://localhost:8080/api/v1/ws', 'JWT123');
    expect(uri.queryParameters['token'], 'JWT123');
    expect(uri.scheme, 'ws');
    expect(uri.path, '/api/v1/ws');
  });

  test('authWsUri with null token yields empty token param', () {
    final uri = authWsUri('ws://localhost:8080/api/v1/ws', null);
    expect(uri.queryParameters['token'], '');
  });
}
