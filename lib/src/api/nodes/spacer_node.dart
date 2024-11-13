import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'spacer_node.g.dart';

/// A node that can be used to create space between other nodes inside a row or
/// column or any other flexible spaces.
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
  });

  /// Creates a new [SpacerNode] from a JSON data.
  factory SpacerNode.fromJson(Map json) => _$SpacerNodeFromJson(json);

  @override
  Map toJson() => _$SpacerNodeToJson(this);
}
