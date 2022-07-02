import 'dart:math';
import 'dart:typed_data';

import 'generated/vector_tile.pb.dart' as raw;
import 'feature.dart';
import 'geometry.dart';
import 'layer.dart';
import 'value.dart';

export 'feature.dart';
export 'geometry.dart';
export 'layer.dart';
export 'value.dart';

//const int _moveTo = 1;
const int _lineTo = 2;
const int _closePath = 7;

/// Vector tile containing multiple layers.
class VectorTile {
  const VectorTile({
    required this.layers,
  });

  /// Decodes the given bytes (`.mvt`/`.pbf`) to a [VectorTile]
  factory VectorTile.fromBytes({required Uint8List bytes}) {
    final tile = raw.VectorTile.fromBuffer(bytes);
    List<Layer> layers = tile.layers.map(_decodeLayer).toList();
    return VectorTile(layers: layers);
  }

  /// Layers of this VectorTile.
  final List<Layer> layers;
}

Layer _decodeLayer(raw.Layer layer) {
  List<Value> values = layer.values.map((value) {
    return Value(
      stringValue: value.hasStringValue() ? value.stringValue : null,
      floatValue: value.hasFloatValue() ? value.floatValue : null,
      doubleValue: value.hasDoubleValue() ? value.doubleValue : null,
      intValue: value.hasIntValue() ? value.intValue : null,
      uintValue: value.hasUintValue() ? value.uintValue : null,
      sintValue: value.hasSintValue() ? value.sintValue : null,
      boolValue: value.hasBoolValue() ? value.boolValue : null,
    );
  }).toList();
  List<Feature> features = layer.features.map((feature) {
    final geometry = _decodeGeometry(feature.geometry, feature.type);
    final properties = _decodeProperties(layer.keys, values, feature.tags);

    return Feature(
      id: feature.id.toInt(),
      geometries: geometry,
      properties: properties,
    );
  }).toList();

  return Layer(
    name: layer.name,
    extent: layer.extent,
    version: layer.version,
    // keys: layer.keys.toList(),
    // values: values,
    features: features,
  );
}

Point<int> _toPoint(List<int> x) {
  assert(x.length == 2);
  return Point<int>(x[0], x[1]);
}

List<Geometry> _decodeGeometry(
  List<int> geometries,
  raw.GeomType type,
) {
  switch (type) {
    case raw.GeomType.POINT:
      final coords = _decodePoint(geometries);

      return coords
          .map((point) => Geometry.point(coordinates: _toPoint(point)))
          .toList();

    case raw.GeomType.LINESTRING:
      final coords = _decodeLineString(geometries);

      return coords
          .map(
            (line) =>
                Geometry.lineString(coordinates: line.map(_toPoint).toList()),
          )
          .toList();

    case raw.GeomType.POLYGON:
      final coords = _decodePolygon(geometries);

      return coords
          .map(
            (polygon) => Geometry.polygon(
              coordinates: polygon
                  .map(
                    (ring) => ring.map(_toPoint).toList(),
                  )
                  .toList(),
            ),
          )
          .toList();

    default:
      return [];
  }
}

/// Decode Point geometry
///
/// @docs: https://github.com/mapbox/vector-tile-spec/tree/master/2.1#4342-point-geometry-type
List<List<int>> _decodePoint(List<int> geometries) {
  int length = 0;
  int commandId = 0;
  int x = 0;
  int y = 0;
  bool isX = true;
  List<List<int>> coords = [];
  List<int> point = [];

  for (var commandInt in geometries) {
    if (length <= 0) {
      _Command command = _Command.fromInt(commandInt);

      commandId = command.id;
      length = command.count;
    } else if (commandId != _closePath) {
      if (isX) {
        x += _Command.zigZagDecode(commandInt);
        point.add(x);
        isX = false;
      } else {
        y += _Command.zigZagDecode(commandInt);
        point.add(y);
        length -= 1;
        isX = true;
      }
    }

    if (length <= 0) {
      coords.add(point);
      point = [];
    }
  }

  return coords;
}

/// Decode LineString geometry
///
/// @docs: https://github.com/mapbox/vector-tile-spec/tree/master/2.1#4343-linestring-geometry-type
List<List<List<int>>> _decodeLineString(List<int> geometries) {
  int length = 0;
  int commandId = 0;
  int x = 0;
  int y = 0;
  bool isX = true;
  List<List<List<int>>> coords = [];
  List<List<int>> ring = [];

  for (var commandInt in geometries) {
    if (length <= 0) {
      _Command command = _Command.fromInt(commandInt);

      commandId = command.id;
      length = command.count;
    } else if (commandId != _closePath) {
      if (isX) {
        x += _Command.zigZagDecode(commandInt);
        isX = false;
      } else {
        y += _Command.zigZagDecode(commandInt);
        ring.add([x, y]);
        length -= 1;
        isX = true;
      }
    }

    if (length <= 0 && commandId == _lineTo) {
      coords.add(ring);
      ring = [];
    }
  }

  return coords;
}

/// Decode polygon geometry
///
/// @docs: https://github.com/mapbox/vector-tile-spec/tree/master/2.1#4344-polygon-geometry-type
List<List<List<List<int>>>> _decodePolygon(List<int> geometries) {
  int length = 0;
  int commandId = 0;
  int x = 0;
  int y = 0;
  bool isX = true;
  List<List<List<List<int>>>> polygons = [];
  List<List<List<int>>> coords = [];
  List<List<int>> ring = [];

  for (var commandInt in geometries) {
    if (length <= 0 || commandId == _closePath) {
      _Command command = _Command.fromInt(commandInt);

      commandId = command.id;
      length = command.count;

      if (commandId == _closePath) {
        coords.add(ring.reversed.toList());
        ring = [];
      }
    } else if (commandId != _closePath) {
      if (isX) {
        x += _Command.zigZagDecode(commandInt);
        isX = false;
      } else {
        y += _Command.zigZagDecode(commandInt);
        ring.add([x, y]);
        length -= 1;
        isX = true;
      }
    }

    if (length <= 0 && commandId == _lineTo) {
      if (coords.isNotEmpty && _isCCW(ring)) {
        polygons.add(coords);
        coords = [];
      }
    }
  }

  polygons.add(coords);
  return polygons;
}

/// Gets properties from feature tags and key/value pairs got from parent layer
Map<String, Value> _decodeProperties(
  List<String> keys,
  List<Value> values,
  List<int> tags,
) {
  int length = tags.length;
  Map<String, Value> properties = {};

  for (int i = 0; i < length; i = i + 2) {
    final keyIndex = tags[i];
    final valueIndex = tags[i + 1];

    final key = keys[keyIndex];
    final value = values[valueIndex];

    properties[key] = value;
  }

  return properties;
}

/// Command and its utils
class _Command {
  const _Command({required this.id, required this.count});

  const _Command.fromInt(int command)
      : this(
          id: command & 0x7,
          count: command >> 3,
        );

  final int id;
  final int count;

  // static int zigZagEncode(int val) {
  //   return (val << 1) ^ (val >> 31);
  // }

  static int zigZagDecode(int parameterInteger) {
    return ((parameterInteger >> 1) ^ (-(parameterInteger & 1)));
  }
}

/// Implements https://en.wikipedia.org/wiki/Shoelace_formula
bool _isCCW(List<List<int>> ring) {
  int i = -1;
  int ccw = ring.sublist(1, ring.length - 1).fold(0, (sum, point) {
    i++;
    return sum + (point[0] - ring[i][0]) * (point[1] + ring[i][1]);
  });

  return ccw < 0;
}
