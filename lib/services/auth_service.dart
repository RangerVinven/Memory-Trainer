import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiClient().dio;

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await _api.post(
        '/api/v1/auth/login',
        data: {
          'user': {
            'email': email,
            'password': password,
            'remember_me': rememberMe ? 1 : 0,
          },
        },
      );

      debugPrint('Login Response status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<bool> signup(String email, String password, String passwordConfirmation) async {
    try {
      final response = await _api.post(
        '/api/v1/auth/signup',
        data: {
          'user': {
            'email': email,
            'password': password,
            'password_confirmation': passwordConfirmation,
          },
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Signup Error: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get('/api/v1/auth/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      debugPrint('Get User Error: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final data = {
        'user': {
          'email': email,
          'current_password': currentPassword,
          if (password != null && password.isNotEmpty) 'password': password,
          if (passwordConfirmation != null && passwordConfirmation.isNotEmpty)
            'password_confirmation': passwordConfirmation,
        }
      };

      final response = await _api.put('/api/v1/auth/profile', data: data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return false;
    }
  }
}