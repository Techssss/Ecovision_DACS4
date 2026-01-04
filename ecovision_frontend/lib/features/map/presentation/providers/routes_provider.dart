import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_model.dart';
import '../../domain/models/mock_data.dart';
import 'selected_strategy_provider.dart';

/// Provider cho danh sách routes được filter theo strategy
final routesProvider = Provider<List<RouteModel>>((ref) {
  final strategy = ref.watch(selectedStrategyProvider);

  // Filter routes dựa trên strategy
  return MockMapData.routes.where((route) {
    if (strategy == 'cleanest') return route.avgAqi < 45;
    if (strategy == 'fastest') return route.durationMinutes < 16;
    return true; // balanced - show all
  }).toList();
});
