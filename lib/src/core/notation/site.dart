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

/// The path of an app's state file as a project keeps it (at its root,
/// beside `pages/` and `components/`): the state every page and component
/// shares, as `state` lines ([readNotationAppState]).
const String notationAppStatePath = 'app.txt';

/// The key of a manifest that says what `expand` wrote in it: `{"all":
/// true}` for a manifest written whole (the site has none of its own), or
/// `{"variables": [names]}` for the variables written from app.txt into the
/// site's own manifest. What it names is not the site's source.
const String notationBuiltKey = 'expand';

/// [manifest] (a site.json as read) as the site's source: without what
/// `expand` wrote in it ([notationBuiltKey]). Null when all of it was (the
/// site has no manifest of its own).
Json? notationSourceManifest(Json manifest) {
  final built = readMap(manifest[notationBuiltKey]);
  if (built == null) return manifest;
  if (built['all'] == true) return null;
  final names = readStrings(built['variables']).toSet();
  final out = {...manifest}..remove(notationBuiltKey);
  final variables = manifest['variables'];
  if (variables is List) {
    out['variables'] = [
      for (final v in variables)
        if (!(v is Map && names.contains(v['name']))) v,
    ];
  } else if (variables is Map) {
    out['variables'] = <String, Object?>{
      for (final e in variables.entries)
        if (!names.contains(e.key)) '${e.key}': e.value,
    };
  }
  return out;
}

/// The manifest `expand` writes for a site whose shared state is in
/// app.txt, which a render reads its variables from: [source] (the site's
/// own manifest; null: none, and the manifest lists [pages], the page ids in
/// order) with [appVariables] (app.txt's, as
/// [NotationSiteFiles.appVariables]) among its variables, marked as written
/// ([notationBuiltKey]). Null when there is nothing to write: a manifest of
/// the site's own and no state in app.txt.
Json? notationBuiltManifest({required Json? source, required List<String> pages, required Map<String, Json> appVariables}) {
  Json record(Json v) => {
        for (final k in const ['type', 'value', 'formula', 'parameters', 'options', 'persist'])
          if (v.containsKey(k)) k: v[k],
        if (!v.containsKey('value') && !v.containsKey('formula')) 'value': null,
      };
  final declared = {
    for (final e in appVariables.entries)
      if (!e.value.containsKey(notationInlineFormulaKey)) e.key: record(e.value),
  };
  if (source == null) {
    return {
      'schema': 3,
      'pages': [for (final p in pages) '$p.json'],
      if (declared.isNotEmpty) 'variables': declared,
      notationBuiltKey: {'all': true},
    };
  }
  if (declared.isEmpty) return null;
  final own = source['variables'];
  return {
    ...source,
    'variables': own is List
        ? [
            ...own,
            for (final e in declared.entries) {'name': e.key, ...e.value},
          ]
        : {...?readMap(own), ...declared},
    notationBuiltKey: {'variables': declared.keys.toList()},
  };
}

/// The page ids [names] in the order a site with no listed pages shows
/// them: `home` first, then the others by name.
List<String> notationPageOrder(Iterable<String> names) {
  final rest = names.toSet().toList()..sort();
  return [if (rest.remove('home')) 'home', ...rest];
}

/// The variables a site's pages read: the manifest's ([manifestVariables],
/// its `variables` as written) and app.txt's ([app], null: no such file),
/// as [NotationOptions.projectVariables] takes them. A name both declare is
/// app.txt's, and said in [say] at its line of app.txt.
Map<String, Json> notationSiteVariables(Object? manifestVariables, NotationAppState? app, {void Function(int line, String message)? say}) {
  final out = <String, Json>{
    for (final v in Variable.declarationsFromJson(manifestVariables)) v.name: {'type': v.type.name, ...v.toJson()},
  };
  if (app == null) return out;
  for (final e in app.variables.entries) {
    if (out.containsKey(e.key)) {
      say?.call(
        app.lines[e.key] ?? 1,
        '${e.key} is declared here and in site.json\'s variables: one name is one value. This one is used; take "${e.key}" out of site.json.',
      );
    }
    if (e.value.containsKey(notationInlineFormulaKey)) {
      out[e.key] = e.value;
    } else if (Variable.fromJson({...e.value, 'name': e.key}) case final v?) {
      out[e.key] = {'type': v.type.name, ...v.toJson()};
    }
  }
  return out;
}

/// The names [document] (a page or a component as expanded) reads, sets or
/// binds in its expressions that [known] does not hold and the document
/// does not declare with a line of its own ([text] is its notation: a name
/// with a `state` line there is declared): what the app's state file still
/// has to declare for the page to show it. In the order first read.
///
/// It reads the expressions as text, so it is a list to go by, not a
/// check: a loop's item, a formula's own parameter, a field after a dot, a
/// function and the runtime's names are left out.
///
/// With [others] (the texts of the files the page may call: its components,
/// the site's definitions), only a name the app's own writing has is listed:
/// one [text] or one of them mentions. A name the expansion made itself (the
/// pane a phone shows of a list beside its detail, a component's own state
/// kept for each call, what a row passes to its menu) is in no file, and
/// nothing the writer can declare. A name a `state` line of [text] gives is
/// declared whatever the document made of it (a worked-out value is written
/// out where it is read, and is no variable of the document).
///
/// [drawing], when given, takes the names read only inside a drawing (a
/// `customPaint`'s lines) in place of the list answered: what is read there
/// by a wrong name is most often a `repeat`'s index, which is `index`.
List<String> notationUndeclaredNames(
  Json document, {
  required String text,
  Set<String> known = const {},
  Iterable<String>? others,
  List<String>? drawing,
}) {
  Set<String> statedIn(String text) => {
        for (final m in RegExp(r'^[ \t]*(?:state|let|derived|const|var|project)\s+([A-Za-z_][A-Za-z0-9_]*)', multiLine: true).allMatches(text)) m[1]!,
        for (final m in RegExp(r'^([a-z_][A-Za-z0-9_]*)\s*=(?!=)', multiLine: true).allMatches(text)) m[1]!,
        for (final m in RegExp(r'^[ \t]*param\s+([A-Za-z_][A-Za-z0-9_]*)', multiLine: true).allMatches(text)) m[1]!,
      };
  final stated = statedIn(text);
  // What a component states is its own, kept by the expansion.
  final statedElsewhere = {for (final o in others ?? const <String>[]) ...statedIn(o)};
  // The names each and its index give the lines under them.
  final loops = <String>{
    for (final m in RegExp(r'^[ \t]*each\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*,\s*([A-Za-z_][A-Za-z0-9_]*))?\s+in\b', multiLine: true).allMatches(text)) ...[m[1]!, ?m[2]],
  };
  final declared = <String>{};
  final made = <String>{};
  for (final scope in (readMap(document['variables']) ?? const {}).values) {
    for (final v in readList(scope) ?? const []) {
      final name = readString(readMap(v)?['name']);
      if (name == null) continue;
      // One the document declares that no line states was made for a name
      // the text sets or binds: it is still to be declared.
      (stated.contains(name) ? declared : made).add(name);
    }
  }
  final mentioned = <String, bool>{};
  // (With no [others] given, what the page's own text does not mention may
  // be a component's, and is listed as before.)
  bool written(String name) =>
      mentioned[name] ??= _mentions(text, name) || (others == null ? !made.contains(name) : others.any((o) => _mentions(o, name)));
  final out = <String>{};
  // The pressed row of a list with a menu (`menu=rowMenu` under `each m in
  // …`): the reader keeps it in a variable of the each's name, set to the
  // row's item before the menu opens, so the menu's lines read `m`. That
  // variable is the reader's own: the text declared the name with its each.
  final eaches = <String>{
    for (final m in RegExp(r'^[ \t]*each\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*,\s*([A-Za-z_][A-Za-z0-9_]*))?\s+in\s', multiLine: true).allMatches(text)) ...[m[1]!, ?m[2]],
  };
  final rows = <String>{};
  void pressed(Object? json) {
    if (json is List) {
      json.forEach(pressed);
    } else if (json is Map) {
      if (json['type'] == 'setVariable' && eaches.contains(json['variable']) && RegExp(r'^\$\{= (parent\.)*item\}$').hasMatch('${json['value']}')) {
        rows.add(json['variable'] as String);
      }
      // The names a drawing's repeat gives its item and its position.
      if (json['op'] == 'repeat') {
        rows.addAll([for (final k in const ['as', 'indexAs']) if (json[k] case final String name) name]);
      }
      json.values.forEach(pressed);
    }
  }

  pressed(document['nodes']);
  final drawn = <String>{};
  var inDrawing = false;
  bool skip(String name) =>
      known.contains(name) ||
      declared.contains(name) ||
      rows.contains(name) ||
      stated.contains(name) ||
      _notNames.contains(name) ||
      !RegExp(r'^[a-z_]').hasMatch(name) ||
      // In no file of the app: the expansion's own.
      !written(name) ||
      // Made by the expansion under the name of a loop's item (what a row
      // hands the menu it opens): the loop declares it.
      (made.contains(name) && loops.contains(name)) ||
      (made.contains(name) && statedElsewhere.contains(name) && !_mentions(text, name));
  void add(String name) => (inDrawing ? drawn : out).add(name);
  void read(String expression) {
    final code = expression.replaceAll(RegExp('"(?:[^"\\\\]|\\\\.)*"|\'(?:[^\'\\\\]|\\\\.)*\''), '""');
    final own = <String>{
      for (final m in RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*=>').allMatches(code)) m[1]!,
      for (final m in RegExp(r'\(([A-Za-z_][A-Za-z0-9_,\s]*)\)\s*=>').allMatches(code)) ...m[1]!.split(',').map((p) => p.trim()),
    };
    for (final m in RegExp(r'(?<![A-Za-z0-9_.$#"])([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_])').allMatches(code)) {
      final name = m[1]!;
      final after = code.substring(m.end).trimLeft();
      if (after.startsWith('(') || own.contains(name) || skip(name)) continue;
      // A record's key (`{merchant: draft}`) is a name, not a value.
      final before = code.substring(0, m.start).trimRight();
      if ((before.endsWith('{') || before.endsWith(',')) && RegExp(r'^:(?!:)').hasMatch(after) && !before.endsWith('?')) continue;
      add(name);
    }
  }

  void walk(Object? json) {
    if (json is String) {
      var at = 0;
      while (true) {
        final start = json.indexOf(r'${', at);
        if (start < 0) break;
        var depth = 0, end = -1;
        for (var i = start + 1; i < json.length; i++) {
          if (json[i] == '{') depth++;
          if (json[i] == '}' && --depth == 0) {
            end = i;
            break;
          }
        }
        if (end < 0) break;
        final inner = json.substring(start + 2, end).trim();
        read(inner.startsWith('=') ? inner.substring(1) : inner);
        at = end + 1;
      }
    } else if (json is List) {
      json.forEach(walk);
    } else if (json is Map) {
      if (json['type'] == 'setVariable' && json['variable'] is String) {
        final name = (json['variable'] as String).split('.').first.split('[').first;
        if (!skip(name)) add(name);
      }
      for (final e in json.entries) {
        // A drawing's lines (a customPaint's painter and foregroundPainter).
        final paint = !inDrawing && (e.key == 'painter' || e.key == 'foregroundPainter') && e.value is List;
        if (paint) inDrawing = true;
        walk(e.value);
        if (paint) inDrawing = false;
      }
    }
  }

  walk(document['nodes']);
  for (final name in made) {
    if (!skip(name) && _mentions(text, name)) out.add(name);
  }
  drawn.removeAll(out);
  if (drawing != null) {
    drawing.addAll(drawn);
  } else {
    out.addAll(drawn);
  }
  return out.toList();
}

bool _mentions(String text, String name) => RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(name)}(?![A-Za-z0-9_])').hasMatch(text);

/// What an expression names that is no variable: its words, and the names
/// the runtime gives every expression or a node gives what is in it.
const Set<String> _notNames = {
  'true', 'false', 'null', 'in', 'and', 'or', 'not', 'is', 'if', 'else', //
  'data', 'route', 'storage', 'screen', 'device', 'theme', 'item', 'index', 'parent', 'result', 'loop', 'auth', 'drag', 'perf', 'track', 'dismiss',
  'pan', 'transform', 'flip', 'tilt', 'view', 'sticky', 'script', 'speech', 'pageOffset', 'form', 'params', 'props', 'event', 'value', 'navMenu',
};

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
  ///
  /// The app's shared state is `app.txt` beside the pages (`site/app.txt`
  /// beside `site/pages/`), read with [readNotationAppState];
  /// [appStatePartial] says more of it is coming (a stream). The manifest is
  /// read as the site's source ([notationSourceManifest]): a site needs none.
  ///
  /// What of the manifest's `theme` is not read (a key a theme does not
  /// have, a color name nothing defines: [themeProblems]) is among
  /// [problems], at its line of the manifest. [themeColors]: the color names
  /// of the design system the site is shown under, which its theme may name.
  NotationSiteFiles(Map<String, String> files, {Catalog? catalog, bool appStatePartial = false, Iterable<String> themeColors = const []})
      : files = {for (final e in files.entries) notationSitePath(e.key): e.value},
        _catalog = catalog ?? Catalog.current {
    final text = this.files['site/${SiteManifest.fileName}'] ?? this.files[SiteManifest.fileName];
    if (text != null && text.trim().isNotEmpty) {
      try {
        final read = readMap(jsonDecode(text)) ?? const <String, Object?>{};
        final source = notationSourceManifest(read);
        hasManifest = source != null;
        manifest = source ?? const {};
        for (final p in themeProblems(manifest['theme'], colors: themeColors)) {
          problems.add((path: manifestPath, line: themeKeyLine(text, p.path), message: '$manifestPath ${['theme', ...p.path].join('.')}: ${p.message}'));
        }
      } on FormatException catch (e) {
        hasManifest = true;
        problems.add((path: manifestPath, line: null, message: '$manifestPath is not JSON (${e.message}): its variables, theme and pages were not read'));
      }
    }
    final appPath = appStatePath;
    final ofApp = <NotationSiteProblem>[];
    if (appPath != null) {
      final app = appState = readNotationAppState(this.files[appPath]!, catalog: _catalog, partial: appStatePartial);
      for (final i in app.issues) {
        ofApp.add((path: appPath, line: i.line, message: i.message));
      }
    }
    variables = notationSiteVariables(manifest['variables'], appState, say: (line, message) => ofApp.add((path: appPath!, line: line, message: message)));
    problems.addAll(ofApp..sort((a, b) => (a.line ?? 0) - (b.line ?? 0)));
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
  ///
  /// The manifest's `variables` and app.txt's state ([notationSiteVariables]):
  /// a name both declare is app.txt's, and a problem at its line there. A
  /// formula with no type of app.txt is `{"inline": formula}`.
  late final Map<String, Json> variables;

  /// Whether the site has a manifest of its own (one `expand` wrote whole is
  /// not: [notationSourceManifest]).
  bool hasManifest = false;

  /// The path of the app's state file among [files]: `app.txt` beside the
  /// pages read, else whichever there is; null when the site has none.
  String? get appStatePath {
    final beside = pageSources.isNotEmpty && pageSources.first.startsWith('site/') ? 'site/$notationAppStatePath' : notationAppStatePath;
    for (final p in [beside, notationAppStatePath, 'site/$notationAppStatePath']) {
      if (files.containsKey(p)) return p;
    }
    return null;
  }

  /// What the app's state file declares; null when the site has none.
  NotationAppState? appState;

  /// app.txt's state by name, as [variables] has it; empty with no such file.
  Map<String, Json> get appVariables => {
        for (final name in appState?.variables.keys ?? const <String>[])
          if (variables[name] case final v?) name: v,
      };

  /// The variables every page shares as a view's scope declares them
  /// (`Variable.declarationsFromJson` reads it): the manifest's and
  /// app.txt's, without app.txt's formulas with no type (those are written
  /// out on each page that reads them).
  List<Json> get sharedDeclarations => [
        for (final e in variables.entries)
          if (!e.value.containsKey(notationInlineFormulaKey)) {...e.value, 'name': e.key},
      ];

  /// The manifest a render reads this site's variables from, when it is not
  /// the site's own as written ([notationBuiltManifest]); null: nothing to
  /// write.
  Json? get builtManifest => notationBuiltManifest(source: hasManifest ? manifest : null, pages: [for (final p in orderedPageSources) _stem(p)], appVariables: appVariables);

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
  /// ones written that it does not ([notationPageOrder]: `home` first, then
  /// by name).
  late final List<String> screens = {...listedScreens, ...notationPageOrder(pageSources.map(_stem))}.toList();

  /// The pages written in the notation in the order shown: the manifest's
  /// order, then the others with `home` first and the rest by name (the
  /// whole order of a site with no manifest, or one that lists no pages).
  late final List<String> orderedPageSources = () {
    final byName = {for (final p in pageSources) _stem(p): p};
    return [
      for (final s in listedScreens) ?byName.remove(s),
      for (final s in notationPageOrder(byName.keys.toList())) byName[s]!,
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
      // (Said of this file at its line: the "page:1: " a definition's line is
      // named by in a text read alone says nothing here.)
      problems.add((path: path, line: p.line, message: p.message.replaceFirst(RegExp(r'^page:\d+: '), '')));
    }
    final lines = const LineSplitter().convert(text);
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (l.trim().isEmpty || l.startsWith(' ') || l.startsWith('\t') || l.startsWith('//')) continue;
      if (RegExp(r'^(define|primitive)\s').hasMatch(l)) continue;
      // A line at the margin with an id (`Sheet#player "Now playing"`): what
      // a word opens is one of the word's lines, so it is written under the
      // word's `define`, as far in as its other lines.
      final word = RegExp(r'^(define|primitive)\s+([A-Z][A-Za-z0-9]*)').allMatches(lines.take(i).join('\n')).lastOrNull?[2];
      final part = RegExp(r'^[A-Z][A-Za-z0-9]*(?:\.[A-Za-z0-9_]+)*#[A-Za-z_][A-Za-z0-9_]*').stringMatch(l);
      problems.add((
        path: path,
        line: i + 1,
        message: '`${l.length > 50 ? '${l.substring(0, 47)}...' : l}` is in no definition, so it is not read: '
            'a file of definitions holds `define` (or `primitive`) lines, each with its lines indented under it.'
            '${part == null || word == null ? '' : ' For $word to write $part (a dialog or a sheet it opens), indent this line and the lines under it by two spaces, so that they are among the lines of define $word; or write them in the page\x27s file, after the page.'}',
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
