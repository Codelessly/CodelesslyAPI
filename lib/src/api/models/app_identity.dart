// A project's identity as a web app and as a mobile app: names, title,
// description, icons, social card, PWA manifest, colors and splash.
//
// The Editor stores it on the project and copies it into the publish model
// (`appIdentity` in `publish/<projectId>`, so in the `publish/<slug>.json`
// bundle) and into a small `publish/<slug>.identity.json` sidecar that
// site.codelessly.com reads server-side to fill each slug's <head>.
//
// The JSON is written by hand (no codegen) so it stays readable by the Site's
// JavaScript too: colors are `#RRGGBB` / `#RRGGBBAA` strings, enums are their
// names, nulls are left out. Parsing is lenient: unknown keys are ignored,
// legacy shapes are migrated (see [AppIdentity.fromJson]).

import 'package:equatable/equatable.dart';

/// `${page.title} · ${app.name}`: the default page title template.
const String kDefaultTitleTemplate = r'${page.title} · ${app.name}';

/// The schema version [AppIdentity.toJson] writes.
const int kAppIdentitySchemaVersion = 1;

/// How an installed web app opens (Web App Manifest `display`).
enum PwaDisplayMode {
  standalone('standalone'),
  fullscreen('fullscreen'),
  minimalUi('minimal-ui'),
  browser('browser');

  const PwaDisplayMode(this.value);

  /// The manifest value.
  final String value;

  static PwaDisplayMode? parse(Object? value) => _parseEnum(
        values,
        value,
        (e) => [e.name, e.value],
      );
}

/// The orientation an installed app locks to (manifest `orientation`).
enum PwaOrientation {
  any('any'),
  natural('natural'),
  portrait('portrait'),
  portraitPrimary('portrait-primary'),
  landscape('landscape'),
  landscapePrimary('landscape-primary');

  const PwaOrientation(this.value);

  final String value;

  static PwaOrientation? parse(Object? value) =>
      _parseEnum(values, value, (e) => [e.name, e.value]);
}

/// The Twitter / X card type.
enum SocialCardType {
  summary('summary'),
  summaryLargeImage('summary_large_image');

  const SocialCardType(this.value);

  final String value;

  static SocialCardType? parse(Object? value) =>
      _parseEnum(values, value, (e) => [e.name, e.value]);
}

/// The document's text direction.
enum IdentityTextDirection {
  ltr,
  rtl,
  auto;

  static IdentityTextDirection? parse(Object? value) =>
      _parseEnum(values, value, (e) => [e.name]);
}

/// The status bar style on mobile: which color its icons and text use.
enum StatusBarStyle {
  /// Pick from the theme / background brightness.
  auto,

  /// Light (white) icons, for dark backgrounds.
  light,

  /// Dark icons, for light backgrounds.
  dark;

  static StatusBarStyle? parse(Object? value) =>
      _parseEnum(values, value, (e) => [e.name]);

  /// The `apple-mobile-web-app-status-bar-style` meta value.
  String get appleWebValue => switch (this) {
        StatusBarStyle.light => 'black-translucent',
        StatusBarStyle.dark => 'default',
        StatusBarStyle.auto => 'default',
      };
}

T? _parseEnum<T>(
  List<T> values,
  Object? value,
  List<String> Function(T) names,
) {
  if (value is! String) return null;
  final String v = value.trim().toLowerCase().replaceAll('_', '-');
  for (final T e in values) {
    for (final String n in names(e)) {
      if (n.toLowerCase().replaceAll('_', '-') == v) return e;
      // camelCase name vs kebab value: minimalUi == minimal-ui.
      final String kebab = n
          .replaceAllMapped(RegExp('[A-Z]'), (m) => '-${m[0]!.toLowerCase()}')
          .toLowerCase();
      if (kebab == v) return e;
    }
  }
  return null;
}

/// A color as `#RRGGBB` (or `#RRGGBBAA`), or null when [value] isn't one.
///
/// Accepts `#RGB`, `RRGGBB`, `0xAARRGGBB` and an ARGB int (the legacy shape
/// of colors in Codelessly JSON).
String? normalizeHexColor(Object? value) {
  if (value is int) {
    final int a = (value >> 24) & 0xFF;
    final String rgb =
        (value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    return a == 0xFF || a == 0
        ? '#$rgb'
        : '#$rgb${a.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
  if (value is Map) {
    // A ColorRGB(A) map: {r, g, b, a?} with 0..1 or 0..255 channels.
    num? ch(String k) => value[k] is num ? value[k] as num : null;
    final num? r = ch('r'), g = ch('g'), b = ch('b');
    if (r == null || g == null || b == null) return null;
    final bool unit = r <= 1 && g <= 1 && b <= 1;
    String hex(num c) => ((unit ? c * 255 : c).round().clamp(0, 255))
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final num? a = ch('a');
    final String base = '#${hex(r)}${hex(g)}${hex(b)}';
    if (a == null || a >= (unit ? 1 : 255)) return base;
    return '$base${hex(unit ? a : a)}';
  }
  if (value is! String) return null;
  String s = value.trim();
  if (s.startsWith('0x') || s.startsWith('0X')) {
    final int? n = int.tryParse(s.substring(2), radix: 16);
    return n == null ? null : normalizeHexColor(s.length > 8 ? n : n | 0xFF000000);
  }
  if (s.startsWith('#')) s = s.substring(1);
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(s)) return null;
  if (s.length == 3) s = s.split('').map((c) => '$c$c').join();
  if (s.length != 6 && s.length != 8) return null;
  if (s.length == 8 && s.substring(6).toUpperCase() == 'FF') {
    s = s.substring(0, 6);
  }
  return '#${s.toUpperCase()}';
}

String? _str(Object? value) {
  if (value is! String) return null;
  final String s = value.trim();
  return s.isEmpty ? null : s;
}

List<String> _strList(Object? value) {
  if (value is String) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is! List) return const [];
  return [
    for (final Object? e in value)
      if (_str(e) case final String s) s,
  ];
}

double? _double(Object? value) => value is num
    ? value.toDouble()
    : value is String
        ? double.tryParse(value)
        : null;

int? _int(Object? value) => value is num
    ? value.toInt()
    : value is String
        ? int.tryParse(value)
        : null;

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? value.map((k, v) => MapEntry('$k', v)) : null;

/// Leaves out nulls and empty lists/maps, like the rest of Codelessly JSON.
Map<String, dynamic> _clean(Map<String, dynamic> map) => map
  ..removeWhere(
    (k, v) =>
        v == null || (v is List && v.isEmpty) || (v is Map && v.isEmpty),
  );

/// An uploaded image: where it is and what it is.
class IdentityImage with Equatable {
  /// The public URL (Firebase Storage download URL, content-hash named).
  final String url;

  /// Pixel size, when known (null for SVG).
  final int? width;
  final int? height;

  /// MIME type: image/png, image/svg+xml, image/x-icon, image/jpeg, ...
  final String? contentType;

  /// The content hash the file is named after (cache busting).
  final String? hash;

  /// Whether the image has transparent pixels (iOS icons shouldn't).
  final bool? hasAlpha;

  const IdentityImage({
    required this.url,
    this.width,
    this.height,
    this.contentType,
    this.hash,
    this.hasAlpha,
  });

  /// Reads an image; a bare URL string is the legacy shape.
  static IdentityImage? fromJson(Object? json) {
    if (json is String) {
      final String? url = _str(json);
      return url == null ? null : IdentityImage(url: url);
    }
    final Map<String, dynamic>? map = _map(json);
    final String? url = _str(map?['url'] ?? map?['src']);
    if (map == null || url == null) return null;
    return IdentityImage(
      url: url,
      width: _int(map['width']),
      height: _int(map['height']),
      contentType: _str(map['contentType'] ?? map['type']),
      hash: _str(map['hash']),
      hasAlpha: map['hasAlpha'] is bool ? map['hasAlpha'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'url': url,
        'width': width,
        'height': height,
        'contentType': contentType,
        'hash': hash,
        'hasAlpha': hasAlpha,
      });

  bool get isSvg =>
      contentType == 'image/svg+xml' ||
      Uri.tryParse(url)?.path.toLowerCase().endsWith('.svg') == true;

  bool get isSquare => width != null && width == height;

  @override
  List<Object?> get props => [url, width, height, contentType, hash, hasAlpha];
}

/// The Open Graph / Twitter card: what link unfurls show.
class SocialCard with Equatable {
  /// Falls back to the page title.
  final String? title;

  /// Falls back to the meta description.
  final String? description;

  /// 1200×630 recommended.
  final IdentityImage? image;
  final String? imageAlt;
  final SocialCardType cardType;

  /// The site's X / Twitter handle, like `@codelessly`.
  final String? twitterSite;

  const SocialCard({
    this.title,
    this.description,
    this.image,
    this.imageAlt,
    this.cardType = SocialCardType.summaryLargeImage,
    this.twitterSite,
  });

  factory SocialCard.fromJson(Object? json) {
    final Map<String, dynamic> m = _map(json) ?? const {};
    return SocialCard(
      title: _str(m['title']),
      description: _str(m['description']),
      image: IdentityImage.fromJson(m['image']),
      imageAlt: _str(m['imageAlt']),
      cardType: SocialCardType.parse(m['cardType'] ?? m['card']) ??
          SocialCardType.summaryLargeImage,
      twitterSite: _str(m['twitterSite']),
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'title': title,
        'description': description,
        'image': image?.toJson(),
        'imageAlt': imageAlt,
        'cardType': cardType.value,
        'twitterSite': twitterSite,
      });

  @override
  List<Object?> get props =>
      [title, description, image, imageAlt, cardType, twitterSite];
}

/// A manifest shortcut (long-press menu of an installed app).
class PwaShortcut with Equatable {
  final String name;
  final String? shortName;
  final String? description;

  /// Relative to the app's start, like `cart` or `/cart`.
  final String url;

  const PwaShortcut({
    required this.name,
    required this.url,
    this.shortName,
    this.description,
  });

  static PwaShortcut? fromJson(Object? json) {
    final Map<String, dynamic>? m = _map(json);
    final String? name = _str(m?['name']);
    final String? url = _str(m?['url']);
    if (name == null || url == null) return null;
    return PwaShortcut(
      name: name,
      url: url,
      shortName: _str(m!['shortName'] ?? m['short_name']),
      description: _str(m['description']),
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'name': name,
        'shortName': shortName,
        'description': description,
        'url': url,
      });

  @override
  List<Object?> get props => [name, shortName, description, url];
}

/// Web App Manifest settings.
class PwaManifestSettings with Equatable {
  final PwaDisplayMode display;
  final PwaOrientation orientation;

  /// Relative to the site's root (`/<slug>/` on site.codelessly.com).
  /// Null means the root itself.
  final String? startUrl;

  /// Relative to the site's root. Null means the root itself.
  final String? scope;
  final List<String> categories;
  final List<PwaShortcut> shortcuts;

  const PwaManifestSettings({
    this.display = PwaDisplayMode.standalone,
    this.orientation = PwaOrientation.any,
    this.startUrl,
    this.scope,
    this.categories = const [],
    this.shortcuts = const [],
  });

  factory PwaManifestSettings.fromJson(Object? json) {
    final Map<String, dynamic> m = _map(json) ?? const {};
    return PwaManifestSettings(
      display: PwaDisplayMode.parse(m['display']) ?? PwaDisplayMode.standalone,
      orientation:
          PwaOrientation.parse(m['orientation']) ?? PwaOrientation.any,
      startUrl: _str(m['startUrl'] ?? m['start_url']),
      scope: _str(m['scope']),
      categories: _strList(m['categories']),
      shortcuts: [
        if (m['shortcuts'] is List)
          for (final Object? s in m['shortcuts'] as List)
            if (PwaShortcut.fromJson(s) case final PwaShortcut sc) sc,
      ],
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'display': display.value,
        'orientation': orientation.value,
        'startUrl': startUrl,
        'scope': scope,
        'categories': categories,
        'shortcuts': [for (final s in shortcuts) s.toJson()],
      });

  @override
  List<Object?> get props =>
      [display, orientation, startUrl, scope, categories, shortcuts];
}

/// The splash / loading screen shown while the app starts.
class SplashSettings with Equatable {
  /// Falls back to the identity's background color.
  final String? backgroundColor;
  final String? backgroundColorDark;

  /// Falls back to the app icon.
  final IdentityImage? logo;
  final IdentityImage? logoDark;

  const SplashSettings({
    this.backgroundColor,
    this.backgroundColorDark,
    this.logo,
    this.logoDark,
  });

  factory SplashSettings.fromJson(Object? json) {
    final Map<String, dynamic> m = _map(json) ?? const {};
    return SplashSettings(
      backgroundColor: normalizeHexColor(m['backgroundColor'] ?? m['color']),
      backgroundColorDark:
          normalizeHexColor(m['backgroundColorDark'] ?? m['colorDark']),
      logo: IdentityImage.fromJson(m['logo'] ?? m['image']),
      logoDark: IdentityImage.fromJson(m['logoDark'] ?? m['imageDark']),
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'backgroundColor': backgroundColor,
        'backgroundColorDark': backgroundColorDark,
        'logo': logo?.toJson(),
        'logoDark': logoDark?.toJson(),
      });

  @override
  List<Object?> get props =>
      [backgroundColor, backgroundColorDark, logo, logoDark];
}

/// Settings for the project exported as a native mobile app.
class MobileIdentity with Equatable {
  /// The name under the icon (CFBundleDisplayName / android:label). Falls
  /// back to the short name, then the name.
  final String? displayName;

  /// Android adaptive icon foreground (transparent, art in the inner 66%).
  /// Falls back to the app icon source.
  final IdentityImage? adaptiveIconForeground;

  /// Android adaptive icon background color. Falls back to the icon
  /// background color.
  final String? adaptiveIconBackgroundColor;

  /// An optional background image instead of the color.
  final IdentityImage? adaptiveIconBackground;
  final StatusBarStyle statusBarStyle;

  /// Launch screen; falls back to the identity's [SplashSettings].
  final SplashSettings? launchScreen;

  const MobileIdentity({
    this.displayName,
    this.adaptiveIconForeground,
    this.adaptiveIconBackgroundColor,
    this.adaptiveIconBackground,
    this.statusBarStyle = StatusBarStyle.auto,
    this.launchScreen,
  });

  factory MobileIdentity.fromJson(Object? json) {
    final Map<String, dynamic> m = _map(json) ?? const {};
    return MobileIdentity(
      displayName: _str(m['displayName'] ?? m['bundleDisplayName']),
      adaptiveIconForeground: IdentityImage.fromJson(
        m['adaptiveIconForeground'],
      ),
      adaptiveIconBackgroundColor:
          normalizeHexColor(m['adaptiveIconBackgroundColor']),
      adaptiveIconBackground:
          IdentityImage.fromJson(m['adaptiveIconBackground']),
      statusBarStyle:
          StatusBarStyle.parse(m['statusBarStyle']) ?? StatusBarStyle.auto,
      launchScreen: m['launchScreen'] == null
          ? null
          : SplashSettings.fromJson(m['launchScreen']),
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'displayName': displayName,
        'adaptiveIconForeground': adaptiveIconForeground?.toJson(),
        'adaptiveIconBackgroundColor': adaptiveIconBackgroundColor,
        'adaptiveIconBackground': adaptiveIconBackground?.toJson(),
        'statusBarStyle': statusBarStyle.name,
        'launchScreen': launchScreen?.toJson(),
      });

  @override
  List<Object?> get props => [
        displayName,
        adaptiveIconForeground,
        adaptiveIconBackgroundColor,
        adaptiveIconBackground,
        statusBarStyle,
        launchScreen,
      ];
}

/// One page's (or screen's) title and description override.
///
/// Keyed in [AppIdentity.pages] by the Editor page id, or by a canvas /
/// layout id for one screen.
class PageIdentity with Equatable {
  /// The page's own name (filled in at publish), used as `${page.title}`
  /// when [title] is empty.
  final String? name;

  /// Overrides the page title (`${page.title}` in the template).
  final String? title;

  /// Overrides the meta description.
  final String? description;

  /// The page's URL path below the site root, like `about` (filled in at
  /// publish), so the server can title deep links.
  final String? path;

  /// Overrides the social card image.
  final IdentityImage? socialImage;

  const PageIdentity({
    this.name,
    this.title,
    this.description,
    this.path,
    this.socialImage,
  });

  factory PageIdentity.fromJson(Object? json) {
    final Map<String, dynamic> m = _map(json) ?? const {};
    return PageIdentity(
      name: _str(m['name']),
      title: _str(m['title']),
      description: _str(m['description']),
      path: _str(m['path']),
      socialImage: IdentityImage.fromJson(m['socialImage'] ?? m['ogImage']),
    );
  }

  Map<String, dynamic> toJson() => _clean({
        'name': name,
        'title': title,
        'description': description,
        'path': path,
        'socialImage': socialImage?.toJson(),
      });

  bool get isEmpty =>
      name == null &&
      title == null &&
      description == null &&
      path == null &&
      socialImage == null;

  @override
  List<Object?> get props => [name, title, description, path, socialImage];
}

/// A generated file (favicon, icon, splash, social image).
class IdentityAssetSpec {
  /// The key in [AppIdentity.assets], also the base of the stored file name.
  final String key;
  final int width;
  final int height;

  /// png or ico.
  final String format;

  /// What it's generated from.
  final IdentityAssetSource source;

  /// For icons: the fraction of each side kept free (maskable safe zone).
  final bool maskable;

  const IdentityAssetSpec(
    this.key,
    this.width,
    this.height, {
    this.format = 'png',
    this.source = IdentityAssetSource.icon,
    this.maskable = false,
  });

  String get mimeType => format == 'ico' ? 'image/x-icon' : 'image/png';

  @override
  String toString() => '$key ${width}x$height $format';
}

/// The source image a generated asset is drawn from.
enum IdentityAssetSource {
  /// The favicon source, else the app icon.
  favicon,

  /// The favicon dark-mode source.
  faviconDark,

  /// The 1024px app icon (or the apple-touch-icon source for iOS).
  icon,

  /// The apple-touch-icon source, else the app icon.
  appleIcon,

  /// The splash logo, else the app icon, on the splash background.
  splash,

  /// The social image, else the icon on the background color.
  social,
}

/// Every asset the pipeline generates.
abstract final class IdentityAssets {
  static const IdentityAssetSpec faviconIco = IdentityAssetSpec(
    'favicon.ico',
    48,
    48,
    format: 'ico',
    source: IdentityAssetSource.favicon,
  );
  static const IdentityAssetSpec favicon16 = IdentityAssetSpec(
    'favicon-16.png',
    16,
    16,
    source: IdentityAssetSource.favicon,
  );
  static const IdentityAssetSpec favicon32 = IdentityAssetSpec(
    'favicon-32.png',
    32,
    32,
    source: IdentityAssetSource.favicon,
  );
  static const IdentityAssetSpec faviconDark32 = IdentityAssetSpec(
    'favicon-dark-32.png',
    32,
    32,
    source: IdentityAssetSource.faviconDark,
  );
  static const IdentityAssetSpec appleTouchIcon = IdentityAssetSpec(
    'apple-touch-icon.png',
    180,
    180,
    source: IdentityAssetSource.appleIcon,
  );
  static const IdentityAssetSpec icon192 =
      IdentityAssetSpec('icon-192.png', 192, 192);
  static const IdentityAssetSpec icon512 =
      IdentityAssetSpec('icon-512.png', 512, 512);
  static const IdentityAssetSpec maskable192 =
      IdentityAssetSpec('maskable-192.png', 192, 192, maskable: true);
  static const IdentityAssetSpec maskable512 =
      IdentityAssetSpec('maskable-512.png', 512, 512, maskable: true);
  static const IdentityAssetSpec social = IdentityAssetSpec(
    'og.png',
    1200,
    630,
    source: IdentityAssetSource.social,
  );

  /// The ICO's frames.
  static const List<int> icoSizes = [16, 32, 48];

  /// Apple startup images (portrait, device pixels) for the common iPhones
  /// and iPads, with the CSS size and pixel ratio for the media query.
  static const List<AppleSplashSize> appleSplashSizes = [
    AppleSplashSize(1320, 2868, 440, 956, 3), // iPhone 16 Pro Max
    AppleSplashSize(1206, 2622, 402, 874, 3), // iPhone 16 Pro
    AppleSplashSize(1290, 2796, 430, 932, 3), // 15/14 Pro Max, 15 Plus
    AppleSplashSize(1179, 2556, 393, 852, 3), // 15, 15 Pro, 14 Pro
    AppleSplashSize(1284, 2778, 428, 926, 3), // 13/12 Pro Max, 14 Plus
    AppleSplashSize(1170, 2532, 390, 844, 3), // 14, 13, 12
    AppleSplashSize(1125, 2436, 375, 812, 3), // X, XS, 11 Pro, 13 mini
    AppleSplashSize(1242, 2688, 414, 896, 3), // XS Max, 11 Pro Max
    AppleSplashSize(828, 1792, 414, 896, 2), // XR, 11
    AppleSplashSize(750, 1334, 375, 667, 2), // SE, 8
    AppleSplashSize(2048, 2732, 1024, 1366, 2), // iPad Pro 12.9"
    AppleSplashSize(1668, 2388, 834, 1194, 2), // iPad Pro 11"
    AppleSplashSize(1640, 2360, 820, 1180, 2), // iPad Air
    AppleSplashSize(1536, 2048, 768, 1024, 2), // iPad mini / 9.7"
  ];

  /// The splash specs, keyed `splash-<w>x<h>.png`.
  static List<IdentityAssetSpec> get splash => [
        for (final AppleSplashSize s in appleSplashSizes)
          IdentityAssetSpec(
            s.key,
            s.width,
            s.height,
            source: IdentityAssetSource.splash,
          ),
      ];

  /// Every generated asset, in generation order.
  static List<IdentityAssetSpec> get all => [
        faviconIco,
        favicon16,
        favicon32,
        faviconDark32,
        appleTouchIcon,
        icon192,
        icon512,
        maskable192,
        maskable512,
        social,
        ...splash,
      ];

  static IdentityAssetSpec? byKey(String key) {
    for (final IdentityAssetSpec s in all) {
      if (s.key == key) return s;
    }
    return null;
  }
}

/// One Apple startup image size.
class AppleSplashSize {
  final int width;
  final int height;
  final int cssWidth;
  final int cssHeight;
  final int ratio;

  const AppleSplashSize(
    this.width,
    this.height,
    this.cssWidth,
    this.cssHeight,
    this.ratio,
  );

  String get key => 'splash-${width}x$height.png';

  /// The `media` of its `<link rel="apple-touch-startup-image">`.
  String get media => '(device-width: ${cssWidth}px) and '
      '(device-height: ${cssHeight}px) and '
      '(-webkit-device-pixel-ratio: $ratio) and (orientation: portrait)';
}

/// How serious a checklist item is.
enum IdentityIssueLevel { error, warning, info }

/// A checklist item from [AppIdentity.checklist].
class IdentityIssue with Equatable {
  /// Stable id, like `missing-description`.
  final String code;
  final IdentityIssueLevel level;
  final String message;

  /// The JSON path of the field to fix, like `description`.
  final String? field;

  const IdentityIssue(this.code, this.level, this.message, {this.field});

  Map<String, dynamic> toJson() => _clean({
        'code': code,
        'level': level.name,
        'message': message,
        'field': field,
      });

  @override
  List<Object?> get props => [code, level, message, field];

  @override
  String toString() => '${level.name}: $message';
}

/// A project's identity as a web app and as a mobile app.
class AppIdentity with Equatable {
  /// The app's full name (manifest `name`, og:site_name, `${app.name}`).
  final String? name;

  /// The name under a home-screen icon (manifest `short_name`). Falls back
  /// to [name].
  final String? shortName;

  /// The page title template. `${page.title}` and `${app.name}` are
  /// replaced; a part around an empty value is dropped (so the home page,
  /// which has no page title, is titled just the app name).
  final String titleTemplate;

  /// The meta description.
  final String? description;
  final List<String> keywords;

  /// The canonical URL of the site root, like `https://example.com/`.
  final String? canonicalUrl;

  /// BCP 47 language, like `en` or `fr-CA`.
  final String language;
  final IdentityTextDirection textDirection;

  /// Whether search engines may index / follow the site.
  final bool robotsIndex;
  final bool robotsFollow;

  /// The browser UI color in light and dark mode.
  final String? themeColor;
  final String? themeColorDark;

  /// The page / manifest background color.
  final String? backgroundColor;

  /// Favicon sources. SVG is passed through; PNG and ICO are resized.
  /// Falls back to [iconSource].
  final IdentityImage? favicon;
  final IdentityImage? faviconDark;

  /// The app icon source: a 1024px square.
  final IdentityImage? iconSource;

  /// The maskable safe-zone padding: the fraction of each side left around
  /// the icon in maskable / adaptive icons (0.1 = the art fills the middle
  /// 80%, the W3C safe zone).
  final double iconPadding;

  /// The color behind the icon in maskable icons, the apple-touch-icon and
  /// the social fallback. Falls back to [backgroundColor].
  final String? iconBackgroundColor;

  /// A separate apple-touch-icon source (should be opaque).
  final IdentityImage? appleTouchIcon;

  final SocialCard social;
  final PwaManifestSettings manifest;
  final SplashSettings splash;
  final MobileIdentity mobile;

  /// Per-page overrides, keyed by page id (or canvas / layout id).
  final Map<String, PageIdentity> pages;

  /// The generated files: [IdentityAssetSpec.key] -> public URL.
  final Map<String, String> assets;

  /// The hash of the inputs [assets] were generated from; when it differs
  /// from [assetInputsHash] the assets are stale.
  final String? assetsHash;

  const AppIdentity({
    this.name,
    this.shortName,
    this.titleTemplate = kDefaultTitleTemplate,
    this.description,
    this.keywords = const [],
    this.canonicalUrl,
    this.language = 'en',
    this.textDirection = IdentityTextDirection.ltr,
    this.robotsIndex = true,
    this.robotsFollow = true,
    this.themeColor,
    this.themeColorDark,
    this.backgroundColor,
    this.favicon,
    this.faviconDark,
    this.iconSource,
    this.iconPadding = 0.1,
    this.iconBackgroundColor,
    this.appleTouchIcon,
    this.social = const SocialCard(),
    this.manifest = const PwaManifestSettings(),
    this.splash = const SplashSettings(),
    this.mobile = const MobileIdentity(),
    this.pages = const {},
    this.assets = const {},
    this.assetsHash,
  });

  /// Reads an identity, migrating older shapes:
  /// - `title` -> [name] when there is no `name`;
  /// - `og` / `openGraph` -> [social]; flat `ogTitle`, `ogDescription`,
  ///   `ogImage`, `twitterCard` -> [social];
  /// - `robots: "noindex, nofollow"` -> [robotsIndex] / [robotsFollow];
  /// - `icon` / `appIcon` -> [iconSource]; image URLs as plain strings;
  /// - colors as ARGB ints or `0xAARRGGBB` -> `#RRGGBB`;
  /// - `keywords` as a comma-separated string.
  factory AppIdentity.fromJson(Map json) {
    final Map<String, dynamic> m = json.map((k, v) => MapEntry('$k', v));

    // Social: a nested map, or legacy flat og* keys.
    final Map<String, dynamic> social = {
      ...?_map(m['openGraph']),
      ...?_map(m['og']),
      ...?_map(m['social']),
    };
    if (m['ogTitle'] != null) social['title'] ??= m['ogTitle'];
    if (m['ogDescription'] != null) {
      social['description'] ??= m['ogDescription'];
    }
    if (m['ogImage'] != null) social['image'] ??= m['ogImage'];
    if (m['twitterCard'] != null) social['cardType'] ??= m['twitterCard'];

    bool robotsIndex = m['robotsIndex'] is bool ? m['robotsIndex'] : true;
    bool robotsFollow = m['robotsFollow'] is bool ? m['robotsFollow'] : true;
    if (m['robots'] is String) {
      final String r = (m['robots'] as String).toLowerCase();
      if (r.contains('noindex')) robotsIndex = false;
      if (r.contains('nofollow')) robotsFollow = false;
    }

    final double padding = _double(m['iconPadding']) ?? 0.1;

    return AppIdentity(
      name: _str(m['name']) ?? _str(m['appName']) ?? _str(m['title']),
      shortName: _str(m['shortName'] ?? m['short_name']),
      titleTemplate: _str(m['titleTemplate']) ?? kDefaultTitleTemplate,
      description: _str(m['description']),
      keywords: _strList(m['keywords']),
      canonicalUrl: _str(m['canonicalUrl'] ?? m['canonical']),
      language: _str(m['language'] ?? m['lang']) ?? 'en',
      textDirection: IdentityTextDirection.parse(m['textDirection'] ?? m['dir']) ??
          IdentityTextDirection.ltr,
      robotsIndex: robotsIndex,
      robotsFollow: robotsFollow,
      themeColor: normalizeHexColor(m['themeColor']),
      themeColorDark: normalizeHexColor(m['themeColorDark']),
      backgroundColor: normalizeHexColor(m['backgroundColor']),
      favicon: IdentityImage.fromJson(m['favicon']),
      faviconDark: IdentityImage.fromJson(m['faviconDark']),
      iconSource:
          IdentityImage.fromJson(m['iconSource'] ?? m['appIcon'] ?? m['icon']),
      iconPadding: padding.clamp(0.0, 0.4),
      iconBackgroundColor: normalizeHexColor(m['iconBackgroundColor']),
      appleTouchIcon: IdentityImage.fromJson(m['appleTouchIcon']),
      social: SocialCard.fromJson(social),
      manifest: PwaManifestSettings.fromJson(m['manifest']),
      splash: SplashSettings.fromJson(m['splash']),
      mobile: MobileIdentity.fromJson(m['mobile']),
      pages: {
        for (final MapEntry<String, dynamic> e
            in (_map(m['pages']) ?? const <String, dynamic>{}).entries)
          if (PageIdentity.fromJson(e.value) case final PageIdentity p
              when !p.isEmpty)
            e.key: p,
      },
      assets: {
        for (final MapEntry<String, dynamic> e
            in (_map(m['assets']) ?? const <String, dynamic>{}).entries)
          if (_str(e.value) case final String url) e.key: url,
      },
      assetsHash: _str(m['assetsHash']),
    );
  }

  /// Reads an identity from anything (null or not a map: null).
  static AppIdentity? maybeFromJson(Object? json) =>
      json is Map ? AppIdentity.fromJson(json) : null;

  Map<String, dynamic> toJson() => _clean({
        'version': kAppIdentitySchemaVersion,
        'name': name,
        'shortName': shortName,
        'titleTemplate':
            titleTemplate == kDefaultTitleTemplate ? null : titleTemplate,
        'description': description,
        'keywords': keywords,
        'canonicalUrl': canonicalUrl,
        'language': language,
        'textDirection': textDirection.name,
        'robotsIndex': robotsIndex,
        'robotsFollow': robotsFollow,
        'themeColor': themeColor,
        'themeColorDark': themeColorDark,
        'backgroundColor': backgroundColor,
        'favicon': favicon?.toJson(),
        'faviconDark': faviconDark?.toJson(),
        'iconSource': iconSource?.toJson(),
        'iconPadding': iconPadding,
        'iconBackgroundColor': iconBackgroundColor,
        'appleTouchIcon': appleTouchIcon?.toJson(),
        'social': social.toJson(),
        'manifest': manifest.toJson(),
        'splash': splash.toJson(),
        'mobile': mobile.toJson(),
        'pages': {
          for (final e in pages.entries) e.key: e.value.toJson(),
        },
        'assets': assets,
        'assetsHash': assetsHash,
      });

  /// A copy with [patch] deep-merged into the JSON: maps merge, other values
  /// replace, and a null value removes the key. This is how the Editor and
  /// the MCP set fields (`{"social": {"title": "Hi"}}`).
  AppIdentity merge(Map<String, dynamic> patch) =>
      AppIdentity.fromJson(deepMergeJson(toJson(), patch));

  /// [name], else [fallback].
  String appName([String fallback = '']) => name ?? fallback;

  /// The page title for [pageId] (null for the site root / home).
  ///
  /// [pageName] is used when the page has no override or stored name.
  String titleFor({String? pageId, String? pageName, String fallbackName = ''}) {
    final PageIdentity? page = pageId == null ? null : pages[pageId];
    return renderTitle(
      titleTemplate,
      appName: appName(fallbackName),
      pageTitle: page?.title ?? page?.name ?? pageName,
    );
  }

  /// The description for [pageId]: its override, else [description].
  String? descriptionFor(String? pageId) =>
      (pageId == null ? null : pages[pageId]?.description) ?? description;

  /// The effective short name.
  String get effectiveShortName => shortName ?? name ?? '';

  /// The color behind maskable icons.
  String get effectiveIconBackground =>
      iconBackgroundColor ?? backgroundColor ?? '#FFFFFF';

  /// The effective splash background.
  String get effectiveSplashBackground =>
      splash.backgroundColor ?? backgroundColor ?? '#FFFFFF';

  /// The mobile display name.
  String get effectiveDisplayName =>
      mobile.displayName ?? shortName ?? name ?? '';

  /// A fingerprint of everything the generated [assets] depend on.
  String get assetInputsHash {
    final String input = [
      favicon?.url,
      faviconDark?.url,
      iconSource?.url,
      appleTouchIcon?.url,
      iconPadding.toStringAsFixed(3),
      effectiveIconBackground,
      effectiveSplashBackground,
      splash.logo?.url,
      social.image?.url,
      backgroundColor,
      themeColor,
    ].join('|');
    // FNV-1a 32-bit: stable across platforms, no crypto dependency.
    int hash = 0x811c9dc5;
    for (final int unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Whether [assets] need generating again.
  bool get assetsStale =>
      (iconSource != null || favicon != null || social.image != null) &&
      assetsHash != assetInputsHash;

  /// The pre-publish checklist: what's missing or likely wrong.
  List<IdentityIssue> checklist() {
    final List<IdentityIssue> issues = [];
    void add(String code, IdentityIssueLevel level, String message,
            [String? field]) =>
        issues.add(IdentityIssue(code, level, message, field: field));

    if (name == null) {
      add('missing-name', IdentityIssueLevel.warning,
          'Add an app name: tabs, home screens and link cards show it.', 'name');
    }
    if (description == null) {
      add('missing-description', IdentityIssueLevel.warning,
          'Add a description: search results and link previews show it.',
          'description');
    } else if (description!.length > 160) {
      add('long-description', IdentityIssueLevel.info,
          'The description is ${description!.length} characters; search '
              'results cut it at about 160.',
          'description');
    }
    if (iconSource == null && favicon == null) {
      add('missing-icon', IdentityIssueLevel.warning,
          'Upload an app icon: the tab, the home screen and the install '
              'prompt use it.',
          'iconSource');
    } else if (iconSource != null) {
      final IdentityImage icon = iconSource!;
      if (!icon.isSvg && icon.width != null && icon.height != null) {
        if (!icon.isSquare) {
          add('icon-not-square', IdentityIssueLevel.error,
              'The app icon is ${icon.width}×${icon.height}; it must be square.',
              'iconSource');
        } else if (icon.width! < 512) {
          add('icon-too-small', IdentityIssueLevel.warning,
              'The app icon is ${icon.width}px; use 1024px so large icons '
                  'stay sharp.',
              'iconSource');
        }
      }
      final IdentityImage apple = appleTouchIcon ?? icon;
      if (apple.hasAlpha == true && iconBackgroundColor == null &&
          backgroundColor == null) {
        add('ios-icon-transparent', IdentityIssueLevel.warning,
            'The icon has transparent pixels; iOS shows them black. Set an '
                'icon background color or upload an opaque apple-touch-icon.',
            'iconBackgroundColor');
      }
    }
    if (social.image == null) {
      add('missing-social-image', IdentityIssueLevel.warning,
          'Add a social image (1200×630): link previews in Slack, X and '
              'iMessage show it. The icon is used until then.',
          'social.image');
    } else if (social.image!.width != null && social.image!.height != null) {
      final double ratio = social.image!.width! / social.image!.height!;
      if ((ratio - 1200 / 630).abs() > 0.1) {
        add('social-image-aspect', IdentityIssueLevel.info,
            'The social image is ${social.image!.width}×'
                '${social.image!.height}; 1200×630 (1.91:1) fits every card.',
            'social.image');
      }
    }
    if (themeColor == null) {
      add('missing-theme-color', IdentityIssueLevel.info,
          'Set a theme color for the browser bar and the installed app.',
          'themeColor');
    }
    if (assetsStale) {
      add('assets-stale', IdentityIssueLevel.warning,
          'The icons were not generated from the current sources; generate '
              'them again before publishing.',
          'assets');
    }
    if (canonicalUrl != null) {
      final Uri? uri = Uri.tryParse(canonicalUrl!);
      if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
        add('bad-canonical', IdentityIssueLevel.error,
            'The canonical URL must be an absolute http(s) URL.',
            'canonicalUrl');
      }
    }
    if (!robotsIndex) {
      add('noindex', IdentityIssueLevel.info,
          'Search engines are asked not to index this site.', 'robotsIndex');
    }
    return issues;
  }

  /// A Web App Manifest for the site served at [baseUrl] (like
  /// `/wireless/`), with icons from [assets].
  Map<String, dynamic> toWebManifest({
    String baseUrl = '/',
    String fallbackName = 'App',
  }) {
    String rel(String? path) {
      if (path == null || path.isEmpty) return baseUrl;
      if (Uri.tryParse(path)?.hasScheme == true) return path;
      final String trimmed = path.startsWith('/') ? path.substring(1) : path;
      return '$baseUrl$trimmed';
    }

    String? asset(String key) => assets[key];
    return _clean({
      'id': baseUrl,
      'name': name ?? fallbackName,
      'short_name': shortName ?? name ?? fallbackName,
      'description': description,
      'lang': language,
      'dir': textDirection.name,
      'start_url': rel(manifest.startUrl),
      'scope': rel(manifest.scope),
      'display': manifest.display.value,
      'orientation': manifest.orientation.value,
      'background_color': backgroundColor ?? splash.backgroundColor,
      'theme_color': themeColor,
      'categories': manifest.categories,
      'prefer_related_applications': false,
      'icons': [
        if (asset('icon-192.png') case final String u)
          {'src': u, 'sizes': '192x192', 'type': 'image/png', 'purpose': 'any'},
        if (asset('icon-512.png') case final String u)
          {'src': u, 'sizes': '512x512', 'type': 'image/png', 'purpose': 'any'},
        if (asset('maskable-192.png') case final String u)
          {
            'src': u,
            'sizes': '192x192',
            'type': 'image/png',
            'purpose': 'maskable',
          },
        if (asset('maskable-512.png') case final String u)
          {
            'src': u,
            'sizes': '512x512',
            'type': 'image/png',
            'purpose': 'maskable',
          },
      ],
      'shortcuts': [
        for (final PwaShortcut s in manifest.shortcuts)
          _clean({
            'name': s.name,
            'short_name': s.shortName,
            'description': s.description,
            'url': rel(s.url),
            'icons': [
              if (asset('icon-192.png') case final String u)
                {'src': u, 'sizes': '192x192', 'type': 'image/png'},
            ],
          }),
      ],
    });
  }

  @override
  List<Object?> get props => [
        name,
        shortName,
        titleTemplate,
        description,
        keywords,
        canonicalUrl,
        language,
        textDirection,
        robotsIndex,
        robotsFollow,
        themeColor,
        themeColorDark,
        backgroundColor,
        favicon,
        faviconDark,
        iconSource,
        iconPadding,
        iconBackgroundColor,
        appleTouchIcon,
        social,
        manifest,
        splash,
        mobile,
        pages,
        assets,
        assetsHash,
      ];
}

/// Fills a title template. `${page.title}`, `${app.name}` (and the
/// shorthands `${page}`, `${app}`) are replaced. When a value is empty, the
/// separator next to it goes too, so `${page.title} · ${app.name}` with no
/// page title is just the app name.
String renderTitle(
  String template, {
  required String appName,
  String? pageTitle,
}) {
  final Map<String, String> values = {
    'page.title': (pageTitle ?? '').trim(),
    'page': (pageTitle ?? '').trim(),
    'app.name': appName.trim(),
    'app': appName.trim(),
  };
  // Split into variables and literal text, drop the literal separators that
  // touch an empty variable.
  final RegExp re = RegExp(r'\$\{\s*([a-zA-Z.]+)\s*\}');
  final List<({bool isVar, String text})> parts = [];
  int index = 0;
  for (final RegExpMatch match in re.allMatches(template)) {
    if (match.start > index) {
      parts.add((isVar: false, text: template.substring(index, match.start)));
    }
    parts.add((isVar: true, text: values[match[1]!] ?? ''));
    index = match.end;
  }
  if (index < template.length) {
    parts.add((isVar: false, text: template.substring(index)));
  }
  // A literal touching an empty variable is a separator for nothing: drop it.
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (!part.isVar) {
      final bool prevEmpty =
          i > 0 && parts[i - 1].isVar && parts[i - 1].text.isEmpty;
      final bool nextEmpty = i + 1 < parts.length &&
          parts[i + 1].isVar &&
          parts[i + 1].text.isEmpty;
      if (prevEmpty || nextEmpty) continue;
    }
    out.write(part.text);
  }
  final String result = out.toString().trim();
  return result.isEmpty ? appName.trim() : result;
}

/// Deep-merges [patch] into [base]: maps merge, a null removes, anything
/// else replaces. Neither argument is changed.
Map<String, dynamic> deepMergeJson(
  Map<String, dynamic> base,
  Map<String, dynamic> patch,
) {
  final Map<String, dynamic> out = {...base};
  for (final MapEntry<String, dynamic> e in patch.entries) {
    if (e.value == null) {
      out.remove(e.key);
    } else if (e.value is Map && out[e.key] is Map) {
      out[e.key] = deepMergeJson(
        (out[e.key] as Map).map((k, v) => MapEntry('$k', v)),
        (e.value as Map).map((k, v) => MapEntry('$k', v)),
      );
    } else {
      out[e.key] = e.value;
    }
  }
  return out;
}
