import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void addPlanDialog(BuildContext context, Function(String, String) addTile) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  LatLng? selectedLocation;

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                  initialCenter: LatLng(53.4808, -2.2426),
                  initialZoom: 13,
                  onTap: (tapPosition, latLng) {
                    selectedLocation = latLng;
                  },
                ),
                children: [
                  TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      subdomains: ['a', 'b', 'c'],
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
              addTile(titleController.text, descriptionController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
