import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_drawer.dart';
import 'package:walkingapp/components/my_submissionlist.dart';
import 'package:walkingapp/functions/jsonReader.dart';

import '../models/submission.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder<List<Submission>>(
        future: loadSubmissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No submissions found'));
          } else {
            return SubmissionList(submissions: snapshot.data!);
          }
        },
      ),
    );
  }
}
