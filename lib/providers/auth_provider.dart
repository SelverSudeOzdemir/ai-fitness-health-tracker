import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  late Dio _dio;

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Login: $email');

      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          _currentUser = data['data'] as Map<String, dynamic>;
          _isLoading = false;
          _error = null;
          print('✅ Login başarılı!');
          notifyListeners();
          return true;
        }
      }

      _error = 'Giriş başarısız';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _error = 'Hata: ${e.message}';
      _isLoading = false;
      print('❌ Error: $_error');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Hata: $e';
      _isLoading = false;
      print('❌ Error: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Register: $email');

      final response = await _dio.post(
        '/api/auth/signup',
        data: {'email': email, 'password': password},
      );

      print('✅ Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          _currentUser = data['data'] as Map<String, dynamic>;
          _isLoading = false;
          _error = null;
          print('✅ Register başarılı!');
          notifyListeners();
          return true;
        }
      }

      _error = 'Kayıt başarısız';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Hata: $e';
      _isLoading = false;
      print('❌ Error: $_error');
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
