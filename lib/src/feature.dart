import 'geometry.dart';
import 'value.dart';

class Feature {
  const Feature({
    required this.id,
    required this.geometries,
    required this.properties,
  });

  final int id;
  final List<Geometry> geometries;
  final Map<String, Value> properties;
}
