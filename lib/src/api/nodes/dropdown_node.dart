// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'dropdown_node.g.dart';

/// A dropdown is a widget that lets the user choose from multiple options.
/// This widget is a material dropdown button that shows an overlay with the
/// options when pressed.
/// Refer to [DropdownButton](https://api.flutter.dev/flutter/material/DropdownButton-class.html) in Flutter for more details.
@JsonSerializable()
class DropdownNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'dropdown';

  /// Holds configurable properties of the dropdown.
  DropdownProperties properties;

  /// Creates a [DropdownNode] with the given data.
  DropdownNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.rotationDegrees,
    super.visible,
    super.alignment,
    super.padding,
    super.margin,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    required this.properties,
  });

  @override
  List<TriggerType> get triggerTypes =>
      [TriggerType.click, TriggerType.changed];

  @override
  SizeC minimumInternalSize({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    final double iconSize = properties.icon.size ?? 24;
    final size = SizeC(iconSize, 0);
    return size |
        super.minimumInternalSize(
          horizontalFit: horizontalFit,
          verticalFit: verticalFit,
        );
  }

  /// Creates a [DropdownNode] from a JSON object.
  factory DropdownNode.fromJson(Map json) => _$DropdownNodeFromJson(json);

  @override
  Map toJson() => _$DropdownNodeToJson(this);
}

/// Holds configurable properties of the dropdown.
@JsonSerializable()
class DropdownProperties with SerializableMixin, EquatableMixin {
  /// Index of the selected option in the dropdown.
  int value;

  /// Whether the dropdown is in the enabled state.
  bool enabled;

  /// Whether to reduce dropdown button's height.
  bool dense;

  /// Whether to expand the dropdown button's width.
  bool expanded;

  /// Whether to automatically focus the dropdown button.
  bool autoFocus;

  /// Whether to enable device-specific haptic feedback when dropdown button is
  /// tapped or long pressed.
  bool enableFeedback;

  /// Dropdown's options.
  final List<String> items;

  /// Text style applied to the dropdown's options.
  TextProp itemTextStyle;

  /// Alignment applied to the dropdown's options.
  AlignmentModel itemAlignment;

  /// Text style applied to the selected option.
  TextProp selectedItemTextStyle;

  /// Alignment applied to the selected option.
  AlignmentModel selectedItemAlignment;

  /// Placeholder text displayed in the dropdown button when [value] is null,
  /// i.e. no option is selected.
  String hint;

  /// Text style applied to hint.
  TextProp hintStyle;

  /// Color of icon when the dropdown button is disabled.
  ColorRGBA iconDisabledColor;

  /// Color of icon when the dropdown button is enabled.
  ColorRGBA iconEnabledColor;

  /// Icon size in dropdown button.
  double iconSize;

  /// Dropdown button's icon.
  MultiSourceIconModel icon;

  /// Color of dropdown overlay.
  ColorRGBA dropdownColor;

  /// Color of dropdown button when it is focused.
  ColorRGBA focusColor;

  /// The z-coordinate of the dropdown overlay.
  int elevation;

  /// Corner radii of the dropdown overlay.
  CornerRadius borderRadius;

  /// Whether to underline dropdown button's contents.
  bool underline;

  /// Creates a [DropdownProperties] with the given data.
  DropdownProperties({
    this.value = 0,
    this.enabled = true,
    this.dense = false,
    this.expanded = false,
    this.autoFocus = false,
    this.enableFeedback = true,
    required this.items,
    this.itemTextStyle = const TextProp.general(
      fills: [PaintModel.blackPaint],
      fontSize: 16,
      fontName: FontName.poppinsRegular,
    ),
    this.itemAlignment = AlignmentModel.centerLeft,
    this.selectedItemTextStyle = const TextProp.general(
      fills: [PaintModel.blackPaint],
      fontSize: 16,
      fontName: FontName.poppinsRegular,
    ),
    this.selectedItemAlignment = AlignmentModel.centerLeft,
    this.hint = '',
    this.hintStyle = const TextProp.general(
      fills: [PaintModel.blackPaint],
      fontSize: 16,
      fontName: FontName.poppinsRegular,
    ),
    this.iconDisabledColor = ColorRGBA.grey,
    this.iconEnabledColor = ColorRGBA.black,
    this.iconSize = 24,
    this.icon = const MultiSourceIconModel.icon(show: false),
    this.dropdownColor = ColorRGBA.white,
    this.focusColor = ColorRGBA.white,
    this.elevation = 8,
    this.borderRadius = CornerRadius.zero,
    this.underline = true,
  });

  /// Duplicates this [DropdownProperties] instance with the given data
  /// overrides.
  DropdownProperties copyWith({
    List<String>? items,
    TextProp? itemTextStyle,
    AlignmentModel? itemAlignment,
    TextProp? selectedItemTextStyle,
    AlignmentModel? selectedItemAlignment,
    String? hint,
    TextProp? hintStyle,
    ColorRGBA? iconDisabledColor,
    ColorRGBA? iconEnabledColor,
    double? iconSize,
    MultiSourceIconModel? icon,
    ColorRGBA? dropdownColor,
    ColorRGBA? focusColor,
    int? elevation,
    CornerRadius? borderRadius,
    bool? underline,
  }) {
    return DropdownProperties(
      items: items ?? this.items,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemAlignment: itemAlignment ?? this.itemAlignment,
      selectedItemTextStyle:
          selectedItemTextStyle ?? this.selectedItemTextStyle,
      selectedItemAlignment:
          selectedItemAlignment ?? this.selectedItemAlignment,
      hint: hint ?? this.hint,
      hintStyle: hintStyle ?? this.hintStyle,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconEnabledColor: iconEnabledColor ?? this.iconEnabledColor,
      iconSize: iconSize ?? this.iconSize,
      icon: icon ?? this.icon,
      dropdownColor: dropdownColor ?? this.dropdownColor,
      focusColor: focusColor ?? this.focusColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      underline: underline ?? this.underline,
    );
  }

  @override
  List<Object?> get props => [
        items,
        itemTextStyle,
        itemAlignment,
        selectedItemTextStyle,
        selectedItemAlignment,
        hint,
        hintStyle,
        iconDisabledColor,
        iconEnabledColor,
        iconSize,
        icon,
        dropdownColor,
        focusColor,
        elevation,
        borderRadius,
      ];

  /// Creates a [DropdownProperties] from a JSON object.
  factory DropdownProperties.fromJson(Map json) =>
      _$DropdownPropertiesFromJson(json);

  @override
  Map toJson() => _$DropdownPropertiesToJson(this);
}
