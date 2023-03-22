// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
import 'models.dart';

part 'input_decoration.g.dart';

/// Represents when to display floating label.
enum FloatingLabelBehaviorEnum {
  /// Never show.
  never,

  /// Default auto behavior. Only show when focused.
  auto,

  /// Always show.
  always;

  /// Displayable string representation of this enum.
  String get prettify {
    switch (this) {
      case FloatingLabelBehaviorEnum.never:
        return 'Never';
      case FloatingLabelBehaviorEnum.auto:
        return 'Auto';
      case FloatingLabelBehaviorEnum.always:
        return 'Always';
    }
  }
}

/// Input decoration for text field.
@JsonSerializable()
class InputDecorationModel with EquatableMixin, SerializableMixin {
  /// An icon to show before the input field and outside of the decoration's
  /// container.
  final MultiSourceIconModel icon;

  /// Optional text that describes the input field.
  final String? labelText;

  /// The style to use for [InputDecorationModel.labelText] when the label is on top
  /// of the input field.
  final TextProp labelStyle;

  /// The style to use for [InputDecorationModel.labelText] when the label is
  /// above (i.e., vertically adjacent to) the input field.
  final TextProp floatingLabelStyle;

  /// Text that provides context about the [InputDecorator.child]'s value, such
  /// as how the value will be used.
  final String? helperText;

  /// The style to use for the [helperText].
  final TextProp helperStyle;

  //// The maximum number of lines the [helperText] can occupy.
  final int helperMaxLines;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// The style to use for the [hintText].
  final TextProp hintStyle;

  /// The maximum number of lines the [hintText] can occupy.
  final int hintMaxLines;

  /// Text that appears below the [InputDecorator.child] and the border.
  final String? errorText;

  /// The style to use for the [InputDecoration.errorText].
  final TextProp errorStyle;

  /// The maximum number of lines the [errorText] can occupy.
  final int errorMaxLines;

  /// Defines **how** the floating label should behave.
  final FloatingLabelBehaviorEnum floatingLabelBehavior;

  /// Whether the decoration is the same size as the input field.
  final bool isCollapsed;

  /// Whether the [InputDecorator.child] is part of a dense form (i.e., uses less vertical
  /// space).
  final bool isDense;

  /// The padding for the input decoration's container.
  final EdgeInsetsModel contentPadding;

  // Widget prefix;
  /// Optional text prefix to place on the line before the input.
  final String? prefixText;

  /// The style to use for the [prefixText].
  final TextProp prefixStyle;

  /// An icon that appears before the [prefix] or [prefixText] and before
  /// the editable part of the text field, within the decoration's container.
  final MultiSourceIconModel prefixIcon;

  /// The constraints for the prefix icon.
  final BoxConstraintsModel prefixIconConstraints;

  // Widget suffix;
  /// Optional text suffix to place on the line after the input.
  final String? suffixText;

  /// The style to use for the [suffixText].
  final TextProp suffixStyle;

  /// An icon that appears after the editable part of the text field and
  /// after the [suffix] or [suffixText], within the decoration's container.
  final MultiSourceIconModel suffixIcon;

  /// The constraints for the suffix icon.
  final BoxConstraintsModel suffixIconConstraints;

  // Widget counter;
  /// Optional text to place below the line as a character count.
  final String? counterText;

  /// The style to use for the [counterText].
  final TextProp counterStyle;

  /// If true the decoration's container is filled with [fillColor].
  final bool filled;

  /// The base fill color of the decoration's container color.
  final ColorRGBA fillColor;

  /// Fill color when the text field is focused.
  final ColorRGBA focusColor;

  /// The color of the focus highlight for the decoration shown if the container
  /// is being hovered over by a mouse.
  final ColorRGBA hoverColor;

  /// The border to display when the [InputDecorator] does not have the focus and
  /// is showing an error.
  final InputBorderModel errorBorder;

  /// The border to display when the [InputDecorator] has the focus and is not
  /// showing an error.
  final InputBorderModel focusedBorder;

  /// The border to display when the [InputDecorator] has the focus and is
  /// showing an error.
  final InputBorderModel focusedErrorBorder;

  /// The border to display when the [InputDecorator] is disabled and is not
  /// showing an error.
  final InputBorderModel disabledBorder;

  /// The border to display when the [InputDecorator] is enabled and is not
  /// showing an error.
  final InputBorderModel enabledBorder;

  /// The shape of the border to draw around the decoration's container.
  final InputBorderModel border;

  /// If false [helperText],[errorText], and [counterText] are not displayed,
  /// and the opacity of the remaining visual elements is reduced.
  final bool enabled;

  /// A semantic label for the [counterText].
  final String? semanticCounterText;

  /// Typically set to true when the [InputDecorator] contains a multiline
  /// [TextField] ([TextField.maxLines] is null or > 1) to override the default
  /// behavior of aligning the label with the center of the [TextField].
  final bool alignLabelWithHint;

  /// Defines minimum and maximum sizes for the [InputDecorator].
  final BoxConstraintsModel constraints;

  /// Creates [InputDecorationModel] with given data.
  const InputDecorationModel({
    this.icon = const MultiSourceIconModel(),
    this.labelText,
    this.labelStyle = const TextProp.general(
      fontSize: 14,
      fills: [PaintModel.blackPaint],
    ),
    this.floatingLabelStyle = const TextProp.general(
      fontSize: 14,
      fills: [PaintModel.blackPaint],
    ),
    this.helperText,
    this.helperStyle = const TextProp.general(
      fontSize: 14,
      fills: [PaintModel.blackPaint],
    ),
    this.helperMaxLines = 1,
    this.hintText,
    this.hintStyle = const TextProp.general(
      fontSize: 14,
      fills: [
        PaintModel.solid(visible: true, opacity: 1, color: ColorRGB.grey)
      ],
    ),
    this.hintMaxLines = 1,
    this.errorText,
    this.errorStyle = const TextProp.general(
      fills: [PaintModel.solid(visible: true, opacity: 1, color: ColorRGB.red)],
    ),
    this.errorMaxLines = 1,
    this.floatingLabelBehavior = FloatingLabelBehaviorEnum.auto,
    this.isCollapsed = false,
    this.isDense = true,
    this.contentPadding =
        const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16),
    this.prefixIcon = const MultiSourceIconModel(),
    this.prefixIconConstraints = const BoxConstraintsModel(),
    this.prefixText,
    this.prefixStyle = const TextProp.general(),
    this.suffixIcon = const MultiSourceIconModel(),
    this.suffixText,
    this.suffixStyle = const TextProp.general(
      fontSize: 14,
      fills: [PaintModel.blackPaint],
    ),
    this.suffixIconConstraints = const BoxConstraintsModel(),
    this.counterText,
    this.counterStyle = const TextProp.general(),
    this.filled = false,
    this.fillColor = ColorRGBA.grey10,
    this.focusColor = ColorRGBA.black,
    this.hoverColor = ColorRGBA.grey10,
    this.errorBorder = const InputBorderModel(
      borderSide: BorderSideModel(color: ColorRGBA.red),
    ),
    this.focusedBorder = const InputBorderModel(),
    this.focusedErrorBorder = const InputBorderModel(
      borderSide: BorderSideModel(color: ColorRGBA.red),
    ),
    this.disabledBorder = const InputBorderModel(
      borderSide: BorderSideModel(color: ColorRGBA.grey10),
    ),
    this.enabledBorder = const InputBorderModel(
      borderSide: BorderSideModel(color: ColorRGBA.grey),
    ),
    this.border = const InputBorderModel(
      borderSide: BorderSideModel(color: ColorRGBA.grey),
    ),
    this.enabled = true,
    this.semanticCounterText,
    this.alignLabelWithHint = true,
    this.constraints = const BoxConstraintsModel(),
  });

  /// Duplicates this instance with given data overrides.
  InputDecorationModel copyWith({
    MultiSourceIconModel? icon,
    String? labelText,
    TextProp? labelStyle,
    TextProp? floatingLabelStyle,
    String? helperText,
    TextProp? helperStyle,
    int? helperMaxLines,
    String? hintText,
    TextProp? hintStyle,
    int? hintMaxLines,
    String? errorText,
    TextProp? errorStyle,
    int? errorMaxLines,
    FloatingLabelBehaviorEnum? floatingLabelBehavior,
    bool? isCollapsed,
    bool? isDense,
    EdgeInsetsModel? contentPadding,
    MultiSourceIconModel? prefixIcon,
    BoxConstraintsModel? prefixIconConstraints,
    String? prefixText,
    TextProp? prefixStyle,
    MultiSourceIconModel? suffixIcon,
    String? suffixText,
    TextProp? suffixStyle,
    BoxConstraintsModel? suffixIconConstraints,
    String? counterText,
    TextProp? counterStyle,
    bool? filled,
    ColorRGBA? fillColor,
    ColorRGBA? focusColor,
    ColorRGBA? hoverColor,
    InputBorderModel? errorBorder,
    InputBorderModel? focusedBorder,
    InputBorderModel? focusedErrorBorder,
    InputBorderModel? disabledBorder,
    InputBorderModel? enabledBorder,
    InputBorderModel? border,
    bool? enabled,
    String? semanticCounterText,
    bool? alignLabelWithHint,
    BoxConstraintsModel? constraints,
  }) =>
      InputDecorationModel(
        icon: icon ?? this.icon,
        labelText: labelText ?? this.labelText,
        labelStyle: labelStyle ?? this.labelStyle,
        floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
        helperText: helperText ?? this.helperText,
        helperStyle: helperStyle ?? this.helperStyle,
        helperMaxLines: helperMaxLines ?? this.helperMaxLines,
        hintText: hintText ?? this.hintText,
        hintStyle: hintStyle ?? this.hintStyle,
        hintMaxLines: hintMaxLines ?? this.hintMaxLines,
        errorText: errorText ?? this.errorText,
        errorStyle: errorStyle ?? this.errorStyle,
        errorMaxLines: errorMaxLines ?? this.errorMaxLines,
        floatingLabelBehavior:
            floatingLabelBehavior ?? this.floatingLabelBehavior,
        isCollapsed: isCollapsed ?? this.isCollapsed,
        isDense: isDense ?? this.isDense,
        contentPadding: contentPadding ?? this.contentPadding,
        prefixIcon: prefixIcon ?? this.prefixIcon,
        prefixIconConstraints:
            prefixIconConstraints ?? this.prefixIconConstraints,
        prefixText: prefixText ?? this.prefixText,
        prefixStyle: prefixStyle ?? this.prefixStyle,
        suffixIcon: suffixIcon ?? this.suffixIcon,
        suffixText: suffixText ?? this.suffixText,
        suffixStyle: suffixStyle ?? this.suffixStyle,
        suffixIconConstraints:
            suffixIconConstraints ?? this.suffixIconConstraints,
        counterText: counterText ?? this.counterText,
        counterStyle: counterStyle ?? this.counterStyle,
        filled: filled ?? this.filled,
        fillColor: fillColor ?? this.fillColor,
        focusColor: focusColor ?? this.focusColor,
        hoverColor: hoverColor ?? this.hoverColor,
        errorBorder: errorBorder ?? this.errorBorder,
        focusedBorder: focusedBorder ?? this.focusedBorder,
        focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
        disabledBorder: disabledBorder ?? this.disabledBorder,
        enabledBorder: enabledBorder ?? this.enabledBorder,
        border: border ?? this.border,
        enabled: enabled ?? this.enabled,
        semanticCounterText: semanticCounterText ?? this.semanticCounterText,
        alignLabelWithHint: alignLabelWithHint ?? this.alignLabelWithHint,
        constraints: constraints ?? this.constraints,
      );

  @override
  List<Object?> get props => [
        icon,
        labelText,
        labelStyle,
        floatingLabelStyle,
        helperText,
        helperStyle,
        helperMaxLines,
        hintText,
        hintStyle,
        hintMaxLines,
        errorText,
        errorStyle,
        errorMaxLines,
        floatingLabelBehavior,
        isCollapsed,
        isDense,
        contentPadding,
        prefixIcon,
        prefixIconConstraints,
        prefixText,
        prefixStyle,
        suffixIcon,
        suffixText,
        suffixStyle,
        suffixIconConstraints,
        counterText,
        counterStyle,
        filled,
        fillColor,
        focusColor,
        hoverColor,
        errorBorder,
        focusedBorder,
        focusedErrorBorder,
        disabledBorder,
        enabledBorder,
        border,
        enabled,
        semanticCounterText,
        alignLabelWithHint,
        constraints,
      ];

  /// Factory constructor for creating a new [InputDecorationModel] instance
  /// from JSON data.
  factory InputDecorationModel.fromJson(Map json) =>
      _$InputDecorationModelFromJson(json);

  @override
  Map toJson() => _$InputDecorationModelToJson(this);
}
