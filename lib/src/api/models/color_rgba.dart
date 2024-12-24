import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../../../codelessly_api.dart';

part 'color_rgba.g.dart';

/// A color model capable of having variable opacity/alpha.
@JsonSerializable(useDynamics: true, createToJson: false)
final class ColorRGBA extends ColorRGB with DynamicSerializableMixin {
  /// Alpha channel value, between 0 and 1
  final double a;

  /// Represents transparent color.
  static const ColorRGBA transparent =
      ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.0);

  /// Represents black color.
  static const ColorRGBA black = ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 1.0);

  /// Represents black color with 54% alpha.
  static const ColorRGBA black54 = ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.54);

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
    required super.r,
    required super.g,
    required super.b,
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
  List<Object> get props => [...super.props, a];

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
  String toHex({bool includeHash = true, bool includeAlpha = true}) {
    final r = (this.r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).toInt().toRadixString(16).padLeft(2, '0');
    final a = (this.a * 255).toInt().toRadixString(16).padLeft(2, '0');
    return '${includeHash ? '#' : ''}${includeAlpha ? a : ''}$r$g$b'
        .toUpperCase();
  }

  @override
  dynamic toJson() => toHex(includeHash: true);

  /// Factory constructor for creating a new [ColorRGBA] instance form JSON data.
  factory ColorRGBA.fromJson(dynamic json) {
    if (json is String) {
      return fromHex(json) ?? ColorRGBA.transparent;
    }
    return _$ColorRGBAFromJson(json);
  }

  /// Creates a [PaintModel] with this color.
  @override
  PaintModel toPaint([String? id, double? opacity]) => PaintModel.solid(
        id: id ?? generateId(),
        color: ColorRGB.fromColorRGBA(this),
        opacity: opacity ?? a,
      );
}
