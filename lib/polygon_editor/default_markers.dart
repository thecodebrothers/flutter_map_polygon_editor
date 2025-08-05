import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Default point marker widget - blue circle with white border and shadow.
/// Green circle when it's the start point during creation.
///
/// This is the default implementation for point markers used in the polygon editor.
/// The marker changes appearance when being dragged to provide visual feedback.
class DefaultPointMarker extends StatelessWidget {
  const DefaultPointMarker({
    required this.isDragging,
    this.isStartPoint = false,
    super.key,
  });

  /// Whether this marker is currently being dragged.
  final bool isDragging;

  /// Whether this marker is the start point during creation mode.
  final bool isStartPoint;

  @override
  Widget build(BuildContext context) {
    final color = isStartPoint ? Colors.green : Colors.blue;
    final dragColor =
        isStartPoint ? Colors.green.shade700 : Colors.blue.shade700;

    return Container(
      decoration: BoxDecoration(
        color: isDragging ? dragColor : color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Default midpoint marker widget - green circle with white border, shadow, and plus icon.
///
/// This is the default implementation for midpoint markers used in the polygon editor.
/// Midpoint markers are shown between existing points and can be dragged to create new points.
/// The marker changes appearance when being dragged to provide visual feedback.
class DefaultMidpointMarker extends StatelessWidget {
  const DefaultMidpointMarker({
    required this.isDragging,
    super.key,
  });

  /// Whether this marker is currently being dragged.
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDragging ? Colors.green.shade700 : Colors.green,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 12),
    );
  }
}

/// Default point builder function for the polygon editor.
///
/// Returns a [DefaultPointMarker] widget. The [position] parameter is available
/// for custom implementations but not used in the default marker.
Widget defaultPointBuilder(
  BuildContext context,
  LatLng position,
  bool isDragging,
  bool isStartPoint,
) {
  return DefaultPointMarker(
    isDragging: isDragging,
    isStartPoint: isStartPoint,
  );
}

/// Default midpoint builder function for the polygon editor.
///
/// Returns a [DefaultMidpointMarker] widget. The [position] parameter is available
/// for custom implementations but not used in the default marker.
Widget defaultMidpointBuilder(
  BuildContext context,
  LatLng position,
  bool isDragging,
) {
  return DefaultMidpointMarker(isDragging: isDragging);
}
