import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'spacer_node.g.dart';

/// A node that can be used to create space between other nodes inside a row or
/// column or any other flexible spaces.
// TODO: SpacerNode should extend BaseNode, not SceneNode. Reactions should not be allowed on this.
@JsonSerializable()
class SpacerNode extends SceneNode {
  @override
  final String type = 'spacer';

  @override
  bool get supportsMargin => false;

  @override
  bool get supportsRotation => false;

  @override
  bool get supportsVisibility => false;

  @override
  bool get canBeMarked => false;

  /// Creates a new [SpacerNode] with the given data.
  SpacerNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.horizontalFit,
    super.verticalFit,
    super.visible,
    super.enabled,
    super.flex,
    super.edgePins,
    super.parentID,
    super.constraints,
    super.positioningMode,
    super.aspectRatioLock,
    super.reactions,
  });

  /// Creates a new [SpacerNode] from a JSON data.
  factory SpacerNode.fromJson(Map json) => _$SpacerNodeFromJson(json);

  /// Keys that SDKs up to codelessly_api 6.0.0 require in a spacer's JSON. They are written
  /// even at their defaults so those SDKs can still read it.
  static const List<String> _legacyRequiredKeys = [
    'positioningMode',
    'aspectRatioLock',
    'reactions',
  ];

  @override
  Map toJson() {
    final Map<String, dynamic> json = _$SpacerNodeToJson(this);
    final Map<String, dynamic> legacy = {
      for (final key in _legacyRequiredKeys) key: json[key],
    };
    return {..._$SpacerNodeOmitDefaults(this, json), ...legacy};
  }
}
