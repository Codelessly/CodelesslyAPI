// How a page written once, for a desktop, lays out on a tablet and a phone.
//
// The notation is written for one width (a page 1280 wide). Shown narrower,
// its rows squeeze: three cards across a phone, a table's fixed columns, a
// sidebar beside its content. [PageReflow] reads the expanded nodes and gives
// each one that would not fit the media rules that make it fit:
//
//   Grid cols=3            its rows wrap (cells take a least width); a
//                          grid of 7 columns (a week), of 5 or more small
//                          cells, or written keep, keeps its columns;
//                          a repeated cell that is a key (3+ columns)
//                          or a square of 64 or less (5+) is a board
//   Row of blocks          wraps: a card beside a card, content beside a rail
//   Row of controls        wraps on a phone (a search field, a select, buttons)
//   a table's row          its columns share the width; a phone keeps the
//                          first, the widest and the last
//   App                    a phone shows the main pane; a tablet drops the
//                          panes after it; the sidebar it hides opens as
//                          a drawer from a button in the main pane's bar
//   a list beside its detail  a phone shows one pane at a time ([ListDetail]):
//                          the list, the detail a row's tap opens, back
//   Nav                    a phone hides its links
//   Section                less padding above and below
//   a headline             smaller
//   a wide fixed box       as wide as its place, at most its width
//
// Every rule holds below a width (`maxWidth` 1023: a tablet and narrower;
// 699: a phone), so the page at the width it was written for is untouched.
//
// What the writer laid out by width is left as written ([_leftAsWritten]):
// a line with rules of its own (tablet.w=64, hide=phone) gets none of
// these over them, and a row is not wrapped when its line or a line right
// under it says what it does at another width, when it is an app's frame
// (it fills the height, or grows in a column), when it has a height of its
// own (a toolbar, a table's row), when it is a row of a list, when it sits
// in something of a fixed width a phone holds (a sidebar, a track's head)
// or in a row that scrolls sideways, or when it (or what holds it) is
// written `keep`.
import 'dart:math' as math;

import '../behaviors.dart' show mergePatch;
import '../json.dart';

/// The widest a phone is and the widest a tablet is, as the rules count them.
const int reflowPhoneMax = 699, reflowTabletMax = 1023;

/// A list beside its detail, which a phone shows one at a time: [levels]
/// from the first (a list of folders, if there is one) to the detail, each
/// shown alone while the page's state ([PageReflow.listDetailState]) holds
/// its index, at screens up to [below] wide (wider, side by side, as
/// written). It starts at [start], the list of the detail.
final class ListDetail {
  const ListDetail({required this.levels, required this.opens, required this.below, required this.app});

  final List<String> levels;

  /// The taps that select a row of a level, which then show the next level:
  /// the node, the index of its reaction, and the level they show.
  final List<({String node, int reaction, int level})> opens;

  /// The widest screen that shows one level at a time.
  final int below;

  /// Whether the levels are the panes of an `App` (else the two sides of a row).
  final bool app;

  int get start => levels.length - 2;
}

/// Works out the media rules of a page's nodes ([run]).
final class PageReflow {
  PageReflow({
    required this.nodes,
    this.roles = const {},
    this.gridRows = const {},
    this.keepColumns = const {},
    this.cards = const {},
    this.tableRows = const {},
    this.displaySizes = const {},
    this.isComponent = _no,
    this.fillsItsPlace = _no,
    this.listDetailState,
    this.variableStart = _none,
    this.kept = const {},
  });

  /// The nodes written `keep` (on a Grid: its columns hold): the reflow
  /// leaves each, and what is in it, as written.
  final Set<String> kept;

  /// The nodes whose lines say what they do at other widths (their own
  /// media rules, read before any is added): never reflowed over.
  late final Set<String> _own = {
    for (final e in nodes.entries)
      if ((e.value['media'] as List? ?? const []).isNotEmpty) e.key,
  };

  /// Whether [id] or what holds it is written `keep`.
  bool _underKept(String id) {
    for (String? k = id; k != null; k = _parents[k]) {
      if (kept.contains(k)) return true;
    }
    return false;
  }

  /// The widest a box that holds a row may be for the row to be as wide at
  /// every width: a phone holds it.
  static const num _phoneHolds = 400;

  /// Whether a row is an app's window of panes: it fills the height (or
  /// grows in a column), and beside the one pane that fills the room are
  /// panes of a fixed width (a sidebar, a list, an inspector).
  bool _frame(String id, Json n) {
    final h = _layout(n)['height'];
    final parent = _parents[id];
    final flex = _layout(n)['flex'];
    final tall = (h is Map && h.containsKey('fill')) || (parent != null && flex is num && flex > 0 && _type(nodes[parent]!) == 'column');
    if (!tall) return false;
    // The window itself: not a picture of one in a box of a set height, nor
    // a part of a page that scrolls.
    for (var p = parent; p != null; p = _parents[p]) {
      final holder = nodes[p]!;
      if (_layout(holder)['height'] is num || _props(holder)['scrollable'] == true) return false;
    }
    final kids = _kids(n);
    var fixed = 0, fills = 0;
    for (final k in kids) {
      final kid = nodes[k]!;
      final type = _type(kid);
      if (const {'splitter', 'divider', 'verticalDivider'}.contains(type)) continue;
      final w = _fixedWidth(kid);
      final pane = _containers.contains(type) || isComponent(type);
      if (w != null || (readMap(kid['bind'])?.containsKey('layout.width') ?? false)) {
        if (pane && (w == null || w >= 120)) fixed++;
      } else if (_fills(kid)) {
        fills++;
      }
    }
    return fixed >= 1 && fills == 1;
  }

  /// Whether a row is the writer's to lay out at other widths, so that it
  /// is not wrapped nor its parts given shares ([list]: a row of a list is
  /// too). See the head of this file.
  bool _leftAsWritten(String id, {bool list = false, bool ownKids = true}) {
    if (_underKept(id) || _own.contains(id)) return true;
    final n = nodes[id]!;
    if (ownKids && _kids(n).any(_own.contains)) return true;
    // An app's frame or a bar: a height of its own, the room left in a column.
    final h = _layout(n)['height'];
    if (h is num || (h is Map && h.containsKey('fill')) || (readMap(n['bind'])?.containsKey('layout.height') ?? false)) return true;
    final parent = _parents[id];
    final flex = _layout(n)['flex'];
    if (parent != null && flex is num && flex > 0 && _type(nodes[parent]!) == 'column') return true;
    for (var p = parent; p != null; p = _parents[p]) {
      final holder = nodes[p]!;
      final w = _fixedWidth(holder);
      if (w != null && w <= _phoneHolds) return true;
      if (_type(holder) == 'row' && _props(holder)['scrollable'] == true) return true;
      if (list && (_type(holder) == 'listView' || readMap(holder['bind'])?['data'] != null)) return true;
    }
    return false;
  }

  static bool _no(String _) => false;
  static Object? _none(String _) => null;

  /// The value a page variable starts at.
  final Object? Function(String name) variableStart;

  /// The page variable that says which level of a list beside its detail a
  /// phone shows ([ListDetail]); null: such panes are left as written.
  final String? listDetailState;

  /// The list beside its detail the page has, once [run] found it.
  ListDetail? listDetail;

  /// The page's nodes by id, each with its `children`.
  final Map<String, Json> nodes;

  /// The frames among them: `app`, `nav`, `section`, `sidebar`, `main`, `pane`.
  final Map<String, String> roles;

  /// A `Grid`'s rows: how many columns the grid has and the space between.
  final Map<String, ({int cols, num gap})> gridRows;

  /// The grids (their rows, or their list) written `keep`.
  final Set<String> keepColumns;

  /// The nodes written as `Card`.
  final Set<String> cards;

  /// The rows whose fixed columns were already made shares of the row.
  final Set<String> tableRows;

  /// A theme's text styles of a headline's size, by name → font size.
  final Map<String, num> displaySizes;

  /// Whether a type is a design system's component, and whether a
  /// component is as wide as its place.
  final bool Function(String type) isComponent, fillsItsPlace;

  final _rules = <String, Map<int, Json>>{};
  final _handled = <String>{};

  void _add(String id, int max, Json patch, {bool force = false}) {
    if (!force && (_own.contains(id) || _underKept(id))) return;
    final at = _rules.putIfAbsent(id, () => {});
    at[max] = at[max] == null ? patch : mergePatch(at[max]!, patch, keepNulls: true);
  }

  void _hide(String id, int max) {
    // A line that says where it shows (show=phone, hide=tablet) is left to
    // what it says: a link a Nav would hide, written show=phone, shows.
    if (nodes[id]?['media'] != null) return;
    final bound = readMap(nodes[id]?['bind'])?.containsKey('visible') ?? false;
    _add(id, max, {
      'visible': false,
      if (bound) 'bind': {'visible': null},
    });
  }

  Json _layout(Json n) => readMap(n['layout']) ?? const {};
  Json _props(Json n) => readMap(n['props']) ?? const {};
  String _type(Json n) => n['type'] as String? ?? '';

  List<String> _kids(Json n) => [
        for (final c in (n['children'] as List? ?? const []))
          if (c is String && nodes.containsKey(c)) c,
      ];

  num? _fixedWidth(Json n) {
    if (readMap(n['bind'])?.containsKey('layout.width') ?? false) return null;
    final w = _layout(n)['width'];
    return w is num && w > 0 ? w : null;
  }

  bool _fills(Json n) {
    final l = _layout(n);
    final w = l['width'], f = l['flex'];
    return (f is num && f > 0) || (w is Map && w.containsKey('fill'));
  }

  static const _containers = {'column', 'row', 'flex', 'stack', 'listView', 'gridView', 'pageView', 'tabs', 'accordion'};
  static const _fields = {'textField', 'dropdown', 'segmentedButton', 'datePicker', 'slider'};

  bool _isMedia(String type) => type == 'image' || type == 'video' || type == 'map' || type == 'customPaint' || type.endsWith('Chart');

  /// How many nodes are under [id], itself included (up to [cap]).
  int _weight(String id, [int cap = 6]) {
    var n = 1;
    for (final c in _kids(nodes[id]!)) {
      if (n >= cap) break;
      n += _weight(c, cap - n);
    }
    return n;
  }

  /// A child that is a part of the page of its own (a card, a column of
  /// content, a picture, a list), not a control or a label of its row.
  ({bool fixed, bool grows, num width, bool light})? _block(String id) {
    final n = nodes[id]!;
    final type = _type(n);
    final component = isComponent(type);
    final container = _containers.contains(type) || component;
    final w = _fixedWidth(n);
    if (w != null) return w >= 120 && (container || _isMedia(type)) ? (fixed: true, grows: false, width: w, light: false) : null;
    final grows = _fills(n);
    if (cards.contains(id)) return (fixed: false, grows: grows, width: 0, light: false);
    // A column as wide as its content with a list of things in it (a side
    // navigation written with no width) is a block at its own size.
    if (!grows) return container && !component && _weight(id, 8) >= 8 ? (fixed: false, grows: false, width: 0, light: false) : null;
    if (component) return fillsItsPlace(type) ? (fixed: false, grows: true, width: 0, light: false) : null;
    if (_isMedia(type)) return (fixed: false, grows: true, width: 0, light: false);
    if (container && _weight(id) >= 4) return (fixed: false, grows: true, width: 0, light: false);
    // A heading and its paragraph: a column of content beside another such
    // column, but a label's two lines beside a picture or a button.
    if (container && _weight(id) == 3) return (fixed: false, grows: true, width: 0, light: true);
    return null;
  }

  /// A control with several choices (a segmented filter, chips) needs room
  /// for them even when it fills its place: a row of such controls would
  /// otherwise divide a tablet into cells too narrow for their labels.
  num _choiceBasis(Json n, num basis) {
    final options = _props(n)['options'];
    return options is List && options.length >= 2 ? math.max(basis, math.min(400, options.length * 100)) : basis;
  }

  /// The media rules to add, by node id: the widest first, so a phone's
  /// rule wins over a tablet's.
  Map<String, List<Json>> run() {
    final found = listDetailState == null ? null : _findListDetail();
    _levels = {...?found?.levels};
    for (final e in roles.entries) {
      final n = nodes[e.key];
      if (n == null) continue;
      switch (e.value) {
        case 'app':
          _app(e.key, n);
        case 'nav':
          _nav(e.key, n);
        case 'section':
          _section(e.key, n);
        case 'appmenu':
          _appMenu(e.key, n);
      }
    }
    if (found != null) _listDetailRules(found);
    for (final e in roles.entries) {
      if (e.value == 'nav' && nodes[e.key] != null) _navOnTablet(e.key, nodes[e.key]!);
    }
    for (final e in nodes.entries) {
      if (_type(e.value) == 'row' && !_handled.contains(e.key)) _stacksWhereAChildFills(e.key, e.value);
    }
    for (final e in nodes.entries) {
      final id = e.key, n = e.value;
      final type = _type(n);
      if (type == 'row' && !_handled.contains(id) && roles[id] != 'app' && _frame(id, n)) {
        // A window of panes written as a Row, with no width rules in it: as an `App`.
        if (!_underKept(id) && !_own.contains(id) && !_kids(n).any(_own.contains)) _app(id, n);
      } else if (type == 'row' && !_handled.contains(id) && !_leftAsWritten(id)) {
        if (gridRows[id] case final g?) {
          _gridRow(id, n, g);
        } else if (_props(n)['scrollable'] != true && _props(n)['wrap'] != true) {
          if (!_tableRow(id, n) && roles[id] != 'app') _row(id, n);
        }
      } else if (type == 'row' && !_handled.contains(id) && !_leftAsWritten(id, list: true, ownKids: false) && roles[id] != 'app') {
        // A row the writer laid out by width in part (a field narrower on
        // a tablet, a menu button shown on a phone) that still has no room
        // on a phone.
        _crowded(id, n);
      }
      if (type == 'gridView') _gridView(id, n);
      if (type == 'text') _headline(id, n);
    }
    for (final e in nodes.entries) {
      _wideBox(e.key, e.value);
    }
    return {
      for (final e in _rules.entries)
        e.key: [
          for (final max in e.value.keys.toList()..sort((a, b) => b.compareTo(a))) {'maxWidth': max, 'patch': e.value[max]},
        ],
    };
  }

  /// A node's own rules that hold at a screen [max] wide (those for that
  /// width or a wider one), the widest first, as they are applied.
  Iterable<Json> _ownRulesAt(Json n, int max) sync* {
    final rules = [
      for (final r in (n['media'] as List? ?? const []))
        if (readMap(r) case final Json rule when rule['maxWidth'] is num && (rule['maxWidth'] as num) >= max && rule['minWidth'] == null) rule,
    ]..sort((a, b) => (b['maxWidth'] as num).compareTo(a['maxWidth'] as num));
    for (final r in rules) {
      if (readMap(r['patch']) case final Json patch) yield patch;
    }
  }

  /// A row whose child is written as wide as its place at a narrower width
  /// (`Column w=345 phone.w=fill`, `Select w=180 phone.w=fill`): a child as
  /// wide as the row leaves no room beside it, so the row is laid out down
  /// the page there. Each such child, and each that grows, takes a line of
  /// its own; what is neither (a button, a count) shares a line. A row that
  /// says its own wrap or direction there, has a height of its own, scrolls,
  /// or is written `keep` is left as written.
  void _stacksWhereAChildFills(String id, Json n) {
    if (_props(n)['wrap'] == true || _props(n)['scrollable'] == true || _layout(n)['height'] is num || kept.contains(id) || gridRows.containsKey(id)) return;
    final kids = _kids(n);
    if (kids.length < 2) return;
    // (A share of the row said with it, `phone.grow`, is a place beside the others.)
    bool fillsAt(Json kid, int max) {
      Object? w;
      var shares = false;
      for (final p in _ownRulesAt(kid, max)) {
        final l = readMap(p['layout']);
        if (l != null && l.containsKey('width')) w = l['width'];
        if (l != null && l['flex'] != null) shares = true;
      }
      return !shares && w is Map && w.containsKey('fill');
    }

    final widths = <int>{
      for (final k in kids)
        if (_layout(nodes[k]!)['width'] case final Object? base when !(base is Map && base.containsKey('fill')))
          for (final r in (nodes[k]!['media'] as List? ?? const []))
            if (readMap(r) case final Json rule when rule['maxWidth'] is num && rule['minWidth'] == null && fillsAt(nodes[k]!, (rule['maxWidth'] as num).toInt()))
              if (readMap(readMap(rule['patch'])?['layout'])?['width'] case final Map w when w.containsKey('fill')) (rule['maxWidth'] as num).toInt(),
    };
    for (final max in widths) {
      // What the row says of itself there.
      num spacing = _spacing(n);
      var own = false;
      for (final p in _ownRulesAt(n, max)) {
        final props = readMap(p['props']);
        if (props == null) continue;
        if (props['spacing'] case final num s) spacing = s;
        if (props.containsKey('wrap') || props.containsKey('direction')) own = true;
      }
      if (own) continue;
      _add(force: true, id, max, {
        'props': {'wrap': true, 'runSpacing': spacing},
      });
      for (final k in kids) {
        final kid = nodes[k]!;
        if (_type(kid) == 'spacer') {
          if (kid['media'] == null) _add(force: true, k, max, {'visible': false});
        } else if (fillsAt(kid, max) || (_fills(kid) && _fixedWidthAt(kid, max) == null)) {
          _add(force: true, k, max, {
            'layout': {
              'width': {'fill': 0},
              'basis': max,
              'flex': 1,
              if (_layout(kid)['height'] case final Map h when h.containsKey('fill')) 'height': {'fill': null, 'hug': 0},
            },
          });
          _handled.add(k);
        }
      }
      _handled.add(id);
    }
  }

  /// The fixed width a node's own rules give it at a screen [max] wide.
  num? _fixedWidthAt(Json n, int max) {
    Object? w = _fixedWidth(n);
    for (final p in _ownRulesAt(n, max)) {
      final l = readMap(p['layout']);
      if (l != null && l.containsKey('width')) w = l['width'];
    }
    return w is num && w > 0 ? w : null;
  }

  /// An app's window: its main pane is what a phone shows; a tablet keeps
  /// the panes before it (the navigation, a list) while they leave it room.
  void _app(String id, Json n) {
    final kids = _kids(n);
    var main = kids.indexWhere((k) => roles[k] == 'main');
    if (main < 0) main = kids.indexWhere((k) => !_sized(k) && _fills(nodes[k]!));
    if (main < 0) return;
    // (A pane whose width is kept in a variable, `Sidebar w={sidebarWidth}`
    // that a splitter sizes, is a pane of that width: it stayed on a phone.)
    final before = [
      for (var i = 0; i < main; i++)
        if (_sized(kids[i])) kids[i],
    ];
    for (var i = main + 1; i < kids.length; i++) {
      if (_sized(kids[i])) _hide(kids[i], reflowTabletMax);
    }
    num taken = 0;
    for (final k in before) {
      taken += _paneWidth(nodes[k]!);
    }
    // Two panes before the main one (a sidebar and a list): a tablet keeps the nearer.
    if (before.length >= 2 && taken > 420 && !_levels.contains(before.first)) _hide(before.first, reflowTabletMax);
    // A list beside its detail shows on a phone by turns ([ListDetail]).
    for (final k in before) {
      if (!_levels.contains(k)) _hide(k, reflowPhoneMax);
    }
    // A Main of a fixed width (a list) before the pane that takes the room
    // left, with no taps that select what it shows: a phone shows the list
    // alone, as wide as the window.
    final detail = _detailAfter(kids, main);
    if (detail != null && !_levels.contains(kids[main])) {
      _add(kids[main], reflowPhoneMax, {'layout': {'width': {'fill': 0}, 'flex': 1}});
      _hide(detail, reflowPhoneMax);
    }
  }

  // A list beside its detail.

  /// The panes of the list beside its detail the page has ([ListDetail.levels]).
  Set<String> _levels = const {};

  /// The least width a detail is shown at beside its list.
  static const num _detailLeast = 360;

  /// What reads a page's values in a node: the names in its expressions.
  static final _identifier = RegExp(r'(?<![.\w$])([A-Za-z_]\w*)');
  static final _quoted = RegExp(r'"(?:[^"\\]|\\.)*"' r"|'(?:[^'\\]|\\.)*'");

  /// The names the expressions (`${= …}`, `${name}`) in [v] read.
  static Set<String> _names(Object? v, [Set<String>? into]) {
    final out = into ?? <String>{};
    if (v is String) {
      for (var at = v.indexOf(r'${'); at >= 0; at = v.indexOf(r'${', at)) {
        var depth = 0, end = at + 1;
        for (; end < v.length; end++) {
          if (v[end] == '{') depth++;
          if (v[end] == '}' && --depth == 0) break;
        }
        final body = v.substring(at + 2, math.min(end, v.length)).replaceAll(_quoted, '');
        out.addAll(_identifier.allMatches(body).map((m) => m[1]!));
        at = end;
      }
    } else if (v is Map) {
      for (final e in v.entries) {
        if (e.key != 'children') _names(e.value, out);
      }
    } else if (v is List) {
      for (final e in v) {
        _names(e, out);
      }
    }
    return out;
  }

  /// A node's children and the nodes in its slots (a tile's trailing).
  List<String> _inside(Json n) => [
        ..._kids(n),
        for (final s in (readMap(n['slots']) ?? const {}).values)
          if (s is String && nodes.containsKey(s)) s,
      ];

  /// The names read under [id], itself included ([actions]: in what its
  /// reactions do too), and the names the lists under it are drawn from.
  ({Set<String> all, Set<String> data}) _reads(String id, {bool actions = true}) {
    final all = <String>{}, data = <String>{};
    void walk(String k) {
      final n = nodes[k];
      if (n == null) return;
      for (final e in n.entries) {
        if (e.key == 'children' || e.key == 'slots' || (!actions && e.key == 'actions')) continue;
        _names(e.value, all);
      }
      _names(readMap(n['bind'])?['data'], data);
      _inside(n).forEach(walk);
    }

    walk(id);
    return (all: all, data: data);
  }

  /// What a row of a list is not: a control of its own, or a button.
  static const _notARow = {'checkbox', 'switch', 'radio', 'textField', 'slider', 'dropdown', 'segmentedButton', 'chip', 'filterChip', 'choiceChip'};

  /// A component's events that are its tap.
  static const _tapEvents = {'onTap', 'onPressed', 'onPress', 'onClick', 'onSelect', 'onSelected', 'onOpen'};

  /// The taps in [pane] that select what [next] shows: a tap reaction of a
  /// row (not a button or a control of its own) that sets a page value and
  /// opens nothing over the page nor goes to another. Under an `each`, the
  /// value is read from the row's item (`sel=m.id`), is not the list the
  /// rows are drawn from (a star a tap toggles), and [next] or the pane
  /// reads it (the open row marked); elsewhere (a sidebar's item written line by
  /// line) it is a text or a number [next] reads. A value that reads itself
  /// (a toggle, a selection a tap adds to) is not a choice of one.
  List<({String node, int reaction})> _selects(String pane, String next) {
    final shown = _reads(next).all;
    final own = _reads(pane, actions: false);
    final out = <({String node, int reaction})>[];
    void walk(String id, String? list) {
      final n = nodes[id];
      if (n == null) return;
      final type = _type(n);
      final rows = readMap(n['bind'])?['data'] != null ? id : list;
      final reactions = n['actions'];
      if (reactions is List && !_notARow.contains(type) && !type.endsWith('Button')) {
        for (var i = 0; i < reactions.length; i++) {
          final r = readMap(reactions[i]);
          final trigger = readMap(r?['trigger']);
          if (trigger == null || !(trigger['type'] == 'click' || (trigger['type'] == 'event' && _tapEvents.contains(trigger['event'])))) continue;
          final actions = readList(r!['actions']) ?? const [];
          if (actions.any((a) => a is Map && const {'navigate', 'openModal', 'openLink'}.contains(a['type']))) continue;
          final picks = actions.any((a) {
            if (a is! Map || a['type'] != 'setVariable') return false;
            final name = a['variable'], value = a['value'];
            if (name is! String || name == listDetailState || own.data.contains(name)) return false;
            final reads = _names(value);
            if (reads.contains(name)) return false;
            if (rows != null) {
              return (reads.contains('item') || reads.contains('index')) && (shown.contains(name) || own.all.contains(name));
            }
            // A text or a number (`${= 2}`); true and false read as names.
            return (value is num || (value is String && reads.isEmpty && value != 'true' && value != 'false')) && shown.contains(name);
          });
          if (picks) {
            out.add((node: id, reaction: i));
            break;
          }
        }
      }
      for (final k in _inside(n)) {
        walk(k, rows);
      }
    }

    walk(pane, null);
    return out;
  }

  /// Whether a node says itself where it shows (show=phone, a bound
  /// visibility): the writer laid it out by size, so it is left as written.
  bool _placesItself(String id) {
    final n = nodes[id]!;
    if (readMap(n['bind'])?.containsKey('visible') ?? false) return true;
    return (n['media'] as List? ?? const []).any((r) {
      final p = readMap(readMap(r)?['patch']);
      return p != null && (p.containsKey('visible') || (readMap(p['bind'])?.containsKey('visible') ?? false));
    });
  }

  /// Whether a pane has a width of its own: written, or kept in a variable.
  bool _sized(String k) {
    final n = nodes[k]!;
    if (_fixedWidth(n) != null) return true;
    final type = _type(n);
    return (readMap(n['bind'])?.containsKey('layout.width') ?? false) && (_containers.contains(type) || isComponent(type));
  }

  /// A pane's width: as written, or the value it is bound to starts at (a
  /// list a splitter sizes, `w={listW}`).
  num _paneWidth(Json n) {
    if (_fixedWidth(n) case final num w) return w;
    final bound = readMap(n['bind'])?['layout.width'];
    final match = bound is String ? RegExp(r'^\$\{\s*([A-Za-z_]\w*)\s*\}$').firstMatch(bound) : null;
    final name = match?[1];
    return switch (name == null ? null : variableStart(name)) { final num w when w > 0 => w, _ => 300 };
  }

  /// The page's list beside its detail: in an `App`, `Main` and the `Pane`s
  /// just before it, each selecting what the next shows; else, in an app,
  /// a row of a column of a fixed width (at least 200) that selects what the
  /// one that grows beside it shows (a `Splitter` between them).
  ListDetail? _findListDetail() {
    final apps = [
      for (final e in roles.entries)
        if (e.value == 'app' && nodes.containsKey(e.key)) e.key,
    ];
    if (apps.isEmpty) return null;
    for (final app in apps) {
      final kids = _kids(nodes[app]!);
      final main = kids.indexWhere((k) => roles[k] == 'main');
      if (main < 0 || _placesItself(kids[main])) continue;
      // A list written as `Main w=380` beside the `Pane` that shows what it
      // selects (Desk's mail): at a phone's width Main kept its 380 and the
      // reading pane was 10 wide (track C).
      final detail = _detailAfter(kids, main);
      if (detail != null) {
        final s = _selects(kids[main], detail);
        if (s.isNotEmpty) {
          num need = _detailLeast + _fixedWidth(nodes[kids[main]]!)!;
          for (final k in kids.take(main)) {
            if (_fixedWidth(nodes[k]!) != null && !_hiddenAtTablet(k, app)) need += _tabletWidth(k);
          }
          return _listDetail([kids[main], detail], [s], need, app: true);
        }
      }
      final levels = [kids[main]];
      final taps = <List<({String node, int reaction})>>[];
      for (var i = main - 1; i >= 0; i--) {
        final k = kids[i];
        if (roles[k] != 'pane' || _fixedWidth(nodes[k]!) == null || _placesItself(k)) break;
        final s = _selects(k, levels.first);
        if (s.isEmpty) break;
        levels.insert(0, k);
        taps.insert(0, s);
      }
      if (levels.length < 2) continue;
      num need = _detailLeast;
      for (final k in levels.take(levels.length - 1)) {
        need += _paneWidth(nodes[k]!);
      }
      // What a tablet keeps beside them (a sidebar, where there is room for one).
      for (final k in kids.take(main)) {
        if (!levels.contains(k) && _fixedWidth(nodes[k]!) != null && !_hiddenAtTablet(k, app)) need += _fixedWidth(nodes[k]!)!;
      }
      return _listDetail(levels, taps, need, app: true);
    }
    for (final e in nodes.entries) {
      final n = e.value;
      if (_type(n) != 'row' || roles[e.key] == 'app' || _props(n)['wrap'] == true || _props(n)['scrollable'] == true) continue;
      final kids = _kids(n);
      final sides = [
        for (final k in kids)
          if (!const {'splitter', 'divider', 'verticalDivider'}.contains(_type(nodes[k]!))) k,
      ];
      if (sides.length != 2) continue;
      final list = nodes[sides.first]!, detail = nodes[sides.last]!;
      final boundWidth = readMap(list['bind'])?.containsKey('layout.width') ?? false;
      if (!_containers.contains(_type(list)) || !_containers.contains(_type(detail))) continue;
      if ((_fixedWidth(list) == null && !boundWidth) || _paneWidth(list) < 200) continue;
      if (_fixedWidth(detail) != null || !_fills(detail)) continue;
      if (_placesItself(sides.first) || _placesItself(sides.last)) continue;
      final s = _selects(sides.first, sides.last);
      if (s.isEmpty) continue;
      // Its sides, what stands between them and what is beside the row
      // (a sidebar a tablet keeps, the padding around it).
      num need = _detailLeast + _paneWidth(list) + _spacing(n) * (kids.length - 1);
      for (final k in kids) {
        if (!sides.contains(k)) need += _fixedWidth(nodes[k]!) ?? 8;
      }
      for (var (child, p) = (e.key, _parents[e.key]); p != null; child = p, p = _parents[p]) {
        final parent = nodes[p]!;
        need += _sidesPadding(parent);
        if (_type(parent) != 'row') continue;
        for (final k in _kids(parent)) {
          if (k != child && _rules[k]?[reflowTabletMax]?['visible'] != false && !_hiddenAtTablet(k, p)) need += _fixedWidth(nodes[k]!) ?? 0;
        }
      }
      _rowSplit = e.key;
      return _listDetail(sides, [s], need, app: false);
    }
    return null;
  }

  /// The pane after an app's `Main` of a fixed width (a list) that takes
  /// the room left (what the list shows), when nothing between them and
  /// neither says where it shows.
  String? _detailAfter(List<String> kids, int main) {
    if (_fixedWidth(nodes[kids[main]]!) == null || main + 1 >= kids.length) return null;
    final next = kids[main + 1];
    final n = nodes[next]!;
    if (roles[next] != 'pane' || _fixedWidth(n) != null || !_fills(n) || _placesItself(next)) return null;
    return next;
  }

  /// A pane's width at a tablet's: its own rule there (a rail's
  /// `tablet.w=64`), else as written.
  num _tabletWidth(String k) {
    for (final r in (nodes[k]!['media'] as List? ?? const [])) {
      final rule = readMap(r);
      final w = readMap(readMap(rule?['patch'])?['layout'])?['width'];
      if (rule?['maxWidth'] case final num max when max >= reflowTabletMax && w is num) return w;
    }
    return _fixedWidth(nodes[k]!) ?? 0;
  }

  /// The row a list and its detail share, when they are not an app's panes.
  String? _rowSplit;

  num _spacing(Json n) => switch (_props(n)['spacing']) { final num s => s, _ => 0 };

  num _sidesPadding(Json n) => switch (_layout(n)['padding']) {
        final num p => p * 2,
        final List p when p.length == 4 && p[0] is num && p[2] is num => (p[0] as num) + (p[2] as num),
        _ => 0,
      };

  /// A tablet's width as the rules count it (the middle of 700 to 1023).
  static const num _tabletWide = 834;

  /// About the width [id] is given on a tablet: the window's, less the
  /// padding of what holds it and what is beside it of a width of its own
  /// (a sidebar, a rail, a summary of a fixed width in its row) that a
  /// tablet still shows, and no more than a width or a most-width above it.
  num _tabletRoom(String id) {
    num room = _tabletWide;
    String at = id;
    for (var p = _parents[id]; p != null; at = p, p = _parents[p]) {
      final holder = nodes[p]!;
      if (_fixedWidth(holder) case final num w) room = math.min(room, w);
      if (readMap(_layout(holder)['constraints'])?['maxWidth'] case final num most) room = math.min(room, most);
      room -= _sidesPadding(holder);
      if (_type(holder) != 'row') continue;
      for (final k in _kids(holder)) {
        if (k == at) continue;
        if (_rules[k]?[reflowTabletMax]?['visible'] == false || _hiddenAtTablet(k, p) || nodes[k]!['visible'] == false) continue;
        final w = _tabletWidth(k);
        if (w > 0) room -= w + _spacing(holder);
      }
    }
    return math.max(0, room);
  }

  /// A bar that has no room for its line on a tablet (a brand, four links,
  /// a select and two buttons beside a sidebar: its right group ran 41 to 65
  /// px past the window's edge, test 17) wraps there: what does not fit goes
  /// to a second line, nothing is hidden. A bar that says what it does
  /// there, or whose links a tablet hides, is left.
  void _navOnTablet(String id, Json n) {
    if (_type(n) != 'row' || _own.contains(id) || _underKept(id) || _props(n)['wrap'] == true) return;
    if (_rules[id]?[reflowTabletMax]?['props'] case final Map p when p.containsKey('wrap')) return;
    final shown = [
      for (final k in _kids(n))
        if (_rules[k]?[reflowTabletMax]?['visible'] != false && _need(k) > 0) k,
    ];
    if (shown.length < 2) return;
    final need = _sidesPadding(n) + _spacing(n) * (shown.length - 1) + shown.fold<num>(0, (s, k) => s + _need(k));
    if (need <= _tabletRoom(id)) return;
    _add(id, reflowTabletMax, {
      'props': {'wrap': true, 'runSpacing': 8},
    });
  }

  /// Whether an app's pane [k] is one a tablet hides, as [_app] decides it.
  bool _hiddenAtTablet(String k, String parent) {
    if (roles[parent] != 'app') return false;
    final kids = _kids(nodes[parent]!);
    final main = kids.indexWhere((x) => roles[x] == 'main');
    final at = kids.indexOf(k);
    if (main < 0 || at < 0) return false;
    if (at > main) return _sized(k);
    final before = [
      for (var i = 0; i < main; i++)
        if (_sized(kids[i])) kids[i],
    ];
    num taken = 0;
    for (final b in before) {
      taken += _paneWidth(nodes[b]!);
    }
    return before.length >= 2 && taken > 420 && before.first == k;
  }

  ListDetail _listDetail(List<String> levels, List<List<({String node, int reaction})>> taps, num need, {required bool app}) => ListDetail(
        levels: levels,
        opens: [
          for (var i = 0; i < taps.length; i++)
            for (final t in taps[i]) (node: t.node, reaction: t.reaction, level: i + 1),
        ],
        below: (need - 1).clamp(reflowPhoneMax, reflowTabletMax).floor(),
        app: app,
      );

  /// Where one level shows at a time, each fills the room the frame gives
  /// it, while the page's state holds its index; a splitter between them goes.
  void _listDetailRules(ListDetail ld) {
    listDetail = ld;
    final state = listDetailState!;
    for (var i = 0; i < ld.levels.length; i++) {
      final id = ld.levels[i];
      final n = nodes[id]!;
      final last = i == ld.levels.length - 1;
      final boundWidth = readMap(n['bind'])?.containsKey('layout.width') ?? false;
      // A pane's rule at its side has nothing beside it to rule off there.
      final ruled = readMap(n['decoration'])?['strokeSides'] == 'right';
      _add(force: true, id, ld.below, {
        if (!last) 'layout': {'width': {'fill': 0}, 'flex': 1},
        if (!last && ruled) 'decoration': {'strokes': <Object?>[]},
        'bind': {
          'visible': '\${= $state==$i}',
          if (boundWidth && !last) 'layout.width': null,
          // The animation the notation gives a pane with none of its own
          // plays as the pane takes another's place.
          if (n['animations'] == null) ...{
            'animations[0].enabled': r'${= true}',
            'animations[0].playKey': '\${= $state==$i ? "shown" : ""}',
          },
        },
      });
      _handled.add(id);
    }
    if (_rowSplit case final String row) {
      _handled.add(row);
      for (final k in _kids(nodes[row]!)) {
        if (!ld.levels.contains(k)) _hide(k, ld.below);
      }
    }
  }

  /// A bar across the top: a phone keeps the brand and the buttons.
  void _nav(String id, Json n) {
    bool link(String k) => _type(nodes[k]!) == 'textButton';
    var links = 0;
    final hide = <String>[];
    for (final k in _kids(n)) {
      final kid = nodes[k]!;
      if (link(k)) {
        links++;
        hide.add(k);
      } else if (_type(kid) == 'row') {
        final inner = _kids(kid);
        final own = inner.where(link).length;
        // …unless one of them says where it shows: then each goes by itself.
        if (own >= 2 && own == inner.length && inner.every((k) => nodes[k]!['media'] == null)) {
          links += own;
          hide.add(k);
        } else if (own >= 2) {
          // Links beside a button in one row: the links go, the button stays.
          links += own;
          hide.addAll(inner.where(link));
        }
      }
    }
    // A phone's bar is tighter: the brand, the buttons and the menu button on one line.
    _add(id, reflowPhoneMax, {'props': {'spacing': 12}});
    if (_parents[id] case final String band) {
      final pad = _layout(nodes[band]!)['padding'];
      if (pad is List && pad.length == 4 && pad.every((v) => v is num) && (pad[0] as num) > 16) {
        _add(band, reflowPhoneMax, {'layout': {'padding': [16, pad[1], 16, pad[3]]}});
      }
    }
    final band = _parents[id];
    final pageBar = band != null && roles[band] == null && _type(nodes[band]!) == 'column' && _kids(nodes[band]!).firstOrNull == id;
    final kids = _kids(n);
    if (links == 0) return;
    final width = links >= 6 ? reflowTabletMax : reflowPhoneMax;
    for (final k in hide) {
      _hide(k, width);
    }
    // Where its links are in its menu (the button the bar ends with, which
    // opens it), its other labelled buttons are too.
    final menu = kids.isNotEmpty && _type(nodes[kids.last]!) == 'iconButton' && '${nodes[kids.last]!['actions']}'.contains('navMenu');
    if (!pageBar || !menu) return;
    // Its brand, its icon buttons and the menu button are one line there:
    // the bar does not wrap where its links are in its menu.
    if (!_own.contains(id) && !_underKept(id)) _add(id, width, {'props': {'wrap': false}});
    final buttons = <String>[];
    void find(String k) {
      final kid = nodes[k]!;
      final type = _type(kid);
      if (const {'filledButton', 'outlinedButton', 'elevatedButton'}.contains(type)) {
        final label = _props(kid)['label'];
        final bound = readMap(kid['bind'])?.containsKey('visible') ?? false;
        if (label is String && label.isNotEmpty && kid['actions'] is List && kid['media'] == null && !bound) buttons.add(k);
        return;
      }
      if (readMap(kid['bind'])?.containsKey('visible') ?? false) return;
      _kids(kid).forEach(find);
    }

    kids.forEach(find);
    if (buttons.isEmpty) return;
    // …where they have no room beside the brand and the menu button on a
    // phone (about what the line needs, with a margin: a wordmark is wider
    // than its letters count). Where they have, they stay in the bar (a
    // short brand and its one call to action), and the menu has the links.
    final shown = [for (final k in kids) if (_need(k) > 0) k];
    final need = shown.fold<num>(0, (sum, k) => sum + _need(k)) + 12 * math.max(0, shown.length - 1);
    final folds = width != reflowPhoneMax || need > 340;
    if (folds) {
      for (final k in buttons) {
        _hide(k, width);
      }
      return;
    }
    // The menu's copies of them are not shown.
    final menuColumn = _kids(nodes[band]!).skip(1).firstOrNull;
    for (final row in menuColumn == null ? const <String>[] : _kids(nodes[menuColumn]!)) {
      final first = _kids(nodes[row]!).firstOrNull;
      if (first != null && const {'filledButton', 'outlinedButton', 'elevatedButton'}.contains(_type(nodes[first]!))) _hide(row, width);
    }
  }

  /// The button that opens an app's sidebar where the window hides it: what
  /// follows it in the bar (the page's title) takes the room beside it there,
  /// so the two sit together at the bar's start and the actions at its end.
  /// A bar of the title alone too: its title went to the bar's far end,
  /// away from the button (track C).
  void _appMenu(String id, Json n) {
    final bar = _parents[id];
    if (bar == null) return;
    final kids = _kids(nodes[bar]!);
    if (kids.length < 2 || kids.first != id) return;
    final next = nodes[kids[1]]!;
    if (_fixedWidth(next) != null || _fills(next)) return;
    final from = (n['media'] as List? ?? const []).map((r) => r is Map ? r['minWidth'] : null).whereType<num>().firstOrNull;
    _add(kids[1], from == null ? reflowPhoneMax : from.toInt() - 1, {
      'layout': {'width': {'fill': 0}, 'flex': 1, 'basis': 96},
    });
  }

  void _section(String id, Json n) {
    final pad = _layout(n)['padding'];
    if (pad is! List || pad.length != 4 || pad.any((v) => v is! num)) return;
    final p = pad.cast<num>();
    List<num> capped(num side, num band) => [math.min(p[0], side), math.min(p[1], band), math.min(p[2], side), math.min(p[3], band)];
    // A compact band has half a section's room above and below: on a phone too.
    final tablet = capped(p[0], 48), phone = capped(20, p[1] <= 48 && p[3] <= 48 ? 24 : 40);
    if (!jsonEquality.equals(tablet, p)) _add(id, reflowTabletMax, {'layout': {'padding': tablet}});
    if (!jsonEquality.equals(phone, p)) _add(id, reflowPhoneMax, {'layout': {'padding': phone}});
  }

  /// The least width of a grid's cell, by how many columns it was written with.
  static num _cellBasis(int cols) => switch (cols) { <= 2 => 300, 3 => 220, 4 => 260, _ => 150 };

  /// Whether a grid's columns mean something and hold at every width: seven
  /// (the days of a week: a month, a streak, a timetable), written `keep`,
  /// or five or more cells that are small (a number, a dot, an icon: at
  /// most three nodes each, no card and no component). Its cells shrink.
  ///
  /// A grid of one cell repeated ([repeated]: an `each`, written on a page
  /// or in a defined word's lines) is a board when its cell is a key, a
  /// square or a small thing: of three or more columns, a cell that is
  /// pressed (a button, or what has a tap) and small (a keypad, 3 by 4); of
  /// five or more, a small cell or one of a fixed side of at most 64 with no
  /// card or component in it (a crossword's square, a seat). The node the
  /// notation wraps each copy in is not the cell's.
  bool _keeps(String id, int cols, List<String> cells, {bool repeated = false}) {
    if (keepColumns.contains(id) || cols == 7) return true;
    if (cells.isEmpty) return false;
    if (repeated && cells.length == 1) {
      final cell = _cellOf(cells.single);
      final n = nodes[cell];
      if (n == null) return false;
      final small = _small(cell, 3) >= 0;
      final pressed = _type(n).endsWith('Button') || (n['actions'] is List && (n['actions'] as List).isNotEmpty);
      if (cols >= 3 && small && pressed) return true;
      if (cols < 5) return false;
      num? side(Object? v) => v is num ? v : null;
      final w = side(_layout(n)['width']), h = side(_layout(n)['height']);
      // (A tile of a set height over 64, a photo's, is no small thing: five
      // across a phone were strips 68 wide and 130 tall.)
      if (small) return !(h != null && h > 64 && w == null);
      return ((w != null && w <= 64) || (h != null && h <= 64)) && _small(cell, 12) >= 0;
    }
    if (cols < 5) return false;
    return cells.every((c) => _small(c, 3) >= 0);
  }

  /// The cell of a repeated grid: the node the notation wraps each copy in
  /// (a column with one child and nothing of its own to draw) is passed.
  String _cellOf(String id) {
    final n = nodes[id];
    if (n == null || _type(n) != 'column') return id;
    final kids = _kids(n);
    final fills = readMap(n['decoration'])?['fills'];
    if (kids.length != 1 || (fills is List && fills.isNotEmpty) || n['actions'] != null) return id;
    return kids.single;
  }

  /// How many nodes [id] has left of [budget] (-1: too many, or a card or a
  /// component among them).
  int _small(String id, int budget) {
    final n = nodes[id];
    if (n == null) return budget;
    if (cards.contains(id) || isComponent(_type(n)) || budget <= 0) return -1;
    var left = budget - 1;
    for (final k in _kids(n)) {
      left = _small(k, left);
      if (left < 0) return -1;
    }
    return left;
  }

  void _gridRow(String id, Json n, ({int cols, num gap}) g) {
    if (g.cols < 2) return;
    if (_keeps(id, g.cols, _kids(n))) return;
    _add(id, reflowTabletMax, {
      'props': {'wrap': true, 'runSpacing': g.gap},
    });
    final basis = _cellBasis(g.cols);
    for (final k in _kids(n)) {
      // A cell as tall as its row on one line is as tall as itself on lines
      // of their own (the row's lines stretch their cells): a lane of a
      // board that filled its row's height had none where the row wrapped.
      final tall = switch (_layout(nodes[k]!)['height']) { final Map h => h.containsKey('fill'), _ => false };
      _add(k, reflowTabletMax, {
        'layout': {
          'basis': basis,
          if (tall) 'height': {'fill': null, 'hug': 0},
        },
      });
      // An empty cell that fills out the last row has nothing to show on a line of its own.
      if (_type(nodes[k]!) == 'spacer') _hide(k, reflowPhoneMax);
    }
  }

  void _gridView(String id, Json n) {
    final cols = _props(n)['crossAxisCount'];
    if (_props(n)['minCrossAxisExtent'] != null) return;
    // Columns worked out from the state (`Grid cols={zoom}`, a size slider):
    // a phone shows at most three of them, so a cell is never a sliver (five
    // across a phone were 45 px each).
    if (readMap(n['bind'])?['props.crossAxisCount'] case final String bound) {
      final inner = RegExp(r'^\$\{=?\s*(.*)\}$', dotAll: true).firstMatch(bound)?[1];
      if (inner == null || keepColumns.contains(id) || _underKept(id) || _own.contains(id)) return;
      _add(id, reflowPhoneMax, {
        'bind': {'props.crossAxisCount': '\${= min(3, ${inner.trim()})}'},
      });
      return;
    }
    if (cols is! num || cols < 2) return;
    if (_keeps(id, cols.toInt(), _kids(n), repeated: true)) return;
    var tablet = cols >= 5 ? 3 : cols >= 4 ? 2 : cols.toInt();
    // Beside something of a width of its own (a summary, a sidebar a
    // tablet keeps) it has less than the window: a column fewer while its
    // cells would be under 160 (three cards of 120 beside an order summary,
    // a stepper 14 px past its card: test 17).
    final gap = switch (_props(n)['crossAxisSpacing']) { final num g => g, _ => 0 };
    final room = _tabletRoom(id) - _sidesPadding(n);
    while (tablet > 1 && (room - gap * (tablet - 1)) / tablet < 160) {
      tablet--;
    }
    if (tablet != cols) _add(id, reflowTabletMax, {'props': {'crossAxisCount': tablet}});
    _add(id, reflowPhoneMax, {'props': {'crossAxisCount': cols >= 5 ? 2 : 1}});
  }

  /// A table's row: at least three columns of fixed widths, texts among them.
  bool _tableRow(String id, Json n) {
    final kids = [
      for (final k in _kids(n))
        if (_type(nodes[k]!) != 'spacer') k,
    ];
    final shared = tableRows.contains(id);
    final fixed = <String, num>{};
    var texts = 0;
    for (final k in kids) {
      final kid = nodes[k]!;
      final w = _fixedWidth(kid);
      if (w == null) continue;
      final type = _type(kid);
      if (type == 'text') {
        texts++;
        fixed[k] = w;
      } else if (w >= 80 && (type == 'row' || type == 'column' || isComponent(type))) {
        // (A cell that is a design system's part, a status of a fixed
        // width, is a column as the text of its head is: counted as a
        // control it left the row no room, and the row lost its first
        // column while its head kept it.)
        fixed[k] = w;
      }
    }
    if (!shared && (fixed.length < 3 || (texts < 2 && fixed.values.any((w) => w >= 200)))) return false;
    num share(String k) => switch (_layout(nodes[k]!)['flex']) { final num f when f > 0 => f, _ => 0 };
    if (!shared) {
      final widest = fixed.values.fold<num>(0, math.max);
      for (final k in kids) {
        if (fixed[k] case final num w) {
          _add(k, reflowTabletMax, {'layout': {'width': {'fill': 0}, 'flex': w}});
        } else if (share(k) > 0 && share(k) < 20) {
          _add(k, reflowTabletMax, {'layout': {'flex': share(k) * widest * 1.5}});
        }
      }
    }
    // A narrower screen keeps the columns it has room for, from the first
    // on: each at a least width, the one that grows at more, and what is
    // not a column of data (a checkbox, a menu button) as it is.
    final all = _kids(n);
    final spacing = switch (_props(n)['spacing']) { final num s => s, _ => 0 };
    final pad = switch (_layout(n)['padding']) {
      final num p => p * 2,
      final List p when p.length == 4 && p[0] is num && p[2] is num => (p[0] as num) + (p[2] as num),
      _ => 0,
    };
    String? grower;
    num most = 0;
    for (final k in kids) {
      final s = shared ? share(k) : (fixed.containsKey(k) || _fixedWidth(nodes[k]!) != null ? 0 : share(k));
      if (s > most) {
        most = s;
        grower = k;
      }
    }
    for (final (max, least, growLeast, room) in const [(reflowTabletMax, 90, 160, 600), (reflowPhoneMax, 56, 110, 342)]) {
      num used = pad + spacing * (all.length - 1);
      final data = <String>[];
      for (final k in all) {
        final w = _fixedWidth(nodes[k]!);
        if (k == grower) {
          used += growLeast;
        } else if (shared ? share(k) > 0 : fixed.containsKey(k)) {
          data.add(k);
        } else {
          // (What is not a column, a menu button or a checkbox, at 32: counted
          // 40, a row with a menu button had
          // less room than its head with a Spacer of 32 in its place, and
          // hid a column its head kept.)
          used += w ?? (_type(nodes[k]!) == 'spacer' ? 0 : 32);
        }
      }
      var full = false;
      for (final k in data) {
        final need = math.min(shared ? share(k) : fixed[k]!, least);
        // The first column is what the row is of (a name): it is kept
        // whatever the room, and the others go before it does.
        if (k == data.first || (!full && used + need <= room)) {
          used += need;
        } else {
          full = true;
          used -= spacing;
          _hide(k, max);
        }
      }
    }
    return true;
  }

  /// A row whose one child is the list an `each` makes: its copies wrap.
  void _rowOfCopies(String id, Json n) {
    final kids = _kids(n);
    if (kids.length != 1 || _leftAsWritten(id, list: true)) return;
    final list = nodes[kids.single]!;
    final p = _props(list);
    if (_type(list) != 'listView' || p['scrollDirection'] != 'horizontal' || p['scrollable'] == true || p['wrap'] == true || p['reorder'] != null) return;
    final spacing = switch (_props(n)['spacing']) { final num s => s, _ => switch (p['spacing']) { final num s => s, _ => 0 } };
    _add(kids.single, reflowTabletMax, {
      'layout': {'width': {'hug': null, 'fill': 0}},
      'props': {'wrap': true, 'wrapSpacing': spacing, 'runSpacing': spacing > 0 ? math.min(spacing, 12) : 8},
    });
    // A copy is as tall as its row on one line; on lines of their own, as
    // tall as it is.
    for (final item in _kids(list)) {
      if (_layout(nodes[item]!)['height'] case final Map h when h.containsKey('fill')) {
        _add(item, reflowTabletMax, {'layout': {'height': {'fill': null, 'hug': 0}}});
      }
    }
  }

  /// The rules of a canvas laid out for a narrow width (a dialog, a
  /// sheet, a component): only its rows of copies wrap, where the window
  /// is narrower than a desktop's (a dialog on a phone is narrower than
  /// written).
  Map<String, List<Json>> runNarrow() {
    for (final e in nodes.entries) {
      if (_type(e.value) == 'row' && _props(e.value)['scrollable'] != true && _props(e.value)['wrap'] != true) _rowOfCopies(e.key, e.value);
    }
    return {
      for (final e in _rules.entries)
        e.key: [
          for (final max in e.value.keys.toList()..sort((a, b) => b.compareTo(a))) {'maxWidth': max, 'patch': e.value[max]},
        ],
    };
  }

  /// A row of blocks wraps where they no longer fit side by side; a row of
  /// controls wraps on a phone.
  void _row(String id, Json n) {
    final kids = _kids(n);
    // A row of copies an `each` repeats (`Row gap=5` over `each day in week`
    // / `ChoiceChip …`): one list to the row, so it wrapped nothing and
    // overflowed a phone (test 10: 29 runs). The copies wrap onto further
    // lines where they no longer fit, as a row of choices does; `Row scroll`
    // or `keep` keeps them on one line.
    if (kids.length == 1) return _rowOfCopies(id, n);
    if (kids.length < 2) return;
    if (_leftAsWritten(id, list: true)) {
      // (Here it is a list's row and nothing else of the writer's.)
      return _listRow(id, n);
    }
    // A row with a reorder Handle is a list's row: its grip stays beside
    // what it moves (what grows in it narrows), never alone on a line.
    if (kids.any((k) => nodes[k]?['reorderHandle'] == true)) return;
    final spacing = switch (_props(n)['spacing']) { final num s => s, _ => 0 };
    final blocks = {
      for (final k in kids)
        k: ?_block(k),
    };
    // Two short columns side by side are blocks; one beside a full block or
    // alone is a label.
    if (blocks.values.where((b) => b.light).length < 2) blocks.removeWhere((_, b) => b.light);
    if (blocks.length >= 2) {
      // The one block that grows beside fixed ones is the content beside its
      // rails: it keeps a column's width, and a rail goes under it sooner.
      final growing = blocks.values.where((b) => b.grows).length;
      final basis = growing == 1 && blocks.length >= 2 ? 360 : blocks.length >= 3 ? 240 : 280;
      _add(id, reflowTabletMax, {
        'props': {'wrap': true, 'runSpacing': spacing > 0 ? spacing : 16},
      });
      for (final e in blocks.entries) {
        if (e.value.fixed) {
          _add(e.key, reflowPhoneMax, {'layout': {'width': {'fill': 0}, 'basis': math.min(e.value.width, 280), 'flex': 1}});
          _handled.add(e.key);
        } else if (e.value.grows) {
          _add(e.key, reflowTabletMax, {'layout': {'width': {'fill': 0}, 'basis': _choiceBasis(nodes[e.key]!, basis), 'flex': switch (_layout(nodes[e.key]!)['flex']) { final num f when f > 0 => f, _ => 1 }}});
        }
      }
      for (final k in kids) {
        if (_type(nodes[k]!) == 'spacer') _hide(k, reflowPhoneMax);
      }
      return;
    }
    // Any other row wraps before it overflows: what grows in it keeps a
    // least width (and its share of what its line leaves), so a label
    // beside a button is as before while both fit.
    if (_layout(n)['height'] is num) return;
    // What grows in it is texts that end in an ellipsis when they have no
    // room (`maxLines=1 overflow=ellipsis`: a name and its role beside an
    // avatar): they give way and the row keeps its line. It wrapped, the
    // avatar above its name, in a narrow sidebar.
    final growing = [for (final k in kids) if (_fills(nodes[k]!)) k];
    if (growing.isNotEmpty && growing.every(_truncates)) return;
    // In an app's window a pane narrows, it is not a page whose lines wrap:
    // a list's row, a label beside its value keep their line (what is wider
    // than a phone holds beside anything, a form beside its preview, wraps).
    final wide = kids.any((k) => (_fixedWidth(nodes[k]!) ?? 0) > 300);
    for (var p = _parents[id]; p != null && !wide; p = _parents[p]) {
      // …unless it has no room on a phone (a filter bar of fields).
      if (roles[p] == 'app' || (_type(nodes[p]!) == 'row' && _frame(p, nodes[p]!))) return _crowded(id, n);
    }
    _add(id, reflowTabletMax, {
      'props': {'wrap': true, 'runSpacing': spacing > 0 ? math.min(spacing, 12) : 8},
    });
    for (final k in kids) {
      final kid = nodes[k]!;
      final type = _type(kid);
      final w = _fixedWidth(kid);
      if (w != null && w > 300) {
        _add(k, reflowPhoneMax, {'layout': {'width': {'fill': 0}, 'basis': 240, 'flex': 1}});
        _handled.add(k);
      } else if (w == null && _fills(kid)) {
        // A block alone among labels and buttons still keeps a column's width.
        final basis = _choiceBasis(kid, type == 'spacer' ? 0 : blocks[k] != null && !blocks[k]!.light ? 280 : _fields.contains(type) ? 180 : isComponent(type) ? 160 : 96);
        _add(k, reflowTabletMax, {'layout': {'width': {'fill': 0}, 'basis': basis, 'flex': switch (_layout(kid)['flex']) { final num f when f > 0 => f, _ => 1 }}});
        // On a phone what grows keeps the width its own words need (up to
        // 200 for a column of text, 160 for a text): two columns of
        // paragraphs side by side each took half a phone, and a heading
        // beside a box of figures 50 px, a letter to a line.
        final least = type == 'text' ? 160 : type == 'column' || type == 'row' ? 200 : 0;
        if (least > basis && !_truncates(k)) {
          final own = math.min<num>(least, _need(k));
          if (own > basis) _add(k, reflowPhoneMax, {'layout': {'basis': own}});
        }
      }
    }
  }

  /// What a row of controls with nothing that grows may need before it is
  /// given further lines ([_listRow]).
  static const num _controlsHold = 160;

  /// A row of a list keeps its line while it has room (a name narrows
  /// beside its avatar and its time). Where it has none, it is laid out as
  /// any other row with none is, so nothing in it is squeezed to a sliver:
  ///
  /// - with something that grows (a text beside a picture of a fixed width,
  ///   a field beside two more and three buttons), where a phone has no
  ///   room for what keeps its width and the least what grows is read at,
  ///   the row wraps there ([_crowded]): the picture a line, the text under
  ///   it (it kept the picture's 240 and gave the text 45 px, a word to a
  ///   line; the field 4 px);
  /// - with nothing that grows (a price beside two buttons in a card of a
  ///   grid), where its controls alone take more than [_controlsHold], it
  ///   wraps when its place is narrower than it, at a tablet's width and
  ///   under (the price was cut to "€2" under its buttons). A text beside
  ///   less than that narrows to further lines of its own, as before.
  void _listRow(String id, Json n) {
    final kids = _kids(n);
    if (_layout(n)['height'] is num || _props(n)['wrap'] == true || _props(n)['scrollable'] == true) return;
    if (_underKept(id) || _own.contains(id) || kids.any(_own.contains)) return;
    if (kids.any((k) => nodes[k]?['reorderHandle'] == true)) return;
    final growing = [for (final k in kids) if (_fills(nodes[k]!) && _fixedWidth(nodes[k]!) == null && _type(nodes[k]!) != 'spacer') k];
    if (growing.isNotEmpty) {
      // Only where it is plain that it has none: beside something of a
      // width of its own that is wide (a picture, a rail: 160 or more), or
      // where what grows is a field. A row of a text beside a switch and a
      // button is counted too roughly to be wrapped on the count (it has
      // room, and its last button went to a line of its own).
      final wide = kids.any((k) => (_fixedWidth(nodes[k]!) ?? 0) >= 160);
      final field = growing.any((k) => _fields.contains(_type(nodes[k]!)));
      if (wide || field) _crowded(id, n);
      return;
    }
    if (kids.any((k) => _type(nodes[k]!) == 'spacer')) return;
    // (Buttons alone too: three of them in a card of a grid, the last 44 px
    // past its row.)
    final texts = [for (final k in kids) if (_type(nodes[k]!) == 'text') k];
    num held = _spacing(n) * math.max(0, kids.length - texts.length - 1);
    for (final k in kids) {
      if (!texts.contains(k)) held += _need(k);
    }
    if (held <= _controlsHold) return;
    final spacing = _spacing(n);
    _add(id, reflowTabletMax, {
      'props': {'wrap': true, 'runSpacing': spacing > 0 ? math.min(spacing, 12) : 8},
    });
  }

  /// Whether [id] is a text of one line that ends in an ellipsis, or a
  /// column of only such texts.
  bool _truncates(String id) {
    final n = nodes[id];
    if (n == null) return false;
    final type = _type(n);
    if (type == 'text') return _props(n)['maxLines'] == 1 && _props(n)['overflow'] == 'ellipsis';
    final kids = _kids(n);
    return type == 'column' && kids.isNotEmpty && kids.every(_truncates);
  }

  /// The room a phone gives a row: its width less a page's padding.
  static const num _phoneRoom = 342;

  /// About how wide [id] is laid out as written (what a row needs on a
  /// phone): a fixed width as written, a text by its letters, a control or
  /// a design system's part at a button's width; 0 when a phone hides it.
  num _need(String id) {
    final n = nodes[id]!;
    if (n['visible'] == false || _rules[id]?[reflowPhoneMax]?['visible'] == false) return 0;
    for (final r in (n['media'] as List? ?? const [])) {
      final rule = readMap(r);
      if (rule?['maxWidth'] case final num max when max >= reflowPhoneMax && readMap(rule!['patch'])?['visible'] == false) return 0;
    }
    if (_fixedWidth(n) case final num w) return w;
    final type = _type(n);
    final p = _props(n);
    num text(Object? t, num size) => t is String && !t.contains(r'${') ? t.length * size * 0.55 : 60;
    num pad() => _sidesPadding(n);
    switch (type) {
      case 'spacer':
        return 0;
      case 'text':
        return text(p['text'], switch (readMap(p['style'])?['fontSize']) { final num s => s, _ => displaySizes[readMap(p['style'])?['from']] ?? 14 });
      case 'icon':
        return switch (p['size']) { final num s => s, _ => 24 };
      case 'iconButton':
        return 32;
      case 'textField' || 'dropdown':
        return 160;
      case 'row':
        final kids = _kids(n);
        return pad() + _spacing(n) * math.max(0, kids.length - 1) + kids.fold<num>(0, (s, k) => s + _need(k));
      case 'column':
        return pad() + _kids(n).fold<num>(0, (m, k) => math.max(m, _need(k)));
    }
    if (type.endsWith('Button') || type.endsWith('Chip')) return text(p['label'], 13) + (p['icon'] == null ? 32 : 52);
    return isComponent(type) ? 100 : 60;
  }

  /// A row of an app's pane, or one laid out by width in part, that has no
  /// room on a phone (a filter bar: a search field, two selects and a
  /// count; a top bar's title beside a search and a button): its parts
  /// wrap onto further lines there, a field of a fixed width taking a
  /// line's share, a spacer gone (track C: a row of controls kept its line
  /// in an app and overflowed a phone by up to 370 px).
  void _crowded(String id, Json n) {
    final kids = _kids(n);
    if (kids.length < 2 || _layout(n)['height'] is num || _props(n)['wrap'] == true || _props(n)['scrollable'] == true) return;
    // What grows in it (a list row's subject) narrows first: the row is
    // crowded when what keeps its width has no room.
    final shown = [for (final k in kids) if (_need(k) > 0 || (_fills(nodes[k]!) && _type(nodes[k]!) != 'spacer')) k];
    // (What grows gives way down to the least its words can be read at: a
    // text that ends in an ellipsis to almost nothing, any other to 120.
    // A column of them; a text alone narrows, as a list row's subject does.)
    // (A field that grows at 100: it was counted at 32 and drawn 4 px wide
    // beside two fields and three buttons.)
    num least(String k) => _truncates(k)
        ? 32
        : _fields.contains(_type(nodes[k]!))
            ? 100
            : _type(nodes[k]!) != 'column'
                ? 32
                : _showsData(k)
                    ? 120
                    : math.max(32, math.min(120, _need(k)));
    final need = _sidesPadding(n) + _spacing(n) * math.max(0, shown.length - 1) + shown.fold<num>(0, (s, k) => s + (_fills(nodes[k]!) && _fixedWidth(nodes[k]!) == null ? least(k) : _need(k)));
    if (need <= _phoneRoom) return;
    final spacing = _spacing(n);
    _add(id, reflowPhoneMax, {
      'props': {'wrap': true, 'runSpacing': spacing > 0 ? math.min(spacing, 12) : 8},
    });
    for (final k in kids) {
      final kid = nodes[k]!;
      final type = _type(kid);
      if (type == 'spacer') {
        _hide(k, reflowPhoneMax);
      } else if (_fixedWidth(kid) case final num w when w >= 120) {
        _add(k, reflowPhoneMax, {'layout': {'width': {'fill': 0}, 'basis': math.min(w, 240), 'flex': 1}});
      } else if (_fills(kid) || ((type == 'row' || type == 'column') && _need(k) > 120)) {
        final basis = math.min(_phoneRoom, math.max(96, _need(k)));
        _add(k, reflowPhoneMax, {'layout': {'width': {'fill': 0}, 'basis': basis, 'flex': switch (_layout(kid)['flex']) { final num f when f > 0 => f, _ => 1 }}});
      }
    }
  }

  /// Whether a column has a text that wraps and shows a value of the page
  /// (a title from a record): how long it is is not known here, so it is
  /// counted as a line of words ([_need] counts 60 for it, which let a
  /// title and its summary be given 45 px beside a picture of 240).
  bool _showsData(String id) {
    for (final k in _kids(nodes[id]!)) {
      final kid = nodes[k]!;
      if (_type(kid) != 'text' || _truncates(k)) continue;
      final t = _props(kid)['text'];
      if (t is String && t.contains(r'${')) return true;
      if (readMap(kid['bind'])?.containsKey('props.text') ?? false) return true;
    }
    return false;
  }

  /// A headline's size on a tablet and on a phone.
  void _headline(String id, Json n) {
    if (readMap(n['bind'])?.keys.any((k) => k.startsWith('props.style')) ?? false) return;
    final style = readMap(_props(n)['style']);
    if (style == null) return;
    final size = switch (style['fontSize']) { final num s => s, _ => displaySizes[style['from']] };
    if (size == null || size < 32) return;
    if (size >= 44) _add(id, reflowTabletMax, {'props': {'style': {'fontSize': (size * 0.86).round()}}});
    _add(id, reflowPhoneMax, {'props': {'style': {'fontSize': math.max(26, (size * 0.72).round())}}});
  }

  /// A box wider than a phone, in a column: as wide as its place there, and
  /// no wider than written.
  void _wideBox(String id, Json n) {
    if (_handled.contains(id) || _rules[id]?[reflowPhoneMax]?['visible'] == false) return;
    final w = _fixedWidth(n);
    if (w == null || w <= 300) return;
    final parent = _parents[id];
    final parentType = parent == null ? null : _type(nodes[parent]!);
    if (parentType != 'column' && parentType != 'listView' && parentType != 'gridView') return;
    if (parent != null && roles[parent] == 'app') return;
    _add(id, reflowPhoneMax, {
      'layout': {'width': {'fill': 0}, 'constraints': {'maxWidth': w}},
    });
  }

  late final Map<String, String> _parents = {
    for (final e in nodes.entries)
      for (final c in _kids(e.value)) c: e.key,
  };
}
