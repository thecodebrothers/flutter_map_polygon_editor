import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';

import 'default_markers.dart';
import 'polygon_editor_controller.dart';
import 'polygon_editor_style.dart';

/// Interactive polygon and polyline editor for Flutter Map.
///
/// Allows users to create and edit polygons and polylines by dragging markers
/// on the map. Supports both closed polygons and open polylines with
/// customizable styling and marker builders.
///
/// ```dart
/// class _MapPageState extends State<MapPage> {
///   late final PolygonEditorController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = PolygonEditorController();
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return FlutterMap(
///       children: [
///         TileLayer(urlTemplate: '...'),
///         PolygonEditor(
///           controller: _controller,
///           style: PolygonEditorStyle(
///             borderColor: Colors.blue,
///             fillColor: Colors.blue.withOpacity(0.3),
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
class PolygonEditor extends StatefulWidget {
  const PolygonEditor({
    required this.controller,
    this.pointBuilder,
    this.midpointBuilder,
    this.style = const PolygonEditorStyle(),
    this.throttleDuration = const Duration(milliseconds: 16),
    super.key,
  });

  /// The controller that manages the polygon/polyline data and editing operations.
  final PolygonEditorController controller;

  /// Custom builder for point markers. If null, uses [defaultPointBuilder].
  ///
  /// The builder receives the context, position, and drag state of the marker.
  final Widget Function(BuildContext context, LatLng position, bool isDragging)?
  pointBuilder;

  /// Custom builder for midpoint markers. If null, uses [defaultMidpointBuilder].
  ///
  /// The builder receives the context, position, and drag state of the marker.
  final Widget Function(BuildContext context, LatLng position, bool isDragging)?
  midpointBuilder;

  /// The visual styling configuration for the polygon/polyline.
  final PolygonEditorStyle style;

  /// Throttling duration for midpoint drag updates. Defaults to 16ms.
  /// Set to [Duration.zero] to disable throttling.
  final Duration throttleDuration;

  @override
  State<PolygonEditor> createState() => _PolygonEditorState();
}

class _PolygonEditorState extends State<PolygonEditor> {
  // State variables
  List<LatLng> _midpoints = [];
  late final ValueNotifier<bool> _showMidpoints;
  late final ValueNotifier<List<LatLng>> _interleavedPoints;
  DateTime? _polygonLastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _interleavedPoints = ValueNotifier([]);
    _showMidpoints = ValueNotifier(true);
    widget.controller.addListener(_onPointsChanged);
    _onPointsChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPointsChanged);
    _showMidpoints.dispose();
    _interleavedPoints.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        _buildShapeLayer(),
        _buildMidpointMarkers(),
        _buildPointMarkers(),
      ],
    );
  }

  /// Called when the controller's points change.
  ///
  /// This method uses both setState() and ValueNotifier updates because:
  /// - setState() is needed to rebuild DragMarkers (they don't respond to ValueNotifier)
  /// - ValueNotifier is used for efficient shape layer updates
  void _onPointsChanged() {
    // Update midpoints for DragMarkers (requires setState for rebuild)
    setState(() {
      _midpoints = _getMidPoints(widget.controller.points);
    });

    // Update interleaved points for shape rendering (ValueNotifier)
    _interleavedPoints.value = _interleavePointsAndMidpoints(
      points: widget.controller.points,
      midpoints: _midpoints,
    );
  }

  /// Updates interleaved points with throttling to maintain performance during dragging.
  void _throttleUpdateInterleavedPoints() {
    // If throttling is disabled (Duration.zero), update immediately
    if (widget.throttleDuration == Duration.zero) {
      _interleavedPoints.value = _interleavePointsAndMidpoints(
        points: widget.controller.points,
        midpoints: _midpoints,
      );
      return;
    }

    // Apply throttling
    final now = DateTime.now();
    if (_polygonLastUpdatedAt == null ||
        now.difference(_polygonLastUpdatedAt!) >= widget.throttleDuration) {
      _interleavedPoints.value = _interleavePointsAndMidpoints(
        points: widget.controller.points,
        midpoints: _midpoints,
      );
      _polygonLastUpdatedAt = now;
    }
  }

  /// Calculates midpoints between consecutive points.
  ///
  /// For polygon mode, includes midpoint between last and first point.
  /// For line mode, only includes midpoints between consecutive segments.
  List<LatLng> _getMidPoints(List<LatLng> points) {
    if (points.length < 2) {
      return [];
    }

    final midPoints = <LatLng>[];
    final isPolygonMode = widget.controller.mode == PolygonEditorMode.polygon;
    final segmentCount = isPolygonMode ? points.length : points.length - 1;

    for (var i = 0; i < segmentCount; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];

      final latitude =
          current.latitude + (next.latitude - current.latitude) / 2;
      final longitude =
          current.longitude + (next.longitude - current.longitude) / 2;

      midPoints.add(LatLng(latitude, longitude));
    }

    return midPoints;
  }

  /// Interleaves points and midpoints for rendering the complete shape.
  List<LatLng> _interleavePointsAndMidpoints({
    required List<LatLng> points,
    required List<LatLng> midpoints,
  }) {
    if (points.length < 2) {
      return [];
    }

    final interleavedPoints = <LatLng>[];

    // Both polygon and line modes use the same interleaving logic
    // The difference is handled in midpoint calculation, not here
    for (var i = 0; i < points.length; i++) {
      interleavedPoints.add(points[i]);
      if (i < midpoints.length) {
        interleavedPoints.add(midpoints[i]);
      }
    }

    return interleavedPoints;
  }

  /// Builds the shape layer with efficient ValueListenableBuilder updates.
  Widget _buildShapeLayer() {
    if (widget.controller.points.length < 2) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<List<LatLng>>(
      valueListenable: _interleavedPoints,
      builder: (context, interleavedPoints, _) =>
          _buildShapeForMode(interleavedPoints),
    );
  }

  /// Builds either a polygon or polyline based on the current mode.
  Widget _buildShapeForMode(List<LatLng> interleavedPoints) {
    return widget.controller.mode == PolygonEditorMode.line
        ? PolylineLayer(
            polylines: [
              Polyline(
                points: interleavedPoints,
                strokeWidth: widget.style.borderWidth,
                color: widget.style.borderColor,
              ),
            ],
          )
        : PolygonLayer(
            polygons: [
              Polygon(
                points: interleavedPoints,
                color: widget.style.fillColor,
                borderColor: widget.style.borderColor,
                borderStrokeWidth: widget.style.borderWidth,
              ),
            ],
          );
  }

  /// Builds the midpoint markers that can be dragged to create new points.
  Widget _buildMidpointMarkers() {
    return ValueListenableBuilder(
      valueListenable: _showMidpoints,
      builder: (context, showMidpoints, _) {
        if (!showMidpoints || _midpoints.isEmpty) {
          return const SizedBox.shrink();
        }

        return DragMarkers(
          markers: _midpoints
              .mapIndexed((index, point) => _buildMidpointMarker(index, point))
              .toList(),
        );
      },
    );
  }

  /// Builds a single midpoint marker with drag behavior.
  DragMarker _buildMidpointMarker(int index, LatLng point) {
    return DragMarker(
      key: Key('midpoint_$index'),
      point: point,
      size: const Size(20, 20), // Default size, overridden by builder
      onDragUpdate: (details, point) {
        _midpoints[index] = point;
        _throttleUpdateInterleavedPoints();
      },
      onDragEnd: (details, latLng) {
        final insertIndex = widget.controller.mode == PolygonEditorMode.line
            ? index + 1
            : (index + 1) % widget.controller.points.length;
        widget.controller.insertPoint(insertIndex, latLng);
      },
      builder: widget.midpointBuilder ?? defaultMidpointBuilder,
    );
  }

  /// Builds the main point markers that can be dragged to move existing points.
  Widget _buildPointMarkers() {
    return DragMarkers(
      markers: widget.controller.points
          .mapIndexed((index, point) => _buildPointMarker(index, point))
          .toList(),
    );
  }

  /// Builds a single point marker with drag and long-press behavior.
  DragMarker _buildPointMarker(int index, LatLng point) {
    return DragMarker(
      key: Key('point_$index'),
      point: point,
      size: const Size(24, 24), // Default size, overridden by builder
      onLongPress: (latLng) {
        widget.controller.removePoint(index);
      },
      onDragStart: (details, _) {
        _showMidpoints.value = false;
      },
      onDragUpdate: (details, point) {
        widget.controller.updatePoint(index, point);
      },
      onDragEnd: (details, _) {
        _showMidpoints.value = true;
      },
      builder: widget.pointBuilder ?? defaultPointBuilder,
    );
  }
}
