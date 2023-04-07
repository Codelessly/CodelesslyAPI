// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

import 'nodes/nodes.dart';

/// A deserializer function that takes a map as input and deserializes it into
/// a [SceneNode].
typedef JsonNodeDeserializer = SceneNode? Function(Map<dynamic, dynamic> json);

/// Converts a JSON decoded object to a [textNode] specific instance regarding
/// its `type` property.
/// [NodeJsonConverter] is a singleton class by design. So creating an instance
/// of it will always return the same object.
///
/// By default, this contains a registry of all the nodes types supported
/// by Codelessly. If you want to add your own custom nodes, you can use the
/// [registerNode] method.
///
/// If node type is not found in the registry wh ile deserializing, it will
/// throw an [UnsupportedError].
class NodeJsonConverter implements JsonConverter<BaseNode?, Map> {
  NodeJsonConverter._() {
    _registerDeserializers();
  }

  /// Singleton instance of this class.
  static final NodeJsonConverter instance = NodeJsonConverter._();

  /// A factory constructor that returns the singleton instance of this class.
  factory NodeJsonConverter() => instance;

  /// A map of node types and their deserializers.
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
    };
  }

  /// Registers a new deserializer for a specific node type. If a deserializer
  /// for the given type already exists, it will be overwritten.
  /// [type] is the type of the node to be deserialized. This must be same as
  /// [BaseNode.type] field. [type] string is case-sensitive and must be
  /// an exact match of [BaseNode.type].
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
      throw UnsupportedError('Unsupported node type : ${json["type"]}');
    }
    return _registry[json['type']]!(json);
  }

  @override
  Map toJson(BaseNode? object) => object!.toJson();
}
