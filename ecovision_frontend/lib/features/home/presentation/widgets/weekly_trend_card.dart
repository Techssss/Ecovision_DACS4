import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/aqi_provider.dart';
import '../../../home/data/services/aqi_trend_service.dart';

/// Card hiển thị xu hướng AQI 7 ngày
class WeeklyTrendCard extends ConsumerStatefulWidget {
  const WeeklyTrendCard({super.key});

  @override
  ConsumerState<WeeklyTrendCard> createState() => _WeeklyTrendCardState();
}

class _WeeklyTrendCardState extends ConsumerState<WeeklyTrendCard> {
  void refresh() {
    ref.invalidate(aqiTrendProvider);
  }

  @override
  Widget build(BuildContext context) {
    final trendAsync = ref.watch(aqiTrendProvider);

    return trendAsync.when(
      data: (trendData) {
        print('✅ Trend data received: ${trendData.length} items');
        return _buildChart(context, trendData);
      },
      loading: () => _buildLoadingChart(context),
      error: (err, stack) {
        print('❌ Trend error: $err');
        print('❌ Stack: $stack');
        return _buildErrorChart(context, err);
      },
    );
  }

  Widget _buildChart(BuildContext context, List<AQITrendData> trendData) {
    // Convert trend data to chart format
    final weeklyData = trendData.map((data) {
      return {
        'day': data.getDayName(),
        'aqi': data.avgAqi.toInt(),
      };
    }).toList();

    // If we have less than 7 days, pad with empty data
    while (weeklyData.length < 7) {
      weeklyData.insert(0, {'day': '', 'aqi': 0});
    }

    // Calculate trend percentage
    double trendPercent = 0;
    if (weeklyData.length >= 2) {
      final first = weeklyData.first['aqi'] as int;
      final last = weeklyData.last['aqi'] as int;
      if (first > 0) {
        trendPercent = ((last - first) / first) * 100;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với title và trend indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Xu hướng 7 ngày',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trendPercent >= 0 ? '+' : ''}${trendPercent.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendPercent >= 0 
                            ? const Color(0xFF2196F3) 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Line Chart
          SizedBox(
            height: 120,
            child: LineChart(
              _buildChartData(weeklyData),
            ),
          ),

          const SizedBox(height: 12),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeklyData.map((data) {
              final day = data['day'] as String;
              if (day.isEmpty) {
                return const SizedBox.shrink();
              }
              return Text(
                day,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF666666),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorChart(BuildContext context, Object error) {
    print('❌ WeeklyTrendCard Error: $error');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Xu hướng 7 ngày',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không thể tải dữ liệu',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Refresh data by invalidating provider
              ref.invalidate(aqiTrendProvider);
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(List<Map<String, dynamic>> weeklyData) {
    // Filter out empty days
    final validData = weeklyData.where((e) => (e['aqi'] as int) > 0).toList();
    
    if (validData.isEmpty) {
      // Return empty chart
      return LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [],
      );
    }

    final minAqi = validData.map((e) => e['aqi'] as int).reduce((a, b) => a < b ? a : b);
    final maxAqi = validData.map((e) => e['aqi'] as int).reduce((a, b) => a > b ? a : b);
    final range = maxAqi - minAqi;
    final padding = range > 0 ? range * 0.2 : 10; // 20% padding or min 10

    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minY: (minAqi - padding).toDouble(),
      maxY: (maxAqi + padding).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: validData.asMap().entries.map((entry) {
            final index = entry.key;
            final aqi = entry.value['aqi'] as int;
            return FlSpot(index.toDouble(), aqi.toDouble());
          }).toList(),
          isCurved: true,
          color: AppColors.primaryLight,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryLight,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryLight.withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.primaryLight,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                'AQI: ${barSpot.y.toInt()}',
                GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

