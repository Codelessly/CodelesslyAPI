// v1 breakpoints → v2's two levels (CodelesslyAPI/v2/DESIGN.md §5.3): the
// project's breakpoints, and a node's or screen canvas's own switch points.
//
// v1 had no project set: the screen size classes were the fixed
// `ScreenBreakpoint`s (mobile, tablet, desktop at 0, 600, 1024), and
// widths were moved locally: a responsive node's `tabletMinWidth` /
// `desktopMinWidth`, a layout group's canvas ranges, an adaptive dialog's
// `sheetBelowWidth`. The project's set takes the widths most of the project
// uses ([migrateProjectBreakpoints]: `tablet` and `desktop` at the most
// common v1 widths); a node or layout group switching elsewhere keeps its
// widths as its own switch points (`minWidths`, a canvas's
// `breakpointMinWidth`). A project breakpoint is added only for a width no
// override can say: an adaptive dialog's sheet width (an action has no
// switch points of its own), or a layout group with more canvases than the
// set has breakpoints.
import 'package:codelessly_api/codelessly_api.dart'
    show DialogPresentation, NodeJsonConverter, ScreenBreakpoint, VarianceNode;

import 'page_schema.dart' show MigrationHandler;

typedef _Json = Map<String, Object?>;

/// The default breakpoints' design sizes (API v2 `Breakpoints.defaults`).
const Map<String, (num, num)> _designSizes = {'mobile': (390, 844), 'tablet': (834, 1112), 'desktop': (1440, 900)};

/// A project's breakpoints as the migration made them.
final class MigratedBreakpoints {
  MigratedBreakpoints._(this.json, this.added, this.votes);

  /// The default set (mobile 0, tablet 600, desktop 1024): a project whose
  /// pages switch nowhere else.
  static final MigratedBreakpoints defaults = migrateProjectBreakpoints(const []);

  /// From a stored set (API v2 `Breakpoints` JSON: `[{id, name, minWidth,
  /// width, height}]`): what [migrateDocument] resolves widths against.
  /// Null or empty: [defaults].
  static MigratedBreakpoints fromJson(Object? json) {
    final list = [
      for (final b in (json is List ? json : const []))
        if (b is Map && b['id'] is String) {for (final e in b.entries) '${e.key}': e.value},
    ];
    if (list.isEmpty) return defaults;
    list.sort((a, b) => _num(a['minWidth']).compareTo(_num(b['minWidth'])));
    list[0] = {...list[0]}..remove('minWidth');
    return MigratedBreakpoints._(list, const [], const {});
  }

  /// The set, narrowest first, as API v2 `Breakpoints.toJson` (the first's
  /// `minWidth` omitted: it starts at 0). What the conversion job writes to
  /// the project's data (`breakpoints` of its v2 settings document) and the
  /// publish model.
  final List<_Json> json;

  /// Ids of the breakpoints added for v1 widths no override can say (an
  /// adaptive dialog's sheet width no breakpoint starts at; a layout group
  /// with more canvases than breakpoints): normally none. Where there are,
  /// `${screen.breakpoint}` names them between the others (report them).
  final List<String> added;

  /// How many uses each v1 switch width had (width → count), for reports.
  final Map<num, int> votes;

  /// Whether this is the default set (stored as nothing).
  bool get isDefault => _same(json, defaults.json);

  /// The breakpoint that starts at [width] (0 or less: the first); null when
  /// none does.
  String? idAt(num width) {
    if (width <= 0) return json.first['id'] as String;
    for (final b in json) {
      if (_num(b['minWidth']) == width) return b['id'] as String;
    }
    return null;
  }

  /// The breakpoint [width] falls in (the last starting at or below it).
  String idFor(num width) {
    var id = json.first['id'] as String;
    for (final b in json.skip(1)) {
      if (width >= _num(b['minWidth'])) id = b['id'] as String;
    }
    return id;
  }

  /// [idAt], else (a width the set lacks: a page migrated without its
  /// project's set) the breakpoint it falls in.
  String idNear(num width) => idAt(width) ?? idFor(width);

  /// The position of breakpoint [id] (narrowest 0), or -1.
  int indexOf(String id) => json.indexWhere((b) => b['id'] == id);

  /// The min width of breakpoint [id] (0 for the first or one not in the set).
  num minWidthOf(String id) {
    for (final b in json) {
      if (b['id'] == id) return _num(b['minWidth']);
    }
    return 0;
  }
}

/// A v1 switch width a page uses: [slot] is the v1 class it starts.
typedef _Vote = ({String slot, num width});

/// The project's breakpoints for its v1 pages (DESIGN.md §5.3, "Migration").
///
/// [documents] are the pages' stored v1 documents (node id → node JSON, as
/// [migrateDocument] takes them); [layoutGroups] each page's v1 layout
/// groups (its metadata `breakpoints`: group id → `[{nodeId, lowerBound,
/// upperBound}]`, or a published layout's list of them); [logic] any other
/// v1 JSON holding actions or formulas (canvas variables, conditions).
///
/// The widths v1 switched at vote: a responsive node's tablet and desktop
/// widths (its own or v1's 600 / 1024; only for the classes it has a
/// variant for), each layout group canvas's lower bound, an adaptive
/// dialog's `sheetBelowWidth`, and 600 and 1024 wherever the global classes
/// were read (`screen.is…` in a formula, a toast's per-breakpoint look). The
/// most used tablet width (600 on a tie) is `tablet`'s, the most used
/// desktop width (1024 on a tie) `desktop`'s. Nodes and groups switching
/// elsewhere keep their widths as overrides ([varianceMinWidths],
/// [migrateLayoutGroups]). Added ([MigratedBreakpoints.added], `<class><width>`,
/// "Tablet 700") only: an adaptive dialog's sheet width no breakpoint starts
/// at, and a lower bound of a layout group with more canvases than the set
/// has breakpoints (one canvas per breakpoint).
MigratedBreakpoints migrateProjectBreakpoints(
  Iterable<Map<String, Object?>> documents, {
  Iterable<Object?> layoutGroups = const [],
  Iterable<Object?> logic = const [],
}) {
  final votes = <_Vote>[];
  final sheets = <num>{};
  final groupBounds = <List<num>>[];
  void vote(String slot, num width) {
    if (width.isFinite && width > 0) votes.add((slot: slot, width: _round(width)));
  }

  void voteGlobal() {
    vote(ScreenBreakpoint.tablet.name, ScreenBreakpoint.tablet.minWidth);
    vote(ScreenBreakpoint.desktop.name, ScreenBreakpoint.desktop.minWidth);
  }

  void sheet(num width) {
    vote(ScreenBreakpoint.forWidth(width.toDouble()).name, width);
    if (width > 0) sheets.add(_round(width));
  }

  void scan(Object? json) => _scanJson(json, sheet, voteGlobal);

  for (final doc in documents) {
    final wrapped = <String, dynamic>{'document': {...doc}};
    MigrationHandler.migrateJson(wrapped);
    for (final v in ((wrapped['document'] as Map).values)) {
      if (v is! Map || v['type'] != 'variance') continue;
      final VarianceNode node;
      try {
        final n = NodeJsonConverter().fromJson(v);
        if (n is! VarianceNode) continue;
        node = n;
      } catch (_) {
        continue;
      }
      if (!node.isResponsive) continue;
      for (final r in _ranges(node)) {
        if (r.start > 0) vote(r.slot, r.start);
      }
    }
    scan(doc);
  }
  for (final groups in layoutGroups) {
    for (final g in _groups(groups)) {
      final bounds = [for (final b in g) _round(_num(b['lowerBound']))]..sort();
      if (bounds.length > 1) groupBounds.add(bounds);
      for (final lb in bounds) {
        vote(ScreenBreakpoint.forWidth(lb.toDouble()).name, lb);
      }
    }
  }
  for (final l in logic) {
    scan(l);
  }
  return _choose(votes, sheets: sheets, groups: groupBounds);
}

/// A responsive v1 [node]'s variant ranges: each breakpoint class it has a
/// variant for and where that class starts by its own widths (v1
/// `ScreenBreakpoint.forWidth`); a class whose range is empty (tablet at
/// or above desktop) is left out.
List<({String slot, num start})> _ranges(VarianceNode node) {
  final t = node.properties.tabletMinWidth ?? ScreenBreakpoint.tablet.minWidth;
  final d = node.properties.desktopMinWidth ?? ScreenBreakpoint.desktop.minWidth;
  final has = {for (final v in node.variants) ?v.breakpoint?.name};
  final out = <({String slot, num start})>[];
  final tablet = t < d ? t : d;
  if (has.contains('mobile') && tablet > 0) out.add((slot: 'mobile', start: 0));
  if (has.contains('tablet') && t < d) out.add((slot: 'tablet', start: _round(t < 0 ? 0 : t)));
  if (has.contains('desktop')) out.add((slot: 'desktop', start: _round(d < 0 ? 0 : d)));
  return out;
}

/// A responsive variance's v1 `tabletMinWidth` / `desktopMinWidth` (v1's
/// 600 / 1024 when unset) as its v2 own switch points (`minWidths`,
/// breakpoint id → width) against the project's [breakpoints] (default:
/// the defaults): the ones that differ from the project's. Empty when it
/// switches where the project does. A tablet at or above desktop (v1 never
/// showed tablet) keeps both, so desktop stays where v1 had it.
Map<String, num> varianceMinWidths({double? tabletMinWidth, double? desktopMinWidth, MigratedBreakpoints? breakpoints}) {
  final set = breakpoints ?? MigratedBreakpoints.defaults;
  final t = _round(tabletMinWidth ?? ScreenBreakpoint.tablet.minWidth);
  final d = _round(desktopMinWidth ?? ScreenBreakpoint.desktop.minWidth);
  final both = t >= d;
  return {
    if (both || t != set.minWidthOf('tablet')) 'tablet': t,
    if (both || d != set.minWidthOf('desktop')) 'desktop': d,
  };
}

/// Which project breakpoint each canvas of a layout group is the design
/// for, by [set]: the one its lower bound falls in, else (taken by a
/// narrower canvas of the group) the next one, in order; `minWidth` when
/// its lower bound isn't that breakpoint's (its own switch point). Null
/// when the group has more canvases than [set] has breakpoints left.
List<({String breakpoint, num? minWidth})>? _assign(List<num> bounds, MigratedBreakpoints set) {
  final out = <({String breakpoint, num? minWidth})>[];
  var last = -1;
  for (final lb in bounds) {
    var i = set.indexOf(set.idFor(lb));
    if (i <= last) i = last + 1;
    if (i >= set.json.length) return null;
    last = i;
    final b = set.json[i];
    final min = _num(b['minWidth']);
    out.add((breakpoint: b['id'] as String, minWidth: lb == min || (i == 0 && lb <= 0) ? null : lb));
  }
  return out;
}

/// The v2 breakpoint entry of a canvas whose v1 range starts at [lowerBound]
/// (a canvas of its own): `{canvas, breakpoint, minWidth?}`, the project
/// breakpoint ([set]; default: the defaults) it falls in, and its own switch
/// point when that isn't the breakpoint's.
_Json canvasBreakpoint(String canvasId, num lowerBound, [MigratedBreakpoints? set]) {
  final a = _assign([_round(lowerBound)], set ?? MigratedBreakpoints.defaults)!.single;
  return {'canvas': canvasId, 'breakpoint': a.breakpoint, 'minWidth': ?a.minWidth};
}

/// Gives the canvases of each v1 layout group in v2 document [doc] (its
/// `nodes`) their breakpoint, screen and own switch point: [groups] is v1's
/// page metadata `breakpoints` (group id → `[{nodeId, lowerBound,
/// upperBound}]`). A group of one canvas is a screen of its own and gets
/// nothing. Each canvas gets the project breakpoint ([breakpoints], from
/// [migrateProjectBreakpoints]; default: the defaults) its lower bound falls
/// in (the next one when a narrower canvas took it) and its lower bound as
/// `breakpointMinWidth` when it isn't that breakpoint's. Returns each
/// group's entries, narrowest first, as a published layout lists them.
Map<String, List<_Json>> migrateLayoutGroups(_Json doc, Object? groups, {MigratedBreakpoints? breakpoints}) {
  final set = breakpoints ?? MigratedBreakpoints.defaults;
  final nodes = doc['nodes'];
  final out = <String, List<_Json>>{};
  if (nodes is! Map || groups is! Map) return out;
  for (final g in groups.entries) {
    final entries = [
      for (final b in _groupEntries(g.value))
        if (nodes[b['nodeId']] is Map) b,
    ]..sort((a, b) => _num(a['lowerBound']).compareTo(_num(b['lowerBound'])));
    if (entries.length < 2) continue;
    final bounds = [for (final b in entries) _round(_num(b['lowerBound']))];
    // A set without room (a page migrated without its project's set): the
    // widest breakpoint repeats, each canvas at its own switch point.
    final assigned = _assign(bounds, set) ??
        [
          for (var i = 0; i < bounds.length; i++)
            (_assign(bounds.sublist(0, i + 1), set)?.last ?? (breakpoint: set.json.last['id'] as String, minWidth: bounds[i])),
        ];
    final list = <_Json>[];
    for (var i = 0; i < entries.length; i++) {
      final id = entries[i]['nodeId'] as String;
      final a = assigned[i];
      list.add({'canvas': id, 'breakpoint': a.breakpoint, 'minWidth': ?a.minWidth});
      final node = (nodes[id] as Map).cast<String, Object?>();
      final props = {...?(node['props'] as Map?)?.cast<String, Object?>()};
      props['breakpoint'] = a.breakpoint;
      props['screen'] = '${g.key}';
      if (a.minWidth != null) props['breakpointMinWidth'] = a.minWidth;
      nodes[id] = {...node, 'props': props};
    }
    out['${g.key}'] = list;
  }
  return out;
}

/// A v1 formula reading the global breakpoint class (`screen.isTablet`,
/// `screen.breakpoint`).
final RegExp _readsClass = RegExp(r'(?<![\w.])screen\.(is|breakpoint)');

/// The keys of a v2 toast look keyed by breakpoint.
const List<String> _perBreakpointLookKeys = ['alignments', 'sideMargins', 'bottomOffsets'];

/// Rewrites v2 JSON [json] (a migrated document, its logic) for the
/// project's [set], in place: an adaptive `openModal`'s v1
/// `sheetBelowWidth` (600 when absent) becomes `sheetBelow`, the breakpoint
/// starting there (left out when it's the set's second, the default), and
/// a toast's per-breakpoint look values (v1's mobile, tablet, desktop: the
/// global classes) get an entry for every breakpoint, the one of the v1
/// class it starts in.
void applyProjectBreakpoints(Object? json, MigratedBreakpoints set) {
  if (json is List) {
    for (final v in json) {
      applyProjectBreakpoints(v, set);
    }
    return;
  }
  if (json is! Map) return;
  if (json['type'] == 'openModal') {
    final w = json.remove('sheetBelowWidth');
    if (json['presentation'] == 'adaptive') {
      final width = w is num ? w : ScreenBreakpoint.tablet.minWidth;
      final id = set.idNear(width);
      if (set.json.length < 2 || set.json[1]['id'] != id) json['sheetBelow'] = id;
    }
  }
  if (json['type'] == 'showToast' && json['look'] is Map) {
    final look = json['look'] as Map;
    for (final k in _perBreakpointLookKeys) {
      final values = look[k];
      if (values is! Map || values.isEmpty) continue;
      look[k] = {
        for (final b in set.json)
          if (values[ScreenBreakpoint.forWidth(_num(b['minWidth']).toDouble()).name] case final Object v) b['id']: v,
      };
    }
  }
  for (final v in json.values) {
    applyProjectBreakpoints(v, set);
  }
}

// -----------------------------------------------------------------------------

/// Votes [json]'s v1 uses of breakpoint widths: adaptive dialogs' sheet
/// widths, and the global classes where `screen` or a toast's
/// per-breakpoint look reads them.
void _scanJson(Object? json, void Function(num width) sheet, void Function() voteGlobal) {
  if (json is String) {
    if (_readsClass.hasMatch(json)) voteGlobal();
    return;
  }
  if (json is List) {
    for (final v in json) {
      _scanJson(v, sheet, voteGlobal);
    }
    return;
  }
  if (json is! Map) return;
  if (json['type'] == 'showDialog' && json['presentation'] == DialogPresentation.adaptive.name) {
    final w = json['sheetBelowWidth'];
    final width = w is num ? w : ScreenBreakpoint.tablet.minWidth;
    sheet(width);
  }
  if (json['type'] == 'showToast' && _perBreakpointLookKeys.any((k) => json[k] is Map && (json[k] as Map).isNotEmpty)) {
    voteGlobal();
  }
  for (final v in json.values) {
    _scanJson(v, sheet, voteGlobal);
  }
}

/// The set for [votes]; see [migrateProjectBreakpoints].
MigratedBreakpoints _choose(List<_Vote> votes, {Set<num> sheets = const {}, List<List<num>> groups = const []}) {
  final counts = <num, int>{};
  final slots = <num, Map<String, int>>{};
  for (final v in votes) {
    counts.update(v.width, (c) => c + 1, ifAbsent: () => 1);
    (slots[v.width] ??= {}).update(v.slot, (c) => c + 1, ifAbsent: () => 1);
  }
  num pick(String slot, num fallback, bool Function(num) ok) {
    num? best;
    var bestCount = 0;
    for (final e in slots.entries) {
      final c = e.value[slot] ?? 0;
      if (c == 0 || !ok(e.key)) continue;
      final better = c > bestCount ||
          (c == bestCount && (e.key == fallback || (best != fallback && e.key < best!)));
      if (better) {
        best = e.key;
        bestCount = c;
      }
    }
    return best ?? fallback;
  }

  final desktop = pick('desktop', _round(ScreenBreakpoint.desktop.minWidth), (_) => true);
  var tablet = pick('tablet', _round(ScreenBreakpoint.tablet.minWidth), (w) => w < desktop);
  if (tablet >= desktop) tablet = _round(desktop / 2);

  final byWidth = <num, _Json>{
    0: {'id': 'mobile', 'name': 'Mobile'},
    tablet: {'id': 'tablet', 'name': 'Tablet'},
    desktop: {'id': 'desktop', 'name': 'Desktop'},
  };
  final added = <String>[];
  bool add(num w) {
    if (byWidth.containsKey(w) || w <= 0) return false;
    final slot = ScreenBreakpoint.forWidth(w.toDouble()).name;
    final label = '${slot[0].toUpperCase()}${slot.substring(1)}';
    final key = '$w'.replaceAll('.', '_');
    byWidth[w] = {'id': '$slot$key', 'name': '$label $w', 'slot': slot};
    added.add('$slot$key');
    return true;
  }

  // An adaptive dialog's sheet width: a breakpoint must start there.
  for (final w in sheets) {
    add(w);
  }
  var set = _build(byWidth, added, counts);
  // A layout group needs a breakpoint per canvas.
  for (var changed = true; changed;) {
    changed = false;
    for (final bounds in groups) {
      if (_assign(bounds, set) != null) continue;
      // A breakpoint at the lower bound of the first canvas that shares its
      // breakpoint with a narrower one (it was moved to the next), else of
      // the first without one left.
      final candidates = [
        for (var i = 1; i < bounds.length; i++)
          if (set.idFor(bounds[i]) == set.idFor(bounds[i - 1])) bounds[i],
        ...bounds,
      ];
      for (final w in candidates) {
        if (add(w)) {
          set = _build(byWidth, added, counts);
          changed = true;
          break;
        }
      }
    }
  }
  return set;
}

MigratedBreakpoints _build(Map<num, _Json> byWidth, List<String> added, Map<num, int> counts) {
  final widths = byWidth.keys.toList()..sort();
  final json = <_Json>[];
  for (var i = 0; i < widths.length; i++) {
    final w = widths[i];
    final next = i + 1 < widths.length ? widths[i + 1] : double.infinity;
    final b = byWidth[w]!;
    final size = _designSizes[b['id']] ?? _designSizes[b['slot']];
    final out = <String, Object?>{'id': b['id'], 'name': b['name'], if (w != 0) 'minWidth': w};
    // A design size inside the breakpoint's range (else its min width).
    if (size != null && size.$1 >= w && size.$1 < next) {
      out['width'] = size.$1;
      out['height'] = size.$2;
    } else if (size != null) {
      out['height'] = size.$2;
    }
    json.add(out);
  }
  return MigratedBreakpoints._(json, [...added], counts);
}

/// Each layout group's entries (`[{nodeId, lowerBound}]`) of v1 [groups]: a
/// page's metadata map (group id → list), or one published layout's list.
Iterable<List<Map>> _groups(Object? groups) sync* {
  final lists = groups is Map ? groups.values : (groups is List ? [groups] : const []);
  for (final l in lists) {
    yield [
      for (final b in (l is List ? l : const []))
        if (b is Map && b['nodeId'] is String) b,
    ];
  }
}

Iterable<Map> _groupEntries(Object? groups) sync* {
  final lists = groups is Map ? groups.values : (groups is List ? [groups] : const []);
  for (final l in lists) {
    for (final b in (l is List ? l : const [])) {
      if (b is Map && b['nodeId'] is String) yield b;
    }
  }
}

bool _same(List<_Json> a, List<_Json> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final x = a[i], y = b[i];
    if (x.length != y.length) return false;
    for (final e in x.entries) {
      if (y[e.key] != e.value) return false;
    }
  }
  return true;
}

num _num(Object? v) => v is num && v.isFinite ? v : 0;

num _round(num v) {
  final r = (v * 10000).roundToDouble() / 10000;
  return r == r.roundToDouble() ? r.toInt() : r;
}
