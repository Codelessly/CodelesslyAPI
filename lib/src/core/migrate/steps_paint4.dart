// Steps of the schema 3 → 4 migration that move the special-purpose paint
// features onto the general ones (docs/design/01-paint-node.md, "Schema 4"):
//
// * `strokePath` (a line through points behind or over a node) → a `path`
//   op of the node's `customPaint`, its stroke Flutter's `Paint`;
// * a `box` with `props.path` (a box drawn as an SVG path) → a `path` node,
//   the one decorated shape;
// * `props.subpathColors` and `gradientPerSubpath` (a path's shapes painted
//   one by one) → one `customPaint` path op per color or per shape;
// * the state and media patches that set any of them.
//
// Each step is written so the migrated document draws the same pixels; where
// a value has no exact form it is kept as `legacy.<name>` and reported, with
// what to write instead. `migrate3to4` applies [paintSteps4] after its other
// node steps (steps4.dart's `nodeSteps3to4`).
import '../custom_paint.dart' show Expr;
import '../json.dart';
import '../node.dart';
import '../node_patch.dart' show mergeNodePatch;
import '../behaviors.dart' show diffPatch;
import '../values/color.dart';
import '../values/paint.dart';
import '../widgets/flex.dart' show FlexProps;
import '../values/enums.dart' show Axis, CrossAxisAlignment;
import '../layout.dart' show SizeFit;
import 'legacy_read.dart';
import 'legacy_svg.dart';
import 'migrate.dart';

/// The paint steps of the schema 3 → 4 migration, in order.
/// The patches step comes first: it reads the nodes as they were.
final List<MigrationStep> paintSteps4 = [
  paintPatchesStep4,
  strokePathStep,
  boxPathStep,
  perShapePaintStep,
];

// --- helpers ----------------------------------------------------------------------

/// [v] as JSON number text a formula reads back as the same double.
String _n(double v) => v == v.roundToDouble() && v.abs() < 1e15 ? '${v.toInt()}' : '$v';

/// A number for JSON: whole numbers as ints.
num _j(double v) => jsonNum(v);

/// The node's `customPaint`, created when [create]; null when it has a view
/// box (ops in box pixels can't be added to it as they are).
Json? _customPaintOf(Json n) {
  final cp = readMap(n['customPaint']) ?? <String, Object?>{};
  if (cp['viewBox'] != null) return null;
  return cp;
}

List<Object?> _ops(Json cp, String key) => [...?readList(cp[key])];

/// Removes the binding keys [keys] from [n].
void _unbind(Json n, Iterable<String> keys, MigrationScope s) {
  final bind = bindOf(n);
  if (!keys.any(bind.containsKey)) return;
  putBind(n, {...bind}..removeWhere((k, _) => keys.contains(k)), s);
}

// --- strokePath ---------------------------------------------------------------------

/// The strokePath fields a binding may set and the step can still express.
const _boundOk = {'strokePath.points', 'strokePath.progress', 'strokePath.color'};

/// The schema-3 `strokePath` behavior read as its decoder read it.
final class _StrokePath {
  _StrokePath(Json m)
      : xFraction = (readString(m['xUnit']) ?? 'fraction') != 'pixels',
        yFraction = readString(m['yUnit']) == 'fraction',
        curve = switch (readString(m['curve'])) {
          'vertical' || 'horizontal' || 'quadratic' => readString(m['curve'])!,
          _ => 'straight',
        },
        color = Color.fromJson(m['color']) ?? Color.white,
        width = readDouble(m['width']) ?? 4,
        progress = (readDouble(m['progress']) ?? 1).clamp(0.0, 1.0),
        dashes = [...?readList(m['dashPattern'])?.map(readDouble).nonNulls.where((d) => d > 0)],
        cap = switch (readString(m['cap'])) {
          'butt' || 'square' => readString(m['cap'])!,
          _ => 'round',
        },
        inFront = readBool(m['inFront']) ?? false,
        drawMs = readInt(m['drawMs']) ?? 0,
        fill = Color.fromJson(m['fillColor']),
        untilWidth = readBool(m['untilWidth']) ?? false,
        points = [
          for (final p in readList(m['points']) ?? const []) ?_point(p),
        ];

  final bool xFraction, yFraction;
  final String curve, cap;
  final Color color;
  final Color? fill;
  final double width, progress;
  final List<double> dashes;
  final bool inFront, untilWidth;
  final int drawMs;
  final List<(double, double)> points;

  static (double, double)? _point(Object? p) {
    final l = readList(p);
    if (l != null) {
      final x = l.length == 2 ? readDouble(l[0]) : null, y = l.length == 2 ? readDouble(l[1]) : null;
      return x == null || y == null ? null : (x, y);
    }
    final m = readMap(p);
    final x = readDouble(m?['x']), y = readDouble(m?['y']);
    return x == null || y == null ? null : (x, y);
  }

  /// Coordinate [v] on an axis in pixels, or a formula of the box's size.
  Object x(double v) => xFraction ? _ofSize(v, 'width') : _j(v);
  Object y(double v) => yFraction ? _ofSize(v, 'height') : _j(v);

  static Object _ofSize(double v, String side) =>
      v == 0 ? 0 : (v == 1 ? '\${size.$side}' : '\${= ${_n(v)} * size.$side}');

  /// The midpoint of [a] and [b] on an axis, as the painter computed it.
  Object mid(double a, double b, {required bool fraction, required String side}) =>
      fraction ? '\${= (${_n(a)} * size.$side + ${_n(b)} * size.$side) / 2}' : _j((a + b) / 2);

  /// The geometry, as a path op's fields: `points` for straight lines,
  /// else Flutter `Path` calls. With [untilWidth], a call whose segment
  /// starts past the box's width (and every one after it) is skipped.
  Json geometry({required bool close}) {
    if (curve == 'straight' && !untilWidth) {
      return {
        'points': [for (final p in points) [x(p.$1), y(p.$2)]],
        if (close) 'close': true,
      };
    }
    final commands = <Json>[
      {'moveTo': [x(points.first.$1), y(points.first.$2)]},
    ];
    var furthest = points.first.$1;
    var stopped = false;
    // Whether a segment from x [from] is drawn; null: always.
    Object? until(double from) {
      if (!untilWidth) return null;
      if (from > furthest) furthest = from;
      if (xFraction) {
        // fx · width > width, for a box of any width: fx > 1.
        if (furthest > 1) stopped = true;
        return null;
      }
      return furthest <= 0 ? null : '\${= size.width >= ${_n(furthest)}}';
    }

    void add(String method, List<Object> args, double from) {
      final when = until(from);
      if (stopped) return;
      commands.add({method: args, 'when': ?when});
    }

    var prev = points.first;
    if (curve == 'quadratic') {
      for (var i = 1; i < points.length && !stopped; i += 2) {
        final c = points[i];
        if (i + 1 >= points.length) {
          add('lineTo', [x(c.$1), y(c.$2)], prev.$1);
          break;
        }
        final e = points[i + 1];
        add('quadraticBezierTo', [x(c.$1), y(c.$2), x(e.$1), y(e.$2)], prev.$1);
        prev = e;
      }
    } else {
      for (final p in points.skip(1)) {
        if (stopped) break;
        switch (curve) {
          case 'vertical':
            final my = mid(prev.$2, p.$2, fraction: yFraction, side: 'height');
            add('cubicTo', [x(prev.$1), my, x(p.$1), my, x(p.$1), y(p.$2)], prev.$1);
          case 'horizontal':
            final mx = mid(prev.$1, p.$1, fraction: xFraction, side: 'width');
            add('cubicTo', [mx, y(prev.$2), mx, y(p.$2), x(p.$1), y(p.$2)], prev.$1);
          default:
            add('lineTo', [x(p.$1), y(p.$2)], prev.$1);
        }
        prev = p;
      }
    }
    if (close) commands.add({'close': true});
    return {'commands': commands};
  }
}

/// `strokePath` → a `path` op in the node's `customPaint`: in
/// `foregroundPainter` with `inFront`, else first in `painter` (drawn just
/// outside the content, as the stroke path was). Fractions of the box
/// become formulas of `size`; `progress` becomes `trimEnd`; the line is
/// Flutter's `Paint` with `strokeJoin: round`; `fillColor` is a closed path
/// op under it. The draw-on animation (`drawMs` and the fields that time
/// it) has no exact form: it is kept as `legacy.strokePath.draw`.
final strokePathStep = MigrationStep(
  id: 'paint.strokePath',
  description: 'strokePath → a customPaint path op',
  node: (n, s) {
    final raw = n['strokePath'];
    final bind = bindOf(n);
    final bound = {
      for (final e in bind.entries)
        if (e.key == 'strokePath' || e.key.startsWith('strokePath.')) e.key: e.value,
    };
    if (raw == null && bound.isEmpty) return;
    var m = readMap(raw);
    if (m == null && bound.isEmpty) {
      n.remove('strokePath');
      s.rewrite('/strokePath', raw, null, 'strokePath was not an object: it drew nothing.');
      return;
    }
    m ??= <String, Object?>{};
    final sp = _StrokePath(m);
    final boundPoints = bound['strokePath.points'];
    final boundProgress = bound['strokePath.progress'];
    final boundColor = bound['strokePath.color'];

    // What has no exact customPaint form keeps the whole behavior.
    final why = <String>[
      for (final k in bound.keys)
        if (!_boundOk.contains(k)) 'a binding of "$k"',
      for (final v in bound.values)
        if (!Expr.isSource(v)) 'a binding that is not an expression ("$v")',
      if (boundPoints != null && (sp.xFraction || sp.yFraction)) 'bound points in fractions of the box',
      if (boundPoints != null && sp.curve != 'straight') 'bound points joined by "${sp.curve}" curves',
      if (boundPoints != null && sp.untilWidth) 'bound points with untilWidth',
      if (boundProgress != null && sp.fill != null) 'a fill that fades with a bound progress',
      if (_customPaintOf(n) == null) 'a customPaint with a viewBox on the same node',
    ];
    if (why.isNotEmpty) {
      n.remove('strokePath');
      _unbind(n, bound.keys, s);
      s.unconvertible(n, 'strokePath', {'value': raw, if (bound.isNotEmpty) 'bind': bound},
          path: '/strokePath',
          instead: 'Draw it with "customPaint": a "path" op with "points" (or "commands"), a stroke "paint" and "trimEnd" '
              'for the progress (docs/design/01-paint-node.md, "Schema 4").',
          message: 'strokePath has no exact customPaint form here (${why.join('; ')}); kept as `legacy.strokePath`.');
      s.behaviourChange('The stroke path is no longer drawn.', path: '/strokePath', old: raw);
      return;
    }

    n.remove('strokePath');
    _unbind(n, bound.keys, s);

    // The draw-on animation.
    final draw = {for (final k in const ['drawMs', 'drawDelayMs', 'drawCurve', 'drawKey']) if (m.containsKey(k)) k: m[k]};
    if (draw.isNotEmpty) {
      if (sp.drawMs > 0) {
        s.unconvertible(n, 'strokePath.draw', draw,
            path: '/strokePath/drawMs',
            instead: 'An animation (doc 02) with a track on a variable, from 0 to the progress, played on load and when the '
                'key changes, the variable bound into the op\'s "trimEnd".',
            message: 'The draw-on animation (drawMs) has no customPaint form; kept as `legacy.strokePath.draw`.');
        s.behaviourChange('The stroke path no longer draws itself on: it shows at its progress at once.',
            path: '/strokePath/drawMs', old: draw);
      } else {
        s.rewrite('/strokePath', draw, null, 'drawDelayMs/drawCurve/drawKey dropped: without drawMs they did nothing.');
      }
    }

    // Nothing drawn: no op.
    final literalPoints = boundPoints == null;
    if ((literalPoints && sp.points.length < 2) || (boundProgress == null && sp.progress <= 0)) {
      s.rewrite('/strokePath', raw, null, 'strokePath drew nothing (fewer than 2 points, or progress 0): dropped.');
      return;
    }

    Json geometry({required bool close}) =>
        literalPoints ? sp.geometry(close: close) : {'points': boundPoints, if (close) 'close': true};

    final ops = <Json>[];
    if (sp.fill case final fill? when !literalPoints || sp.points.length >= 3) {
      // The enclosed shape, fading in as the line draws (its alpha times
      // the progress).
      final a = fill.opacity * sp.progress;
      final color = sp.progress >= 1 ? fill : fill.withAlpha((a * 255).round());
      if (sp.progress < 1 && sp.progress > 0) {
        s.rewrite('/strokePath/fillColor', fill.toJson(), color.toJson(),
            'The fill\'s alpha times the progress, written into the color (rounded to 8 bits).');
      }
      ops.add({'op': 'path', 'id': 'strokePathFill', ...geometry(close: true), 'paint': color.toJson()});
    }
    if (sp.width > 0) {
      ops.add({
        'op': 'path',
        'id': 'strokePath',
        ...geometry(close: false),
        if (boundProgress != null) 'trimEnd': boundProgress else if (sp.progress < 1) 'trimEnd': _j(sp.progress),
        'paint': {
          'color': boundColor ?? sp.color.toJson(),
          'style': 'stroke',
          'strokeWidth': _j(sp.width),
          if (sp.cap != 'butt') 'strokeCap': sp.cap,
          'strokeJoin': 'round',
          if (sp.dashes.isNotEmpty) 'dashPattern': [for (final d in sp.dashes) _j(d)],
        },
      });
    }
    final cp = _customPaintOf(n)!;
    if (sp.inFront) {
      cp['foregroundPainter'] = [..._ops(cp, 'foregroundPainter'), ...ops];
    } else {
      cp['painter'] = [...ops, ..._ops(cp, 'painter')];
    }
    if (ops.isNotEmpty) n['customPaint'] = cp;
    s.rewrite('/strokePath', {'value': raw, if (bound.isNotEmpty) 'bind': bound}, {
      'customPaint/${sp.inFront ? 'foregroundPainter' : 'painter'}': ops,
    });
  },
);

// --- box.path -----------------------------------------------------------------------

bool _visible(Object? p) => readBool(readMap(p)?['visible']) ?? true;
List<Json> _paints(Json? d, String key) => [...?readList(d?[key])?.map(readMap).nonNulls];

/// A box with `props.path` → a `path` node: `props.data` the path, its
/// `strokeJoin` and `strokeMiterLimit` kept; `gradientPerSubpath` on its
/// paints (which a box never read) dropped. Where the box painter differed
/// from the path node's, it is reported: fills clipped to a rounded
/// rectangle too, a gradient stroke drawn in its first color, foreground
/// fills, dashes beyond one dash and gap, inner shadows (not drawn on a
/// box), blending fills, and a bare box a stretching row or column sizes.
/// A box without a path loses `strokeJoin` and `strokeMiterLimit` (unread).
final boxPathStep = MigrationStep(
  id: 'paint.boxPath',
  description: 'a box drawn as an SVG path → a path node',
  document: (doc, s) {
    // A bare box filling across a stretching row/column that hugs that axis
    // takes its siblings' thickness; a path node there does not.
    final nodes = readMap(doc['nodes']) ?? const <String, Object?>{};
    for (final e in nodes.entries) {
      final p = readMap(e.value);
      if (p == null || !const {'row', 'column', 'flex'}.contains(p['type'])) continue;
      final parent = Node.fromJson(p, id: e.key);
      if (parent == null || parent.prop(FlexProps.crossAxisAlignment) != CrossAxisAlignment.stretch) continue;
      final row = p['type'] == 'row' || (p['type'] == 'flex' && parent.prop(FlexProps.direction) == Axis.horizontal);
      if ((row ? parent.layout.height.fit : parent.layout.width.fit) != SizeFit.hug) continue;
      for (final id in parent.children) {
        final c = readMap(nodes[id]);
        if (c == null || c['type'] != 'box' || !_hasPath(c)) continue;
        final child = Node.fromJson(c, id: id);
        if (child == null || child.children.isNotEmpty) continue;
        if ((row ? child.layout.height.fit : child.layout.width.fit) != SizeFit.fill) continue;
        s.behaviourChange(
            'Box "$id" with a path filled across a stretching ${p['type']} that hugs it, sized by its siblings; as a path node it takes its design size there.',
            path: '/nodes/$id/layout',
            instead: 'Give it a fixed size across the ${p['type']}.');
      }
    }
  },
  node: (n, s) {
    final type = n['type'];
    if (type != 'box' && type != null) return;
    final props = readMap(n['props']);
    final bind = bindOf(n);
    if (!_hasPath(n)) {
      if (type != 'box' || props == null) return;
      for (final k in const ['path', 'strokeJoin', 'strokeMiterLimit']) {
        if (props.containsKey(k)) s.rewrite('/props/$k', props.remove(k), null, 'box.$k dropped: a box without a path never read it.');
      }
      if (props.isEmpty) {
        n.remove('props');
      } else {
        n['props'] = props;
      }
      _unbind(n, const ['props.strokeJoin', 'props.strokeMiterLimit'], s);
      return;
    }
    final out = <String, Object?>{...?props};
    final path = out.remove('path');
    if (path != null) out['data'] = path;
    if (type == 'box') n['type'] = 'path';
    n['props'] = out;
    s.rewrite('/props/path', path, path, type == 'box' ? 'box with a path → path node (props.data)' : 'props.path → props.data');
    if (bind.containsKey('props.path')) {
      putBind(n, {for (final e in bind.entries) e.key == 'props.path' ? 'props.data' : e.key: e.value}, s);
      s.behaviourChange('While the bound path is empty the node draws nothing (a box drew its rectangle).',
          path: '/bind/props.path', instead: 'Bind "visible" to whether the path is empty, with a box beside it.');
    }
    final d = readMap(n['decoration']);
    if (d == null) return;
    // gradientPerSubpath: a box never read it.
    var dropped = false;
    for (final key in const ['fills', 'strokes', 'foregroundFills']) {
      final list = readList(d[key]);
      if (list == null) continue;
      for (var i = 0; i < list.length; i++) {
        final p = readMap(list[i]);
        if (p == null || !p.containsKey('gradientPerSubpath')) continue;
        s.rewrite('/decoration/$key/$i/gradientPerSubpath', p.remove('gradientPerSubpath'), null,
            'gradientPerSubpath dropped: a box drawn as a path never read it.');
        list[i] = p;
        dropped = true;
      }
      if (dropped) d[key] = list;
    }
    if (dropped) n['decoration'] = d;
    // Where the two painters differ.
    void differs(String what, String at, String instead) => s.behaviourChange(what, path: at, instead: instead);
    final fills = _paints(d, 'fills').where(_visible).toList();
    // The box filled the part of the path inside its own rectangle.
    final layout = readMap(n['layout']);
    final w = readDouble(layout?['width']), h = readDouble(layout?['height']);
    final parts = svgSubpaths('$path') ?? const [];
    if (fills.isNotEmpty && w != null && h != null && parts.isNotEmpty) {
      final out = parts.any((p) => p.left < -0.01 || p.top < -0.01 || p.right > w + 0.01 || p.bottom > h + 0.01);
      if (out) {
        differs('The path reaches outside the box: its fill is drawn there too (the box filled only the part inside its rectangle).',
            '/props/data', 'Clip it: put it in a box with "decoration": {"clip": "antiAlias"}, or keep the path inside its box.');
      }
    }
    final strokes = _paints(d, 'strokes').where(_visible).toList();
    final width = readDouble(d['strokeWidth']) ?? 0;
    final radius = d['radius'];
    if (fills.isNotEmpty && radius != null && radius != 0 && !(readList(radius)?.every((r) => r == 0) ?? false)) {
      differs('The box clipped its fills to its rounded rectangle as well as the path; the path node fills the path only.',
          '/decoration/radius', 'Round the path\'s own corners.');
    }
    if (width > 0 && strokes.any((p) => const {'linear', 'radial', 'angular', 'diamond', 'sweep'}.contains(p['type']))) {
      differs('A gradient stroke is drawn as a gradient (the box drew it in its first stop\'s color).', '/decoration/strokes',
          'A solid stroke of that color.');
    }
    if (_paints(d, 'foregroundFills').any(_visible)) {
      differs('Foreground fills are not drawn by a path node (the box drew them over its stroke, clipped to the path).',
          '/decoration/foregroundFills', 'A second path node over it, filled.');
    }
    final dashes = [...?readList(d['dashPattern'])?.map(readDouble).nonNulls];
    if (width > 0 && strokes.isNotEmpty && dashes.any((v) => v > 0) &&
        (dashes.length > 2 || (svgSubpaths('$path')?.length ?? 1) > 1)) {
      differs('Dashes follow the whole pattern along the whole outline (the box used the first dash and gap, starting each subpath on a dash).',
          '/decoration/dashPattern', 'Write the pattern you want.');
    }
    if (_paints(d, 'effects').any((e) => _visible(e) && e['type'] == 'innerShadow')) {
      differs('Inner shadows are drawn inside the path (the box drew none).', '/decoration/effects', 'Remove them.');
    }
    if (fills.any((p) => (readString(p['blendMode']) ?? 'srcOver') != 'srcOver')) {
      differs('Blending fills blend with the fills under them only (the path node draws them in a layer).',
          '/decoration/fills', 'None needed.');
    }
  },
);

bool _hasPath(Json n) {
  final p = readMap(n['props'])?['path'];
  return (p is String && p.trim().isNotEmpty) || bindOf(n).containsKey('props.path');
}

// --- per-shape paints -----------------------------------------------------------

const _gradients = {'linear', 'radial', 'angular', 'diamond', 'sweep'};

/// The colors of `subpathColors`: a list, or text split at commas, spaces
/// or semicolons; an entry that is not a color is null.
List<Color?> _colors(Object? j) {
  final items = switch (j) {
    final List l => l,
    final String s => s.split(RegExp(r'[\s,;]+')).where((e) => e.isNotEmpty).toList(),
    _ => const [],
  };
  return [for (final e in items) Color.fromHex(e is String ? e.trim() : e)];
}

/// A path node's `subpathColors` and the `gradientPerSubpath` of its fills
/// and strokes → `customPaint` path ops on the node: a solid fill becomes
/// one op per color (the shapes of that color in one path, in the order the
/// colors first appear, as the painter merged them), a per-shape gradient
/// one op per shape (its gradient laid out in the shape's bounds), and the
/// fills leave the decoration. When strokes are per shape, the strokes move
/// to `foregroundPainter` the same way. `gradientPerSubpath` anywhere else
/// (a box, a text, a custom paint's shader) never acted and is dropped.
///
/// Exact only for a path node without a view box or visible effects whose
/// visible fills are solid colors or per-shape gradients (and strokes,
/// when moved, solid or per-shape and not trimmed or dashed); otherwise
/// the value is kept as `legacy.<name>` and reported.
final perShapePaintStep = MigrationStep(
  id: 'paint.perShape',
  description: 'subpathColors and gradientPerSubpath → customPaint ops per color or per shape',
  node: (n, s) {
    final isPath = n['type'] == 'path';
    final decoration = readMap(n['decoration']);
    // Where a per-shape gradient was read: a path node's fills and strokes.
    bool read(String at) => isPath && RegExp(r'^/decoration/(fills|strokes)/\d+$').hasMatch(at);
    eachMap(n, (m, at) {
      if (!m.containsKey('gradientPerSubpath') || read(at)) return;
      s.rewrite('$at/gradientPerSubpath', m.remove('gradientPerSubpath'), null, 'gradientPerSubpath dropped: only a path node\'s own paints read it.');
    });
    if (!isPath) return;
    final props = readMap(n['props']) ?? <String, Object?>{};
    final bind = bindOf(n);
    final colors = _colors(props['subpathColors']);
    final boundColors = bind['props.subpathColors'];
    final d = decoration ?? <String, Object?>{};
    final fills = [...?readList(d['fills'])];
    final strokes = [...?readList(d['strokes'])];
    bool perShape(Object? p) => readBool(readMap(p)?['gradientPerSubpath']) ?? false;
    final width = readDouble(d['strokeWidth']) ?? 0;
    final perFill = fills.any((p) => _visible(p) && perShape(p) && _gradients.contains(readMap(p)?['type']));
    final perStroke = width > 0 && strokes.any((p) => _visible(p) && perShape(p) && _gradients.contains(readMap(p)?['type']));
    final data = readString(props['data']) ?? '';
    // A view box `[width, height]` (the path node's) scales the data onto the box.
    final viewBox = readList(props['viewBox'])?.map(readDouble).toList();
    final hasViewBox = viewBox != null && viewBox.length == 2 && viewBox.every((v) => v != null && v > 0);

    // Clean what did nothing first: false flags, flags on solid paints,
    // empty colors.
    void dropInert(List<Object?> list, String key, bool moving) {
      for (var i = 0; i < list.length; i++) {
        final p = readMap(list[i]);
        if (p == null || !p.containsKey('gradientPerSubpath')) continue;
        final acts = perShape(p) && _visible(p) && _gradients.contains(p['type']) && (key == 'fills' || width > 0);
        if (acts && moving) continue;
        if (!acts) {
          s.rewrite('/decoration/$key/$i/gradientPerSubpath', p.remove('gradientPerSubpath'), null, 'gradientPerSubpath dropped: it did nothing here.');
          list[i] = p;
        }
      }
    }

    if (colors.isEmpty && boundColors == null && !perFill && !perStroke) {
      dropInert(fills, 'fills', false);
      dropInert(strokes, 'strokes', false);
      if (decoration != null) {
        if (fills.isNotEmpty) d['fills'] = fills;
        if (strokes.isNotEmpty) d['strokes'] = strokes;
        n['decoration'] = d;
      }
      if (props.containsKey('subpathColors')) {
        s.rewrite('/props/subpathColors', props.remove('subpathColors'), null, 'subpathColors dropped: empty, it did nothing.');
        n['props'] = props;
      }
      return;
    }

    final shapes = data.trim().isEmpty ? null : svgShapes(data);
    final visibleFills = fills.where(_visible).map(readMap).nonNulls.toList();
    final visibleStrokes = strokes.where(_visible).map(readMap).nonNulls.where((p) => p['type'] != 'image').toList();
    final paintsFills = colors.isNotEmpty || perFill;
    final why = <String>[
      if (boundColors != null) 'bound subpathColors',
      if (shapes == null) 'path data that cannot be read',
      if (hasViewBox && perStroke) 'strokes per shape under a viewBox',
      if (hasViewBox && _ops(readMap(n['customPaint']) ?? const {}, 'painter').isNotEmpty) 'a viewBox and other custom paint ops',
      if (hasViewBox && _ops(readMap(n['customPaint']) ?? const {}, 'foregroundPainter').isNotEmpty) 'a viewBox and other custom paint ops',
      if (_paints(d, 'effects').any(_visible)) 'visible effects (shadows drawn between its paints)',
      if (_customPaintOf(n) == null) 'a customPaint with a viewBox on the same node',
      if (paintsFills)
        for (final f in visibleFills)
          if ((readString(f['blendMode']) ?? 'srcOver') != 'srcOver')
            'a blending fill'
          else if (f['type'] == 'image' || f['type'] == 'noise')
            'an ${f['type']} fill'
          else if (_gradients.contains(f['type']) && !perShape(f))
            'a gradient fill laid out across the box',
      if (perStroke) ...[
        if ((readDouble(props['trimStart']) ?? 0) > 0 || (readDouble(props['trimEnd']) ?? 1) < 1) 'a trimmed stroke',
        if (readList(d['dashPattern'])?.isNotEmpty ?? false) 'a dashed stroke',
        for (final p in visibleStrokes)
          if (_gradients.contains(p['type']) && !perShape(p)) 'a gradient stroke laid out across the box',
      ],
    ];
    if (why.isNotEmpty) {
      final kept = {
        if (props.containsKey('subpathColors')) 'subpathColors': props.remove('subpathColors'),
        'bind': ?boundColors,
      };
      if (kept.isNotEmpty) {
        n['props'] = props;
        _unbind(n, const ['props.subpathColors'], s);
        s.unconvertible(n, 'props.subpathColors', kept,
            path: '/props/subpathColors',
            instead: 'One customPaint "path" op per color, each with the SVG data of its shapes.',
            message: 'subpathColors has no exact form here (${why.join('; ')}); kept as `legacy.props.subpathColors`.');
        s.behaviourChange('The path\'s shapes are no longer colored one by one: the fills\' colors fill the whole path.',
            path: '/props/subpathColors');
      }
      if (perFill || perStroke) {
        for (final (key, list) in [('fills', fills), ('strokes', strokes)]) {
          for (var i = 0; i < list.length; i++) {
            final p = readMap(list[i]);
            if (p == null || !p.containsKey('gradientPerSubpath')) continue;
            final v = p.remove('gradientPerSubpath');
            list[i] = p;
            if (v != true) continue;
            s.unconvertible(n, 'decoration.$key.$i.gradientPerSubpath', v,
                path: '/decoration/$key/$i/gradientPerSubpath',
                instead: 'One customPaint "path" op per shape, each with the gradient as its paint\'s shader.',
                message: 'gradientPerSubpath has no exact form here (${why.join('; ')}); kept as `legacy.decoration.$key.$i.gradientPerSubpath`.');
            s.behaviourChange('The gradient is laid out across the whole path, not in each shape.', path: '/decoration/$key/$i');
          }
          if (list.isNotEmpty) d[key] = list;
        }
        n['decoration'] = d;
      }
      return;
    }

    // The ops.
    final shapeList = shapes!;
    final painter = <Json>[];
    final foreground = <Json>[];
    var approximate = false;
    Json shader(Json p) => {...p}..remove('gradientPerSubpath');
    if (shapeList.any((sh) => sh.subpaths.any((sp) => !sp.absoluteStart))) approximate = true;
    if (paintsFills) {
      for (final f in visibleFills) {
        final paint = Paint.fromJson(f)!;
        if (paint.isGradient) {
          approximate = true;
          for (final sh in shapeList) {
            painter.add({'op': 'path', 'd': sh.text, 'paint': {'shader': shader(f)}});
          }
          continue;
        }
        final base = paint.effectiveColor ?? Color.transparent;
        if (colors.isEmpty) {
          painter.add({'op': 'path', 'd': data, 'paint': base.toJson()});
          continue;
        }
        // One path per color, in the order the colors first appear.
        final byColor = <Color?, List<SvgShape>>{};
        for (var i = 0; i < shapeList.length; i++) {
          byColor.putIfAbsent(colors[i % colors.length], () => []).add(shapeList[i]);
        }
        for (final e in byColor.entries) {
          final c = e.key;
          Color color;
          if (c == null) {
            color = base;
          } else if (base.alpha == 255) {
            color = c;
          } else {
            approximate = true;
            color = c.withAlpha((c.opacity * base.opacity * 255).round());
          }
          painter.add({'op': 'path', 'd': e.value.map((sh) => sh.text).join(' '), 'paint': color.toJson()});
        }
      }
      d['fills'] = [for (final f in fills) if (!_visible(f)) f];
    } else {
      // Only the strokes move; the fills keep drawing in the node.
      for (var i = 0; i < fills.length; i++) {
        final p = readMap(fills[i]);
        if (p != null && p.containsKey('gradientPerSubpath')) {
          s.rewrite('/decoration/fills/$i/gradientPerSubpath', p.remove('gradientPerSubpath'), null);
          fills[i] = p;
        }
      }
      d['fills'] = fills;
    }
    if (perStroke) {
      final cap = readString(d['strokeCap']) ?? 'butt';
      final join = readString(props['strokeJoin']) ?? 'miter';
      final miter = readDouble(props['strokeMiterLimit']) ?? 4;
      Json strokePaint(Json extra) => {
        ...extra,
        'style': 'stroke',
        'strokeWidth': _j(width),
        if (cap != 'butt') 'strokeCap': cap,
        if (join != 'miter') 'strokeJoin': join,
        if (miter != 4) 'strokeMiterLimit': _j(miter),
      };
      for (final p in visibleStrokes) {
        final paint = Paint.fromJson(p)!;
        if (paint.isGradient) {
          approximate = true;
          for (final sh in shapeList) {
            foreground.add({'op': 'path', 'd': sh.text, 'paint': strokePaint({'shader': shader(p)})});
          }
        } else if (paint.effectiveColor case final c?) {
          foreground.add({'op': 'path', 'd': data, 'paint': strokePaint({'color': c.toJson()})});
        }
      }
      d['strokes'] = [for (final p in strokes) if (!_visible(p) || readMap(p)?['type'] == 'image') p];
    }
    final cp = _customPaintOf(n)!;
    // The data in the path's view box, mapped onto the box as the path is
    // (stretched, `BoxFit.fill`).
    if (hasViewBox && painter.isNotEmpty) cp['viewBox'] = [for (final v in viewBox) _j(v!)];
    if (painter.isNotEmpty) cp['painter'] = [..._ops(cp, 'painter'), ...painter];
    if (foreground.isNotEmpty) cp['foregroundPainter'] = [...foreground, ..._ops(cp, 'foregroundPainter')];
    n['customPaint'] = cp;
    if ((d['fills'] as List?)?.isEmpty ?? false) d.remove('fills');
    if ((d['strokes'] as List?)?.isEmpty ?? false) d.remove('strokes');
    if (d.isEmpty) {
      n.remove('decoration');
    } else {
      n['decoration'] = d;
    }
    final old = props.remove('subpathColors');
    // The node itself draws nothing now (its fills are ops, and no stroke
    // is left): the data lives in the ops only.
    final strokesLeft = width > 0 && _paints(d, 'strokes').any(_visible);
    if (!strokesLeft && !_paints(d, 'fills').any(_visible)) {
      props.remove('data');
      props.remove('viewBox');
    }
    n['props'] = props;
    s.rewrite('/customPaint', {'subpathColors': ?old, 'gradientPerSubpath': perFill || perStroke},
        {'painter': painter, 'foregroundPainter': foreground},
        approximate
            ? 'Per-shape paints → customPaint path ops; within a pixel\'s rounding (a gradient laid out in the shape\'s exact bounds, a translucent fill\'s alpha in 8 bits, or a subpath starting with a relative move).'
            : 'Per-shape paints → customPaint path ops.');
  },
);

// --- patches -------------------------------------------------------------------------

/// The interaction-state and media patches that set any of the fields the
/// node steps above move: each re-expressed as the patch of the migrated
/// node that gives the node the migrated patched node is.
final paintPatchesStep4 = MigrationStep(
  id: 'paint.patches',
  description: 'state and media patches setting strokePath, a box path or per-shape paints → schema-4 patches',
  document: (doc, s) {
    final steps = [strokePathStep, boxPathStep, perShapePaintStep];
    final nodes = readMap(doc['nodes']) ?? const <String, Object?>{};
    Json migrate(Json node) {
      final out = copyJson(node) as Json;
      for (final step in steps) {
        step.node!(out, MigrationScope.silent(step));
      }
      return out;
    }

    bool touches(Json patch) {
      var hit = patch.containsKey('strokePath') || bindOf(patch).keys.any((k) => k.startsWith('strokePath') || k == 'props.path');
      final props = readMap(patch['props']);
      if (props != null && (props.containsKey('path') || props.containsKey('subpathColors'))) hit = true;
      eachMap(patch, (m, _) {
        if (m.containsKey('gradientPerSubpath')) hit = true;
      });
      return hit;
    }

    Json? repatch(Json? target, Json patch) {
      if (target == null) return null;
      final base = {...target}
        ..remove('states')
        ..remove('media');
      final after = migrate(mergeNodePatch(base, patch));
      final same = migrate(mergeNodePatch(base, const {}));
      return diffPatch(same, after) ?? const {};
    }

    for (final e in nodes.entries) {
      final node = readMap(e.value);
      if (node == null) continue;
      final states = readMap(node['states']);
      if (states != null) {
        for (final st in states.entries) {
          final per = readMap(st.value);
          if (per == null) continue;
          for (final p in per.entries) {
            final patch = readMap(p.value);
            if (patch == null || !touches(patch)) continue;
            final out = repatch(readMap(nodes[p.key]), patch);
            if (out == null || jsonEquality.equals(out, patch)) continue;
            s.rewrite('/nodes/${e.key}/states/${st.key}/${p.key}', patch, out);
            per[p.key] = out;
          }
          states[st.key] = per;
        }
        node['states'] = states;
      }
      final media = readList(node['media']);
      if (media != null) {
        for (var i = 0; i < media.length; i++) {
          final rule = readMap(media[i]);
          final patch = readMap(rule?['patch']);
          if (rule == null || patch == null || !touches(patch)) continue;
          final out = repatch(node, patch);
          if (out == null || jsonEquality.equals(out, patch)) continue;
          s.rewrite('/nodes/${e.key}/media/$i/patch', patch, out);
          rule['patch'] = out;
          media[i] = rule;
        }
        node['media'] = media;
      }
    }
  },
);
