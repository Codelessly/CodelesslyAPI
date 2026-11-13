// The fonts a site declares: font files beside its `site.json`, in the shape
// of a Flutter app's pubspec `fonts:` section (a family, and its files each
// with a weight and style). The runtime registers each family's files with
// the engine (`FontLoader`), so a text style naming the family draws in it.
import 'package:meta/meta.dart';

import 'json.dart';
import 'values/enums.dart' show FontStyle;
import 'values/paint.dart' show listEquals;

/// One font file of a [FontFamily] (a pubspec `fonts:` entry's `- asset:`):
/// its path relative to the site's folder, its weight (100–900) and style.
@immutable
final class FontAsset {
  const FontAsset({required this.asset, this.weight = 400, this.style = FontStyle.normal});

  /// The file, relative to the site's folder (`fonts/Inter-Bold.ttf`):
  /// TrueType or OpenType (`.ttf`, `.otf`), or WOFF (`.woff`).
  final String asset;

  /// The weight this file draws (Flutter's `FontWeight`, 100–900).
  final int weight;

  /// `normal` or `italic`.
  final FontStyle style;

  bool get italic => style == FontStyle.italic;

  static const Set<String> keys = {'asset', 'weight', 'style'};

  /// Null for anything without an `asset`.
  static FontAsset? fromJson(Object? json) {
    final m = readMap(json);
    final asset = readString(m?['asset'])?.trim();
    if (m == null || asset == null || asset.isEmpty) return null;
    return FontAsset(
      asset: asset,
      weight: (readInt(m['weight']) ?? 400).clamp(100, 900),
      style: readEnum(FontStyle.values, m['style'], FontStyle.normal),
    );
  }

  Json toJson() => {
        'asset': asset,
        if (weight != 400) 'weight': weight,
        if (style != FontStyle.normal) 'style': style.name,
      };

  @override
  bool operator ==(Object other) => other is FontAsset && other.asset == asset && other.weight == weight && other.style == style;

  @override
  int get hashCode => Object.hash(asset, weight, style);
}

/// A font family a site declares (a pubspec `fonts:` entry): text styles
/// name it by [family] (`"fontFamily": "Fraunces"`, whatever the files call
/// themselves inside), and each weight and style draws from its file.
///
/// JSON, in `site.json`: `"fonts": [{"family": "Fraunces", "fonts":
/// [{"asset": "fonts/Fraunces-Regular.ttf"}, {"asset": "fonts/Fraunces-Bold.ttf",
/// "weight": 700}, {"asset": "fonts/Fraunces-Italic.ttf", "style": "italic"}]}]`.
@immutable
final class FontFamily {
  const FontFamily({required this.family, this.fonts = const []});

  final String family;

  /// Its files, one per weight and style.
  final List<FontAsset> fonts;

  static const Set<String> keys = {'family', 'fonts'};

  /// The file extensions a font may have.
  static const Set<String> extensions = {'.ttf', '.otf', '.woff'};

  /// Null for anything without a `family`.
  static FontFamily? fromJson(Object? json) {
    final m = readMap(json);
    final family = readString(m?['family'])?.trim();
    if (m == null || family == null || family.isEmpty) return null;
    return FontFamily(family: family, fonts: [...?readList(m['fonts'])?.map(FontAsset.fromJson).nonNulls]);
  }

  static List<FontFamily> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {'family': family, 'fonts': [for (final f in fonts) f.toJson()]};

  @override
  bool operator ==(Object other) => other is FontFamily && other.family == family && listEquals(other.fonts, fonts);

  @override
  int get hashCode => Object.hash(family, Object.hashAll(fonts));
}

/// Whether [path] names a file relative to a published site
/// (`images/hero.jpg`, `./fonts/a.ttf`), not a URL (`https:`, `data:`,
/// `asset:`...), an absolute path or an expression.
bool isRelativeAssetPath(String path) {
  final p = path.trim();
  if (p.isEmpty || p.startsWith('/') || p.startsWith('#') || p.contains(r'${') || p.contains('\n')) return false;
  return !RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:').hasMatch(p);
}
