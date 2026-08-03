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
      return const AppException('Сервер не отвечает');
    case DioExceptionType.connectionError:
      return const AppException('Нет связи с сервером');
    case DioExceptionType.badResponse:
      final data = e.response?.data;
      final code = e.response?.statusCode;
      // Текст ошибки с бэкенда уже на русском — показываем его как есть.
      if (data is Map && data['error'] is String) {
        return AppException(data['error'] as String, statusCode: code);
      }
      return AppException(_statusMessage(code), statusCode: code);
    default:
      return const AppException('Ошибка сети');
  }
}

String _statusMessage(int? code) {
  switch (code) {
    case 401:
    case 403:
      return 'Нужно войти заново';
    case 409:
      return 'Сейчас не ваш ход';
    case 404:
      return 'Не найдено';
    case 500:
      return 'Ошибка на сервере';
    default:
      return 'Запрос не прошёл${code == null ? '' : ' ($code)'}';
  }
}
