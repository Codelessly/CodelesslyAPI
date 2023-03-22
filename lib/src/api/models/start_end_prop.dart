// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'start_end_prop.g.dart';

/// Different types of text decoration.
enum TextDecorationEnum {
  /// No decoration.
  none,

  /// Text with underline.
  underline,

  /// Text with line above.
  overline,

  /// Text with line strike-through.
  strikethrough;

  /// Displayable string representation of this enum.
  String get prettify {
    switch (this) {
      case TextDecorationEnum.none:
        return 'None';
      case TextDecorationEnum.underline:
        return 'Underline';
      case TextDecorationEnum.overline:
        return 'Overline';
      case TextDecorationEnum.strikethrough:
        return 'Strikethrough';
    }
  }
}

/// A solid color, gradient, or image texture that
/// can be applied as fills or strokes
@JsonSerializable()
class StartEndProp extends TextProp {
  /// Index of the start character (zero when in the first position).
  final int start;

  /// Index of the last character where the style is applied.
  /// This is inclusive.
  final int end;

  /// This can be used if it is just meant to hold style data for text. It
  /// will ignore [start] and [end] properties.
  const StartEndProp.general({
    super.fills = const [PaintModel.whitePaint],
    super.textDecoration,
    super.letterSpacing,
    super.fontSize = 12,
    super.fontName,
    super.lineHeight,
    super.link,
    super.isJsonPath,
  })  : start = 0,
        end = 0;

  /// Creates a [StartEndProp] with the given data.
  const StartEndProp({
    required this.start,
    required this.end,
    super.fills,
    super.textDecoration,
    super.letterSpacing,
    super.fontSize,
    super.fontName,
    super.lineHeight,
    super.link,
    super.isJsonPath,
  });

  @override
  StartEndProp copyWith({
    int? start,
    int? end,
    List<PaintModel>? fills,
    TextDecorationEnum? textDecoration,
    double? fontSize,
    LetterSpacing? letterSpacing,
    FontName? fontName,
    LineHeight? lineHeight,
    String? link,
    bool? isJsonPath,
  }) =>
      StartEndProp(
        start: start ?? this.start,
        end: end ?? this.end,
        fills: fills ?? this.fills,
        textDecoration: textDecoration ?? this.textDecoration,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontName: fontName ?? this.fontName,
        lineHeight: lineHeight ?? this.lineHeight,
        link: link ?? this.link,
        isJsonPath: isJsonPath ?? this.isJsonPath,
      );

  @override
  List<Object> get props => [
        start,
        end,
        fills,
        textDecoration,
        fontSize,
        letterSpacing,
        fontName,
        lineHeight,
        link,
        isJsonPath,
      ];

  /// Factory constructor for creating a new [StartEndProp] instance from
  /// JSON data.
  factory StartEndProp.fromJson(Map json) => _$StartEndPropFromJson(json);

  @override
  Map toJson() => _$StartEndPropToJson(this);
}

/// Represents text styling for whole text. All the values/properties are
/// applied to the whole text unlike [StartEndProp] which can be used for
/// rich text.
@JsonSerializable()
class TextProp extends Equatable with SerializableMixin {
  /// Fills for the text.
  final List<PaintModel> fills;

  /// Decoration for the text.
  final TextDecorationEnum textDecoration;

  /// Size of the text.
  final double fontSize;

  /// Space between letters in text.
  final LetterSpacing letterSpacing;

  /// Font family.
  final FontName fontName;

  /// line height for the text.
  final LineHeight lineHeight;

  /// URL to launch when text span is tapped.
  final String link;

  /// Whether the text is recognized as a variable.
  final bool isJsonPath;

  /// Creates a [TextProp] with the given data.
  const TextProp({
    this.fills = const [PaintModel.blackPaint],
    this.textDecoration = TextDecorationEnum.none,
    this.letterSpacing = LetterSpacing.zero,
    this.fontSize = 18,
    this.fontName = FontName.robotoRegular,
    this.lineHeight = LineHeight.auto,
    this.link = '',
    this.isJsonPath = false,
  });

  /// Creates a [TextProp] with the given data with white text.
  const TextProp.general({
    this.fills = const [PaintModel.whitePaint],
    this.textDecoration = TextDecorationEnum.none,
    this.letterSpacing = LetterSpacing.zero,
    this.fontSize = 12,
    this.fontName = FontName.robotoRegular,
    this.lineHeight = LineHeight.auto,
    this.link = '',
    this.isJsonPath = false,
  });

  /// Duplicates this instance with given data overrides.
  TextProp copyWith({
    List<PaintModel>? fills,
    TextDecorationEnum? textDecoration,
    double? fontSize,
    LetterSpacing? letterSpacing,
    FontName? fontName,
    LineHeight? lineHeight,
    String? link,
    bool? isJsonPath,
  }) =>
      TextProp(
        fills: fills ?? this.fills,
        textDecoration: textDecoration ?? this.textDecoration,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontName: fontName ?? this.fontName,
        lineHeight: lineHeight ?? this.lineHeight,
        link: link ?? this.link,
        isJsonPath: isJsonPath ?? this.isJsonPath,
      );

  @override
  List<Object> get props => [
        fills,
        textDecoration,
        fontSize,
        letterSpacing,
        fontName,
        lineHeight,
        link,
        isJsonPath,
      ];

  /// Factory constructor for creating a new [TextProp] instance from JSON data.
  factory TextProp.fromJson(Map json) => _$TextPropFromJson(json);

  @override
  Map toJson() => _$TextPropToJson(this);
}
