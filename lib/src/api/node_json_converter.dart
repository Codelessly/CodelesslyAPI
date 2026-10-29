import 'dart:convert';
import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

import 'nodes/nodes.dart';

/// A deserializer function that takes a map as input and deserializes it into
/// a [BaseNode].
typedef JsonNodeDeserializer = BaseNode? Function(Map<dynamic, dynamic> json);

/// A malformed or unsupported wire payload. The caller keeps [raw] unchanged.
class UnresolvedNodeSchema implements Exception {
  /// Captures the source payload before applying defaults.
  UnresolvedNodeSchema(this.reason, Map json)
    : raw = jsonDecode(jsonEncode(json)) as Map;

  /// Machine-readable reason for refusing the wire schema.
  final String reason;

  /// Original top-level JSON.
  final Map raw;

  @override
  String toString() => 'UnresolvedNodeSchema: $reason';
}

/// Converts between registered node types and their JSON representations.
class NodeJsonConverter implements JsonConverter<BaseNode?, Map> {
  NodeJsonConverter._() {
    _registerDeserializers();
  }

  /// Singleton instance.
  static final NodeJsonConverter instance = NodeJsonConverter._();

  /// Returns the singleton instance.
  factory NodeJsonConverter() => instance;

  late final Map<String, JsonNodeDeserializer> _registry;

  void _registerDeserializers() {
    _registry = {
      'root': RootNode.fromJson,
      'frame': FrameNode.fromJson,
      'text': TextNode.fromJson,
      'canvas': CanvasNode.fromJson,
      'rectangle': RectangleNode.fromJson,
      'spacer': SpacerNode.fromJson,
      'icon': IconNode.fromJson,
      'row': RowNode.fromJson,
      'column': ColumnNode.fromJson,
      'singlePlaceholder': SinglePlaceholderNode.fromJson,
      'autoPlaceholder': AutoPlaceholderNode.fromJson,
      'freeformPlaceholder': FreeformPlaceholderNode.fromJson,
      'placeholder': PlaceholderNode.fromJson,
      'elevatedButton': ElevatedButtonNode.fromJson,
      'textButton': TextButtonNode.fromJson,
      'outlinedButton': OutlinedButtonNode.fromJson,
      'iconButton': IconButtonNode.fromJson,
      'filledButton': FilledButtonNode.fromJson,
      'textField': TextFieldNode.fromJson,
      'checkbox': CheckboxNode.fromJson,
      'appBar': AppBarNode.fromJson,
      'navigationBar': NavigationBarNode.fromJson,
      'floatingActionButton': FloatingActionButtonNode.fromJson,
      'switch': SwitchNode.fromJson,
      'radio': RadioNode.fromJson,
      'slider': SliderNode.fromJson,
      'expansionTile': ExpansionTileNode.fromJson,
      'accordion': AccordionNode.fromJson,
      'listTile': ListTileNode.fromJson,
      'embeddedVideo': EmbeddedVideoNode.fromJson,
      'divider': DividerNode.fromJson,
      'loadingIndicator': LoadingIndicatorNode.fromJson,
      'webView': WebViewNode.fromJson,
      'dropdown': DropdownNode.fromJson,
      'progressBar': ProgressBarNode.fromJson,
      'lineChart': LineChartNode.fromJson,
      'barChart': BarChartNode.fromJson,
      'variance': VarianceNode.fromJson,
      'listView': ListViewNode.fromJson,
      'gridView': GridViewNode.fromJson,
      'pageView': PageViewNode.fromJson,
      'tabBar': TabBarNode.fromJson,
      'badge': BadgeNode.fromJson,
      'chip': ChipNode.fromJson,
      'segmentedButton': SegmentedButtonNode.fromJson,
      'external': ExternalComponentNode.fromJson,
    };
  }

  /// Register or replace one custom node deserializer.
  static void registerNode(String type, JsonNodeDeserializer deserializer) {
    if (type.isEmpty) throw ArgumentError('Type cannot be empty.');
    if (instance._registry[type] != null) {
      log('A deserializer for type "$type" already exists. Overwriting...');
    }
    instance._registry[type] = deserializer;
  }

  /// Whether a node type has a decoder.
  static bool isNodeRegistered(String type) =>
      const {'chart', 'gauge', 'signature'}.contains(type) ||
      instance._registry[type] != null;

  static String _requireKind(
    Map json,
    String family,
    String key,
    Set<String> allowed,
    String expected,
  ) {
    if (json['type'] != family) {
      throw UnresolvedNodeSchema('invalid-$family-type', json);
    }
    final kind = json[key];
    if (kind == null) throw UnresolvedNodeSchema('missing-$key', json);
    if (!allowed.contains(kind)) {
      throw UnresolvedNodeSchema('unknown-$key', json);
    }
    if (expected.isNotEmpty && kind != expected) {
      throw UnresolvedNodeSchema('conflicting-$family-kind', json);
    }
    return kind as String;
  }

  /// Validates the canonical chart discriminator without reading shape keys.
  static String validateChartWire(Map json, {required String expectedType}) =>
      _requireKind(json, 'chart', 'chartKind', const {'series', 'plot'}, expectedType);

  /// Validates the canonical gauge discriminator without reading shape keys.
  static String validateGaugeWire(Map json, {required String expectedType}) =>
      _requireKind(json, 'gauge', 'gaugeKind', const {'radial', 'meter'}, expectedType);

  /// Validates the canonical signature coordinate mode without shape guessing.
  static String validateSignatureWire(Map json, {required String expectedType}) =>
      _requireKind(json, 'signature', 'signatureKind',
          const {'strokes', 'normalized'}, expectedType);

  @override
  BaseNode? fromJson(Map json) {
    // Keep independent layout/pulse format validation fail-closed.
    if (json['type'] == 'listView' && json['properties'] is Map) {
      final properties = json['properties'] as Map;
      if (properties['stacked'] == true && properties['layout'] == 'stack') {
        throw UnresolvedNodeSchema('conflicting-list-layout-schema', json);
      }
    }
    final pulse = json['pulse'];
    if (pulse is Map) {
      const relativeKeys = {'minOpacity', 'durationMillis'};
      const motionKeys = {
        'periodMs', 'reverse', 'opacityFrom', 'opacityTo',
        'scaleFrom', 'scaleTo',
      };
      final relative = pulse.keys.any(relativeKeys.contains);
      final motion = pulse.keys.any(motionKeys.contains);
      final kind = pulse['pulseKind'];
      if (kind != null && kind != 'relative' && kind != 'motion') {
        throw UnresolvedNodeSchema('unknown-pulse-kind', json);
      }
      if (relative && motion ||
          kind == 'relative' && motion ||
          kind == 'motion' && relative) {
        throw UnresolvedNodeSchema('conflicting-pulse-schema', json);
      }
      if (kind == null && !relative && !motion) {
        throw UnresolvedNodeSchema('ambiguous-pulse-schema', json);
      }
    }
    switch (json['type']) {
      case 'chart':
        return switch (validateChartWire(json, expectedType: '')) {
          'series' => ChartNode.fromJson(json),
          'plot' => PlotChartNode.fromJson(json),
          _ => throw StateError('Unreachable chart kind'),
        };
      case 'gauge':
        return switch (validateGaugeWire(json, expectedType: '')) {
          'radial' => GaugeNode.fromJson(json),
          'meter' => GaugeMeterNode.fromJson(json),
          _ => throw StateError('Unreachable gauge kind'),
        };
      case 'signature':
        return switch (validateSignatureWire(json, expectedType: '')) {
          'strokes' => SignatureNode.fromJson(json),
          'normalized' => SignatureNormalizedNode.fromJson(json),
          _ => throw StateError('Unreachable signature kind'),
        };
    }
    if (json['type'] == null || _registry[json['type']] == null) {
      throw UnsupportedError('Unsupported node type: ${json["type"]}\n$json');
    }
    return _registry[json['type']]!(
      json['properties'] == null ? {...json, 'properties': const {}} : json,
    );
  }

  @override
  Map toJson(BaseNode? object) => object!.toJson();
}
