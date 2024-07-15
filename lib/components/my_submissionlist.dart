import 'package:flutter/material.dart';
import 'package:walkingapp/components/my_submissiontile.dart';

import '../models/submission.dart';

class SubmissionList extends StatelessWidget {
  final List<Submission> submissions;

  const SubmissionList({required this.submissions, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        return SubmissionTile(submission: submissions[index]);
      },
    );
  }
}
