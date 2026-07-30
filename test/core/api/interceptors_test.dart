import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/core/api/interceptors/auth_interceptor.dart';
import 'package:f1manager/core/api/interceptors/refresh_interceptor.dart';
import 'package:f1manager/core/storage/token_store.dart';

void main() {
  group('AuthInterceptor', () {
    test('attaches bearer to non-auth paths', () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'AAA', refresh: 'r');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      dio.interceptors.add(AuthInterceptor(store));
      final adapter = DioAdapter(dio: dio);
      adapter.onGet('/pilots', (s) => s.reply(200, []),
          headers: {'Authorization': 'Bearer AAA'});

      final r = await dio.get('/pilots');

      expect(r.statusCode, 200);
    });

    test('does NOT attach bearer to /auth/ paths', () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'AAA', refresh: 'r');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      Map<String, dynamic>? captured;
      dio.interceptors.add(AuthInterceptor(store));
      // Capture the outgoing headers after AuthInterceptor has run.
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        captured = Map<String, dynamic>.from(options.headers);
        handler.next(options);
      }));
      final adapter = DioAdapter(dio: dio);
      adapter.onPost('/auth/login', (s) => s.reply(200, {'ok': true}));

      final r = await dio.post('/auth/login');

      expect(r.statusCode, 200);
      expect(captured, isNotNull);
      expect(captured!.containsKey('Authorization'), isFalse);
    });
  });

  group('RefreshInterceptor', () {
    test('refreshes once on 401, rotates tokens, retries with new bearer',
        () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'OLD', refresh: 'REFRESH');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      final adapter = DioAdapter(dio: dio);
      var authFailed = false;
      dio.interceptors.add(RefreshInterceptor(
        dio: dio,
        store: store,
        onAuthFailure: () async => authFailed = true,
      ));

      var refreshCalls = 0;
      adapter
        // Original request with the stale token: unauthorized.
        ..onGet('/my-team', (s) => s.reply(401, {'error': 'unauthorized'}))
        // Retried request presents the new token: succeeds. Registered after
        // the 401 route so it wins the match once the Authorization header
        // carries the rotated token (see http_mock_adapter header subset
        // matching + last-registered-match-wins semantics).
        ..onGet('/my-team', (s) => s.reply(200, {'team': 'Ferrari'}),
            headers: {'Authorization': 'Bearer NEW'})
        ..onPost(
          '/auth/refresh',
          (s) => s.replyCallback(200, (options) {
            refreshCalls++;
            return {'access_token': 'NEW', 'refresh_token': 'R2'};
          }, delay: const Duration(milliseconds: 30)),
          data: {'refresh_token': 'REFRESH'},
        );

      final response = await dio.get('/my-team');

      expect(response.statusCode, 200);
      expect(refreshCalls, 1);
      expect(await store.readAccess(), 'NEW');
      expect(await store.readRefresh(), 'R2');
      expect(authFailed, isFalse);
    });

    test('single-flight: concurrent 401s share one refresh call', () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'OLD', refresh: 'REFRESH');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      final adapter = DioAdapter(dio: dio);
      var authFailed = false;
      dio.interceptors.add(RefreshInterceptor(
        dio: dio,
        store: store,
        onAuthFailure: () async => authFailed = true,
      ));

      var refreshCalls = 0;
      adapter
        ..onGet('/my-team', (s) => s.reply(401, {'error': 'unauthorized'}))
        ..onGet('/my-team', (s) => s.reply(200, {'team': 'Ferrari'}),
            headers: {'Authorization': 'Bearer NEW'})
        ..onPost(
          '/auth/refresh',
          (s) => s.replyCallback(200, (options) {
            refreshCalls++;
            return {'access_token': 'NEW', 'refresh_token': 'R2'};
          }, delay: const Duration(milliseconds: 30)),
          data: {'refresh_token': 'REFRESH'},
        );

      final results = await Future.wait([
        dio.get('/my-team'),
        dio.get('/my-team'),
      ]);

      expect(results[0].statusCode, 200);
      expect(results[1].statusCode, 200);
      expect(refreshCalls, 1);
      expect(await store.readAccess(), 'NEW');
      expect(authFailed, isFalse);
    });

    test('refresh failure clears tokens and calls onAuthFailure', () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'OLD', refresh: 'REFRESH');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      final adapter = DioAdapter(dio: dio);
      var authFailed = false;
      dio.interceptors.add(RefreshInterceptor(
        dio: dio,
        store: store,
        onAuthFailure: () async => authFailed = true,
      ));

      adapter
        ..onGet('/my-team', (s) => s.reply(401, {'error': 'unauthorized'}))
        ..onPost('/auth/refresh',
            (s) => s.reply(401, {'error': 'invalid_refresh'}));

      await expectLater(dio.get('/my-team'), throwsA(isA<DioException>()));
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
      expect(authFailed, isTrue);
    });

    test('does not loop when the retried request is also 401', () async {
      final store = InMemoryTokenStore();
      await store.save(access: 'OLD', refresh: 'REFRESH');
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
      final adapter = DioAdapter(dio: dio);
      var authFailed = false;
      dio.interceptors.add(RefreshInterceptor(
        dio: dio,
        store: store,
        onAuthFailure: () async => authFailed = true,
      ));

      var refreshCalls = 0;
      // Every /my-team call is 401, regardless of bearer token.
      adapter
        ..onGet('/my-team', (s) => s.reply(401, {'error': 'unauthorized'}))
        ..onPost(
          '/auth/refresh',
          (s) => s.replyCallback(200, (options) {
            refreshCalls++;
            return {'access_token': 'NEW', 'refresh_token': 'R2'};
          }),
          data: {'refresh_token': 'REFRESH'},
        );

      await expectLater(dio.get('/my-team'), throwsA(isA<DioException>()));
      // Refresh succeeded and rotated tokens, but the retry itself still
      // failed with 401 — the guard must prevent a second refresh attempt,
      // and this is not treated as an auth failure (tokens are still valid).
      expect(refreshCalls, 1);
      expect(await store.readAccess(), 'NEW');
      expect(authFailed, isFalse);
    });
  });
}
