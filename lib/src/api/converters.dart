import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'node_json_converter.dart';
import 'nodes/base_node.dart';

/// Top level converter for serializing [DateTime] to [millisecondsSinceEpoch].
class DateTimeConverter extends JsonConverter<DateTime, int?> {
  /// Creates a new instance of [DateTimeConverter].
  const DateTimeConverter();

  @override
  DateTime fromJson(int? json) => deserialize(json);

  @override
  int? toJson(DateTime object) => serialize(object);

  /// Serializes [DateTime] to [int].
  static int? serialize(DateTime object) =>
      object.toUtc().millisecondsSinceEpoch;

  /// Deserializes [int] to [DateTime].
  static DateTime deserialize(int? json) {
    return json != null
        ? DateTime.fromMillisecondsSinceEpoch(json).toLocal()
        : DateTime.now();
  }
}

/// Top level converter for serializing [DateTime] to [millisecondsSinceEpoch].
class NullableDateTimeConverter extends JsonConverter<DateTime?, int?> {
  /// Creates a new instance of [NullableDateTimeConverter].
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(int? json) => deserialize(json);

  @override
  int? toJson(DateTime? object) => serialize(object);

  /// Serializes [DateTime] to [int].
  static int? serialize(DateTime? object) =>
      object?.toUtc().millisecondsSinceEpoch;

  /// Deserializes [int] to [DateTime].
  static DateTime? deserialize(int? json) {
    return json != null
        ? DateTime.fromMillisecondsSinceEpoch(json).toLocal()
        : null;
  }
}

/// Top level converter for serializing Nodes map to and from JSON.
class CanvasesMapConverter
    extends
        JsonConverter<
          Map<String, Map<String, BaseNode>>,
          Map<String, dynamic>
        > {
  /// Creates a new instance of [CanvasesMapConverter].
  const CanvasesMapConverter();

  @override
  Map<String, Map<String, BaseNode>> fromJson(Map<String, dynamic> json) =>
      deserialize(json);

  @override
  Map<String, dynamic> toJson(Map<String, Map<String, BaseNode>> object) =>
      serialize(object);

  /// Top level function to deserialize a JSON Map into a map of node ID to node.
  static Map<String, Map<String, BaseNode>> deserialize(
    Map<String, dynamic> value,
  ) => {
    for (final MapEntry(key: key, value: value) in value.entries)
      key: NodesMapConverter.deserialize(value),
  };

  /// Top level function to serialize a map of node ID to node into a JSON map.
  static Map<String, dynamic> serialize(
    Map<String, Map<String, BaseNode>> canvases,
  ) => {
    for (final MapEntry(key: key, value: value) in canvases.entries)
      key: NodesMapConverter.serialize(value),
  };
}

/// Top level converter for serializing Nodes map to and from JSON.
class NodesMapConverter
    extends JsonConverter<Map<String, BaseNode>, Map<String, dynamic>> {
  /// Creates a new instance of [NodesMapConverter].
  const NodesMapConverter();

  @override
  Map<String, BaseNode> fromJson(Map<String, dynamic> json) =>
      deserialize(json);

  @override
  Map<String, dynamic> toJson(Map<String, BaseNode> object) =>
      serialize(object);

  /// Top level function to deserialize a JSON Map into a map of node ID to node.
  static Map<String, BaseNode> deserialize(Map<String, dynamic> value) => {
    for (final MapEntry(key: key, value: value) in value.entries)
      key: NodeJsonConverter.instance.fromJson(value)!,
  };

  /// Top level function to serialize a map of node ID to node into a JSON map.
  static Map<String, dynamic> serialize(Map<String, BaseNode> nodes) => {
    for (final MapEntry(key: key, value: value) in nodes.entries)
      key: NodeJsonConverter.instance.toJson(value),
  };
}

/// Top level converter for serializing map of DateTime.
class DateTimeMapConverter
    extends JsonConverter<Map<String, DateTime>, Map<String, dynamic>> {
  /// Creates a new instance of [DateTimeMapConverter].
  const DateTimeMapConverter();

  @override
  Map<String, DateTime> fromJson(Map<String, dynamic> json) =>
      deserialize(json);

  @override
  Map<String, dynamic> toJson(Map<String, DateTime> object) =>
      serialize(object);

  /// Top level function for deserializing the millis from JSON as the values of
  /// a map to [DateTime].
  static Map<String, DateTime> deserialize(Map<String, dynamic> value) => {
    for (final MapEntry(key: key, value: value) in value.entries)
      key: DateTime.fromMillisecondsSinceEpoch(value).toLocal(),
  };

  /// Top level function for serializing a map of with [DateTime] as the values
  /// to [millisecondsSinceEpoch].
  static Map<String, int> serialize(Map<String, DateTime> dates) => {
    for (final MapEntry(key: key, value: value) in dates.entries)
      key: value.toUtc().millisecondsSinceEpoch,
  };
}

/// Compares two lists for equality.
bool listsEqual(List? a, List? b) => const ListEquality().equals(a, b);

/// Compares two maps for equality.
bool mapsEqual(Map? a, Map? b) => const MapEquality().equals(a, b);

/// Compares two sets for equality.
bool setsEqual(Set? a, Set? b) => const SetEquality().equals(a, b);

/// Determines whether a field should be serialized based on its value.
///
/// Returns `false` if [value] is null.
/// Returns `true` if [serializeDefaultValues] is true.
/// Otherwise, compares [value] with [defaultValue] to determine if serialization is needed.
bool shouldSerialize(
  String key,
  dynamic value,
  dynamic jsonValue,
  dynamic defaultValue,
  bool serializeDefaultValues,
) {
  if (value == null) return false;
  if (value is List && defaultValue is List) {
    return serializeDefaultValues || !listsEqual(value, defaultValue);
  } else if (value is Map && defaultValue is Map) {
    return serializeDefaultValues || !mapsEqual(value, defaultValue);
  } else if (value is Set && defaultValue is Set) {
    return serializeDefaultValues || !setsEqual(value, defaultValue);
  }
  return serializeDefaultValues || value != defaultValue;
}
