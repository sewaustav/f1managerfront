import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'AppException($statusCode): $message';
}

AppException mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const AppException('Request timeout');
    case DioExceptionType.connectionError:
      return const AppException('Cannot reach server');
    case DioExceptionType.badResponse:
      final data = e.response?.data;
      final code = e.response?.statusCode;
      if (data is Map && data['error'] is String) {
        return AppException(data['error'] as String, statusCode: code);
      }
      return AppException('Request failed ($code)', statusCode: code);
    default:
      return AppException(e.message ?? 'Network error');
  }
}
