import 'package:flutter/material.dart';

class ActivityTwoScreen extends StatefulWidget {
  const ActivityTwoScreen({super.key});

  @override
  State<ActivityTwoScreen> createState() =>
      _ActivityTwoScreenState();
}

class _ActivityTwoScreenState
    extends State<ActivityTwoScreen> {

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 2'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Activity 2: Stateful Interaction',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Button pressed:',
                      style: TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '$counter times',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          counter++;
                        });
                      },
                      child: const Text('Press Me'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}