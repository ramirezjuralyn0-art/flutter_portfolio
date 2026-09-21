import 'dart:io';

import 'package:flutter/foundation.dart';

enum NetworkHealth {
  excellent,
  fair,
  poor,
  degraded,
}

class NetworkDiagnosticProvider extends ChangeNotifier {
  double? idlePing;
  double? downloadSpeed;
  double? downloadPing;
  double? uploadSpeed;
  double? uploadPing;

  String currentTest = 'Ready';
  bool isTesting = false;

  NetworkHealth? health;

  String get healthText {
    switch (health) {
      case NetworkHealth.excellent:
        return 'Excellent';

      case NetworkHealth.fair:
        return 'Fair';

      case NetworkHealth.poor:
        return 'Poor';

      case NetworkHealth.degraded:
        return 'Degraded';

      case null:
        return 'Not Tested';
    }
  }

  // Measures network latency using a TCP connection.
  Future<double?> measurePing() async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect(
        'google.com',
        80,
        timeout: const Duration(seconds: 5),
      );

      stopwatch.stop();

      await socket.close();

      return stopwatch.elapsedMilliseconds.toDouble();
    } catch (e) {
      return null;
    }
  }

  // Measures download speed.
  Future<({double speedMbps, double pingMs})>
      measureDownloadSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect(
        'speedtest.wdc01.softlayer.com',
        80,
        timeout: const Duration(seconds: 10),
      );

      final request =
          'GET /download/10MB.zip HTTP/1.1\r\n'
          'Host: speedtest.wdc01.softlayer.com\r\n'
          'Connection: close\r\n\r\n';

      socket.write(request);
      await socket.flush();

      int totalBytes = 0;

      final pingStart = Stopwatch()..start();

      await for (final data in socket) {
        totalBytes += data.length;

        if (pingStart.isRunning) {
          pingStart.stop();
        }
      }

      stopwatch.stop();

      await socket.close();

      final seconds =
          stopwatch.elapsedMilliseconds / 1000.0;

      if (totalBytes <= 0 || seconds <= 0) {
        return (
          speedMbps: 0.0,
          pingMs: pingStart.elapsedMilliseconds.toDouble(),
        );
      }

      final speedMbps =
          (totalBytes * 8.0) /
          seconds /
          1000000.0;

      return (
        speedMbps: speedMbps,
        pingMs: pingStart.elapsedMilliseconds.toDouble(),
      );
    } catch (e) {
      return (
        speedMbps: 0.0,
        pingMs: 0.0,
      );
    }
  }

  Future<void> runDiagnostic() async {
    isTesting = true;
    health = null;
    currentTest = 'Starting diagnostic...';

    notifyListeners();

    // -----------------------------
    // IDLE PING TEST
    // -----------------------------

    currentTest = 'Testing idle ping...';

    notifyListeners();

    final pingResult = await measurePing();

    idlePing = pingResult;

    // -----------------------------
    // DOWNLOAD TEST
    // -----------------------------

    currentTest = 'Testing download speed...';

    notifyListeners();

    final downloadResult =
        await measureDownloadSpeed();

    downloadSpeed = downloadResult.speedMbps;
    downloadPing = downloadResult.pingMs;

    // -----------------------------
    // UPLOAD TEST
    // -----------------------------

    currentTest = 'Testing upload speed...';

    notifyListeners();

    // Temporary upload test
    // We will replace this with a real upload test next.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    uploadSpeed = 6.5;
    uploadPing = 35.0;

    // -----------------------------
    // ANALYZE NETWORK HEALTH
    // -----------------------------

    _analyzeHealth();

    currentTest = 'Diagnostic complete';
    isTesting = false;

    notifyListeners();
  }

  void _analyzeHealth() {
    // Degraded connection
    if ((idlePing ?? 0.0) > 300.0 ||
        (downloadPing ?? 0.0) > 300.0 ||
        (uploadPing ?? 0.0) > 300.0) {
      health = NetworkHealth.degraded;
      return;
    }

    // Excellent: above 10 Mbps
    if ((downloadSpeed ?? 0.0) > 10.0) {
      health = NetworkHealth.excellent;
    }

    // Fair: 2–10 Mbps
    else if ((downloadSpeed ?? 0.0) >= 2.0) {
      health = NetworkHealth.fair;
    }

    // Poor: below 2 Mbps
    else {
      health = NetworkHealth.poor;
    }
  }
}