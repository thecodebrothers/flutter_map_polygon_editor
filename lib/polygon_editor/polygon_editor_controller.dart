import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// The editing state for the polygon editor.
enum PolygonEditingState {
  /// The user is actively creating a new polygon by adding points.
  creating,

  /// The user is editing a closed polygon.
  editing,
}

/// Controller for managing polygon editing state.
///
/// Extends [ChangeNotifier] to provide reactive updates when points or state change.
class PolygonEditorController extends ChangeNotifier {
  List<LatLng> _points = [];
  PolygonEditingState _state;

  /// Creates a new controller with the specified editing state.
  ///
  /// Defaults to [PolygonEditingState.creating] if no state is provided.
  PolygonEditorController(
      {PolygonEditingState initialState = PolygonEditingState.creating})
      : _state = initialState;

  /// The current list of points forming the polygon.
  List<LatLng> get points => _points;

  /// The current editing state (creating or editing).
  PolygonEditingState get state => _state;

  /// Changes the editing state and notifies listeners.
  ///
  /// Only notifies if the state actually changes.
  void setState(PolygonEditingState newState) {
    if (_state != newState) {
      _state = newState;
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

  /// Moves all points by the specified offset in latitude and longitude.
  ///
  /// This can be used to implement polygon dragging functionality.
  void movePolygon(double latOffset, double lngOffset) {
    _points = _points
        .map((point) => LatLng(
              point.latitude + latOffset,
              point.longitude + lngOffset,
            ))
        .toList();
    notifyListeners();
  }
}
