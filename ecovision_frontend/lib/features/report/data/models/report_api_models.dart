import '../../../auth/data/services/auth_service.dart';
import '../../domain/models/report_model.dart';

/// API Request model cho tạo report
class ReportCreateRequest {
  final String type;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String severity;

  ReportCreateRequest({
    required this.type,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.severity = 'medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (description != null && description!.isNotEmpty) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null && address!.isNotEmpty) 'address': address,
      'severity': severity,
    };
  }
}

/// API Response model cho report image
class ReportImageApiResponse {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final int orderIndex;
  final List<dynamic>? yoloDetections; // Changed from Map to List - backend returns array of detections

  ReportImageApiResponse({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.orderIndex,
    this.yoloDetections,
  });

  factory ReportImageApiResponse.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image_url'] as String;
    String? thumbnailUrl = json['thumbnail_url'] as String?;
    
    // Prepend baseUrl if image_url is a relative path
    if (imageUrl.startsWith('/')) {
      // Remove /api/v1 from baseUrl to get base server URL
      final baseServerUrl = AuthService.baseUrl.replaceAll('/api/v1', '');
      imageUrl = '$baseServerUrl$imageUrl';
    }
    if (thumbnailUrl != null && thumbnailUrl.startsWith('/')) {
      final baseServerUrl = AuthService.baseUrl.replaceAll('/api/v1', '');
      thumbnailUrl = '$baseServerUrl$thumbnailUrl';
    }
    
    // Parse yolo_detections - can be List or null
    List<dynamic>? yoloDetections;
    if (json['yolo_detections'] != null) {
      if (json['yolo_detections'] is List) {
        yoloDetections = json['yolo_detections'] as List<dynamic>;
      } else {
        // If it's a string (old format), try to parse it
        yoloDetections = null;
      }
    }
    
    return ReportImageApiResponse(
      id: json['id'] as String,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      orderIndex: json['order_index'] as int? ?? 0,
      yoloDetections: yoloDetections,
    );
  }
}

/// API Response model cho report
class ReportApiResponse {
  final String id;
  final String userId;
  final String type;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String severity;
  final String status;
  final String? trackingCode;
  final List<ReportImageApiResponse> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportApiResponse({
    required this.id,
    required this.userId,
    required this.type,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.severity,
    required this.status,
    this.trackingCode,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportApiResponse.fromJson(Map<String, dynamic> json) {
    return ReportApiResponse(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      severity: json['severity'] as String,
      status: json['status'] as String,
      trackingCode: json['tracking_code'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ReportImageApiResponse.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to domain model
  ReportModel toDomainModel() {
    return ReportModel(
      id: id,
      type: type,
      location: address ?? 'Unknown',
      status: status,
      timestamp: createdAt,
      description: description,
      imagePath: images.isNotEmpty ? images.first.imageUrl : null,
      trackingCode: trackingCode,
    );
  }
}

/// API Response model cho danh sách reports
class ReportListApiResponse {
  final List<ReportApiResponse> reports;
  final int total;
  final int limit;
  final int offset;

  ReportListApiResponse({
    required this.reports,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ReportListApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    return ReportListApiResponse(
      reports: data
          .map((item) => ReportApiResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? data.length,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
    );
  }
}

