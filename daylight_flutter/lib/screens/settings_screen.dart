import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    // Forces dark mode styling for the sheet content
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
           bodyMedium: TextStyle(color: Colors.white),
           bodyLarge: TextStyle(color: Colors.white),
           titleMedium: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: ListView(
        shrinkWrap: true, // Important for BottomSheet
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Theme Section
          _buildSectionHeader("Theme"),
          ListTile(
            title: const Text("Appearance", style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              dropdownColor: Colors.grey.shade900,
              underline: Container(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  settings.themeMode = newValue;
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text("System", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: ThemeMode.light, child: Text("Light", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark", style: TextStyle(color: Colors.white))),
              ],
            ),
          ),

          // Display Section
          _buildSectionHeader("Display"),
          SwitchListTile(
            title: const Text("Show Center Line", style: TextStyle(color: Colors.white)),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                "Shows a vertical line at the center of timezone cards to indicate current time position",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            value: settings.showCenterLine,
            onChanged: (bool value) {
              settings.showCenterLine = value;
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green, // iOS Green
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
