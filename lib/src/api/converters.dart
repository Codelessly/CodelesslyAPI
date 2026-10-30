import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'node_json_converter.dart';
import 'nodes/base_node.dart';
import 'nodes/modal_node.dart';
import 'nodes/tabs_node.dart';

/// A document whose node schema cannot be determined safely. No parsed tree
/// is returned: the caller must retain [raw] outside the typed node map and
/// refuse to save it until the ambiguity is reviewed.
class UnresolvedDocumentSchema implements Exception {
  /// Snapshots the complete original document and the failing node key.
  UnresolvedDocumentSchema(this.reason, this.nodeKey, Map<String, dynamic> json)
    : raw = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

  /// Machine-readable node schema failure.
  final String reason;

  /// Key of the unresolved node in its node map.
  final String nodeKey;

  /// Full unmodified nodes map or canvases map passed to the converter.
  final Map<String, dynamic> raw;

  @override
  String toString() => 'UnresolvedDocumentSchema: $reason at $nodeKey';
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
  ) {
    try {
      return {
        for (final MapEntry(key: key, value: canvas) in value.entries)
          key: NodesMapConverter.deserialize(canvas),
      };
    } on UnresolvedDocumentSchema catch (error) {
      throw UnresolvedDocumentSchema(error.reason, error.nodeKey, value);
    }
  }

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
  static Map<String, BaseNode> deserialize(Map<String, dynamic> value) {
    final result = <String, BaseNode>{};
    for (final entry in value.entries) {
      try {
        result[entry.key] = NodeJsonConverter.instance.fromJson(entry.value)!;
      } on UnresolvedNodeSchema catch (error) {
        throw UnresolvedDocumentSchema(error.reason, entry.key, value);
      }
    }
    for (final entry in result.entries) {
      final node = entry.value;
      if (node is TabsNode &&
          node.tabs.any((tab) => !result.containsKey(tab.child))) {
        throw UnresolvedDocumentSchema('unknown-tabs-child', entry.key, value);
      }
      if (node is ModalNode &&
          (!result.containsKey(node.trigger) ||
              !result.containsKey(node.content))) {
        throw UnresolvedDocumentSchema('unknown-modal-child', entry.key, value);
      }
    }
    return result;
  }

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

/// Converts a [DateTime] to and from milliseconds since epoch.
///
/// Times are written in UTC and read back as local time. A missing value
/// reads as [DateTime.now].
class DateTimeConverter extends JsonConverter<DateTime, int?> {
  /// Creates a new instance of [DateTimeConverter].
  const DateTimeConverter();

  @override
  DateTime fromJson(int? json) => deserialize(json);

  @override
  int? toJson(DateTime object) => serialize(object);

  /// Serializes [DateTime] to milliseconds since epoch.
  static int? serialize(DateTime object) =>
      object.toUtc().millisecondsSinceEpoch;

  /// Deserializes milliseconds since epoch to [DateTime].
  static DateTime deserialize(int? json) => json != null
      ? DateTime.fromMillisecondsSinceEpoch(json).toLocal()
      : DateTime.now();
}
