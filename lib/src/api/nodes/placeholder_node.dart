import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'placeholder_node.g.dart';

/// [PlaceholderNode] holds the place for another node until the other node
/// replaces it.
@FlutterNode(
  'CodelesslyPlaceholder',
  family: 'codelessly',
  nodeType: 'placeholder',
)
@JsonSerializable()
class PlaceholderNode extends SceneNode with PlaceholderMixin {
  @override
  final String type = 'placeholder';

  @override
  final bool supportsPadding = true;

  /// Image asset displayed in the placeholder.
  @FlutterProp(
    'leadingAsset',
    type: 'string',
    group: 'Content',
    control: 'text',
  )
  String? leadingAsset;

  /// Text displayed in the placeholder.
  @FlutterProp('text', type: 'string', group: 'Content', control: 'text')
  String? text;

  @override
  bool get canBeMarked => false;

  /// Creates a [PlaceholderNode] instance with the given data.
  PlaceholderNode({
    required this.text,
    required this.leadingAsset,
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.rotationDegrees,
    super.alignment,
    super.margin,
    super.padding,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.parentID,
    super.reactions,
  });

  /// Creates a [PlaceholderNode] instance from a JSON object.
  factory PlaceholderNode.fromJson(Map json) => _$PlaceholderNodeFromJson(json);

  @override
  Map toJson() =>
      _$PlaceholderNodeOmitDefaults(this, _$PlaceholderNodeToJson(this));
}
