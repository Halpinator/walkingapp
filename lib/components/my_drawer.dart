import 'package:flutter/material.dart';
import 'package:walkingapp/auth/auth_service.dart';
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
                    Icons.pin,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                    )
                  ),
              ),
              
              //home
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  title: Text("Home"),
                  leading: Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              
                        //home
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  title: Text("Settings"),
                  leading: Icon(Icons.settings),
                  onTap: () {
                     Navigator.pop(context);
                     //nav to settings
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage()
                        )
                      );
                  },
                ),
              ),
            ],
          ),

                    //home
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 15.0),
            child: ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          )
        ],
      )
    );
  }
}