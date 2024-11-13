import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'external_component_node.g.dart';

/// An inert node that does nothing.
/// This is populated dynamically through the Codelessly SDK.
@JsonSerializable()
class ExternalComponentNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'external';

  @override
  covariant ExternalComponentProperties properties;

  @override
  bool get handlesDefaultReactionsInternally => false;

  /// Creates an [ExternalComponentNode] with the given data.
  ExternalComponentNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    String? builderID,
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
    ExternalComponentProperties? properties,
  }) : properties =
            properties ?? ExternalComponentProperties(builderID: builderID);

  /// Creates a [ExternalComponentNode] from a JSON object.
  factory ExternalComponentNode.fromJson(Map json) =>
      _$ExternalComponentNodeFromJson(json);

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.longPress];

  @override
  Map toJson() => _$ExternalComponentNodeToJson(this);
}

/// Holds configurable properties for the [ExternalComponentNode].
@JsonSerializable()
class ExternalComponentProperties extends CustomProperties {
  /// A user-defined ID that is used to map this node to a widget builder.
  /// The reason we allow an external ID is to allow users to define friendly
  /// names for their dynamic nodes instead of arbitrarily-generated IDs.
  /// Another reason is that the ID can be used more than once to map multiple
  /// nodes to the same widget builder.
  String? builderID;

  /// Creates [ExternalComponentProperties] with the given data.
  ExternalComponentProperties({this.builderID});

  @override
  Map<String, dynamic> toJson() => _$ExternalComponentPropertiesToJson(this);

  /// Creates [ExternalComponentProperties] from a JSON object.
  factory ExternalComponentProperties.fromJson(Map<String, dynamic> json) =>
      _$ExternalComponentPropertiesFromJson(json);

  @override
  List<Object?> get props => [builderID];
}
