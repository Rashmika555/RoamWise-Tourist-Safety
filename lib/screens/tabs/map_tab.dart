import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;
  LatLng? _currentLatLng;
  bool _isLocating = true;
  String? _locationError;

  static const LatLng _fallbackCenter = LatLng(20.5937, 78.9629);
  static const double _defaultZoom = 14;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationTracking() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocating = false;
        _locationError = 'Location services are disabled. Enable GPS to continue.';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocating = false;
        _locationError = 'Location permission denied. Please allow access to show your position.';
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocating = false;
        _locationError = 'Location permission is permanently denied. Open app settings to enable it.';
      });
      return;
    }

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (!mounted) {
        return;
      }

      final initialPoint = LatLng(current.latitude, current.longitude);
      setState(() {
        _currentLatLng = initialPoint;
        _isLocating = false;
      });

      _mapController.move(initialPoint, _defaultZoom);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        if (!mounted) {
          return;
        }

        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
        });
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocating = false;
        _locationError = 'Unable to fetch your location. Check permissions and try again.';
      });
    }
  }

  void _recenterOnUser() {
    final point = _currentLatLng;
    if (point == null) {
      return;
    }
    _mapController.move(point, _defaultZoom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = _currentLatLng ?? _fallbackCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Safety Map'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB7D8FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _locationError ??
                          (_currentLatLng == null
                              ? 'Searching for your location...'
                              : 'Your live location is displayed on the map.'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: _currentLatLng == null ? 5 : _defaultZoom,
                        minZoom: 3,
                        maxZoom: 19,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.roamwise',
                        ),
                        if (_currentLatLng != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLatLng!,
                                width: 52,
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isLocating)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x55000000),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        heroTag: 'recenter_btn',
                        onPressed: _currentLatLng == null ? null : _recenterOnUser,
                        backgroundColor: const Color(0xFF0D47A1),
                        child: const Icon(Icons.gps_fixed, color: Colors.white),
                      ),
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