import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class DistanceInfo {
  final double distanceKm;
  final int estimatedTimeMinutes;
  final String routeType;
  final String description;
  final DateTime lastUpdated;

  const DistanceInfo({
    required this.distanceKm,
    required this.estimatedTimeMinutes,
    required this.routeType,
    required this.description,
    required this.lastUpdated,
  });
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String name;
  final String type; // 'user', 'university', 'bus'

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.type,
  });
}

class DistanceService {
  // Shanto-Mariam University coordinates
  static const LocationInfo university = LocationInfo(
    latitude: 23.7489,
    longitude: 90.3708,
    name: 'Shanto-Mariam University',
    type: 'university',
  );

  // Get current user location (real or fallback)
  static LocationInfo getUserLocation() {
    final currentLocation = LocationService.currentLocation;
    if (currentLocation != null) {
      return LocationInfo(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        name: 'Your Current Location',
        type: 'user',
      );
    } else {
      // Fallback to Dhaka center if location not available
      return const LocationInfo(
        latitude: 23.8103,
        longitude: 90.4125,
        name: 'Your Location (Approximate)',
        type: 'user',
      );
    }
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate detailed distance information for user to bus
  static DistanceInfo calculateUserToBusDistance(
    double busLat,
    double busLng,
  ) {
    final userLoc = getUserLocation();
    final distance = calculateDistance(
      userLoc.latitude,
      userLoc.longitude,
      busLat,
      busLng,
    );

    // Estimate time based on average speed in Dhaka traffic (15-20 km/h)
    final estimatedTime = (distance / 18 * 60).round(); // 18 km/h average

    return DistanceInfo(
      distanceKm: distance,
      estimatedTimeMinutes: estimatedTime,
      routeType: 'You → Bus',
      description: 'Distance from your location to the bus',
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate detailed distance information for university to bus
  static DistanceInfo calculateUniversityToBusDistance(
    double busLat,
    double busLng,
  ) {
    final distance = calculateDistance(
      university.latitude,
      university.longitude,
      busLat,
      busLng,
    );

    // Estimate time based on average speed (20-25 km/h for university routes)
    final estimatedTime = (distance / 22 * 60).round(); // 22 km/h average

    return DistanceInfo(
      distanceKm: distance,
      estimatedTimeMinutes: estimatedTime,
      routeType: 'University → Bus',
      description: 'Distance from university to the bus',
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate detailed distance information for user to university
  static DistanceInfo calculateUserToUniversityDistance() {
    final userLoc = getUserLocation();
    final distance = calculateDistance(
      userLoc.latitude,
      userLoc.longitude,
      university.latitude,
      university.longitude,
    );

    // Estimate time based on average speed
    final estimatedTime = (distance / 20 * 60).round(); // 20 km/h average

    return DistanceInfo(
      distanceKm: distance,
      estimatedTimeMinutes: estimatedTime,
      routeType: 'You → University',
      description: 'Distance from your location to university',
      lastUpdated: DateTime.now(),
    );
  }

  /// Get comprehensive distance information for a bus
  static Map<String, DistanceInfo> getComprehensiveDistanceInfo(
    double busLat,
    double busLng,
  ) {
    return {
      'userToBus': calculateUserToBusDistance(busLat, busLng),
      'universityToBus': calculateUniversityToBusDistance(busLat, busLng),
      'userToUniversity': calculateUserToUniversityDistance(),
    };
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Format time for display
  static String formatTime(int minutes) {
    if (minutes < 60) {
      return '~$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '~${hours}h';
      } else {
        return '~${hours}h ${remainingMinutes}m';
      }
    }
  }

  /// Attempt to get more accurate routing information from external API
  static Future<DistanceInfo?> getRoutingInfo({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required String routeType,
  }) async {
    try {
      // Using OpenRouteService API (free tier available)
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?'
        'api_key=YOUR_API_KEY&'
        'start=$fromLng,$fromLat&'
        'end=$toLng,$toLat',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['features'][0]['properties']['segments'][0];
        
        return DistanceInfo(
          distanceKm: route['distance'] / 1000,
          estimatedTimeMinutes: (route['duration'] / 60).round(),
          routeType: routeType,
          description: 'Real-time routing data',
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      print('Routing API error: $e');
    }

    // Fallback to Haversine calculation
    final distance = calculateDistance(fromLat, fromLng, toLat, toLng);
    return DistanceInfo(
      distanceKm: distance,
      estimatedTimeMinutes: (distance / 20 * 60).round(),
      routeType: routeType,
      description: 'Straight-line distance (estimated)',
      lastUpdated: DateTime.now(),
    );
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
