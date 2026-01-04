import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/models/report_model.dart';

/// Provider cho loại ô nhiễm đã chọn
final selectedPollutionProvider = StateProvider<String?>((ref) => null);

/// Provider cho ảnh đã chọn
final selectedImageProvider = StateProvider<File?>((ref) => null);

/// Provider cho vị trí hiện tại (address string)
final currentLocationProvider =
    StateProvider<String>((ref) => 'Đang lấy vị trí...');

/// Provider cho GPS coordinates
final currentCoordinatesProvider =
    StateProvider<Map<String, double>?>((ref) => null);

/// Provider cho mô tả
final descriptionProvider = StateProvider<String>((ref) => '');

/// Provider cho trạng thái loading (khi AI đang phân tích)
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

/// Provider cho trạng thái đang gửi report
final isSubmittingReportProvider = StateProvider<bool>((ref) => false);

/// Provider cho ReportRepository
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

/// Provider cho danh sách reports của user
final userReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  try {
    return await repository.getUserReports(limit: 10);
  } catch (e) {
    // Trả về empty list nếu có lỗi
    return [];
  }
});
