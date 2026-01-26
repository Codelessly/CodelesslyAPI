import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'badge_node.g.dart';

/// A Material 3 badge for displaying a small amount of information.
/// Refer to [Badge](https://api.flutter.dev/flutter/material/Badge-class.html)
/// for more details.
@JsonSerializable()
class BadgeNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'badge';

  @override
  final bool supportsPadding = true;

  /// Holds configurable properties of this badge.
  @override
  covariant BadgeProperties properties;

  /// ID of the child node that the badge is anchored to.
  String? childID;

  /// Strictly used for previews. e.g in components panel.
  BadgeNode.empty()
      : childID = null,
        properties = BadgeProperties(),
        super(
          id: 'badge',
          name: 'Badge',
          basicBoxLocal: NodeBox(0, 0, 48, 48),
        );

  /// Strictly used for previews. e.g in components panel.
  BadgeNode.fromProperties(this.properties)
      : childID = null,
        super(
          id: 'badge',
          name: 'Badge',
          basicBoxLocal: NodeBox(0, 0, 48, 48),
        );

  /// Creates a [BadgeNode] with given data.
  BadgeNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.alignment,
    super.padding,
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.aspectRatioLock,
    super.edgePins,
    super.parentID,
    super.positioningMode,
    required this.properties,
    this.childID,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<BadgeProperties>(
          'Properties',
          'Properties of a badge',
          () => properties,
          (value) => properties = value,
        ),
      };

  @override
  List<TriggerType> get triggerTypes => [
        TriggerType.click,
      ];

  @override
  List<Object?> get props => [
        ...super.props,
        properties,
        childID,
        variables,
        multipleVariables,
      ];

  /// Creates a [BadgeNode] from a JSON data.
  factory BadgeNode.fromJson(Map json) => _$BadgeNodeFromJson(json);

  @override
  Map toJson() => _$BadgeNodeToJson(this);
}

/// Badge types.
enum BadgeType {
  /// Small dot badge.
  dot,

  /// Badge with a label.
  label,

  /// Badge with a count number.
  count;

  /// Returns displayable string representation.
  String get prettify {
    switch (this) {
      case BadgeType.dot:
        return 'Dot Badge';
      case BadgeType.label:
        return 'Label Badge';
      case BadgeType.count:
        return 'Count Badge';
    }
  }
}

/// Badge alignment relative to the child.
enum BadgeAlignment {
  /// Top-right corner.
  topRight,

  /// Top-left corner.
  topLeft,

  /// Bottom-right corner.
  bottomRight,

  /// Bottom-left corner.
  bottomLeft;

  /// Returns displayable string representation.
  String get prettify {
    switch (this) {
      case BadgeAlignment.topRight:
        return 'Top Right';
      case BadgeAlignment.topLeft:
        return 'Top Left';
      case BadgeAlignment.bottomRight:
        return 'Bottom Right';
      case BadgeAlignment.bottomLeft:
        return 'Bottom Left';
    }
  }
}

/// Holds configurable properties of a [BadgeNode].
@JsonSerializable()
class BadgeProperties extends CustomProperties with FieldsHolder {
  /// Type of badge.
  late BadgeType badgeType;

  /// Label text for label/count badges.
  late String label;

  /// Badge background color.
  late ColorRGBA? backgroundColor;

  /// Label text style.
  late TextProp labelStyle;

  /// Badge alignment relative to child.
  late BadgeAlignment alignment;

  /// Horizontal offset from the aligned position.
  late double offsetX;

  /// Vertical offset from the aligned position.
  late double offsetY;

  /// Whether to show the badge.
  late bool isLabelVisible;

  /// Size for dot badges.
  late double dotSize;

  /// Padding for label/count badges.
  late EdgeInsetsModel padding;

  /// Creates a [BadgeProperties] with given data.
  BadgeProperties({
    this.badgeType = BadgeType.count,
    this.label = '',
    this.backgroundColor,
    TextProp? labelStyle,
    this.alignment = BadgeAlignment.topRight,
    this.offsetX = 0,
    this.offsetY = 0,
    this.isLabelVisible = true,
    this.dotSize = 6,
    EdgeInsetsModel? padding,
  })  : labelStyle = labelStyle ?? TextProp.general(fills: List.empty(growable: true)),
        padding = padding ?? const EdgeInsetsModel.symmetric(horizontal: 4, vertical: 0);

  /// Duplicates this [BadgeProperties] instance with given data overrides.
  BadgeProperties copyWith({
    BadgeType? badgeType,
    String? label,
    ColorRGBA? backgroundColor,
    TextProp? labelStyle,
    BadgeAlignment? alignment,
    double? offsetX,
    double? offsetY,
    bool? isLabelVisible,
    double? dotSize,
    EdgeInsetsModel? padding,
  }) {
    return BadgeProperties(
      badgeType: badgeType ?? this.badgeType,
      label: label ?? this.label,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      labelStyle: labelStyle ?? this.labelStyle,
      alignment: alignment ?? this.alignment,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      isLabelVisible: isLabelVisible ?? this.isLabelVisible,
      dotSize: dotSize ?? this.dotSize,
      padding: padding ?? this.padding,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'badgeType': EnumFieldAccess<BadgeType>(
          'Badge Type',
          'Type of the badge.',
          () => badgeType,
          (BadgeType? value) {
            if (value != null) badgeType = value;
          },
          defaultValue: () => BadgeType.count,
          options: () => BadgeType.values,
          requiresLayout: true,
        ),
        'label': StringFieldAccess(
          'Label',
          'Text label of the badge.',
          () => label,
          requiresLayout: true,
          (String? value) {
            if (value != null) label = value;
          },
        ),
        'backgroundColor': ColorFieldAccess<ColorRGBA?>(
          'Background Color',
          'Background color of the badge.',
          () => backgroundColor,
          (ColorRGBA? value) => backgroundColor = value,
        ),
        'labelStyle': TextStyleFieldAccess<TextProp>(
          'Label Style',
          'Style of the badge label text.',
          () => labelStyle,
          requiresLayout: true,
          (TextProp value) => labelStyle = value,
        ),
        'alignment': EnumFieldAccess<BadgeAlignment>(
          'Alignment',
          'Alignment of the badge relative to child.',
          () => alignment,
          (BadgeAlignment? value) {
            if (value != null) alignment = value;
          },
          defaultValue: () => BadgeAlignment.topRight,
          options: () => BadgeAlignment.values,
          requiresLayout: true,
        ),
        'offsetX': NumFieldAccess<double>(
          'Offset X',
          'Horizontal offset from the aligned position.',
          () => offsetX,
          requiresLayout: true,
          (double value) => offsetX = value,
        ),
        'offsetY': NumFieldAccess<double>(
          'Offset Y',
          'Vertical offset from the aligned position.',
          () => offsetY,
          requiresLayout: true,
          (double value) => offsetY = value,
        ),
        'isLabelVisible': BoolFieldAccess(
          'Show Badge',
          'Whether to show the badge.',
          () => isLabelVisible,
          (bool? value) {
            if (value != null) isLabelVisible = value;
          },
        ),
        'dotSize': NumFieldAccess<double>(
          'Dot Size',
          'Size for dot badges.',
          () => dotSize,
          requiresLayout: true,
          (double value) => dotSize = value,
        ),
        'padding': SpacingFieldAccess.padding(
          'Padding',
          'Padding for label/count badges.',
          () => padding,
          (EdgeInsetsModel? value) {
            if (value != null) padding = value;
          },
          requiresLayout: true,
        ),
      };

  /// Creates a [BadgeProperties] from a JSON data.
  factory BadgeProperties.fromJson(Map json) =>
      _$BadgePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BadgePropertiesToJson(this);

  @override
  List<Object?> get props => [
        badgeType,
        label,
        backgroundColor,
        labelStyle,
        alignment,
        offsetX,
        offsetY,
        isLabelVisible,
        dotSize,
        padding,
      ];
}
