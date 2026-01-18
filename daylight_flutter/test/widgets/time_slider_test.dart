import 'package:daylight_flutter/models/timezone_item.dart';
import 'package:daylight_flutter/utils/app_settings.dart';
import 'package:daylight_flutter/utils/theme_colors.dart';
import 'package:daylight_flutter/widgets/time_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'time_slider_test.mocks.dart';

@GenerateMocks([AppSettings])
void main() {
  late MockAppSettings mockSettings;

  setUp(() {
    tz.initializeTimeZones();
    mockSettings = MockAppSettings();
    when(mockSettings.addListener(any)).thenReturn(null);
    when(mockSettings.removeListener(any)).thenReturn(null);
  });

  Widget createWidgetUnderTest({required double hourOffset, required ValueChanged<double> onChanged}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: mockSettings),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TimeSlider(
            hourOffset: hourOffset,
            onHourOffsetChanged: onChanged,
            homeTimeZone: TimeZoneItem(identifier: 'UTC', cityName: 'UTC', abbreviation: 'UTC', isHome: true),
            theme: ThemeColors(Brightness.light),
          ),
        ),
      ),
    );
  }

  testWidgets('TimeSlider renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(hourOffset: 0, onChanged: (_) {}));

    expect(find.text('Now'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('TimeSlider displays offset time', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(hourOffset: 2.0, onChanged: (_) {}));
    
    // Format logic: DateFormat('h:mm a')
    // 2 hours from now might depend on current time. 
    // The slider code calculates "Now" vs formatted time.
    // If offset is > 0.01, it shows time.
    
    expect(find.text('Now'), findsNothing);
    // Finding specific time string is hard without injecting "Now", so checking it DOES NOT say "Now" is a good proxy for "it's showing time".
  });
}
