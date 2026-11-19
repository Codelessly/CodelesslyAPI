// The page words of the compact notation: the frames of a desktop page.
//
// On a phone a UI is one card, and the card is the frame: it owns the width,
// the padding and how its blocks stack. On a desktop there are two frames a
// model would otherwise build from rows and boxes, and get the sizes wrong:
//
//   Page                      a website page: scrolls, its sections stack
//     Nav                     the bar across the top: ends apart
//     Section                 a full-width band; its content in a centered column
//     Footer                  the band that closes the page
//
//   App                       an app window: panes side by side, as tall as the window
//     Sidebar                 a fixed-width pane (navigation)
//     Main                    the pane that takes the room left, and scrolls
//       Footer                a bar at its foot, in view while the rest scrolls
//       Nav                   its top bar
//     Pane w=320              a further fixed-width pane (a list, details)
//
// Each is written out as the plain lines it stands for (a Column, a Row, a
// Text), before the notation reads them: the sizes, the content width and
// the scrolling are the frame's, and nothing else of the notation changes.
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;

part 'table_words.dart';
part 'page_words_at.dart';

/// A line to read in place of the one written: its indent and its text.
typedef PageLine = ({int indent, String text});

/// Rewrites page words into plain notation lines, a line at a time (the
/// notation is read as it streams).
final class PageWords {
  PageWords({
    this.contentWidth = 1120,
    this.narrowWidth = 720,
    this.sidebarWidth = 248,
    this.sidebarRail,
    this.sectionPad = 64,
    this.gutter = 24,
    this.band,
    this.siteFill,
    this.paneFill,
    this.sideFill,
    this.accentName,
    this.accent = '#FF2563EB',
    this.siteHeadline,
    this.selectedFill = '#FFE5E7EB',
    this.line = '#FFE5E7EB',
    this.textVariants = const {},
    this.isComponent = _none,
    this.declares = _none,
    this.isFrame = _none,
    this.frameEvents = _noEvents,
    this.roles = false,
    this.menu = false,
    this.sidebarMenu,
    this.surface = '#FFFFFFFF',
    this.themeRoles = false,
    this.overlaySurface,
    this.viewer,
    this.takesViewer = _none,
  });

  static bool _none(String _) => false;
  static List<String> _noEvents(String _) => const [];

  /// The widest a section's content gets, and a `narrow` section's.
  final double contentWidth, narrowWidth;
  final double sidebarWidth;

  /// A design system's rail width (`sizes.rail`): an app's sidebar written
  /// with no rule for other widths is a rail that wide at a tablet's, where
  /// the system's words fold to their icons. Null: as wide as written.
  final double? sidebarRail;

  /// A section's padding above and below, and a page's side gutter.
  final double sectionPad, gutter;

  /// A tinted section's fill, what a website page is drawn on, and the fill
  /// of an app's sidebar and top bar; null: none is written.
  final String? band, siteFill, paneFill;

  /// What an app's sidebar is drawn on (a theme's `colors.sidebar`); null: [paneFill].
  final String? sideFill;

  /// The accent as the theme names it (a selected item's ink); null: [accent].
  final String? accentName;

  /// Colors, as the notation takes them (`#AARRGGBB`).
  final String accent, selectedFill, line;

  /// The size of a website's headline (`Text.pageTitle`, `Text.heading1` in
  /// a Page's Section), its second and third levels in
  /// proportion; null where the theme gives its headline a display size of
  /// its own. A 30 px headline over a 1440 page read as a section's title
  /// (round 11: the web's were 48 to 150 px).
  final num? siteHeadline;

  /// The indent of the plain Section just written under a Page (no ground,
  /// no bleed), while nothing else has been written beside it.
  int? _plainSectionAt;

  /// The indent of the Main a slim bar was made for (its sidebar's button,
  /// where Main's first line is no bar), and whether that bar is not to be
  /// drawn after all: Main's own bar came later and took the button, or the
  /// writer made a button of their own ([ownMenuButton]: no drawer either).
  int? _slimBarIn;
  bool slimBarSuperseded = false, ownMenuButton = false;

  /// Whether the page's bar (its first `Nav`) was written.
  bool _pageBar = false;

  /// Whether the text is a website's (its top is a `Page`): its controls are
  /// a page's size ([NotationOptions.controlHeight] else 40).
  bool site = false;

  /// [siteHeadline]'s size for heading [level] (1 to 3), or null.
  num? _headlineSize(int level) => switch ((siteHeadline, level)) {
        (final num h, 1) => h,
        (final num h, 2) => (h * 0.6).roundToDouble(),
        (final num h, 3) => (h * 0.37).roundToDouble(),
        _ => null,
      };

  /// Whether a line is in a website's Section (not in its bar or its foot).
  bool get _inSiteSection =>
      _open.isNotEmpty && _open.first.frame == 'Page' && _open.any((l) => l.frame == 'Section') && !_open.any((l) => l.frame == 'Nav' || l.frame == 'Foot');

  /// The names `Text.<name>` takes: a heading picks the first it finds.
  final Set<String> textVariants;

  /// Whether a design system has a component of this name (its `Sidebar`
  /// with `items:` is that component, not a pane).
  final bool Function(String name) isComponent;

  /// Whether the catalog declares a node type of this name, also one a word
  /// of the notation shadows (`Badge "3" type=Badge` is the component).
  final bool Function(String name) declares;

  /// Whether a design system's component of this name takes children (its
  /// `Dialog` frames a dialog's content).
  final bool Function(String name) isFrame;

  /// The events of a design system's frame of this name, in order (its
  /// `Dialog`'s onClose: what its close button and Escape send).
  final List<String> Function(String name) frameEvents;

  /// Whether a frame's line says which frame it is, after its type
  /// (`Row~nav`, `Column~section`, `Row~app`, `Column~sidebar`, `Column~main`,
  /// `Column~pane`): what lays a page out at other widths reads it, and
  /// takes it off before the line is read.
  final bool roles;

  /// Whether a website's `Nav` gets a menu for a phone: a button at its
  /// end, shown where its links are not, that opens them in a column under
  /// the bar (the links as written, each closing the menu as it goes). A
  /// Nav that writes a `show=phone` or `show=tablet` line has its own.
  final bool menu;

  /// The id of the drawer an app's `Sidebar` opens in where the window is
  /// too narrow to show it (a phone): its lines are kept ([sidebar]) and the
  /// top bar of `Main` gets a menu button, shown there only, that opens it.
  /// Null: none.
  final String? sidebarMenu;

  /// What a drawer's panel is drawn on when the theme names no pane fill.
  final String surface;

  /// Whether what the words draw by themselves with no theme color for it
  /// (a sidebar item's tint under the pointer, a table's header band) is
  /// written by the theme's role for it (`hoverFill`, `band`:
  /// ThemeTokens.notationRoles), light or dark as the site is shown.
  final bool themeRoles;

  /// What a table's header band is with no band of the theme's.
  String get _headBand => themeRoles ? 'band' : '#FFF8FAFC';

  /// With no theme of its own (no design system): the theme's role an
  /// overlay's panel is drawn in (`surface`), and its title and close button
  /// in `onSurface`, so a dialog or a drawer follows the site's theme and
  /// its dark mode. Null: the design system's looks, as written.
  final String? overlaySurface;

  /// The id of the lightbox a design system's gallery opens its photos in
  /// on a page (a component [takesViewer] names: it has `photos` and
  /// `viewer="overlay"`), so its large view is over the window and not in
  /// the page's flow. Its line is given `viewer="overlay"` and, after its
  /// own actions, sets `<id>Photos` and `<id>At` and opens the lightbox,
  /// which is written once at the end of the text ([viewerUsed]). Null: a
  /// gallery is left as written (a card).
  final String? viewer;
  final bool Function(String name) takesViewer;

  /// Whether a gallery's line was given the viewer, and the lists written
  /// out on such lines, by the name of the variable each was moved to.
  bool viewerUsed = false;
  final viewerLists = <String, String>{};

  /// [text], a gallery's line, opening its photos in the page's viewer.
  String _gallery(String text) {
    final id = viewer;
    final head = _head.firstMatch(text);
    if (id == null || head == null || !takesViewer(head[1]!)) return text;
    final parts = _Parts(text.substring(head.end));
    // One photo at a time in place is paged where it is; a line that says
    // how it opens is left as it is.
    if (parts.has('viewer') || parts.value('layout')?.replaceAll('"', '') == 'pages' || parts.hasWord('pages')) return text;
    final written = parts.value('photos');
    if (written == null) return text;
    var list = written;
    if (list.startsWith('{') && list.endsWith('}')) list = list.substring(1, list.length - 1);
    if (list.startsWith('[')) {
      // A list written out is kept once, for the gallery and the viewer.
      final name = '${id}List${viewerLists.length + 1}';
      viewerLists[name] = list;
      text = text.replaceFirst('photos=$written', 'photos={$name}');
      list = name;
    }
    viewerUsed = true;
    final held = parts.binding();
    final opened = '${id}Photos=$list; ${id}At=result-1; open $id${held == null ? '' : '; $held=0'}';
    return withAction(text.replaceFirst(head[0]!, '${head[0]} viewer="overlay"'), opened);
  }

  /// Where the actions of what [text]'s node does are: inside the braces of
  /// its onTap={…}, else of the first event written on the line (a control's
  /// onChange, a block's own), or null when it has none.
  static ({int start, int end})? _ownEvent(String text) {
    ({int start, int end})? first;
    for (final m in RegExp(r'\s(on[A-Z][A-Za-z]*)=\{').allMatches(text)) {
      if (_inString(text, m.start)) continue;
      var depth = 0, quoted = false, end = -1;
      for (var i = m.end - 1; i < text.length; i++) {
        final c = text[i];
        if (c == '"' && text[i - 1] != r'\') quoted = !quoted;
        if (quoted) continue;
        if (c == '{' || c == '[') depth++;
        if ((c == '}' || c == ']') && --depth == 0) {
          end = i;
          break;
        }
      }
      if (end < 0) continue;
      final found = (start: m.end, end: end);
      if (m[1] == 'onTap') return found;
      first ??= found;
    }
    return first;
  }

  /// Where the `{…}` merged into the node starts at the end of [text] (its
  /// length when there is none).
  static int _tailAt(String text) {
    for (final m in RegExp(r'\s\{"').allMatches(text)) {
      if (!_inString(text, m.start) && RegExp(r'\}\s*$').hasMatch(text) && _ownEventHolds(text, m.start) == false) return m.start;
    }
    return text.length;
  }

  /// Whether [at] is inside the braces of a value on [text] (an event's
  /// actions, an expression).
  static bool _ownEventHolds(String text, int at) {
    var depth = 0, quoted = false;
    for (var i = 0; i < at; i++) {
      final c = text[i];
      if (c == '"' && (i == 0 || text[i - 1] != r'\')) quoted = !quoted;
      if (quoted) continue;
      if (c == '{' || c == '[') depth++;
      if (c == '}' || c == ']') depth--;
    }
    return depth > 0;
  }

  /// [text] with [action] after the actions of what its node does (a `{…}`
  /// merged into the node at the end of the line stays last).
  static String withAction(String text, String action) {
    final own = _ownEvent(text);
    if (own != null) return '${text.substring(0, own.end).trimRight()}; $action${text.substring(own.end)}';
    final end = _tailAt(text);
    return '${text.substring(0, end).trimRight()} onTap={$action}${text.substring(end)}';
  }

  /// An app's `Sidebar` as written: what followed the word on its line and
  /// the lines under it (each with its indent from the Sidebar's), and
  /// whether a menu button was written for it.
  String? sidebarRest;
  final sidebar = <PageLine>[];
  bool sidebarButton = false;
  int? _sidebarAt;
  int _panesBefore = 0;
  double _widthBefore = 0;

  /// How wide an app's sidebar is at a tablet's width: a rail's 64, none
  /// where it is hidden there, else as written (what a table beside it has
  /// no room for).
  double _sideAtTablet = 0;
  bool _mainSeen = false;
  int? _mainAt;

  /// Whether the page makes its own drawer (a `Drawer` line of its own) or
  /// lays its window out by width itself (`App keep`): then no drawer and
  /// no button for it are made.
  bool ownDrawer = false;

  /// A token of a line that says what it does at another width.
  static final _byWidth = RegExp(r'^(?:(?:phone|tablet|desktop|portrait|landscape|min\w+|max\w+)\.|hide=|show=)');

  /// Where the sidebar's button shows: on a phone, and on a tablet too when
  /// the window drops the first of two panes there.
  String get _menuSize => _panesBefore >= 2 && _widthBefore > 420 ? 'tablet' : 'phone';

  /// The ink of what an overlay draws by itself, with no theme of its own.
  String get _overlayInk => overlaySurface == null ? '' : ' color=onSurface';

  static final _overlayHead = RegExp(r'^(Dialog|Modal|Sheet|BottomSheet|Drawer|Menu|Dropdown|Popover|Popup|Lightbox)#([A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*)(?=\s|$)');

  /// The overlay a top-level line opens (`Dialog#signup "Join"`,
  /// `Sheet#filters`, `Drawer#menu`, `Menu#more`, `Popover#tip`,
  /// `Lightbox#zoom`), or null: the lines under it are a canvas of their
  /// own, shown over the page by `open <id>`.
  Overlay? overlay(String text) {
    // `Canvas#about "About" path="about"`: another canvas of the document
    // (a page, or what an open shows as written), its lines its tree.
    final canvas = RegExp(r'^Canvas#([A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*)(?=\s|$)').firstMatch(text);
    if (canvas != null) {
      final width = double.tryParse(RegExp(r'\sw=(\d+(?:\.\d+)?)(?=\s|$)').firstMatch(text)?[1] ?? '');
      return Overlay('canvas', canvas[1]!, width ?? 390, const {}, const []);
    }
    final head = _overlayHead.firstMatch(text);
    if (head == null) return null;
    // A design system's component of the word's name that is no frame (a
    // Menu called with its items) is that component, as anywhere.
    if (isComponent(head[1]!) && !isFrame(head[1]!)) return null;
    final id = head[2]!;
    final parts = _Parts(text.substring(head.end));
    final width = double.tryParse(parts.take('w') ?? '');
    // `guard={expression}`: while it holds, a tap outside, Escape and back do
    // not close it (a form with something typed); `stops=[0.5,0.9]`: the
    // heights a sheet rests at, as shares of the window.
    // `blockBack={…}` (the canvas's key, as events.md names it) is the same.
    String? braced(String? g) => switch (g) {
          final String g when g.startsWith('{') && g.endsWith('}') && g.length > 2 => g.substring(1, g.length - 1).trim(),
          final g => g,
        };
    // `onBackPressed={…}`: what Escape, a tap outside and back do instead of
    // closing it (while the guard holds; with no guard, always).
    final onBack = switch (parts.take('onBackPressed')) {
      final String d when d.startsWith('{') && d.endsWith('}') => d.substring(1, d.length - 1).trim(),
      _ => null,
    };
    final guard = braced(parts.take('guard')) ?? braced(parts.take('blockBack')) ?? (onBack == null ? null : 'true');
    // `guardText="Discard changes?"`: what Escape, a tap outside and back do
    // while the guard holds: ask that, and on a yes run `onDiscard={…}` and
    // close.
    final guardText = switch (parts.take('guardText')) {
      final String t when t.startsWith('"') => t,
      final String t when t.isNotEmpty => '"$t"',
      _ => null,
    };
    final discard = switch (parts.take('onDiscard')) {
      final String d when d.startsWith('{') && d.endsWith('}') => d.substring(1, d.length - 1).trim(),
      _ => null,
    };
    final stops = [
      for (final s in (parts.take('stops') ?? '').replaceAll(RegExp(r'[\[\]\s]'), '').split(','))
        if (double.tryParse(s) case final double h when h > 0 && h <= 1) h,
    ];
    // `stop=@name` (a Sheet with stops): the variable that holds the stop
    // the open sheet rests at, read and written.
    final stop = parts.take('stop');
    final stopVariable = stop != null && RegExp(r'^@[A-Za-z_][A-Za-z0-9_]*$').hasMatch(stop) && stops.isNotEmpty ? stop.substring(1) : null;
    final title = parts.string(), note = parts.string();
    final heading = _variant(const ['heading', 'heading3', 'sectionTitle', 'strong']);
    // What heads a dialog or a sheet: its title, a close button, a line under it.
    List<PageLine> titled() => [
          if (title != null) (indent: 2, text: 'Row w=fill between middle gap=12'),
          if (title != null) (indent: 4, text: 'Text${heading == null ? '' : '.$heading'} $title grow$_overlayInk'),
          if (title != null) (indent: 4, text: 'IconButton "close"$_overlayInk onTap={close}'),
          if (note != null) (indent: 2, text: 'Text${textVariants.contains('muted') ? '.muted' : ''} $note'),
        ];
    switch (head[1]!) {
      case 'Dialog' || 'Modal':
        const action = <String, Object?>{
          'presentation': 'dialog',
          'insets': [16, 24, 16, 24],
        };
        // A design system's own dialog frame (its title, its close button) is the dialog.
        if (isFrame('Dialog')) {
          // Its close event (its close button, Escape) closes it; a frame with
          // no event closes as the page's other overlays do.
          final events = frameEvents('Dialog');
          final closes = events.contains('onClose') ? 'onClose' : events.firstOrNull;
          return Overlay('dialog', id, width ?? 480, action, [
            (indent: 0, text: 'Dialog${title == null ? '' : ' $title'}${note == null ? '' : ' $note'}${parts.hasEvent || closes == null ? parts.props : '${parts.props} $closes={close}'}${parts.tail}'),
          ], surface: false, guard: guard, guardText: guardText, onDiscard: discard, onBack: onBack);
        }
        final pad = parts.take('pad') ?? '24', gap = parts.take('gap') ?? '16';
        return Overlay('dialog', id, width ?? 480, action, [(indent: 0, text: 'Column w=fill pad=$pad gap=$gap${parts.all}'), ...titled()], radius: 16, guard: guard, guardText: guardText, onDiscard: discard, onBack: onBack);
      case 'Sheet' || 'BottomSheet':
        final pad = parts.take('pad') ?? '[20,8,20,24]', gap = parts.take('gap') ?? '16';
        final w = width ?? 560;
        return Overlay(
          'sheet',
          id,
          w,
          {
            'presentation': 'bottomSheet',
            'sheetWidth': w,
            'sheetRadius': 20,
            'showDragHandle': true,
            // As tall as its highest stop when that is over nine tenths (`stops=[0.5,1]`).
            'maxHeightFactor': stops.fold<double>(0.9, math.max),
            if (stops.isNotEmpty) 'snapHeights': stops,
            'stopVariable': ?stopVariable,
          },
          // A sheet with stops is as tall as its stop, and scrolls in it.
          [(indent: 0, text: 'Column w=fill${stops.isEmpty ? '' : ' h=fill scroll'} pad=$pad gap=$gap${parts.all}'), ...titled()],
          guard: guard,
          guardText: guardText,
          onDiscard: discard,
          onBack: onBack,
          stop: stop,
        );
      case 'Drawer':
        // A panel as tall as the window at its side; a tap beside it closes it.
        final right = parts.word('right') | parts.word('end');
        parts.word('left');
        final w = width ?? 300;
        final pad = parts.take('pad') ?? '[16,20,16,16]', gap = parts.take('gap') ?? '12';
        const beside = (indent: 2, text: 'Box grow h=fill onTap={close}');
        return Overlay(
          'drawer',
          id,
          390,
          const {'presentation': 'dialog', 'cover': true},
          [
            (indent: 0, text: 'App'),
            if (right) beside,
            // A drawer's edge is the scrim's: no rule at its side (a light
            // line round a dark panel), unless the line writes a border.
            (indent: 2, text: 'Sidebar w=${_n(w)} pad=$pad gap=$gap${parts.has('fill') || (sideFill ?? paneFill) != null ? '' : ' fill=${overlaySurface ?? surface}'}${parts.hasBorder ? '' : ' border-right=#00000000'}${parts.all}'),
            if (title != null) (indent: 4, text: 'Text${heading == null ? '' : '.$heading'} $title$_overlayInk'),
          ],
          shift: 2,
          foot: [if (!right) beside],
          surface: false,
          closes: 'nav',
        );
      case 'Menu' || 'Dropdown' || 'Popover' || 'Popup':
        final menu = head[1] == 'Menu' || head[1] == 'Dropdown';
        final above = parts.word('above') | parts.word('up');
        final end = parts.word('end') | parts.word('right');
        final center = parts.word('center');
        parts.word('below');
        parts.word('start');
        final placement = parts.take('placement') ?? '${above ? 'above' : 'below'}${end ? 'End' : center ? 'Center' : 'Start'}';
        // `arrow`: it points at what opened it. `hover`: it opens as a hover
        // card however it is opened (what preview=id on a line asks for).
        final arrow = parts.word('arrow'), hover = parts.word('hover');
        final action = <String, Object?>{
          'presentation': 'popover',
          'anchor': 'trigger',
          'placement': placement,
          'anchorGap': arrow ? 10 : 6,
          if (arrow) 'popoverArrow': true,
          if (hover) 'hoverCard': true,
        };
        if (menu && isFrame('MenuPopover')) {
          return Overlay('menu', id, width ?? 228, action, [(indent: 0, text: 'MenuPopover${title == null ? '' : ' $title'}${parts.all}')], surface: false, closes: 'all');
        }
        final pad = parts.take('pad') ?? (menu ? '6' : '16'), gap = parts.take('gap') ?? (menu ? '2' : '12');
        return Overlay(
          menu ? 'menu' : 'popover',
          id,
          width ?? (menu ? 220 : 320),
          action,
          [
            (indent: 0, text: 'Column w=fill pad=$pad gap=$gap${parts.all}'),
            if (title != null) (indent: 2, text: 'Text${textVariants.contains('caption') ? '.caption' : ''} $title${menu ? ' pad=[8,6,8,2]' : ''}'),
            if (note != null) (indent: 2, text: 'Text${textVariants.contains('muted') ? '.muted' : ''} $note'),
          ],
          radius: 12,
          outlined: true,
          closes: menu ? 'all' : 'none',
        );
      default:
        return _lightbox(id, parts, title, note);
    }
  }

  /// A picture, or a list of them, shown large over the page
  /// (`Lightbox#zoom "{photo}" "Caption"`, `Lightbox#zoom
  /// photos={photos} @at`): the picture contained in the window on a dark scrim, zoomed by
  /// a pinch, the wheel and a double tap (to 2x where it was tapped, and
  /// back), panned while zoomed and kept inside the window; closed by its
  /// button, Escape, a tap on the scrim and a drag down. A list is paged by
  /// a swipe, the arrows and the arrow keys, with a count and a strip of
  /// thumbnails; `@at` is the picture shown, from 0. The lines written under
  /// a list draw one picture (`photo` is the element) in place of an Image
  /// of its `url`.
  Overlay _lightbox(String id, _Parts parts, String? title, String? note) {
    final written = parts.take('photos') ?? parts.take('images') ?? parts.take('items');
    final thumbs = (parts.take('thumbs') ?? 'true') != 'false';
    final max = num.tryParse(parts.take('max') ?? '') ?? 4;
    // It is the whole window, its picture contained in it: a size written on
    // its line (`Lightbox#gallery "…" w=960 h=665`, as a Dialog's) has nothing
    // to size. It was "h= is written twice on this line", said of a line that
    // wrote it once (round 11b, property-listings).
    parts
      ..take('w')
      ..take('h');
    // Its variables are named after it, an id's hyphens as `_` (a name).
    final word = id.replaceAll('-', '_');
    final zoom = '${word}Zoom';
    final variables = <String, Object?>{zoom: 1.0};
    final still = '$zoom<=1.01';
    const white = '#FFFFFFFF', pill = '#8C000000', pillOver = '#BF000000';
    String tail(Map<String, Object?> json) => ' ${_json(json)}';
    Map<String, Object?> at(Map<String, Object?> x, Map<String, Object?> y) => {'x': x, 'y': y};
    Map<String, Object?> fill(String color) => {
          'fills': [
            {'color': color},
          ],
        };
    // The picture's place: the window, clear of the bars. What zooms is the
    // picture's own box in it, kept over the window as a zoomed photo is
    // (no gap where it is larger, centered where it is smaller). The box has
    // the picture's proportions where they are known: `ratio:` on the line,
    // a `ratio` in a record of the list, a design system's drawn scene.
    final given = num.tryParse(parts.take('ratio') ?? '') ?? 0;
    final scenes = written != null && isComponent('Media');
    final ratio = written == null
        ? '$given'
        : 'coalesce(item.ratio, ${scenes ? 'coalesce(item.kind, "") != "" ? 1.5 : $given' : '$given'})';
    // The picture shown (a list's), from 0: the line's variable, or its own.
    final current = written == null ? null : (parts.binding() ?? '${word}At');
    final below = written == null ? (note == null ? 64 : 80) : (thumbs ? 144 : 80);
    List<PageLine> photo(int indent) => [
          (
            indent: indent,
            text: 'Stack w=fill h=fill center middle pad=[72,64,72,$below]${tail({
              'media': [
                {
                  'maxWidth': 699,
                  'patch': {
                    'layout': {
                      'padding': [0, 64, 0, below],
                    },
                  },
                },
              ],
            })}',
          ),
          (
            indent: indent + 2,
            text: 'Stack#${id}Photo w=fill h=fill center middle${tail({
              'transformGesture': {'target': 'node', 'pan': 'whenZoomed', 'minScale': 1, 'maxScale': max, 'doubleTapScale': 2, 'wheel': 'zoom', 'bounds': 'cover'},
              'bind': {'layout.aspectRatio': '\${= $ratio}'},
              'actions': [
                // The zoom of the picture in view (one left behind as the page
                // turns settles unseen).
                {
                  'trigger': {'type': 'changed', if (current != null) 'when': '\${= index == $current}'},
                  'actions': [
                    {'type': 'setVariable', 'variable': zoom, 'value': r'${= round(result.scale, 2)}'},
                  ],
                },
                // A tap on the picture itself leaves it open; where its box
                // may be wider than the picture, a tap is one on the scrim.
                {
                  'trigger': {'type': 'click', 'when': '\${= ($ratio) <= 0 && $still}'},
                  'actions': [
                    {'type': 'closeModal'},
                  ],
                },
              ],
            })}',
          ),
        ];
    PageLine round(String name, double size, String action, Map<String, Object?> place, {String? visible, bool wide = false}) => (
          indent: 4,
          text: 'Row#$id$name w=${_n(size)} h=${_n(size)} center middle radius=${_n(size / 2)}${visible == null ? '' : ' visible={$visible}'} onTap={$action}${tail({
            'layout': place,
            'decoration': fill(pill),
            'states': {
              'hovered': {
                '$id$name': {'decoration': fill(pillOver)},
              },
            },
            if (wide)
              'media': [
                {
                  'maxWidth': 699,
                  'patch': {
                    'visible': false,
                    'bind': {'visible': null},
                  },
                },
              ],
          })}',
        );
    PageLine glyph(String name, double size) => (indent: 6, text: 'Icon "$name"${tail({'props': {'size': size, 'color': white}})}');
    PageLine label(int indent, String text, {num size = 13, int weight = 500, String more = ''}) => (
          indent: indent,
          text: 'Text $text$more${tail({
            'props': {
              'style': {'color': white, 'fontSize': size, 'fontWeight': weight, 'height': 1.35},
            },
          })}',
        );
    Map<String, Object?> key(String name, List<Map<String, Object?>> actions, String when) => {
          'trigger': {'type': 'keyDown', 'key': name, 'when': '\${= $when}'},
          'actions': actions,
        };
    Map<String, Object?> set(String name, String value) => {'type': 'setVariable', 'variable': name, 'value': '\${= $value}'};
    // A tap on the scrim closes it while the picture is at rest; a zoom left
    // from the last time is forgotten as it opens.
    List<Map<String, Object?>> rootActions([List<Map<String, Object?>> more = const []]) => [
          {
            'trigger': {'type': 'click', 'when': '\${= $still}'},
            'actions': [
              {'type': 'closeModal'},
            ],
          },
          {
            'trigger': {'type': 'load'},
            'actions': [set(zoom, '1')],
          },
          ...more,
        ];
    const action = <String, Object?>{
      'presentation': 'dialog',
      'cover': true,
      'barrierColor': '#F2000000',
      // It fades in rising a little; a drag down takes it back the same
      // way, under the finger, and closes it past a fifth of the window.
      'routeTransition': {
        'enter': {
          'motion': {'opacity': 0, 'shiftY': 0.12},
        },
        'durationMs': 220,
        'dismiss': {'direction': 'down', 'distance': 0.2},
      },
    };
    final close = [round('Close', 40, 'close', at({'end': 16}, {'start': 16})), glyph('close', 20)];
    final zoomed = <PageLine>[
      (indent: 4, text: 'Row#${id}Scale w=hug pad=[12,6,12,6] radius=999 visible={$zoom>1.01}${tail({'layout': at({'align': 0}, {'start': 20}), 'decoration': fill(pill)})}'),
      label(6, '"{round($zoom,1)}×"', weight: 600),
    ];
    if (written == null) {
      return Overlay(
        'lightbox',
        id,
        390,
        action,
        [
          (indent: 0, text: 'Column w=fill h=fill center middle${parts.props}${tail({'actions': rootActions()})}'),
          (indent: 2, text: 'Stack#${id}Stage w=fill h=fill grow'),
          ...photo(4),
          if (title != null) (indent: 8, text: 'Image $title w=fill h=fill fit=contain'),
          if (note != null) (indent: 4, text: 'Row w=hug pad=[14,8,14,8] radius=12 visible={$still}${tail({'layout': at({'align': 0}, {'end': 20}), 'decoration': fill(pill)})}'),
          if (note != null) label(6, note, size: 14, more: ' center'),
          ...zoomed,
          ...close,
        ],
        surface: false,
        variables: variables,
      );
    }
    // A list: written out (a variable of its own), or worked out.
    var list = written;
    if (list.startsWith('{') && list.endsWith('}')) list = list.substring(1, list.length - 1);
    if (list.startsWith('[')) {
      variables['${word}Photos'] = list;
      list = '${word}Photos';
    }
    final index = current!;
    variables.putIfAbsent(index, () => 0);
    final last = 'length($list)-1';
    final shown = 'at($list,clamp($index,0,max(0,$last)))';
    final caption = 'coalesce($shown.caption,$shown.title,"")';
    return Overlay(
      'lightbox',
      id,
      390,
      action,
      [
        (
          indent: 0,
          text: 'Column w=fill h=fill center middle${parts.props}${tail({
            'actions': rootActions([
              key('ArrowRight', [set(index, 'min($index+1,$last)')], '$index<$last'),
              key('ArrowLeft', [set(index, 'max($index-1,0)')], '$index>0'),
            ]),
          })}',
        ),
        (indent: 2, text: 'Stack#${id}Stage w=fill h=fill grow'),
        (
          indent: 4,
          text: 'Pages#${id}Pages @$index w=fill h=fill${tail({
            'props': {'animationDuration': 280},
            // Another picture starts at rest.
            'actions': [
              {
                'trigger': {'type': 'changed'},
                'actions': [
                  set(index, 'result.index'),
                  {'type': 'controlTransform', 'node': '${id}Photo', 'command': 'reset'},
                  set(zoom, '1'),
                ],
              },
            ],
          })}',
        ),
        (indent: 6, text: 'each photo in $list'),
        ...photo(8),
      ],
      shift: 10,
      empty: [
        if (scenes)
          (indent: 2, text: 'Media kind={coalesce(photo.kind,"mountain")} tone={coalesce(photo.tone,"auto")} w=fill h=fill visible={coalesce(photo.kind,"")!=""}${tail({'layout': {'aspectRatio': 1.5}})}'),
        (indent: 2, text: 'Image "{coalesce(photo.url,photo.src,photo.image,photo)}" w=fill h=fill fit=contain${scenes ? ' visible={coalesce(photo.kind,"")==""}' : ''}'),
      ],
      foot: [
        (indent: 4, text: 'Row#${id}Count w=hug pad=[12,6,12,6] radius=999${tail({'layout': at({'start': 16}, {'start': 20}), 'decoration': fill(pill)})}'),
        label(6, '"{clamp($index,0,max(0,$last))+1} / {length($list)}"', weight: 600),
        ...zoomed,
        ...close,
        round('Prev', 44, '$index=max($index-1,0)', at({'start': 16}, {'align': 0}), visible: '$index>0&&$still', wide: true),
        glyph('chevron_left', 26),
        round('Next', 44, '$index=min($index+1,$last)', at({'end': 16}, {'align': 0}), visible: '$index<$last&&$still', wide: true),
        glyph('chevron_right', 26),
        (
          indent: 4,
          text: 'Column#${id}Foot w=hug h=hug center gap=10 visible={$still}${tail({'layout': at({'align': 0}, {'end': 16})})}',
        ),
        (indent: 6, text: 'Row pad=[14,8,14,8] radius=12 visible={$caption!=""}${tail({'decoration': fill(pill)})}'),
        label(8, '"{$caption}"', size: 14, more: ' center'),
        if (thumbs) ...[
          (indent: 6, text: 'Row#${id}Thumbs scroll gap=6 pad=6 radius=10 visible={length($list)>1}${tail({'decoration': fill(pill)})}'),
          (indent: 8, text: 'each photo in $list'),
          (
            indent: 10,
            text: 'Stack#${id}Thumb w=64 h=48 radius=6 onTap={$index=index}${tail({
              'decoration': {
                'clip': 'antiAlias',
                'strokes': [
                  {'color': white},
                ],
                'strokeWidth': 2,
              },
              'bind': {'opacity': '\${= index == $index ? 1 : 0.6}', 'decoration.strokeWidth': '\${= index == $index ? 2 : 0}'},
            })}',
          ),
          (indent: 12, text: Overlay.lines),
        ],
      ],
      surface: false,
      variables: variables,
    );
  }

  static String _json(Object? v) => switch (v) {
        final Map<Object?, Object?> m => '{${m.entries.map((e) => '"${e.key}":${_json(e.value)}').join(',')}}',
        final List<Object?> l => '[${l.map(_json).join(',')}]',
        final String s => '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"',
        _ => '$v',
      };

  /// [text], a line written under an overlay that closes as its lines are
  /// used ([Overlay.closes]), with `close` after its actions. In a drawer
  /// (`nav`) a line tapped closes it (a row of a list, a text, a component),
  /// but a control (a button, a chip, a toggle…) only when it goes somewhere
  /// (`go`, `scroll`, `link`, `open` …): a filter cleared or a choice made in
  /// the drawer keeps it open.
  static String closing(String text, String closes) {
    if (closes == 'none') return text;
    final t = text.trimLeft();
    if (closes == 'nav' && !RegExp(r'(^|\s)onTap=\{').hasMatch(t)) return text;
    final own = _ownEvent(text);
    if (own == null) return text;
    final actions = text.substring(own.start, own.end);
    if (RegExp(r'(^|;)\s*close\s*(;|$)').hasMatch(actions)) return text;
    if (closes == 'nav' &&
        _controls.contains(RegExp(r'^[A-Za-z][A-Za-z0-9]*').stringMatch(t)) &&
        !RegExp(r'(^|[;{]|then|:)\s*(go|scroll|link|open|back|confirm)\b').hasMatch(actions)) {
      return text;
    }
    // What opens another overlay closes this one first: closed after, the
    // close would shut the overlay just opened (a drawer's "Shortcuts").
    if (RegExp(r'(^|[;{]|then|:)\s*(open|confirm)\s').hasMatch(actions)) {
      return '${text.substring(0, own.start)}close; ${text.substring(own.start).trimLeft()}';
    }
    return '${text.substring(0, own.end).trimRight()}; close${text.substring(own.end)}';
  }

  /// The notation's controls: a tap on one in a drawer closes it only when
  /// it goes somewhere ([closing]).
  static const _controls = {
    'Button', 'IconButton', 'Chip', 'Toggle', 'Switch', 'Checkbox', 'Radio', 'Slider', 'Input', 'TextArea', 'Select', //
    'Dropdown', 'SegmentedButton', 'Stepper', 'NumberInput', 'DatePicker', 'TimePicker', 'Rating', 'Tabs',
  };

  /// What closes a frame: a bar's menu for a phone, then its rule.
  List<PageLine> _closing(_Line closed) {
    final at = closed.indent + closed.before;
    // It repeats the links the bar hides on a phone: the ones written
    // straight under the Nav and the ones in a row of two or more. A lone
    // link beside the bar's buttons stays where it is.
    final inGroup = <_Line?, int>{};
    for (final link in closed.links) {
      if (link.mark == null) inGroup[link.group] = (inGroup[link.group] ?? 0) + 1;
    }
    final links = [
      for (final link in closed.links)
        if (link.mark == null && (link.direct || (inGroup[link.group] ?? 0) >= 2)) link,
    ];
    // The bar's other labelled buttons, which the menu holds once there is one.
    final buttons = [
      if (links.isNotEmpty)
        for (final link in closed.links)
          if (link.mark != null) link,
    ];
    // From six links on, a tablet has no room for them either.
    final size = links.length >= 6 ? 'tablet' : 'phone';
    return [
      if (closed.table case final _Table t) ..._tableClose(t),
      if (menu && closed.pageNav && links.isNotEmpty && !closed.ownMenu) ...[
        // As big as the bar's buttons: a target a thumb finds.
        (indent: at + 4, text: 'IconButton "menu" w=40 h=40 show=$size onTap={navMenu=!navMenu}'),
        (indent: at + 2, text: 'if navMenu'),
        (indent: at + 4, text: 'Column w=fill maxw=${_n(contentWidth)} show=$size gap=2 pad=[0,8,0,4]'),
        for (final link in links) ...[
          (indent: at + 6, text: 'Row w=fill pad=[12,10,12,10] radius=8 middle onTap={navMenu=false; ${link.action}}'),
          (indent: at + 8, text: 'Text.strong ${link.label}'),
        ],
        for (final b in buttons) ...[
          (indent: at + 6, text: 'Row w=fill pad=[12,6,12,6]'),
          (indent: at + 8, text: 'Button${b.mark} ${b.label} grow onTap={navMenu=false; ${b.action}}'),
        ],
      ],
      if (closed.after != null) (indent: at, text: closed.after!),
    ];
  }

  String _role(String name) => roles ? '~$name' : '';

  /// The lines open above the one being read.
  final _open = <_Line>[];

  /// Whether the page's root is an app window (as tall as the window).
  bool app = false;

  /// Every word this layer reads (a frame, a bar, a pane, an overlay, a
  /// line of a bar): none of them is an unknown word, or an alias.
  static const words = {
    'Page', 'App', 'AppShell', 'Window', 'Section', 'Footer', 'Hero', 'Main', 'Content', 'Pane', 'Panel', //
    'Dialog', 'Modal', 'Sheet', 'BottomSheet', 'Drawer', 'Menu', 'Dropdown', 'Popover', 'Popup', 'Lightbox', 'SwipeAction', 'Wanted',
    ..._bars, ..._sides,
  };
  static const _bars = {'Nav', 'Navbar', 'NavBar', 'TopBar', 'Topbar', 'Header', 'AppBar'};
  static const _sides = {'Sidebar', 'Aside', 'SideNav', 'Sidenav', 'Rail'};

  /// In a sidebar: the foot pinned at its end.
  static const _feet = {'Footer'};

  static final _head = RegExp(r'^([A-Z][A-Za-z0-9]*)((?:\.[A-Za-z][A-Za-z0-9]*)?(?:#[A-Za-z_][A-Za-z0-9_]*(?:-[A-Za-z0-9_]+)*)?)(?=\s|$)');

  /// The lines [text] at [indent] stands for: itself, moved under the frame
  /// it is in, or the plain lines of a page word.
  ///
  /// A key the writer wrote is theirs: where the word's lines give the same
  /// key a value of their own (`Sidebar w=240 h=fill`, whose column is
  /// already as tall as the window; `Table … radius=0 border=rule`), the
  /// word's is left out and the writer's kept, without a word. A key the
  /// writer wrote twice is still said.
  /// How far a plain line written at [indent] moves under the lines its
  /// frames added (a Section's inner column, a Nav's row), as [rewrite]
  /// moves it, without reading it: a node's custom paint and animation lines
  /// go under the node they are written under.
  int shiftAt(int indent) {
    final parent = _open.lastWhere((l) => l.indent < indent, orElse: () => _Line(-1, null, before: 0));
    return parent.indent < 0 ? 0 : parent.before + parent.shift;
  }

  List<PageLine> rewrite(int indent, String text) {
    _Parts.handedOut.clear();
    final out = _rewrite(indent, text);
    if (_Parts.handedOut.isEmpty) return out;
    final own = [for (final s in _Parts.handedOut) if (s.trim().isNotEmpty) s];
    _Parts.handedOut.clear();
    if (own.isEmpty) return out;
    return [
      for (final l in out)
        switch (own.where(l.text.endsWith).firstOrNull) {
          final String s => (indent: l.indent, text: _writerWins(l.text.substring(0, l.text.length - s.length), s)),
          null => l,
        },
    ];
  }

  /// [head] (a word's line before what the writer wrote) and [written],
  /// without the keys of [head] that [written] gives again.
  static String _writerWins(String head, String written) {
    final keys = {
      for (final t in _Parts(written)._tokens)
        if (_Parts._key.firstMatch(t)?[1] case final String k) k,
    };
    if (keys.isEmpty) return '$head$written';
    final firstSpace = head.indexOf(' ');
    if (firstSpace < 0) return '$head$written';
    final kept = [
      for (final t in _Parts(head.substring(firstSpace))._tokens)
        if (!keys.contains(_Parts._key.firstMatch(t)?[1])) t,
    ];
    return '${head.substring(0, firstSpace)}${kept.isEmpty ? '' : ' ${kept.join(' ')}'}$written';
  }

  List<PageLine> _rewrite(int indent, String text) {
    text = _gallery(_plain(text));
    final out = <PageLine>[];
    while (_open.isNotEmpty && _open.last.indent >= indent) {
      out.addAll(_closing(_open.removeLast()));
    }
    if (_sidebarAt case final int from) {
      if (indent > from) {
        sidebar.add((indent: indent - from, text: text));
      } else {
        _sidebarAt = null;
      }
    }
    final bar = _open.where((l) => l.pageNav).lastOrNull;
    if (bar != null && RegExp(r'\sshow[=:](phone|tablet|mobile)(\s|$)').hasMatch(text)) bar.ownMenu = true;
    final parent = _open.lastOrNull;
    // Where this line goes: under the lines its frames added.
    final shift = parent == null ? 0 : parent.before + parent.shift;
    final at = indent + shift;
    final head = _head.firstMatch(text);
    final word = head?[1];
    final rest = head == null ? '' : text.substring(head.end);
    final mark = head?[2] ?? '';
    // A frame is one only among frames: a Header inside a card is a row.
    final framed = parent == null || parent.frame != null;
    final root = _open.isEmpty ? null : _open.first.frame;

    _Line open({String? frame, int shift = 0, String? after}) {
      final l = _Line(indent, frame, before: at - indent, shift: shift, after: after);
      _open.add(l);
      return l;
    }

    // A line under a Table is its next cell (table_words.dart); an `else`
    // goes on the cell of the `if` before it (round 11b, kanban-board: "An
    // else follows an if at the same depth" was said of one that did).
    if (parent?.table case final _Table t when !RegExp(r'^else\b').hasMatch(text)) out.add(_cellLine(t));
    if (word == 'Table' && !isComponent('Table') && !declares('Table')) {
      if (_tableLines(at, mark, rest) case (final lines, final table)) {
        // Its cells go under a row's: eight further in than its own lines.
        open(frame: 'Table', shift: 8).table = table;
        return out..addAll(lines);
      }
    }

    // A Main with no top bar of its own gets a slim one where the sidebar is
    // hidden, for the button that opens it.
    if (_mainAt case final int from) {
      _mainAt = null;
      final bar = word != null && _bars.contains(word) && !isComponentCall(word, _Parts(rest));
      if (indent > from && !bar && sidebarMenu != null && sidebarRest != null && !sidebarButton) {
        sidebarButton = true;
        _slimBarIn = from;
        out
          ..add((indent: at, text: 'Row${_role('autobar')} w=fill middle pad=[12,8,12,8] show=$_menuSize${paneFill == null ? '' : ' fill=$paneFill'}'))
          ..add((indent: at + 2, text: 'IconButton "menu" onTap={open $sidebarMenu}'))
          ..add((indent: at, text: 'Divider${_role('autobar')} show=$_menuSize'));
      }
    }
    // The writer's own button for a narrow window (`IconButton "menu"
    // show=phone onTap={open houseNav}`): the page has its navigation there,
    // so the button made for the sidebar, its bar and its drawer are not.
    if (root == 'App' && sidebarRest != null && !ownMenuButton && (word == 'IconButton' || word == 'Button') && RegExp(r'\sshow=(phone|mobile|tablet)(\s|$)').hasMatch(rest) && RegExp(r'[{;]\s*open\s').hasMatch(rest)) {
      ownMenuButton = true;
      slimBarSuperseded = true;
    }
    // An `if` or an `each` is not a place of its own: what is under it is
    // where the line itself is.
    if (RegExp(r'^(if|each|for|else)\b').hasMatch(text)) {
      open(frame: parent?.frame).conditional = true;
      return out..add((indent: at, text: text));
    }
    if (word == null || text.startsWith('node ') || text.startsWith('document ')) {
      open();
      return out..add((indent: at, text: text));
    }
    final parts = _Parts(rest);
    if (parent?.frame == 'Page' && word != 'Section') _plainSectionAt = null;
    // `TopBar "…" type=TopBar`: the design system's component, by its own
    // name (design 22, 4.2), no page word.
    if ((isComponent(word) || declares(word)) && parts.value('type') == word) {
      open();
      return out..add((indent: at, text: text));
    }
    // A text with a look of its own (a rule at its side, a fill, a corner)
    // is a box around the text: a text itself draws none.
    if (word == 'Text' && _looks(parts)) {
      open();
      return out..addAll(_textBox(at, mark, parts));
    }
    if (word == 'Page' && indent == 0) {
      site = true;
      open(frame: 'Page');
      final fill = parts.has('fill') || siteFill == null ? '' : ' fill=$siteFill';
      // As tall as the window it is shown in (where it has one), so that its
      // ground reaches the foot and its Footer sits there on a short page
      // (round 11: white under the footer).
      return out..add((indent: at, text: 'Column${_role('page')}$mark w=fill h=fill scroll stretch$fill${parts.all}'));
    }
    // `Page grow` under a site's header, `Page w=fill h=fill` in a Stack: the
    // page's scrolling column there, taking the room its column leaves, its
    // Sections a page's, as `App grow` is an app's region (round 11b, 4
    // builds: "No node type Page", which read as if the word did not exist).
    if (word == 'Page' && indent > 0 && !isComponent(word) && !declares(word)) {
      open(frame: 'Page');
      final sized = parts.has('h') || parts.hasWord('grow');
      return out..add((indent: at, text: 'Column$mark w=fill scroll stretch${sized ? '' : ' grow'}${parts.all}'));
    }
    if ((word == 'App' || word == 'AppShell' || word == 'Window') && indent == 0) {
      app = true;
      if (parts.hasWord('keep')) ownDrawer = true;
      open(frame: 'App');
      return out..add((indent: at, text: 'Row${_role('app')}$mark w=fill h=fill stretch${parts.all}'));
    }
    // `App grow` under a page's header (or in a component): a region of
    // panes side by side, taking the room its column leaves; its Sidebar,
    // Main and Pane are as in a window (Main scrolls), with no window's
    // drawer or phone bar of its own.
    if ((word == 'App' || word == 'AppShell' || word == 'Window') && indent > 0 && !isComponent(word)) {
      if (parts.hasWord('keep')) ownDrawer = true;
      open(frame: 'App');
      final sized = parts.has('h') || parts.hasWord('grow');
      return out..add((indent: at, text: 'Row$mark w=fill stretch${sized ? '' : ' grow'}${parts.all}'));
    }
    final inApp = root == 'App' || (parent?.frame == 'Sidebar' || parent?.frame == 'Main' || parent?.frame == 'Pane');
    // The foot of an app's window: a bar that stays in view at the bottom of
    // Main while what is above it scrolls (a now-playing bar, a composer, a
    // basket). `Footer` in Main or in App; `Row sticky bottom` the same.
    final foot = framed &&
        root == 'App' &&
        (parent?.frame == 'Main' || parent?.frame == 'App' || parent?.frame == 'Pane') &&
        (word == 'Footer' || ((word == 'Row' || word == 'Column' || word == 'Card') && parts.hasWord('sticky') && parts.hasWord('bottom')));
    if (foot) {
      final row = word == 'Row';
      parts.word('sticky');
      parts.word('bottom');
      parts.word('pinned');
      final pad = parts.take('pad') ?? '[24,12,24,12]';
      final gap = parts.take('gap') ?? '12';
      final fill = parts.has('fill') ? '' : ' fill=${paneFill ?? surface}';
      open(frame: 'Foot');
      return out
        ..add((indent: at, text: '${row ? 'Row' : 'Column'}${_role('foot')}$mark w=fill${row ? ' middle' : ''} pad=$pad gap=$gap$fill border-top=$line${parts.all}'));
    }
    if (word == 'Section' || (word == 'Footer' && !inApp) || (word == 'Hero' && !isComponent('Hero'))) {
      if (!framed) {
        open();
        return out..add((indent: at, text: 'Column$mark w=fill${parts.has('gap') ? '' : ' gap=16'}${parts.all}'));
      }
      final footer = word == 'Footer';
      final width = parts.take('maxw') ?? (parts.word('narrow') ? _n(narrowWidth) : _n(contentWidth));
      parts.word('wide');
      final g = _n(gutter);
      final tight = parts.word('compact') | parts.word('tight');
      final v = _n(tight ? (sectionPad / 2).roundToDouble() : sectionPad);
      // bleed: what is in it runs from edge to edge (a wide picture, a map).
      // With no ground of its own it is that picture, top to bottom: a hero
      // meets the bar above it (it sat 64 px below it on white, round 11).
      final bleed = parts.word('bleed');
      // A tinted band: the page's alternate ground, ruled off above and below.
      final tint = parts.word('tint') | parts.word('alt') | parts.word('band') | parts.word('muted');
      final grounded = tint || parts.has('fill');
      // A plain Section after a plain Section starts half its space down:
      // two sections' padding made 128 px of white between them.
      final plain = !grounded && !bleed && !footer && parent?.frame == 'Page';
      final top = plain && _plainSectionAt == indent ? _n((sectionPad / 2).roundToDouble()) : v;
      _plainSectionAt = plain && !parts.has('pad') ? indent : null;
      final pad = parts.take('pad') ?? (bleed ? (grounded ? '[0,$v,0,$v]' : '0') : footer ? '[$g,40,$g,40]' : '[$g,$top,$g,$v]');
      final banded = tint && band != null && !parts.has('fill') ? ' fill=$band border-top=$line border-bottom=$line' : '';
      final gap = parts.take('gap') ?? (footer ? '24' : '32');
      final inner = parts.takeWords(const {'center', 'middle', 'start', 'end', 'between', 'stretch', 'left', 'right'});
      open(frame: 'Section', shift: 2);
      // A page's Footer sits at the window's foot when the page is short: what
      // is left goes above it (nothing, on a page longer than the window).
      if (footer && parent?.frame == 'Page') out.add((indent: at, text: 'Spacer'));
      if (footer) out.add((indent: at, text: 'Divider'));
      return out
        ..add((indent: at, text: 'Column${_role('section')}$mark w=fill center pad=$pad$banded${parts.all}'))
        ..add((indent: at + 2, text: 'Column w=fill${bleed ? '' : ' maxw=$width'} gap=$gap${inner.isEmpty ? '' : ' ${inner.join(' ')}'}'));
    }
    if (_bars.contains(word) && !isComponentCall(word, parts)) {
      if (!framed) {
        // A bar still (in a component, out of a page's frame): its items sit
        // side by side. As a sidebar's, each took a share of the row's width,
        // one letter a line on a phone. Where they have no room (a phone)
        // they go onto a further line.
        open(frame: 'Nav');
        final wraps = RegExp(r'(^|\s)([a-z]+\.)?wrap\b').hasMatch(rest) ? '' : ' phone.wrap=true';
        return out..add((indent: at, text: 'Row$mark w=fill between middle${parts.has('gap') ? '' : ' gap=16'}$wraps${parts.all}'));
      }
      final gap = parts.take('gap') ?? '24';
      if (inApp) {
        final pad = parts.take('pad') ?? '[24,14,24,14]';
        final fill = parts.has('fill') || paneFill == null ? '' : ' fill=$paneFill';
        open(frame: 'Nav', after: 'Divider');
        out.add((indent: at, text: 'Row${_role('nav')}$mark w=fill between middle pad=$pad gap=$gap$fill${parts.all}'));
        // The sidebar a phone has no room for opens from a button here
        // (a tablet too, where it drops the first of two panes).
        // (A bar written after a line that draws nothing, an overlay's or a
        // shortcut's word: it is still Main's bar, and takes the button from
        // the slim bar made before it was read, which is then not drawn.)
        final afterSlim = _slimBarIn != null && parent?.frame == 'Main' && parent?.indent == _slimBarIn && !slimBarSuperseded;
        if (sidebarMenu != null && sidebarRest != null && (!sidebarButton || afterSlim) && parent?.frame == 'Main') {
          sidebarButton = true;
          if (afterSlim) slimBarSuperseded = true;
          out.add((indent: at + 2, text: 'IconButton${_role('appmenu')} "menu" show=$_menuSize onTap={open $sidebarMenu}'));
        }
        return out;
      }
      final width = parts.take('maxw') ?? _n(contentWidth);
      final pad = parts.take('pad') ?? '[${_n(gutter)},14,${_n(gutter)},14]';
      final sticky = parts.word('sticky') ? ' sticky=0${parts.has('fill') || siteFill == null ? '' : ' fill=$siteFill'}' : '';
      // A page has one bar that folds into a menu: its first. A Nav further
      // down the page is a strip of the page's own (the tabs of an article,
      // a filter): it keeps what is written in it at every width and, where
      // that has no room, scrolls sideways.
      if (_pageBar) {
        open(frame: 'Nav', shift: 2, after: 'Divider');
        return out
          ..add((indent: at, text: 'Column$mark w=fill center pad=$pad$sticky${parts.all}'))
          ..add((indent: at + 2, text: 'Row w=fill maxw=$width between middle gap=$gap phone.scroll=true'));
      }
      _pageBar = true;
      open(frame: 'Nav', shift: 2, after: 'Divider').pageNav = true;
      return out
        ..add((indent: at, text: 'Column$mark w=fill center pad=$pad$sticky${parts.all}'))
        ..add((indent: at + 2, text: 'Row${_role('nav')} w=fill maxw=$width between middle gap=$gap'));
    }
    if (_sides.contains(word) && !isComponentCall(word, parts)) {
      final width = parts.take('w') ?? _n(sidebarWidth);
      final pad = parts.take('pad') ?? '[12,16,12,12]';
      final gap = parts.take('gap') ?? '2';
      final tokens = parts._tokens;
      final window = framed && root == 'App' && indent > 0 && !_mainSeen;
      // A design system whose sidebar words fold to their icons at a
      // tablet's width (Desk) has a rail there: a sidebar written with no
      // rule for other widths was as wide as on a desktop with its items
      // folded, icons alone in 240 (track C).
      final railed = window &&
          sidebarRail != null &&
          (double.tryParse(width) ?? sidebarWidth) >= 120 &&
          !tokens.any((t) => _byWidth.hasMatch(t));
      // (On a phone it is the drawer, as a writer's rail is: `hide=phone`.)
      final rail = railed ? ' tablet.w=${_n(sidebarRail!)} hide=phone' : '';
      open(frame: framed ? 'Sidebar' : null);
      final side = sideFill ?? paneFill;
      final fill = !framed || parts.has('fill') || side == null ? '' : ' fill=$side';
      if (window) {
        _panesBefore++;
        _widthBefore += double.tryParse(width) ?? sidebarWidth;
        _sideAtTablet = railed
            ? sidebarRail!
            : parts.railWidths.any((w) => w != 'phone')
            ? 64
            : tokens.contains('hide=tablet') || tokens.contains('tablet.hidden') || tokens.contains('tablet.visible=false')
                ? 0
                : double.tryParse(width) ?? sidebarWidth;
        // The first pane of the window is what a narrow one leaves out.
        if (sidebarMenu != null && sidebarRest == null && _panesBefore == 1 && !ownDrawer) {
          // The drawer is the sidebar at a phone's width: what the line says
          // of other widths (tablet.w=64, hide=phone) is the rail's, not its.
          sidebarRest = ' pad=$pad gap=$gap${parts.propsAtEveryWidth}';
          _sidebarAt = indent;
        }
      }
      return out..add((indent: at, text: 'Column${framed ? _role('sidebar') : ''}$mark w=$width${framed ? ' h=fill' : ''} pad=$pad gap=$gap$fill${parts.hasBorder ? '' : ' border-right=$line'}${parts.all}$rail'));
    }
    if (word == 'Main' || word == 'Content') {
      if (framed && root == 'App' && !_mainSeen) {
        _mainSeen = true;
        _mainAt = indent;
      }
      open(frame: framed ? 'Main' : null);
      return out..add((indent: at, text: 'Column${framed ? _role('main') : ''}$mark grow${framed ? ' h=fill scroll' : ''}${parts.all}'));
    }
    if (word == 'Pane' || (word == 'Panel' && inApp && !isComponent('Panel'))) {
      // Among the panes of a window it is as tall as the window and scrolls;
      // in a row further in (a list beside its details) it is a column of it.
      final width = parts.take('w');
      parts.word('scroll');
      parts.word('grow');
      if (framed && root == 'App' && !_mainSeen && width != null) {
        _panesBefore++;
        _widthBefore += double.tryParse(width) ?? 0;
      }
      open(frame: framed ? 'Pane' : null);
      return out..add((indent: at, text: 'Column${framed ? _role('pane') : ''}$mark ${width == null ? 'grow' : 'w=$width'}${framed ? ' h=fill scroll' : ''}${parts.hasBorder || !framed ? '' : _mainSeen ? ' border-left=$line' : ' border-right=$line'}${parts.all}'));
    }
    if (parent?.frame == 'Sidebar' && _feet.contains(word) && !isComponent(word)) {
      // The foot stays at the sidebar's end whatever is above it: a spacer
      // takes the room between, and a rule parts it from the items.
      final pad = parts.take('pad') ?? '[0,8,0,0]';
      final gap = parts.take('gap') ?? '2';
      open(frame: 'Sidebar');
      return out
        ..add((indent: at, text: 'Spacer'))
        ..add((indent: at, text: 'Column$mark w=fill gap=$gap pad=$pad${parts.hasBorder ? '' : ' border-top=$line'}${parts.all}'));
    }
    // A badge with a width is a table's cell: the cell has the width, the
    // badge stays as big as its label.
    // A badge's ink follows its tone: a color worked out from data is left out.
    if (word == 'Badge' && !isComponent('Badge') && parts.bound('color')) {
      parts.take('color');
      if (!parts.has('w')) {
        open();
        return out..add((indent: at, text: 'Badge$mark${parts.all}'));
      }
    }
    if (word == 'Badge' && parts.has('w') && !isComponent('Badge')) {
      final width = parts.take('w')!;
      final grow = parts.word('grow') ? ' grow' : '';
      open();
      return out
        ..add((indent: at, text: 'Row w=$width$grow'))
        ..add((indent: at + 2, text: 'Badge$mark${parts.all}'));
    }
    // A field in a bar has no room for a label above it: its label is its
    // hint. A search field shows the magnifier before its text, as every
    // web search field and Desk's SearchField do, unless the line writes its
    // own icon (`icon=none`: none).
    if ((word == 'Input' || word == 'Search' || word == 'SearchField') &&
        (_open.any((l) => l.frame == 'Nav') || RegExp(r'^\s*"(Search|Filter|Find)\b').hasMatch(rest)) &&
        !isComponent(word)) {
      // A field in a bar that is not a search (a title edited in place, a
      // formula) has no magnifier: a search is one by its word, its text or
      // its id.
      final search = word != 'Input' ||
          RegExp(r'^\s*"(Search|Filter|Find)\b').hasMatch(rest) ||
          RegExp(r'search|find|filter', caseSensitive: false).hasMatch('$mark ${RegExp(r'"[^"]*"').allMatches(rest).take(2).map((m) => m[0]).join(' ')}');
      final ownIcon = parts.has('icon') || parts.has('prefixIcon');
      final noIcon = const {'none', '"none"'}.contains(parts.value('icon'));
      if (noIcon) parts.take('icon');
      final icon = ownIcon || !search ? '' : ' icon="search"';
      if (!parts.has('hint')) {
        final label = parts.string();
        final hint = parts.string() ?? label ?? '"Search"';
        open();
        return out..add((indent: at, text: 'Input$mark "" $hint$icon${parts.all}'));
      }
      if (word == 'Input' && (icon.isNotEmpty || noIcon)) {
        final label = parts.string();
        open();
        return out..add((indent: at, text: 'Input$mark${label == null ? '' : ' $label'}$icon${parts.all}'));
      }
    }
    // A quiet button in a website's bar (Button.ghost … onTap={…}): the bar
    // hides it on a phone, and its menu there repeats it.
    // Its other labelled buttons go into that menu with them (a phone's bar
    // is one line: the brand, the icon buttons and the menu button), unless
    // the line says where it shows or stands under a condition.
    if (bar != null && word == 'Button' && !isComponent('Button')) {
      final link = mark.startsWith('.ghost');
      final placed = _open.skipWhile((l) => !identical(l, bar)).any((l) => l.conditional) ||
          parts._tokens.any((t) => _byWidth.hasMatch(t) || t.startsWith('visible=') || t == 'hidden' || t.startsWith('hidden='));
      final label = parts.string();
      final does = parts.takeEvent();
      if (label != null && does != null && (link || !placed)) {
        bar.links.add((label: label, action: does.trim(), group: parent, direct: parent?.frame == 'Nav', mark: link ? null : mark.split('#').first));
      }
      open(frame: null);
      return out..add((indent: at, text: text));
    }
    // On a website a hero's buttons are large (44), and an icon button has
    // a hit area that shows (a 40 px square in a hairline): they were a
    // desktop app's 28 px buttons and a bare glyph (round 11). Its bar's are
    // the bar's, and a line that shows or hides itself is left as it is.
    if (site && !inApp && word == 'Button' && _inSiteSection && _open.any((l) => l.hero) && !parts.has('size') && !parts.has('h') && !isComponent('Button')) {
      open(frame: null);
      return out..add((indent: at, text: '$text size=large'));
    }
    if (site &&
        !inApp &&
        word == 'IconButton' &&
        mark.isEmpty &&
        _inSiteSection &&
        !isComponent('IconButton') &&
        !const ['w', 'h', 'size', 'fill', 'border', 'hide', 'show', 'visible'].any(parts.has) &&
        !RegExp(r'(^|\s)(hidden|hide=|show=|[a-z]+\.(hidden|visible|w|h)=)').hasMatch(rest)) {
      open(frame: null);
      return out
        ..add((indent: at, text: 'Box w=40 h=40 pad=0 radius=8 border=$line center middle'))
        ..add((indent: at + 2, text: '$text w=40 h=40'));
    }
    // A website's headline written as its text style: the same size.
    if (word == 'Text' && !inApp && (mark.startsWith('.pageTitle') || mark.startsWith('.heading1')) && _inSiteSection) {
      _open.lastWhere((l) => l.frame == 'Section').hero = true;
    }
    if (word == 'Text' && !inApp && (mark.startsWith('.pageTitle') || mark.startsWith('.heading1')) && _inSiteSection && !parts.has('size')) {
      if (_headlineSize(1) case final num display) {
        open(frame: null);
        return out..add((indent: at, text: '$text size=${_n(display.toDouble())}'));
      }
    }
    // `Row … phone.direction=vertical`: a row that is a column at some width
    // is a Flex, which has a direction to change.
    // (`phone.axis=vertical`, `phone.direction=column`: the same rule by the
    // names Flutter's and CSS's own have for it.)
    if ((word == 'Row' || word == 'Column') && !isComponent(word) && _turns.hasMatch(rest)) {
      open(frame: null);
      final all = parts.all.replaceAllMapped(_turn, (m) => '${m[1]}direction=${const {'column': 'vertical', 'row': 'horizontal'}[m[2]] ?? m[2]}');
      return out..add((indent: at, text: 'Flex$mark direction=${word == 'Row' ? 'horizontal' : 'vertical'}$all'));
    }
    open(frame: null);
    return out..add((indent: at, text: text));
  }

  /// A design system's own component of this name, when the line is
  /// written as it is called (`Sidebar items=[…]`, `TopBar title="…"`).
  /// Whether a text line writes a look of its own (a rule at a side, a
  /// fill, a corner): a text itself draws none.
  static bool _looks(_Parts parts) => (parts.hasBorder || parts.has('fill') || parts.has('radius')) && parts.tail.isEmpty && !parts.props.contains('{"');

  /// A text with a look of its own, as a box around the text.
  static List<PageLine> _textBox(int at, String mark, _Parts parts, {String text = '', String? action}) {
    final look = [
      for (final k in const ['fill', 'radius', 'border', 'border-left', 'border-right', 'border-top', 'border-bottom', 'w', 'maxw'])
        if (parts.take(k) case final String v) '$k=$v',
    ];
    final filled = look.any((l) => l.startsWith('fill='));
    final pad = parts.take('pad') ?? (!filled && look.any((l) => l.startsWith('border-left')) ? '[12,2,0,2]' : '[8,3,8,3]');
    final grow = parts.word('grow') ? ' grow' : '';
    // Where it shows, and the box's keys at other widths, are the box's: a
    // text hidden on a tablet leaves no empty box behind (hide=tablet,
    // phone.hidden, visible={…}, tablet.pad=4).
    final shown = [
      for (final k in const ['hide', 'show', 'visible', 'hidden'])
        if (parts.take(k) case final String v) '$k=$v',
      if (parts.word('hidden')) 'hidden',
      ...parts.takeMatching(_boxRule),
    ];
    return [
      (indent: at, text: 'Box${filled && !look.any((l) => l.startsWith('w=')) ? ' w=hug' : ''} ${look.join(' ')} pad=$pad$grow${shown.map((w) => ' $w').join()}'),
      (indent: at + 2, text: 'Text$mark${text.isEmpty ? '' : ' $text'}${parts.props}${action ?? parts.tail}'),
    ];
  }

  /// A rule at another width of a key the box around a text takes (its
  /// look, its size, its padding, whether it shows): `tablet.hidden`,
  /// `phone.pad=4`, `max899.fill=…`.
  /// A rule at another width that turns a line's direction (`phone.direction=vertical`).
  static final _turns = RegExp(r'(?:^|\s)(?:(?:phone|mobile|tablet|desktop|portrait|landscape|(?:min|max)(?:\d+|[A-Z][A-Za-z0-9]*))\.)+(?:direction|axis)=');

  /// One such rule, by any of its names and values.
  static final _turn = RegExp(r'((?:(?:phone|mobile|tablet|desktop|portrait|landscape|(?:min|max)(?:\d+|[A-Z][A-Za-z0-9]*))\.)+)(?:direction|axis)=(vertical|horizontal|column|row)(?=\s|$)');

  static final _boxRule = RegExp(
      r'^(?:(?:phone|mobile|tablet|desktop|portrait|landscape|(?:min|max)(?:\d+|[A-Z][A-Za-z0-9]*))\.)+(?:fill|radius|border(?:-[a-z]+)?|w|maxw|pad|hidden|visible)(?:=|$)');

  bool isComponentCall(String word, _Parts parts) => isComponent(word) && (parts.has('items') || parts.has('title') || parts.has('brand'));

  /// The lines that close what is still open (a bar's rule).
  List<PageLine> finish() {
    final out = <PageLine>[];
    while (_open.isNotEmpty) {
      out.addAll(_closing(_open.removeLast()));
    }
    return out;
  }

  static final _stickyKey = RegExp(r'\ssticky=true(?:\s+top=\d+)?(?=\s|$)');
  static final _avatarSrc = RegExp(r'^(Avatar(?:#\w+)?)\s+(?:src|url|img)=');

  /// A line with the keys a model reaches for by habit put as the notation
  /// has them: `sticky=true top=24` as the word `sticky`, an Avatar's `src=`
  /// as its `image=` (with the name it must have).
  static String _plain(String text) {
    // A typed state's formula (`state n:text={…}`) is kept as written: it is the document's.
    if (text.contains("'") && !RegExp(r'^state\s+[A-Za-z_][A-Za-z0-9_]*(\([^()]*\))?:[a-z]+').hasMatch(text)) text = _doubleQuoted(text);
    if (!text.contains('=')) return text;
    var t = text;
    if (t.contains(' sticky=true')) {
      final m = _stickyKey.firstMatch(t);
      if (m != null && !_inString(t, m.start)) t = t.replaceRange(m.start, m.end, ' sticky');
    }
    if (t.startsWith('Avatar')) {
      final m = _avatarSrc.firstMatch(t);
      if (m != null) {
        t = '${m[1]} "" image=${t.substring(m.end)}';
      } else {
        t = t.replaceFirstMapped(RegExp(r'\s(?:src|url|img)=(?=")'), (_) => ' image=');
      }
    }
    return t;
  }

  /// 'single-quoted' text outside a string, as "double-quoted": a value
  /// in an expression ends at its closing quote. An expression is kept as
  /// written, its quotes too (docs/design/22, 4.2): a value worked out
  /// (`key={…}` for a key that is no event), the condition of an `if` line
  /// and the list of an `each` line.
  static String _doubleQuoted(String t) {
    if (RegExp(r'^\s*(if|else\s+if|each)\s').hasMatch(t)) return t;
    final out = StringBuffer();
    var inDouble = false;
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      if (!inDouble && c == '{' && i > 0 && t[i - 1] == '=') {
        final key = RegExp(r'[^\s]*$').stringMatch(t.substring(0, i - 1)) ?? '';
        final end = key.startsWith(RegExp('on[A-Z]')) ? -1 : _braceEnd(t, i);
        if (end > i) {
          out.write(t.substring(i, end + 1));
          i = end;
          continue;
        }
      }
      if (inDouble) {
        out.write(c);
        if (t.codeUnitAt(i) == 0x5C && i + 1 < t.length) {
          out.write(t[++i]);
        } else if (c == '"') {
          inDouble = false;
        }
        continue;
      }
      if (c == '"') {
        inDouble = true;
        out.write(c);
        continue;
      }
      if (c == "'") {
        final end = t.indexOf("'", i + 1);
        final before = i == 0 ? ' ' : t[i - 1];
        if (end > i && !t.substring(i + 1, end).contains('"') && '=(,?:[!<>+&| '.contains(before)) {
          out.write('"${t.substring(i + 1, end)}"');
          i = end;
          continue;
        }
      }
      out.write(c);
    }
    return out.toString();
  }

  /// Where the `{` at [open] of [t] closes, either kind of quote paired;
  /// -1: never.
  static int _braceEnd(String t, int open) {
    var depth = 0;
    String? quote;
    for (var i = open; i < t.length; i++) {
      final c = t[i];
      if (quote != null) {
        if (t.codeUnitAt(i) == 0x5C) {
          i++;
        } else if (c == quote) {
          quote = null;
        }
        continue;
      }
      if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '{') {
        depth++;
      } else if (c == '}' && --depth == 0) {
        return i;
      }
    }
    return -1;
  }

  static bool _inString(String t, int at) {
    var inside = false;
    for (var i = 0; i < at; i++) {
      if (t.codeUnitAt(i) == 0x5C) {
        i++;
      } else if (t[i] == '"') {
        inside = !inside;
      }
    }
    return inside;
  }

  String? _variant(List<String> names) => names.where(textVariants.contains).firstOrNull;

  static String _n(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';

}

/// A block written after the page that is shown over it: a dialog, a
/// sheet, a drawer, a menu, a popover, a lightbox ([PageWords.overlay]).
final class Overlay {
  const Overlay(this.kind, this.id, this.width, this.action, this.head,
      {this.shift = 0,
      this.foot = const [],
      this.surface = true,
      this.radius = 0,
      this.outlined = false,
      this.closes = 'none',
      this.empty = const [],
      this.variables = const {},
      this.guard,
      this.guardText,
      this.onDiscard,
      this.onBack,
      this.stop});

  /// What a Sheet's `stop=` is given, as written (`@sheetStop`: the variable
  /// that holds the stop it rests at); null: nothing.
  final String? stop;

  /// The condition, as written, while which a tap outside, Escape and back
  /// do not close it (`guard={name != ""}`); null: they always do.
  final String? guard;

  /// While [guard] holds, what a tap outside, Escape and back ask, quoted
  /// (`guardText="Discard changes?"`): a yes runs [onDiscard] and closes it.
  /// Null: they do nothing.
  final String? guardText;

  /// The actions a yes to [guardText] runs before it closes (`draft=""`).
  final String? onDiscard;

  /// What Escape, a tap outside and back run while [guard] holds, in place
  /// of closing it (`onBackPressed={open keepDraft}`); before [guardText].
  final String? onBack;

  /// In [foot], a line that stands for the lines written under the block
  /// (else [empty]), read again there: a gallery's picture in its thumbnails.
  static const lines = '@lines';

  /// The lines read where none is written under the block.
  final List<PageLine> empty;

  /// The variables it keeps (a lightbox's zoom, the picture it shows), by
  /// name with the value each starts at; a text starting `[` is a list
  /// written out.
  final Map<String, Object?> variables;

  /// `dialog`, `sheet`, `drawer`, `menu`, `popover` or `lightbox`.
  final String kind;

  /// Its canvas's id: what `open` names.
  final String id;

  /// Its canvas's width.
  final double width;

  /// What an `open <id>` says besides its canvas: the presentation, where
  /// it sits.
  final Map<String, Object?> action;

  /// The plain lines it starts with (its root first) and ends with, and how
  /// much further in the lines written under it are.
  final List<PageLine> head, foot;
  final int shift;

  /// Whether its canvas draws the surface (a fill, with [radius] corners and,
  /// when [outlined], a hairline and a shadow); false: what is in it does.
  final bool surface, outlined;
  final num radius;

  /// Which of its lines close it after their actions: `all` (a menu's
  /// items), `nav` (a drawer's NavItems and Links) or `none`.
  final String closes;
}

class _Line {
  _Line(this.indent, this.frame, {required this.before, this.shift = 0, this.after});

  /// As written.
  final int indent;

  /// The frame this line is (Page, App, Section, Nav, Sidebar, Main, Pane), if one.
  final String? frame;

  /// How far this line itself was moved in, and how much further its
  /// children are (a frame of two lines holds them under the second).
  final int before, shift;

  /// A line written after its children, at its own level.
  final String? after;

  /// The table this line is (`Table … in …`), whose cells are the lines under it.
  _Table? table;

  /// A website's Nav: the links written in it (for its phone menu), and
  /// whether it writes a menu of its own.
  bool pageNav = false, ownMenu = false;

  /// A website's Section that holds its headline (a hero): its buttons are large.
  bool hero = false;
  ///
  /// Each is a link (a quiet button) or, with its [mark] (`.outline`, empty
  /// for a plain one), another labelled button of the bar.
  final links = <({String label, String action, _Line? group, bool direct, String? mark})>[];

  /// An `if` or an `each`: what is under it shows by a condition or is repeated.
  bool conditional = false;
}

/// The words of a line after its type, taken apart: `key=value` pairs
/// (events among them), bare words and strings, each where it was written,
/// and the `{…}` merged into the node at its end.
class _Parts {
  _Parts(String rest) {
    var i = 0;
    final s = rest;
    while (i < s.length) {
      if (s[i] == ' ') {
        i++;
        continue;
      }
      if (s[i] == '{') {
        tail = ' ${s.substring(i).trimRight()}';
        break;
      }
      final from = i;
      var depth = 0;
      String? quote;
      while (i < s.length) {
        final c = s[i];
        if (quote != null) {
          if (c == r'\') i++;
          if (c == quote) quote = null;
        } else if (c == '"' || c == "'") {
          quote = c;
        } else if (c == '[' || c == '{' || c == '(') {
          depth++;
        } else if (c == ']' || c == '}' || c == ')') {
          depth = math.max(0, depth - 1);
        } else if (c == ' ' && depth == 0) {
          break;
        }
        i++;
      }
      _tokens.add(s.substring(from, math.min(i, s.length)));
    }
  }

  final _tokens = <String>[];

  /// The `{…}` merged into the node, with the space before it ('' when none).
  String tail = '';

  static final _key = RegExp(r'^([A-Za-z][A-Za-z0-9_-]*)=');
  static final _event = RegExp(r'^(on[A-Z][A-Za-z]*)=\{([\s\S]*)\}$');

  /// Whether [key] is written with a value worked out (`key={…}`).
  bool bound(String key) => _tokens.any((t) => t.startsWith('$key={') && !t.startsWith('$key={"'));

  /// Whether the line says what its node does (an event).
  bool get hasEvent => _tokens.any(_event.hasMatch);

  /// The actions of what the node does (its onTap={…}, else the first event
  /// written), removed.
  String? takeEvent() {
    var i = _tokens.indexWhere((t) => t.startsWith('onTap={') && _event.hasMatch(t));
    if (i < 0) i = _tokens.indexWhere(_event.hasMatch);
    return i < 0 ? null : _event.firstMatch(_tokens.removeAt(i))![2]!.trim();
  }

  bool has(String key) => _tokens.any((t) => _key.firstMatch(t)?[1] == key);

  /// The value of `key=value`, left on the line.
  String? value(String key) {
    final i = _tokens.indexWhere((t) => _key.firstMatch(t)?[1] == key);
    return i < 0 ? null : _tokens[i].substring(key.length + 1);
  }

  /// The widths at which the line is narrower than a label has room for
  /// (`tablet.w=72`, `max900.w=64`): a sidebar is a rail there.
  List<String> get railWidths => [
        for (final t in _tokens)
          if (_railWidth.firstMatch(t) case final m? when (double.tryParse(m[2]!) ?? 999) < 120) m[1]!,
      ];

  static final _railWidth = RegExp(r'^([A-Za-z][A-Za-z0-9]*)\.w=([0-9.]+)$');

  /// Whether a border is written, on every side or on one.
  bool get hasBorder => _tokens.any((t) => _key.firstMatch(t)?[1]?.startsWith('border') ?? false);

  /// The value of `key=value`, removed from the line.
  String? take(String key) {
    final i = _tokens.indexWhere((t) => _key.firstMatch(t)?[1] == key);
    if (i < 0) return null;
    return _tokens.removeAt(i).substring(key.length + 1);
  }

  /// Whether the bare [word] is written.
  bool hasWord(String word) => _tokens.contains(word);

  /// Whether the bare [word] was written; it is removed.
  bool word(String word) => _tokens.remove(word);

  /// The words that match [pattern], removed, in order.
  List<String> takeMatching(RegExp pattern) {
    final found = [for (final t in _tokens) if (pattern.hasMatch(t)) t];
    _tokens.removeWhere(pattern.hasMatch);
    return found;
  }

  List<String> takeWords(Set<String> words) {
    final found = [for (final t in _tokens) if (words.contains(t)) t];
    _tokens.removeWhere(words.contains);
    return found;
  }

  /// The variable a line is bound to (`@at`, `value=@at`), removed.
  String? binding() {
    final i = _tokens.indexWhere((t) => RegExp(r'^(value=)?@[A-Za-z_][A-Za-z0-9_]*$').hasMatch(t));
    if (i < 0) return null;
    final t = _tokens.removeAt(i);
    return t.substring(t.indexOf('@') + 1);
  }

  /// The first string of the line, removed.
  String? string() {
    final i = _tokens.indexWhere((t) => t.startsWith('"'));
    return i < 0 ? null : _tokens.removeAt(i);
  }

  /// What is left, without the `{…}` at the end.
  String get props => _tokens.isEmpty ? '' : ' ${_tokens.join(' ')}';

  /// [props] without what they say of one width (`hide=phone`, `show=`,
  /// `tablet.w=64`, `phone.visible=…`).
  String get propsAtEveryWidth {
    final kept = [for (final t in _tokens) if (!_byWidth.hasMatch(t)) t];
    return kept.isEmpty ? '' : ' ${kept.join(' ')}';
  }

  static final _byWidth = RegExp(r'^(?:(?:hide|show)=|(?:phone|tablet|desktop|mobile|wide)\.)');

  /// What is left, as it was written.
  String get all {
    final s = '$props$tail';
    handedOut.add(s);
    return s;
  }

  /// What [all] gave the lines of the word being read (PageWords.rewrite:
  /// the writer's keys there win over the word's own).
  static final handedOut = <String>[];
}
