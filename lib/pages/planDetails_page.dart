import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'addPlan_page.dart'; // Ensure the import path is correct

class PlanDetailsPage extends StatelessWidget {
  final Plan plan;

  PlanDetailsPage({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.description),
              const SizedBox(height: 16),
              const Text('Route Map:'),
              SizedBox(
                height: 400,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: plan.points.first.location,
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
                          points: plan.generatedRoute,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: plan.points.map((poi) {
                        return Marker(
                          width: 80,
                          height: 80,
                          point: poi.location,
                          child: Icon(
                            _getPOIIcon(poi.name),
                            color: _getPOIColor(poi.name),
                            size: 40,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Points of Interest:'),
              for (var poi in plan.points)
                ListTile(
                  title: Text(poi.name),
                  subtitle: Text(poi.description),
                ),
              const SizedBox(height: 16),
              const Text('Navigation Instructions:'),
              for (var instruction in plan.instructions)
                ListTile(
                  title: Text(instruction),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPOIIcon(String name) {
    if (name.toLowerCase().contains('cafe')) return Icons.local_cafe;
    if (name.toLowerCase().contains('restaurant')) return Icons.restaurant;
    if (name.toLowerCase().contains('hospital')) return Icons.local_hospital;
    return Icons.location_on;
  }

  Color _getPOIColor(String name) {
    if (name.toLowerCase().contains('cafe')) return Colors.blue;
    if (name.toLowerCase().contains('restaurant')) return Colors.green;
    if (name.toLowerCase().contains('hospital')) return Colors.red;
    return Colors.grey;
  }
}