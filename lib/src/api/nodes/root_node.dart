// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import '../constants.dart';
import '../mixins.dart';
import '../models/models.dart';

/// A [Node] that represents the root of the project. Typically the whole
/// canvas is the root node.
/// This is not JSON Serializable to avoid setting [BaseNode].
/// It needs to extend [BaseNode] since every other method depends on
/// [BaseNode].
class RootNode extends ParentNode with ChildrenMixin {
  @override
  final String type = 'root';

  /// Creates a new [RootNode] with the given data.
  /// RootNode just needs a children, but it extends [BaseNode] so that
  /// [getNode] works.
  RootNode({
    super.id = kRootNode,
    required super.children,
    SizeC? size,
  }) : super(
          name: kRootNode,
          basicBoxLocal: NodeBox(0, 0, (size ?? kDefaultCanvasSize).width,
              (size ?? kDefaultCanvasSize).height),
          outerBoxLocal: OuterNodeBox(0, 0, (size ?? kDefaultCanvasSize).width,
              (size ?? kDefaultCanvasSize).height,
              edgeInsets: EdgeInsetsModel.zero),
          retainedOuterBoxLocal: NodeBox(
              0,
              0,
              (size ?? kDefaultCanvasSize).width,
              (size ?? kDefaultCanvasSize).height),
          flex: 0,
        );

  /// Creates a new [RootNode] from the given JSON data.
  factory RootNode.fromJson(Map json) => _$RootNodeFromJson(json);

  @override
  Map toJson() => _$RootNodeToJson(this);
}

RootNode _$RootNodeFromJson(Map json) {
  return RootNode(
    id: json['id'] as String,
    children: !json.containsKey('children')
        ? []
        : (json['children'] as List<dynamic>).map((e) => e as String).toList(),
    size: json['size'] != null ? SizeC.fromJson(json['size'] as Map) : null,
  );
}

Map _$RootNodeToJson(RootNode instance) => {
      'id': instance.id,
      'type': instance.type,
      'children': instance.children,
      'size': instance.basicBoxGlobal.size.toJson(),
    };
