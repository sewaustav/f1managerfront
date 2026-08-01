import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/api/jwt_decode.dart';

String _fakeJwt(Map<String, dynamic> payload) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg({
        'alg': 'RS256'
      })}.${seg(payload)}.sig';
}

void main() {
  test('decodes an integer sub claim', () {
    expect(userIdFromJwt(_fakeJwt({'sub': 42})), 42);
  });

  test('decodes a stringified sub claim (matches this backend)', () {
    expect(userIdFromJwt(_fakeJwt({'sub': '7'})), 7);
  });

  test('returns null for a malformed token', () {
    expect(userIdFromJwt('not-a-jwt'), isNull);
  });

  test('returns null when sub is missing', () {
    expect(userIdFromJwt(_fakeJwt({'iss': 'f1manager'})), isNull);
  });
}
