// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';

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
  w900;

  /// Displayable string representation of the object.
  String get prettify {
    switch (this) {
      case FontWeightNumeric.w100:
        return 'Thin';
      case FontWeightNumeric.w200:
        return 'Extra Light';
      case FontWeightNumeric.w300:
        return 'Light';
      case FontWeightNumeric.w400:
        return 'Normal';
      case FontWeightNumeric.w500:
        return 'Medium';
      case FontWeightNumeric.w600:
        return 'Semibold';
      case FontWeightNumeric.w700:
        return 'Bold';
      case FontWeightNumeric.w800:
        return 'Extra Bold';
      case FontWeightNumeric.w900:
        return 'Black';
    }
  }

  /// Whether the weight is considered bold, i.e., all weights heavier than
  /// medium.
  bool get isBold {
    if (compare(FontWeightNumeric.w500) < 0) return true;
    return false;
  }

  /// Compares [this] weight with the input weight.
  /// Returns 1 if the input weight is heavier than [this] weight.
  /// Returns -1 if the input weight is lighter than [this] weight.
  /// Returns 0 if both the weights are equal.
  int compare(FontWeightNumeric weight) {
    final int indexOfThisWeight = FontWeightNumeric.values.indexOf(this);
    final int indexOfInputWeight = FontWeightNumeric.values.indexOf(weight);
    if (indexOfInputWeight > indexOfThisWeight) {
      return 1;
    } else if (indexOfInputWeight < indexOfThisWeight) {
      return -1;
    } else {
      return 0;
    }
  }
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
