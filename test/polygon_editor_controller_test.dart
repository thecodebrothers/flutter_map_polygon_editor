import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_polygon_editor/polygon_editor.dart';

void main() {
  group('PolygonEditorController', () {
    late PolygonEditorController controller;

    setUp(() {
      controller = PolygonEditorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('ignores invalid indices', () {
      final point = LatLng(51.5074, -0.1278);
      controller.addPoint(point);
      
      // Try invalid operations
      controller.insertPoint(-1, LatLng(0, 0));
      controller.insertPoint(5, LatLng(0, 0));
      controller.updatePoint(-1, LatLng(0, 0));
      controller.updatePoint(5, LatLng(0, 0));
      controller.removePoint(-1);
      controller.removePoint(5);
      
      // Should remain unchanged
      expect(controller.points, [point]);
    });

    test('removeLast returns null when empty', () {
      final removed = controller.removeLast();
      expect(removed, isNull);
      expect(controller.points, isEmpty);
    });

    test('setPoints creates copy to prevent external mutation', () {
      final originalPoints = [LatLng(51.5074, -0.1278)];
      controller.setPoints(originalPoints);
      
      // Modify original list
      originalPoints.add(LatLng(51.5174, -0.1178));
      
      // Controller should not be affected
      expect(controller.points.length, 1);
    });
  });
}