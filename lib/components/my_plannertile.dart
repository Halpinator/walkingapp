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
    super.key,
  });

  @override
  State<MyPlannerTile> createState() => _PlannerTileState();
}

class _PlannerTileState extends State<MyPlannerTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Start: ${widget.route.first.latitude}, ${widget.route.first.longitude}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.route.first,
                    initialZoom: 13,
                    minZoom: 10,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
