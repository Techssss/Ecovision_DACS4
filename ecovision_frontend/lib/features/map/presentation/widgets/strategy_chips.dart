import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Strategy chips floating horizontal
class StrategyChips extends ConsumerWidget {
  const StrategyChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual provider
    final selected = 'fastest'; // ref.watch(selectedStrategyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildChip(
            context: context,
            ref: ref,
            icon: Icons.eco,
            label: 'Sạch',
            strategy: 'cleanest',
            isSelected: selected == 'cleanest',
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            ref: ref,
            icon: Icons.speed,
            label: 'Nhanh',
            strategy: 'fastest',
            isSelected: selected == 'fastest',
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            ref: ref,
            icon: Icons.balance,
            label: 'Cân bằng',
            strategy: 'balanced',
            isSelected: selected == 'balanced',
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String strategy,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Update strategy
        // ref.read(selectedStrategyProvider.notifier).state = strategy;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D9A3) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9A3).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF00D9A3) : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF00D9A3) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
