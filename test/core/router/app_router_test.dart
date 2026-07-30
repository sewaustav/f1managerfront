import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/router/app_router.dart';

void main() {
  test('unauthenticated always routed to /auth', () {
    expect(
      redirectLogic(authed: false, hasGroup: false, phase: null, location: '/season'),
      '/auth',
    );
  });

  test('authed without group → /lobby', () {
    expect(
      redirectLogic(authed: true, hasGroup: false, phase: null, location: '/auth'),
      '/lobby',
    );
  });

  test('authed with group routes by phase', () {
    expect(routeForPhase(SeasonPhase.draft), '/draft');
    expect(routeForPhase(SeasonPhase.tokenSetup), '/token-setup');
    expect(routeForPhase(SeasonPhase.racing), '/season');
    expect(routeForPhase(SeasonPhase.interSeason), '/inter-season');
  });

  test('authed on matching phase location → no redirect', () {
    expect(
      redirectLogic(authed: true, hasGroup: true, phase: SeasonPhase.racing, location: '/season'),
      isNull,
    );
  });
}
