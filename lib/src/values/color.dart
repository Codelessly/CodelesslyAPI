import 'package:meta/meta.dart';

/// A 32-bit ARGB color, as Flutter's `Color`. JSON: `"#AARRGGBB"`
/// (`"#RRGGBB"` and ints also read).
@immutable
final class Color {
  const Color(int value) : value = value & 0xFFFFFFFF;

  /// From 0–255 components.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);

  final int value;

  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  int get alpha => (value >> 24) & 0xff;
  int get red => (value >> 16) & 0xff;
  int get green => (value >> 8) & 0xff;
  int get blue => value & 0xff;

  /// Opacity, 0–1.
  double get opacity => alpha / 255;

  /// This color with its alpha multiplied by [factor] (truncated, as
  /// Flutter's `Color.withOpacity` did and 10.x colors were converted).
  Color multiplyOpacity(double factor) =>
      factor >= 1 ? this : Color.fromARGB((alpha * factor.clamp(0, 1)).toInt(), red, green, blue);

  Color withAlpha(int a) => Color.fromARGB(a, red, green, blue);

  static Color? fromJson(Object? json) {
    if (json is int) return Color(json);
    if (json is! String) return null;
    var hex = json.startsWith('#') ? json.substring(1) : json;
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final v = int.tryParse(hex, radix: 16);
    return v == null ? null : Color(v);
  }

  String toJson() => '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  @override
  bool operator ==(Object other) => other is Color && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Color(${toJson()})';
}
