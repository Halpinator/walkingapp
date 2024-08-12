import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:walkingapp/components/my_webcamView.dart';

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

Future<List<POI>> fetchPOIs(String amenityType) async {
  String overpassQuery = '';
  // Adjusting the query based on the type of amenity
  switch (amenityType) {
    case 'park':
      overpassQuery = '[leisure=park]';  // Parks are often leisure-focused.
      break;
    case 'picnic_site':
      overpassQuery = '[tourism=picnic_site]';  // Specific tag for picnic sites.
      break;
    case 'viewpoint':
      overpassQuery = '[tourism=viewpoint]';  // For scenic viewpoints.
      break;
    case 'historic_site':
      overpassQuery = '[historic=site]';  // For sites of historical importance.
      break;
    case 'nature_reserve':
      overpassQuery = '[leisure=nature_reserve]';  // Areas dedicated to preserving natural habitats.
      break;
    case 'trail':
      overpassQuery = '[route=hiking]';  // Hiking trails are specific routes designed for walking.
      break;
    case 'waterfall':
      overpassQuery = '[waterway=waterfall]';  // Natural waterfalls.
      break;
    case 'campsite':
      overpassQuery = '[tourism=camp_site]';  // Places designated for camping.
      break;
    default:
      overpassQuery = '[tourism=$amenityType]';  // Default fallback to tourism tag.
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
  bool isMapFullScreen = false; // Variable to track full-screen state
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

    // Fetch POIs for other types
    poiToggles.forEach((type, _) {
      if (type != 'webcam') {
        fetchPOIs(type).then((data) {
          setState(() {
            poiLocations[type] = data;
          });
        });
      }
    });

    // Add manually defined webcam POIs
    poiLocations['webcam'] = [
      POI(
        location: LatLng(53.593349, -1.800309), // Example coordinates
        name: 'Peak District Webcam 1',
        description: 'Live feed from Peak District 1',
      ),
      POI(
        location: LatLng(53.4808, -2.2426), // Another example
        name: 'Peak District Webcam 2',
        description: 'Live feed from Peak District 2',
      ),
      // Add more webcams as needed
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isMapFullScreen
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.width,
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
                                                url:
                                                    'https://www.maccinfo.com/WebcamCat/Webcamn200.jpg',
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
                        stopPoints.add(POI(
                            location: selectedLocation,
                            name: 'Custom Point',
                            description: 'User selected point'));
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
          Positioned(
            bottom: 16, // Move to the bottom of the screen
            right: 16,  // Keep it on the right side
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

  IconData _getPOIIcon(String type) {
    switch (type) {
      case 'park':
        return Icons.local_florist; // Changed to more explicitly represent nature
      case 'picnic_site':
        return Icons.food_bank; // Using a more specific icon if available
      case 'viewpoint':
        return Icons.remove_red_eye; // Suggestive of viewing or sightseeing
      case 'historic_site':
        return Icons.account_balance; // Represents historical buildings or sites
      case 'nature_reserve':
        return Icons.eco; // Represents environmental and ecological sites
      case 'waterfall':
        return Icons.waterfall_chart; // Iconic representation of waterfalls
      case 'campsite':
        return Icons.forest; // Ideal for campsites
      case 'trail':
        return Icons.terrain; // Represents rough terrains on hiking trails
      case 'webcam':
        return Icons.camera; // Represents rough terrains on hiking trails
      default:
        return Icons.location_on; // Generic location icon for unspecified types
    }
  }

  Color _getPOIColor(String type) {
    switch (type) {
      case 'park':
        return Colors.green[700]!; // Darker shade of green for better visibility
      case 'picnic_site':
        return Colors.amber[800]!; // Deeper orange for a warm, inviting look
      case 'viewpoint':
        return Colors.deepPurple[400]!; // A vibrant purple to denote special spots
      case 'historic_site':
        return Colors.brown[600]!; // Brown reflects the earthy, historical essence
      case 'nature_reserve':
        return Colors.lightGreen[800]!; // Vibrant green symbolizing untouched nature
      case 'waterfall':
        return Colors.blue[300]!; // Light blue representing water
      case 'campsite':
        return Colors.deepOrange[700]!; // Rich orange for outdoor adventure
      case 'trail':
        return Colors.brown[400]!; // Earthy tones matching the hiking theme
      default:
        return Colors.grey[600]!; // Neutral grey for undefined types
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}