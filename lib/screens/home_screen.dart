import 'package:flutter/material.dart';

import '../widgets/activity_card.dart';
import 'activity_one_screen.dart';
import 'activity_two_screen.dart';
import 'activity_five_screen.dart';
import 'network_diagnostic_screen.dart';
import 'local_mesh_chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openActivity(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

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
                final isWide = constraints.maxWidth >= 600;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 2 : 1,
                  childAspectRatio: isWide ? 3.0 : 1.0,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    ActivityCard(
                      title: 'Activity 1',
                      description: 'Portfolio & State Management',
                      icon: Icons.widgets,
                      onTap: () =>
                          _openActivity(context, const ActivityOneScreen()),
                    ),
                    ActivityCard(
                      title: 'Activity 2',
                      description: 'Stateful Interaction',
                      icon: Icons.touch_app,
                      onTap: () =>
                          _openActivity(context, const ActivityTwoScreen()),
                    ),
                    ActivityCard(
                      title: 'Activity 3',
                      description: 'Network Diagnostic',
                      icon: Icons.speed,
                      onTap: () => _openActivity(
                          context, const NetworkDiagnosticScreen()),
                    ),
                    ActivityCard(
                      title: 'Activity 4',
                      description: 'Local Mesh Chat',
                      icon: Icons.wifi_tethering,
                      onTap: () =>
                          _openActivity(context, const LocalMeshChatScreen()),
                    ),
                    ActivityCard(
                      title: 'Activity 5',
                      description: 'Geofence Tracker Map',
                      icon: Icons.map,
                      onTap: () =>
                          _openActivity(context, const ActivityFiveScreen()),
                    ),
                    ActivityCard(
                      title: 'Settings',
                      description: 'Dark / Light Theme',
                      icon: Icons.settings,
                      onTap: () =>
                          _openActivity(context, const SettingsScreen()),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
