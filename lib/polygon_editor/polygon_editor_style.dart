import 'package:flutter/material.dart';

/// Configuration class for customizing the appearance of the polygon editor.
///
/// This class allows you to customize the visual appearance of polygons and
/// polylines in the editor, including border width, colors, fill colors,
/// and marker sizes.
class PolygonEditorStyle {
  const PolygonEditorStyle({
    this.borderWidth = 2.0,
    this.borderColor = Colors.red,
    this.fillColor = const Color(0x80FF0000), // Red with 50% opacity
    this.pointSize = const Size(24, 24),
    this.midpointSize = const Size(20, 20),
  });

  /// The width of the border stroke. Defaults to 2.0.
  final double borderWidth;

  /// The color of the border stroke. Defaults to [Colors.red].
  final Color borderColor;

  /// The fill color for polygons. Defaults to semi-transparent red.
  /// This property is ignored when editing polylines.
  final Color fillColor;

  /// The size of point markers. Defaults to 24x24.
  final Size pointSize;

  /// The size of midpoint markers. Defaults to 20x20.
  final Size midpointSize;

  PolygonEditorStyle copyWith({
    double? borderWidth,
    Color? borderColor,
    Color? fillColor,
    Size? pointSize,
    Size? midpointSize,
  }) {
    return PolygonEditorStyle(
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      fillColor: fillColor ?? this.fillColor,
      pointSize: pointSize ?? this.pointSize,
      midpointSize: midpointSize ?? this.midpointSize,
    );
  }
}