import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_model.dart';

class BusTrackerProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<BusModel> _buses = [];
  BusModel? _selectedBus;
  bool _isLoading = false;
  String? _errorMessage;

  List<BusModel> get buses => _buses;
  BusModel? get selectedBus => _selectedBus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BusTrackerProvider() {
    _initializeBusTracking();
  }

  void _initializeBusTracking() {
    // Listen to real-time changes in buses table
    _supabase
        .channel('buses')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buses',
          callback: (payload) {
            _loadBuses();
          },
        )
        .subscribe();

    _loadBuses();
  }

  Future<void> _loadBuses() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('buses')
          .select()
          .eq('is_active', true)
          .order('bus_number');

      _buses = (response as List)
          .map((busData) => BusModel.fromJson(busData))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> refreshBuses() async {
    await _loadBuses();
  }

  void selectBus(BusModel bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  void clearSelectedBus() {
    _selectedBus = null;
    notifyListeners();
  }

  // Admin functions
  Future<bool> addBus({
    required String busNumber,
    required String route,
    required String driver,
    required double latitude,
    required double longitude,
    String? plusCode,
    String? locationName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.from('buses').insert({
        'bus_number': busNumber,
        'route': route,
        'driver': driver,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'gps_plus_code': plusCode,
        'gps_timestamp': DateTime.now().toIso8601String(),
        'location_name': locationName,
        'is_active': true,
      });

      await _loadBuses();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBus({
    required String busId,
    required String busNumber,
    required String route,
    required String driver,
    required double latitude,
    required double longitude,
    String? plusCode,
    String? locationName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase
          .from('buses')
          .update({
            'bus_number': busNumber,
            'route': route,
            'driver': driver,
            'gps_latitude': latitude,
            'gps_longitude': longitude,
            'gps_plus_code': plusCode,
            'gps_timestamp': DateTime.now().toIso8601String(),
            'location_name': locationName,
          })
          .eq('id', busId);

      await _loadBuses();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteBus(String busId) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase
          .from('buses')
          .update({'is_active': false})
          .eq('id', busId);

      await _loadBuses();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
    String? plusCode,
    String? locationName,
  }) async {
    try {
      await _supabase
          .from('buses')
          .update({
            'gps_latitude': latitude,
            'gps_longitude': longitude,
            'gps_plus_code': plusCode,
            'gps_timestamp': DateTime.now().toIso8601String(),
            'location_name': locationName,
          })
          .eq('id', busId);

      await _loadBuses();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  List<BusModel> getBusesNearUniversity({double maxDistanceKm = 10.0}) {
    return _buses
        .where((bus) => bus.distanceFromUniversity() <= maxDistanceKm)
        .toList();
  }

  List<BusModel> searchBuses(String query) {
    if (query.isEmpty) return _buses;

    return _buses
        .where(
          (bus) =>
              bus.busNumber.toLowerCase().contains(query.toLowerCase()) ||
              bus.route.toLowerCase().contains(query.toLowerCase()) ||
              bus.driver.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
