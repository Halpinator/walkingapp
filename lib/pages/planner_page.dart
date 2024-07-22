import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkingapp/components/my_plannertilegridview.dart';
import 'package:walkingapp/pages/addPlan_page.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  final List<List<String>> tileInformation = [
    ["Hello", "Hello"],
    ["David", "Halpin"],
  ];

  final List<List<LatLng>> tileRoutes = [
    [const LatLng(53.4808, -2.2426), const LatLng(53.4818, -2.2436)],
    [const LatLng(53.4808, -2.2426), const LatLng(53.4818, -2.2436)],
  ];

  void _addTile(String title, String description,  List<LatLng> route) {
    setState(() {
      tileInformation.add([title, description]);
      tileRoutes.add(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Planner Page")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPlanPage(addTile: _addTile),
            ),
          );
        },
        splashColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        child: const Icon(
          Icons.add,
          size: 50,
          ),
        ),
      body: Padding (
        padding: const EdgeInsets.all(16),
        child: Column (
          children: [
            Expanded(child: MyPlannerTileGridView(plannerList: tileInformation, routes: tileRoutes,))
          ],
        ),
      )
    );
  }
}