import 'package:fixnum/fixnum.dart';

/// Variant type encoding. Exactly one of these values must be present in a valid message.
/// The use of values is described in section 4.1 of the specification.
class Value {
  const Value({
    this.stringValue,
    this.floatValue,
    this.doubleValue,
    this.intValue,
    this.uintValue,
    this.sintValue,
    this.boolValue,
  });

  final String? stringValue;
  final double? floatValue;
  final double? doubleValue;
  final Int64? intValue;
  final Int64? uintValue;
  final Int64? sintValue;
  final bool? boolValue;

  @override
  String toString() {
    if (floatValue != null) return floatValue!.toString();
    if (doubleValue != null) return doubleValue!.toString();
    if (intValue != null) return intValue!.toString();
    if (uintValue != null) return uintValue!.toString();
    if (sintValue != null) return sintValue!.toString();
    if (boolValue != null) return boolValue!.toString();
    if (stringValue != null) return stringValue!;

    return '';
  }
}
