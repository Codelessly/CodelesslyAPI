// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';

part 'line_height.g.dart';

/// Type of line height unit.
enum LineHeightUnitEnum {
  /// Pixel based line height.
  pixels,

  /// Percentage based line height where having 100% line height is same as
  /// font size.
  percent,

  /// Auto line height.
  auto;
}

/// Height of a line in a text paragraph.
@JsonSerializable()
class LineHeight extends Equatable with SerializableMixin {
  /// Value of line height.
  final double? value;

  /// Unit of the [value]
  final LineHeightUnitEnum unit;

  /// Creates [LineHeight] with given values.
  const LineHeight({
    this.value,
    this.unit = LineHeightUnitEnum.pixels,
  });

  /// Creates pixel based [LineHeight] with given [value].
  const LineHeight.pixels([this.value]) : unit = LineHeightUnitEnum.pixels;

  /// Creates percentage based [LineHeight] with given [value].
  const LineHeight.percent([this.value]) : unit = LineHeightUnitEnum.percent;

  /// Auto line height.
  static const LineHeight auto =
      LineHeight(value: 0, unit: LineHeightUnitEnum.auto);

  @override
  List<Object?> get props => [value, unit];

  /// Factory constructor for creating a new [LineHeight] instance from
  /// JSON data.
  factory LineHeight.fromJson(Map json) => _$LineHeightFromJson(json);

  @override
  Map toJson() => _$LineHeightToJson(this);

  /// Duplicates this instance of [LineHeight] with given data overrides.
  LineHeight copyWith({double? value, LineHeightUnitEnum? unit}) =>
      LineHeight(value: value ?? this.value, unit: unit ?? this.unit);
}
