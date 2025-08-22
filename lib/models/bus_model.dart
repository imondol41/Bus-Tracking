import 'dart:math' as math;
import '../services/distance_service.dart';

class BusModel {
  final String id;
  final String busNumber;
  final String route;
  final String driver;
  final double gpsLatitude;
  final double gpsLongitude;
  final String? gpsPlusCode;
  final DateTime gpsTimestamp;
  final String? locationName;
  final bool isActive;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.route,
    required this.driver,
    required this.gpsLatitude,
    required this.gpsLongitude,
    this.gpsPlusCode,
    required this.gpsTimestamp,
    this.locationName,
    this.isActive = true,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] ?? '',
      busNumber: json['bus_number'] ?? '',
      route: json['route'] ?? '',
      driver: json['driver'] ?? '',
      gpsLatitude: (json['gps_latitude'] ?? 0.0).toDouble(),
      gpsLongitude: (json['gps_longitude'] ?? 0.0).toDouble(),
      gpsPlusCode: json['gps_plus_code'],
      gpsTimestamp: DateTime.parse(
        json['gps_timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      locationName: json['location_name'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_number': busNumber,
      'route': route,
      'driver': driver,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'gps_plus_code': gpsPlusCode,
      'gps_timestamp': gpsTimestamp.toIso8601String(),
      'location_name': locationName,
      'is_active': isActive,
    };
  }

  double distanceFromUniversity() {
    return DistanceService.calculateDistance(
      DistanceService.university.latitude,
      DistanceService.university.longitude,
      gpsLatitude,
      gpsLongitude,
    );
  }

  double distanceFromUser() {
    final userLoc = DistanceService.getUserLocation();
    return DistanceService.calculateDistance(
      userLoc.latitude,
      userLoc.longitude,
      gpsLatitude,
      gpsLongitude,
    );
  }

  DistanceInfo getDetailedDistanceFromUniversity() {
    return DistanceService.calculateUniversityToBusDistance(
      gpsLatitude,
      gpsLongitude,
    );
  }

  DistanceInfo getDetailedDistanceFromUser() {
    return DistanceService.calculateUserToBusDistance(
      gpsLatitude,
      gpsLongitude,
    );
  }
}
