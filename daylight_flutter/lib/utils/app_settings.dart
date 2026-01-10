import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  // Mocking UserDefaults using memory for now, ideally use shared_preferences
  // But for the scope of UI conversion, we can start with in-memory or setup shared_preferences in main
  
  bool _showCenterLine = true;
  ThemeMode _themeMode = ThemeMode.dark; 

  bool get showCenterLine => _showCenterLine;
  ThemeMode get themeMode => _themeMode;

  set showCenterLine(bool value) {
    _showCenterLine = value;
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  // Helper to convert from String to ThemeMode like in Swift enum
  void setThemeFromString(String value) {
    switch (value) {
      case 'Light':
        themeMode = ThemeMode.light;
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        themeMode = ThemeMode.system;
        break;
    }
  }
}
