import 'package:flutter/material.dart';

/// Configuration class for customizing the appearance of the polygon editor.
///
/// This class allows you to customize the visual appearance of polygons and
/// polylines in the editor, including border width, colors, and fill colors.
class PolygonEditorStyle {
  const PolygonEditorStyle({
    this.borderWidth = 2.0,
    this.borderColor = Colors.red,
    this.fillColor = const Color(0x80FF0000), // Red with 50% opacity
  });

  /// The width of the border stroke. Defaults to 2.0.
  final double borderWidth;

  /// The color of the border stroke. Defaults to [Colors.red].
  final Color borderColor;

  /// The fill color for polygons. Defaults to semi-transparent red.
  /// This property is ignored when editing polylines.
  final Color fillColor;
}