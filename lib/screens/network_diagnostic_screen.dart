import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_diagnostic_provider.dart';

class NetworkDiagnosticScreen extends StatelessWidget {
  const NetworkDiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkDiagnosticProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostic Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.network_check,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      network.healthText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(network.currentTest),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _resultCard(
              'Idle Ping',
              network.idlePing == null
                  ? '--'
                  : '${network.idlePing!.toStringAsFixed(1)} ms',
              Icons.speed,
            ),

            _resultCard(
              'Download Speed',
              network.downloadSpeed == null
                  ? '--'
                  : '${network.downloadSpeed!.toStringAsFixed(2)} Mbps',
              Icons.download,
            ),

            _resultCard(
              'Download Ping',
              network.downloadPing == null
                  ? '--'
                  : '${network.downloadPing!.toStringAsFixed(1)} ms',
              Icons.network_ping,
            ),

            _resultCard(
              'Upload Speed',
              network.uploadSpeed == null
                  ? '--'
                  : '${network.uploadSpeed!.toStringAsFixed(2)} Mbps',
              Icons.upload,
            ),

            _resultCard(
              'Upload Ping',
              network.uploadPing == null
                  ? '--'
                  : '${network.uploadPing!.toStringAsFixed(1)} ms',
              Icons.network_ping,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: network.isTesting
                    ? null
                    : () {
                        context
                            .read<NetworkDiagnosticProvider>()
                            .runDiagnostic();
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  network.isTesting
                      ? 'Testing...'
                      : 'Run Diagnostic',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}