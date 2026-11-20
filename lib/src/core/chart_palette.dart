// A chart's colors from a theme's accent: the accent itself, then colors of
// other hues that stand apart from it and from one another, each about as
// light and as strong as the accent (a pale theme's are pale, a vivid one's
// vivid). The hues are turned in OKLCH, where equal steps look equal.
import 'dart:math' as math;

/// How far each color's hue is turned from the accent's, in degrees.
const _turns = [0, -80, 170, 110, 40, -120, 140, -40];

double _linear(int c) {
  final v = c / 255;
  return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _gamma(double v) => v <= 0.0031308 ? 12.92 * v : 1.055 * math.pow(v, 1 / 2.4) - 0.055;

double _cbrt(double v) => v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();

/// Lightness, chroma and hue (degrees) of an sRGB color.
(double, double, double) _oklch(int r, int g, int b) {
  final lr = _linear(r), lg = _linear(g), lb = _linear(b);
  final l = _cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb);
  final m = _cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb);
  final s = _cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb);
  final lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
  final a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  final bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
  return (lightness, math.sqrt(a * a + bb * bb), (math.atan2(bb, a) * 180 / math.pi) % 360);
}

/// The sRGB color of a lightness, chroma and hue, its chroma taken down
/// until the color is one a screen has.
int _rgb(double lightness, double chroma, double hue) {
  for (var c = chroma;; c -= 0.005) {
    final a = c * math.cos(hue * math.pi / 180), b = c * math.sin(hue * math.pi / 180);
    final l = math.pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3).toDouble();
    final m = math.pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3).toDouble();
    final s = math.pow(lightness - 0.0894841775 * a - 1.2914855480 * b, 3).toDouble();
    final rgb = [
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    ];
    if (c <= 0 || rgb.every((v) => v >= -0.0005 && v <= 1.0005)) {
      int channel(double v) => (_gamma(v.clamp(0.0, 1.0)) * 255).round().clamp(0, 255);
      return channel(rgb[0]) << 16 | channel(rgb[1]) << 8 | channel(rgb[2]);
    }
  }
}

/// The colors of a chart's series or slices from a theme's accent
/// ([argb], `0xAARRGGBB`): the accent, then seven colors of other hues,
/// each as light and as strong as it (a hue that is light by nature, a
/// yellow, a little lighter). An accent with no hue of its own (a black, a
/// gray) is followed by colors of a moderate strength.
List<int> chartPaletteOf(int argb) {
  final (lightness, chroma, own) = _oklch(argb >> 16 & 0xFF, argb >> 8 & 0xFF, argb & 0xFF);
  final hue = chroma < 0.03 ? 335.0 : own;
  final l = lightness.clamp(0.5, 0.72).toDouble(), c = chroma.clamp(0.1, 0.17).toDouble();
  return [
    argb,
    for (final turn in _turns.skip(1))
      () {
        final h = (hue + turn) % 360;
        return 0xFF000000 | _rgb(l + 0.14 * math.max(0, math.cos((h - 90) * math.pi / 180)), c, h);
      }(),
  ];
}

/// [chartPaletteOf] for a color written `#AARRGGBB` (or `#RRGGBB`), as
/// `#AARRGGBB` texts; null for a text that is no such color.
List<String>? chartPalette(String accent) {
  final m = RegExp(r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$').firstMatch(accent);
  if (m == null) return null;
  final hex = m[1]!;
  final argb = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return [
    accent.length == 9 ? accent.toUpperCase() : '#FF${hex.toUpperCase()}',
    for (final c in chartPaletteOf(argb).skip(1)) '#${c.toRadixString(16).padLeft(8, '0').toUpperCase()}',
  ];
}
