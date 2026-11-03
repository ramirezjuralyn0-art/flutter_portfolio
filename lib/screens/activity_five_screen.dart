import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ActivityFiveScreen extends StatefulWidget {
  const ActivityFiveScreen({super.key});

  @override
  State<ActivityFiveScreen> createState() => _ActivityFiveScreenState();
}

class _ActivityFiveScreenState extends State<ActivityFiveScreen> {
  static const LatLng _center = LatLng(8.6445, 126.0891);

  // Undiscovered spots near Banahao, Lianga (5 custom markers not on Google Maps).
  final List<Map<String, dynamic>> _spots = [
    {'name': 'Banahao (Sanchez Store)', 'lat': 8.6445, 'lng': 126.0891, 'radius': 30.0},
    {'name': 'Undiscovered Spot 2', 'lat': 8.6553, 'lng': 126.0900, 'radius': 40.0},
    {'name': 'Undiscovered Spot 3', 'lat': 8.6400, 'lng': 126.0950, 'radius': 40.0},
    {'name': 'Undiscovered Spot 4', 'lat': 8.6500, 'lng': 126.0850, 'radius': 40.0},
    {'name': 'Undiscovered Spot 5', 'lat': 8.6380, 'lng': 126.0830, 'radius': 40.0},
  ];

  Set<Marker> _markers = {};
  String _status = 'Checking location...';

  @override
  void initState() {
    super.initState();
    _markers = _spots.map((s) {
      return Marker(
        markerId: MarkerId(s['name'] as String),
        position: LatLng(s['lat'] as double, s['lng'] as double),
        infoWindow: InfoWindow(title: s['name'] as String),
      );
    }).toSet();
    _checkGeofence();
  }

  Future<void> _checkGeofence() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        setState(() => _status = 'Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      String inside = 'Outside all geofences';
      for (final s in _spots) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
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
          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  const CameraPosition(target: _center, zoom: 15),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}
