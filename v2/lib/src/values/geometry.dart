import 'package:meta/meta.dart';

import '../json.dart';

/// Flutter's `EdgeInsets` (left, top, right, bottom). JSON: a number (all
/// sides) or `[left, top, right, bottom]`.
@immutable
final class EdgeInsets {
  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);
  const EdgeInsets.all(double v) : this.fromLTRB(v, v, v, v);
  const EdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
      : this.fromLTRB(horizontal, vertical, horizontal, vertical);
  const EdgeInsets.only({this.left = 0, this.top = 0, this.right = 0, this.bottom = 0});

  static const EdgeInsets zero = EdgeInsets.all(0);

  final double left, top, right, bottom;

  double get horizontal => left + right;
  double get vertical => top + bottom;
  bool get isZero => left == 0 && top == 0 && right == 0 && bottom == 0;

  EdgeInsets operator +(EdgeInsets o) =>
      EdgeInsets.fromLTRB(left + o.left, top + o.top, right + o.right, bottom + o.bottom);

  static EdgeInsets fromJson(Object? json) {
    if (readDouble(json) case final double v) return EdgeInsets.all(v);
    final l = readList(json);
    if (l == null || l.length != 4) return zero;
    return EdgeInsets.fromLTRB(readDouble(l[0]) ?? 0, readDouble(l[1]) ?? 0, readDouble(l[2]) ?? 0, readDouble(l[3]) ?? 0);
  }

  Object toJson() => left == top && top == right && right == bottom
      ? writeDouble(left)
      : [writeDouble(left), writeDouble(top), writeDouble(right), writeDouble(bottom)];

  @override
  bool operator ==(Object other) =>
      other is EdgeInsets && other.left == left && other.top == top && other.right == right && other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'EdgeInsets($left, $top, $right, $bottom)';
}

/// Flutter's `BorderRadius` with circular corners. JSON: a number (all
/// corners) or `[topLeft, topRight, bottomRight, bottomLeft]`.
@immutable
final class BorderRadius {
  const BorderRadius.only({this.topLeft = 0, this.topRight = 0, this.bottomRight = 0, this.bottomLeft = 0});
  const BorderRadius.circular(double r) : this.only(topLeft: r, topRight: r, bottomRight: r, bottomLeft: r);

  static const BorderRadius zero = BorderRadius.circular(0);

  final double topLeft, topRight, bottomRight, bottomLeft;

  bool get isZero => topLeft == 0 && topRight == 0 && bottomRight == 0 && bottomLeft == 0;
  bool get isUniform => topLeft == topRight && topRight == bottomRight && bottomRight == bottomLeft;

  static BorderRadius fromJson(Object? json) {
    if (readDouble(json) case final double v) return BorderRadius.circular(v);
    final l = readList(json);
    if (l == null || l.length != 4) return zero;
    return BorderRadius.only(
      topLeft: readDouble(l[0]) ?? 0,
      topRight: readDouble(l[1]) ?? 0,
      bottomRight: readDouble(l[2]) ?? 0,
      bottomLeft: readDouble(l[3]) ?? 0,
    );
  }

  Object toJson() => isUniform
      ? writeDouble(topLeft)
      : [writeDouble(topLeft), writeDouble(topRight), writeDouble(bottomRight), writeDouble(bottomLeft)];

  @override
  bool operator ==(Object other) =>
      other is BorderRadius &&
      other.topLeft == topLeft &&
      other.topRight == topRight &&
      other.bottomRight == bottomRight &&
      other.bottomLeft == bottomLeft;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomRight, bottomLeft);
}

/// Flutter's `Alignment`: -1 (start) to 1 (end) per axis. JSON: `[x, y]`.
@immutable
final class Alignment {
  const Alignment(this.x, this.y);

  final double x, y;

  static const Alignment topLeft = Alignment(-1, -1);
  static const Alignment topCenter = Alignment(0, -1);
  static const Alignment center = Alignment(0, 0);

  static Alignment? fromJson(Object? json) {
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
