import 'dart:io';
import '../services/report_service.dart';
import '../models/report_api_models.dart';
import '../../domain/models/report_model.dart';

class ReportRepository {
  final ReportService _reportService;

  ReportRepository({ReportService? reportService})
      : _reportService = reportService ?? ReportService();

  /// Tạo report mới
  Future<ReportModel> createReport({
    required String type,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    String severity = 'medium',
    List<File>? images,
  }) async {
    try {
      final request = ReportCreateRequest(
        type: type,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        severity: severity,
      );

      final response = await _reportService.createReport(
        request,
        images: images,
      );

      return response.toDomainModel();
    } catch (e) {
      throw Exception('Failed to create report: ${e.toString()}');
    }
  }

  /// Lấy danh sách reports của user
  Future<List<ReportModel>> getUserReports({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _reportService.getUserReports(
        status: status,
        limit: limit,
        offset: offset,
      );

      return response.reports.map((r) => r.toDomainModel()).toList();
    } catch (e) {
      throw Exception('Failed to get user reports: ${e.toString()}');
    }
  }

  /// Lấy chi tiết report
  Future<ReportModel> getReportById(String reportId) async {
    try {
      final response = await _reportService.getReportById(reportId);
      return response.toDomainModel();
    } catch (e) {
      throw Exception('Failed to get report: ${e.toString()}');
    }
  }
}

