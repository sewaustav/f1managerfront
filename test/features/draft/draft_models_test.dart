import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/features/draft/model/engine.dart';
import 'package:f1manager/features/draft/model/budget.dart';

void main() {
  test('Pilot maps PascalCase keys', () {
    final p = Pilot.fromJson({
      'ID': 5, 'Name': 'Max', 'Garage': null, 'Team': 3, 'Rating': 98,
      'QualifyingRating': 95, 'Price': 40, 'Sponsors': 10,
    });
    expect(p.id, 5);
    expect(p.name, 'Max');
    expect(p.team, 3);
    expect(p.rating, 98);
    expect(p.price, 40);
    expect(p.sponsors, 10);
  });

  test('Team maps PascalCase and IsManufacturer int', () {
    final t = Team.fromJson({
      'ID': 1, 'Name': 'Reds', 'ICE': 0, 'Budget': 120, 'IsManufacturer': 0, 'Tokens': 35,
    });
    expect(t.id, 1);
    expect(t.name, 'Reds');
    expect(t.ice, 0);
    expect(t.budget, 120);
    expect(t.isManufacturer, 0);
  });

  test('Principal + Engine + Budget map correctly', () {
    expect(Principal.fromJson({'ID': 2, 'Name': 'TP', 'Price': 15, 'TeamID': 1, 'Level': 20}).price, 15);
    expect(Engine.fromJson({'ID': 1, 'Engine': 2, 'Price': 8, 'BaseLevel': 5}).engine, 2);
    expect(Budget.fromJson({'budget': 110, 'tokens': 35}).budget, 110);
  });
}
