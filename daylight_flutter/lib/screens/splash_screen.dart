import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Home after 1 second
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background based on device theme (handled by main.dart theme data)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = Responsive.isTabletOrLarger(context);

    // Responsive sizes
    final iconSize = isLargeScreen ? 200.0 : 150.0;
    final iconRadius = isLargeScreen ? 45.0 : 34.0;
    final titleFontSize = isLargeScreen ? 42.0 : 32.0;
    final brandFontSize = isLargeScreen ? 52.0 : 40.0;
    final poweredByFontSize = isLargeScreen ? 14.0 : 12.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Center: Application Icon and Title
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(iconRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: isLargeScreen ? 30 : 20,
                        offset: Offset(0, isLargeScreen ? 15 : 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(iconRadius),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: isLargeScreen ? 32 : 24),
                Text(
                  "Daylight Zones",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Bottom: Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + (isLargeScreen ? 60 : 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ārāycci",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: brandFontSize,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 12 : 8),
                Text(
                  "POWERED BY KAASPRO",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: poweredByFontSize,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w300,
                    letterSpacing: isLargeScreen ? 3.0 : 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
