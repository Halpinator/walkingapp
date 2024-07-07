import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MyPlannerTile extends StatefulWidget {
  final String title;
  final String description;
  final LatLng startingLocation;

  const MyPlannerTile({
    required this.title,
    required this.description,
    required this.startingLocation,
    super.key
    });

  @override
  State<MyPlannerTile> createState() => _PlannerTileState();
}

class _PlannerTileState extends State<MyPlannerTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title, 
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                ),
              textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20,),

            Text(
              widget.description, 
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.normal,
                fontSize: 25,
                ),
              textAlign: TextAlign.center,
              ),
              
            const SizedBox(height: 20,),

            Text(
              'Location: ${widget.startingLocation.latitude}, ${widget.startingLocation.longitude}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.normal,
                fontSize: 10,
                ),
              textAlign: TextAlign.center,
              ),
            ],
          )
        )
    );
  }
}