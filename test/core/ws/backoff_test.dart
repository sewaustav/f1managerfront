import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_service.dart';

void main() {
  test('exponential backoff capped at 30s', () {
    expect(backoffDelay(0), const Duration(seconds: 1));
    expect(backoffDelay(1), const Duration(seconds: 2));
    expect(backoffDelay(2), const Duration(seconds: 4));
    expect(backoffDelay(5), const Duration(seconds: 30));
    expect(backoffDelay(10), const Duration(seconds: 30));
  });
}
