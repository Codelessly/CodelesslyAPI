import 'package:meta/meta.dart';

/// A 32-bit ARGB color, as Flutter's `Color`. JSON: `"#AARRGGBB"`
/// (`"#RRGGBB"` and ints also read), or the name of one of the project's
/// theme colors (`"ember"`: [ThemeTokens.colors], resolved before the
/// document renders; see `resolveThemeRefs`).
@immutable
final class Color {
  const Color(int value) : value = value & 0xFFFFFFFF, name = null;

  /// A theme color named [name], not resolved yet: it keeps its name
  /// through a decode and encode, and stands for transparent until the
  /// document is resolved against its theme.
  const Color.named(String this.name) : value = 0;

  /// The theme color this color names while unresolved; null for a color
  /// given by value.
  final String? name;

  /// From 0–255 components.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff),
        name = null;

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
  /// Flutter's `Color.withOpacity` did).
  Color multiplyOpacity(double factor) =>
      factor >= 1 ? this : Color.fromARGB((alpha * factor.clamp(0, 1)).toInt(), red, green, blue);

  Color withAlpha(int a) => Color.fromARGB(a, red, green, blue);

  /// [json] as a color, or as a theme color's name ([isName]): what a
  /// declared color field reads.
  static Color? fromJson(Object? json) => fromHex(json) ?? (json is String && isName(json) ? Color.named(json) : null);

  /// [json] as a color given by value (`"#AARRGGBB"`, `"#RRGGBB"`, an int),
  /// else null: names are not read.
  static Color? fromHex(Object? json) {
    if (json is int) return Color(json);
    if (json is! String) return null;
    var hex = json.startsWith('#') ? json.substring(1) : json;
    if (hex.length == 6) hex = 'FF$hex';
    final v = hex.length == 8 ? int.tryParse(hex, radix: 16) : null;
    return v == null ? null : Color(v);
  }

  /// Whether [text] is written as a theme color's name (a key such as
  /// `ember` or `brandBlue`): a letter, then letters, digits or `_`, and not
  /// a hex color.
  static bool isName(String text) =>
      RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(text) && !RegExp(r'^([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$').hasMatch(text);

  String toJson() => name ?? '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  @override
  bool operator ==(Object other) => other is Color && other.value == value && other.name == name;

  @override
  int get hashCode => Object.hash(value, name);

  @override
  String toString() => 'Color(${toJson()})';
}
