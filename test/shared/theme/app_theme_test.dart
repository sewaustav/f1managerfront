import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/shared/theme/app_theme.dart';

void main() {
  test('themes expose F1 red seed and correct brightness', () {
    expect(AppTheme.f1Red, const Color(0xFFE10600));
    expect(AppTheme.dark().brightness, Brightness.dark);
    expect(AppTheme.light().brightness, Brightness.light);
    expect(AppTheme.dark().useMaterial3, isTrue);
  });
}
