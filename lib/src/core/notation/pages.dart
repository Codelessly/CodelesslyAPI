/// The pages of one notation text: an app or a site of several screens is
/// written as one text, each screen starting at a `### Name` line (the
/// convention the prompt teaches: [notationPrompt] with `pages`).
///
/// [notationPages] splits such a text in memory. Each page's text is the
/// whole text with every line that is not the page's left blank, so a line
/// keeps its number: an issue of a page is at its line of the whole text.
/// What is written before the first `###` line, when it is no page (only
/// state, shortcuts, timers, definitions, comments and overlays), is the
/// app's: every page has those lines. A word defined anywhere
/// (`define Word …`) holds on every page ([NotationPages.definitions], given
/// to [parseNotation] as its `definitions`), and a state one page declares
/// that another uses without declaring it is that page's too.
///
/// A text with no `###` line is one page, its text unchanged.
library;

/// One page of a text ([notationPages]).
final class NotationPage {
  const NotationPage({required this.name, required this.id, required this.heading, required this.from, required this.to, required this.text});

  /// As its `### Name` line names it (`Cook mode`); the fallback name for a
  /// text, or lines before the first heading, with none.
  final String name;

  /// Its screen's id (`cook-mode`): the canvas it expands to
  /// ([NotationOptions.screen]) and what `go cook-mode` names
  /// ([NotationOptions.withScreens]). Unique in the text.
  final String id;

  /// The line (1-based) of its `### Name` line; null when it has none.
  final int? heading;

  /// Its own lines (1-based, inclusive), the heading not among them. [to] is
  /// below [from] for a page with no line yet.
  final int from, to;

  /// The whole text with every line that is not this page's blank: its own
  /// lines, the app's (before the first heading) and each state line of
  /// another page it uses without declaring it.
  final String text;

  /// Whether [line] (1-based) is the page's heading or one of its own lines.
  bool holds(int line) => line == heading || (line >= from && line <= to);

  @override
  String toString() => 'NotationPage($name #$id $from-$to)';
}

/// The pages of a text ([notationPages]).
final class NotationPages {
  const NotationPages({required this.source, required this.pages, required this.headed, required this.shared, required this.definitions});

  /// The text that was split.
  final String source;

  /// Its pages in the order written; never empty.
  final List<NotationPage> pages;

  /// Whether the text has a `### Name` line. False: it is one page, read as
  /// it is written.
  final bool headed;

  /// How many of the first lines are the app's (what is written before the
  /// first heading when it is no page): 0 when there are none.
  final int shared;

  /// The text with only its definitions (`define …` and `primitive …`
  /// blocks) left, each on its own lines: what every page is read with
  /// ([parseNotation]'s `definitions`). Null when the text is one page with
  /// no heading (its definitions are its own).
  final String? definitions;

  /// The ids of the pages, as [NotationOptions.withScreens] takes them.
  List<String> get ids => [for (final p in pages) p.id];

  /// The page [line] (1-based) is in; null for a line that is the app's.
  NotationPage? at(int line) {
    for (final p in pages) {
      if (p.holds(line)) return p;
    }
    return null;
  }

  /// The page called [name]: by its id, or its name in any case; null when
  /// none is.
  NotationPage? named(String name) {
    final want = name.trim().replaceFirst(RegExp(r'^#+\s*'), '').toLowerCase();
    for (final p in pages) {
      if (p.id == want || p.name.toLowerCase() == want) return p;
    }
    return null;
  }
}

final _pageHeading = RegExp(r'^###\s+(.+?)\s*$');
final _appStatement = RegExp(r'^(state|project|computed|key|every)\s');
final _appDefinition = RegExp(r'^(define|primitive)\s');
final _appOverlay = RegExp(r'^(Dialog|Modal|Sheet|BottomSheet|Drawer|Menu|Dropdown|Popover|Popup|Lightbox|ConfirmDialog)#');
final _declares = RegExp(r'^(?:state|project|computed)\s+@?([A-Za-z_][A-Za-z0-9_]*)\s*=');

/// The heading a line is (`### Name`): its name, or null.
String? notationPageHeading(String line) => _pageHeading.firstMatch(line.endsWith('\r') ? line.substring(0, line.length - 1) : line)?[1];

/// [text] as its pages: each `### Name` line starts one. See the library's
/// comment for what each page's text holds. A text without a heading is one
/// page called [fallback] with the id `screen`, its text as written.
NotationPages notationPages(String text, {String fallback = 'Page'}) {
  final lines = text.split('\n');
  String plain(int i) => lines[i].endsWith('\r') ? lines[i].substring(0, lines[i].length - 1) : lines[i];
  final headings = <int>[
    for (var i = 0; i < lines.length; i++)
      if (_pageHeading.hasMatch(plain(i))) i,
  ];
  if (headings.isEmpty) {
    return NotationPages(
      source: text,
      pages: [NotationPage(name: fallback, id: 'screen', heading: null, from: 1, to: lines.length, text: text)],
      headed: false,
      shared: 0,
      definitions: null,
    );
  }

  // The margin blocks: where each line that starts at the margin begins one,
  // and what kind it is.
  bool margin(int i) => plain(i).isNotEmpty && !plain(i).startsWith(' ') && !plain(i).startsWith('\t');
  bool idle(int i) => plain(i).trim().isEmpty || plain(i).trimLeft().startsWith('//');

  // Whether the lines before the first heading are the app's: no line of a
  // page among them.
  final first = headings.first;
  var appOnly = true, any = false;
  var inBlock = false;
  for (var i = 0; i < first && appOnly; i++) {
    if (idle(i)) continue;
    any = true;
    if (!margin(i)) {
      if (!inBlock) appOnly = false;
      continue;
    }
    final l = plain(i);
    // What closes a list written over several lines (`]`, `] saved`) is
    // its statement's last line.
    if (inBlock && RegExp(r'^[\])}]+(\s+saved)?\s*$').hasMatch(l)) continue;
    inBlock = _appStatement.hasMatch(l) || _appDefinition.hasMatch(l) || _appOverlay.hasMatch(l);
    if (!inBlock) appOnly = false;
  }
  final shared = appOnly ? first : 0;

  // The sections: the lines before the first heading when they are a page,
  // then one for each heading.
  final sections = <({String name, int? heading, int from, int to})>[
    if (!appOnly && any) (name: fallback, heading: null, from: 0, to: first - 1),
    for (var h = 0; h < headings.length; h++)
      (
        name: _pageHeading.firstMatch(plain(headings[h]))![1]!,
        heading: headings[h],
        from: headings[h] + 1,
        to: (h + 1 < headings.length ? headings[h + 1] : lines.length) - 1,
      ),
  ];

  final ids = <String>{};
  String slug(String name) {
    var s = name.toLowerCase().replaceAll(RegExp("['’]"), '').replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    if (s.isEmpty || !RegExp(r'^[a-z_]').hasMatch(s)) s = 's-$s';
    var id = s;
    for (var n = 2; !ids.add(id); n++) {
      id = '$s-$n';
    }
    return id;
  }

  // The state each section declares at the margin: its name, and the lines
  // of its declaration (the line and what is indented under it).
  final declared = <int, Map<String, List<int>>>{};
  for (var s = 0; s < sections.length; s++) {
    final own = declared[s] = <String, List<int>>{};
    for (var i = sections[s].from; i <= sections[s].to; i++) {
      if (!margin(i)) continue;
      final m = _declares.firstMatch(plain(i));
      if (m == null) continue;
      final at = <int>[i];
      for (var j = i + 1; j <= sections[s].to && !margin(j) && !idle(j); j++) {
        at.add(j);
      }
      own.putIfAbsent(m[1]!, () => at);
    }
  }

  // The definitions, wherever they are written.
  final defining = List<bool>.filled(lines.length, false);
  var inDefinition = false;
  for (var i = 0; i < lines.length; i++) {
    if (headings.contains(i)) {
      inDefinition = false;
      continue;
    }
    if (margin(i)) inDefinition = _appDefinition.hasMatch(plain(i));
    defining[i] = inDefinition && !idle(i);
  }

  String blank(int i) => lines[i].endsWith('\r') ? '\r' : '';
  String only(bool Function(int i) keep) => [for (var i = 0; i < lines.length; i++) keep(i) ? lines[i] : blank(i)].join('\n');

  final pages = <NotationPage>[];
  for (var s = 0; s < sections.length; s++) {
    final section = sections[s];
    final own = [for (var i = section.from; i <= section.to; i++) plain(i)].join('\n');
    // The state of another page this one uses without declaring it.
    final borrowed = <int>{};
    for (var o = 0; o < sections.length; o++) {
      if (o == s) continue;
      for (final e in declared[o]!.entries) {
        if (declared[s]!.containsKey(e.key)) continue;
        if (RegExp('(?<![A-Za-z0-9_.])${RegExp.escape(e.key)}(?![A-Za-z0-9_])').hasMatch(own)) borrowed.addAll(e.value);
      }
    }
    pages.add(NotationPage(
      name: section.name,
      id: slug(section.name),
      heading: section.heading == null ? null : section.heading! + 1,
      from: section.from + 1,
      to: section.to + 1,
      text: only((i) => i < shared || (i >= section.from && i <= section.to) || borrowed.contains(i)),
    ));
  }
  return NotationPages(source: text, pages: pages, headed: true, shared: shared, definitions: only((i) => defining[i]));
}
