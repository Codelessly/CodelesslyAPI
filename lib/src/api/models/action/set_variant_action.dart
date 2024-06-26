import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../../codelessly_api.dart';

part 'set_variant_action.g.dart';

/// An action that sets the variant of a node.
@JsonSerializable()
class SetVariantAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// ID of the variance node whose variant is to be set.
  final String nodeID;

  /// ID of variant that needs to be set.
  final String variantID;

  /// Creates a new [SetVariantAction].
  SetVariantAction({
    required this.nodeID,
    required this.variantID,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.setVariant);

  @override
  List<Object?> get props => [nodeID, variantID];

  /// Duplicates this [SetVariantAction] with given data overrides.
  SetVariantAction copyWith({
    String? nodeID,
    String? variantID,
  }) =>
      SetVariantAction(
        nodeID: nodeID ?? this.nodeID,
        variantID: variantID ?? this.variantID,
      );

  /// Creates a new [SetVariantAction] instance from a JSON object.
  factory SetVariantAction.fromJson(Map json) =>
      _$SetVariantActionFromJson(json);

  @override
  Map toJson() => _$SetVariantActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSetVariantAction(this);
}
