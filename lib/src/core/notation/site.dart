/// A site of notation files, held in memory: the layout the command-line
/// `expand <site folder>` reads (CodelesslySDK tool/notation/notation_site.dart),
/// with no file system.
///
///     pages/home.txt          one page a file; its file name is its screen
///     components/Card.txt     one word a file: `define Card …` with its
///                             lines under it, or a `component Card` head
///     site/site.json          the pages' order, the theme, the variables
///
/// [NotationSiteFiles] reads a map of path → text in that layout
/// (`site.json` at the root is read too). [NotationSiteExpander] expands
/// its files by the tool's rules: the site's variables are read by name and
/// declared on no page; a bare `go budgets` names the page `budgets`; the
/// site's theme gives the looks a line takes when it says none; a word the
/// site defines (`components/*.txt` of `define` blocks) holds on every page
/// and in every component; a component written in the notation is callable
/// by name, each expanded after those it calls; and an overlay two pages
/// write with one id and draw differently is made each page's own
/// (site_overlays.dart).
///
/// What the tool has that this does not: components that exist only as
/// JSON, the dictionaries a manifest names by folder (give the vocabulary
/// in [NotationSiteSettings.vocabulary]) and a design system a manifest
/// names by folder (give it to the expander).
library;

import 'dart:convert';

import '../catalog.dart';
import '../design_system.dart';
import '../document.dart';
import '../json.dart';
import '../variables.dart';
import '../sections.dart';
import '../theme.dart';
import 'brackets.dart';
import 'define.dart';
import 'notation.dart';
import 'site_overlays.dart';
import 'vocabulary.dart';

export 'site_overlays.dart' show OverlayScoping, ScopedComponent, ScopedPage, isOverlayEvent, pageScopedId, scopeOverlays, unscopeOverlays, writtenOverlayId;

/// A component written in the notation: its type (the name on its
/// `component` line), its file and its text.
typedef NotationComponentSource = ({String type, String path, String text});

/// Something of a site's file that is not read, or must be said: the file,
/// its line when it has one, and what to write.
typedef NotationSiteProblem = ({String path, int? line, String message});

/// The path of a site's manifest as a project keeps it (at its root).
const String notationSiteManifestPath = 'site.json';

/// [path] with `/` between its parts and none before the first.
String notationSitePath(String path) => path.replaceAll(r'\', '/').replaceFirst(RegExp(r'^(\./|/)+'), '');

String _stem(String ref) {
  final name = ref.replaceAll(r'\', '/').split('/').last;
  final dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

/// The type a component's notation text declares (`component Name "…"`, its
/// first line that is not blank or a comment); null when it is not one.
String? notationComponentType(String text) {
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('//') || line.startsWith('#')) continue;
    return RegExp(r'^component\s+([A-Za-z_][A-Za-z0-9_]*)').firstMatch(line)?[1];
  }
  return null;
}

/// The names of [types] that [text] calls: a line written with one as its
/// word (`Card#c "…"`, `Card.compact`), or `type=Card`.
Set<String> notationCallsIn(String text, Set<String> types) {
  if (types.isEmpty) return const {};
  final out = <String>{};
  for (final m in RegExp(r'(?:^[ \t]*|\btype=)([A-Z][A-Za-z0-9_]*)', multiLine: true).allMatches(text)) {
    if (types.contains(m[1])) out.add(m[1]!);
  }
  return out;
}

/// Whether [text] is definitions: its first line that is not blank or a
/// `//` comment starts with `define ` or `primitive `.
bool notationIsDefinitions(String text) {
  final first = const LineSplitter().convert(text).map((l) => l.trim()).where((l) => l.isNotEmpty && !l.startsWith('//')).firstOrNull;
  return first != null && RegExp(r'^(define|primitive)\s+[A-Za-z_]').hasMatch(first);
}

/// A site's files as the expander reads them.
final class NotationSiteFiles {
  /// Reads [files] (path → text). The manifest is `site/site.json`, else
  /// `site.json`; the pages are `pages/*.txt` (else `site/pages/*.txt`), the
  /// components `components/*.txt` (and `site/components/*.txt`). Any other
  /// file is not read. [catalog] says which words the notation already has
  /// (a component of such a name is said).
  NotationSiteFiles(Map<String, String> files, {Catalog? catalog})
      : files = {for (final e in files.entries) notationSitePath(e.key): e.value},
        _catalog = catalog ?? Catalog.current {
    final text = this.files['site/${SiteManifest.fileName}'] ?? this.files[SiteManifest.fileName];
    if (text != null && text.trim().isNotEmpty) {
      try {
        manifest = readMap(jsonDecode(text)) ?? const {};
      } on FormatException catch (e) {
        problems.add((path: manifestPath, line: null, message: '$manifestPath is not JSON (${e.message}): its variables, theme and pages were not read'));
      }
    }
    _readComponents();
    _checkRings();
  }

  /// Says each word of the site's definitions that reaches itself through
  /// words other files define (`A` calls `B`, whose file calls `A`): one file
  /// read alone cannot know, and the pages read it as no word at all. The
  /// message is the one a file gets for a word that calls itself, with every
  /// word on the way: `A uses itself (A > B > A): it is not read.`
  void _checkRings() {
    final text = definitionText;
    if (text == null) return;
    for (final p in readPageDefinitions(text).problems) {
      final m = RegExp(r'^page:(\d+): (\S+ uses itself \(.*\): it is not read\.)$').firstMatch(p.message);
      final at = m == null ? null : definitionLine(int.parse(m[1]!));
      if (m == null || at == null) continue;
      // A word that calls itself in its own file is said there already.
      if (problems.any((q) => q.path == at.path && q.line == at.line && q.message.contains(' uses itself ('))) continue;
      problems.add((path: at.path, line: at.line, message: m[2]!));
    }
  }

  /// The files, by path with `/` between its parts.
  final Map<String, String> files;
  final Catalog _catalog;

  /// The manifest as read (empty when there is none, or it is not JSON).
  Json manifest = const {};

  /// The manifest's path among [files].
  String get manifestPath => files.containsKey('site/${SiteManifest.fileName}') ? 'site/${SiteManifest.fileName}' : SiteManifest.fileName;

  /// What is not read or must be said: a manifest that is not JSON, a
  /// component file that is neither a component nor definitions, a second
  /// file of one type, what a file of definitions has wrong, a word that
  /// reaches itself through the words of other files.
  final List<NotationSiteProblem> problems = [];

  /// The site's variables by name, as [NotationOptions.projectVariables]
  /// takes them.
  late final Map<String, Json> variables = {
    for (final v in Variable.declarationsFromJson(manifest['variables'])) v.name: {'type': v.type.name, ...v.toJson()},
  };

  /// The site's own theme (its manifest's).
  late final ThemeTokens ownTheme = ThemeTokens.fromJson(manifest['theme']);

  List<String> _in(String folder) => [
        for (final p in files.keys)
          if (p.startsWith('$folder/') && !p.substring(folder.length + 1).contains('/') && p.endsWith('.txt')) p,
      ]..sort();

  /// The pages written in the notation, by path, in file order.
  late final List<String> pageSources = () {
    final own = _in('pages');
    return own.isNotEmpty ? own : _in('site/pages');
  }();

  /// The ids of the pages the manifest lists (each reference's file stem).
  late final List<String> listedScreens = [for (final p in SiteManifest.pageRefs(manifest['pages'])) _stem(p)];

  /// The ids of the site's pages: the ones the manifest lists, then the
  /// ones written that it does not.
  late final List<String> screens = {...listedScreens, for (final p in pageSources) _stem(p)}.toList();

  /// The pages written in the notation in the order shown: the manifest's
  /// order, then the others in file order.
  late final List<String> orderedPageSources = () {
    final byName = {for (final p in pageSources) _stem(p): p};
    return [
      for (final s in listedScreens) ?byName.remove(s),
      ...byName.values,
    ];
  }();

  /// The components written in the notation with a `component` head, by
  /// type.
  final Map<String, NotationComponentSource> sources = {};

  /// The `components/*.txt` that are `define` (or `primitive`) blocks, by
  /// path: each word they define is the site's, read by every page and
  /// component.
  final Map<String, String> definitionFiles = {};

  /// [definitionFiles] as one text, for [parseNotation]'s `definitions`;
  /// null when there are none.
  late final String? definitionText = definitionFiles.isEmpty ? null : definitionFiles.values.join('\n');

  /// The words [definitionFiles] define, by the file that defines each.
  late final Map<String, String> definedWords = {
    for (final e in definitionFiles.entries)
      for (final w in readPageDefinitions(e.value).words.entries)
        if (notationBuiltInWord(w.key, catalog: _catalog, primitive: w.value.every((d) => d.primitive)) == null) w.key: e.key,
  };

  void _readComponents() {
    for (final path in [..._in('components'), ..._in('site/components')]) {
      final text = files[path]!;
      final type = notationComponentType(text);
      if (type == null) {
        if (notationIsDefinitions(text)) {
          definitionFiles[path] = text;
          _checkDefinitions(path, text);
        } else if (text.trim().isNotEmpty) {
          problems.add((path: path, line: 1, message: _notAComponent(path, text)));
        }
        continue;
      }
      if (sources[type] case final first?) {
        problems.add((
          path: path,
          line: 1,
          message: '$path writes component $type, which ${first.path} already writes: this file is not read. Give one of them another name.',
        ));
        continue;
      }
      sources[type] = (type: type, path: path, text: text);
      if (notationBuiltInWord(type, catalog: _catalog) case final what?) {
        problems.add((path: path, line: 1, message: '${notationBuiltInDefinition(type, what, kind: 'component')} To call this component, write `$type type=$type`.'));
      }
    }
  }

  void _checkDefinitions(String path, String text) {
    final read = readPageDefinitions(text);
    for (final p in read.problems) {
      problems.add((path: path, line: p.line, message: p.message));
    }
    final lines = const LineSplitter().convert(text);
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (l.trim().isEmpty || l.startsWith(' ') || l.startsWith('\t') || l.startsWith('//')) continue;
      if (RegExp(r'^(define|primitive)\s').hasMatch(l)) continue;
      problems.add((
        path: path,
        line: i + 1,
        message: '`${l.length > 50 ? '${l.substring(0, 47)}...' : l}` is in no definition, so it is not read: '
            'a file of definitions holds `define` (or `primitive`) lines, each with its lines indented under it.',
      ));
    }
    for (final e in read.words.entries) {
      if (notationBuiltInWord(e.key, catalog: _catalog, primitive: e.value.every((d) => d.primitive)) case final what?) {
        for (final d in e.value) {
          problems.add((path: path, line: d.line, message: notationBuiltInDefinition(e.key, what, kind: d.primitive ? 'primitive' : 'definition')));
        }
      }
    }
    for (final i in notationBracketIssues(text)) {
      problems.add((path: path, line: i.line, message: i.message));
    }
  }

  static String _notAComponent(String path, String text) {
    final first = const LineSplitter().convert(text).map((l) => l.trim()).where((l) => l.isNotEmpty && !l.startsWith('//')).firstOrNull ?? '';
    return '$path is not read: its first line is `${first.length > 60 ? '${first.substring(0, 57)}...' : first}`, neither `component <Name>` nor `define <Name> …`. '
        'Write `define ${_stem(path)}` (its strings, parameters and events as a line would use it) above its lines indented under it.';
  }

  /// Where a line of the site's definitions is written: [line] of
  /// [definitionText] as its file and the line in it; null past the end.
  ({String path, int line})? definitionLine(int line) {
    var at = line;
    for (final e in definitionFiles.entries) {
      final n = const LineSplitter().convert(e.value).length + (e.value.endsWith('\n') ? 1 : 0);
      if (at <= n) return (path: e.key, line: at);
      at -= n;
    }
    return null;
  }

  /// The notation components in the order they can be expanded: each after
  /// the components it calls.
  List<NotationComponentSource> ordered() {
    final calls = {for (final s in sources.values) s.type: notationCallsIn(s.text, sources.keys.toSet()..remove(s.type))};
    final out = <NotationComponentSource>[];
    final state = <String, int>{};
    void visit(String t) {
      if (state[t] != null) return;
      state[t] = 1;
      for (final c in calls[t]!.toList()..sort()) {
        visit(c);
      }
      state[t] = 2;
      out.add(sources[t]!);
    }

    for (final t in sources.keys.toList()..sort()) {
      visit(t);
    }
    return out;
  }
}

/// How [NotationSiteExpander] expands each file: the tool's flags.
typedef NotationSiteSettings = ({
  double width,
  bool reflow,
  bool named,
  bool nearestColors,
  bool open,
  NotationVocabulary vocabulary,
});

/// The settings `expand <site folder>` has with no flag: pages 1440 wide.
const NotationSiteSettings notationSiteDefaults = (
  width: 1440,
  reflow: true,
  named: false,
  nearestColors: false,
  open: false,
  vocabulary: NotationVocabulary.core,
);

/// A site expanded whole ([NotationSiteExpander.expandAll]).
typedef ExpandedNotationSite = ({
  List<ScopedComponent> components,
  Map<String, NotationResult> componentResults,
  List<ScopedPage> pages,
  List<NotationResult> results,
  OverlayScoping scoping,
});

/// Expands a site's files with what the site and a design system give them
/// (see the library's comment), as the tool's `NotationExpander` does.
final class NotationSiteExpander {
  NotationSiteExpander(this.site, {this.designSystem, this.settings = notationSiteDefaults, this.themeOverDesignSystem = false, Catalog? catalog})
      : base = catalog ?? Catalog.current;

  /// Whether the site's theme is laid over the design system's tokens (a
  /// site with no theme of its own then has the design system's looks).
  /// False, as the tool has it: a site's theme is its own alone.
  final bool themeOverDesignSystem;

  final NotationSiteFiles site;

  /// The design system the site is drawn in; null: none.
  final DesignSystem? designSystem;
  final NotationSiteSettings settings;

  /// The catalog under the design system's and the site's components.
  final Catalog base;

  final Map<String, LayoutDocument> _fromSource = {};

  /// The results of the components expanded so far, by type.
  final Map<String, NotationResult> componentResults = {};

  /// The site's theme: its own, over the design system's tokens with
  /// [themeOverDesignSystem].
  ThemeTokens get theme => themeOverDesignSystem ? (designSystem?.themeUnder(site.ownTheme) ?? site.ownTheme) : site.ownTheme;

  Map<String, LayoutDocument> _libraryFor(String? self) {
    final out = <String, LayoutDocument>{...?designSystem?.components.definitions};
    final skip = <String>{?self};
    if (self != null) {
      var grew = true;
      while (grew) {
        grew = false;
        for (final src in site.sources.values) {
          if (!skip.contains(src.type) && notationCallsIn(src.text, skip).isNotEmpty) grew = skip.add(src.type) || grew;
        }
      }
    }
    for (final src in site.ordered()) {
      if (skip.contains(src.type)) {
        out.remove(src.type);
        continue;
      }
      final doc = _fromSource[src.type] ?? _expandComponent(src, out);
      if (doc != null) out[src.type] = doc;
    }
    if (self != null) out.remove(self);
    return out;
  }

  LayoutDocument? _expandComponent(NotationComponentSource src, Map<String, LayoutDocument> library) {
    final result = _expand(src.text, library, screen: src.type);
    componentResults[src.type] = result;
    try {
      final d = LayoutDocument.fromJson(result.document);
      if (!d.isComponent) return null;
      _fromSource[src.type] = d;
      return d;
    } on Object {
      return null;
    }
  }

  DesignSystem? _merged(Map<String, LayoutDocument> library) {
    final ds = designSystem;
    final theme = this.theme;
    if (ds == null && library.isEmpty && theme.isEmpty) return null;
    return DesignSystem(
      manifest: DesignSystemManifest.fromJson({
        ...?ds?.manifest.toJson(),
        'id': ds?.id ?? 'site',
        'theme': theme.toJson(),
        'components': [for (final t in library.keys) DesignSystem.componentRef(t)],
      }),
      components: ComponentLibrary(library),
    );
  }

  /// The design system a page of the site is shown with: the one given,
  /// with the site's theme over its own and the site's components among
  /// its own. Null when there is nothing of either.
  late final DesignSystem? pageDesignSystem = _merged(_libraryFor(null));

  NotationResult _expand(String text, Map<String, LayoutDocument> library, {required String screen}) {
    final ds = designSystem;
    final theme = this.theme;
    final merged = _merged(library);
    final catalog = merged?.catalogOver(base) ?? base;
    final variables = site.variables;
    final named = settings.named || !theme.isEmpty;
    final options = (merged == null || theme.isEmpty
            ? NotationOptions(
                screen: screen,
                width: settings.width,
                reflow: settings.reflow,
                projectVariables: variables,
                components: merged == null ? const {} : NotationOptions.fromDesignSystem(merged).components,
                componentScreenActions: merged == null ? const {} : NotationOptions.fromDesignSystem(merged).componentScreenActions,
                componentScreenOverlays: merged == null ? const {} : NotationOptions.fromDesignSystem(merged).componentScreenOverlays,
              )
            : NotationOptions.fromDesignSystem(merged,
                screen: screen, width: settings.width, named: named, nearestColors: settings.nearestColors, reflow: settings.reflow, projectVariables: variables, roles: ds == null))
        .open(openVocabulary: settings.open, vocabulary: settings.vocabulary)
        .withScreens(site.screens)
        .withOwnComponents(site.sources.keys);
    return Catalog.run(catalog, () => parseNotation(text, catalog: catalog, options: options, definitions: site.definitionText));
  }

  /// Expands [text] (the file at [path]) as the canvas [screen]: a page (its
  /// one leading `### Name` line is left out), or a component.
  NotationResult expand(String text, {required String screen}) {
    final self = notationComponentType(text);
    return _expand(self == null ? _withoutScreenHeading(text) : text, _libraryFor(self), screen: screen);
  }

  /// Expands the page at [path] (one of [NotationSiteFiles.pageSources]),
  /// its file name the canvas id.
  NotationResult expandPage(String path) => expand(site.files[path]!, screen: _stem(path));

  /// The whole site expanded: its notation components, then its pages, with
  /// each overlay two pages write with one id and draw differently made the
  /// page's own.
  ExpandedNotationSite expandAll() {
    Json copy(Json d) => jsonDecode(jsonEncode(d)) as Json;
    final components = <ScopedComponent>[];
    final results = <String, NotationResult>{};
    for (final src in site.ordered()) {
      final r = expand(src.text, screen: 'screen');
      results[src.type] = r;
      components.add((type: src.type, path: src.path, document: copy(r.document)));
    }
    final pages = <ScopedPage>[];
    final pageResults = <NotationResult>[];
    for (final page in site.pageSources) {
      final r = expandPage(page);
      pageResults.add(r);
      pages.add((name: _stem(page), path: page, document: copy(r.document)));
    }
    final scoping = scopeOverlays(pages, components);
    return (components: components, componentResults: results, pages: pages, results: pageResults, scoping: scoping);
  }
}

final _screenHeading = RegExp(r'^###\s+\S');

/// [text] without its screen heading when it has exactly one and it is its
/// first line that is not blank or a comment. The line is left blank, so
/// every other line keeps its number.
String _withoutScreenHeading(String text) {
  final lines = text.split('\n');
  final at = [
    for (var i = 0; i < lines.length; i++)
      if (_screenHeading.hasMatch(lines[i])) i,
  ];
  if (at.length != 1) return text;
  for (var i = 0; i < at.single; i++) {
    final t = lines[i].trim();
    if (t.isNotEmpty && !t.startsWith('//')) return text;
  }
  lines[at.single] = lines[at.single].endsWith('\r') ? '\r' : '';
  return lines.join('\n');
}
