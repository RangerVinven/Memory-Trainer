import 'package:flutter/foundation.dart';
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
}
