import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_requests.freezed.dart';
part 'auth_requests.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({required String login, required String password}) = _LoginRequest;
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String username,
    required String password,
  }) = _RegisterRequest;
  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
}
