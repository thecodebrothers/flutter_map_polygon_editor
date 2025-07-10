# Changelog

## [0.1.2] - 2025-07-10

### Added

- Customizable marker sizes via `pointSize` and `midpointSize` properties in `PolygonEditorStyle`
- `copyWith` method to `PolygonEditorStyle` for flexible style variations

### Changed

- Default marker builders now fill available space instead of using hardcoded sizes
- Marker sizing is now controlled through the style system for better consistency

## [0.1.1] - 2025-07-10

### Changed

- Lower Dart SDK requirement from ^3.8.1 to >=3.6.0 <4.0.0
- Add Flutter version requirement >=3.27.0 to align with flutter_map dependencies
- Add demo GIFs showing polygon and polyline editing functionality

### Fixed

- SDK version compatibility issues reported in #1

## [0.1.0] - 2025-07-07

### Added

- Initial release of flutter_map_polygon_editor