import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../services/network_monitor_service.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() =>
      _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final NetworkMonitorService _networkService =
      NetworkMonitorService();

  StreamSubscription<ConnectivityResult>? _networkSubscription;

  ConnectivityResult _currentNetwork = ConnectivityResult.none;

  final List<String> _events = [];

  int _pendingRequests = 0;

  bool _requestRunning = false;
  bool _requestQueued = false;

  @override
  void initState() {
    super.initState();

    _initializeNetwork();

    _networkService.startMonitoring();

    _networkSubscription =
        _networkService.networkStream.listen((network) {
      if (!mounted) return;

      setState(() {
        _currentNetwork = network;

        _events.insert(
          0,
          '${_getTime()} - Network changed to ${_getNetworkName(network)}',
        );
      });

      // Automatically retry queued request
      // when a connection becomes available.
      if (network != ConnectivityResult.none &&
          _requestQueued) {
        _retryQueuedRequest();
      }
    });
  }

  Future<void> _initializeNetwork() async {
    final network =
        await _networkService.checkCurrentNetwork();

    if (!mounted) return;

    setState(() {
      _currentNetwork = network;

      _events.insert(
        0,
        '${_getTime()} - Current network: ${_getNetworkName(network)}',
      );
    });
  }

  // Simulates a long-running network request.
  Future<void> _simulateLongRequest() async {
    if (_requestRunning) return;

    setState(() {
      _requestRunning = true;
    });

    _addEvent('Long-running request started');

    // Simulate a request that takes 10 seconds.
    await Future.delayed(
      const Duration(seconds: 10),
    );

    if (!mounted) return;

    // If connection was lost, queue the request.
    if (_currentNetwork == ConnectivityResult.none) {
      setState(() {
        _requestRunning = false;
        _requestQueued = true;
        _pendingRequests++;
      });

      _addEvent(
        'Connection lost - request added to queue',
      );

      return;
    }

    // Request succeeded.
    setState(() {
      _requestRunning = false;
    });

    _addEvent(
      'Request completed successfully',
    );
  }

  // Retry the queued request when connection returns.
  Future<void> _retryQueuedRequest() async {
    if (!_requestQueued || _requestRunning) return;

    setState(() {
      _requestQueued = false;

      if (_pendingRequests > 0) {
        _pendingRequests--;
      }

      _requestRunning = true;
    });

    _addEvent(
      'Connection restored - retrying queued request',
    );

    // Simulate request recovery.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    setState(() {
      _requestRunning = false;
    });

    _addEvent(
      'Queued request completed successfully',
    );
  }

  void _addEvent(String message) {
    if (!mounted) return;

    setState(() {
      _events.insert(
        0,
        '${_getTime()} - $message',
      );
    });
  }

  String _getNetworkName(
    ConnectivityResult network,
  ) {
    switch (network) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';

      case ConnectivityResult.mobile:
        return 'Cellular';

      case ConnectivityResult.none:
        return 'Offline';

      case ConnectivityResult.ethernet:
        return 'Ethernet';

      case ConnectivityResult.bluetooth:
        return 'Bluetooth';

      case ConnectivityResult.vpn:
        return 'VPN';

      default:
        return 'Unknown';
    }
  }

  IconData _getNetworkIcon() {
    switch (_currentNetwork) {
      case ConnectivityResult.wifi:
        return Icons.wifi;

      case ConnectivityResult.mobile:
        return Icons.signal_cellular_alt;

      case ConnectivityResult.none:
        return Icons.signal_wifi_off;

      default:
        return Icons.network_check;
    }
  }

  Color _getStatusColor() {
    if (_currentNetwork == ConnectivityResult.none) {
      return Colors.red;
    }

    return Colors.green;
  }

  String _getTime() {
    final now = DateTime.now();

    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _networkService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkName =
        _getNetworkName(_currentNetwork);

    final isConnected =
        _currentNetwork != ConnectivityResult.none;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Monitor'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            // ==========================
            // CURRENT NETWORK
            // ==========================

            Card(
              elevation: 3,

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [

                    Icon(
                      _getNetworkIcon(),
                      size: 70,
                      color: _getStatusColor(),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Current Active Network',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      networkName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isConnected
                          ? 'Connected'
                          : 'Offline',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================
            // REQUEST QUEUE
            // ==========================

            Card(
              elevation: 3,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Request Queue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Pending Requests: $_pendingRequests',
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _requestRunning
                          ? 'Status: Request Running'
                          : _requestQueued
                              ? 'Status: Request Queued'
                              : 'Status: Idle',
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed:
                            _requestRunning
                                ? null
                                : _simulateLongRequest,

                        icon: const Icon(
                          Icons.cloud_download,
                        ),

                        label: const Text(
                          'Simulate Long Request',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================
            // NETWORK EVENTS
            // ==========================

            Card(
              elevation: 3,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Network Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (_events.isEmpty)
                      const Text(
                        'No network events yet.',
                      )
                    else
                      ..._events.take(10).map(
                        (event) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(event),
                                ),
                              ],
                            ),
                          );
                        },
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