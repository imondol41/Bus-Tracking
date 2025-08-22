import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bus_tracker_provider.dart';
import '../../services/plus_code_service.dart';

class BusFormScreen extends StatefulWidget {
  final String? busId;

  const BusFormScreen({super.key, this.busId});

  @override
  State<BusFormScreen> createState() => _BusFormScreenState();
}

class _BusFormScreenState extends State<BusFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _routeController = TextEditingController();
  final _driverController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _plusCodeController = TextEditingController();
  final _locationNameController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.busId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadBusData();
    }
  }

  void _loadBusData() {
    final busProvider = Provider.of<BusTrackerProvider>(context, listen: false);
    final bus = busProvider.buses.firstWhere(
      (b) => b.id == widget.busId,
      orElse: () => throw Exception('Bus not found'),
    );

    _busNumberController.text = bus.busNumber;
    _routeController.text = bus.route;
    _driverController.text = bus.driver;
    _latitudeController.text = bus.gpsLatitude.toString();
    _longitudeController.text = bus.gpsLongitude.toString();
    _plusCodeController.text = bus.gpsPlusCode ?? '';
    _locationNameController.text = bus.locationName ?? '';
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _routeController.dispose();
    _driverController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _plusCodeController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/admin'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Admin Panel',
        ),
        title: Text(_isEditing ? 'Edit Bus' : 'Add New Bus'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bus Information Section
              _buildSectionCard(
                title: 'Bus Information',
                children: [
                  TextFormField(
                    controller: _busNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Bus Number',
                      prefixIcon: Icon(Icons.directions_bus),
                      hintText: 'e.g., 101, A-1, etc.',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bus number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _routeController,
                    decoration: const InputDecoration(
                      labelText: 'Route',
                      prefixIcon: Icon(Icons.route),
                      hintText: 'e.g., Dhaka to Savar',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Route is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _driverController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name',
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Enter driver name',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Driver name is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Location Information Section
              _buildSectionCard(
                title: 'Location Information',
                subtitle: 'Provide either GPS coordinates OR Plus Code',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.location_on),
                            hintText: '23.7489',
                          ),
                          validator: (value) {
                            // Check if plus code is provided
                            if (_plusCodeController.text.trim().isNotEmpty) {
                              return null; // Plus code provided, lat/lng optional
                            }
                            // If no plus code, then lat/lng is required
                            if (value?.isEmpty ?? true) {
                              return 'Required if Plus Code not provided';
                            }
                            final lat = double.tryParse(value!);
                            if (lat == null || lat < -90 || lat > 90) {
                              return 'Invalid latitude (-90 to 90)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.location_on),
                            hintText: '90.3708',
                          ),
                          validator: (value) {
                            // Check if plus code is provided
                            if (_plusCodeController.text.trim().isNotEmpty) {
                              return null; // Plus code provided, lat/lng optional
                            }
                            // If no plus code, then lat/lng is required
                            if (value?.isEmpty ?? true) {
                              return 'Required if Plus Code not provided';
                            }
                            final lng = double.tryParse(value!);
                            if (lng == null || lng < -180 || lng > 180) {
                              return 'Invalid longitude (-180 to 180)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Clear all location fields
                          _latitudeController.clear();
                          _longitudeController.clear();
                          _plusCodeController.clear();
                          _locationNameController.clear();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _plusCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Plus Code',
                      prefixIcon: Icon(Icons.qr_code),
                      hintText: 'e.g., R932+W23 Dhaka or V9PH+H48',
                      helperText: 'Alternative to GPS coordinates - supports short formats',
                    ),
                    validator: (value) {
                      // Check if coordinates are provided
                      final hasCoordinates = _latitudeController.text.trim().isNotEmpty && 
                                           _longitudeController.text.trim().isNotEmpty;
                      
                      if (!hasCoordinates && (value?.isEmpty ?? true)) {
                        return 'Provide either Plus Code or GPS coordinates';
                      }
                      
                      // If plus code is provided, validate it properly
                      if (value?.isNotEmpty ?? false) {
                        if (value!.length < 8) {
                          return 'Plus Code must be at least 8 characters';
                        }
                        
                        // Check if Plus Code format is valid
                        if (!PlusCodeService.isValidBangladeshPlusCode(value)) {
                          return 'Invalid Plus Code format or not in Bangladesh';
                        }
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Location Name (Optional)',
                      prefixIcon: Icon(Icons.place),
                      hintText: 'e.g., Dhaka Bus Station',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Location Buttons
              _buildSectionCard(
                title: 'Quick Locations',
                children: [
                  const Text(
                    'Tap to use preset locations:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLocationChip(
                        'University',
                        23.7489,
                        90.3708,
                        'Shanto-Mariam University',
                        'R9XC+F9',
                      ),
                      _buildLocationChip(
                        'Dhaka Central',
                        23.7644,
                        90.3849,
                        'Dhaka Central Station',
                        'QV7M+GH',
                      ),
                      _buildLocationChip(
                        'Savar',
                        23.8583,
                        90.2667,
                        'Savar Bus Stand',
                        'V758+8R',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Plus Code Examples:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPlusCodeChip('R9XC+F9 Dhaka'),
                      _buildPlusCodeChip('QV7M+GH Dhaka'), 
                      _buildPlusCodeChip('V758+8R Savar'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBus,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Bus' : 'Add Bus'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(
    String label,
    double latitude,
    double longitude,
    String locationName,
    String plusCode,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _latitudeController.text = latitude.toString();
        _longitudeController.text = longitude.toString();
        _locationNameController.text = locationName;
        _plusCodeController.text = plusCode;
      },
    );
  }

  Widget _buildPlusCodeChip(String plusCode) {
    return ActionChip(
      label: Text(plusCode),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onPressed: () {
        _plusCodeController.text = plusCode;
        // Clear coordinates when using Plus Code
        _latitudeController.clear();
        _longitudeController.clear();
      },
    );
  }

  Future<void> _saveBus() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    final busProvider = Provider.of<BusTrackerProvider>(context, listen: false);

    // Handle coordinates - use provided coordinates or decode Plus Code
    double latitude = 0.0;
    double longitude = 0.0;
    String? errorMessage;
    
    if (_latitudeController.text.trim().isNotEmpty && 
        _longitudeController.text.trim().isNotEmpty) {
      // Use provided coordinates
      latitude = double.parse(_latitudeController.text);
      longitude = double.parse(_longitudeController.text);
    } else if (_plusCodeController.text.trim().isNotEmpty) {
      // Decode Plus Code to get actual coordinates
      Map<String, double>? coordinates = PlusCodeService.decodePlusCodeBangladesh(
        _plusCodeController.text.trim()
      );
      
      if (coordinates != null) {
        latitude = coordinates['latitude']!;
        longitude = coordinates['longitude']!;
        
        // Show success message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Plus Code decoded: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Plus Code decoding failed
        errorMessage = 'Invalid Plus Code format. Please check and try again.';
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } else {
      // Neither coordinates nor Plus Code provided
      errorMessage = 'Please provide either GPS coordinates or a Plus Code.';
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    bool success;

    if (_isEditing) {
      success = await busProvider.updateBus(
        busId: widget.busId!,
        busNumber: _busNumberController.text.trim(),
        route: _routeController.text.trim(),
        driver: _driverController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        plusCode: _plusCodeController.text.trim().isEmpty
            ? null
            : _plusCodeController.text.trim(),
        locationName: _locationNameController.text.trim().isEmpty
            ? null
            : _locationNameController.text.trim(),
      );
    } else {
      success = await busProvider.addBus(
        busNumber: _busNumberController.text.trim(),
        route: _routeController.text.trim(),
        driver: _driverController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        plusCode: _plusCodeController.text.trim().isEmpty
            ? null
            : _plusCodeController.text.trim(),
        locationName: _locationNameController.text.trim().isEmpty
            ? null
            : _locationNameController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Bus updated successfully' : 'Bus added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/admin');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(busProvider.errorMessage ?? 'Operation failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
