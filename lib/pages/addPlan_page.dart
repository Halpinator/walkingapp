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

class AddPlanPage extends StatefulWidget {
  final Function(String, String, List<LatLng>) addTile;

  AddPlanPage({required this.addTile});

  @override
  _AddPlanPageState createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = const LatLng(53.4808, -2.2426);
  List<LatLng> stopPoints = [];
  List<LatLng> generatedRoute = [];
  String defaultName = '';
  String defaultInstruction = '';

  Future<void> updateRoute() async {
    List<LatLng> allPoints = [selectedLocation, ...stopPoints];
    generatedRoute.clear();
    try {
      for (int i = 0; i < allPoints.length - 1; i++) {
        final result = await fetchRoute(allPoints[i], allPoints[i + 1]);
        generatedRoute.addAll(result['route']);
        if (i == 0) {
          defaultName = result['name'];
          defaultInstruction = result['instruction'];
        }
      }
      setState(() {});
    } catch (e) {
      setState(() {
        generatedRoute = []; // Ensure it's empty in case of error
      });
    }
  }

  void removePoint(int index) {
    setState(() {
      stopPoints.removeAt(index);
    });
  }

  void reorderPoints(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final LatLng item = stopPoints.removeAt(oldIndex);
      stopPoints.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plan Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            const Text("Select Starting Point:"),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: selectedLocation,
                  initialZoom: 13,
                  minZoom: 10,
                  onPositionChanged: (position, hasGesture) {
                    setState(() {
                      selectedLocation = position.center;
                    });
                  }
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
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
                          size: 40,
                        ),
                      ),
                      for (LatLng stopPoint in stopPoints)
                        Marker(
                          width: 80,
                          height: 80,
                          point: stopPoint,
                          child: const Icon(
                            Icons.stop_circle,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    stopPoints.add(selectedLocation);
                  });
                },
                child: const Text('Add Stop Point'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Stop Points:'),
            ReorderableListView(
              shrinkWrap: true,
              onReorder: reorderPoints,
              children: [
                for (int index = 0; index < stopPoints.length; index++)
                  ListTile(
                    key: ValueKey(stopPoints[index]),
                    title: Text('Point ${index + 1}: ${stopPoints[index].latitude}, ${stopPoints[index].longitude}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removePoint(index),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await updateRoute();
                  if (generatedRoute.isNotEmpty) {
                    final title = titleController.text.isEmpty ? defaultName : titleController.text;
                    final description = descriptionController.text.isEmpty ? defaultInstruction : descriptionController.text;
                    widget.addTile(title, description, generatedRoute);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to generate route. Please try again.'),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
