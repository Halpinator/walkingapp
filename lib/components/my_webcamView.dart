// lib/webcam_view.dart

import 'dart:async';
import 'package:flutter/material.dart';

class WebcamView extends StatefulWidget {
  final String url;
  final String title;

  const WebcamView({required this.url, required this.title, Key? key}) : super(key: key);

  @override
  _WebcamViewState createState() => _WebcamViewState();
}

class _WebcamViewState extends State<WebcamView> {
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.url;
    _startImageRefreshTimer();
  }

  void _startImageRefreshTimer() {
    // Refresh the image every 10 minutes
    Timer.periodic(Duration(minutes: 10), (Timer timer) {
      setState(() {
        imageUrl = widget.url + '?t=${DateTime.now().millisecondsSinceEpoch}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Text('Failed to load webcam feed');
          },
        ),
      ),
    );
  }
}
