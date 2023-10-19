import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';

part 'letter_spacing.g.dart';

/// Letter spacing value unit.
enum LetterSpacingUnitEnum {
  /// Letter spacing in pixels.
  pixels,

  /// Letter spacing in percentage.
  percent;
}

/// The spacing between the text characters.
@JsonSerializable()
class LetterSpacing extends Equatable with SerializableMixin {
  /// Letter spacing value.
  final double value;

  /// Letter spacing value unit.
  final LetterSpacingUnitEnum unit;

  /// Creates a [LetterSpacing] instance with given values.
  const LetterSpacing({
    required this.value,
    this.unit = LetterSpacingUnitEnum.pixels,
  });

  /// Creates a pixel based [LetterSpacing] instance.
  const LetterSpacing.pixels(this.value) : unit = LetterSpacingUnitEnum.pixels;

  /// Creates a percentage based [LetterSpacing] instance.
  const LetterSpacing.percent(this.value)
      : unit = LetterSpacingUnitEnum.percent;

  /// Creates a [LetterSpacing] instance with zero value.
  static const LetterSpacing zero = LetterSpacing(
    value: 0,
    unit: LetterSpacingUnitEnum.pixels,
  );

  @override
  List<Object> get props => [value, unit];

  /// Factory constructor for creating a new [LetterSpacing] instance from
  /// JSON data.
  factory LetterSpacing.fromJson(Map json) => _$LetterSpacingFromJson(json);

  @override
  Map toJson() => _$LetterSpacingToJson(this);

  /// Duplicates this instance with given data overrides.
  LetterSpacing copyWith({
    double? value,
    LetterSpacingUnitEnum? unit,
  }) =>
      LetterSpacing(
        value: value ?? this.value,
        unit: unit ?? this.unit,
      );
}
