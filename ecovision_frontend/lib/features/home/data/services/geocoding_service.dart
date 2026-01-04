import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeocodingService {
  /// Lấy địa chỉ chi tiết từ GPS coordinates
  Future<String> getAddressFromPosition(Position position) async {
    try {
      print('📍 Geocoding: ${position.latitude}, ${position.longitude}');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        print('⚠️ No placemarks found');
        return 'Không xác định được vị trí';
      }

      final place = placemarks.first;
      
      print('📍 Placemark: ${place.toString()}');
      print('   - Street: ${place.street}');
      print('   - SubAdmin: ${place.subAdministrativeArea}');
      print('   - Admin: ${place.administrativeArea}');
      print('   - Locality: ${place.locality}');
      print('   - Country: ${place.country}');
      
      // Format: "Đường, Quận/Huyện, Thành phố"
      List<String> addressParts = [];
      
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }
      
      if (place.subAdministrativeArea != null && 
          place.subAdministrativeArea!.isNotEmpty) {
        addressParts.add(place.subAdministrativeArea!);
      }
      
      if (place.administrativeArea != null && 
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      
      if (addressParts.isEmpty) {
        // Fallback to locality
        if (place.locality != null && place.locality!.isNotEmpty) {
          print('✅ Using locality: ${place.locality}');
          return place.locality!;
        }
        print('⚠️ No address parts, using default');
        return 'Đà Nẵng';
      }
      
      String address = addressParts.join(', ');
      print('✅ Final address: $address');
      
      return address;
    } catch (e) {
      print('❌ Geocoding error: $e');
      return 'Đà Nẵng';
    }
  }
}
