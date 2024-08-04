import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

const String apiKey = "5b3ce3597851110001cf62481e0f688e55fc43cd9bd1f5807ec3d81a";

class POI {
  final LatLng location;
  final String name;
  final String description;

  POI({
    required this.location,
    required this.name,
    required this.description,
  });
}

class Plan {
  final String title;
  final String description;
  final List<POI> points;
  final List<String> instructions;
  final List<LatLng> generatedRoute;

  Plan({
    required this.title,
    required this.description,
    required this.points,
    required this.instructions,
    required this.generatedRoute,
  });
}

Future<Map<String, dynamic>> fetchRoute(LatLng start, LatLng end) async {
  final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final geometry = data['features'][0]['geometry']['coordinates'] as List;
    final route = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();
    final steps = data['features'][0]['properties']['segments'][0]['steps'] as List;
    final instructions = steps.map((step) => step['instruction'] as String).toList();
    final firstStep = steps[0];
    final firstName = firstStep['name'];
    final firstInstruction = firstStep['instruction'];
    return {
      'route': route,
      'instructions': instructions,
      'name': firstName,
      'instruction': firstInstruction,
    };
  } else {
    throw Exception('Failed to load route');
  }
}

Future<List<POI>> fetchPOIs(String amenity) async {
  final url = Uri.parse(
      'http://overpass-api.de/api/interpreter?data=[out:json];node[amenity=$amenity](53.3600,-2.4200,53.6300,-2.0500);out;');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final pois = data['elements'] as List;
    return pois.map((poi) {
      final name = poi['tags']?['name'] ?? 'Unnamed $amenity';
      final description = poi['tags']?['description'] ?? 'No description available';
      return POI(
        location: LatLng(poi['lat'], poi['lon']),
        name: name,
        description: description,
      );
    }).toList();
  } else {
    throw Exception('Failed to load POIs');
  }
}

class AddPlanPage extends StatefulWidget {
  final Function(Plan) addTile;

  AddPlanPage({required this.addTile});

  @override
  _AddPlanPageState createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = const LatLng(53.4808, -2.2426); // Center of Greater Manchester
  List<POI> stopPoints = [];
  List<LatLng> generatedRoute = [];
  List<String> generatedInstructions = [];
  String defaultName = '';
  String defaultInstruction = '';
  double currentZoom = 13;
  bool loopBack = false;
  Map<String, bool> poiToggles = {
    'cafe': true,
    'restaurant': false,
    'hospital': false,
  };
  Map<String, List<POI>> poiLocations = {};

  @override
  void initState() {
    super.initState();
    poiToggles.forEach((type, _) {
      fetchPOIs(type).then((data) {
        setState(() {
          poiLocations[type] = data;
        });
      });
    });
  }

  Future<void> updateRoute() async {
    try {
      List<LatLng> allPoints = [selectedLocation, ...stopPoints.map((poi) => poi.location)];
      if (loopBack) {
        allPoints.add(selectedLocation);
      }
      generatedRoute.clear();
      generatedInstructions.clear();
      for (int i = 0; i < allPoints.length - 1; i++) {
        final result = await fetchRoute(allPoints[i], allPoints[i + 1]);
        if (i == 0) {
          defaultName = result['name'];
          defaultInstruction = result['instruction'];
        }
        generatedRoute.addAll(result['route']);
        generatedInstructions.addAll(result['instructions']);
      }
      if (generatedRoute.isEmpty) {
        throw Exception('No route generated');
      }
      setState(() {});
    } catch (e) {
      setState(() {
        generatedRoute = []; // Ensure it's empty in case of error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate route: ${e.toString()}'),
        ),
      );
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
      final POI item = stopPoints.removeAt(oldIndex);
      stopPoints.insert(newIndex, item);
    });
  }

  void addPoiToRoute(POI poi) {
    setState(() {
      stopPoints.add(poi);
    });
  }

  void togglePoiType(String type, bool value) {
    setState(() {
      poiToggles[type] = value;
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
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text("Select Starting Point:"),
            SizedBox(
              height: MediaQuery.of(context).size.width, // Make the map square
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: selectedLocation,
                  initialZoom: 13,
                  minZoom: 10,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedLocation = point;
                    });
                  },
                  onPositionChanged: (mapPosition, hasGesture) {
                    setState(() {
                      selectedLocation = mapPosition.center;
                      currentZoom = mapPosition.zoom;
                    });
                  },
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
                      for (POI stopPoint in stopPoints)
                        Marker(
                          width: 80,
                          height: 80,
                          point: stopPoint.location,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      if (currentZoom >= 13)
                        for (var entry in poiToggles.entries)
                          if (entry.value)
                            for (POI poi in poiLocations[entry.key] ?? [])
                              Marker(
                                width: 80,
                                height: 80,
                                point: poi.location,
                                child: GestureDetector(
                                  onTap: () => addPoiToRoute(poi),
                                  child: Icon(
                                    _getPOIIcon(entry.key),
                                    color: _getPOIColor(entry.key),
                                    size: 20,
                                  ),
                                ),
                              ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Loop back to starting point'),
                Switch(
                  value: loopBack,
                  onChanged: (value) {
                    setState(() {
                      loopBack = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('POI Types:'),
            Column(
              children: poiToggles.keys.map((type) {
                return CheckboxListTile(
                  title: Text(type.capitalize()),
                  value: poiToggles[type],
                  onChanged: (bool? value) {
                    if (value != null) {
                      togglePoiType(type, value);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    stopPoints.add(POI(location: selectedLocation, name: 'Custom Point', description: 'User selected point'));
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
                    title: Text('Point ${index + 1}: ${stopPoints[index].name}'),
                    subtitle: Text(stopPoints[index].description),
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
                    final plan = Plan(
                      title: title,
                      description: description,
                      points: stopPoints,
                      instructions: generatedInstructions,
                      generatedRoute: generatedRoute,
                    );
                    widget.addTile(plan);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to generate route. Please try again.'),
                      ),
                    );
                  }
                },
                child: const Text('Generate Route'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPOIIcon(String type) {
    switch (type) {
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'hospital':
        return Icons.local_hospital;
      default:
        return Icons.location_on;
    }
  }

  Color _getPOIColor(String type) {
    switch (type) {
      case 'cafe':
        return Colors.brown;
      case 'restaurant':
        return Colors.green;
      case 'hospital':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
