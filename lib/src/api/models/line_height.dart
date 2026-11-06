import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../json_defaults.dart';

part 'line_height.g.dart';

/// Type of line height unit.
enum LineHeightUnitEnum {
  /// Pixel based line height.
  pixels,

  /// Percentage based line height where having 100% line height is same as
  /// font size.
  percent,

  /// Auto line height.
  auto,
}

/// How the space a [LineHeight] adds or takes away is shared between the
/// top and the bottom of a line. Mirrors Flutter's
/// `TextLeadingDistribution`.
enum LeadingDistributionEnum {
  /// In proportion to the font's ascent and descent: Flutter's default for a
  /// `TextStyle(height: x)` written on its own.
  proportional,

  /// Half above and half below: what Material 3's text theme uses, so a
  /// `Text` inside a `Scaffold` or `Material` (which takes its default text
  /// style from the theme) lays out this way.
  even,
}

/// Height of a line in a text paragraph.
@JsonSerializable()
class LineHeight extends Equatable with SerializableMixin {
  /// Value of line height.
  final double? value;

  /// Unit of the [value]
  final LineHeightUnitEnum unit;

  /// Where the glyphs sit in a line whose height differs from the font's
  /// own: the extra (or missing) space goes above and below in proportion
  /// to the font's ascent and descent, or half on each side. Has no effect
  /// on the height of the text, only on where it is drawn in it, and none
  /// on [auto] line heights.
  final LeadingDistributionEnum leadingDistribution;

  /// Creates [LineHeight] with given values.
  const LineHeight({
    this.value,
    this.unit = LineHeightUnitEnum.pixels,
    this.leadingDistribution = LeadingDistributionEnum.proportional,
  });

  /// Creates pixel based [LineHeight] with given [value].
  const LineHeight.pixels([this.value])
    : unit = LineHeightUnitEnum.pixels,
      leadingDistribution = LeadingDistributionEnum.proportional;

  /// Creates percentage based [LineHeight] with given [value].
  const LineHeight.percent([
    this.value,
    this.leadingDistribution = LeadingDistributionEnum.proportional,
  ]) : unit = LineHeightUnitEnum.percent;

  /// Auto line height.
  static const LineHeight auto = LineHeight(
    value: 0,
    unit: LineHeightUnitEnum.auto,
  );

  @override
  List<Object?> get props => [value, unit, leadingDistribution];

  /// Factory constructor for creating a new [LineHeight] instance from
  /// JSON data.
  factory LineHeight.fromJson(Map json) => _$LineHeightFromJson(json);

  @override
  Map toJson() => _$LineHeightOmitDefaults(this, _$LineHeightToJson(this));

  /// Duplicates this instance of [LineHeight] with given data overrides.
  LineHeight copyWith({
    double? value,
    LineHeightUnitEnum? unit,
    LeadingDistributionEnum? leadingDistribution,
  }) => LineHeight(
    value: value ?? this.value,
    unit: unit ?? this.unit,
    leadingDistribution: leadingDistribution ?? this.leadingDistribution,
  );
}
