import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/router/app_router.dart';

void main() {
  test('authed with group and null phase stays put (no phase redirect yet)', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: null, location: '/lobby'),
      isNull,
    );
  });

  test('authed without group is sent to lobby from a game route', () {
    expect(
      redirectLogic(authed: true, hasGroup: false, phase: null, location: '/draft'),
      '/lobby',
    );
  });
}
