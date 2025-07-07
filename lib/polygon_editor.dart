/// A high-quality, performant polygon and polyline editor for Flutter Map applications.
///
/// This package provides an intuitive, customizable editor that allows users to
/// create, edit, and manipulate polygons and polylines directly on interactive maps.
///
/// ## Features
///
/// - **Dual Mode Support**: Both polygon and polyline editing modes
/// - **Interactive Editing**: Drag markers to move points
/// - **Point Management**: Add, remove, and insert points
/// - **Midpoint Insertion**: Click midpoints to add new vertices
/// - **Customizable Appearance**: Custom styles and marker builders
/// - **Controller Pattern**: Clean separation of state and UI
/// - **Performance Optimized**: ValueNotifier pattern, efficient rendering
/// - **Memory Safe**: Proper disposal and listener management
/// - **Type Safe**: Full Dart null safety support
///
/// ## Usage
///
/// ```dart
/// class MapWithEditor extends StatefulWidget {
///   @override
///   _MapWithEditorState createState() => _MapWithEditorState();
/// }
///
/// class _MapWithEditorState extends State<MapWithEditor> {
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
///         TileLayer(/* ... */),
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
library;

export 'polygon_editor/default_markers.dart';
export 'polygon_editor/polygon_editor.dart';
export 'polygon_editor/polygon_editor_controller.dart';
export 'polygon_editor/polygon_editor_style.dart';