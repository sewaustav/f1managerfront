import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/token_pair.dart';
import '../model/auth_requests.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<TokenPair> login(LoginRequest r) async {
    final res = await _dio.post('/auth/login', data: r.toJson());
    return TokenPair.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TokenPair> register(RegisterRequest r) async {
    final res = await _dio.post('/auth/register', data: r.toJson());
    return TokenPair.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() => _dio.post('/auth/logout');
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));
