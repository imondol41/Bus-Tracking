import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../providers/bus_tracker_provider.dart';
import '../../models/bus_model.dart';
import '../../services/openlayers_map_service.dart';
import '../../services/location_service.dart';
import '../../widgets/distance_info_widget.dart';

class MapTrackerScreen extends StatefulWidget {
  final String? focusBusId;

  const MapTrackerScreen({super.key, this.focusBusId});

  @override
  State<MapTrackerScreen> createState() => _MapTrackerScreenState();
}

class _MapTrackerScreenState extends State<MapTrackerScreen> {
  BusModel? _selectedBus;
  bool _showTraffic = true;
  String? _trackingBusId;
  bool _locationPermissionRequested = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _initializeMap();
    _startLiveTracking();
  }

  Future<void> _requestLocationPermission() async {
    if (_locationPermissionRequested) return;
    
    _locationPermissionRequested = true;
    
    try {
      final hasPermission = await LocationService.showLocationDialog();
      if (hasPermission) {
        print('Location permission granted - starting location updates');
        setState(() {}); // Refresh UI to show real location
      } else {
        print('Location permission denied - using fallback location');
        _showLocationPermissionDialog();
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }

  void _showLocationPermissionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'To show accurate distances to buses, please allow location access. '
          'You can enable it in your browser settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestLocationPermission();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _initializeMap() {
    // Register the map container for Flutter Web
    ui_web.platformViewRegistry.registerViewFactory(
      'openlayers-map',
      (int viewId) {
        final div = html.DivElement()
          ..id = 'map-container-$viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none';
        
        // Initialize OpenLayers map after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            OpenLayersMapService.initializeMap('map-container-$viewId');
            _loadBusesOnMap();
            
            // Focus on specific bus if provided
            if (widget.focusBusId != null) {
              _trackBus(widget.focusBusId!);
            }
          }
        });
        
        return div;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
        ),
        title: Text(_selectedBus != null 
          ? 'Tracking Bus ${_selectedBus!.busNumber}'
          : 'Live Bus Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedBus != null)
            IconButton(
              onPressed: _stopTracking,
              icon: const Icon(Icons.close),
              tooltip: 'Stop Tracking',
            ),
          IconButton(
            onPressed: () {
              setState(() => _showTraffic = !_showTraffic);
              OpenLayersMapService.toggleTrafficLayer(_showTraffic);
            },
            icon: Icon(_showTraffic ? Icons.traffic : Icons.traffic_outlined),
            tooltip: 'Toggle Traffic',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final mapHeight = screenHeight * 0.65; // 65% for map
          final controlsHeight = screenHeight * 0.35; // 35% for controls
          
          return Column(
            children: [
              // Map container with fixed height
              SizedBox(
                height: mapHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const HtmlElementView(
                      viewType: 'openlayers-map',
                    ),
                  ),
                ),
              ),
              
              // Bus information and controls with constrained height
              SizedBox(
                height: controlsHeight,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _selectedBus != null 
                    ? _buildTrackingInfo()
                    : _buildBusList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startLiveTracking() {
    // Simulate live tracking - update every 30 seconds
    // In a real app, this would be real-time updates from GPS devices
    _updateBusLocations();
    
    // Set up periodic updates
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _updateBusLocations();
        _startLiveTracking(); // Continue the cycle
      }
    });
  }

  void _updateBusLocations() {
    final busProvider = Provider.of<BusTrackerProvider>(context, listen: false);
    
    // Simulate live movement for demo purposes
    for (var bus in busProvider.buses) {
      if (bus.isActive) {
        // Add small random movement to simulate real bus movement
        final random = DateTime.now().millisecondsSinceEpoch % 1000;
        final latOffset = (random % 20 - 10) * 0.0001; // Small random offset
        final lngOffset = (random % 30 - 15) * 0.0001;
        
        final newLat = bus.gpsLatitude + latOffset;
        final newLng = bus.gpsLongitude + lngOffset;
        
        // Update bus location on map
        OpenLayersMapService.updateBusLocation(
          busId: bus.id,
          busNumber: bus.busNumber,
          latitude: newLat,
          longitude: newLng,
          route: bus.route,
          driver: bus.driver,
        );
        
        // Draw route if this bus is being tracked
        if (_trackingBusId == bus.id) {
          OpenLayersMapService.drawRoute(
            busId: bus.id,
            busLat: newLat,
            busLng: newLng,
            showTraffic: _showTraffic,
          );
        }
      }
    }
  }

  void _loadBusesOnMap() {
    final busProvider = Provider.of<BusTrackerProvider>(context, listen: false);
    
    for (var bus in busProvider.buses) {
      if (bus.isActive) {
        OpenLayersMapService.updateBusLocation(
          busId: bus.id,
          busNumber: bus.busNumber,
          latitude: bus.gpsLatitude,
          longitude: bus.gpsLongitude,
          route: bus.route,
          driver: bus.driver,
        );
      }
    }
  }

  void _trackBus(String busId) {
    final busProvider = Provider.of<BusTrackerProvider>(context, listen: false);
    final bus = busProvider.buses.firstWhere((b) => b.id == busId);
    
    setState(() {
      _selectedBus = bus;
      _trackingBusId = busId;
    });
    
    // Show only this bus
    OpenLayersMapService.showOnlyBus(busId);
    
    // Focus on the bus
    OpenLayersMapService.focusOnBus(busId, zoom: 16.0);
    
    // Draw route from university to bus
    OpenLayersMapService.drawRoute(
      busId: busId,
      busLat: bus.gpsLatitude,
      busLng: bus.gpsLongitude,
      showTraffic: _showTraffic,
    );
  }

  void _stopTracking() {
    setState(() {
      _selectedBus = null;
      _trackingBusId = null;
    });
    
    // Show all buses
    OpenLayersMapService.showAllBuses();
  }

  Widget _buildTrackingInfo() {
    if (_selectedBus == null) return const SizedBox.shrink();
    
    final distance = _selectedBus!.distanceFromUniversity();
    final estimatedTime = (distance / 30 * 60).round(); // Assuming 30 km/h average speed
    
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Distance Information Widget
          DistanceInfoWidget(
            busLatitude: _selectedBus!.gpsLatitude,
            busLongitude: _selectedBus!.gpsLongitude,
            busNumber: _selectedBus!.busNumber,
            busLocation: _selectedBus!.locationName ?? _selectedBus!.route,
          ),
          
          // Bus Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bus ${_selectedBus!.busNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${estimatedTime}min',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.route, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedBus!.route,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Driver: ${_selectedBus!.driver}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location: ${_selectedBus!.locationName ?? "GPS Coordinates"}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _trackBus(_selectedBus!.id),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _stopTracking,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    return Consumer<BusTrackerProvider>(
      builder: (context, busProvider, child) {
        final activeBuses = busProvider.buses.where((bus) => bus.isActive).toList();
        
        if (activeBuses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active buses available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Available Buses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: activeBuses.length,
                itemBuilder: (context, index) {
                  final bus = activeBuses[index];
                  final distance = bus.distanceFromUniversity();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        'Bus ${bus.busNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            bus.route,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${distance.toStringAsFixed(1)} km away',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _trackBus(bus.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(60, 32),
                        ),
                        child: const Text('Track', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
