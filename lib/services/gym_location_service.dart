import 'package:dio/dio.dart';
import '../utils/constants.dart';

class GymLocationService {
  late Dio _dio;

  GymLocationService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // Get all gyms
  Future<List<Gym>> getAllGyms() async {
    try {
      final response = await _dio.get('/api/gyms');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          final gyms = (data['data'] as List)
              .map((gym) => Gym.fromJson(gym as Map<String, dynamic>))
              .toList();
          return gyms;
        }
      }
      throw Exception(response.data['error'] ?? 'Unknown error');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get nearby gyms with radius in km
  Future<NearbyGymsResponse> getNearbyGyms(
    double latitude,
    double longitude, {
    double radius = 10.0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/gyms/nearby',
        queryParameters: {'lat': latitude, 'lng': longitude, 'radius': radius},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final gyms = (data['data'] as List)
              .map((gym) => Gym.fromJson(gym as Map<String, dynamic>))
              .toList();

          return NearbyGymsResponse(
            gyms: gyms,
            userLat: double.parse(data['userLocation']['latitude'].toString()),
            userLng: double.parse(data['userLocation']['longitude'].toString()),
            radius: double.parse(data['radius'].toString()),
          );
        }
      }
      throw Exception(response.data['error'] ?? 'Unknown error');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get gym details with reviews
  Future<Gym> getGymDetails(int gymId) async {
    try {
      final response = await _dio.get('/api/gyms/$gymId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return Gym.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Unknown error');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add gym review
  Future<Map<String, dynamic>> addGymReview(
    int gymId,
    int userId,
    int rating,
    String? reviewText,
  ) async {
    try {
      final response = await _dio.post(
        '/api/gyms/$gymId/reviews',
        data: {'user_id': userId, 'rating': rating, 'review_text': reviewText},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception(response.data['error'] ?? 'Unknown error');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user's favorite gyms
  Future<List<Gym>> getUserFavoriteGyms(int userId) async {
    try {
      final response = await _dio.get('/api/users/$userId/favorites');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          final gyms = (data['data'] as List)
              .map((gym) => Gym.fromJson(gym as Map<String, dynamic>))
              .toList();
          return gyms;
        }
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add gym to favorites
  Future<void> addGymToFavorites(int userId, int gymId) async {
    try {
      final response = await _dio.post('/api/users/$userId/favorites/$gymId');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to add to favorites');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Remove gym from favorites
  Future<void> removeGymFromFavorites(int userId, int gymId) async {
    try {
      final response = await _dio.delete('/api/users/$userId/favorites/$gymId');

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Failed to remove from favorites',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Helper method to handle Dio exceptions
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      case DioExceptionType.unknown:
        return Exception('Unknown error: ${e.message}');
      default:
        return Exception('Error: ${e.message}');
    }
  }
}

// Models
class Gym {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;
  final List<String>? amenities;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;
  final List<GymReview>? reviews;

  Gym({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.amenities,
    this.rating,
    this.reviewCount,
    this.imageUrl,
    this.reviews,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    List<String> amenities = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        amenities = List<String>.from(json['amenities']);
      } else if (json['amenities'] is String) {
        amenities = (json['amenities'] as String)
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(',');
      }
    }

    List<GymReview> reviews = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = (json['reviews'] as List)
          .map((r) => GymReview.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return Gym(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      openingHours: json['opening_hours'] as String?,
      amenities: amenities,
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      reviewCount: json['review_count'] as int?,
      imageUrl: json['image_url'] as String?,
      reviews: reviews,
    );
  }
}

class GymReview {
  final int id;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;

  GymReview({
    required this.id,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory GymReview.fromJson(Map<String, dynamic> json) {
    return GymReview(
      id: json['id'] as int,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NearbyGymsResponse {
  final List<Gym> gyms;
  final double userLat;
  final double userLng;
  final double radius;

  NearbyGymsResponse({
    required this.gyms,
    required this.userLat,
    required this.userLng,
    required this.radius,
  });
}
