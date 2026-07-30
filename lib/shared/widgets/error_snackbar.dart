import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/error/app_exception.dart';

String errorMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is DioException) return mapDioError(error).message;
  return error.toString();
}

void showErrorSnackbar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(errorMessage(error))));
}
