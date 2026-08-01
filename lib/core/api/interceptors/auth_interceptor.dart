import 'package:dio/dio.dart';
import '../../storage/token_store.dart';

/// Attaches `Authorization: Bearer <access>` to every request except the
/// unauthenticated auth endpoints (login/register/refresh). `/auth/logout`
/// IS authenticated and must carry the bearer, so it is not excluded here.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._store);
  final TokenStore _store;

  /// Endpoints that must NOT carry a bearer (they issue/rotate tokens).
  static const _unauthenticatedPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isUnauthenticated =
        _unauthenticatedPaths.any((p) => options.path.contains(p));
    if (!isUnauthenticated) {
      final token = await _store.readAccess();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
