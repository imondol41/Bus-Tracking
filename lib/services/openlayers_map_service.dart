import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math' as dart_math;
import 'package:http/http.dart' as http;

class OpenLayersMapService {
  static const String _openRouteServiceApiKey = 'YOUR_ORS_API_KEY'; // Get from openrouteservice.org
  static const String _osmTileUrl = 'https://{a-c}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  // University coordinates (Shanto-Mariam University)
  static const double universityLat = 23.7489;
  static const double universityLng = 90.3708;

  /// Initialize OpenLayers map in the web container
  static void initializeMap(String containerId, {
    double centerLat = universityLat,
    double centerLng = universityLng,
    double zoom = 13.0,
  }) {
    // Inject OpenLayers CSS and JS if not already loaded
    _injectOpenLayersResources();
    
    // Initialize the map
    js.context.callMethod('eval', ['''
      if (typeof ol !== 'undefined') {
        // Create map layers
        var osmLayer = new ol.layer.Tile({
          source: new ol.source.OSM({
            url: '$_osmTileUrl'
          })
        });

        // Traffic layer (using MapTiler for traffic data)
        var trafficLayer = new ol.layer.Tile({
          source: new ol.source.XYZ({
            url: 'https://api.maptiler.com/tiles/traffic/{z}/{x}/{y}.png?key=YOUR_MAPTILER_KEY',
            attributions: '© MapTiler'
          }),
          opacity: 0.7,
          visible: false  // Initially hidden
        });

        // Create vector layer for buses and routes
        var busVectorSource = new ol.source.Vector();
        var busLayer = new ol.layer.Vector({
          source: busVectorSource,
          style: function(feature) {
            if (feature.get('type') === 'bus') {
              return new ol.style.Style({
                image: new ol.style.Icon({
                  anchor: [0.5, 1],
                  src: 'data:image/svg+xml;base64,' + btoa(getBusIconSVG()),
                  scale: 0.8
                })
              });
            } else if (feature.get('type') === 'university') {
              return new ol.style.Style({
                image: new ol.style.Icon({
                  anchor: [0.5, 1],
                  src: 'data:image/svg+xml;base64,' + btoa(getUniversityIconSVG()),
                  scale: 1.0
                })
              });
            } else if (feature.get('type') === 'route') {
              var status = feature.get('trafficStatus') || 'normal';
              var color = status === 'heavy' ? '#FF4444' : 
                         status === 'moderate' ? '#FF8800' : '#4CAF50';
              return new ol.style.Style({
                stroke: new ol.style.Stroke({
                  color: color,
                  width: 4
                })
              });
            }
          }
        });

        // Create the map
        window.busTrackingMap = new ol.Map({
          target: '$containerId',
          layers: [osmLayer, trafficLayer, busLayer],
          view: new ol.View({
            center: ol.proj.fromLonLat([$centerLng, $centerLat]),
            zoom: $zoom
          })
        });

        // Add university marker
        var universityFeature = new ol.Feature({
          geometry: new ol.geom.Point(ol.proj.fromLonLat([$universityLng, $universityLat])),
          type: 'university',
          name: 'Shanto-Mariam University'
        });
        busVectorSource.addFeature(universityFeature);

        // Store references for later use
        window.busVectorSource = busVectorSource;
        window.trafficLayer = trafficLayer;

        console.log('OpenLayers map initialized successfully');
      } else {
        console.error('OpenLayers not loaded');
      }

      // Helper function to create bus icon SVG
      function getBusIconSVG() {
        return '<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">' +
               '<rect x="4" y="8" width="24" height="16" rx="2" fill="#FF6B35" stroke="#FFF" stroke-width="2"/>' +
               '<rect x="6" y="10" width="6" height="4" fill="#FFF"/>' +
               '<rect x="20" y="10" width="6" height="4" fill="#FFF"/>' +
               '<circle cx="8" cy="26" r="2" fill="#333"/>' +
               '<circle cx="24" cy="26" r="2" fill="#333"/>' +
               '<text x="16" y="18" text-anchor="middle" fill="white" font-size="8" font-weight="bold">BUS</text>' +
               '</svg>';
      }

      // Helper function to create university icon SVG
      function getUniversityIconSVG() {
        return '<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">' +
               '<rect x="6" y="12" width="20" height="12" fill="#2196F3" stroke="#FFF" stroke-width="2"/>' +
               '<polygon points="4,12 16,4 28,12" fill="#1976D2"/>' +
               '<rect x="14" y="16" width="4" height="8" fill="#FFF"/>' +
               '<rect x="8" y="16" width="3" height="3" fill="#FFF"/>' +
               '<rect x="21" y="16" width="3" height="3" fill="#FFF"/>' +
               '<text x="16" y="30" text-anchor="middle" fill="#1976D2" font-size="6" font-weight="bold">UNIV</text>' +
               '</svg>';
      }
    ''']);
  }

  /// Add or update a bus marker on the map
  static void updateBusLocation({
    required String busId,
    required String busNumber,
    required double latitude,
    required double longitude,
    required String route,
    required String driver,
    String? eta,
  }) {
    js.context.callMethod('eval', ['''
      if (window.busVectorSource) {
        // Remove existing bus marker if it exists
        var existingFeatures = window.busVectorSource.getFeatures();
        for (var i = 0; i < existingFeatures.length; i++) {
          if (existingFeatures[i].get('busId') === '$busId') {
            window.busVectorSource.removeFeature(existingFeatures[i]);
            break;
          }
        }

        // Add new bus marker
        var busFeature = new ol.Feature({
          geometry: new ol.geom.Point(ol.proj.fromLonLat([$longitude, $latitude])),
          type: 'bus',
          busId: '$busId',
          busNumber: '$busNumber',
          route: '$route',
          driver: '$driver',
          eta: '$eta'
        });

        window.busVectorSource.addFeature(busFeature);
        
        console.log('Updated bus $busNumber at [$latitude, $longitude]');
      }
    ''']);
  }

  /// Draw route between university and bus with traffic information
  static Future<void> drawRoute({
    required String busId,
    required double busLat,
    required double busLng,
    bool showTraffic = true,
  }) async {
    try {
      // Get route from OpenRouteService
      final routeData = await _getRouteData(
        startLat: universityLat,
        startLng: universityLng,
        endLat: busLat,
        endLng: busLng,
      );

      if (routeData != null) {
        final coordinates = routeData['coordinates'] as List;
        final duration = routeData['duration'] as double;
        final distance = routeData['distance'] as double;

        // Convert coordinates to OpenLayers format
        final coordsString = coordinates.map((coord) => '[${coord[0]}, ${coord[1]}]').join(',');

        js.context.callMethod('eval', ['''
          if (window.busVectorSource) {
            // Remove existing route for this bus
            var existingFeatures = window.busVectorSource.getFeatures();
            for (var i = existingFeatures.length - 1; i >= 0; i--) {
              if (existingFeatures[i].get('type') === 'route' && 
                  existingFeatures[i].get('busId') === '$busId') {
                window.busVectorSource.removeFeature(existingFeatures[i]);
              }
            }

            // Create route coordinates
            var routeCoords = [$coordsString];
            var routeLine = new ol.geom.LineString(routeCoords);
            routeLine.transform('EPSG:4326', 'EPSG:3857');

            // Determine traffic status (simplified - in real app, use traffic API)
            var trafficStatus = ${duration > 1800 ? "'heavy'" : duration > 1200 ? "'moderate'" : "'normal'"};

            var routeFeature = new ol.Feature({
              geometry: routeLine,
              type: 'route',
              busId: '$busId',
              duration: $duration,
              distance: $distance,
              trafficStatus: trafficStatus
            });

            window.busVectorSource.addFeature(routeFeature);

            // Update ETA in bus marker
            var busFeatures = window.busVectorSource.getFeatures();
            for (var i = 0; i < busFeatures.length; i++) {
              if (busFeatures[i].get('busId') === '$busId' && busFeatures[i].get('type') === 'bus') {
                busFeatures[i].set('eta', Math.round($duration / 60) + ' min');
                break;
              }
            }

            console.log('Route drawn for bus $busId - ETA: ' + Math.round($duration / 60) + ' minutes');
          }
        ''']);
      }
    } catch (e) {
      print('Error drawing route: $e');
    }
  }

  /// Focus map on specific bus
  static void focusOnBus(String busId, {double zoom = 15.0}) {
    js.context.callMethod('eval', ['''
      if (window.busVectorSource && window.busTrackingMap) {
        var features = window.busVectorSource.getFeatures();
        for (var i = 0; i < features.length; i++) {
          if (features[i].get('busId') === '$busId' && features[i].get('type') === 'bus') {
            var geometry = features[i].getGeometry();
            var coordinates = geometry.getCoordinates();
            
            window.busTrackingMap.getView().animate({
              center: coordinates,
              zoom: $zoom,
              duration: 1000
            });
            
            console.log('Focused on bus $busId');
            break;
          }
        }
      }
    ''']);
  }

  /// Show only specific bus and hide others
  static void showOnlyBus(String busId) {
    js.context.callMethod('eval', ['''
      if (window.busVectorSource) {
        var features = window.busVectorSource.getFeatures();
        for (var i = 0; i < features.length; i++) {
          var feature = features[i];
          if (feature.get('type') === 'bus') {
            // Hide all buses except the target one
            feature.setStyle(feature.get('busId') === '$busId' ? null : 
              new ol.style.Style({ image: new ol.style.Circle({ radius: 0 }) }));
          } else if (feature.get('type') === 'route') {
            // Hide all routes except for the target bus
            feature.setStyle(feature.get('busId') === '$busId' ? null :
              new ol.style.Style({ stroke: new ol.style.Stroke({ width: 0 }) }));
          }
        }
        console.log('Showing only bus $busId');
      }
    ''']);
  }

  /// Show all buses
  static void showAllBuses() {
    js.context.callMethod('eval', ['''
      if (window.busVectorSource) {
        var features = window.busVectorSource.getFeatures();
        for (var i = 0; i < features.length; i++) {
          features[i].setStyle(null); // Reset to default style
        }
        console.log('Showing all buses');
      }
    ''']);
  }

  /// Toggle traffic layer
  static void toggleTrafficLayer(bool show) {
    js.context.callMethod('eval', ['''
      if (window.trafficLayer) {
        window.trafficLayer.setVisible($show);
        console.log('Traffic layer: ${show ? 'visible' : 'hidden'}');
      }
    ''']);
  }

  /// Get route data from OpenRouteService API
  static Future<Map<String, dynamic>?> _getRouteData({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final url = 'https://api.openrouteservice.org/v2/directions/driving-car';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _openRouteServiceApiKey,
        },
        body: jsonEncode({
          'coordinates': [
            [startLng, startLat],
            [endLng, endLat],
          ],
          'format': 'geojson',
          'instructions': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['features'][0];
        final properties = route['properties'];
        final geometry = route['geometry'];

        return {
          'coordinates': geometry['coordinates'],
          'duration': properties['summary']['duration'], // in seconds
          'distance': properties['summary']['distance'], // in meters
        };
      } else {
        print('Route API error: ${response.statusCode}');
        // Fallback to simple straight line
        return _createStraightLineRoute(startLat, startLng, endLat, endLng);
      }
    } catch (e) {
      print('Route API exception: $e');
      // Fallback to simple straight line
      return _createStraightLineRoute(startLat, startLng, endLat, endLng);
    }
  }

  /// Create a simple straight line route as fallback
  static Map<String, dynamic> _createStraightLineRoute(
    double startLat, double startLng, double endLat, double endLng) {
    
    // Simple distance calculation (Haversine formula)
    const double earthRadius = 6371000; // meters
    final double dLat = (endLat - startLat) * (3.141592653589793 / 180);
    final double dLng = (endLng - startLng) * (3.141592653589793 / 180);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        startLat.toRadians().cos() * endLat.toRadians().cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final double c = 2 * (a.sqrt().atan2((1 - a).sqrt()));
    final double distance = earthRadius * c;
    
    // Estimate duration (assuming 30 km/h average speed in city)
    final double duration = (distance / 1000) * (3600 / 30);

    return {
      'coordinates': [
        [startLng, startLat],
        [endLng, endLat],
      ],
      'duration': duration,
      'distance': distance,
    };
  }

  /// Inject OpenLayers CSS and JavaScript into the page
  static void _injectOpenLayersResources() {
    // Check if already loaded
    if (js.context.hasProperty('ol')) return;

    // Inject CSS
    final cssLink = html.LinkElement()
      ..rel = 'stylesheet'
      ..href = 'https://cdn.jsdelivr.net/npm/ol@latest/ol.css';
    html.document.head!.append(cssLink);

    // Inject JavaScript
    final script = html.ScriptElement()
      ..src = 'https://cdn.jsdelivr.net/npm/ol@latest/dist/ol.js'
      ..onLoad.listen((event) {
        print('OpenLayers loaded successfully');
      });
    html.document.head!.append(script);
  }
}

// Extension for math operations
extension MathExtensions on double {
  double sin() => dart_math.sin(this);
  double cos() => dart_math.cos(this);
  double sqrt() => dart_math.sqrt(this);
  double atan2(double x) => dart_math.atan2(this, x);
  double toRadians() => this * (dart_math.pi / 180);
}
