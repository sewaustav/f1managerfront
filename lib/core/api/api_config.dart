class ApiConfig {
  const ApiConfig({required this.host});

  factory ApiConfig.fromEnv() => const ApiConfig(
        host: String.fromEnvironment('API_HOST', defaultValue: 'localhost:8080'),
      );

  final String host;

  bool get isSecure {
    final h = host.split(':').first;
    return !(h == 'localhost' || h == '127.0.0.1' || h == '10.0.2.2');
  }

  String get restBaseUrl => '${isSecure ? 'https' : 'http'}://$host/api/v1';
  String get wsUrl => '${isSecure ? 'wss' : 'ws'}://$host/api/v1/ws';
}
