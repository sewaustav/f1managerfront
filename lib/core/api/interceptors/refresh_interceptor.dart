import 'package:dio/dio.dart';
import '../../storage/token_store.dart';
import '../../models/token_pair.dart';

/// On a 401 (outside `/auth/`), performs a single-flight token refresh via
/// `POST /auth/refresh` and retries the original request once with the new
/// access token.
///
/// Testability note: the refresh call and the retry are both issued on the
/// *same* `dio` instance the interceptor was built with (not a fresh, bare
/// `Dio()`), so tests can drive everything through one mock adapter. This is
/// safe from recursion because:
///   - `/auth/refresh` is skipped by [AuthInterceptor] and by this
///     interceptor's own `isAuthPath` guard, so refreshing never triggers
///     another refresh.
///   - the retried request is marked with [_retriedKey] in `extra` before
///     being re-sent; if it fails again with 401 this interceptor sees the
///     flag already set and passes the error straight through instead of
///     refreshing again, so a persistently-401 endpoint cannot loop.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this.dio,
    required this.store,
    required this.onAuthFailure,
  });

  final Dio dio;
  final TokenStore store;
  final Future<void> Function() onAuthFailure;

  static const _retriedKey = '__retried__';

  Future<TokenPair>? _inflight;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final isAuthPath = err.requestOptions.path.contains('/auth/');
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (status != 401 || isAuthPath || alreadyRetried) {
      return handler.next(err);
    }

    final TokenPair pair;
    try {
      pair = await (_inflight ??= _refresh());
    } catch (_) {
      _inflight = null;
      await store.clear();
      await onAuthFailure();
      return handler.next(err);
    }
    _inflight = null;

    final opts = err.requestOptions;
    opts.extra[_retriedKey] = true;
    opts.headers['Authorization'] = 'Bearer ${pair.accessToken}';

    try {
      final response = await dio.fetch(opts);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      // Retry itself failed (e.g. still 401 even with the new token). The
      // `alreadyRetried` guard above prevents another refresh loop; just
      // surface this error without touching tokens/auth state.
      return handler.next(retryErr);
    }
  }

  Future<TokenPair> _refresh() async {
    final refresh = await store.readRefresh();
    if (refresh == null) throw StateError('no refresh token');
    final res = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refresh},
    );
    final pair = TokenPair.fromJson(res.data!);
    await store.save(access: pair.accessToken, refresh: pair.refreshToken);
    return pair;
  }
}
