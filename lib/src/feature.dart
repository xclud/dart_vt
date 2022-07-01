import 'geometry.dart';
import 'value.dart';

/// Features are described in section 4.2 of the specification.
class Feature {
  /// Default constructor.
  const Feature({
    required this.id,
    required this.geometries,
    required this.properties,
  });

  /// Id of this feature.
  final int id;

  /// Geometries of this feature.
  final List<Geometry> geometries;

  /// Properties of this feature.
  final Map<String, Value> properties;
}
