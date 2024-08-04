import 'package:flutter/material.dart';
import 'package:walkingapp/pages/addPlan_page.dart';
import 'package:walkingapp/components/my_plannertile.dart';

class MyPlannerTileGridView extends StatefulWidget {
  final List<Plan> plans;

  MyPlannerTileGridView({
    required this.plans,
    super.key,
  });

  @override
  State<MyPlannerTileGridView> createState() => _MyPlannerTileGridViewState();
}

class _MyPlannerTileGridViewState extends State<MyPlannerTileGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: widget.plans.length,
      itemBuilder: (BuildContext context, int index) {
        return MyPlannerTile(
          plan: widget.plans[index],
        );
      },
    );
  }
}
