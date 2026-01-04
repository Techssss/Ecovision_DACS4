import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/air_quality_model.dart';
import '../../domain/models/recommendation_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/ai_recommendation_card.dart';
import '../widgets/weekly_trend_card.dart';
import '../providers/aqi_provider.dart';
import '../../data/repositories/aqi_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Trang chủ - Home Screen
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aqiAsync = ref.watch(currentAQIProvider);
    final recommendations = RecommendationModel.getMockData();
    
    // Mock data để hiển thị ngay
    final mockAirQuality = AirQualityModel.mock();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentAQIProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom App Bar with location
                Row(
                  children: [
                    Expanded(
                      child: CustomAppBar(
                        locationName: aqiAsync.maybeWhen(
                          data: (aqiData) => aqiData.cityName,
                          orElse: () => null,
                        ),
                      ),
                    ),
                    // Debug: Clear cache button
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () async {
                        // Clear cache and refresh
                        final repo = await ref.read(aqiRepositoryProvider.future);
                        await repo.clearCache();
                        ref.invalidate(currentAQIProvider);
                      },
                      tooltip: 'Làm mới dữ liệu',
                    ),
                  ],
                ),

                // Air Quality Card - Show mock first, then real data
                aqiAsync.when(
                  data: (aqiData) {
                    // Convert AQIData to AirQualityModel
                    final airQuality = AirQualityModel(
                      aqi: aqiData.aqi,
                      status: aqiData.status,
                      temperature: aqiData.temperature,
                      humidity: aqiData.humidity.toInt(),
                    );
                    return AirQualityCard(data: airQuality);
                  },
                  loading: () => AirQualityCard(data: mockAirQuality),
                  error: (error, _) => AirQualityCard(data: mockAirQuality),
                ),

                const SizedBox(height: 24),

                // 7-Day Trend Section
                const WeeklyTrendCard(),

                const SizedBox(height: 24),

                // AI Recommendations Section
                Text(
                  'Khuyến nghị từ AI',
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),

                // Danh sách recommendations
                ...recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AiRecommendationCard(recommendation: rec),
                    )),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu AQI...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải dữ liệu AQI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kéo xuống để thử lại',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
