import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Backend URL - Update this if your backend runs on different host/port
  // For Android emulator: use 'http://10.0.2.2:8000/api/v1'
  // For iOS simulator: use 'http://localhost:8000/api/v1'
  // For physical device: use your computer's IP address, e.g., 'http://192.168.1.100:8000/api/v1'
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // SharedPreferences keys
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        // Registration successful, but we need to login to get tokens
        // For now, return the user data
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          final user = UserModel.fromJson(apiResponse.data!);
          // After registration, user should login to get tokens
          // For now, we'll return empty tokens
          final tokens = TokenModel(
            accessToken: '',
            refreshToken: '',
            tokenType: 'bearer',
            expiresIn: 0,
          );

          return AuthResponse(user: user, tokens: tokens);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ?? 
            jsonResponse['detail'] as String? ?? 
            'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          final data = apiResponse.data!;
          final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          final tokens = TokenModel.fromJson(data['tokens'] as Map<String, dynamic>);

          // Save tokens and user data
          await _saveAuthData(tokens, user);

          return AuthResponse(user: user, tokens: tokens);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ?? 
            jsonResponse['detail'] as String? ?? 
            'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          return UserModel.fromJson(apiResponse.data!);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(TokenModel tokens, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, tokens.accessToken);
    await prefs.setString(_refreshTokenKey, tokens.refreshToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgot-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>?,
        );
        
        // In debug mode, token might be returned
        if (apiResponse.data != null && apiResponse.data!['reset_token'] != null) {
          // Store token for testing (in production, this would come from email link)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('reset_token', apiResponse.data!['reset_token'] as String);
        }
        
        // Always return success (don't reveal if email exists)
        return;
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to send reset link';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Forgot password error: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final url = Uri.parse('$baseUrl/auth/reset-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return;
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to reset password';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Reset password error: ${e.toString()}');
    }
  }

  /// Get stored reset token (for testing in debug mode)
  Future<String?> getResetToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reset_token');
  }
}


