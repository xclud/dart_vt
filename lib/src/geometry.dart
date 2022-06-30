import 'dart:math';

abstract class Geometry {
  factory Geometry.point({required Point<int> coordinates}) = PointGeometry;
  factory Geometry.lineString({required List<Point<int>> coordinates}) =
      LineStringGeometry;
  factory Geometry.polygon({required List<List<Point<int>>> coordinates}) =
      PolygonGeometry;

  const Geometry._();
}

/// Point Geometry.
class PointGeometry extends Geometry {
  const PointGeometry({
    required this.coordinates,
  }) : super._();

  final Point<int> coordinates;
}

/// LineString Geometry.
class LineStringGeometry extends Geometry {
  const LineStringGeometry({
    required this.coordinates,
  }) : super._();

  final List<Point<int>> coordinates;
}

/// Polygon Geometry.
class PolygonGeometry extends Geometry {
  const PolygonGeometry({
    required this.coordinates,
  }) : super._();

  final List<List<Point<int>>> coordinates;
}
