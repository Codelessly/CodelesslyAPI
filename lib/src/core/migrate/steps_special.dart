// One-way steps after 30.1.0 (the last node steps of `migrate2to3`) that
// remove the last special-case fields, each said with a general mechanism
// the model already has (docs/design/10-audit-verdict.md, section 6, (d)):
//
// * a text's `countUp`, `countUpDuration`, `countUpCurve`, `countUpOnShow`
//   → a transition of `props.text` (its number counts) and, for the count
//   from 0 when it shows, an animation of it;
// * a slider's ruler ticks, marker, `activeTrackStartOpacity` and
//   `thumbGripColor` → draw ops of its `customPaint` (on a slider, `painter`
//   draws over the track and under the thumb, `foregroundPainter` over the
//   thumb, both reading `slider`: its value, track rect and thumb center);
//   `deriveOverlayColorFromThumb`, which no renderer read, is dropped;
// * a text field's `highlightStart`/`highlightEnd`/`highlightStyle` → its
//   `runs` (styled ranges, as a text's);
// * a table's `selectedRowEdgeColor`/`selectedRowEdgeWidth` → the cell
//   template's `selected` state style;
// * a date/time input's `displayFormat` → its `format`.
//
// Each writes what the old field drew where it can, and reports a behaviour
// change where it can't. A schema-3 document that still has one of the
// fields is refused by validation, naming the form to write.
import '../json.dart';
import '../values/color.dart';
import 'legacy_read.dart';
import 'migrate.dart';

/// The node steps, in order.
final List<MigrationStep> specialCaseSteps = [
  countUpStep,
  sliderPaintStep,
  textFieldRunsStep,
  displayFormatStep,
];

/// The document steps (they change a node other than the one with the
/// field).
final List<MigrationStep> specialCaseDocumentSteps = [tableRowEdgeStep];

// --- helpers ------------------------------------------------------------------------

/// The node's type, or (a patch) the type of the node it patches.
Object? _typeOf(Json n, MigrationScope s) => n['type'] ?? readMap(readMap(s.document?['nodes'])?[s.nodeId])?['type'];

/// [v] as JSON number text a formula reads back as the same double.
String _n(num v) => v == v.roundToDouble() && v.abs() < 1e15 ? '${v.toInt()}' : '$v';

/// Takes [keys] out of [n]'s props and their bindings out of its `bind`:
/// the literal values and the bound expressions, by key. Null when it has
/// none of them.
(Json, Map<String, String>)? _take(Json n, List<String> keys, MigrationScope s) {
  final props = readMap(n['props']);
  final bind = bindOf(n);
  final literal = <String, Object?>{
    for (final k in keys)
      if (props != null && props.containsKey(k)) k: props[k],
  };
  final bound = <String, String>{
    for (final e in bind.entries)
      for (final k in keys)
        if (e.key == 'props.$k' || e.key.startsWith('props.$k.') || e.key.startsWith('props.$k[')) e.key.substring(6): e.value,
  };
  if (literal.isEmpty && bound.isEmpty) return null;
  if (literal.isNotEmpty) {
    final out = {...props!}..removeWhere((k, _) => keys.contains(k));
    for (final k in literal.keys) {
      s.rewrite('/props/$k', literal[k], null);
    }
    if (out.isEmpty) {
      n.remove('props');
    } else {
      n['props'] = out;
    }
  }
  if (bound.isNotEmpty) putBind(n, {...bind}..removeWhere((k, _) => k.startsWith('props.') && bound.containsKey(k.substring(6))), s);
  return (literal, bound);
}

/// A value for a formula: a literal number, or `(formula)` of a bound one.
String? _term(Json literal, Map<String, String> bound, String key, num fallback) {
  if (bound[key] case final String e) {
    final f = formulaOf(e);
    return f == null ? null : '($f)';
  }
  return _n(readDouble(literal[key]) ?? fallback);
}

/// A color for a draw op's paint: the literal (or [fallback]), or the
/// bound expression as it is.
Object? _colorOf(Json literal, Map<String, String> bound, String key, Color? fallback) =>
    bound[key] ?? Color.fromJson(literal[key])?.toJson() ?? fallback?.toJson();

/// Appends [ops] to [n]'s `customPaint` list [list] (created when needed).
void _addOps(Json n, String list, List<Json> ops, MigrationScope s, String path) {
  if (ops.isEmpty) return;
  final cp = <String, Object?>{...?readMap(n['customPaint'])};
  cp[list] = [...?readList(cp[list]), ...ops];
  n['customPaint'] = cp;
  s.rewrite(path, null, {'customPaint.$list/-': ops});
}

/// [json] written as a formula literal (`{'k': v}`, `[a, b]`, `'text'`).
String _literal(Object? json) => switch (json) {
      null => 'null',
      final bool b => '$b',
      final num v => _n(v),
      final String t => "'${t.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'",
      final List l => '[${l.map(_literal).join(', ')}]',
      final Map m => '{${m.entries.map((e) => '${_literal('${e.key}')}: ${_literal(e.value)}').join(', ')}}',
      _ => _literal('$json'),
    };

// --- text countUp -------------------------------------------------------------------

const _countUpKeys = ['countUp', 'countUpDuration', 'countUpCurve', 'countUpOnShow'];

/// A text's number counting up (`countUp`, its own clock) → a transition of
/// `props.text` with its timing (a change of the number counts from the one
/// shown, written as the text writes it) and, with `countUpOnShow` (on by
/// default), an animation `countUp` whose track counts `props.text` from 0
/// when the text shows. Exact; one case differs: a value that changes while
/// the count from 0 still plays carries on toward the new value on the same
/// clock (the track's end is the text's own value), where the count started
/// again from the number shown.
final countUpStep = MigrationStep(
  id: 'text.countUp',
  description: 'a text\'s countUp → a transition (and an animation from 0) of props.text',
  node: (n, s) {
    if (_typeOf(n, s) != 'text') return;
    final taken = _take(n, _countUpKeys, s);
    if (taken == null) return;
    final (literal, bound) = taken;
    if (bound.isNotEmpty) {
      s.behaviourChange('A bound countUp setting has no single place to go; the count uses its literal values.',
          path: '/bind', old: bound, instead: 'Bind the transition\'s or the animation\'s duration instead.');
    }
    final on = loose(literal['countUp']) ?? false;
    final duration = readInt(literal['countUpDuration']) ?? 500;
    if (!on || duration <= 0) return;
    final curve = readString(literal['countUpCurve']);
    final timing = <String, Object?>{'duration': duration, if (curve != null && curve != 'linear') 'curve': curve};
    final transitions = [...?readList(n['transitions'])];
    if (!transitions.any((t) => readMap(t)?['property'] == 'props.text')) {
      final transition = {'property': 'props.text', ...timing};
      n['transitions'] = [...transitions, transition];
      s.rewrite('/props/countUp', true, {'transitions/-': transition}, 'A change of the number counts: a transition of props.text.');
    }
    if (loose(literal['countUpOnShow']) ?? true) {
      final animations = [...?readList(n['animations'])];
      final taken = {for (final a in animations) readMap(a)?['id'] ?? readMap(a)?['name']};
      var id = 'countUp';
      for (var i = 2; taken.contains(id); i++) {
        id = 'countUp$i';
      }
      final animation = {
        'id': id,
        ...timing,
        'tracks': [
          {'path': 'props.text', 'from': 0},
        ],
      };
      n['animations'] = [...animations, animation];
      s.rewrite('/props/countUpOnShow', true, {'animations/-': animation},
          'The count from 0 when it shows: an animation of props.text from 0.');
    }
  },
);

// --- slider -------------------------------------------------------------------------

const _sliderKeys = [
  'rulerTicks', 'rulerMajorEvery', 'rulerTickColor', 'rulerMinorTickColor', //
  'markerValue', 'markerColor', 'markerWidth', 'markerHeight',
  'activeTrackStartOpacity', 'thumbGripColor', 'deriveOverlayColorFromThumb',
];

/// A slider's ruler ticks, marker, fading track start and thumb grip → its
/// `customPaint` ops, drawn where the slider drew them: the ticks, the marker
/// and the fade in `painter` (over the track, under the thumb), the grip in
/// `foregroundPainter` (over the thumb). The ops read `size` (the slider's
/// box) and `slider` (`value`, `min`, `max`, `trackRect`, `thumbCenter`).
/// `deriveOverlayColorFromThumb`, read by no renderer, is dropped.
final sliderPaintStep = MigrationStep(
  id: 'slider.paint',
  description: 'a slider\'s ruler ticks, marker, track fade and thumb grip → customPaint ops',
  node: (n, s) {
    if (_typeOf(n, s) != 'slider') return;
    // What the slider is drawn with: the patched node's own props for a patch.
    final base = readMap(readMap(readMap(s.document?['nodes'])?[s.nodeId])?['props']) ?? const <String, Object?>{};
    final props = {...base, ...?readMap(n['props'])};
    final bindBefore = bindOf(n);
    final taken = _take(n, _sliderKeys, s);
    // A ruler track drew its ticks with none of their fields set too (20,
    // every fifth long, black); not again once they are ops.
    final drawsTicks = readString(props['trackShape']) == 'ruler' &&
        !(readList(readMap(n['customPaint'])?['painter']) ?? const []).any((o) => readMap(o)?['id'] == 'rulerTicks');
    if (taken == null && !(drawsTicks && n['type'] == 'slider')) return;
    final (literal, bound) = taken ?? (const <String, Object?>{}, const <String, String>{});
    if (n['customPaint'] != null && readMap(n['customPaint'])?['viewBox'] != null) {
      s.behaviourChange('The slider\'s customPaint has a view box: the ops written in the slider\'s pixels are drawn in it.',
          path: '/customPaint/viewBox');
    }
    final trackShape = readString(props['trackShape']);
    final ruler = trackShape == 'ruler';
    final painter = <Json>[], foreground = <Json>[];

    // The ruler's baseline and ticks (always drawn by a ruler track, 20
    // ticks, every fifth long, by default; black, short ones as the long).
    if ((ruler && drawsTicks) || bindBefore['props.trackShape'] != null) {
      final ticks = _term(literal, bound, 'rulerTicks', 20), every = _term(literal, bound, 'rulerMajorEvery', 5);
      final major = _colorOf(literal, bound, 'rulerTickColor', const Color(0xFF000000));
      final minor = bound['rulerMinorTickColor'] ?? Color.fromJson(literal['rulerMinorTickColor'])?.toJson() ?? major;
      final drawn = ruler ? null : '\${= ${formulaOf(bindBefore['props.trackShape']!) ?? 'false'} == \'ruler\'}';
      if (ticks != null && every != null) {
        Json stroke(Object? color) => {'style': 'stroke', 'strokeWidth': 1, 'color': color};
        const base = 'size.height / 2 + 1';
        const x = '\${= (size.width - 1) * index / $_ticks + 0.5}';
        painter.add({
          'op': 'line',
          'id': 'rulerBaseline',
          'p1': [0, '\${= $base}'],
          'p2': ['\${size.width}', '\${= $base}'],
          'paint': stroke(major),
          'when': ?drawn,
        });
        painter.add({
          'op': 'repeat',
          'id': 'rulerTicks',
          'count': '\${= $ticks + 1}',
          'when': ?drawn,
          'ops': [
            {
              'op': 'line',
              'when': '\${= index % $every == 0}',
              'p1': [x.replaceAll(_ticks, ticks), '\${= $base}'],
              'p2': [x.replaceAll(_ticks, ticks), '\${= $base - 8}'],
              'paint': stroke(major),
            },
            {
              'op': 'line',
              'when': '\${= index % $every != 0}',
              'p1': [x.replaceAll(_ticks, ticks), '\${= $base}'],
              'p2': [x.replaceAll(_ticks, ticks), '\${= $base - 4}'],
              'paint': stroke(minor),
            },
          ],
        });
      }
    }

    // A marker across the track at a value (not on a ruler track).
    final markerSet = literal['markerValue'] != null || bound.containsKey('markerValue');
    final fillFromEnd = readBool(props['fillFromEnd']) ?? false;
    if (markerSet && !ruler) {
      final v = _term(literal, bound, 'markerValue', 0);
      final w = _term(literal, bound, 'markerWidth', 2), h = _term(literal, bound, 'markerHeight', 14);
      if (v != null && w != null && h != null) {
        const t = 'slider.trackRect';
        painter.add({
          'op': 'rect',
          'id': 'marker',
          'when': '\${= slider.max > slider.min}',
          'rect': [
            '\${= $t.left + $t.width * clamp(($v - slider.min) / (slider.max - slider.min), 0, 1) - $w / 2}',
            '\${= $t.top + $t.height / 2 - $h / 2}',
            w.startsWith('(') ? '\${= $w}' : readDouble(w)!,
            h.startsWith('(') ? '\${= $h}' : readDouble(h)!,
          ],
          'paint': {'color': _colorOf(literal, bound, 'markerColor', Color.white)},
        });
      } else {
        s.behaviourChange('The marker\'s bound value is not a formula: it is not drawn.', path: '/bind', old: bound);
      }
      if (!fillFromEnd) {
        s.behaviourChange('The marker made the slider draw a plain rounded track; the track is now its trackShape\'s '
            '(Flutter\'s default when unset).', path: '/props/markerValue', instead: 'Set "trackShape" to the track you want.');
      }
    }

    // The active track fading in from its start: the inactive track's color
    // laid over it, from 1 − opacity to nothing.
    final opacity = readDouble(literal['activeTrackStartOpacity']);
    if (bound.containsKey('activeTrackStartOpacity') || (opacity != null && opacity < 1 && !ruler)) {
      final inactive = Color.fromJson(props['inactiveTrackColor']);
      final rtl = readBool(props['inverted']) ?? false;
      final onRight = fillFromEnd != rtl;
      if (bound.isEmpty && inactive != null && inactive.alpha == 255 && opacity != null && bindBefore.keys.every((k) => !k.startsWith('props.'))) {
        final height = readDouble(props['trackHeight']) ?? 4;
        final radius = trackShape == 'rectangle' ? 0 : height / 2;
        const t = 'slider.trackRect';
        painter.add({
          'op': 'rrect',
          'id': 'activeTrackFade',
          'rect': onRight
              ? ['\${slider.thumbCenter.x}', '\${$t.top}', '\${= $t.left + $t.width - slider.thumbCenter.x}', '\${$t.height}']
              : ['\${$t.left}', '\${$t.top}', '\${= slider.thumbCenter.x - $t.left}', '\${$t.height}'],
          'radius': radius,
          'when': onRight ? '\${= slider.thumbCenter.x < $t.left + $t.width}' : '\${= slider.thumbCenter.x > $t.left}',
          'paint': {
            'shader': {
              'type': 'linear',
              'begin': onRight ? 'centerRight' : 'centerLeft',
              'end': onRight ? 'centerLeft' : 'centerRight',
              'stops': [
                {'position': 0, 'color': inactive.withAlpha(((1 - opacity.clamp(0.0, 1.0)) * 255).round()).toJson()},
                {'position': 1, 'color': inactive.withAlpha(0).toJson()},
              ],
            },
          },
        });
        if (!fillFromEnd) {
          s.behaviourChange('The fade made the slider draw a plain rounded track; the track is now its trackShape\'s '
              '(Flutter\'s default when unset), with the fade over its active part.',
              path: '/props/activeTrackStartOpacity', instead: 'Set "trackShape" to the track you want.');
        }
      } else {
        s.behaviourChange('The track\'s fade needs a fixed, opaque inactiveTrackColor to be drawn over it: it is not drawn.',
            path: '/props/activeTrackStartOpacity', old: literal['activeTrackStartOpacity'] ?? bound['activeTrackStartOpacity'],
            instead: 'A customPaint "rrect" op over the active part ("slider.trackRect", "slider.thumbCenter") with a '
                'gradient of the inactive color.');
      }
    }

    // Grip lines across a rectangular thumb.
    final grip = _colorOf(literal, bound, 'thumbGripColor', null);
    if (grip != null && props['thumbShape'] == 'rectangle' && (readBool(props['showThumb']) ?? true)) {
      final size = readList(props['thumbSize']);
      final vertical = props['orientation'] == 'vertical';
      final w = readDouble(size?.elementAtOrNull(vertical ? 1 : 0)) ?? 20, h = readDouble(size?.elementAtOrNull(vertical ? 0 : 1)) ?? 20;
      if (bindBefore.keys.any((k) => k.startsWith('props.thumbSize') || k == 'props.showThumb' || k == 'props.thumbShape')) {
        s.behaviourChange('The grip is drawn at the thumb\'s literal size; its size or shape is bound.', path: '/props/thumbGripColor');
      }
      if (w > 0 && h > 0) {
        final width = w * 0.43;
        foreground.add({
          'op': 'rect',
          'id': 'thumbGrip',
          'rect': ['\${= slider.thumbCenter.x - ${_n(width / 2)}}', '\${= slider.thumbCenter.y - 1}', width, 2],
          'paint': {'color': grip},
        });
      }
    }
    _addOps(n, 'painter', painter, s, '/customPaint/painter');
    _addOps(n, 'foregroundPainter', foreground, s, '/customPaint/foregroundPainter');
  },
);

const _ticks = '<ticks>';

// --- text field ---------------------------------------------------------------------

const _highlightKeys = ['highlightStart', 'highlightEnd', 'highlightStyle'];

/// A text field's one highlighted range (`highlightStart` to `highlightEnd`
/// in `highlightStyle`) → the first of its `runs`. Bound ends make the runs
/// a formula (no run while either is null, as no highlight was).
final textFieldRunsStep = MigrationStep(
  id: 'textField.runs',
  description: 'a text field\'s highlightStart/End/Style → its runs',
  node: (n, s) {
    if (_typeOf(n, s) != 'textField') return;
    final taken = _take(n, _highlightKeys, s);
    if (taken == null) return;
    final (literal, bound) = taken;
    final style = readMap(literal['highlightStyle']);
    final hasStart = literal['highlightStart'] != null || bound.containsKey('highlightStart');
    final hasEnd = literal['highlightEnd'] != null || bound.containsKey('highlightEnd');
    // Nothing was highlighted without both ends.
    if (!hasStart || !hasEnd) return;
    final runs = [...?readList(readMap(n['props'])?['runs'])];
    if (bound.isEmpty) {
      final start = readInt(literal['highlightStart'])!, end = readInt(literal['highlightEnd'])!;
      if (end <= start) return;
      final run = {'start': start, 'end': end, if (style != null && style.isNotEmpty) 'style': style};
      n['props'] = {...?readMap(n['props']), 'runs': [run, ...runs]};
      s.rewrite('/props/runs', null, [run, ...runs]);
      return;
    }
    String? part(String key) {
      if (bound[key] case final String e) return formulaOf(e);
      return _literal(literal[key]);
    }

    final start = part('highlightStart'), end = part('highlightEnd');
    // The style's fields, a bound one as its formula.
    final styleFields = <String>[
      for (final e in (style ?? const <String, Object?>{}).entries)
        if (!bound.containsKey('highlightStyle.${e.key}')) '${_literal(e.key)}: ${_literal(e.value)}',
      for (final e in bound.entries)
        if (e.key.startsWith('highlightStyle.') && formulaOf(e.value) != null)
          '${_literal(e.key.substring('highlightStyle.'.length))}: (${formulaOf(e.value)})',
    ];
    final wholeStyle = bound['highlightStyle'] == null ? null : formulaOf(bound['highlightStyle']!);
    if (start == null || end == null || (bound['highlightStyle'] != null && wholeStyle == null)) {
      s.behaviourChange('A bound highlight that is not a formula can\'t be written as runs: nothing is highlighted.',
          path: '/bind', old: bound, instead: 'Bind "props.runs" to a list of {start, end, style}.');
      return;
    }
    final styleOut = wholeStyle != null ? '($wholeStyle)' : '{${styleFields.join(', ')}}';
    final rest = runs.isEmpty ? '' : ', ${runs.map(_literal).join(', ')}';
    final formula = '\${= ($start) == null || ($end) == null || ($end) <= ($start) ? [${rest.isEmpty ? '' : rest.substring(2)}] : '
        '[{\'start\': $start, \'end\': $end, \'style\': $styleOut}$rest]}';
    putBind(n, {...bindOf(n), 'props.runs': formula}, s);
  },
);

// --- date/time input ----------------------------------------------------------------

/// The named styles `formatDate` reads (an intl pattern is formatted the same
/// way by `format`).
const _namedDateStyles = {'full', 'long', 'medium', 'short', 'time', 'dayMonth', 'weekday', 'monthYear'};

/// A date/time input's `displayFormat` (an older name, read when `format` is
/// unset) → `format`.
final displayFormatStep = MigrationStep(
  id: 'dateTimeInput.format',
  description: 'a date/time input\'s displayFormat → format',
  node: (n, s) {
    if (_typeOf(n, s) != 'dateTimeInput') return;
    final props = readMap(n['props']);
    final format = readString(props?['format']);
    final hasFormat = (format != null && format.isNotEmpty) || bindOf(n).containsKey('props.format');
    final taken = _take(n, const ['displayFormat'], s);
    if (taken == null || hasFormat) return;
    final (literal, bound) = taken;
    if (bound['displayFormat'] case final String e) {
      putBind(n, {...bindOf(n), 'props.format': e}, s);
      return;
    }
    final pattern = readString(literal['displayFormat']);
    if (pattern == null || pattern.isEmpty) return;
    n['props'] = {...?readMap(n['props']), 'format': pattern};
    s.rewrite('/props/format', format, pattern);
    if (_namedDateStyles.contains(pattern.trim())) {
      s.behaviourChange('"$pattern" was formatDate\'s named style; format reads it as an intl pattern.',
          path: '/props/format', old: pattern, instead: 'Write the intl pattern the style stands for (full: "EEEE, MMMM d, y").');
    }
  },
);

// --- table --------------------------------------------------------------------------

/// A table's selected row edge (`selectedRowEdgeColor`, `selectedRowEdgeWidth`:
/// a bar at the start of the selected row) → its `cell` template's
/// `selected` state style: a left stroke of that color and width while
/// `selected` (bound to the cell being in the first column of the selected
/// row) holds. The same pixels when the template fills its cell and the
/// table has no horizontal padding (the bar was at the row's start, as tall
/// as the row); else reported.
final tableRowEdgeStep = MigrationStep(
  id: 'tableView.rowEdge',
  description: 'a table\'s selectedRowEdgeColor/Width → the cell template\'s selected state style',
  document: (d, s) {
    final nodes = readMap(d['nodes']);
    if (nodes == null) return;
    for (final e in nodes.entries) {
      final n = readMap(e.value);
      if (n == null || n['type'] != 'tableView') continue;
      final scope = MigrationScope.silent(s.step, nodeId: e.key, document: s.document);
      final taken = _take(n, const ['selectedRowEdgeColor', 'selectedRowEdgeWidth'], scope);
      if (taken == null) continue;
      s.rewrite('/nodes/${e.key}/props', taken.$1, null, 'The table\'s row edge leaves it.');
      final (literal, bound) = taken;
      final color = bound['selectedRowEdgeColor'] ?? Color.fromJson(literal['selectedRowEdgeColor'])?.toJson();
      if (color == null) continue;
      final width = bound['selectedRowEdgeWidth'] ?? readDouble(literal['selectedRowEdgeWidth']) ?? 4;
      final cellId = readString(readMap(n['slots'])?['cell']);
      final cell = cellId == null ? null : readMap(nodes[cellId]);
      final selected = bindOf(n)['props.selectedRow'] ?? '${readInt(readMap(n['props'])?['selectedRow']) ?? -1}';
      final row = formulaOf(selected);
      if (cell == null || row == null || bindOf(cell).containsKey('selected') || readMap(readMap(cell['states'])?['selected']) != null) {
        s.behaviourChange('The selected row\'s edge could not go on the table\'s cell template (none, or it is already '
            'selected by a binding of its own): it is not drawn.', path: '/nodes/${e.key}/props/selectedRowEdgeColor', old: color,
            instead: 'A "selected" state style on the cell template, with "selected" bound to the row being the selected one.');
        continue;
      }
      final patch = {
        'decoration': {
          'strokes': [
            {'color': color},
          ],
          'strokeWidth': width,
          'strokeSides': 'left',
        },
      };
      putBind(cell, {...bindOf(cell), 'selected': '\${= item.rowIndex == ($row) && item.columnIndex == 0}'},
          MigrationScope.silent(s.step, nodeId: cellId!));
      cell['states'] = {
        ...?readMap(cell['states']),
        'selected': {cellId: patch},
      };
      s.rewrite('/nodes/$cellId/states/selected', null, {cellId: patch}, 'The selected row\'s edge: the cell template\'s selected style.');
      final layout = readMap(cell['layout']);
      bool fills(Object? axis) => readMap(axis)?.containsKey('fill') ?? false;
      final strokes = readList(readMap(cell['decoration'])?['strokes']);
      final padding = readDouble(readMap(n['props'])?['horizontalPadding']) ?? 0;
      if (!fills(layout?['width']) || !fills(layout?['height']) || padding != 0 || (strokes != null && strokes.isNotEmpty)) {
        s.behaviourChange('The edge is drawn on the first cell\'s box, which is not the whole row\'s start (the template '
            'does not fill its cell, the table has horizontal padding, or the cell has strokes of its own, which the '
            'style replaces while selected).', path: '/nodes/$cellId/states/selected');
      }
    }
  },
);
