import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

const String apiKey = "5b3ce3597851110001cf62481e0f688e55fc43cd9bd1f5807ec3d81a";

Future<Map<String, dynamic>> fetchRoute(LatLng start, LatLng end) async {
  final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final geometry = data['features'][0]['geometry']['coordinates'] as List;
    final route = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();
    final firstStep = data['features'][0]['properties']['segments'][0]['steps'][0];
    final firstName = firstStep['name'];
    final firstInstruction = firstStep['instruction'];
    return {
      'route': route,
      'name': firstName,
      'instruction': firstInstruction,
    };
  } else {
    throw Exception('Failed to load route');
  }
}

void addPlanDialog(BuildContext context, Function(String, String, List<LatLng>) addTile) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = LatLng(53.4808, -2.2426);
  double walkLength = 1.0;
  List<LatLng> generatedRoute = [];
  String defaultName = '';
  String defaultInstruction = '';


    Future<void> updateRoute() async {
    LatLng endLocation = LatLng(selectedLocation.latitude + walkLength * 0.01, selectedLocation.longitude + walkLength * 0.01);
    try {
      final result = await fetchRoute(selectedLocation, endLocation);
      generatedRoute = result['route'];
      defaultName = result['name'];
      defaultInstruction = result['instruction'];
    } catch (e) {
      generatedRoute = []; // Ensure it's empty in case of error
    }
  }


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
                      minZoom: 10,
                      onPositionChanged: (position, hasGesture) {
                        setState(() {
                          selectedLocation = position.center;
                          //updateRoute();
                          //generatedRoute = generateRoute(selectedLocation, walkLength);
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
                      //updateRoute();
                      //generatedRoute = generateRoute(selectedLocation, walkLength);
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
                onPressed: () async {
                  await updateRoute();
                  if (generatedRoute.isNotEmpty) {
                    final title = titleController.text.isEmpty ? defaultName : titleController.text;
                    final description = descriptionController.text.isEmpty ? defaultInstruction : descriptionController.text;
                    addTile(title, description, generatedRoute);
                    Navigator.of(context).pop();
                  } else {
                    // Show an error message if the route is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to generate route. Please try again.'),
                      ),
                    );
                  }
                }
              ),
            ],
          );
        }
      );
    },
  );
}
