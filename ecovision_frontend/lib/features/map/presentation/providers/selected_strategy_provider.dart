import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cho chiến lược đã chọn: "cleanest" | "fastest" | "balanced"
final selectedStrategyProvider = StateProvider<String>((ref) => 'cleanest');
