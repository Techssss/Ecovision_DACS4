import 'package:geolocator/geolocator.dart';

class LocationService {
  // Fallback location: Da Nang, Vietnam
  static const double defaultLat = 16.0544;
  static const double defaultLon = 108.2022;

  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services disabled, using Da Nang');
        return _getDaNangPosition();
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied, using Da Nang');
          return _getDaNangPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission permanently denied, using Da Nang');
        return _getDaNangPosition();
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Faster
        timeLimit: const Duration(seconds: 5), // 5s timeout
      );

      // DEBUG: Check if position is in Vietnam
      // Vietnam bounds: lat 8-24, lng 102-110
      if (position.latitude < 8 ||
          position.latitude > 24 ||
          position.longitude < 102 ||
          position.longitude > 110) {
        print(
            '⚠️ GPS outside Vietnam (${position.latitude}, ${position.longitude}), using Da Nang');
        return _getDaNangPosition();
      }

      print('✅ GPS in Vietnam: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Location error: $e, using Da Nang');
      return _getDaNangPosition();
    }
  }

  Position _getDaNangPosition() {
    return Position(
      latitude: defaultLat,
      longitude: defaultLon,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
