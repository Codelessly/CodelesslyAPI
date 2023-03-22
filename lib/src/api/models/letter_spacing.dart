import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';

part 'letter_spacing.g.dart';

/// LetterSpacing value unit.
enum LetterSpacingUnitEnum {
  /// LetterSpacing in pixels.
  pixels,

  /// LetterSpacing in percentage.
  percent;
}

/// A solid color, gradient, or image texture that
/// can be applied as fills or strokes
@JsonSerializable()
class LetterSpacing extends Equatable with SerializableMixin {
  /// LetterSpacing value.
  final double value;

  /// LetterSpacing value unit.
  final LetterSpacingUnitEnum unit;

  /// Creates a LetterSpacing with given values.
  const LetterSpacing({required this.value, required this.unit});

  /// Creates a pixel based LetterSpacing.
  const LetterSpacing.pixels(this.value) : unit = LetterSpacingUnitEnum.pixels;

  /// Creates a percentage based LetterSpacing.
  const LetterSpacing.percent(this.value)
      : unit = LetterSpacingUnitEnum.percent;

  /// Creates a LetterSpacing with zero value.
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
