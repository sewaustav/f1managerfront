import 'dart:convert';

/// Reads the `sub` claim out of an already-issued, already-trusted JWT for
/// DISPLAY purposes only — the server verifies the signature on every
/// request; this never gates access.
int? userIdFromJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    var payload = parts[1];
    payload += '=' * ((4 - payload.length % 4) % 4);
    final json = jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
    final sub = json['sub'];
    if (sub is int) return sub;
    if (sub is String) return int.tryParse(sub);
    return null;
  } catch (_) {
    return null;
  }
}
