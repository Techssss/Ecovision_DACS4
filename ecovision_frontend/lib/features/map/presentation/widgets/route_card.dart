import 'package:flutter/material.dart';
import '../../domain/models/route_model.dart';
import '../../../../core/theme/map_colors.dart';

/// Card hiển thị thông tin tuyến đường
class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tên tuyến + badge
          Row(
            children: [
              Expanded(
                child: Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (route.avgAqi < 45)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Đề xuất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Duration & Distance
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${route.durationMinutes} phút',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.navigation, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                '${route.distanceKm} km',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: AQI Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'AQI trung bình',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.avgAqi}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MapColors.getAQIColor(route.avgAqi),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'AQI tối đa',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.maxAqi}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MapColors.getAQIColor(route.maxAqi),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Feature chips
          Wrap(
            spacing: 8,
            children: route.features
                .map(
                  (feature) => Chip(
                    label: Text(
                      feature,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: feature.contains('AQI')
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Bắt đầu chỉ đường'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Navigate to navigation screen
                debugPrint('Bắt đầu chỉ đường: ${route.name}');
                if (onTap != null) onTap!();
              },
            ),
          ),
        ],
      ),
    );
  }
}
