import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyPlannerTile extends StatefulWidget {
  final String title;
  final String description;
  final List<LatLng> route;

  const MyPlannerTile({
    required this.title,
    required this.description,
    required this.route,
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
              'Start: ${widget.route.first.latitude}, ${widget.route.first.longitude}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.normal,
                fontSize: 10,
                ),
              textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20,),

              Expanded(
                child: FlutterMap(
                    options: MapOptions(
                      initialCenter: widget.route.first,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: widget.route,
                            strokeWidth: 4,
                            color: Colors.blue,
                            ),
                        ],
                      ),
                    ],
                  ),
                )
            ],
          )
        )
    );
  }
}