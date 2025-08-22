// Import for math functions
import 'dart:math' as dart_math;
import 'lib/services/plus_code_service.dart';

void main() {
  print('Testing Plus Code Service');
  print('========================');
  
  // Test some example Plus Codes
  List<String> testCodes = [
    '7MMCR9XC+F9',  // Example Dhaka area
    '7MMCQGC2+H4',  // Example Chittagong area
    '7MMFP9X9+2R',  // Example Sylhet area
    'INVALID+CODE', // Invalid code
    '7MMC+123',     // Too short
    '',             // Empty code
  ];
  
  for (String code in testCodes) {
    print('\nTesting Plus Code: $code');
    
    if (PlusCodeService.isValidBangladeshPlusCode(code)) {
      print('✓ Valid Plus Code');
      
      Map<String, double>? coords = PlusCodeService.decodePlusCodeBangladesh(code);
      if (coords != null) {
        print('  Latitude: ${coords['latitude']!.toStringAsFixed(6)}');
        print('  Longitude: ${coords['longitude']!.toStringAsFixed(6)}');
        
        // Calculate distance from Shanto-Mariam University
        double universityLat = 23.7489;
        double universityLng = 90.3708;
        
        double distance = calculateDistance(
          universityLat, universityLng,
          coords['latitude']!, coords['longitude']!
        );
        
        print('  Distance from University: ${distance.toStringAsFixed(2)} km');
      } else {
        print('✗ Failed to decode coordinates');
      }
    } else {
      print('✗ Invalid Plus Code');
    }
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Earth radius in kilometers
  
  double dLat = toRadians(lat2 - lat1);
  double dLon = toRadians(lon2 - lon1);
  
  double a = 
      (dLat / 2).sin() * (dLat / 2).sin() +
      toRadians(lat1).cos() *
          toRadians(lat2).cos() *
          (dLon / 2).sin() *
          (dLon / 2).sin();
  
  double c = 2 * a.sqrt().atan2((1 - a).sqrt());
  
  return earthRadius * c;
}

double toRadians(double degrees) {
  return degrees * (3.14159265359 / 180);
}

extension on double {
  double sin() => dart_math.sin(this);
  double cos() => dart_math.cos(this);
  double sqrt() => dart_math.sqrt(this);
  double atan2(double x) => dart_math.atan2(this, x);
}
