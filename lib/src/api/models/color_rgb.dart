import 'dart:math' as math;

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'color_rgb.g.dart';

/// An opaque color with no controllable opacity/alpha.
@JsonSerializable(useDynamics: true)
class ColorRGB extends Equatable with DynamicSerializableMixin {
  /// Red channel value, between 0 and 1.
  final double r;

  /// Green channel value, between 0 and 1.
  final double g;

  /// Blue channel value, between 0 and 1.
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

  /// Generates a color with darker or lighter shade based on the given index.
  static ColorRGB defaultRectangleColorWithIndex(int index) {
    const int shadesNumber = 10;
    // [0, 80] it gets darker, [81, 160] it gets lighter, and so on.
    final double colorIntensity;
    if ((index ~/ shadesNumber) % 2 == 0) {
      // Increasing order.
      colorIntensity = math.min((index % shadesNumber) / shadesNumber, 1) / 5;
    } else {
      // Decreasing order.
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

  /// Transform a [ColorRGBA] into this model.
  static ColorRGB? fromColorRGBA(ColorRGBA? color) {
    if (color == null) return null;
    return ColorRGB(r: color.r, g: color.g, b: color.b);
  }

  /// Factory constructor for creating a new [ColorRGBA] instance from hex string.
  static ColorRGB? fromHex(String hex) {
    String hexCode = hex.replaceAll('#', '').toUpperCase();
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }

    if (!RegExp(r'^[0-9A-F]{8}$', caseSensitive: false).hasMatch(hexCode)) {
      return null;
    }

    return ColorRGB(
      r: int.parse(hexCode.substring(2, 4), radix: 16) / 255,
      g: int.parse(hexCode.substring(4, 6), radix: 16) / 255,
      b: int.parse(hexCode.substring(6, 8), radix: 16) / 255,
    );
  }

  /// Converts this [ColorRGBA] to [ColorRGB] by removing the alpha channel.
  String toHex({bool includeHash = true}) {
    final r = (this.r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).toInt().toRadixString(16).padLeft(2, '0');
    return '${includeHash ? '#' : ''}$r$g$b'.toUpperCase();
  }

  @override
  dynamic toJson() => toHex(includeHash: true);

  /// Factory constructor for creating a new [ColorRGB] instance from JSON data.
  factory ColorRGB.fromJson(dynamic json) {
    if (json is String) {
      return fromHex(json) ?? ColorRGB.black;
    }
    return _$ColorRGBFromJson(json);
  }

  /// Creates a [PaintModel] with this color and given [opacity].
  PaintModel toPaint([String? id, double opacity = 1.0]) => PaintModel.solid(
        id: id ?? generateId(),
        color: this,
        opacity: opacity,
      );
}
