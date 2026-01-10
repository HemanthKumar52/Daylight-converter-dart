import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeZoneItem {
  final String id;
  final String identifier;
  final String cityName;
  final String abbreviation;
  bool isHome;

  TimeZoneItem({
    String? id,
    required this.identifier,
    required this.cityName,
    required this.abbreviation,
    this.isHome = false,
  }) : id = id ?? Uuid().v4();

  factory TimeZoneItem.fromJson(Map<String, dynamic> json) {
    return TimeZoneItem(
      id: json['id'],
      identifier: json['identifier'],
      cityName: json['cityName'],
      abbreviation: json['abbreviation'],
      isHome: json['isHome'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'cityName': cityName,
      'abbreviation': abbreviation,
      'isHome': isHome,
    };
  }
  
  tz.Location get location {
    try {
      return tz.getLocation(identifier);
    } catch (e) {
      return tz.local; // Fallback
    }
  }

  // Logic matched from Swift
  int currentHour({double offsetBy = 0}) {
    final date = DateTime.now().toUtc().add(Duration(milliseconds: (offsetBy * 3600 * 1000).round()));
    final zonedDate = tz.TZDateTime.from(date, location);
    return zonedDate.hour;
  }

  int currentMinute({double offsetBy = 0}) {
    final date = DateTime.now().toUtc().add(Duration(milliseconds: (offsetBy * 3600 * 1000).round()));
    final zonedDate = tz.TZDateTime.from(date, location);
    return zonedDate.minute;
  }

  String formattedTime({double offsetBy = 0}) {
    final date = DateTime.now().toUtc().add(Duration(milliseconds: (offsetBy * 3600 * 1000).round()));
    final zonedDate = tz.TZDateTime.from(date, location);
    return DateFormat('h:mma').format(zonedDate).toUpperCase();
  }

  bool isDaylight({double offsetBy = 0}) {
    final hour = currentHour(offsetBy: offsetBy);
    return hour >= 6 && hour < 18;
  }
  
  // Helper for sorting
  int get secondsFromGMT {
    final now = tz.TZDateTime.now(location);
    return now.timeZoneOffset.inSeconds;
  }
}
