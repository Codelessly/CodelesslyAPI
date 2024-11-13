import '../mixins.dart';
import '../models/models.dart';
import 'base_node.dart';

/// SceneNode should never be called directly, only inherited by other nodes.
abstract class SceneNode extends BaseNode
    with ReactionMixin, PropertyVariableMixin {
  /// Creates a [SceneNode] with the given data.
  SceneNode({
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
    List<Reaction> reactions = const [],
    super.variables,
    super.multipleVariables,
  }) {
    setReactionMixin([...reactions]);
  }
}
