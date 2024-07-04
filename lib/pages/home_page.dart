import 'package:flutter/material.dart';
import 'package:walkingapp/auth/auth_service.dart';
import 'package:walkingapp/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      drawer: MyDrawer(),
    );
  }
}