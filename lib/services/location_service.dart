import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService with ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;
  bool _permissionDenied = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionDenied => _permissionDenied;
  
  static const String PREF_LAT_KEY = 'user_latitude';
  static const String PREF_LNG_KEY = 'user_longitude';
  static const String PREF_ADDR_KEY = 'user_address';

  LocationService() {
    _loadSavedLocation();
  }
  
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(PREF_LAT_KEY);
      final lng = prefs.getDouble(PREF_LNG_KEY);
      final address = prefs.getString(PREF_ADDR_KEY);
      
      if (lat != null && lng != null) {
        _currentPosition = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _currentAddress = address;
        notifyListeners();
      }
    } catch (e) {
      // Silently handle error, will try to get actual location
    }
  }

  Future<void> _saveLocation(Position position, String? address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(PREF_LAT_KEY, position.latitude);
      await prefs.setDouble(PREF_LNG_KEY, position.longitude);
      if (address != null) {
        await prefs.setString(PREF_ADDR_KEY, address);
      }
    } catch (e) {
      // Silently handle error
    }
  }

  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    _error = null;
    _permissionDenied = false;
    notifyListeners();
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _permissionDenied = true;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _permissionDenied = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getCurrentLocation() async {
    if (_permissionDenied) return false;
    
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      
      // Use a geocoding service here to get the address from lat/lng
      // For simplicity, we'll set a placeholder
      _currentAddress = "Current Location";
      
      _saveLocation(position, _currentAddress);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setManualLocation(double latitude, double longitude, String address) async {
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    _currentAddress = address;
    
    await _saveLocation(_currentPosition!, address);
    notifyListeners();
  }
  
  double? getDistanceToEvent(double eventLat, double eventLng) {
    if (_currentPosition == null) return null;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      eventLat,
      eventLng,
    );
  }
  
  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'Unknown distance';
    
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}