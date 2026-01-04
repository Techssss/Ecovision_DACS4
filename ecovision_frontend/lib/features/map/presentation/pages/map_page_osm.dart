import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/aqi_stations_provider.dart';
import '../../data/models/aqi_station_model.dart';
import '../widgets/aqi_legend.dart';
import '../widgets/aqi_heatmap_layer.dart';
import '../widgets/heatmap_controls.dart';

/// OpenStreetMap Page with AQI Heatmap
class MapPageOSM extends ConsumerStatefulWidget {
  const MapPageOSM({super.key});

  @override
  ConsumerState<MapPageOSM> createState() => _MapPageOSMState();
}

class _MapPageOSMState extends ConsumerState<MapPageOSM> {
  final MapController _mapController = MapController();
  bool _showHeatmap = true; // Toggle between heatmap and circles
  bool _showControls = false; // Show/hide heatmap controls
  double _heatmapRadius = 1500; // Heatmap radius in meters
  double _heatmapOpacity = 0.5; // Heatmap opacity

  @override
  Widget build(BuildContext context) {
    final aqiStationsAsync = ref.watch(aqiStationsProvider);
    final selectedStation = ref.watch(selectedAQIStationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ AQI'),
        backgroundColor: const Color(0xFF00D9A3),
        foregroundColor: Colors.white,
        actions: [
          if (_showHeatmap)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              tooltip: 'Cài đặt',
            ),
          IconButton(
            icon: Icon(_showHeatmap ? Icons.layers : Icons.circle),
            onPressed: () {
              setState(() {
                _showHeatmap = !_showHeatmap;
                _showControls = false;
              });
            },
            tooltip: _showHeatmap ? 'Chế độ vòng tròn' : 'Chế độ heatmap',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(aqiStationsProvider);
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Layer 1: OpenStreetMap with AQI data
          aqiStationsAsync.when(
            data: (stations) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(16.0544, 108.2022), // Đà Nẵng
                initialZoom: 12.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Tile layer (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ecovision_mobile',
                  maxZoom: 19,
                  minZoom: 1,
                  tileProvider: NetworkTileProvider(),
                ),

                // AQI Visualization Layer (Heatmap or Circles)
                if (_showHeatmap)
                  AQIHeatmapLayer(
                    stations: stations,
                    radius: _heatmapRadius,
                    opacity: _heatmapOpacity,
                  )
                else
                  CircleLayer(
                    circles: _buildAQICircles(stations),
                  ),

                // AQI Station Markers
                MarkerLayer(
                  markers: _buildAQIMarkers(stations, selectedStation),
                ),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(aqiStationsProvider);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),

          // Layer 2: AQI Legend
          const Positioned(
            bottom: 100,
            left: 16,
            child: AQILegend(),
          ),

          // Layer 3: Recenter Button
          Positioned(
            bottom: 100,
            right: 16,
            child: _buildRecenterButton(),
          ),

          // Layer 4: Heatmap Controls (when enabled)
          if (_showControls && _showHeatmap)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: HeatmapControls(
                radius: _heatmapRadius,
                opacity: _heatmapOpacity,
                onRadiusChanged: (value) {
                  setState(() {
                    _heatmapRadius = value;
                  });
                },
                onOpacityChanged: (value) {
                  setState(() {
                    _heatmapOpacity = value;
                  });
                },
              ),
            ),

          // Layer 5: Station Info Card (when selected)
          if (selectedStation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStationInfoCard(selectedStation),
            ),
        ],
      ),
    );
  }

  List<CircleMarker> _buildAQICircles(List<AQIStationModel> stations) {
    return stations.map((station) {
      if (station.currentAqi == null) return null;

      final color = _parseColor(station.status.color);

      return CircleMarker(
        point: station.position,
        radius: 800, // 800 meters radius
        useRadiusInMeter: true,
        color: color.withOpacity(0.2),
        borderColor: color.withOpacity(0.5),
        borderStrokeWidth: 2,
      );
    }).whereType<CircleMarker>().toList();
  }

  List<Marker> _buildAQIMarkers(
    List<AQIStationModel> stations,
    AQIStationModel? selectedStation,
  ) {
    return stations.map((station) {
      final isSelected = selectedStation?.stationId == station.stationId;
      final color = _parseColor(station.status.color);

      return Marker(
        point: station.position,
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedAQIStationProvider.notifier).state = station;
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                station.currentAqi?.toString() ?? '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSelected ? 18 : 16,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStationInfoCard(AQIStationModel station) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (station.address != null)
                      Text(
                        station.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedAQIStationProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  'AQI Hiện Tại',
                  station.currentAqi?.toString() ?? 'N/A',
                  _parseColor(station.status.color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  'TB 24h',
                  station.avgAqi24h?.toString() ?? 'N/A',
                  Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _parseColor(station.status.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(station.status.level),
                  color: _parseColor(station.status.color),
                ),
                const SizedBox(width: 8),
                Text(
                  station.status.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _parseColor(station.status.color),
                  ),
                ),
              ],
            ),
          ),
          if (station.lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              'Cập nhật: ${_formatDateTime(station.lastUpdated!)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecenterButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: () {
          _mapController.move(
            const LatLng(16.0544, 108.2022),
            12.0,
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

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon(String level) {
    switch (level) {
      case 'good':
        return Icons.check_circle;
      case 'moderate':
        return Icons.info;
      case 'unhealthy_sensitive':
      case 'unhealthy':
        return Icons.warning;
      case 'very_unhealthy':
      case 'hazardous':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
