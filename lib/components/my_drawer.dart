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
      backgroundColor: Theme.of(context).colorScheme.background,
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
              
              // home list tile
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: ListTile(
                  title: Text("Home"),
                  leading: Icon(Icons.home),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),
              // settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text("Settings"),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // Go to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage()
                        )
                    );
                  },
                ),
              ),
               // settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text("Planner"),
                  leading: Icon(Icons.note),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // Go to settings page
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
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
        ),
    );
  }
}