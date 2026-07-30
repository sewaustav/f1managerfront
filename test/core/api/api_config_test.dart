import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/api/api_config.dart';

void main() {
  test('localhost → http/ws', () {
    const c = ApiConfig(host: 'localhost:8080');
    expect(c.restBaseUrl, 'http://localhost:8080/api/v1');
    expect(c.wsUrl, 'ws://localhost:8080/api/v1/ws');
    expect(c.isSecure, isFalse);
  });

  test('remote host → https/wss', () {
    const c = ApiConfig(host: 'api.f1.example');
    expect(c.restBaseUrl, 'https://api.f1.example/api/v1');
    expect(c.wsUrl, 'wss://api.f1.example/api/v1/ws');
    expect(c.isSecure, isTrue);
  });

  test('127.0.0.1 treated as insecure local', () {
    const c = ApiConfig(host: '127.0.0.1:8080');
    expect(c.isSecure, isFalse);
  });
}
