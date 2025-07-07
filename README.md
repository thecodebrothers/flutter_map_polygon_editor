# Flutter Map Polygon Editor

A polygon and polyline editor for Flutter Map applications. This package provides interactive editing functionality that allows users to create, edit, and manipulate polygons and polylines directly on maps.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_map_polygon_editor: ^1.0.0
  flutter_map: ^8.1.1
  latlong2: ^0.9.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polygon_editor/polygon_editor.dart';
import 'package:latlong2/latlong.dart';

class MapWithEditor extends StatefulWidget {
  @override
  _MapWithEditorState createState() => _MapWithEditorState();
}

class _MapWithEditorState extends State<MapWithEditor> {
  late final PolygonEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PolygonEditorController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(51.5074, -0.1278),
          initialZoom: 10,
          onLongPress: (tapPosition, point) {
            _controller.addPoint(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          PolygonEditor(
            controller: _controller,
            style: PolygonEditorStyle(
              borderColor: Colors.blue,
              fillColor: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Usage

### Basic Setup

1. **Create a controller**:
```dart
final controller = PolygonEditorController();
```

2. **Add the editor to your map**:
```dart
PolygonEditor(
  controller: controller,
)
```

3. **Don't forget to dispose**:
```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### Controller Operations

```dart
// Add points programmatically
controller.addPoint(LatLng(51.5074, -0.1278));

// Switch between modes
controller.setMode(PolygonEditorMode.line);
controller.setMode(PolygonEditorMode.polygon);

// Get current points
List<LatLng> points = controller.points;

// Clear all points
controller.clear();

// Listen to changes
controller.addListener(() {
  print('Points changed: ${controller.points.length}');
});
```

### Customization

#### Custom Styling

```dart
PolygonEditor(
  controller: controller,
  style: PolygonEditorStyle(
    borderWidth: 3.0,
    borderColor: Colors.red,
    fillColor: Colors.red.withOpacity(0.2),
  ),
)
```

#### Custom Markers

```dart
PolygonEditor(
  controller: controller,
  pointBuilder: (context, position, isDragging) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isDragging ? Colors.red : Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  },
  midpointBuilder: (context, position, isDragging) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.add, size: 12, color: Colors.white),
    );
  },
)
```

#### Performance Tuning

```dart
PolygonEditor(
  controller: controller,
  throttleDuration: Duration(milliseconds: 16), // 60 FPS
  // Or disable throttling for maximum responsiveness
  throttleDuration: Duration.zero,
)
```

### User Interactions

- **Long press map**: Add new point
- **Drag point**: Move existing point
- **Long press point**: Remove point
- **Drag midpoint**: Create new point at that position

## API Reference

### PolygonEditorController

| Method | Description |
|--------|-------------|
| `addPoint(LatLng point)` | Adds a point to the end of the list |
| `insertPoint(int index, LatLng point)` | Inserts a point at the specified index |
| `updatePoint(int index, LatLng point)` | Updates an existing point |
| `removePoint(int index)` | Removes a point by index |
| `removeLast()` | Removes and returns the last point |
| `clear()` | Removes all points |
| `setPoints(List<LatLng> points)` | Replaces all points |
| `setMode(PolygonEditorMode mode)` | Switches between polygon and line modes |

### PolygonEditorStyle

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `borderWidth` | `double` | `2.0` | Width of the border stroke |
| `borderColor` | `Color` | `Colors.red` | Color of the border |
| `fillColor` | `Color` | Semi-transparent red | Fill color for polygons |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.