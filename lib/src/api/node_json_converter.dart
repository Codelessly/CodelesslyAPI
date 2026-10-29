import 'dart:convert';
import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

import 'nodes/nodes.dart';

/// A deserializer function that takes a map as input and deserializes it into
/// a [BaseNode].
typedef JsonNodeDeserializer = BaseNode? Function(Map<dynamic, dynamic> json);

/// An undecidable or conflicting legacy wire payload. The caller must keep
/// [raw] unchanged (rather than re-serializing a guessed node) until its
/// provenance is resolved.
class UnresolvedNodeSchema implements Exception {
  /// Keeps the undecidable source payload for a caller to store unchanged.
  UnresolvedNodeSchema(this.reason, Map json)
    : raw = jsonDecode(jsonEncode(json)) as Map;

  /// Machine-readable reason for refusing to choose a wire schema.
  final String reason;

  /// Original top-level JSON, before normalizing any node properties.
  final Map raw;

  @override
  String toString() => 'UnresolvedNodeSchema: $reason';
}

/// [NodeJsonConverter] deserializes JSON and converts it into nodes.
///
/// It is a singleton class, so creating an instance will always return the same
/// object.
///
/// This contains a registry of all the node types supported by Codelessly.
/// To add custom nodes, use the [registerNode] method.
///
/// If node type is not found in the registry while deserializing, it will
/// throw an [UnsupportedError].
class NodeJsonConverter implements JsonConverter<BaseNode?, Map> {
  NodeJsonConverter._() {
    _registerDeserializers();
  }

  /// Singleton instance of this class.
  static final NodeJsonConverter instance = NodeJsonConverter._();

  /// A factory constructor that returns the singleton instance of this class.
  factory NodeJsonConverter() => instance;

  /// A map of node type to its deserializer.
  late final Map<String, JsonNodeDeserializer> _registry;

  /// Populates registry with all the nodes supported by Codelessly.
  void _registerDeserializers() {
    // Default registry.
    _registry = {
      'root': RootNode.fromJson,
      'frame': FrameNode.fromJson,
      'text': TextNode.fromJson,
      'canvas': CanvasNode.fromJson,
      'rectangle': RectangleNode.fromJson,
      'spacer': SpacerNode.fromJson,
      'icon': IconNode.fromJson,
      'rowColumn': RowColumnNode.fromJson,
      'singlePlaceholder': SinglePlaceholderNode.fromJson,
      'autoPlaceholder': AutoPlaceholderNode.fromJson,
      'freeformPlaceholder': FreeformPlaceholderNode.fromJson,
      'placeholder': PlaceholderNode.fromJson,
      'button': ButtonNode.fromJson,
      'textField': TextFieldNode.fromJson,
      'checkbox': CheckboxNode.fromJson,
      'appBar': AppBarNode.fromJson,
      'navigationBar': NavigationBarNode.fromJson,
      'floatingActionButton': FloatingActionButtonNode.fromJson,
      'switch': SwitchNode.fromJson,
      'radio': RadioNode.fromJson,
      'slider': SliderNode.fromJson,
      'signature': SignatureNode.fromJson,
      'signatureNormalized': SignatureNormalizedNode.fromJson,
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
      'variance': VarianceNode.fromJson,
      'listView': ListViewNode.fromJson,
      'gridView': GridViewNode.fromJson,
      'pageView': PageViewNode.fromJson,
      'tabBar': TabBarNode.fromJson,
      'badge': BadgeNode.fromJson,
      'chip': ChipNode.fromJson,
      'segmentedButton': SegmentedButtonNode.fromJson,
      'external': ExternalComponentNode.fromJson,
      'gauge': GaugeNode.fromJson,
      'chart': ChartNode.fromJson,
    };
  }

  /// Registers a new deserializer for a specific node type. If a deserializer
  /// for the given type already exists, it will be overwritten.
  /// [type] is the type of the node to be deserialized. This must be same as
  /// [BaseNode.type] field.
  ///
  /// Example:
  ///
  ///   NodeJsonConverter.registerNode('myCustomNode', MyCustomNode.fromJson);
  ///
  /// When deserializing a JSON object, if the `type` property is
  /// `myCustomNode`, the `MyCustomNode.fromJson` method will be called.
  static void registerNode(String type, JsonNodeDeserializer deserializer) {
    if (type.isEmpty) {
      throw ArgumentError('Type cannot be empty.');
    }
    if (instance._registry[type] != null) {
      log('A deserializer for type "$type" already exists. Overwriting...');
    }
    instance._registry[type] = deserializer;
  }

  /// Checks whether given [type] is available in the registry.
  static bool isNodeRegistered(String type) => instance._registry[type] != null;

  @override
  BaseNode? fromJson(Map json) {
    if (json['type'] == 'signature') {
      final properties = json['properties'];
      final Set<dynamic> propertyKeys = properties is Map
          ? properties.keys.toSet()
          : <dynamic>{};
      final kind = json['signatureKind'];
      if (kind != null && kind != 'pixel' && kind != 'normalized') {
        throw UnresolvedNodeSchema('unknown-signature-kind', json);
      }
      final pixel =
          kind == 'pixel' ||
          json.containsKey('value') ||
          propertyKeys.intersection(const {
            'inkWidth',
            'backgroundColor',
            'borderColor',
            'borderWidth',
            'errorBorderColor',
            'errorBorderWidth',
            'cornerRadius',
            'placeholder',
            'placeholderColor',
            'placeholderFontSize',
            'showSignLine',
            'signLineColor',
            'error',
            'enabled',
          }).isNotEmpty;
      final normalized =
          kind == 'normalized' ||
          json.containsKey('strokes') ||
          propertyKeys.intersection(const {
            'strokeWidth',
            'readOnly',
          }).isNotEmpty;
      if (pixel && normalized) {
        throw UnresolvedNodeSchema('conflicting-signature-schema', json);
      }
      if (normalized) {
        return SignatureNormalizedNode.fromJson({
          ...json,
          'type': 'signatureNormalized',
          if (properties == null) 'properties': const {},
        });
      }
      if (!pixel) {
        throw UnresolvedNodeSchema('ambiguous-signature-schema', json);
      }
    }
    if (json['type'] == 'signatureNormalized' &&
        (json['signatureKind'] != null &&
                json['signatureKind'] != 'normalized' ||
            json.containsKey('value') ||
            (json['properties'] is Map &&
                (json['properties'] as Map).keys.any(
                  const {
                    'inkWidth',
                    'backgroundColor',
                    'placeholder',
                    'error',
                    'enabled',
                  }.contains,
                )))) {
      throw UnresolvedNodeSchema('conflicting-signature-schema', json);
    }
    if (json['type'] == null || _registry[json['type']] == null) {
      throw UnsupportedError('Unsupported node type: ${json["type"]}\n$json');
    }
    // Hand-written JSON (e.g. nodes.insertTree) leaves out default
    // properties; nodes with custom properties read a missing key as all
    // defaults. Nodes without properties ignore the key.
    return _registry[json['type']]!(
      json['properties'] == null ? {...json, 'properties': const {}} : json,
    );
  }

  @override
  Map toJson(BaseNode? object) => object!.toJson();
}
