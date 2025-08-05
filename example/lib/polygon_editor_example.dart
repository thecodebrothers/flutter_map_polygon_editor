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
  final ValueNotifier<LatLng?> _cursorPosition = ValueNotifier(null);

  bool _isDraggingPolygon = false;
  LatLng? _dragStartPosition;

  @override
  void dispose() {
    _controller.dispose();
    _cursorPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(51.5074, -0.1278),
              initialZoom: 10,
              interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.all),
              onTap: (tapPosition, latLng) {
                if (_controller.state == PolygonEditingState.creating) {
                  _controller.addPoint(latLng);
                } else if (_isDraggingPolygon) {
                  _isDraggingPolygon = false;
                  _dragStartPosition = null;
                }
              },
              onLongPress: (tapPosition, latLng) {
                if (_controller.state == PolygonEditingState.editing &&
                    _controller.points.length >= 3 &&
                    _isPointInPolygon(latLng, _controller.points)) {
                  _isDraggingPolygon = true;
                  _dragStartPosition = latLng;
                }
              },
              onPointerHover: (event, latLng) {
                if (_controller.state == PolygonEditingState.creating) {
                  _cursorPosition.value = latLng;
                } else if (_isDraggingPolygon && _dragStartPosition != null) {
                  final latOffset =
                      latLng.latitude - _dragStartPosition!.latitude;
                  final lngOffset =
                      latLng.longitude - _dragStartPosition!.longitude;
                  _controller.movePolygon(latOffset, lngOffset);
                  _dragStartPosition = latLng;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.flutter_map_polygon_editor',
              ),
              PolygonEditor(
                controller: _controller,
                cursorPosition: _cursorPosition,
              ),
            ],
          ),

          // Floating controls overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                // State toggle button
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, child) => FloatingActionButton(
                    heroTag: "state_toggle",
                    onPressed: () {
                      _controller.setState(
                        _controller.state == PolygonEditingState.creating
                            ? PolygonEditingState.editing
                            : PolygonEditingState.creating,
                      );
                    },
                    tooltip: _controller.state == PolygonEditingState.creating
                        ? 'Switch to Edit Mode'
                        : 'Switch to Create Mode',
                    child: Icon(
                      _controller.state == PolygonEditingState.creating
                          ? Icons.edit
                          : Icons.add_location,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Clear button
                FloatingActionButton(
                  heroTag: "clear",
                  onPressed: () {
                    _controller.clear();
                    _controller.setState(PolygonEditingState.creating);
                  },
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
                          'State',
                          _controller.state.name.toUpperCase(),
                          _controller.state == PolygonEditingState.creating
                              ? Icons.add_location
                              : Icons.edit,
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
                      _controller.state == PolygonEditingState.creating
                          ? 'Tap map to add point • Tap green start point to finish'
                          : 'Drag points to move • Long press point to remove • Drag midpoints to insert • Long press inside polygon to move it',
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

  /// Simple point-in-polygon test using ray casting algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      if (((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude <
              (xj - xi) * (point.longitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
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
