import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_model.dart';
import '../providers/routes_provider.dart';
import '../providers/selected_route_provider.dart';
import 'compact_route_preview.dart';
import 'route_card.dart';

/// Draggable bottom sheet (20% collapsed, 60% expanded)
class DraggableBottomSheet extends ConsumerWidget {
  const DraggableBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider);
    final selectedRoute = ref.watch(selectedRouteProvider) ?? routes.first;

    return DraggableScrollableSheet(
      initialChildSize: 0.2, // 20% màn hình (collapsed)
      minChildSize: 0.15,
      maxChildSize: 0.6, // Max 60%
      snap: true,
      snapSizes: const [0.2, 0.6],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.expand_less, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Xem ${routes.length} tuyến đường',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF00D9A3),
                      size: 20,
                    ),
                  ],
                ),
              ),

              // Collapsed preview (route chính)
              CompactRoutePreview(route: selectedRoute),

              const Divider(height: 1),

              // Full route list (chỉ hiển thị khi expand)
              ...routes.map((route) => RouteCard(route: route)),
            ],
          ),
        );
      },
    );
  }
}
