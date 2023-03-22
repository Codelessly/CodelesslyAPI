// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';

part 'font_name.g.dart';

/// Represents different font weights. Directly translates to Flutter's
/// [FontWeight].
enum FontWeightNumeric {
  /// Thin, the least thick.
  w100,

  /// Extra-light, Ultra-light.
  w200,

  /// Light
  w300,

  /// Normal / regular / plain.
  w400,

  /// Medium
  w500,

  /// Semi bold
  w600,

  /// Bold
  w700,

  /// Extra bold, Ultra bold.
  w800,

  /// Black
  w900,
}

/// A solid color, gradient, or image texture that
/// can be applied as fills or strokes
@JsonSerializable()
class FontName extends Equatable with SerializableMixin {
  /// example: SF Pro
  final String family;

  /// example: Bold
  final String style;

  /// example: w400
  /// This property is null in projects older than April 30, 2021.
  final FontWeightNumeric? weight;

  /// Whether this style is italic.
  bool get isItalic => style.toLowerCase().contains('italic');

  /// Creates a new instance of [FontName] with given data.
  const FontName({
    required this.family,
    required this.style,
    required this.weight,
  });

  /// Duplicates this instance with given data overrides.
  FontName copyWith({
    String? family,
    String? style,
    FontWeightNumeric? weight,
  }) =>
      FontName(
        family: family ?? this.family,
        style: style ?? this.style,
        weight: weight ?? this.weight,
      );

  /// Represents Roboto fonts.
  static const FontName robotoRegular = FontName(
    family: 'Roboto',
    style: 'Normal',
    weight: FontWeightNumeric.w400,
  );

  /// Represents Poppins fonts.
  static const FontName poppinsRegular = FontName(
    family: 'Poppins',
    style: 'Normal',
    weight: FontWeightNumeric.w400,
  );

  /// Represents Inter fonts.
  static const FontName montserratRegular = FontName(
    family: 'Montserrat',
    style: 'Normal',
    weight: FontWeightNumeric.w400,
  );

  @override
  List<Object?> get props => [family, style, weight];

  /// Factory constructor for creating a new [FontName] instance from JSON data.
  factory FontName.fromJson(Map json) => _$FontNameFromJson(json);

  @override
  Map toJson() => _$FontNameToJson(this);
}
