import 'dart:math';

/// Geometry.
abstract class Geometry {
  /// Creates a PointGeometry.
  factory Geometry.point({required Point<int> coordinates}) = PointGeometry._;

  /// Creates a LineStringGeometry.
  factory Geometry.lineString({required List<Point<int>> coordinates}) =
      LineStringGeometry._;

  /// Creates a PolygonGeometry.
  factory Geometry.polygon({required List<List<Point<int>>> coordinates}) =
      PolygonGeometry._;

  /// Private constructor.
  const Geometry._();
}

/// Point Geometry.
class PointGeometry extends Geometry {
  const PointGeometry._({
    required this.coordinates,
  }) : super._();

  /// The point in the 2D space.
  final Point<int> coordinates;
}

/// LineString Geometry.
class LineStringGeometry extends Geometry {
  const LineStringGeometry._({
    required this.coordinates,
  }) : super._();

  /// List of points in the 2D space.
  final List<Point<int>> coordinates;
}

/// Polygon Geometry.
class PolygonGeometry extends Geometry {
  const PolygonGeometry._({
    required this.coordinates,
  }) : super._();

  /// List of rings of polygons in the 2D space.
  final List<List<Point<int>>> coordinates;
}
