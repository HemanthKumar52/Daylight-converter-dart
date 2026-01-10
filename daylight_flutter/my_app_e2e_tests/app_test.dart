import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:daylight_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verify app startup and navigation', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify Splash Screen appears initially (or if it's already gone, we check Home)
    // The splash screen lasts 5 seconds (from previous context). 
    // pumpAndSettle might wait for animations, but 5 seconds is a Timer. 
    // We might need to handle that.
    
    // Let's verify we are on Home Screen or wait for it.
    // If pumpAndSettle waits for all timers, it might wait the 5 seconds.
    // Let's check for 'Daylight' text.
    
    // Check if we are still on Splash (unlikely with pumpAndSettle if it waits indefinitely? No, Timers are handled)
    // Actually, simple Timers don't always block pumpAndSettle.
    // Let's just try to find the "Daylight" header.
    
    final daylightHeaderFinder = find.text('Daylight');
    
    // If not found immediately, pump for a bit.
    if (!dryRun(daylightHeaderFinder, tester)) {
       await tester.pump(const Duration(seconds: 6)); 
       await tester.pumpAndSettle();
    }
    
    expect(find.text('Daylight'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Tap Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings Sheet
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Close Settings
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Tap Add
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify Add Sheet
    expect(find.text('Add Timezone'), findsOneWidget);
    
    // Close Add
     await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });
}

bool dryRun(Finder finder, WidgetTester tester) {
  try {
    finder.evaluate().first;
    return true;
  } catch (e) {
    return false;
  }
}
