import 'package:meta/meta.dart';

import '../json.dart';

/// Flutter's `EdgeInsets` (left, top, right, bottom). JSON: a number (all
/// sides) or `[left, top, right, bottom]`.
@immutable
/// Flutter's `EdgeInsets`, or `EdgeInsetsDirectional` when [directional].
///
/// JSON: a number (every side), `[left, top, right, bottom]`, or a map. A map
/// with `start` or `end` is directional (Flutter's `EdgeInsetsDirectional`):
/// `{"start": 16, "top": 8, "end": 4, "bottom": 8}` puts 16 on the left under
/// a left-to-right `textDirection` and on the right under right-to-left. A map
/// with only `left`/`top`/`right`/`bottom` is the absolute form.
///
/// A directional value keeps its start in [left] and its end in [right];
/// [resolve] gives the absolute insets for a direction.
final class EdgeInsets {
  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom) : directional = false;
  const EdgeInsets.all(double v) : this.fromLTRB(v, v, v, v);
  const EdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
      : this.fromLTRB(horizontal, vertical, horizontal, vertical);
  const EdgeInsets.only({this.left = 0, this.top = 0, this.right = 0, this.bottom = 0}) : directional = false;

  /// Flutter's `EdgeInsetsDirectional.fromSTEB`: [start] and [end] follow the
  /// text direction.
  const EdgeInsets.fromSTEB(double start, this.top, double end, this.bottom)
      : left = start,
        right = end,
        directional = true;

  static const EdgeInsets zero = EdgeInsets.all(0);

  /// For a [directional] value, [left] is the start and [right] the end.
  final double left, top, right, bottom;

  /// Whether [left] and [right] are the start and end sides, which swap under
  /// a right-to-left text direction.
  final bool directional;

  /// The start side ([left] of a [directional] value).
  double get start => left;

  /// The end side ([right] of a [directional] value).
  double get end => right;

  double get horizontal => left + right;
  double get vertical => top + bottom;
  bool get isZero => left == 0 && top == 0 && right == 0 && bottom == 0;

  /// The absolute insets under a right-to-left ([rtl]) or left-to-right text
  /// direction: a [directional] value's start goes on the right under
  /// right-to-left. An absolute value is itself.
  EdgeInsets resolve({required bool rtl}) {
    if (!directional) return this;
    return rtl ? EdgeInsets.fromLTRB(right, top, left, bottom) : EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  /// The sum, side by side. Directional only when both are.
  EdgeInsets operator +(EdgeInsets o) => directional && o.directional
      ? EdgeInsets.fromSTEB(left + o.left, top + o.top, right + o.right, bottom + o.bottom)
      : EdgeInsets.fromLTRB(left + o.left, top + o.top, right + o.right, bottom + o.bottom);

  static EdgeInsets fromJson(Object? json) {
    if (readDouble(json) case final double v) return EdgeInsets.all(v);
    if (readMap(json) case final Map<String, Object?> m) {
      double side(String k) => readDouble(m[k]) ?? 0;
      if (m.containsKey('start') || m.containsKey('end')) {
        return EdgeInsets.fromSTEB(side('start'), side('top'), side('end'), side('bottom'));
      }
      return EdgeInsets.fromLTRB(side('left'), side('top'), side('right'), side('bottom'));
    }
    final l = readList(json);
    if (l == null || l.length != 4) return zero;
    return EdgeInsets.fromLTRB(readDouble(l[0]) ?? 0, readDouble(l[1]) ?? 0, readDouble(l[2]) ?? 0, readDouble(l[3]) ?? 0);
  }

  Object toJson() {
    if (directional) {
      return {'start': writeDouble(left), 'top': writeDouble(top), 'end': writeDouble(right), 'bottom': writeDouble(bottom)};
    }
    return left == top && top == right && right == bottom
        ? writeDouble(left)
        : [writeDouble(left), writeDouble(top), writeDouble(right), writeDouble(bottom)];
  }

  @override
  bool operator ==(Object other) =>
      other is EdgeInsets &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.directional == directional;

  @override
  int get hashCode => Object.hash(left, top, right, bottom, directional);

  @override
  String toString() => directional
      ? 'EdgeInsetsDirectional($left, $top, $right, $bottom)'
      : 'EdgeInsets($left, $top, $right, $bottom)';
}

/// Flutter's `BorderRadius`: four corners, each circular or elliptical.
/// JSON (sparse, see [fromJson]): `8`, `[16, 8]` or `[8, [16, 8], 0, 0]`.
@immutable
final class BorderRadius {
  /// Each corner's radius: circular, or elliptical when its `Y` (vertical)
  /// radius is given and differs.
  const BorderRadius.only({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomRight = 0,
    this.bottomLeft = 0,
    this._topLeftY,
    this._topRightY,
    this._bottomRightY,
    this._bottomLeftY,
  });
  const BorderRadius.circular(double r) : this.only(topLeft: r, topRight: r, bottomRight: r, bottomLeft: r);

  /// Every corner elliptical: [x] across, [y] down (Flutter's
  /// `BorderRadius.all(Radius.elliptical(x, y))`).
  const BorderRadius.elliptical(double x, double y)
      : this.only(
          topLeft: x,
          topRight: x,
          bottomRight: x,
          bottomLeft: x,
          topLeftY: y,
          topRightY: y,
          bottomRightY: y,
          bottomLeftY: y,
        );

  static const BorderRadius zero = BorderRadius.circular(0);

  /// Each corner's horizontal radius: its radius, when it's circular.
  final double topLeft, topRight, bottomRight, bottomLeft;
  final double? _topLeftY, _topRightY, _bottomRightY, _bottomLeftY;

  /// Each corner's vertical radius (its horizontal one when circular).
  double get topLeftY => _topLeftY ?? topLeft;
  double get topRightY => _topRightY ?? topRight;
  double get bottomRightY => _bottomRightY ?? bottomRight;
  double get bottomLeftY => _bottomLeftY ?? bottomLeft;

  /// Corners as `(x, y)`, clockwise from the top left.
  List<(double, double)> get _corners => [
        (topLeft, topLeftY),
        (topRight, topRightY),
        (bottomRight, bottomRightY),
        (bottomLeft, bottomLeftY),
      ];

  bool get isZero => _corners.every((c) => c.$1 == 0 && c.$2 == 0);
  bool get isUniform {
    final c = _corners;
    return c[0] == c[1] && c[1] == c[2] && c[2] == c[3];
  }

  /// Every corner is circular.
  bool get isCircular => _corners.every((c) => c.$1 == c.$2);

  /// JSON: a number (every corner circular), `[x, y]` (every corner
  /// elliptical), or `[topLeft, topRight, bottomRight, bottomLeft]`, each a
  /// number or `[x, y]`.
  static BorderRadius fromJson(Object? json) {
    if (readDouble(json) case final double v) return BorderRadius.circular(v);
    final l = readList(json);
    if (l != null && l.length == 2) {
      final x = readDouble(l[0]), y = readDouble(l[1]);
      return x == null || y == null ? zero : BorderRadius.elliptical(x, y);
    }
    if (l == null || l.length != 4) return zero;
    (double, double) corner(Object? j) {
      if (readDouble(j) case final double v) return (v, v);
      final c = readList(j);
      if (c == null || c.length != 2) return (0, 0);
      return (readDouble(c[0]) ?? 0, readDouble(c[1]) ?? 0);
    }

    final [tl, tr, br, bl] = [for (final c in l) corner(c)];
    return BorderRadius.only(
      topLeft: tl.$1,
      topRight: tr.$1,
      bottomRight: br.$1,
      bottomLeft: bl.$1,
      topLeftY: tl.$2,
      topRightY: tr.$2,
      bottomRightY: br.$2,
      bottomLeftY: bl.$2,
    );
  }

  Object toJson() {
    Object corner((double, double) c) => c.$1 == c.$2 ? writeDouble(c.$1) : [writeDouble(c.$1), writeDouble(c.$2)];
    final c = _corners;
    if (isUniform) return corner(c[0]);
    return [for (final x in c) corner(x)];
  }

  @override
  bool operator ==(Object other) =>
      other is BorderRadius &&
      other.topLeft == topLeft &&
      other.topRight == topRight &&
      other.bottomRight == bottomRight &&
      other.bottomLeft == bottomLeft &&
      other.topLeftY == topLeftY &&
      other.topRightY == topRightY &&
      other.bottomRightY == bottomRightY &&
      other.bottomLeftY == bottomLeftY;

  @override
  int get hashCode =>
      Object.hash(topLeft, topRight, bottomRight, bottomLeft, topLeftY, topRightY, bottomRightY, bottomLeftY);

  @override
  String toString() => 'BorderRadius(${toJson()})';
}

/// Flutter's `Alignment`: -1 (start) to 1 (end) per axis. JSON: `[x, y]`.
@immutable
final class Alignment {
  const Alignment(this.x, this.y);

  final double x, y;

  static const Alignment topLeft = Alignment(-1, -1);
  static const Alignment topCenter = Alignment(0, -1);
  static const Alignment center = Alignment(0, 0);
  static const Alignment topRight = Alignment(1, -1);
  static const Alignment centerLeft = Alignment(-1, 0);
  static const Alignment centerRight = Alignment(1, 0);
  static const Alignment bottomLeft = Alignment(-1, 1);
  static const Alignment bottomCenter = Alignment(0, 1);
  static const Alignment bottomRight = Alignment(1, 1);

  /// Flutter's named alignments, which JSON may give instead of `[x, y]`.
  static const Map<String, Alignment> named = {
    'topLeft': topLeft, 'topCenter': topCenter, 'topRight': topRight, //
    'centerLeft': centerLeft, 'center': center, 'centerRight': centerRight,
    'bottomLeft': bottomLeft, 'bottomCenter': bottomCenter, 'bottomRight': bottomRight,
  };

  static Alignment? fromJson(Object? json) {
    if (json is String) return named[json];
    final l = readList(json);
    if (l == null || l.length != 2) return null;
    final x = readDouble(l[0]), y = readDouble(l[1]);
    return x == null || y == null ? null : Alignment(x, y);
  }

  List<num> toJson() => [writeDouble(x), writeDouble(y)];

  @override
  bool operator ==(Object other) => other is Alignment && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Alignment($x, $y)';
}

/// An offset. JSON: `[dx, dy]`.
@immutable
final class Offset {
  const Offset(this.dx, this.dy);
  static const Offset zero = Offset(0, 0);
  final double dx, dy;

  static Offset fromJson(Object? json) {
    final l = readList(json);
    if (l == null || l.length != 2) return zero;
    return Offset(readDouble(l[0]) ?? 0, readDouble(l[1]) ?? 0);
  }

  List<num> toJson() => [writeDouble(dx), writeDouble(dy)];

  @override
  bool operator ==(Object other) => other is Offset && other.dx == dx && other.dy == dy;

  @override
  int get hashCode => Object.hash(dx, dy);
}

/// Flutter's `BoxConstraints`, where a missing bound means unconstrained.
@immutable
final class BoxConstraints {
  const BoxConstraints({this.minWidth, this.maxWidth, this.minHeight, this.maxHeight});

  static const BoxConstraints none = BoxConstraints();

  final double? minWidth, maxWidth, minHeight, maxHeight;

  bool get isEmpty => minWidth == null && maxWidth == null && minHeight == null && maxHeight == null;

  static BoxConstraints fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return none;
    double? bound(String k) => readDouble(m[k]).let((v) => v == null || v < 0 ? null : v);
    return BoxConstraints(
      minWidth: bound('minWidth'),
      maxWidth: bound('maxWidth'),
      minHeight: bound('minHeight'),
      maxHeight: bound('maxHeight'),
    );
  }

  Json toJson() => {
        if (minWidth != null) 'minWidth': writeDouble(minWidth!),
        if (maxWidth != null) 'maxWidth': writeDouble(maxWidth!),
        if (minHeight != null) 'minHeight': writeDouble(minHeight!),
        if (maxHeight != null) 'maxHeight': writeDouble(maxHeight!),
      };

  @override
  bool operator ==(Object other) =>
      other is BoxConstraints &&
      other.minWidth == minWidth &&
      other.maxWidth == maxWidth &&
      other.minHeight == minHeight &&
      other.maxHeight == maxHeight;

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);
}
