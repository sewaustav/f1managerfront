import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/router/app_router.dart';

void main() {
  test('authed+group phase=racing redirects to /season from a play route', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: SeasonPhase.racing,
          location: '/draft', onAlwaysAvailableTab: false),
      '/season',
    );
  });

  test('does NOT redirect when on an always-available tab', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: SeasonPhase.racing,
          location: '/standings', onAlwaysAvailableTab: true),
      isNull,
    );
  });

  test('not authed still forced to /auth even on a tab', () {
    expect(
      redirectLogic(authed: false, hasGroup: false, phase: null,
          location: '/standings', onAlwaysAvailableTab: true),
      '/auth',
    );
  });
}
