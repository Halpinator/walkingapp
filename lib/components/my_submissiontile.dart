import 'package:flutter/material.dart';
import '../models/submission.dart';

class SubmissionTile extends StatelessWidget {
  final Submission submission;

  const SubmissionTile({
    required this.submission,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              submission.author,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              submission.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    
                    backgroundColor: Theme.of(context).colorScheme.tertiary, // Background color
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary, // Text color
                  ),
                  onPressed: () {
                    // Handle button press
                    // For example, open the URL in a web browser
                  },
                  child: const Text('Read More'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
