import 'package:flutter/material.dart';

import '../widgets/activity_card.dart';
import 'activity_one_screen.dart';
import 'activity_two_screen.dart';
import 'network_monitor_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flutter Portfolio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'My collection of Flutter laboratory activities.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            const Text(
              'Activities',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: ActivityCard(
                          title: 'Activity 1',
                          description: 'Basic Flutter UI',
                          icon: Icons.widgets,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ActivityOneScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: ActivityCard(
                          title: 'Activity 2',
                          description: 'Stateful Interaction',
                          icon: Icons.touch_app,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ActivityTwoScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ActivityCard(
                      title: 'Activity 1',
                      description: 'Basic Flutter UI',
                      icon: Icons.widgets,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ActivityOneScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    ActivityCard(
                      title: 'Activity 2',
                      description: 'Stateful Interaction',
                      icon: Icons.touch_app,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ActivityTwoScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NetworkMonitorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.network_check),
                label: const Text('Network Monitor'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}