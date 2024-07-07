import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_plannertile.dart';

class MyPlannerTileGridView extends StatefulWidget {
  List<List<String>> plannerList;

  MyPlannerTileGridView({
    required this.plannerList,
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
      ),
      itemCount: widget.plannerList.length,
      itemBuilder: (BuildContext context, int index) {
        return MyPlannerTile(
          title: widget.plannerList[index][0],
          description:  widget.plannerList[index][1],
        );
      },
    );
  }
}