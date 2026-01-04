import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_model.dart';
import '../providers/routes_provider.dart';
import '../providers/selected_route_provider.dart';
import 'route_card.dart';

/// Bottom sheet hiển thị danh sách routes
class RouteListBottomSheet extends ConsumerWidget {
  const RouteListBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Số sành tuyến đường',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Route cards
              ...routes.map((route) => RouteCard(
                    route: route,
                    onTap: () {
                      ref.read(selectedRouteProvider.notifier).state = route;
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
