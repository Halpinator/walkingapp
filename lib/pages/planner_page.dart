import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkingapp/components/my_plannertilegridview.dart';
import 'package:walkingapp/functions/addPlanDialog.dart';

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

  final List<LatLng> tileLocations = [
    LatLng(53.4808, -2.2426),
    LatLng(53.4808, -2.2426),
  ];

  void _addTile(String title, String description, LatLng startingLocation) {
    setState(() {
      tileInformation.add([title, description]);
      tileLocations.add(startingLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Planner Page")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPlanDialog(context, _addTile),
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
            Expanded(child: MyPlannerTileGridView(plannerList: tileInformation, startingLocation: tileLocations,))
          ],
        ),
      )
    );
  }
}