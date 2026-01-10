import 'package:uuid/uuid.dart';

class AvailableTimeZone {
  final String id;
  final String identifier;
  final String cityName;
  final String abbreviation;

  AvailableTimeZone({
    required this.identifier,
    required this.cityName,
    required this.abbreviation,
  }) : id = Uuid().v4();

  static List<AvailableTimeZone> get all => [
        AvailableTimeZone(identifier: "America/New_York", cityName: "New York", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Miami", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/New_York", cityName: "Boston", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Chicago", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Chicago", cityName: "Houston", abbreviation: "CST"),
        AvailableTimeZone(identifier: "America/Denver", cityName: "Denver", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Phoenix", cityName: "Phoenix", abbreviation: "MST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Los Angeles", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "San Francisco", abbreviation: "PST"),
        AvailableTimeZone(identifier: "America/Los_Angeles", cityName: "Seattle", abbreviation: "PST"),
        AvailableTimeZone(identifier: "Pacific/Honolulu", cityName: "Honolulu", abbreviation: "HST"),
        AvailableTimeZone(identifier: "America/Toronto", cityName: "Toronto", abbreviation: "EST"),
        AvailableTimeZone(identifier: "America/Vancouver", cityName: "Vancouver", abbreviation: "PST"),
        AvailableTimeZone(identifier: "Europe/London", cityName: "London", abbreviation: "GMT"),
        AvailableTimeZone(identifier: "Europe/Paris", cityName: "Paris", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Berlin", cityName: "Berlin", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Zurich", cityName: "Zürich", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Madrid", cityName: "Madrid", abbreviation: "CET"),
        AvailableTimeZone(identifier: "Europe/Moscow", cityName: "Moscow", abbreviation: "MSK"),
        AvailableTimeZone(identifier: "Europe/Istanbul", cityName: "Istanbul", abbreviation: "TRT"),
        AvailableTimeZone(identifier: "Asia/Dubai", cityName: "Dubai", abbreviation: "GST"),
        AvailableTimeZone(identifier: "Asia/Riyadh", cityName: "Riyadh", abbreviation: "AST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Mumbai", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Delhi", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Bangalore", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Kolkata", cityName: "Chennai", abbreviation: "IST"),
        AvailableTimeZone(identifier: "Asia/Singapore", cityName: "Singapore", abbreviation: "SGT"),
        AvailableTimeZone(identifier: "Asia/Bangkok", cityName: "Bangkok", abbreviation: "ICT"),
        AvailableTimeZone(identifier: "Asia/Tokyo", cityName: "Tokyo", abbreviation: "JST"),
        AvailableTimeZone(identifier: "Asia/Seoul", cityName: "Seoul", abbreviation: "KST"),
        AvailableTimeZone(identifier: "Asia/Shanghai", cityName: "Shanghai", abbreviation: "CST"),
        AvailableTimeZone(identifier: "Asia/Hong_Kong", cityName: "Hong Kong", abbreviation: "HKT"),
        AvailableTimeZone(identifier: "Australia/Sydney", cityName: "Sydney", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Australia/Melbourne", cityName: "Melbourne", abbreviation: "AEST"),
        AvailableTimeZone(identifier: "Pacific/Auckland", cityName: "Auckland", abbreviation: "NZST"),
        AvailableTimeZone(identifier: "UTC", cityName: "UTC", abbreviation: "UTC"),
  ];
}
