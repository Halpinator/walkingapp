import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:walkingapp/components/my_webcamView.dart';

const String apiKey = "5b3ce3597851110001cf62481e0f688e55fc43cd9bd1f5807ec3d81a";

// Model Classes
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

// Network Functions
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
    return {
      'route': route,
      'instructions': instructions,
      'name': firstStep['name'],
      'instruction': firstStep['instruction'],
    };
  } else {
    throw Exception('Failed to load route');
  }
}

Future<List<POI>> fetchPOIs(String amenityType) async {
  String overpassQuery;

  // Adjusting the query based on the type of amenity
  switch (amenityType) {
    case 'park':
      overpassQuery = '[leisure=park]';
      break;
    case 'picnic_site':
      overpassQuery = '[tourism=picnic_site]';
      break;
    case 'viewpoint':
      overpassQuery = '[tourism=viewpoint]';
      break;
    case 'historic_site':
      overpassQuery = '[historic=site]';
      break;
    case 'nature_reserve':
      overpassQuery = '[leisure=nature_reserve]';
      break;
    case 'trail':
      overpassQuery = '[route=hiking]';
      break;
    case 'waterfall':
      overpassQuery = '[waterway=waterfall]';
      break;
    case 'campsite':
      overpassQuery = '[tourism=camp_site]';
      break;
    default:
      overpassQuery = '[tourism=$amenityType]';
      break;
  }

  final url = Uri.parse(
      'http://overpass-api.de/api/interpreter?data=[out:json];node$overpassQuery(53.3196,-2.4960,53.6270,-1.9090);out;');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final elements = data['elements'] as List;
    return elements.map((element) {
      final name = element['tags']?['name'] ?? 'Unnamed $amenityType';
      final description = element['tags']?['description'] ?? 'No description available';
      return POI(
        location: LatLng(element['lat'], element['lon']),
        name: name,
        description: description,
      );
    }).toList();
  } else {
    throw Exception('Failed to load POIs for $amenityType');
  }
}

// Main Widget
class AddPlanPage extends StatefulWidget {
  final Function(Plan) addTile;

  const AddPlanPage({required this.addTile});

  @override
  _AddPlanPageState createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = const LatLng(53.4808, -2.2426); // Center of Greater Manchester
  List<POI> stopPoints = [];
  List<LatLng> generatedRoute = [];
  List<String> generatedInstructions = [];
  String defaultName = '';
  String defaultInstruction = '';
  double currentZoom = 13;
  bool loopBack = false;
  bool isMapFullScreen = false;
  Map<String, bool> poiToggles = {
    'park': false,
    'picnic_site': false,
    'viewpoint': false,
    'historic_site': false,
    'nature_reserve': false,
    'trail': false,
    'waterfall': false,
    'campsite': false,
    'webcam': false,
  };
  Map<String, List<POI>> poiLocations = {};

  @override
  void initState() {
    super.initState();
    _fetchAllPOIs();
    _initializeWebcamPOIs();
  }

  void _fetchAllPOIs() {
    poiToggles.forEach((type, _) {
      if (type != 'webcam') {
        fetchPOIs(type).then((data) {
          setState(() {
            poiLocations[type] = data;
          });
        });
      }
    });
  }

  void _initializeWebcamPOIs() {
    poiLocations['webcam'] = [
      POI(
        location: LatLng(53.593349, -1.800309),
        name: 'Peak District Webcam 1',
        description: 'Live feed from Peak District 1',
      ),
      POI(
        location: LatLng(53.4808, -2.2426),
        name: 'Peak District Webcam 2',
        description: 'Live feed from Peak District 2',
      ),
    ];
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
        generatedRoute = [];
      });
      _showErrorSnackBar('Failed to generate route: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void addStopPoint() {
    setState(() {
      stopPoints.add(POI(
        location: selectedLocation,
        name: 'Custom Point',
        description: 'User selected point',
      ));
    });
  }

  void addPoiToRoute(POI poi) {
    setState(() {
      stopPoints.add(poi);
    });
  }

  void removePoint(int index) {
    setState(() {
      stopPoints.removeAt(index);
    });
  }

  void reorderPoints(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final POI item = stopPoints.removeAt(oldIndex);
      stopPoints.insert(newIndex, item);
    });
  }

  void togglePoiType(String type, bool value) {
    setState(() {
      poiToggles[type] = value;
    });
  }

  IconData _getPOIIcon(String type) {
    switch (type) {
      case 'park':
        return Icons.local_florist;
      case 'picnic_site':
        return Icons.food_bank;
      case 'viewpoint':
        return Icons.remove_red_eye;
      case 'historic_site':
        return Icons.account_balance;
      case 'nature_reserve':
        return Icons.eco;
      case 'waterfall':
        return Icons.waterfall_chart;
      case 'campsite':
        return Icons.forest;
      case 'trail':
        return Icons.terrain;
      case 'webcam':
        return Icons.camera;
      default:
        return Icons.location_on;
    }
  }

  Color _getPOIColor(String type) {
    switch (type) {
      case 'park':
        return Colors.green[700]!;
      case 'picnic_site':
        return Colors.amber[800]!;
      case 'viewpoint':
        return Colors.deepPurple[400]!;
      case 'historic_site':
        return Colors.brown[600]!;
      case 'nature_reserve':
        return Colors.lightGreen[800]!;
      case 'waterfall':
        return Colors.blue[300]!;
      case 'campsite':
        return Colors.deepOrange[700]!;
      case 'trail':
        return Colors.brown[400]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget buildPOIToggles() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 4,
      children: poiToggles.keys.map((type) {
        return Row(
          children: [
            Checkbox(
              value: poiToggles[type],
              onChanged: (bool? value) {
                if (value != null) togglePoiType(type, value);
              },
            ),
            Text(type.capitalize()),
          ],
        );
      }).toList(),
    );
  }

  Widget buildStopPointsList() {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: reorderPoints,
      children: stopPoints.map((poi) {
        int index = stopPoints.indexOf(poi);
        return ListTile(
          key: ValueKey(poi),
          title: Text('Point ${index + 1}: ${poi.name}'),
          subtitle: Text(poi.description),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => removePoint(index),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Plan Information')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isMapFullScreen
                      ? MediaQuery.of(context).size.height * 0.8
                      : MediaQuery.of(context).size.width * 0.8,
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
                          if (currentZoom >= 1)
                            for (var entry in poiToggles.entries)
                              if (entry.value)
                                for (POI poi in poiLocations[entry.key] ?? [])
                                  Marker(
                                    width: 80,
                                    height: 80,
                                    point: poi.location,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (entry.key == 'webcam') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WebcamView(
                                                url: 'https://www.maccinfo.com/WebcamCat/Webcamn200.jpg',
                                                title: poi.name,
                                              ),
                                            ),
                                          );
                                        } else {
                                          addPoiToRoute(poi);
                                        }
                                      },
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
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: addStopPoint,
                    child: const Text('Add Stop Point'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Loop back to starting point'),
                Switch(
                  value: loopBack,
                  onChanged: (value) {
                    setState(() {
                      loopBack = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('POI Types:'),
                buildPOIToggles(),
                const SizedBox(height: 16),
                const Text('Stop Points:'),
                buildStopPointsList(),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await updateRoute();
                      if (generatedRoute.isNotEmpty) {
                        final title = titleController.text.isEmpty
                            ? defaultName
                            : titleController.text;
                        final description = descriptionController.text.isEmpty
                            ? defaultInstruction
                            : descriptionController.text;
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
                        _showErrorSnackBar('Failed to generate route. Please try again.');
                      }
                    },
                    child: const Text('Generate Route'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isMapFullScreen = !isMapFullScreen;
                });
              },
              child: Icon(isMapFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
