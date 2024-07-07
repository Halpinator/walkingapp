import 'package:flutter/material.dart';
import 'package:walkingapp/auth/auth_service.dart';
import 'package:walkingapp/pages/planner_page.dart';
import 'package:walkingapp/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //logo
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.location_pin,
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                    ),
                  ),
                ),
              
              // Home Tile
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: ListTile(
                  title: const Text("Home"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    // Pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),
              // Settings Tile
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: const Text("Settings"),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    // Pop the drawer
                    Navigator.pop(context);
                    // Go to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage()
                        )
                    );
                  },
                ),
              ),
              // Planner Tile
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: const Text("Planner"),
                  leading: const Icon(Icons.note),
                  onTap: () {
                    // Pop the drawer
                    Navigator.pop(context);
                    // Go to Planner page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlannerPage()
                        )
                    );
                  },
                ),
              ),
            ],
          ),
          // logout
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 15),
            child: ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
        ),
    );
  }
}