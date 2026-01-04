import 'package:flutter/material.dart';

/// Button chip cho actions (Chỉ đường, Báo cáo ngay)
class ActionButtonChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButtonChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF00D9A3).withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF00D9A3)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D9A3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
