import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'addPlan_page.dart'; // Ensure the import path is correct

class PlanDetailsPage extends StatefulWidget {
  final Plan plan;

  PlanDetailsPage({required this.plan});

  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  bool _isMapExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const lightTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    const darkTileUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {
              // Implement navigation functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: _isMapExpanded ? 1 : 4,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: widget.plan.points.first.location,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: isDarkMode ? darkTileUrl : lightTileUrl,
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.plan.generatedRoute,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: widget.plan.points.map((poi) {
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
          GestureDetector(
            onTap: () {
              setState(() {
                _isMapExpanded = !_isMapExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey.shade300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isMapExpanded ? "Show Details" : "Expand Map"),
                  Icon(_isMapExpanded ? Icons.arrow_upward : Icons.arrow_downward),
                ],
              ),
            ),
          ),
          if (!_isMapExpanded)
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points of Interest:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...widget.plan.points.map((poi) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(poi.name),
                            subtitle: Text(poi.description),
                            leading: Icon(
                              _getPOIIcon(poi.name),
                              color: _getPOIColor(poi.name),
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      const Text(
                        'Navigation Instructions:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...widget.plan.instructions.map((instruction) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(instruction),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigation),
        onPressed: () {
          // Implement navigation functionality here
        },
      ),
    );
  }

IconData _getPOIIcon(String type) {
  if (type.toLowerCase().contains('park')) return Icons.local_florist;
  if (type.toLowerCase().contains('picnic_site')) return Icons.food_bank;
  if (type.toLowerCase().contains('viewpoint')) return Icons.remove_red_eye;
  if (type.toLowerCase().contains('historic_site')) return Icons.account_balance;
  if (type.toLowerCase().contains('nature_reserve')) return Icons.eco;
  if (type.toLowerCase().contains('waterfall')) return Icons.waterfall_chart;
  if (type.toLowerCase().contains('campsite')) return Icons.forest;
  if (type.toLowerCase().contains('trail')) return Icons.terrain;
  if (type.toLowerCase().contains('webcam')) return Icons.camera;
  return Icons.location_on;
}

Color _getPOIColor(String type) {
  if (type.toLowerCase().contains('park')) return Colors.green[700]!;
  if (type.toLowerCase().contains('picnic_site')) return Colors.amber[800]!;
  if (type.toLowerCase().contains('viewpoint')) return Colors.deepPurple[400]!;
  if (type.toLowerCase().contains('historic_site')) return Colors.brown[600]!;
  if (type.toLowerCase().contains('nature_reserve')) return Colors.lightGreen[800]!;
  if (type.toLowerCase().contains('waterfall')) return Colors.blue[300]!;
  if (type.toLowerCase().contains('campsite')) return Colors.deepOrange[700]!;
  if (type.toLowerCase().contains('trail')) return Colors.brown[400]!;
  if (type.toLowerCase().contains('webcam')) return Colors.grey[600]!;
  return Colors.grey[600]!;
}
}
