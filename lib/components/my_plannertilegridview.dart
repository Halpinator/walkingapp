import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkingapp/components/my_plannertile.dart';

class MyPlannerTileGridView extends StatefulWidget {
  List<List<String>> plannerList;
  List<List<LatLng>> routes;

  MyPlannerTileGridView({
    required this.plannerList,
    required this.routes,
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
        crossAxisCount: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: widget.plannerList.length,
      itemBuilder: (BuildContext context, int index) {
        return MyPlannerTile(
          title: widget.plannerList[index][0],
          description:  widget.plannerList[index][1],
          route: widget.routes[index],
        );
      },
    );
  }
}