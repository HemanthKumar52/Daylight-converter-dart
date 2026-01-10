
import 'package:flutter_test/flutter_test.dart';
import 'package:daylight_flutter/models/timezone_item.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUp(() {
    tz.initializeTimeZones();
  });

  group('TimeZoneItem Tests', () {
    test('Initialization works correctly', () {
      final item = TimeZoneItem(
        identifier: 'Asia/Kolkata',
        cityName: 'Chennai',
        abbreviation: 'IST',
      );
      
      expect(item.identifier, 'Asia/Kolkata');
      expect(item.cityName, 'Chennai');
      expect(item.abbreviation, 'IST');
      expect(item.isHome, false);
      expect(item.id.isNotEmpty, true);
    });

    test('Helper method secondsFromGMT returns valid offset', () {
       // Note: This relies on the machine's timezone db or the one initialized.
       // Asia/Kolkata is UTC+5:30 = 19800 seconds
       final item = TimeZoneItem(identifier: 'Asia/Kolkata', cityName: 'Kolkata', abbreviation: 'IST');
       expect(item.secondsFromGMT, 19800);
    });

    test('Serialization (toJson/fromJson) works', () {
       final item = TimeZoneItem(
        identifier: 'America/New_York',
        cityName: 'NYC',
        abbreviation: 'EST',
        isHome: true
       );

       final json = item.toJson();
       final newItem = TimeZoneItem.fromJson(json);

       expect(newItem.id, item.id);
       expect(newItem.identifier, item.identifier);
       expect(newItem.isHome, true);
    });
  });
}
