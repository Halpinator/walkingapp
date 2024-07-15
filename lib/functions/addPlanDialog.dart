import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void addPlanDialog(BuildContext context, Function(String, String, List<LatLng>) addTile) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = LatLng(53.4808, -2.2426);
  double walkLength = 1.0;

  List<LatLng> generateRoute(LatLng start, double length) {
  // Simple route generation logic
  List<LatLng> route = [start];
  double distance = 0.01 * length; // example calculation for the route length
  route.add(LatLng(start.latitude + distance, start.longitude + distance));
  return route;
}

List<LatLng> generatedRoute = generateRoute(selectedLocation, walkLength);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Plan Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                // Map starting point select
                const SizedBox(height: 16),
                const Text("Select Starting Point:"),
                
                SizedBox(
                  height: 200,
                  width: 400,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedLocation,
                      initialZoom: 13,
                      onPositionChanged: (position, hasGesture) {
                        setState(() {
                          selectedLocation = position.center;
                          generatedRoute = generateRoute(selectedLocation, walkLength);
                        });
                      }
                    ),
                    children: [
                      TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                          //subdomains: ['a', 'b', 'c'],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: selectedLocation,
                            child: const Icon(
                              Icons.location_on,
                              color: Color.fromARGB(255, 26, 155, 105),
                              size: 40))
                          ]
                        ),
                      ],
                  ),
                ), 

                 const SizedBox(height: 16),
                Text("Length of walk: ${walkLength.toStringAsFixed(1)} km"),
                Slider(
                  min: 0.5,
                  max: 10.0,
                  divisions: 20,
                  value: walkLength,
                  onChanged: (value) {
                    setState(() {
                      walkLength = value;
                      generatedRoute = generateRoute(selectedLocation, walkLength);
                    });
                  }
                )
                
              ],
            ),

            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                    addTile(titleController.text, descriptionController.text, generatedRoute);
                    Navigator.of(context).pop();
                }
              ),
            ],
          );
        }
      );
    },
  );
}
