import 'package:daylight_flutter/models/available_timezones.dart';
import 'package:daylight_flutter/models/timezone_store.dart';
import 'package:daylight_flutter/screens/add_timezone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'add_timezone_screen_test.mocks.dart';

@GenerateMocks([TimeZoneStore])
void main() {
  late MockTimeZoneStore mockStore;

  setUp(() {
    mockStore = MockTimeZoneStore();
    when(mockStore.timeZones).thenReturn([]);
    when(mockStore.addListener(any)).thenReturn(null);
    when(mockStore.removeListener(any)).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimeZoneStore>.value(value: mockStore),
      ],
      child: const MaterialApp(
        home: Scaffold(body: AddTimeZoneScreen()),
      ),
    );
  }

  testWidgets('AddTimeZoneScreen renders list of cities', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Expect at least some cities to be present in the list
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Algiers'), findsOneWidget);
  });

  testWidgets('Search filters the list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'New York');
    await tester.pumpAndSettle();

    expect(find.text('New York'), findsWidgets); // City and Title might match
    expect(find.text('Cairo'), findsNothing);
  });

  testWidgets('Tapping a city adds it', (WidgetTester tester) async {
    when(mockStore.timeZones).thenReturn([]);
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Cairo'));
    
    verify(mockStore.addTimeZone(any)).called(1);
  });
}
