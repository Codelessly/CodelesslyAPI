import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'badge_node.g.dart';

/// Default size of a badge node.
const double kBadgeDefaultSize = 48;

/// A Material 3 badge that shows a small dot, a label or a count, optionally
/// anchored to another node.
/// Refer to [Badge](https://api.flutter.dev/flutter/material/Badge-class.html)
/// in Flutter for more details.
@FlutterNode('Badge', family: 'material', nodeType: 'badge')
@JsonSerializable()
class BadgeNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'badge';

  @override
  bool get supportsPadding => true;

  /// Badges have no tap callback of their own, so click reactions are
  /// handled by the renderer like on any other node.
  @override
  bool get handlesDefaultReactionsInternally => false;

  /// Holds configurable properties of this badge.
  @override
  covariant BadgeProperties properties;

  /// ID of the node that the badge is anchored to, rendered as the badge's
  /// child. When null, only the badge itself is rendered.
  String? childID;

  /// Strictly used for previews. e.g in components panel.
  BadgeNode.empty()
    : childID = null,
      properties = BadgeProperties(label: '1'),
      super(
        id: 'badge',
        name: 'Badge',
        basicBoxLocal: NodeBox(0, 0, kBadgeDefaultSize, kBadgeDefaultSize),
      );

  /// Strictly used for previews. e.g in components panel.
  BadgeNode.fromProperties(this.properties)
    : childID = null,
      super(
        id: 'badge',
        name: 'Badge',
        basicBoxLocal: NodeBox(0, 0, kBadgeDefaultSize, kBadgeDefaultSize),
      );

  /// Creates a [BadgeNode] with the given data.
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
    // Custom properties.
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
      'Properties of the badge.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.cursorEnter,
    TriggerType.cursorExit,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'label', value: properties.label),
    BoolValue(name: 'isLabelVisible', value: properties.isLabelVisible),
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
  Map toJson() => _$BadgeNodeOmitDefaults(this, _$BadgeNodeToJson(this));
}

/// Badge types.
enum BadgeType {
  /// Small dot badge without a label, sized by [BadgeProperties.smallSize].
  dot,

  /// Badge with a text label.
  label,

  /// Badge with a count. Counts above [BadgeProperties.maxCount] show as
  /// `'<maxCount>+'`, like Flutter's `Badge.count`.
  count;

  /// Returns displayable string representation.
  String get prettify => switch (this) {
    BadgeType.dot => 'Dot Badge',
    BadgeType.label => 'Label Badge',
    BadgeType.count => 'Count Badge',
  };
}

/// Badge alignment relative to its child.
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
  String get prettify => switch (this) {
    BadgeAlignment.topRight => 'Top Right',
    BadgeAlignment.topLeft => 'Top Left',
    BadgeAlignment.bottomRight => 'Bottom Right',
    BadgeAlignment.bottomLeft => 'Bottom Left',
  };
}

/// Holds configurable properties of a [BadgeNode].
@JsonSerializable()
class BadgeProperties extends CustomProperties with FieldsHolder {
  /// Type of badge.
  @FlutterProp('badgeType', type: 'string', group: 'Appearance', control: 'select',
      field: 'properties.badgeType', flutterParam: false, a2ui: false,
      note: 'Persisted badge kind selected by the editor.')
  BadgeType badgeType;

  /// Label text for label and count badges.
  String label;

  /// Largest count shown as-is by a [BadgeType.count] badge whose [label] is
  /// a number. Larger counts show as `'<maxCount>+'`.
  @FlutterProp('maxCount', type: 'integer', group: 'Content', control: 'number',
      field: 'properties.maxCount', flutterParam: false, a2ui: false,
      note: 'Persisted count threshold for a count badge.')
  int maxCount;

  /// Badge background color. Defaults to the theme's `colorScheme.error`.
  ColorRGBA? backgroundColor;

  /// Label color. Defaults to the theme's `colorScheme.onError`.
  ColorRGBA? textColor;

  /// Label text style. Its color is used when [textColor] is null and the
  /// style has fills.
  @JsonKey(name: 'labelStyle')
  TextProp textStyle;

  /// Badge alignment relative to the child.
  BadgeAlignment alignment;

  /// Horizontal offset of a labeled badge from the aligned position.
  @FlutterProp('offsetX', type: 'number', group: 'Layout', control: 'number',
      field: 'properties.offsetX', flutterParam: false, a2ui: false,
      note: 'Persisted horizontal badge offset.')
  double offsetX;

  /// Vertical offset of a labeled badge from the aligned position.
  @FlutterProp('offsetY', type: 'number', group: 'Layout', control: 'number',
      field: 'properties.offsetY', flutterParam: false, a2ui: false,
      note: 'Persisted vertical badge offset.')
  double offsetY;

  /// Whether to show the badge.
  @FlutterProp('isLabelVisible', type: 'boolean', group: 'Appearance', control: 'switch', field: 'properties.isLabelVisible')
  bool isLabelVisible;

  /// Diameter of a [BadgeType.dot] badge.
  @JsonKey(name: 'dotSize')
  @FlutterProp('smallSize', type: 'number', group: 'Appearance', control: 'number', field: 'properties.smallSize')
  double smallSize;

  /// Height of a labeled badge, and its minimum width.
  @FlutterProp('largeSize', type: 'number', group: 'Appearance', control: 'number', field: 'properties.largeSize')
  double largeSize;

  /// Padding around the label of label and count badges.
  EdgeInsetsModel padding;

  /// Creates a [BadgeProperties] with the given data.
  BadgeProperties({
    this.badgeType = BadgeType.count,
    this.label = '',
    this.maxCount = 999,
    this.backgroundColor,
    this.textColor,
    TextProp? textStyle,
    this.alignment = BadgeAlignment.topRight,
    this.offsetX = 4,
    this.offsetY = -4,
    this.isLabelVisible = true,
    this.smallSize = 6,
    this.largeSize = 16,
    this.padding = const EdgeInsetsModel.symmetric(horizontal: 4),
  }) : textStyle =
           textStyle ??
           TextProp.general(fontSize: 11, fills: List.empty(growable: true));

  /// The text a labeled badge shows: [label], or `'<maxCount>+'` for a
  /// [BadgeType.count] badge whose numeric label exceeds [maxCount].
  String effectiveLabel([String? label]) {
    final text = label ?? this.label;
    if (badgeType != BadgeType.count) return text;
    final count = int.tryParse(text.trim());
    if (count == null || count <= maxCount) return text;
    return '$maxCount+';
  }

  /// Duplicates this [BadgeProperties] with the given data overrides.
  BadgeProperties copyWith({
    BadgeType? badgeType,
    String? label,
    int? maxCount,
    ColorRGBA? backgroundColor,
    ColorRGBA? textColor,
    TextProp? textStyle,
    BadgeAlignment? alignment,
    double? offsetX,
    double? offsetY,
    bool? isLabelVisible,
    double? smallSize,
    double? largeSize,
    EdgeInsetsModel? padding,
  }) {
    return BadgeProperties(
      badgeType: badgeType ?? this.badgeType,
      label: label ?? this.label,
      maxCount: maxCount ?? this.maxCount,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      isLabelVisible: isLabelVisible ?? this.isLabelVisible,
      smallSize: smallSize ?? this.smallSize,
      largeSize: largeSize ?? this.largeSize,
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
      (value) => badgeType = value,
      defaultValue: () => BadgeType.count,
      options: () => BadgeType.values,
      requiresLayout: true,
    ),
    'label': StringFieldAccess(
      'Label',
      'Text label of the badge.',
      () => label,
      (value) => label = value,
      requiresLayout: true,
    ),
    'maxCount': NumFieldAccess<int>(
      'Max Count',
      'Largest count shown as-is; larger counts show as "<max>+".',
      () => maxCount,
      (value) => maxCount = value,
      requiresLayout: true,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA?>(
      'Background Color',
      'Background color of the badge.',
      () => backgroundColor,
      (value) => backgroundColor = value,
    ),
    'textColor': ColorFieldAccess<ColorRGBA?>(
      'Text Color',
      'Color of the badge label.',
      () => textColor,
      (value) => textColor = value,
    ),
    'labelStyle': TextStyleFieldAccess<TextProp>(
      'Text Style',
      'Style of the badge label.',
      () => textStyle,
      (value) => textStyle = value,
      requiresLayout: true,
    ),
    'alignment': EnumFieldAccess<BadgeAlignment>(
      'Alignment',
      'Alignment of the badge relative to its child.',
      () => alignment,
      (value) => alignment = value,
      defaultValue: () => BadgeAlignment.topRight,
      options: () => BadgeAlignment.values,
      requiresLayout: true,
    ),
    'offsetX': NumFieldAccess<double>(
      'Offset X',
      'Horizontal offset from the aligned position.',
      () => offsetX,
      (value) => offsetX = value,
      requiresLayout: true,
    ),
    'offsetY': NumFieldAccess<double>(
      'Offset Y',
      'Vertical offset from the aligned position.',
      () => offsetY,
      (value) => offsetY = value,
      requiresLayout: true,
    ),
    'isLabelVisible': BoolFieldAccess(
      'Show Badge',
      'Whether to show the badge.',
      () => isLabelVisible,
      (value) => isLabelVisible = value,
    ),
    'dotSize': NumFieldAccess<double>(
      'Dot Size',
      'Diameter of a dot badge.',
      () => smallSize,
      (value) => smallSize = value,
      requiresLayout: true,
    ),
    'largeSize': NumFieldAccess<double>(
      'Large Size',
      'Height of a labeled badge.',
      () => largeSize,
      (value) => largeSize = value,
      requiresLayout: true,
    ),
    'padding': SpacingFieldAccess.padding(
      'Padding',
      'Padding around the label of label and count badges.',
      () => padding,
      (value) => padding = value,
      requiresLayout: true,
    ),
  };

  @override
  List<Object?> get props => [
    badgeType,
    label,
    maxCount,
    backgroundColor,
    textColor,
    textStyle,
    alignment,
    offsetX,
    offsetY,
    isLabelVisible,
    smallSize,
    largeSize,
    padding,
  ];

  /// Creates a [BadgeProperties] from a JSON data.
  factory BadgeProperties.fromJson(Map json) => _$BadgePropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$BadgePropertiesOmitDefaults(this, _$BadgePropertiesToJson(this));
}
