import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationAwareApp extends StatefulWidget {
  final Widget child;

  const LocationAwareApp({super.key, required this.child});

  @override
  State<LocationAwareApp> createState() => _LocationAwareAppState();
}

class _LocationAwareAppState extends State<LocationAwareApp> {
  bool _locationInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Small delay to let the app fully load
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      // Request location permission silently first
      final hasPermission = await LocationService.requestLocationPermission();
      
      if (hasPermission) {
        // Get initial location
        await LocationService.getCurrentLocation();
        print('Location services initialized successfully');
      } else {
        print('Location permission not granted, using fallback');
      }
    } catch (e) {
      print('Error initializing location services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _locationInitialized = true;
        });
      }
    }
  }

  void _showLocationPermissionSnackBar() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Enable location for accurate distance tracking'),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: () async {
            final hasPermission = await LocationService.showLocationDialog();
            if (hasPermission && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location enabled! Distances will be more accurate.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the app immediately, location runs in background
    return widget.child;
  }

  @override
  void dispose() {
    LocationService.dispose();
    super.dispose();
  }
}
