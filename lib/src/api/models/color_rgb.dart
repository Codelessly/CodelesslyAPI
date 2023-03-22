// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../serializable_mixin.dart';
import 'models.dart';

part 'color_rgb.g.dart';

/// An opaque color with no controllable opacity/alpha.
@JsonSerializable()
class ColorRGB extends Equatable with SerializableMixin {
  /// Red channel value, between 0 and 1
  final double r;

  /// Green channel value, between 0 and 1
  final double g;

  /// Blue channel value, between 0 and 1
  final double b;

  /// Creates a [ColorRGB] with given red, blue and green values.
  const ColorRGB({required this.r, required this.g, required this.b})
      : assert(r >= 0 && r <= 1),
        assert(g >= 0 && g <= 1),
        assert(b >= 0 && b <= 1);

  /// Represents black color.
  static const ColorRGB black = ColorRGB(r: 0.0, g: 0.0, b: 0.0);

  /// Represents grey color.
  static const ColorRGB grey = ColorRGB(r: 0.5, g: 0.5, b: 0.5);

  /// Represents white color.
  static const ColorRGB white = ColorRGB(r: 1.0, g: 1.0, b: 1.0);

  /// Represents red color.
  static const ColorRGB red = ColorRGB(r: 1.0, g: 0.0, b: 0.0);

  /// Gets the background color for a rectangle for a given index.
  /// Index is the quantity of rectangles in nodeManager + 1.
  /// This should get a darker/lighter shade, progressively.
  static ColorRGB defaultRectangleColorWithIndex(int index) {
    const int shadesNumber = 10;
    // [0, 80] it gets darker, [81, 160] it gets lighter, and so on..
    final double colorIntensity;
    if ((index ~/ shadesNumber) % 2 == 0) {
      // increasing order
      colorIntensity = math.min((index % shadesNumber) / shadesNumber, 1) / 5;
    } else {
      // decreasing order
      colorIntensity =
          math.min((shadesNumber - index % shadesNumber) / shadesNumber, 1) / 5;
    }

    return ColorRGB(
      r: 0.82 - colorIntensity,
      g: 0.82 - colorIntensity,
      b: 0.82 - colorIntensity,
    );
  }

  @override
  List<Object> get props => [r, g, b];

  /// Factory constructor for creating a new [ColorRGB] instance from JSON data.
  factory ColorRGB.fromJson(Map json) => _$ColorRGBFromJson(json);

  @override
  Map toJson() => _$ColorRGBToJson(this);

  /// Creates a [PaintModel] with this color and given [opacity].
  PaintModel toPaint([double opacity = 1.0]) =>
      PaintModel.solid(color: this, opacity: opacity);
}
