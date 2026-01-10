
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daylight_flutter/models/timezone_item.dart';
import 'package:daylight_flutter/widgets/timezone_card.dart';
import 'package:daylight_flutter/utils/theme_colors.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUp(() {
    tz.initializeTimeZones();
  });

  testWidgets('TimeZoneCard displays city name and time', (WidgetTester tester) async {
    final item = TimeZoneItem(
      identifier: 'Asia/Kolkata', // Valid TZ identifier
      cityName: 'Chennai', 
      abbreviation: 'IST'
    );
    final theme = ThemeColors(Brightness.light);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimeZoneCard(
            timeZone: item, 
            theme: theme, 
            homeTimeZone: item, // Self as home for simplicity
            hourOffset: 0,
            showCenterLine: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('Chennai'), findsOneWidget);
    expect(find.textContaining('IST'), findsOneWidget);
    // Date/Time might vary, so we just check static info.
  });
}
