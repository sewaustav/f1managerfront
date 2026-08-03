import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/error/app_exception.dart';

void main() {
  test('maps backend {error: ...} body', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 400,
        data: {'error': 'group not found'},
      ),
      type: DioExceptionType.badResponse,
    );
    final mapped = mapDioError(e);
    expect(mapped.statusCode, 400);
    expect(mapped.message, 'group not found');
  });

  test('maps timeout to friendly message', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(mapDioError(e).message, 'Сервер не отвечает');
  });
}
