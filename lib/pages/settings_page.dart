import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkingapp/themes/themeProvider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings Page"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              value: Provider.of<ThemeProvider>(context, listen: true).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
        ],
      ),
    );
  }
}
