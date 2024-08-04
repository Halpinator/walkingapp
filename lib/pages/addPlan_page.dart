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
  final Function(String, String, List<LatLng>) addTile;

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
      for (int i = 0; i < allPoints.length - 1; i++) {
        final result = await fetchRoute(allPoints[i], allPoints[i + 1]);
        generatedRoute.addAll(result['route']);
        if (i == 0) {
          defaultName = result['name'];
          defaultInstruction = result['instruction'];
        }
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
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
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
                            Icons.stop_circle,
                            color: Colors.red,
                            size: 40,
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
                                    Icons.local_cafe,
                                    color: entry.key == 'cafe'
                                        ? Colors.blue
                                        : entry.key == 'restaurant'
                                            ? Colors.green
                                            : Colors.purple,
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
