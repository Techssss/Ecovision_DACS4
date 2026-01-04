import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_model.dart';

/// Provider cho route đang được chọn
final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);
