import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';

import 'default_markers.dart';
import 'polygon_editor_controller.dart';
import 'polygon_editor_style.dart';

/// Interactive polygon editor for Flutter Map.
///
/// Allows users to create and edit polygons with a two-stage process:
/// 1. Creation mode: Click to add points, with a line following the cursor
/// 2. Editing mode: Drag existing points and midpoints to modify the polygon
///
/// ```dart
/// class _MapPageState extends State<MapPage> {
///   late final PolygonEditorController _controller;
///   final ValueNotifier<LatLng?> _cursorPosition = ValueNotifier(null);
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
///     _cursorPosition.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return FlutterMap(
///       options: MapOptions(
///         onTap: (tapPosition, latLng) {
///           if (_controller.state == PolygonEditingState.creating) {
///             _controller.addPoint(latLng);
///           }
///         },
///         onPointerMove: (pointerEvent, latLng) {
///           if (_controller.state == PolygonEditingState.creating) {
///             _cursorPosition.value = latLng;
///           }
///         },
///         onPointerExit: (pointerEvent, latLng) {
///           _cursorPosition.value = null;
///         },
///       ),
///       children: [
///         TileLayer(urlTemplate: '...'),
///         PolygonEditor(
///           controller: _controller,
///           cursorPosition: _cursorPosition,
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
    this.cursorPosition,
    this.pointBuilder,
    this.midpointBuilder,
    this.style = const PolygonEditorStyle(),
    this.throttleDuration = const Duration(milliseconds: 16),
    super.key,
  });

  /// The controller that manages the polygon data and editing operations.
  final PolygonEditorController controller;

  /// Cursor position notifier for drawing the line to mouse cursor during creation.
  final ValueNotifier<LatLng?>? cursorPosition;

  /// Custom builder for point markers. If null, uses [defaultPointBuilder].
  ///
  /// The builder receives the context, position, drag state, and start point flag.
  final Widget Function(BuildContext context, LatLng position, bool isDragging,
      bool isStartPoint)? pointBuilder;

  /// Custom builder for midpoint markers. If null, uses [defaultMidpointBuilder].
  ///
  /// The builder receives the context, position, and drag state of the marker.
  final Widget Function(BuildContext context, LatLng position, bool isDragging)?
      midpointBuilder;

  /// The visual styling configuration for the polygon.
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

  @override
  void initState() {
    super.initState();
    _showMidpoints = ValueNotifier(true);
    widget.controller.addListener(_onPointsChanged);
    _onPointsChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPointsChanged);
    _showMidpoints.dispose();
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
  void _onPointsChanged() {
    setState(() {
      _midpoints = _getMidPoints(widget.controller.points);
    });
  }

  /// Calculates midpoints between consecutive points.
  /// Only used in editing mode.
  List<LatLng> _getMidPoints(List<LatLng> points) {
    if (points.length < 2 ||
        widget.controller.state != PolygonEditingState.editing) {
      return [];
    }

    final midPoints = <LatLng>[];

    for (var i = 0; i < points.length; i++) {
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

  /// Builds the shape layer with different rendering for creating vs editing modes.
  Widget _buildShapeLayer() {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [widget.controller, widget.cursorPosition ?? ValueNotifier(null)]),
      builder: (context, _) {
        final points = widget.controller.points;
        if (points.isEmpty) return const SizedBox.shrink();

        if (widget.controller.state == PolygonEditingState.creating) {
          final List<Widget> layers = [];

          if (points.length >= 3) {
            layers.add(
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: points,
                    color: widget.style.fillColor,
                    borderColor: widget.style.borderColor,
                    borderStrokeWidth: widget.style.borderWidth,
                  ),
                ],
              ),
            );
          }

          if (widget.cursorPosition?.value != null && points.isNotEmpty) {
            layers.add(
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [points.last, widget.cursorPosition!.value!],
                    strokeWidth: widget.style.borderWidth,
                    color: widget.style.borderColor,
                  ),
                ],
              ),
            );
          }

          if (points.length >= 2) {
            layers.insert(
              0,
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: widget.style.borderWidth,
                    color: widget.style.borderColor,
                  ),
                ],
              ),
            );
          }

          return Stack(children: layers);
        } else {
          return PolygonLayer(
            polygons: [
              Polygon(
                points: points,
                color: widget.style.fillColor,
                borderColor: widget.style.borderColor,
                borderStrokeWidth: widget.style.borderWidth,
              ),
            ],
          );
        }
      },
    );
  }

  /// Builds the midpoint markers that can be dragged to create new points.
  /// Only visible in editing mode.
  Widget _buildMidpointMarkers() {
    if (widget.controller.state != PolygonEditingState.editing) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: _showMidpoints,
      builder: (context, showMidpoints, _) {
        if (!showMidpoints || _midpoints.isEmpty) {
          return const SizedBox.shrink();
        }

        return DragMarkers(
          markers: _midpoints
              .asMap()
              .entries
              .map((entry) => _buildMidpointMarker(entry.key, entry.value))
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
      size: widget.style.midpointSize,
      onDragUpdate: (details, point) {
        _midpoints[index] = point;
      },
      onDragEnd: (details, latLng) {
        final insertIndex = (index + 1) % widget.controller.points.length;
        widget.controller.insertPoint(insertIndex, latLng);
      },
      builder: widget.midpointBuilder ?? defaultMidpointBuilder,
    );
  }

  /// Builds the main point markers that can be dragged to move existing points.
  Widget _buildPointMarkers() {
    return DragMarkers(
      markers: widget.controller.points
          .asMap()
          .entries
          .map((entry) => _buildPointMarker(entry.key, entry.value))
          .toList(),
    );
  }

  /// Builds a single point marker with drag and interaction behavior.
  DragMarker _buildPointMarker(int index, LatLng point) {
    final bool isStartPoint = index == 0;
    final bool isCreating =
        widget.controller.state == PolygonEditingState.creating;

    return DragMarker(
      key: Key('point_$index'),
      point: point,
      size: widget.style.pointSize,
      onLongPress: (latLng) {
        if (!isCreating && widget.controller.points.length > 3) {
          widget.controller.removePoint(index);
        }
      },
      onDragStart: (details, _) {
        if (!isCreating) {
          _showMidpoints.value = false;
        }
      },
      onDragUpdate: (details, point) {
        widget.controller.updatePoint(index, point);
      },
      onDragEnd: (details, _) {
        if (!isCreating) {
          _showMidpoints.value = true;
        }
      },
      builder: (context, latLng, _) {
        return GestureDetector(
          onTap: () {
            if (isStartPoint &&
                isCreating &&
                widget.controller.points.length >= 3) {
              widget.controller.setState(PolygonEditingState.editing);
            }
          },
          child: (widget.pointBuilder ?? defaultPointBuilder)(
            context,
            point,
            false,
            isStartPoint && isCreating,
          ),
        );
      },
    );
  }
}
