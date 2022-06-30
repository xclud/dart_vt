import 'feature.dart';
// import 'value.dart';

class Layer {
  const Layer({
    required this.name,
    required this.extent,
    required this.version,
    // required this.keys,
    // required this.values,
    required this.features,
  });

  /// Generally the name the locals call the feature, in the local language script.
  final String name;
  final int extent;
  final int version;
  // final List<String> keys;
  // final List<Value> values;
  final List<Feature> features;
}
