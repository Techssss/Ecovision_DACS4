import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/pollution_type_grid.dart';
import '../widgets/location_selector.dart';
import '../widgets/description_input.dart';
import '../widgets/image_picker_section.dart';
import '../widgets/submit_button.dart';
import '../widgets/recent_report_card.dart';
import '../providers/report_providers.dart';

/// Trang Báo cáo Ô nhiễm
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(userReportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (Green)
              _buildHeader(),

              // Pollution Type Grid
              const PollutionTypeGrid(),

              // Location Selector
              const LocationSelector(),

              // Description Input
              const DescriptionInput(),

              // Image Picker Section
              const ImagePickerSection(),

              // Submit Button
              const SubmitButton(),

              // Recent Reports Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Báo cáo gần đây',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    reportsAsync.when(
                      data: (reports) {
                        if (reports.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có báo cáo nào',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: reports
                              .map((report) => RecentReportCard(report: report))
                              .toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lỗi: ${error.toString()}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00D9A3), Color(0xFF00B8D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Báo cáo ô nhiễm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Giúp cộng đồng giữ môi trường sạch đẹp',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
