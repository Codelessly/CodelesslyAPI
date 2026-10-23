import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'single_placeholder_node.g.dart';

/// An unselectable node that serves as a placeholder for a single node.
@JsonSerializable()
class SinglePlaceholderNode extends SceneNode
    with ChildrenMixin, PlaceholderMixin {
  @override
  final String type = 'singlePlaceholder';

  @override
  final bool supportsPadding = true;

  /// Whether the placeholder is only meant to exist for a short period of time.
  @JsonKey(defaultValue: false)
  bool ephemeral;

  @override
  bool get canBeMarked => false;

  @override
  BoxConstraintsModel? relegatedConstraintsToChildren(BaseNode child) {
    final superRelegated = super.relegatedConstraintsToChildren(child);
    return superRelegated == null
        ? constraints
        : superRelegated.union(constraints);
  }

  /// The node types that are allowed to be inside this [SinglePlaceholderNode].
  /// Example: 'APP_BAR' for AppBarNode.
  /// When empty, allow all types. Missing from JSON reads as empty (it is
  /// still always written, for older readers that require it).
  @JsonKey(readValue: readTypesOrEmpty)
  List<String> allowedTypes;

  /// The node types that are not allowed to be inside this
  /// [SinglePlaceholderNode].
  /// Example: "TEXT" for TextNode.
  /// When empty, allow all types. Missing from JSON reads as empty (it is
  /// still always written, for older readers that require it).
  @JsonKey(readValue: readTypesOrEmpty)
  List<String> deniedTypes;

  /// If not null, this [SinglePlaceholderNode] will only accept nodes that do
  /// not grow larger than the specified size.
  SizeC? maxAllowedSize;

  /// Creates a new [SinglePlaceholderNode] with the given data.
  SinglePlaceholderNode({
    required this.allowedTypes,
    required this.deniedTypes,
    this.maxAllowedSize,
    this.ephemeral = false,
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
    super.variables,
    super.multipleVariables,
    required List<String> children,
  }) {
    setChildrenMixin(children: children);
  }

  /// Creates a new [SinglePlaceholderNode] from a JSON data.
  factory SinglePlaceholderNode.fromJson(Map json) =>
      _$SinglePlaceholderNodeFromJson(json);

  @override
  Map toJson() => _$SinglePlaceholderNodeOmitDefaults(
    this,
    _$SinglePlaceholderNodeToJson(this),
  );
}

/// Reads [key] of [json], or an empty list when it is missing, so a node
/// tree written by hand can leave out the placeholder's type filters.
Object? readTypesOrEmpty(Map json, String key) => json[key] ?? const <String>[];
