import 'package:dio/dio.dart';
import '../../storage/token_store.dart';

/// Attaches `Authorization: Bearer <access>` to every request whose path is
/// not under `/auth/` (login, refresh, etc. must not carry a stale bearer).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._store);
  final TokenStore _store;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains('/auth/')) {
      final token = await _store.readAccess();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
