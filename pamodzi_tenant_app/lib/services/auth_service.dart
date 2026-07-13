import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for login, logout, and session management
class AuthService {
  static const String _apiBaseUrl = 'https://api.pamodzi.zm/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In production, call actual API
      // final response = await http.post(
      //   Uri.parse('$_apiBaseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email, 'password': password}),
      // );

      // For demo: validate against hardcoded credentials
      if (email.trim().toLowerCase() == 'chanda.m@pamodzi.com' && password == 'rent2026') {
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'demo_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_userEmailKey, email);

        return AuthResult(
          success: true,
          message: 'Login successful',
          token: 'demo_token',
          userEmail: email,
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Invalid email or password',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // In production, call actual API
      // final token = await getToken();
      // final response = await http.post(
      //   Uri.parse('$_apiBaseUrl/auth/change-password'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'currentPassword': currentPassword,
      //     'newPassword': newPassword,
      //   }),
      // );

      // For demo: simulate success
      if (currentPassword == 'rent2026') {
        return AuthResult(
          success: true,
          message: 'Password changed successfully',
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Current password is incorrect',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }

  /// Request password reset
  Future<AuthResult> requestPasswordReset(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // In production, call actual API
      // final response = await http.post(
      //   Uri.parse('$_apiBaseUrl/auth/reset-password'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email}),
      // );

      return AuthResult(
        success: true,
        message: 'Password reset instructions sent to $email',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to send reset instructions: ${e.toString()}',
      );
    }
  }
}

/// Authentication result model
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? userEmail;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.userEmail,
  });
}
