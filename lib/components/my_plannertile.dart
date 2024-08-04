import 'package:flutter/material.dart';
import 'package:walkingapp/pages/addPlan_page.dart';
import 'package:walkingapp/pages/planDetails_page.dart';

class MyPlannerTile extends StatelessWidget {
  final Plan plan;

  MyPlannerTile({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlanDetailsPage(plan: plan),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
           color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(plan.description,
              style: TextStyle (color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
