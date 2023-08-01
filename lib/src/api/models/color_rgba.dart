// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'color_rgba.g.dart';

/// A color model capable of having variable opacity/alpha.
@JsonSerializable()
class ColorRGBA with EquatableMixin, SerializableMixin {
  /// Red channel value, between 0 and 1
  final double r;

  /// Green channel value, between 0 and 1
  final double g;

  /// Blue channel value, between 0 and 1
  final double b;

  /// Alpha channel value, between 0 and 1
  final double a;

  /// Represents transparent color.
  static const ColorRGBA transparent =
      ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.0);

  /// Represents black color.
  static const ColorRGBA black = ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 1.0);

  /// Represents black color with 10% alpha.
  static const ColorRGBA black10 = ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.1);

  /// Represents white color.
  static const ColorRGBA white = ColorRGBA(r: 1.0, g: 1.0, b: 1.0, a: 1.0);

  /// Represents grey color.
  static const ColorRGBA grey = ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: 1.0);

  /// Represents red color.
  static const ColorRGBA red = ColorRGBA(r: 1, g: 0, b: 0, a: 1.0);

  /// Represents grey color with 10% alpha.
  static const ColorRGBA grey10 = ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: 0.1);

  /// Creates a [ColorRGBA] with given red, blue, green and alpha values.
  const ColorRGBA({
    required this.r,
    required this.g,
    required this.b,
    required this.a,
  });

  /// Duplicates this [ColorRGBA] with given value overrides.
  ColorRGBA copyWith({
    double? r,
    double? g,
    double? b,
    double? a,
  }) =>
      ColorRGBA(
        r: r ?? this.r,
        g: g ?? this.g,
        b: b ?? this.b,
        a: a ?? this.a,
      );

  /// In gradients, each color-stop has an RGBA color. In addition to that,
  /// the fill that holds these color-stops has it's own opacity.
  ///
  /// This method multiplies the fill's opacity with the color-stop's opacity.
  ColorRGBA multiplyAlpha(double alpha) =>
      ColorRGBA(r: r, g: g, b: b, a: a * alpha);

  @override
  List<Object> get props => [r, g, b, a];

  /// Factory constructor for creating a new [ColorRGBA] instance form JSON data.
  factory ColorRGBA.fromJson(Map json) => _$ColorRGBAFromJson(json);

  /// Factory constructor for creating a new [ColorRGBA] instance form JSON data.
  /// Returns null if cannot parse the JSON.
  static ColorRGBA? tryFromJson(Map? json) {
    if (json == null) return null;
    try {
      return ColorRGBA.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Factory constructor for creating a new [ColorRGBA] instance from hex string.
  static ColorRGBA? fromHex(String hex) {
    String hexCode = hex.replaceAll('#', '').toUpperCase();
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }

    if (!RegExp(r'^[0-9A-F]{8}$', caseSensitive: false).hasMatch(hexCode)) {
      return null;
    }

    return ColorRGBA(
      r: int.parse(hexCode.substring(2, 4), radix: 16) / 255,
      g: int.parse(hexCode.substring(4, 6), radix: 16) / 255,
      b: int.parse(hexCode.substring(6, 8), radix: 16) / 255,
      a: int.parse(hexCode.substring(0, 2), radix: 16) / 255,
    );
  }

  @override
  Map toJson() => _$ColorRGBAToJson(this);

  /// Creates a [PaintModel] with this color.
  PaintModel toPaint([String? id]) => PaintModel.solid(
        id: id ?? generateId(),
        color: ColorRGB.fromColorRGBA(this),
        opacity: a,
      );
}
