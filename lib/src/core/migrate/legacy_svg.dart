// SVG path data split into the shapes schema 3's per-shape paints colored
// one by one (`subpathColors`, `gradientPerSubpath`), for the schema-4 step
// that draws them with `customPaint` ops instead. Pure Dart: it reads the
// data as the SDK's parser does (path_parsing) only as far as needed to
// find each subpath, its start point and its control-point bounds; the
// geometry itself stays the original text.
import 'dart:math' as math;

/// One subpath of SVG path data: its text (from its `M`, or from the
/// command after a `Z` that starts it), and its bounds over end and control
/// points (arcs as the cubics they are drawn as).
final class SvgSubpath {
  SvgSubpath(this.text, this.left, this.top, this.right, this.bottom, {required this.absoluteStart});

  /// The subpath as SVG path data that draws it on its own.
  final String text;
  final double left, top, right, bottom;

  /// Whether [text] is the original text (it starts with an absolute `M`);
  /// false: a start point was written in front of it.
  final bool absoluteStart;
}

/// One shape: a subpath and the subpaths after it that lie inside its
/// bounds (its holes), as the SDK's `PathShapes` groups them.
final class SvgShape {
  SvgShape(this.subpaths);
  final List<SvgSubpath> subpaths;
  String get text => subpaths.map((s) => s.text).join(' ');
}

/// [data] as its shapes, in drawing order; null when it can't be read.
List<SvgShape>? svgShapes(String data) {
  final subpaths = svgSubpaths(data);
  if (subpaths == null) return null;
  final shapes = <SvgShape>[];
  SvgSubpath? head;
  for (final s in subpaths) {
    if (head != null &&
        s.left >= head.left - 0.01 &&
        s.top >= head.top - 0.01 &&
        s.right <= head.right + 0.01 &&
        s.bottom <= head.bottom + 0.01) {
      shapes.last.subpaths.add(s);
      continue;
    }
    head = s;
    shapes.add(SvgShape([s]));
  }
  return shapes;
}

/// The subpaths of [data] that draw something, in order; null when it can't
/// be read.
List<SvgSubpath>? svgSubpaths(String data) {
  try {
    return _Splitter(data).run();
  } catch (_) {
    return null;
  }
}

String _num(double v) => v == v.roundToDouble() && v.abs() < 1e15 ? '${v.toInt()}' : '$v';

class _Splitter {
  _Splitter(this.s);
  final String s;
  int i = 0;

  final List<SvgSubpath> out = [];
  double cx = 0, cy = 0, sx = 0, sy = 0;

  // The subpath being read.
  int? start;
  String prefix = '';
  bool absolute = true, drawn = false, closed = false;
  double l = 0, t = 0, r = 0, b = 0;

  void include(double x, double y) {
    l = math.min(l, x);
    t = math.min(t, y);
    r = math.max(r, x);
    b = math.max(b, y);
  }

  void flush(int end) {
    if (start != null && drawn) {
      out.add(SvgSubpath('$prefix${s.substring(start!, end).trim()}', l, t, r, b, absoluteStart: absolute));
    }
    start = null;
  }

  void begin(int at, double x, double y, {required bool abs, String pre = ''}) {
    start = at;
    prefix = pre;
    absolute = abs;
    drawn = false;
    closed = false;
    l = r = x;
    t = b = y;
  }

  bool get more {
    skipSpace();
    return i < s.length;
  }

  void skipSpace() {
    while (i < s.length && ' \t\n\r\f'.contains(s[i])) {
      i++;
    }
  }

  void skipDelimiter() {
    skipSpace();
    if (i < s.length && s[i] == ',') {
      i++;
      skipSpace();
    }
  }

  bool get atNumber {
    skipSpace();
    if (i >= s.length) return false;
    final c = s.codeUnitAt(i);
    return (c >= 48 && c <= 57) || c == 45 || c == 43 || c == 46;
  }

  double number() {
    skipSpace();
    final m = RegExp(r'[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?').matchAsPrefix(s, i);
    if (m == null) throw FormatException('number expected', s, i);
    i = m.end;
    skipDelimiter();
    return double.parse(m[0]!);
  }

  bool flag() {
    skipSpace();
    final c = s[i++];
    skipDelimiter();
    if (c == '0') return false;
    if (c == '1') return true;
    throw FormatException('flag expected', s, i);
  }

  /// A drawing command at [at]: after a `Z` with no `M` it starts a new
  /// subpath where the closed one started.
  void draw(int at) {
    if (start == null || closed) {
      flush(at);
      begin(at, sx, sy, abs: false, pre: 'M${_num(sx)} ${_num(sy)} ');
    }
    drawn = true;
  }

  List<SvgSubpath> run() {
    String? command;
    var lastCubic = false, lastQuad = false;
    double px = 0, py = 0; // the last control point
    while (more) {
      final at = i;
      final c = s[i];
      if (RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(c)) {
        command = c;
        i++;
      } else if (command == null || command == 'Z' || command == 'z') {
        throw FormatException('command expected', s, i);
      }
      final rel = command == command.toLowerCase();
      final ox = rel ? cx : 0.0, oy = rel ? cy : 0.0;
      var cubic = false, quad = false;
      switch (command.toUpperCase()) {
        case 'M':
          final x = ox + number(), y = oy + number();
          // A move after a move that drew nothing replaces it.
          flush(at);
          if (rel) {
            // Written as an absolute move, so the subpath reads the same
            // wherever it is put.
            begin(i, x, y, abs: false, pre: 'M${_num(x)} ${_num(y)} ${atNumber ? 'l ' : ''}');
          } else {
            begin(at, x, y, abs: true);
          }
          cx = sx = x;
          cy = sy = y;
          // Further pairs are line-tos.
          command = rel ? 'l' : 'L';
        case 'L':
          draw(at);
          cx = ox + number();
          cy = oy + number();
          include(cx, cy);
        case 'H':
          draw(at);
          cx = ox + number();
          include(cx, cy);
        case 'V':
          draw(at);
          cy = oy + number();
          include(cx, cy);
        case 'C' || 'S':
          draw(at);
          double x1, y1;
          if (command.toUpperCase() == 'S') {
            (x1, y1) = lastCubic ? (2 * cx - px, 2 * cy - py) : (cx, cy);
          } else {
            x1 = ox + number();
            y1 = oy + number();
          }
          final x2 = ox + number(), y2 = oy + number();
          final x = ox + number(), y = oy + number();
          include(x1, y1);
          include(x2, y2);
          include(x, y);
          (px, py) = (x2, y2);
          cx = x;
          cy = y;
          cubic = true;
        case 'Q' || 'T':
          draw(at);
          double qx, qy;
          if (command.toUpperCase() == 'T') {
            (qx, qy) = lastQuad ? (2 * cx - px, 2 * cy - py) : (cx, cy);
          } else {
            qx = ox + number();
            qy = oy + number();
          }
          final x = ox + number(), y = oy + number();
          // Drawn as the cubic with these control points.
          include(cx + 2 / 3 * (qx - cx), cy + 2 / 3 * (qy - cy));
          include(x + 2 / 3 * (qx - x), y + 2 / 3 * (qy - y));
          include(x, y);
          (px, py) = (qx, qy);
          cx = x;
          cy = y;
          quad = true;
        case 'A':
          draw(at);
          final rx = number(), ry = number(), angle = number();
          final large = flag(), sweep = flag();
          final x = ox + number(), y = oy + number();
          for (final p in _arcControlPoints(cx, cy, rx, ry, angle, large, sweep, x, y)) {
            include(p.$1, p.$2);
          }
          include(x, y);
          cx = x;
          cy = y;
        case 'Z':
          if (start != null) closed = true;
          cx = sx;
          cy = sy;
          skipDelimiter();
      }
      lastCubic = cubic;
      lastQuad = quad;
      if (!cubic && !quad) (px, py) = (cx, cy);
      // A number after a command repeats it (after Z: an error, as in SVG).
      if (command == 'Z' || command == 'z') {
        if (atNumber) throw FormatException('number after Z', s, i);
      }
    }
    flush(s.length);
    return out;
  }
}

/// The control points of the cubics an SVG arc is drawn as (path_parsing's
/// decomposition).
List<(double, double)> _arcControlPoints(
    double x0, double y0, double rx, double ry, double angleDeg, bool large, bool sweep, double x1, double y1) {
  rx = rx.abs();
  ry = ry.abs();
  if (rx == 0 || ry == 0 || (x0 == x1 && y0 == y1)) return const [];
  final angle = angleDeg * math.pi / 180;
  final cosA = math.cos(angle), sinA = math.sin(angle);
  // The midpoint distance, rotated by -angle.
  final mx = (x0 - x1) / 2, my = (y0 - y1) / 2;
  final tx = cosA * mx + sinA * my, ty = -sinA * mx + cosA * my;
  final scale = tx * tx / (rx * rx) + ty * ty / (ry * ry);
  if (scale > 1) {
    rx *= math.sqrt(scale);
    ry *= math.sqrt(scale);
  }
  (double, double) toUnit(double x, double y) => ((cosA * x + sinA * y) / rx, (-sinA * x + cosA * y) / ry);
  (double, double) fromUnit(double x, double y) => (cosA * rx * x - sinA * ry * y, sinA * rx * x + cosA * ry * y);
  final p1 = toUnit(x0, y0), p2 = toUnit(x1, y1);
  var dx = p2.$1 - p1.$1, dy = p2.$2 - p1.$2;
  final d = dx * dx + dy * dy;
  var f = math.sqrt(math.max(1 / d - 0.25, 0.0));
  if (!f.isFinite) f = 0;
  if (sweep == large) f = -f;
  dx *= f;
  dy *= f;
  final ccx = (p1.$1 + p2.$1) / 2 - dy, ccy = (p1.$2 + p2.$2) / 2 + dx;
  final theta1 = math.atan2(p1.$2 - ccy, p1.$1 - ccx), theta2 = math.atan2(p2.$2 - ccy, p2.$1 - ccx);
  var arc = theta2 - theta1;
  if (arc < 0 && sweep) {
    arc += 2 * math.pi;
  } else if (arc > 0 && !sweep) {
    arc -= 2 * math.pi;
  }
  final segments = (arc / (math.pi / 2 + 0.001)).abs().ceil();
  final out = <(double, double)>[];
  for (var k = 0; k < segments; k++) {
    final a = theta1 + k * arc / segments, e = theta1 + (k + 1) * arc / segments;
    final t = 4 / 3 * math.tan((e - a) / 4);
    if (!t.isFinite) return const [];
    final c1 = (math.cos(a) - t * math.sin(a) + ccx, math.sin(a) + t * math.cos(a) + ccy);
    final end = (math.cos(e) + ccx, math.sin(e) + ccy);
    final c2 = (end.$1 + t * math.sin(e), end.$2 - t * math.cos(e));
    for (final p in [c1, c2, end]) {
      out.add(fromUnit(p.$1, p.$2));
    }
  }
  return out;
}
