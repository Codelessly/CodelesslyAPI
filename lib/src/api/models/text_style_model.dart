import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'text_style_model.g.dart';

/// A partial text style for text the runtime draws itself, such as a toast's
/// message or a confirm dialog's title.
///
/// Each value that is set replaces that part of the look the text would take
/// otherwise (the app's font, its size and color); the rest stays.
///
/// JSON, e.g. `{"fontFamily": "Work Sans", "fontWeight": "w600",
/// "fontSize": 13}`.
@JsonSerializable()
class TextStyleModel with Equatable, SerializableMixin {
  /// Font family, e.g. `Work Sans`. A Google Font loads by its name.
  final String? fontFamily;

  /// Font weight.
  @JsonKey(unknownEnumValue: FontWeightNumeric.w400)
  final FontWeightNumeric? fontWeight;

  /// Whether the text is italic.
  final bool? italic;

  /// Font size in logical pixels.
  final double? fontSize;

  /// Line height as a multiple of [fontSize], e.g. 1.4.
  final double? lineHeight;

  /// Space between letters in logical pixels.
  final double? letterSpacing;

  /// Text color. Wins over the color fields of the action it belongs to.
  final ColorRGBA? color;

  /// Creates a [TextStyleModel].
  const TextStyleModel({
    this.fontFamily,
    this.fontWeight,
    this.italic,
    this.fontSize,
    this.lineHeight,
    this.letterSpacing,
    this.color,
  });

  /// The font as a [FontName], or null when [fontFamily] is not set.
  FontName? get fontName => fontFamily == null || fontFamily!.isEmpty
      ? null
      : FontName(
          family: fontFamily!,
          weight: fontWeight ?? FontWeightNumeric.w400,
          style: italic == true ? 'Italic' : 'Normal',
        );

  /// Duplicates this style with the given values replaced.
  TextStyleModel copyWith({
    String? fontFamily,
    FontWeightNumeric? fontWeight,
    bool? italic,
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    ColorRGBA? color,
  }) => TextStyleModel(
    fontFamily: fontFamily ?? this.fontFamily,
    fontWeight: fontWeight ?? this.fontWeight,
    italic: italic ?? this.italic,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    color: color ?? this.color,
  );

  @override
  List<Object?> get props => [
    fontFamily,
    fontWeight,
    italic,
    fontSize,
    lineHeight,
    letterSpacing,
    color,
  ];

  /// Creates a [TextStyleModel] from JSON.
  factory TextStyleModel.fromJson(Map json) => _$TextStyleModelFromJson(json);

  @override
  Map toJson() =>
      _$TextStyleModelOmitDefaults(this, _$TextStyleModelToJson(this));
}
