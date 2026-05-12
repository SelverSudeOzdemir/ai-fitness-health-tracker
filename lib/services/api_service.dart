import 'package:dio/dio.dart';
import '../models/item.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    // Logging (Development)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
      ),
    );
  }

  // ==================== ITEMS ====================

  /// Tüm ürünleri getir
  Future<List<Item>> getItems() async {
    try {
      final response = await _dio.get('/api/items');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          final items = (data['data'] as List)
              .map((item) => Item.fromJson(item as Map<String, dynamic>))
              .toList();
          return items;
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// ID ile ürün getir
  Future<Item> getItemById(int id) async {
    try {
      final response = await _dio.get('/api/items/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return Item.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Yeni ürün ekle
  Future<Item> createItem(Item item) async {
    try {
      final response = await _dio.post('/api/items', data: item.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return Item.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Ürün güncelle
  Future<Item> updateItem(int id, Item item) async {
    try {
      final response = await _dio.put('/api/items/$id', data: item.toJson());

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return Item.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Ürün sil
  Future<void> deleteItem(int id) async {
    try {
      final response = await _dio.delete('/api/items/$id');

      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Ürün ara
  Future<List<Item>> searchItems(String query) async {
    try {
      final response = await _dio.get(
        '/api/items/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          final items = (data['data'] as List)
              .map((item) => Item.fromJson(item as Map<String, dynamic>))
              .toList();
          return items;
        }
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // ==================== AUTH ====================

  /// Kullanıcı kaydı
  Future<AuthResponse> register(User user) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: user.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return AuthResponse.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  /// Kullanıcı girişi
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return AuthResponse.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception(response.data['error'] ?? 'Bilinmeyen hata');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // ==================== HELPERS ====================

  /// Dio hataları işle
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Bağlantı zaman aşımı');
      case DioExceptionType.receiveTimeout:
        return Exception('Alma zaman aşımı');
      case DioExceptionType.sendTimeout:
        return Exception('Gönderme zaman aşımı');
      case DioExceptionType.badResponse:
        return Exception('Sunucu hatası: ${e.response?.statusCode}');
      case DioExceptionType.badCertificate:
        return Exception('Sertifika hatası');
      case DioExceptionType.connectionError:
        return Exception('İnternet bağlantısı bulunamadı');
      case DioExceptionType.unknown:
        return Exception('Bilinmeyen hata: ${e.message}');
      default:
        return Exception('Hata: ${e.message}');
    }
  }
}
