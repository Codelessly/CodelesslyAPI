// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:developer';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import 'nodes/nodes.dart';

/// A deserializer function that takes a map as input and deserializes it into
/// a [BaseNode].
typedef JsonNodeDeserializer = BaseNode? Function(Map<dynamic, dynamic> json);

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
      'button': ButtonNode.fromJson,
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
      'variance': VarianceNode.fromJson,
      'listView': ListViewNode.fromJson,
      'pageView': PageViewNode.fromJson,
      'tabBar': TabBarNode.fromJson,
      'external': ExternalComponentNode.fromJson,
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
    if (json['type'] == null || _registry[json['type']] == null) {
      throw UnsupportedError('Unsupported node type: ${json["type"]}\n$json');
    }
    return _registry[json['type']]!(json);
  }

  @override
  Map toJson(BaseNode? object) => object!.toJson();
}
