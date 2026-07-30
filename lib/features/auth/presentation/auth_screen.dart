import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _regPassword = TextEditingController();

  @override
  void dispose() {
    _tabs.dispose();
    _login.dispose();
    _password.dispose();
    _email.dispose();
    _username.dispose();
    _regPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        showErrorSnackbar(context, next.error!);
      }
    });
    final loading = ref.watch(authControllerProvider).isLoading;
    final ctrl = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 Manager'),
        bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Login'), Tab(text: 'Register')]),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _LoginForm(login: _login, password: _password, loading: loading, onSubmit: () {
            ctrl.login(_login.text.trim(), _password.text);
          }),
          _RegisterForm(
            email: _email, username: _username, password: _regPassword, loading: loading,
            onSubmit: () => ctrl.register(_email.text.trim(), _username.text.trim(), _regPassword.text),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.login, required this.password, required this.loading, required this.onSubmit});
  final TextEditingController login;
  final TextEditingController password;
  final bool loading;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(key: const Key('login_field'), controller: login,
              decoration: const InputDecoration(labelText: 'Email or username')),
          const SizedBox(height: 12),
          TextField(key: const Key('password_field'), controller: password, obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('sign_in_button'),
            onPressed: loading ? null : onSubmit,
            child: loading ? const _Spinner() : const Text('Sign in'),
          ),
        ],
      );
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({required this.email, required this.username, required this.password, required this.loading, required this.onSubmit});
  final TextEditingController email;
  final TextEditingController username;
  final TextEditingController password;
  final bool loading;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(key: const Key('email_field'), controller: email,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(key: const Key('username_field'), controller: username,
              decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(key: const Key('reg_password_field'), controller: password, obscureText: true,
              decoration: const InputDecoration(labelText: 'Password (min 8)')),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('register_button'),
            onPressed: loading ? null : onSubmit,
            child: loading ? const _Spinner() : const Text('Register'),
          ),
        ],
      );
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2));
}
