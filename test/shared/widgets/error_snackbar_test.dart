import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/error/app_exception.dart';
import 'package:f1manager/shared/widgets/error_snackbar.dart';

void main() {
  test('errorMessage prefers AppException.message', () {
    expect(errorMessage(const AppException('group not found')), 'group not found');
  });

  test('errorMessage maps a DioException via mapDioError', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );
    expect(errorMessage(e), 'Cannot reach server');
  });

  test('errorMessage falls back to toString for unknown', () {
    expect(errorMessage('boom'), 'boom');
  });
}
