/// Helper để map location string sang coordinates
class LocationHelper {
  /// Map location name sang latitude/longitude
  /// Trong production, nên dùng geocoding service (Google Maps, OpenStreetMap, etc.)
  static Map<String, double> getCoordinatesFromLocation(String location) {
    // Mock coordinates cho các location phổ biến ở Đà Nẵng
    final locationMap = {
      'Sơn Trà, Đà Nẵng': {'lat': 16.0544, 'lon': 108.2500},
      'Hải Châu, Đà Nẵng': {'lat': 16.0479, 'lon': 108.2208},
      'Thanh Khê, Đà Nẵng': {'lat': 16.0667, 'lon': 108.1833},
      'Ngũ Hành Sơn, Đà Nẵng': {'lat': 16.0000, 'lon': 108.2500},
      'Liên Chiểu, Đà Nẵng': {'lat': 16.0833, 'lon': 108.1500},
      'Cẩm Lệ, Đà Nẵng': {'lat': 16.0167, 'lon': 108.2000},
    };

    // Tìm location trong map
    final coords = locationMap[location];
    if (coords != null) {
      return {'latitude': coords['lat']!, 'longitude': coords['lon']!};
    }

    // Default: Sơn Trà, Đà Nẵng
    return {'latitude': 16.0544, 'longitude': 108.2500};
  }
}

