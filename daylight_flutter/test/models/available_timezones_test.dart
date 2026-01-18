import 'package:daylight_flutter/models/available_timezones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvailableTimeZone Tests', () {
    test('all list should not be empty', () {
      expect(AvailableTimeZone.all, isNotEmpty);
    });

    test('should contain major cities', () {
      final cities = AvailableTimeZone.all.map((e) => e.cityName).toList();
      expect(cities, contains('Cairo'));
      expect(cities, contains('New York'));
      expect(cities, contains('London'));
      expect(cities, contains('Tokyo'));
      expect(cities, contains('Sydney'));
    });

    test('city names should be unique', () {
      final cities = AvailableTimeZone.all.map((e) => e.cityName).toList();
      final uniqueCities = cities.toSet();
      expect(cities.length, equals(uniqueCities.length));
    });

    test('instances should have valid ids', () {
      final tz = AvailableTimeZone(
        identifier: 'Test/Zone',
        cityName: 'Test City',
        abbreviation: 'TST',
      );
      expect(tz.id, isNotNull);
      expect(tz.id, isNotEmpty);
    });
  });
}
