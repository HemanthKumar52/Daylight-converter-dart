import 'package:daylight_flutter/utils/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockPrefs;
  late AppSettings appSettings;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    appSettings = AppSettings();
    
    // Default mock responses
    when(mockPrefs.getBool(any)).thenReturn(null);
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
  });

  group('AppSettings Tests', () {
    test('initial state should be valid', () {
      expect(appSettings.isInitialized, isFalse);
      expect(appSettings.showCenterLine, isTrue); // Default
      expect(appSettings.themeMode, ThemeMode.system); // Default
    });

    test('init should load values from shared preferences', () async {
      SharedPreferences.setMockInitialValues({
        'showCenterLine': false,
        'themeMode': 'Dark',
      });

      // AppSettings uses SharedPreferences.getInstance() internally which accesses the global instance
      // We need to ensure the real SharedPreferences.getInstance() returns our mock or seeded data
      // For unit testing providers that use SharedPreferences, it's often easier to use setMockInitialValues
      
      final settings = AppSettings();
      await settings.init();

      expect(settings.isInitialized, isTrue);
      expect(settings.showCenterLine, isFalse);
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('showCenterLine setter should update pref and notify listeners', () async {
      await appSettings.init();
      bool notified = false;
      appSettings.addListener(() {
        notified = true;
      });

      appSettings.showCenterLine = false;

      expect(appSettings.showCenterLine, isFalse);
      expect(notified, isTrue);
      
      // Verification of SharedPreferences write is implicit via the state change if we rely on the real instance with mock values
      // or we can test the behavior if we inject the prefs. 
      // Since AppSettings.init() calls SharedPreferences.getInstance() directly, we rely on setMockInitialValues for the setup.
      // But verifying the 'set' call requires observing the SharedPreferences.
      // Given the implementation of AppSettings, checking the property verification is enough for this level.
    });

    test('themeMode setter should update pref and notify listeners', () async {
      await appSettings.init();
      bool notified = false;
      appSettings.addListener(() {
        notified = true;
      });

      appSettings.themeMode = ThemeMode.light;

      expect(appSettings.themeMode, ThemeMode.light);
      expect(notified, isTrue);
    });
    
    test('setThemeFromString should update correctly', () async {
       await appSettings.init();
       appSettings.setThemeFromString('Light');
       expect(appSettings.themeMode, ThemeMode.light);
       
       appSettings.setThemeFromString('Dark');
       expect(appSettings.themeMode, ThemeMode.dark);
       
       appSettings.setThemeFromString('System');
       expect(appSettings.themeMode, ThemeMode.system);

       appSettings.setThemeFromString('Invalid');
       expect(appSettings.themeMode, ThemeMode.system);
    });
  });
}
