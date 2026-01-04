import 'package:flutter/material.dart';
import '../../domain/models/route_model.dart';

/// Compact route preview (collapsed state)
class CompactRoutePreview extends StatelessWidget {
  final RouteModel route;

  const CompactRoutePreview({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route name
          Row(
            children: [
              Icon(
                _getStrategyIcon(route.name),
                size: 18,
                color: const Color(0xFF00D9A3),
              ),
              const SizedBox(width: 8),
              Text(
                route.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stats inline
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              Text(
                ' ${route.durationMinutes} phút',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.straighten, size: 14, color: Colors.grey),
              Text(
                ' ${route.distanceKm} km',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(
                '📊 AQI TB: ${route.avgAqi}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                'Max: ${route.maxAqi}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Bắt đầu chỉ đường',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9A3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Start navigation
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStrategyIcon(String name) {
    // Detect strategy from route name
    if (name.contains('Sạch') || name.contains('Clean')) {
      return Icons.eco;
    } else if (name.contains('Nhanh') || name.contains('Fast')) {
      return Icons.speed;
    } else if (name.contains('Cân bằng') || name.contains('Balance')) {
      return Icons.balance;
    }
    return Icons.route;
  }
}
