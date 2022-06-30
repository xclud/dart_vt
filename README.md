[![pub package](https://img.shields.io/pub/v/vt.svg)](https://pub.dartlang.org/packages/vt)

Vector Tiles for Dart. Provides `.pbf` parser.

## Features

* Feature
* Geometry
* Layer
* Value
* VectorTile

## Getting started

In your `pubspec.yaml` file add:

```dart
dependencies:
  vt: any
```

## Usage

In your code import:

```dart
import 'package:vt/vt.dart';
```

Then:

```dart
final tile = VectorTile.fromBytes(fileContents);
```

## Additional information

Is package is compatible with version 2.1 of Vector Tile Specification as described here: https://github.com/mapbox/vector-tile-spec/tree/master/2.1
