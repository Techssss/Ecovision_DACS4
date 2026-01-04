import 'package:flutter/material.dart';

/// AQI Legend floating bottom-left
class AQILegend extends StatelessWidget {
  const AQILegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AQI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: const Color(0xFF06FF64),
            range: '0-50',
            label: 'Tốt',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: const Color(0xFFFFFC00),
            range: '51-100',
            label: 'TB',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: const Color(0xFFFFA500),
            range: '101-150',
            label: 'Kém',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String range,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          range,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
