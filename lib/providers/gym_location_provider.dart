import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../services/gym_location_service.dart';

class GymLocationProvider extends ChangeNotifier {
  final GymLocationService _gymService = GymLocationService();

  List<Gym> _allGyms = [];
  List<Gym> _nearbyGyms = [];
  List<Gym> _favoriteGyms = [];
  Gym? _selectedGym;
  bool _isLoading = false;
  String? _error;

  double? _userLatitude;
  double? _userLongitude;
  double _searchRadius = 10.0;

  // Getters
  List<Gym> get allGyms => _allGyms;
  List<Gym> get nearbyGyms => _nearbyGyms;
  List<Gym> get favoriteGyms => _favoriteGyms;
  Gym? get selectedGym => _selectedGym;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get searchRadius => _searchRadius;

  // Fetch all gyms
  Future<void> fetchAllGyms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allGyms = await _gymService.getAllGyms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch nearby gyms based on user location
  Future<void> fetchNearbyGyms(
    double latitude,
    double longitude, {
    double radius = 10.0,
  }) async {
    _isLoading = true;
    _error = null;
    _userLatitude = latitude;
    _userLongitude = longitude;
    _searchRadius = radius;
    notifyListeners();

    try {
      final response = await _gymService.getNearbyGyms(
        latitude,
        longitude,
        radius: radius,
      );
      _nearbyGyms = response.gyms;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a gym to view details
  Future<void> selectGym(int gymId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedGym = await _gymService.getGymDetails(gymId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a review to a gym
  Future<void> addGymReview(
    int gymId,
    int userId,
    int rating,
    String? reviewText,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _gymService.addGymReview(gymId, userId, rating, reviewText);
      // Refresh gym details to update reviews and rating
      await selectGym(gymId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user's favorite gyms
  Future<void> fetchFavoriteGyms(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favoriteGyms = await _gymService.getUserFavoriteGyms(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add gym to favorites
  Future<void> addToFavorites(int userId, int gymId) async {
    try {
      await _gymService.addGymToFavorites(userId, gymId);
      // Update selected gym's favorite status
      if (_selectedGym != null && _selectedGym!.id == gymId) {
        await selectGym(gymId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove gym from favorites
  Future<void> removeFromFavorites(int userId, int gymId) async {
    try {
      await _gymService.removeGymFromFavorites(userId, gymId);
      // Update selected gym's favorite status
      if (_selectedGym != null && _selectedGym!.id == gymId) {
        await selectGym(gymId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update search radius
  void updateSearchRadius(double newRadius) {
    _searchRadius = newRadius;
    notifyListeners();
  }

  // Check if a gym is in favorites
  bool isGymFavorited(int gymId) {
    return _favoriteGyms.any((gym) => gym.id == gymId);
  }

  // Calculate distance between user and a gym
  double? calculateDistance(Gym gym) {
    if (_userLatitude == null || _userLongitude == null) return null;

    return _calculateHaversineDistance(
      _userLatitude!,
      _userLongitude!,
      gym.latitude,
      gym.longitude,
    );
  }

  // Haversine formula to calculate distance between two points
  double _calculateHaversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2));

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
