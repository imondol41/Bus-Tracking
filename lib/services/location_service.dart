import 'dart:html' as html;
import 'dart:async';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

class LocationService {
  static LocationData? _currentLocation;
  static bool _permissionRequested = false;
  static bool _permissionGranted = false;
  static StreamController<LocationData>? _locationController;

  /// Get current location stream
  static Stream<LocationData> get locationStream {
    _locationController ??= StreamController<LocationData>.broadcast();
    return _locationController!.stream;
  }

  /// Check if location permission is granted
  static bool get hasPermission => _permissionGranted;

  /// Get current cached location
  static LocationData? get currentLocation => _currentLocation;

  /// Request location permission and get location
  static Future<bool> requestLocationPermission() async {
    if (_permissionRequested && _permissionGranted) {
      return true;
    }

    try {
      _permissionRequested = true;
      print('Requesting location permission...');
      
      // Use the modern geolocation API
      final geolocation = html.window.navigator.geolocation;
      if (geolocation != null) {
        final completer = Completer<bool>();
        
        html.window.navigator.geolocation?.getCurrentPosition().then((position) {
          _permissionGranted = true;
          final location = LocationData(
            latitude: (position.coords?.latitude ?? 0.0).toDouble(),
            longitude: (position.coords?.longitude ?? 0.0).toDouble(),
            accuracy: position.coords?.accuracy?.toDouble(),
            timestamp: DateTime.now(),
          );
          _currentLocation = location;
          _locationController?.add(location);
          print('Location permission granted: $location');
          completer.complete(true);
        }).catchError((error) {
          print('Location permission denied: $error');
          _permissionGranted = false;
          completer.complete(false);
        });
        
        return await completer.future;
      } else {
        print('Geolocation not supported');
        _permissionGranted = false;
        return false;
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      _permissionGranted = false;
      return false;
    }
  }

  /// Get user's current location
  static Future<LocationData?> getCurrentLocation() async {
    try {
      if (!_permissionGranted) {
        final hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          return null;
        }
      }

      final completer = Completer<LocationData?>();
      
      html.window.navigator.geolocation?.getCurrentPosition().then((position) {
        final location = LocationData(
          latitude: (position.coords?.latitude ?? 0.0).toDouble(),
          longitude: (position.coords?.longitude ?? 0.0).toDouble(),
          accuracy: position.coords?.accuracy?.toDouble(),
          timestamp: DateTime.now(),
        );
        
        _currentLocation = location;
        print('Current location: $location');
        
        // Notify listeners
        _locationController?.add(location);
        
        completer.complete(location);
      }).catchError((error) {
        print('Error getting location: $error');
        completer.complete(null);
      });

      return completer.future;
    } catch (e) {
      print('Error in getCurrentLocation: $e');
      return null;
    }
  }

  /// Start watching user location (for continuous updates)
  static void startLocationUpdates() {
    if (!_permissionGranted) return;

    try {
      // Use periodic updates for better browser compatibility
      Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (!_permissionGranted) {
          timer.cancel();
          return;
        }
        
        await getCurrentLocation();
      });
    } catch (e) {
      print('Error starting location updates: $e');
    }
  }

  /// Show location permission dialog
  static Future<bool> showLocationDialog() async {
    try {
      final hasPermission = await requestLocationPermission();
      
      if (hasPermission) {
        await getCurrentLocation();
        startLocationUpdates();
      }
      
      return hasPermission;
    } catch (e) {
      print('Error in location dialog: $e');
      return false;
    }
  }

  /// Get fallback location (Dhaka center) if permission denied
  static LocationData getFallbackLocation() {
    return LocationData(
      latitude: 23.8103, // Dhaka center
      longitude: 90.4125,
      timestamp: DateTime.now(),
      address: 'Dhaka, Bangladesh (Approximate)',
    );
  }

  /// Format location for display
  static String formatLocation(LocationData location) {
    final lat = location.latitude.toStringAsFixed(4);
    final lng = location.longitude.toStringAsFixed(4);
    
    if (location.address != null) {
      return '${location.address} ($lat, $lng)';
    } else {
      return 'Location: $lat, $lng';
    }
  }

  /// Clean up resources
  static void dispose() {
    _locationController?.close();
    _locationController = null;
  }
}
