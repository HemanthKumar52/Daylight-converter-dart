import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timezone_item.dart';

class TimeZoneStore extends ChangeNotifier {
  List<TimeZoneItem> timeZones = [];
  final String _saveKey = "SavedTimeZones";

  TimeZoneStore() {
    _loadTimeZones();
  }
  
  Future<void> init() async {
    await _loadTimeZones();
    if (timeZones.isEmpty) {
      _addDefaultTimeZones();
    }
    notifyListeners();
  }

  void saveAfterReorder() {
     _saveTimeZones();
     notifyListeners();
  }

  void _addDefaultTimeZones() {
    final defaults = [
      TimeZoneItem(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST", isHome: true),
      TimeZoneItem(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST", isHome: false),
      TimeZoneItem(identifier: "Asia/Dubai", cityName: "Dubai", abbreviation: "GST", isHome: false)
    ];
    timeZones = defaults;
    _saveTimeZones();
  }

  void addTimeZone(TimeZoneItem item) {
    timeZones.add(item);
    _saveTimeZones();
    notifyListeners();
  }

  void removeTimeZone(TimeZoneItem item) {
    timeZones.removeWhere((t) => t.id == item.id);
    if (!timeZones.any((t) => t.isHome) && timeZones.isNotEmpty) {
      timeZones[0].isHome = true;
    }
    _saveTimeZones();
    notifyListeners();
  }

  void setAsHome(TimeZoneItem item) {
    for (var tz in timeZones) {
      tz.isHome = (tz.id == item.id);
    }
    _saveTimeZones();
    notifyListeners();
  }

  Future<void> _saveTimeZones() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(timeZones.map((e) => e.toJson()).toList());
    await prefs.setString(_saveKey, encoded);
  }

  Future<void> _loadTimeZones() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_saveKey)) {
      final String? data = prefs.getString(_saveKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        timeZones = decoded.map((e) => TimeZoneItem.fromJson(e)).toList();
      }
    }
  }
}
