import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<List<dynamic>> readZstFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  
  if (!file.existsSync()) {
    // Copy the asset file to the documents directory
    final byteData = await rootBundle.load('assets/$fileName');
    final buffer = byteData.buffer;
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  final compressedData = file.readAsBytesSync();
  final decompressedData = ZLibDecoder().decodeBytes(compressedData);
  final decodedString = utf8.decode(decompressedData);

  final jsonData = json.decode(decodedString);
  return jsonData['data']['children'];
}
