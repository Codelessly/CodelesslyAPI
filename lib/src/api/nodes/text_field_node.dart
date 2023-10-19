// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'text_field_node.g.dart';

/// A text field lets the user enter text, either with hardware keyboard or with
/// an onscreen keyboard.
/// Refer to [TextField](https://api.flutter.dev/flutter/material/TextField-class.html)
/// in Flutter for more details.
@JsonSerializable()
class TextFieldNode extends SceneNode with CustomPropertiesMixin {
  @override
  final String type = 'textField';

  /// Holds configurable properties of the text field.
  TextFieldProperties properties;

  /// Initial text value of the field.
  String initialText = '';

  /// Creates a text field from the given properties.
  TextFieldNode.fromProperties(this.properties)
      : super(
          id: 'textField',
          name: 'TextField',
          basicBoxLocal: NodeBox(0, 0, 250, 48),
        );

  @override
  bool get supportsPadding => true;

  /// Creates a [TextFieldNode] instance with the given data.
  TextFieldNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    bool autoCorrect = true,
    bool autoFocus = false,
    bool enableActiveSelection = true,
    bool enabled = true,
    bool obscureText = false,
    bool readOnly = false,
    bool showCursor = true,
    TextInputTypeEnum keyboardType = TextInputTypeEnum.text,
    BoxHeightStyleEnum selectionHeightStyle = BoxHeightStyleEnum.tight,
    BoxWidthStyleEnum selectionWidthStyle = BoxWidthStyleEnum.tight,
    TextAlignHorizontalEnum textAlign = TextAlignHorizontalEnum.left,
    TextAlignVerticalEnum textAlignVertical = TextAlignVerticalEnum.center,
    ColorRGB cursorColor = ColorRGB.black,
    double cursorHeight = 14,
    double cursorWidth = 2.0,
    double cursorRadius = 2.0,
    int? maxLength,
    int maxLines = 1,
    int? minLines,
    String obscuringCharacter = '•',
    super.visible,
    super.alignment,
    super.padding =
        const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16),
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.parentID,
    super.positioningMode,
    required this.properties,
    this.initialText = '',
  });

  @override
  List<TriggerType> get triggerTypes => [
        TriggerType.click,
        TriggerType.changed,
        // TriggerType.editingComplete,
        TriggerType.submitted,
      ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'inputValue', value: ''),
    BoolValue(name: 'enabled', value: properties.enabled),
    BoolValue(name: 'obscureText', value: properties.obscureText),
    BoolValue(name: 'readOnly', value: properties.readOnly),
    BoolValue(name: 'showCursor', value: properties.showCursor),
    IntValue(name: 'maxLength', value: properties.maxLength ?? 8),
    BoolValue(name: 'isCollapsed', value: properties.decoration.isCollapsed),
    BoolValue(name: 'isDense', value: properties.decoration.isDense),
    StringValue(
        name: 'labelText', value: properties.decoration.labelText ?? ''),
    StringValue(name: 'hintText', value: properties.decoration.hintText ?? ''),
  ];

  /// Creates a [TextFieldNode] instance from a JSON object.
  factory TextFieldNode.fromJson(Map json) => _$TextFieldNodeFromJson(json);

  @override
  Map toJson() => _$TextFieldNodeToJson(this);
}

/// Holds configurable properties of the text field.
@JsonSerializable()
class TextFieldProperties with SerializableMixin, EquatableMixin {
  /// Whether to enable automatically correct the input text.
  late bool autoCorrect;

  /// Whether to focus on text field automatically.
  late bool autoFocus;

  /// Whether to enable text selection via mouse drag.
  late bool enableInteractiveSelection;

  /// Whether the field is enabled.
  late bool enabled;

  /// Whether to obscure the input text. Used for password fields.
  late bool obscureText;

  /// Whether the field is read-only.
  late bool readOnly;

  /// Whether to show the cursor in the field.
  late bool showCursor;

  /// The type of keyboard that pops up when inputting text in the field.
  /// For example, if the field should only accept numbers, the keyboard type
  /// should be [TextInputTypeEnum.number].
  late TextInputTypeEnum keyboardType;

  /// Defines how the selection highlighter box covers space vertically.
  @JsonKey(unknownEnumValue: BoxHeightStyleEnum.tight)
  late BoxHeightStyleEnum selectionHeightStyle;

  /// Defines how the selection highlighter box covers space horizontally.
  @JsonKey(unknownEnumValue: BoxWidthStyleEnum.tight)
  late BoxWidthStyleEnum selectionWidthStyle;

  /// Defines how input text is aligned horizontally in the field.
  late TextAlignHorizontalEnum textAlign;

  /// Defines how input text is aligned vertically in the field.
  late TextAlignVerticalEnum textAlignVertical;

  /// Color of the field cursor.
  late ColorRGB cursorColor;

  /// Height of the field cursor.
  late double cursorHeight;

  /// Width of the field cursor.
  late double cursorWidth;

  /// Radius of the field cursor.
  late double cursorRadius;

  /// Maximum characters that can be inputted in the field.
  late int? maxLength;

  /// Maximum lines of text that appear at a time before the field becomes
  /// scrollable.
  late int? maxLines;

  /// Maximum lines of text that appear at a time.
  late int? minLines;

  /// Defines the character that is used to obscure the text in the field.
  /// Defaults to '•'.
  late String obscuringCharacter;

  /// Text style applied to the input text.
  late TextProp inputStyle;

  /// Text field decoration.
  late InputDecorationModel decoration;

  /// Whether the field expands vertically.
  late bool expands;

  /// Creates a [TextFieldProperties] instance with the given data.
  TextFieldProperties({
    this.autoCorrect = true,
    this.autoFocus = false,
    this.enableInteractiveSelection = true,
    this.enabled = true,
    this.obscureText = false,
    this.readOnly = false,
    this.showCursor = true,
    this.keyboardType = TextInputTypeEnum.text,
    this.selectionHeightStyle = BoxHeightStyleEnum.tight,
    this.selectionWidthStyle = BoxWidthStyleEnum.tight,
    this.textAlign = TextAlignHorizontalEnum.left,
    this.textAlignVertical = TextAlignVerticalEnum.center,
    this.cursorColor = ColorRGB.black,
    this.cursorHeight = 14,
    this.cursorWidth = 2.0,
    this.cursorRadius = 2.0,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscuringCharacter = '•',
    TextProp? inputStyle,
    InputDecorationModel? decoration,
    this.expands = false,
  })  : inputStyle = inputStyle ??
            StartEndProp.general(fontSize: 14, fills: [PaintModel.blackPaint]),
        decoration = decoration ?? InputDecorationModel();

  /// Duplicates this [TextFieldProperties] instance with the given data
  /// overrides.
  TextFieldProperties copyWith({
    bool? autoCorrect,
    bool? autoFocus,
    bool? enableInteractiveSelection,
    bool? enabled,
    bool? obscureText,
    bool? readOnly,
    bool? showCursor,
    TextInputTypeEnum? keyboardType,
    BoxHeightStyleEnum? selectionHeightStyle,
    BoxWidthStyleEnum? selectionWidthStyle,
    TextAlignHorizontalEnum? textAlign,
    TextAlignVerticalEnum? textAlignVertical,
    ColorRGB? cursorColor,
    double? cursorHeight,
    double? cursorWidth,
    double? cursorRadius,
    int? maxLength,
    int? maxLines,
    int? minLines,
    String? obscuringCharacter,
    TextProp? inputStyle,
    InputDecorationModel? decoration,
    bool? expands,
  }) {
    return TextFieldProperties(
      autoCorrect: autoCorrect ?? this.autoCorrect,
      autoFocus: autoFocus ?? this.autoFocus,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      enabled: enabled ?? this.enabled,
      obscureText: obscureText ?? this.obscureText,
      readOnly: readOnly ?? this.readOnly,
      showCursor: showCursor ?? this.showCursor,
      keyboardType: keyboardType ?? this.keyboardType,
      selectionHeightStyle: selectionHeightStyle ?? this.selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle ?? this.selectionWidthStyle,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      inputStyle: inputStyle ?? this.inputStyle,
      decoration: decoration ?? this.decoration,
      expands: expands ?? this.expands,
    );
  }

  /// Creates a [TextFieldProperties] instance from a JSON object.
  factory TextFieldProperties.fromJson(Map json) =>
      _$TextFieldPropertiesFromJson(json);

  @override
  Map toJson() => _$TextFieldPropertiesToJson(this);

  @override
  List<Object?> get props => [
        autoCorrect,
        autoFocus,
        enableInteractiveSelection,
        enabled,
        obscureText,
        readOnly,
        showCursor,
        keyboardType,
        selectionHeightStyle,
        selectionWidthStyle,
        textAlign,
        textAlignVertical,
        cursorColor,
        cursorHeight,
        cursorWidth,
        cursorRadius,
        maxLength,
        maxLines,
        minLines,
        obscuringCharacter,
        inputStyle,
        decoration,
        expands,
      ];
}
