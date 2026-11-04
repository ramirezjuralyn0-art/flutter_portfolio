import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActivityFiveScreen extends StatefulWidget {
  const ActivityFiveScreen({super.key});

  @override
  State<ActivityFiveScreen> createState() => _ActivityFiveScreenState();
}

class _ActivityFiveScreenState extends State<ActivityFiveScreen> {
  static final LatLng _center = LatLng(8.6314, 126.1150);

  // 5 custom markers from Ban-as / Purok 3, Lianga (not on Google Maps).
  final List<Map<String, dynamic>> _spots = [
    {
      'name': 'Ramirez Store',
      'lat': 8.63123,
      'lng': 126.11568,
      'radius': 50.0,
    },
    {
      'name': 'Purok 3 Waiting Shed',
      'lat': 8.63110,
      'lng': 126.11545,
      'radius': 40.0,
    },
    {
      'name': 'Ban-as River Footpath Access',
      'lat': 8.63155,
      'lng': 126.11512,
      'radius': 45.0,
    },
    {
      'name': 'Purok 3 Communal Spillway Footbridge',
      'lat': 8.63095,
      'lng': 126.11488,
      'radius': 35.0,
    },
    {
      'name': 'Undiscovered Riverside Spring Spot',
      'lat': 8.63220,
      'lng': 126.11390,
      'radius': 40.0,
    },
  ];

  late final MapController _mapController;
  String _status = 'Checking location...';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkGeofence();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkGeofence() async {
    try {
      String inside = 'Outside all geofences';
      for (final s in _spots) {
        final dist = _distanceBetween(
          _center.latitude,
          _center.longitude,
          s['lat'] as double,
          s['lng'] as double,
        );
        if (dist <= (s['radius'] as double)) {
          inside = 'Inside: ${s['name']}';
          break;
        }
      }
      setState(() => _status = inside);
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  double _distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const pi = 3.14159265358979323846;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        0.5 -
        (cos(dLat)) / 2 +
        (cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            (1 - cos(dLon))) /
            2;
    return 12742000 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity 5 - Geofence Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_status, style: const TextStyle(fontSize: 16)),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Custom Locations (Ban-as / Purok 3, Lianga):\n'
              '• Ramirez Store — 8.63123, 126.11568\n'
              '• Purok 3 Waiting Shed — 8.63110, 126.11545\n'
              '• Ban-as River Footpath Access — 8.63155, 126.11512\n'
              '• Purok 3 Communal Spillway Footbridge — 8.63095, 126.11488\n'
              '• Undiscovered Riverside Spring Spot — 8.63220, 126.11390',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_portfolio',
                ),
                MarkerLayer(
                  markers: _spots.map((s) {
                    return Marker(
                      point: LatLng(s['lat'] as double, s['lng'] as double),
                      width: 52,
                      height: 52,
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              width: 48,
                              child: Text(
                                s['name'] as String,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
