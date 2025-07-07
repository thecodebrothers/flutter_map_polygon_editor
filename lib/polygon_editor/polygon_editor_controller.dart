import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// The editing mode for the polygon editor.
enum PolygonEditorMode { 
  /// Line mode creates polylines (open paths).
  line, 
  /// Polygon mode creates closed shapes.
  polygon 
}

/// Controller for managing polygon and polyline editing state.
/// 
/// Extends [ChangeNotifier] to provide reactive updates when points or mode change.
class PolygonEditorController extends ChangeNotifier {
  List<LatLng> _points = [];
  PolygonEditorMode _mode;

  /// Creates a new controller with the specified editing mode.
  /// 
  /// Defaults to [PolygonEditorMode.polygon] if no mode is provided.
  PolygonEditorController({PolygonEditorMode mode = PolygonEditorMode.polygon}) 
    : _mode = mode;

  /// The current list of points forming the polygon or polyline.
  List<LatLng> get points => _points;
  
  /// The current editing mode (polygon or line).
  PolygonEditorMode get mode => _mode;

  /// Changes the editing mode and notifies listeners.
  /// 
  /// Only notifies if the mode actually changes.
  void setMode(PolygonEditorMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  /// Adds a new point to the end of the points list.
  void addPoint(LatLng point) {
    _points.add(point);
    notifyListeners();
  }

  /// Inserts a point at the specified index.
  /// 
  /// The [index] must be between 0 and [points.length] (inclusive).
  /// Does nothing if the index is out of bounds.
  void insertPoint(int index, LatLng point) {
    if (index >= 0 && index <= _points.length) {
      _points.insert(index, point);
      notifyListeners();
    }
  }

  /// Updates the point at the specified index with a new position.
  /// 
  /// Does nothing if the index is out of bounds.
  void updatePoint(int index, LatLng point) {
    if (index >= 0 && index < _points.length) {
      _points[index] = point;
      notifyListeners();
    }
  }

  /// Removes the point at the specified index.
  /// 
  /// Does nothing if the index is out of bounds.
  void removePoint(int index) {
    if (index >= 0 && index < _points.length) {
      _points.removeAt(index);
      notifyListeners();
    }
  }

  /// Removes and returns the last point from the list.
  /// 
  /// Returns null if the list is empty.
  LatLng? removeLast() {
    if (_points.isNotEmpty) {
      final point = _points.removeLast();
      notifyListeners();
      return point;
    }
    return null;
  }

  /// Removes all points from the list.
  void clear() {
    _points.clear();
    notifyListeners();
  }

  /// Replaces all points with a new list of points.
  /// 
  /// Creates a copy of the provided list to avoid external modifications.
  void setPoints(List<LatLng> points) {
    _points = [...points];
    notifyListeners();
  }
}