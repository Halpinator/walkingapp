import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walkingapp/components/my_submissionlist.dart';

Future<List<Submission>> loadSubmissions() async {
  final String response = await rootBundle.loadString('assets/walking_submissions.json');
  final List<dynamic> data = json.decode(response);

  return data.map<Submission>((json) => Submission.fromJson(json)).toList();
}
