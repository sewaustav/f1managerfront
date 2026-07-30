import 'package:dio/dio.dart';
import '../storage/token_store.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

Dio buildDio({
  required ApiConfig config,
  required TokenStore tokenStore,
  required Future<void> Function() onAuthFailure,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: config.restBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));
  dio.interceptors.addAll([
    AuthInterceptor(tokenStore),
    RefreshInterceptor(
        dio: dio, store: tokenStore, onAuthFailure: onAuthFailure),
  ]);
  return dio;
}
