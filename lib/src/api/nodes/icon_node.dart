import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'icon_node.g.dart';

/// Default size of the icon.
const double kIconDefaultSize = 24;

/// Default icon used as placeholder when no icon is provided.
const MaterialIcon defaultIcon = MaterialIcon(
  name: 'add',
  codepoint: 57669,
  style: MaterialIconStyle.filled,
);

/// A node that displays an icon.
@JsonSerializable()
class IconNode extends SceneNode
    with
        BlendMixin,
        SingleColorMixin,
        FixedAspectRatioMixin,
        CustomPropertiesMixin {
  /// Strictly used for previews. e.g in components panel.
  IconNode.empty()
      : this(
          id: 'icon1',
          name: 'Icon',
          icon: defaultIcon,
          basicBoxLocal: NodeBox(0, 0, 24, 24),
        );

  @override
  covariant IconProperties properties;

  @override
  final String type = 'icon';

  @override
  bool get supportsPadding => false;

  @override
  double get aspectRatio => 1;

  /// Creates an [IconNode] with the given data.
  IconNode({
    IconModel? icon,
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
    ColorRGBA? color,
    double opacity = 1.0,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    InkWellModel? inkWell,
    List<Reaction> reactions = const [],
    IconProperties? properties,
  }) : properties = properties ?? IconProperties(icon: icon ?? defaultIcon) {
    setBlendMixin(
      opacity: opacity,
      isMask: isMask,
      effects: effects,
      blendMode: blendMode,
      inkWell: inkWell,
    );
    setSingleColorMixin(color: color);
    setReactionMixin([...reactions]);
  }

  @override
  List<TriggerType> get triggerTypes => [
        TriggerType.click,
        TriggerType.longPress,
      ];

  /// Creates an [IconNode] from a JSON data.
  factory IconNode.fromJson(Map json) => _$IconNodeFromJson(json);

  @override
  Map toJson() => _$IconNodeToJson(this);
}

/// Properties for an [IconNode].
@JsonSerializable()
class IconProperties extends CustomProperties {
  /// The icon to display.
  IconModel icon;

  /// Creates [IconProperties] with the given data.
  IconProperties({
    required this.icon,
  });

  @override
  Map<String, dynamic> toJson() => _$IconPropertiesToJson(this);

  /// Creates an [IconProperties] from a JSON data.
  factory IconProperties.fromJson(Map json) => _$IconPropertiesFromJson(json);

  @override
  List<Object?> get props => [icon];
}
