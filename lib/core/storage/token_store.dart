import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStore {
  Future<void> save({required String access, required String refresh});
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  @override
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  @override
  Future<String?> readAccess() => _storage.read(key: _kAccess);
  @override
  Future<String?> readRefresh() => _storage.read(key: _kRefresh);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

class InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => _access;
  @override
  Future<String?> readRefresh() async => _refresh;
  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}
