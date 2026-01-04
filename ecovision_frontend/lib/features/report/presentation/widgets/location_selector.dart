import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/report_providers.dart';

/// Widget chọn/edit vị trí với GPS
class LocationSelector extends ConsumerStatefulWidget {
  const LocationSelector({super.key});

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  bool _isLoadingLocation = false;
  bool _hasAttemptedAutoLoad = false;

  @override
  void initState() {
    super.initState();
    // Auto-load location on first open (with delay to avoid blocking UI)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasAttemptedAutoLoad) {
        _hasAttemptedAutoLoad = true;
        final coords = ref.read(currentCoordinatesProvider);
        if (coords == null) {
          // Only auto-load if no coordinates yet
          _getCurrentLocation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocationProvider);
    final coordinates = ref.watch(currentCoordinatesProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _isLoadingLocation ? Icons.location_searching : Icons.location_on,
            color: const Color(0xFF00D9A3),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vị trí hiện tại',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isLoadingLocation ? 'Đang lấy vị trí...' : location,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (coordinates != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${coordinates['latitude']!.toStringAsFixed(4)}, ${coordinates['longitude']!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isLoadingLocation)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _getCurrentLocation(),
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('GPS'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00D9A3),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) => _useMockLocation(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'hai_chau',
                      child: Text('📍 Hải Châu (Mock)'),
                    ),
                    const PopupMenuItem(
                      value: 'son_tra',
                      child: Text('📍 Sơn Trà (Mock)'),
                    ),
                    const PopupMenuItem(
                      value: 'thanh_khe',
                      child: Text('📍 Thanh Khê (Mock)'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng bật trong Settings.');
      }

      // Get current position with timeout
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // Use medium for faster response
          timeLimit: const Duration(seconds: 10), // 10 second timeout
        );
      } catch (e) {
        // If timeout or error, try to get last known position
        position = await Geolocator.getLastKnownPosition() ??
            await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low, // Fallback to low accuracy
              timeLimit: const Duration(seconds: 5),
            );
      }

      // Reverse geocoding to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = '';

          if (place.street != null && place.street!.isNotEmpty) {
            address = place.street!;
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            address += address.isEmpty ? place.subLocality! : ', ${place.subLocality}';
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            address += address.isEmpty ? place.locality! : ', ${place.locality}';
          }

          if (address.isEmpty) {
            address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          }

          // Update location and coordinates
          ref.read(currentLocationProvider.notifier).state = address;
          ref.read(currentCoordinatesProvider.notifier).state = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };
        }
      } catch (e) {
        // If geocoding fails, just use coordinates
        ref.read(currentLocationProvider.notifier).state =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        ref.read(currentCoordinatesProvider.notifier).state = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã lấy vị trí GPS'),
              ],
            ),
            backgroundColor: Color(0xFF00D9A3),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lấy vị trí: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _useMockLocation(String location) {
    // Mock locations for testing/emulator
    final mockLocations = {
      'hai_chau': {
        'address': 'Trung tâm Hải Châu, Đà Nẵng',
        'lat': 16.0544,
        'lng': 108.2022,
      },
      'son_tra': {
        'address': 'Bán đảo Sơn Trà, Đà Nẵng',
        'lat': 16.0900,
        'lng': 108.2500,
      },
      'thanh_khe': {
        'address': 'Công viên 29/3, Thanh Khê, Đà Nẵng',
        'lat': 16.0600,
        'lng': 108.1900,
      },
    };

    final mock = mockLocations[location];
    if (mock != null) {
      ref.read(currentLocationProvider.notifier).state = mock['address'] as String;
      ref.read(currentCoordinatesProvider.notifier).state = {
        'latitude': mock['lat'] as double,
        'longitude': mock['lng'] as double,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Text('Đã dùng vị trí mock: ${mock['address']}'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
