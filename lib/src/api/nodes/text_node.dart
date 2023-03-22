// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../api.dart';

part 'text_node.g.dart';

/// Helper class to communicate text computations to the internal layout engine
/// in the Codelessly editor.
/// [WidthRange] is the range of values of width for which the text node's
/// height remains constant.
/// Beyond this range, the height of text node changes.
@JsonSerializable()
class WidthRange with SerializableMixin implements EquatableMixin {
  /// Minimum width for which the height remains constant.
  final int from;

  /// Maximum width for which the height remains constant.
  final int to;

  /// Creates a [WidthRange] instance with the given data.
  WidthRange({required this.from, required this.to});

  @override
  List<Object> get props => [from, to];

  @override
  bool get stringify => true;

  /// Creates a [WidthRange] instance from a JSON object.
  factory WidthRange.fromJson(Map<String, dynamic> json) =>
      _$WidthRangeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WidthRangeToJson(this);
}

/// A run of text with a single style. The Text widget displays a string of text
/// with single style. The string might break across multiple lines or might all
/// be displayed on the same line depending on the layout constraints.
/// Refer to [Text](https://api.flutter.dev/flutter/widgets/Text-class.html) in
/// Flutter for more details.
@JsonSerializable()
class TextNode extends SceneNode
    with BlendMixin, TextMixin, VariablePropertiesMixin, FontMixin {
  @override
  final String type = 'text';

  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double minTextWidth = double.infinity;

  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double minTextHeight = double.infinity;

  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double maxTextWidth = double.infinity;

  /// Calculated at runtime using Flutter TextPainter.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double maxTextHeight = double.infinity;

  /// Calculated at runtime using Flutter TextPainter.
  /// key is HEIGHT
  /// value is WIDTH RANGE
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, WidthRange> precalculatedSizes = {};

  @override
  List<FontName> get fonts => textMixedProps.map((e) => e.fontName).toList();

  /// Creates a [TextNode] instance with the given data.
  TextNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
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
    // [TextMixin] properties
    required String characters,
    List<StartEndProp> textMixedProps = const [],
    double paragraphIndent = 0,
    double paragraphSpacing = 0,
    TextAlignHorizontalEnum textAlignHorizontal = TextAlignHorizontalEnum.left,
    TextAlignVerticalEnum textAlignVertical = TextAlignVerticalEnum.top,
    int? maxLines,
    TextOverflowC overflow = TextOverflowC.clip,
    // BlendMixin properties
    double opacity = 1.0,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    Map<String, String>? variables,
    Map<String, List<String>>? multipleVariables,
  }) {
    setTextMixin(
      characters: characters,
      textMixedProps: textMixedProps,
      textAlignHorizontal: textAlignHorizontal,
      textAlignVertical: textAlignVertical,
      paragraphIndent: paragraphIndent,
      paragraphSpacing: paragraphSpacing,
      maxLines: maxLines,
      overflow: overflow,
    );

    setBlendMixin(
      opacity: opacity,
      isMask: isMask,
      effects: effects,
      blendMode: blendMode,
    );

    setVariablesMixin(
        variables: variables, multipleVariables: multipleVariables);
  }

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'characters', value: characters),
  ];

  // clone(): TextNode
  // insertCharacters(start: number, characters: string, useStyle?: "BEFORE" | "AFTER"): void
  // deleteCharacters(start: number, end: number): void

  @override
  String toString() => 'TextNode';

  /// Creates a [TextNode] instance from a JSON object.
  factory TextNode.fromJson(Map json) => _$TextNodeFromJson(json);

  @override
  Map toJson() => _$TextNodeToJson(this);

  @override
  void updateVariableName({required String oldName, required String newName}) {
    if (characters.isEmpty) return;
    characters = characters.replaceAll(oldName, newName);
  }
}

/// These are the TextNode specific properties.
/// This is meant to be reusable, so if other nodes can use this.
mixin TextMixin {
  /// Text characters.
  late String characters;

  /// List of mixed text properties.
  /// Each [StartEndProp] has a [start] and [end] point that defines the index
  /// of characters for which the properties should be applied to.
  late List<StartEndProp> textMixedProps;

  /// Horizontal alignment applied to text.
  late TextAlignHorizontalEnum textAlignHorizontal;

  /// Vertical alignment applied to text.
  late TextAlignVerticalEnum textAlignVertical;

  /// Indents for each paragraph.
  late double paragraphIndent;

  /// Spacing between paragraphs.
  late double paragraphSpacing;

  /// Maximum number of lines that the text can spread across when wrapped.
  late int? maxLines;

  /// Defines how the text would clip when it overflows the available space.
  late TextOverflowC overflow;

  /// Set text properties.
  void setTextMixin({
    required String characters,
    required List<StartEndProp> textMixedProps,
    required TextAlignHorizontalEnum textAlignHorizontal,
    required TextAlignVerticalEnum textAlignVertical,
    required double paragraphIndent,
    required double paragraphSpacing,
    required TextOverflowC overflow,
    int? maxLines,
  }) {
    this.characters = characters;
    this.textMixedProps = textMixedProps;
    this.textAlignHorizontal = textAlignHorizontal;
    this.textAlignVertical = textAlignVertical;
    this.paragraphIndent = paragraphIndent;
    this.paragraphSpacing = paragraphSpacing;
    this.maxLines = maxLines;
    this.overflow = overflow;
  }
}

/// A mixin that retrieves the font names from the node with text support.
mixin FontMixin {
  /// Returns a list of font names.
  List<FontName> get fonts;
}
