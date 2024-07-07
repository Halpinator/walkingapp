import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_plannertilegridview.dart';

class PlannerPage extends StatelessWidget {
  PlannerPage({super.key});

  final List<List<String>> todoInformation = [
    ["Hello", "Hello"],
    ["David", "Halpin"],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Planner Page")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
            Expanded(child: MyPlannerTileGridView(plannerList: todoInformation))
          ],
        ),
      )
    );
  }
}