import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_api_models.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/data/models/auth_models.dart';

class ProfileService {
  // Backend URL - sử dụng cùng baseUrl với AuthService
  static const String baseUrl = AuthService.baseUrl;

  /// Get access token từ AuthService
  Future<String?> _getAccessToken() async {
    final authService = AuthService();
    return await authService.getAccessToken();
  }

  /// Get user profile
  Future<ProfileApiResponse> getProfile() async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/user/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          return ProfileApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Get profile error: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ProfileApiResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/user/profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
          return ProfileApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to update profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Update profile error: ${e.toString()}');
    }
  }

  /// Get user statistics
  Future<StatsApiResponse> getStats() async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/user/stats');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          return StatsApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get stats';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Get stats error: ${e.toString()}');
    }
  }

  /// Get user settings
  Future<SettingsApiResponse> getSettings() async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/user/settings');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data != null) {
          return SettingsApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get settings';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Get settings error: ${e.toString()}');
    }
  }

  /// Update user settings
  Future<SettingsApiResponse> updateSettings(UpdateSettingsRequest request) async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/user/settings');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
          return SettingsApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to update settings';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Update settings error: ${e.toString()}');
    }
  }
}
