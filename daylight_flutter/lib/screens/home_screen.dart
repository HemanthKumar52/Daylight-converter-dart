import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timezone_store.dart';
import '../models/timezone_item.dart';
import '../utils/app_settings.dart';
import '../utils/theme_colors.dart';
import '../widgets/timezone_card.dart';
import '../widgets/time_slider.dart';
import 'add_timezone_screen.dart';
import 'edit_list_screen.dart';
import 'settings_screen.dart';
import '../widgets/glass_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double hourOffset = 0;

  TimeZoneItem? get homeTimeZone {
    final store = Provider.of<TimeZoneStore>(context, listen: false);
    try {
      return store.timeZones.firstWhere((element) => element.isHome);
    } catch (e) {
      if (store.timeZones.isNotEmpty) return store.timeZones.first;
      return null;
    }
  }

  List<TimeZoneItem> get sortedTimeZones {
    final store = Provider.of<TimeZoneStore>(context);
    final home = homeTimeZone;
    if (home == null) return store.timeZones;

    final homeOffset = home.secondsFromGMT;
    
    final sorted = List<TimeZoneItem>.from(store.timeZones);
    sorted.sort((a, b) {
       final offset1 = a.secondsFromGMT - homeOffset;
       final offset2 = b.secondsFromGMT - homeOffset;
       return offset1.compareTo(offset2);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    // Determine brightness based on settings
    final brightness = settings.themeMode == ThemeMode.dark ? Brightness.dark : 
                       (settings.themeMode == ThemeMode.light ? Brightness.light : MediaQuery.of(context).platformBrightness);
                       
    final theme = ThemeColors(brightness);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
             children: [
               // Header
               _buildHeader(theme, context),
               
               // List
               Expanded(
                 child: ListView.builder(
                   padding: EdgeInsets.fromLTRB(16, 16, 16, 220 + MediaQuery.of(context).padding.bottom), // Bottom padding for slider + safe area
                   itemCount: sortedTimeZones.length,
                   itemBuilder: (context, index) {
                     final tzItem = sortedTimeZones[index];
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 2),
                       child: TimeZoneCard(
                         timeZone: tzItem,
                         hourOffset: hourOffset,
                         homeTimeZone: homeTimeZone,
                         showCenterLine: settings.showCenterLine,
                         theme: theme,
                       ),
                     );
                   },
                 ),
               ),
             ],
          ),
          
          // Slider Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TimeSlider(
              hourOffset: hourOffset,
              onHourOffsetChanged: (val) {
                setState(() {
                  hourOffset = val;
                });
              },
              homeTimeZone: homeTimeZone,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors theme, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Text(
              "Daylight",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: theme.headerText,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: theme.headerText, size: 28),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withOpacity(0.5),
                  builder: (context) => GlassBottomSheet(
                    title: "Add Timezone",
                    actionText: "Done",
                    onAction: () => Navigator.pop(context),
                    child: const AddTimeZoneScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
             GestureDetector(
               onTap: () {
                 showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   backgroundColor: Colors.transparent,
                   barrierColor: Colors.black.withOpacity(0.5),
                   builder: (context) => GlassBottomSheet(
                     title: "Settings",
                     actionText: "Done",
                     onAction: () => Navigator.pop(context),
                     child: const SettingsScreen(),
                   ),
                 );
               },
               child: Container(
                 width: 36, height: 36,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.transparent,
                   border: Border.all(color: theme.headerText.withOpacity(0.3), width: 2),
                 ),
                 child: Icon(Icons.settings, color: theme.headerText, size: 20),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
