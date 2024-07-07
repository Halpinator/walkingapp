import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void addPlanDialog(BuildContext context, Function(String, String, LatLng) addTile) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng selectedLocation = LatLng(53.4808, -2.2426);

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
                        });
                      }
                    ),
                    children: [
                      TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                          subdomains: ['a', 'b', 'c'],
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
                    addTile(titleController.text, descriptionController.text, selectedLocation);
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
