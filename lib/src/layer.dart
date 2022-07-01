import 'feature.dart';
// import 'value.dart';

/// Layers are described in section 4.1 of the specification.
class Layer {
  /// Default constructor.
  const Layer({
    required this.name,
    required this.extent,
    required this.version,
    required this.features,
  });

  /// Generally the name the locals call the feature, in the local language script.
  final String name;

  /// Although this is an "optional" field it is required by the specification.
  /// See https://github.com/mapbox/vector-tile-spec/issues/47
  final int extent;

  /// Any compliant implementation must first read the version
  /// number encoded in this message and choose the correct
  /// implementation for this version number before proceeding to
  /// decode other parts of this message.
  final int version;

  /// The actual features in this tile.
  final List<Feature> features;
}
