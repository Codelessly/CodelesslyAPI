// How a page written once, for a desktop, lays out on a tablet and a phone.
//
// The notation is written for one width (a page 1280 wide). Shown narrower,
// its rows squeeze: three cards across a phone, a table's fixed columns, a
// sidebar beside its content. [PageReflow] reads the expanded nodes and gives
// each one that would not fit the media rules that make it fit:
//
//   Grid cols=3            its rows wrap (cells take a least width)
//   Row of blocks          wraps: a card beside a card, content beside a rail
//   Row of controls        wraps on a phone (a search field, a select, buttons)
//   a table's row          its columns share the width; a phone keeps the
//                          first, the widest and the last
//   App                    a phone shows the main pane; a tablet drops the
//                          panes after it; the sidebar it hides opens as
//                          a drawer from a button in the main pane's bar
//   Nav                    a phone hides its links
//   Section                less padding above and below
//   a headline             smaller
//   a wide fixed box       as wide as its place, at most its width
//
// Every rule holds below a width (`maxWidth` 1023: a tablet and narrower;
// 699: a phone), so the page at the width it was written for is untouched.
import 'dart:math' as math;

import '../behaviors.dart' show mergePatch;
import '../json.dart';

/// The widest a phone is and the widest a tablet is, as the rules count them.
const int reflowPhoneMax = 699, reflowTabletMax = 1023;

/// Works out the media rules of a page's nodes ([run]).
final class PageReflow {
  PageReflow({
    required this.nodes,
    this.roles = const {},
    this.gridRows = const {},
    this.cards = const {},
    this.tableRows = const {},
    this.displaySizes = const {},
    this.isComponent = _no,
    this.fillsItsPlace = _no,
  });

  static bool _no(String _) => false;

  /// The page's nodes by id, each with its `children`.
  final Map<String, Json> nodes;

  /// The frames among them: `app`, `nav`, `section`, `sidebar`, `main`, `pane`.
  final Map<String, String> roles;

  /// A `Grid`'s rows: how many columns the grid has and the space between.
  final Map<String, ({int cols, num gap})> gridRows;

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

  void _add(String id, int max, Json patch) {
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
    for (final e in nodes.entries) {
      final id = e.key, n = e.value;
      final type = _type(n);
      if (type == 'row' && !_handled.contains(id)) {
        if (gridRows[id] case final g?) {
          _gridRow(id, n, g);
        } else if (_props(n)['scrollable'] != true && _props(n)['wrap'] != true) {
          if (!_tableRow(id, n) && roles[id] != 'app') _row(id, n);
        }
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

  /// An app's window: its main pane is what a phone shows; a tablet keeps
  /// the panes before it (the navigation, a list) while they leave it room.
  void _app(String id, Json n) {
    final kids = _kids(n);
    var main = kids.indexWhere((k) => roles[k] == 'main');
    if (main < 0) main = kids.indexWhere((k) => _fixedWidth(nodes[k]!) == null && _fills(nodes[k]!));
    if (main < 0) return;
    final before = [
      for (var i = 0; i < main; i++)
        if (_fixedWidth(nodes[kids[i]]!) != null) kids[i],
    ];
    for (var i = main + 1; i < kids.length; i++) {
      if (_fixedWidth(nodes[kids[i]]!) != null) _hide(kids[i], reflowTabletMax);
    }
    num taken = 0;
    for (final k in before) {
      taken += _fixedWidth(nodes[k]!)!;
    }
    // Two panes before the main one (a sidebar and a list): a tablet keeps the nearer.
    if (before.length >= 2 && taken > 420) _hide(before.first, reflowTabletMax);
    for (final k in before) {
      _hide(k, reflowPhoneMax);
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
    if (links == 0) return;
    for (final k in hide) {
      _hide(k, links >= 6 ? reflowTabletMax : reflowPhoneMax);
    }
  }

  /// The button that opens an app's sidebar where the window hides it: what
  /// follows it in the bar (the page's title) takes the room beside it there,
  /// so the two sit together at the bar's start and the actions at its end.
  void _appMenu(String id, Json n) {
    final bar = _parents[id];
    if (bar == null) return;
    final kids = _kids(nodes[bar]!);
    if (kids.length < 3 || kids.first != id) return;
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

  void _gridRow(String id, Json n, ({int cols, num gap}) g) {
    if (g.cols < 2) return;
    _add(id, reflowTabletMax, {
      'props': {'wrap': true, 'runSpacing': g.gap},
    });
    final basis = _cellBasis(g.cols);
    for (final k in _kids(n)) {
      _add(k, reflowTabletMax, {'layout': {'basis': basis}});
      // An empty cell that fills out the last row has nothing to show on a line of its own.
      if (_type(nodes[k]!) == 'spacer') _hide(k, reflowPhoneMax);
    }
  }

  void _gridView(String id, Json n) {
    final cols = _props(n)['crossAxisCount'];
    if (cols is! num || cols < 2 || (readMap(n['bind'])?.containsKey('props.crossAxisCount') ?? false)) return;
    if (_props(n)['minCrossAxisExtent'] != null) return;
    final tablet = cols >= 6 ? 3 : cols >= 4 ? 2 : cols;
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
      } else if (w >= 80 && (type == 'row' || type == 'column')) {
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
          used += w ?? (_type(nodes[k]!) == 'spacer' ? 0 : 40);
        }
      }
      var full = false;
      for (final k in data) {
        final need = math.min(shared ? share(k) : fixed[k]!, least);
        if (!full && used + need <= room) {
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

  /// A row of blocks wraps where they no longer fit side by side; a row of
  /// controls wraps on a phone.
  void _row(String id, Json n) {
    final kids = _kids(n);
    if (kids.length < 2) return;
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
      }
    }
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
