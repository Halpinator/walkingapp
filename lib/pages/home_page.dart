import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_drawer.dart';
import 'package:walkingapp/components/my_submissionlist.dart';
import 'package:walkingapp/functions/jsonReader.dart';


class HomePage extends StatelessWidget {
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No submissions found'));
          } else {
            return SubmissionList(submissions: snapshot.data!);
          }
        },
      ),
    );
  }
}
