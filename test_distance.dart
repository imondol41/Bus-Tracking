import 'dart:math' as math;

// Test the distance calculation fix
void main() {
  print('Testing Distance Calculation Fix...\n');
  
  // University coordinates: 23.7489, 90.3708
  const double uniLat = 23.7489;
  const double uniLng = 90.3708;
  
  // Test bus locations
  final testLocations = [
    {'name': 'Same location (University)', 'lat': 23.7489, 'lng': 90.3708},
    {'name': 'Dhaka Central', 'lat': 23.7644, 'lng': 90.3849},
    {'name': 'Savar', 'lat': 23.8583, 'lng': 90.2667},
    {'name': 'Far location', 'lat': 24.0000, 'lng': 91.0000},
  ];
  
  for (var location in testLocations) {
    double distance = calculateDistance(
      uniLat, uniLng, 
      location['lat']! as double, 
      location['lng']! as double
    );
    
    print('${location['name']}: ${distance.toStringAsFixed(2)} km');
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Earth radius in kilometers

  double dLat = toRadians(lat2 - lat1);
  double dLon = toRadians(lon2 - lon1);

  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRadians(lat1)) *
          math.cos(toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c;
}

double toRadians(double degrees) {
  return degrees * (math.pi / 180);
}
