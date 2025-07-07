import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_polygon_editor/polygon_editor.dart';

class PolygonEditorExample extends StatefulWidget {
  const PolygonEditorExample({super.key});

  @override
  State<PolygonEditorExample> createState() => _PolygonEditorExampleState();
}

class _PolygonEditorExampleState extends State<PolygonEditorExample> {
  final PolygonEditorController _controller = PolygonEditorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map layer
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(51.5074, -0.1278), // London
              initialZoom: 10,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
              onLongPress: (tapPosition, point) {
                _controller.addPoint(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_map_polygon_editor',
              ),
              PolygonEditor(controller: _controller),
            ],
          ),

          // Floating controls overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                // Mode toggle button
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, child) => FloatingActionButton(
                    heroTag: "mode_toggle",
                    onPressed: () {
                      _controller.setMode(
                        _controller.mode == PolygonEditorMode.polygon
                            ? PolygonEditorMode.line
                            : PolygonEditorMode.polygon,
                      );
                    },
                    tooltip: _controller.mode == PolygonEditorMode.polygon
                        ? 'Switch to Line Mode'
                        : 'Switch to Polygon Mode',
                    child: Icon(
                      _controller.mode == PolygonEditorMode.polygon
                          ? Icons.polyline
                          : Icons.rectangle_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Clear button
                FloatingActionButton(
                  heroTag: "clear",
                  onPressed: () => _controller.clear(),
                  tooltip: 'Clear all points',
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          ),

          // Info panel overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoChip(
                          'Mode',
                          _controller.mode.name.toUpperCase(),
                          Icons.edit_location,
                        ),
                        _buildInfoChip(
                          'Points',
                          '${_controller.points.length}',
                          Icons.place,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Long press map to add point • Long press point to remove • Drag midpoints to insert',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}