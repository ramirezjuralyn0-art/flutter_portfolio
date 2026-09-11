import 'package:flutter/material.dart';

class ActivityOneScreen extends StatelessWidget {
  const ActivityOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 1'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity 1: Basic Flutter UI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'This activity demonstrates basic Flutter widgets '
              'and declarative user interface design.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            Center(
              child: Icon(
                Icons.flutter_dash,
                size: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}