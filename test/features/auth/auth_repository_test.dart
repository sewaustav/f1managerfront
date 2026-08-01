import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/auth/data/auth_repository.dart';
import 'package:f1manager/features/auth/model/auth_requests.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late AuthRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = AuthRepository(dio);
  });

  test('login posts credentials and parses TokenPair', () async {
    adapter.onPost('/auth/login',
        (s) => s.reply(200, {'access_token': 'a', 'refresh_token': 'r'}),
        data: {'login': 'joe', 'password': 'secretpw'});
    final pair = await repo.login(const LoginRequest(login: 'joe', password: 'secretpw'));
    expect(pair.accessToken, 'a');
    expect(pair.refreshToken, 'r');
  });

  test('register posts email/username/password and parses TokenPair', () async {
    adapter.onPost('/auth/register',
        (s) => s.reply(200, {'access_token': 'a2', 'refresh_token': 'r2'}),
        data: {'email': 'j@e.co', 'username': 'joe', 'password': 'secretpw'});
    final pair = await repo.register(
        const RegisterRequest(email: 'j@e.co', username: 'joe', password: 'secretpw'));
    expect(pair.accessToken, 'a2');
  });
}
