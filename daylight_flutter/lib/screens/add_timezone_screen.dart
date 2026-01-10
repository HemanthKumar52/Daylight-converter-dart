import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timezone_store.dart';
import '../models/timezone_item.dart';
import '../models/available_timezones.dart';

class AddTimeZoneScreen extends StatefulWidget {
  const AddTimeZoneScreen({super.key});

  @override
  State<AddTimeZoneScreen> createState() => _AddTimeZoneScreenState();
}

class _AddTimeZoneScreenState extends State<AddTimeZoneScreen> {
  String searchText = "";
  final TextEditingController _searchController = TextEditingController();

  List<AvailableTimeZone> get filteredTimeZones {
    if (searchText.isEmpty) {
      return AvailableTimeZone.all;
    }
    return AvailableTimeZone.all.where((tz) {
      return tz.cityName.toLowerCase().contains(searchText.toLowerCase()) ||
          tz.abbreviation.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  bool isAlreadyAdded(TimeZoneStore store, AvailableTimeZone tz) {
    return store.timeZones.any((item) => item.cityName == tz.cityName);
  }

  void addTimeZone(BuildContext context, AvailableTimeZone tz) {
    final store = Provider.of<TimeZoneStore>(context, listen: false);
    final newItem = TimeZoneItem(
      identifier: tz.identifier,
      cityName: tz.cityName,
      abbreviation: tz.abbreviation,
      isHome: false, // Default not home
    );
    store.addTimeZone(newItem);
    // Optionally close or show feedback. 
    // Usually selecting adds it.
    // We stay open or close? User image has "Done", suggesting multiple selects or close when done.
    // I'll keep it open so they can add multiple, or close? 
    // Most timezone pickers close on selection.
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TimeZoneStore>(context);

    // Force Dark styling for glass sheet
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFF9900),
          selectionColor: Color(0x55FF9900),
          selectionHandleColor: Color(0xFFFF9900),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true, // Focus when opened
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFFFF9900),
              decoration: InputDecoration(
                hintText: "Search cities",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF2C2C2E), // Dark grey
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
              itemCount: filteredTimeZones.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.withOpacity(0.2), indent: 16),
              itemBuilder: (context, index) {
                final tz = filteredTimeZones[index];
                final added = isAlreadyAdded(store, tz);
                
                return ListTile(
                  title: Text(tz.cityName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(tz.abbreviation, style: const TextStyle(color: Colors.grey)),
                  trailing: added 
                      ? const Icon(Icons.check, color: Color(0xFFFF9900)) 
                      : null,
                  onTap: added ? null : () => addTimeZone(context, tz),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
