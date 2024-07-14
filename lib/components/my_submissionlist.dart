import 'package:flutter/material.dart';

class Submission {
  final String title;
  final String author;
  final String url;
  final String description;

  Submission({
    required this.title,
    required this.author,
    required this.url,
    required this.description,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      title: json['title'],
      author: json['author'],
      url: json['url'],
      description: json['description'],
    );
  }
}

class SubmissionList extends StatelessWidget {
  final List<Submission> submissions;

  SubmissionList({required this.submissions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(submissions[index].title),
          subtitle: Text(submissions[index].description),
          onTap: () {
            // Handle tap
          },
        );
      },
    );
  }
}
