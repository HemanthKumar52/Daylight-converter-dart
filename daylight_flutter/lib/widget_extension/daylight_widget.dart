import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timezone_item.dart';
import 'package:timezone/timezone.dart' as tz;

// MARK: - Enums & Models

enum WidgetSize { small, medium, large }

// MARK: - Main Widget Container

class IOSDaylightWidget extends StatelessWidget {
  final WidgetSize size;
  final List<TimeZoneItem> timeZones;
  final TimeZoneItem? homeTimeZone; // Only needed for relative offsets
  final bool isDark;

  const IOSDaylightWidget({
    super.key,
    required this.size,
    required this.timeZones,
    this.homeTimeZone,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensions based on standard iOS widget sizes (roughly)
    double width;
    double height;

    switch (size) {
      case WidgetSize.small:
        width = 155; // 169 max, usually ~155 safe area
        height = 155;
        break;
      case WidgetSize.medium:
        width = 329;
        height = 155;
        break;
      case WidgetSize.large:
        width = 329;
        height = 345;
        break;
    }

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(size == WidgetSize.small ? 18 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [Colors.black, const Color(0xFF1C1C1D)] 
            : [Colors.white, const Color(0xFFF2F2F7)],
        ),
        borderRadius: BorderRadius.circular(22), // iOS continuous curve approximation
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (size) {
      case WidgetSize.small:
        return _buildSmall();
      case WidgetSize.medium:
        return _buildMediumLarge(limit: 3);
      case WidgetSize.large:
        return _buildMediumLarge(limit: 6);
    }
  }

  // MARK: - Small Widget Logic

  Widget _buildSmall() {
    // Small widget shows the first timezone
    final displayTZ = timeZones.isNotEmpty ? timeZones.first : HomeTimeZonePlaceholder();
    final textColor = isDark ? Colors.white : Colors.black;

    String? offsetText;
    bool isHome = false;

    if (homeTimeZone != null) {
      if (displayTZ.id == homeTimeZone!.id) {
        isHome = true;
      } else {
         offsetText = _calculateOffset(displayTZ, homeTimeZone!);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Offset / Icon
        SizedBox(
          height: 14,
          child: isHome
              ? Icon(Icons.navigation, size: 12, color: textColor)
              : (offsetText != null 
                  ? Text(offsetText, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w300))
                  : null),
        ),
        const SizedBox(height: 2),

        // Time
        Text(
          displayTZ.formattedTime(),
          style: TextStyle(
            color: textColor,
            fontSize: 34, // Slightly scaled for Flutter
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter', // Or system
          ),
          maxLines: 1,
        ),
        
        const Spacer(),

        // City
        Text(
          displayTZ.cityName,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Abbr
        Text(
          displayTZ.abbreviation,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // MARK: - Medium/Large Logic

  Widget _buildMediumLarge({required int limit}) {
    // Show up to limit timezones
    final displayList = timeZones.take(limit).toList();
    if (displayList.isEmpty) {
        // Sample data if empty
        displayList.add(HomeTimeZonePlaceholder());
    }

    return Stack(
      children: [
        Column(
          children: [
            for (int i = 0; i < displayList.length; i++) ...[
              Expanded(
                child: _TimeZoneRow(
                  timeZone: displayList[i],
                  isDark: isDark,
                  // Pass geometry constraints if needed, but Row handles horizontal
                ),
              ),
              if (i < displayList.length - 1)
                const SizedBox(height: 8), 
            ]
          ],
        ),
        
        // Center Line
        Center(
          child: Container(
            width: 1,
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
          ),
        )
      ],
    );
  }

  String _calculateOffset(TimeZoneItem tzItem, TimeZoneItem home) {
    if (tzItem.id == home.id) return ""; // Should be handled by isHome check
    
    final diff = tzItem.secondsFromGMT - home.secondsFromGMT;
    final minutes = (diff.abs() / 60).floor();
    final h = (minutes / 60).floor();
    final m = minutes % 60;
    
    final sign = diff >= 0 ? "+" : "-";
    if (m == 0) return "$sign${h}h";
    return "$sign${h}h ${m}m";
  }
}

// MARK: - Helper Classes

class HomeTimeZonePlaceholder extends TimeZoneItem {
   // A dummy item for empty states matching "Home/UTC"
   HomeTimeZonePlaceholder() 
   : super(
       identifier: 'UTC', 
       cityName: 'UTC', 
       abbreviation: 'UTC', 
       isHome: true
     );
}

class _TimeZoneRow extends StatelessWidget {
  final TimeZoneItem timeZone;
  final bool isDark;

  const _TimeZoneRow({required this.timeZone, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeZone.cityName,
              style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w300),
            ),
            Text(
              timeZone.formattedTime(),
              style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Bar
        SizedBox(
          height: 6,
          child: LayoutBuilder(
            builder: (context, constraints) {
               return CustomPaint(
                 size: Size(constraints.maxWidth, 6),
                 painter: _SolarBarPainter(
                    timeZone: timeZone,
                    isDark: isDark,
                 ),
               );
            },
          ),
        ),
      ],
    );
  }
}

class _SolarBarPainter extends CustomPainter {
  final TimeZoneItem timeZone;
  final bool isDark;

  _SolarBarPainter({required this.timeZone, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Night Background
    final nightPaint = Paint()
      ..color = isDark ? const Color(0xFF757575).withOpacity(0.2) : const Color(0xFFC7C7CC)
      ..style = PaintingStyle.fill;
    
    final barRRect = RRect.fromRectAndRadius(
       Rect.fromLTWH(0, 0, size.width, size.height),
       Radius.circular(3) // Half of height 6
    );
    canvas.drawRRect(barRRect, nightPaint);

    // Daylight Segments
    // 24 hours centered on NOW.
    // Normalized: Now is center (0.5 or pixel center).
    // Daylight is 6am to 6pm local solar time (roughly).
    
    final currentHour = timeZone.currentHour() + timeZone.currentMinute() / 60.0;
    
    // Logic from Swift:
    // let pixelsPerHour = barWidth / 24.0
    // let centerX = barWidth / 2.0
    // loop dayOffset -1...1
    // dayStart = 6.0 + offset
    // dayEnd = 18.0 + offset
    // hoursToStart = dayStart - currentHour
    // hoursToEnd = dayEnd - currentHour
    // clamp between -12 and 12

    final pixelsPerHour = size.width / 24.0;
    final centerX = size.width / 2.0;

    final dayGradient = const LinearGradient(
       colors: [Color(0xFFFFD900), Color(0xFFFF9900)]
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dayPaint = Paint()..shader = dayGradient;

    for (int dayOffset = -1; dayOffset <= 1; dayOffset++) {
       final dayOffsetHours = dayOffset * 24.0;
       final dayStart = 6.0 + dayOffsetHours;
       final dayEnd = 18.0 + dayOffsetHours;
       
       final hoursToStart = dayStart - currentHour;
       final hoursToEnd = dayEnd - currentHour;
       
       if (hoursToEnd >= -12 && hoursToStart <= 12) {
          final clampedStart = max(-12.0, hoursToStart);
          final clampedEnd = min(12.0, hoursToEnd);
          
          final startX = centerX + clampedStart * pixelsPerHour;
          final endX = centerX + clampedEnd * pixelsPerHour;
          
          // Clamp to widget bounds
          final segmentStartX = max(0.0, startX);
          final segmentEndX = min(size.width, endX);
          final segmentWidth = segmentEndX - segmentStartX;
          
          if (segmentWidth > 0) {
             final segmentRRect = RRect.fromRectAndRadius(
                Rect.fromLTWH(segmentStartX, 0, segmentWidth, size.height),
                Radius.circular(3)
             );
             canvas.drawRRect(segmentRRect, dayPaint);
          }
       }
    }
  }

  @override
  bool shouldRepaint(covariant _SolarBarPainter oldDelegate) {
     // Check if time changed significantly or timezone/theme changed
     return oldDelegate.timeZone.id != timeZone.id || oldDelegate.isDark != isDark;
  }
}
