
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daylight_flutter/models/timezone_store.dart';
import 'package:daylight_flutter/models/timezone_item.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUp(() {
    tz.initializeTimeZones();
  });

  group('TimeZoneStore Tests', () {
    test('init loads default timezones if prefs empty', () async {
      SharedPreferences.setMockInitialValues({}); // Empty prefs
      
      final store = TimeZoneStore();
      await store.init();
      
      expect(store.timeZones.length, 3);
      expect(store.timeZones[0].identifier, 'Asia/Kolkata');
      expect(store.timeZones[0].isHome, true);
    });

    test('addTimeZone adds item and saves', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TimeZoneStore();
      await store.init();
      final initialCount = store.timeZones.length;

      final newItem = TimeZoneItem(identifier: 'Europe/London', cityName: 'London', abbreviation: 'BST');
      store.addTimeZone(newItem);

      expect(store.timeZones.length, initialCount + 1);
      expect(store.timeZones.last.cityName, 'London');
    });

    test('removeTimeZone removes item and reassigns home if needed', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TimeZoneStore();
      await store.init();
      
      // Default: Kolkata (Home), LA, Dubai
      final kolkata = store.timeZones[0];
      
      store.removeTimeZone(kolkata);
      
      expect(store.timeZones.length, 2);
      expect(store.timeZones.any((t) => t.cityName == 'Chennai'), false);
      // New home should be assigned to first item (LA)
      expect(store.timeZones[0].cityName, 'San Francisco');
      expect(store.timeZones[0].isHome, true);
    });
    
     test('setAsHome updates isHome flag', () async {
      SharedPreferences.setMockInitialValues({});
      final store = TimeZoneStore();
      await store.init();
      
      final dubai = store.timeZones[2]; // Dubai
      expect(dubai.isHome, false);

      store.setAsHome(dubai);

      expect(store.timeZones[0].isHome, false); // Kolkata
      expect(store.timeZones[2].isHome, true); // Dubai
    });
  });
}
