import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/timezone_item.dart';
import 'widget_extension/daylight_widget.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const WidgetPreviewApp());
}

class WidgetPreviewApp extends StatelessWidget {
  const WidgetPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final home = TimeZoneItem(
      identifier: 'Asia/Kolkata', 
      cityName: 'Chennai', 
      abbreviation: 'IST', 
      isHome: true
    );
    
    final timeZones = [
      home,
      TimeZoneItem(identifier: 'America/Los_Angeles', cityName: 'San Francisco', abbreviation: 'PST', isHome: false),
      TimeZoneItem(identifier: 'Europe/London', cityName: 'London', abbreviation: 'GMT', isHome: false),
      TimeZoneItem(identifier: 'Asia/Tokyo', cityName: 'Tokyo', abbreviation: 'JST', isHome: false),
      TimeZoneItem(identifier: 'Australia/Sydney', cityName: 'Sydney', abbreviation: 'AEST', isHome: false),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("IOS Widget Preview"),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Small Widget", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                IOSDaylightWidget(
                  size: WidgetSize.small,
                  timeZones: timeZones,
                  homeTimeZone: home,
                ),
                
                const SizedBox(height: 40),
                const Text("Medium Widget", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                IOSDaylightWidget(
                  size: WidgetSize.medium,
                  timeZones: timeZones,
                  homeTimeZone: home,
                ),

                const SizedBox(height: 40),
                const Text("Large Widget", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                IOSDaylightWidget(
                  size: WidgetSize.large,
                  timeZones: timeZones,
                  homeTimeZone: home,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
