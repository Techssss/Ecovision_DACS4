import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/pollution_type_model.dart';
import '../providers/report_providers.dart';

/// Grid 6 loại ô nhiễm
class PollutionTypeGrid extends ConsumerWidget {
  const PollutionTypeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedPollutionProvider);
    final pollutionTypes = PollutionTypeModel.getAllTypes();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại ô nhiễm',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: pollutionTypes.length,
            itemBuilder: (context, index) {
              final type = pollutionTypes[index];
              final isSelected = selectedType == type.category;

              return _PollutionTypeCard(
                type: type,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedPollutionProvider.notifier).state = type.category;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PollutionTypeCard extends StatelessWidget {
  final PollutionTypeModel type;
  final bool isSelected;
  final VoidCallback onTap;

  const _PollutionTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D9A3)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9A3).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: type.iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: type.iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                type.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
