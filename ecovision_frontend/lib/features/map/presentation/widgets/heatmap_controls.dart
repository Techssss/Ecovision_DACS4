import 'package:flutter/material.dart';

/// Controls for adjusting heatmap visualization
class HeatmapControls extends StatelessWidget {
  final double radius;
  final double opacity;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onOpacityChanged;

  const HeatmapControls({
    super.key,
    required this.radius,
    required this.opacity,
    required this.onRadiusChanged,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt Heatmap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Radius slider
          Row(
            children: [
              const Icon(Icons.radio_button_unchecked, size: 20),
              const SizedBox(width: 8),
              const Text('Bán kính:', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: radius,
                  min: 500,
                  max: 3000,
                  divisions: 10,
                  label: '${radius.toInt()}m',
                  activeColor: const Color(0xFF00D9A3),
                  onChanged: onRadiusChanged,
                ),
              ),
              Text(
                '${radius.toInt()}m',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          
          // Opacity slider
          Row(
            children: [
              const Icon(Icons.opacity, size: 20),
              const SizedBox(width: 8),
              const Text('Độ mờ:', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: opacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${(opacity * 100).toInt()}%',
                  activeColor: const Color(0xFF00D9A3),
                  onChanged: onOpacityChanged,
                ),
              ),
              Text(
                '${(opacity * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
