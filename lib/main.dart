import 'package:flutter/material.dart';

void main() => runApp(const F1App());

class F1App extends StatelessWidget {
  const F1App({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: Center(child: Text('F1 Manager'))));
}
