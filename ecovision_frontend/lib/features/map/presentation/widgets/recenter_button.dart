import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Recenter button floating bottom-right
class RecenterButton extends ConsumerWidget {
  final GoogleMapController? mapController;

  const RecenterButton({
    super.key,
    this.mapController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Trigger map recenter
          mapController?.animateCamera(
            CameraUpdate.newLatLng(
              const LatLng(16.0544, 108.2022), // Đà Nẵng
            ),
          );
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: const Icon(
            Icons.my_location,
            color: Color(0xFF00D9A3),
            size: 24,
          ),
        ),
      ),
    );
  }
}
