import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_plannertilegridview.dart';
import 'addPlan_page.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  List<Plan> plans = [];

  void _addTile(Plan plan) {
    setState(() {
      plans.add(plan);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: MyPlannerTileGridView(plans: plans),
            ),
          ],
        ),
      ),
    );
  }
}
