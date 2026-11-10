// A published app's identity as a web app and a mobile app: its name, the
// title template its screens are titled with, its description, theme color
// and per-screen overrides. The rest (icons, social card, PWA manifest,
// splash, mobile settings, generated assets) is the editor's and the web
// host's, and rides along untouched in [AppIdentity.extra].
//
// The identity's JSON is shared with the web host (site.codelessly.com
// reads it server-side to fill each page's <head>), so it keeps its own
// format: colors are CSS hex (`#RRGGBB` / `#RRGGBBAA`), not the model's
// `#AARRGGBB`.
import 'package:meta/meta.dart';

import '../json.dart';

/// `${page.title} · ${app.name}`: the default title template.
const String kDefaultTitleTemplate = r'${page.title} · ${app.name}';

/// One page's (or screen's) title and description override, keyed in
/// [AppIdentity.pages] by an editor page id, or a canvas or layout id.
@immutable
final class PageIdentity {
  const PageIdentity({this.name, this.title, this.description, this.path, this.extra = const {}});

  /// The page's own name (filled in at publish): `${page.title}` when
  /// [title] is null.
  final String? name;

  /// `${page.title}` in the template.
  final String? title;
  final String? description;

  /// Its URL path below the site root (filled in at publish).
  final String? path;

  /// The rest (`socialImage`), kept.
  final Json extra;

  static const _keys = {'name', 'title', 'description', 'path'};

  static PageIdentity fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return PageIdentity(
      name: _str(m['name']),
      title: _str(m['title']),
      description: _str(m['description']),
      path: _str(m['path']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {'name': ?name, 'title': ?title, 'description': ?description, 'path': ?path, ...extra};

  @override
  bool operator ==(Object other) => other is PageIdentity && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A published app's identity (the publish model's `appIdentity`). JSON:
/// the identity's own (see the file comment), with every key this version
/// doesn't model kept in [extra].
@immutable
final class AppIdentity {
  const AppIdentity({
    this.name,
    this.shortName,
    this.titleTemplate = kDefaultTitleTemplate,
    this.description,
    this.themeColor,
    this.pages = const {},
    this.extra = const {},
  });

  static const AppIdentity none = AppIdentity();

  final String? name;
  final String? shortName;

  /// How a screen's title is made: `${page.title}`, `${app.name}` (and
  /// `${page}`, `${app}`) are filled in, see [renderTitle].
  final String titleTemplate;

  /// The meta description.
  final String? description;

  /// The browser and task switcher color, CSS hex (`#RRGGBB`, `#RRGGBBAA`).
  final String? themeColor;

  /// Title and description overrides, by editor page, canvas or layout id.
  final Map<String, PageIdentity> pages;

  /// The rest (icons, social card, manifest, splash, mobile, assets...).
  final Json extra;

  static const _keys = {'name', 'shortName', 'titleTemplate', 'description', 'themeColor', 'pages'};

  /// [name], else [fallback].
  String appName([String fallback = '']) => name ?? fallback;

  /// The override for the first of [keys] that has one.
  PageIdentity? pageOf(Iterable<String> keys) {
    for (final k in keys) {
      if (pages[k] case final PageIdentity p) return p;
    }
    return null;
  }

  static AppIdentity? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return AppIdentity(
      name: _str(m['name']),
      shortName: _str(m['shortName']),
      titleTemplate: _str(m['titleTemplate']) ?? kDefaultTitleTemplate,
      description: _str(m['description']),
      themeColor: _str(m['themeColor']),
      pages: {
        for (final e in (readMap(m['pages']) ?? const {}).entries) e.key: PageIdentity.fromJson(e.value),
      },
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
        'name': ?name,
        'shortName': ?shortName,
        if (titleTemplate != kDefaultTitleTemplate) 'titleTemplate': titleTemplate,
        'description': ?description,
        'themeColor': ?themeColor,
        if (pages.isNotEmpty) 'pages': {for (final e in pages.entries) e.key: e.value.toJson()},
        ...extra,
      };

  @override
  bool operator ==(Object other) => other is AppIdentity && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

String? _str(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;

/// Fills title [template]: `${page.title}`, `${app.name}` (and `${page}`,
/// `${app}`). The text touching an empty value goes too, so
/// `${page.title} · ${app.name}` with no page title is the app name alone.
String renderTitle(String template, {required String appName, String? pageTitle}) {
  final values = {
    'page.title': (pageTitle ?? '').trim(),
    'page': (pageTitle ?? '').trim(),
    'app.name': appName.trim(),
    'app': appName.trim(),
  };
  final re = RegExp(r'\$\{\s*([a-zA-Z.]+)\s*\}');
  final parts = <({bool isVar, String text})>[];
  var index = 0;
  for (final match in re.allMatches(template)) {
    if (match.start > index) parts.add((isVar: false, text: template.substring(index, match.start)));
    parts.add((isVar: true, text: values[match[1]!] ?? ''));
    index = match.end;
  }
  if (index < template.length) parts.add((isVar: false, text: template.substring(index)));
  final out = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (!part.isVar) {
      final prevEmpty = i > 0 && parts[i - 1].isVar && parts[i - 1].text.isEmpty;
      final nextEmpty = i + 1 < parts.length && parts[i + 1].isVar && parts[i + 1].text.isEmpty;
      if (prevEmpty || nextEmpty) continue;
    }
    out.write(part.text);
  }
  final result = out.toString().trim();
  return result.isEmpty ? appName.trim() : result;
}
