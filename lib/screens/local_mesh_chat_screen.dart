import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalMeshChatScreen extends StatefulWidget {
  const LocalMeshChatScreen({super.key});

  @override
  State<LocalMeshChatScreen> createState() => _LocalMeshChatScreenState();
}

class _LocalMeshChatScreenState extends State<LocalMeshChatScreen> {
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  static const String _serviceId = 'com.example.localmeshchat';

  String connectionStatus = 'Not connected';
  final List<String> _messages = [];
  final Map<String, String> _endpoints = {};
  String? _connectedEndpointId;

  final TextEditingController _messageController = TextEditingController();

  Future<void> _requestNearbyPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
      Permission.location,
    ].request();

    if (!mounted) return;
    final allGranted = statuses.values.every((s) => s.isGranted);
    setState(() {
      connectionStatus = allGranted ? 'Permissions granted' : 'Some permissions denied';
    });
    if (allGranted) {
      _startAll();
    }
  }

  Future<void> _startAll() async {
    await _startAdvertising();
    await _startDiscovery();
  }

  Future<void> _startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        'LocalMesh',
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      setState(() => connectionStatus = 'Advertising & discovering...');
    } catch (e) {
      setState(() => connectionStatus = 'Advertising error: $e');
    }
  }

  Future<void> _startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        'LocalMesh',
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          setState(() => _endpoints[id] = name);
          Nearby().requestConnection(
            'LocalMesh',
            id,
            onConnectionInitiated: _onConnectionInitiated,
            onConnectionResult: _onConnectionResult,
            onDisconnected: _onDisconnected,
          );
        },
        onEndpointLost: (id) {
          setState(() => _endpoints.remove(id));
        },
        serviceId: _serviceId,
      );
    } catch (e) {
      setState(() => connectionStatus = 'Discovery error: $e');
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          final text = utf8.decode(payload.bytes!);
          setState(() => _messages.add('$endpointId: $text'));
        }
      },
      onPayloadTransferUpdate: (_, _) {},
    );
  }

  void _onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      setState(() {
        _connectedEndpointId = id;
        connectionStatus = 'Connected to $id';
      });
    } else {
      setState(() => connectionStatus = 'Connection failed: $status');
    }
  }

  void _onDisconnected(String id) {
    setState(() {
      if (_connectedEndpointId == id) _connectedEndpointId = null;
      connectionStatus = 'Disconnected';
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _connectedEndpointId == null) return;
    final bytes = Uint8List.fromList(utf8.encode(text));
    await Nearby().sendBytesPayload(_connectedEndpointId!, bytes);
    setState(() => _messages.add('Me: $text'));
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Mesh Chat'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.wifi_tethering, size: 64),
            const SizedBox(height: 12),
            Text(connectionStatus, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _requestNearbyPermissions,
              icon: const Icon(Icons.security),
              label: const Text('Grant Nearby Permissions'),
            ),
            const SizedBox(height: 16),
            const Text('Nearby Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: _endpoints.isEmpty
                  ? const Center(child: Text('Scanning...'))
                  : ListView(
                      children: _endpoints.entries
                          .map((e) => ListTile(title: Text(e.value), subtitle: Text(e.key)))
                          .toList(),
                    ),
            ),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No messages yet.'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.message),
                        title: Text(_messages[index]),
                      ),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
