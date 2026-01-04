import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/report_api_models.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/data/models/auth_models.dart';

class ReportService {
  // Backend URL - sử dụng cùng baseUrl với AuthService
  static const String baseUrl = AuthService.baseUrl;

  /// Get access token từ AuthService
  Future<String?> _getAccessToken() async {
    final authService = AuthService();
    return await authService.getAccessToken();
  }

  /// Tạo report mới với ảnh
  Future<ReportApiResponse> createReport(
    ReportCreateRequest request, {
    List<File>? images,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/reports');
      
      // Tạo multipart request
      final requestMultipart = http.MultipartRequest('POST', url);
      
      // Thêm headers
      requestMultipart.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Thêm form fields
      requestMultipart.fields.addAll({
        'type': request.type,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        'severity': request.severity,
      });

      if (request.description != null && request.description!.isNotEmpty) {
        requestMultipart.fields['description'] = request.description!;
      }
      if (request.address != null && request.address!.isNotEmpty) {
        requestMultipart.fields['address'] = request.address!;
      }

      // Thêm images nếu có
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          final imageFile = images[i];
          final fileExtension = imageFile.path.split('.').last;
          
          // Determine content type based on extension
          String contentType;
          if (fileExtension == 'png') {
            contentType = 'image/png';
          } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
            contentType = 'image/jpeg';
          } else {
            contentType = 'image/jpeg'; // default
          }
          
          // Read file bytes
          final fileBytes = await imageFile.readAsBytes();
          
          // Create multipart file with content type
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            fileBytes,
            filename: 'image_$i.$fileExtension',
            contentType: http.MediaType.parse(contentType),
          );
          
          requestMultipart.files.add(multipartFile);
        }
      }

      // Gửi request
      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data,
        );

        if (apiResponse.data != null) {
          return ReportApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to create report';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Create report error: ${e.toString()}');
    }
  }

  /// Lấy danh sách reports của user
  Future<ReportListApiResponse> getUserReports({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final url = Uri.parse('$baseUrl/reports/user').replace(queryParameters: queryParams);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data,
        );

        if (apiResponse.data != null) {
          // API trả về paginated response
          final data = apiResponse.data as Map<String, dynamic>;
          final reportsList = data['data'] as List<dynamic>?;
          if (reportsList == null) {
            throw Exception('Invalid response format');
          }
          return ReportListApiResponse(
            reports: reportsList
                .map((item) => ReportApiResponse.fromJson(item as Map<String, dynamic>))
                .toList(),
            total: data['total'] as int? ?? reportsList.length,
            limit: data['limit'] as int? ?? limit,
            offset: data['offset'] as int? ?? offset,
          );
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get reports';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Get user reports error: ${e.toString()}');
    }
  }

  /// Lấy chi tiết report
  Future<ReportApiResponse> getReportById(String reportId) async {
    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('$baseUrl/reports/$reportId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data,
        );

        if (apiResponse.data != null) {
          return ReportApiResponse.fromJson(apiResponse.data!);
        }
        throw Exception(apiResponse.message);
      } else {
        final errorMessage = jsonResponse['message'] as String? ??
            jsonResponse['detail'] as String? ??
            'Failed to get report';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Get report error: ${e.toString()}');
    }
  }
}

