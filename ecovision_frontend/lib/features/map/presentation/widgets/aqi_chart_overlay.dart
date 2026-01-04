import 'package:flutter/material.dart';
import '../../domain/models/route_model.dart';
import '../../../../core/theme/map_colors.dart';

/// Overlay hiển thị biểu đồ AQI trên map
class AqiChartOverlay extends StatelessWidget {
  final RouteModel? selectedRoute;
  final VoidCallback onRefresh;

  const AqiChartOverlay({
    super.key,
    this.selectedRoute,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRoute == null) return const SizedBox.shrink();

    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Simple chart visualization
          Expanded(
            child: CustomPaint(
              painter: AQIChartPainter(data: selectedRoute!.segmentAqis),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegend(MapColors.getAQIColor(30), '0-50'),
              const SizedBox(width: 16),
              _buildLegend(MapColors.getAQIColor(75), '51-100'),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tìm lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: onRefresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

/// Custom painter cho biểu đồ AQI đơn giản
class AQIChartPainter extends CustomPainter {
  final List<int> data;

  AQIChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxAqi = data.reduce((a, b) => a > b ? a : b).toDouble();

    // Vẽ đường line chart
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxAqi * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Vẽ điểm
      paint.color = MapColors.getAQIColor(data[i]);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }

    // Vẽ line
    paint.color = Colors.blue;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
