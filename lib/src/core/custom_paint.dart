// Flutter's `CustomPaint` as data: a node behavior holding two draw lists,
// `painter` (behind the node's content) and `foregroundPainter` (over it),
// each a list of draw operations that mirror `dart:ui`'s `Canvas` calls
// (`drawPath`, `drawLine`, `drawRect`, `drawRRect`, `drawCircle`,
// `drawOval`, `drawArc`, `drawPoints`, `drawParagraph`, `drawImageRect`),
// with Flutter's parameter names, and a `Paint` per call with Flutter's
// `Paint` fields. `save`/`translate`/`clip*`/`saveLayer`/`restore` are one
// balanced `group`; `repeat` draws its ops once per item of a list.
//
// A value in an op may be a literal or an expression (`"${count}"`,
// `"${= radians(index * 6)}"`), as an action's text fields are: a draw list
// is a small program, and `repeat` gives `item` and `index`. Decoding is
// total (an unreadable value falls back to its default, an op that isn't
// one is dropped, an unknown op type round-trips), encoding sparse.
import 'package:meta/meta.dart';

import 'json.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/paint.dart';
import 'values/text.dart';

/// Flutter's `PaintingStyle`: fill the shape, or stroke its outline.
enum PaintingStyle { fill, stroke }

/// Flutter's `PathFillType`.
enum PathFillType { nonZero, evenOdd }

/// Flutter's `PointMode` (`Canvas.drawPoints`).
enum PointMode { points, lines, polygon }

// --- expressions ----------------------------------------------------------------

/// A value given as a literal [value] or computed by an expression
/// [source] (`"${size.width}"`, `"${= index * 2}"`) when the list draws.
@immutable
final class Expr<T extends Object> {
  const Expr(T this.value) : source = null;

  /// Computed by [source] (text holding `${...}`).
  const Expr.source(String this.source) : value = null;

  final T? value;
  final String? source;

  bool get isExpression => source != null;

  /// Whether JSON [v] is an expression: text holding `${`.
  static bool isSource(Object? v) => v is String && v.contains(r'${');

  /// [json] as an expression, or a literal read by [literal]; null when it
  /// is neither.
  static Expr<T>? read<T extends Object>(Object? json, T? Function(Object?) literal) {
    if (isSource(json)) return Expr<T>.source(json as String);
    final v = literal(json);
    return v == null ? null : Expr<T>(v);
  }

  /// The JSON: the source, or the literal written by [literal] (as is
  /// without one).
  Object? toJson([Object? Function(T)? literal]) => source ?? (literal == null ? value : literal(value as T));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Expr<T> && other.source == source && jsonEquality.equals(other.value, value);

  @override
  int get hashCode => Object.hash(source, jsonEquality.hash(value));

  @override
  String toString() => source ?? 'Expr($value)';
}

/// A list of numbers (a point `[x, y]`, a rect `[left, top, width,
/// height]`, a scale, a matrix), each a literal or an expression.
typedef Vec = List<Expr<double>>;

Expr<double>? _num(Object? j) => Expr.read<double>(j, readDouble);
Object? _numOut(Expr<double> e) => e.toJson((v) => writeDouble(v));

/// A literal [Vec] of one of [lengths], or null.
Vec? readVec(Object? json, Set<int> lengths) {
  final l = readList(json);
  if (l == null || !lengths.contains(l.length)) return null;
  final out = <Expr<double>>[];
  for (final v in l) {
    final e = _num(v);
    if (e == null) return null;
    out.add(e);
  }
  return out;
}

/// A [Vec] as JSON.
List<Object?> writeVec(Vec v) => [for (final e in v) _numOut(e)];

/// A vector field: a list of [lengths] numbers (each may be an expression),
/// or one expression giving the list.
Expr<Vec>? readExprVec(Object? json, Set<int> lengths) {
  if (Expr.isSource(json)) return Expr<Vec>.source(json as String);
  if (readDouble(json) case final double d when lengths.contains(1)) return Expr<Vec>([Expr(d)]);
  final v = readVec(json, lengths);
  return v == null ? null : Expr<Vec>(v);
}

/// [readExprVec]'s JSON; a one-number vector is written as the number.
Object? writeExprVec(Expr<Vec> e) => e.source ?? (e.value!.length == 1 ? _numOut(e.value!.single) : writeVec(e.value!));

/// A list of points: `[[x, y], ...]` (each coordinate may be an
/// expression), `{"x", "y"}` maps, or flat numbers `[x0, y0, x1, y1...]`;
/// a `null` entry breaks the line. Unreadable entries are dropped.
List<Vec?>? readPoints(Object? json) {
  final l = readList(json);
  if (l == null) return null;
  if (l.isNotEmpty && l.length.isEven && l.every((v) => v is num || Expr.isSource(v))) {
    return [for (var i = 0; i < l.length; i += 2) [_num(l[i])!, _num(l[i + 1])!]];
  }
  final out = <Vec?>[];
  for (final p in l) {
    if (p == null) {
      out.add(null);
    } else if (readMap(p) case final Json m) {
      final x = _num(m['x']), y = _num(m['y']);
      if (x != null && y != null) out.add([x, y]);
    } else if (readVec(p, const {2}) case final Vec v) {
      out.add(v);
    }
  }
  return out;
}

List<Object?> writePoints(List<Vec?> points) => [for (final p in points) p == null ? null : writeVec(p)];

Expr<List<Vec?>>? readExprPoints(Object? json) =>
    Expr.isSource(json) ? Expr<List<Vec?>>.source(json as String) : readPoints(json)?.let(Expr<List<Vec?>>.new);

Object? writeExprPoints(Expr<List<Vec?>> e) => e.source ?? writePoints(e.value!);

// --- the paint ---------------------------------------------------------------------

/// How a shape is drawn: Flutter's `Paint`, with its field names and
/// defaults (black, `fill`, `strokeWidth` 0: a hairline, `butt`, `miter`,
/// miter limit 4, `srcOver`, anti-aliased). [shader] is a gradient or image
/// in the model's [Paint] form, laid out in the shape's bounds (Flutter's
/// `Gradient.createShader(rect)`). [dashPattern] and [scaleStroke] have no
/// `Paint` counterpart: dashes as a decoration's `dashPattern`, and a stroke
/// that stays in the box's pixels under a scaling view box or group as the
/// `path` node's `scaleStroke: false`.
///
/// JSON: an object, or just a color (`"#FF2196F3"`, or an expression giving
/// a color or a paint object).
@immutable
final class DrawPaint {
  const DrawPaint({
    this.id,
    this.color = const Expr(Color.black),
    this.shader,
    this.style = PaintingStyle.fill,
    this.strokeWidth = const Expr(0.0),
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
    this.strokeMiterLimit = 4,
    this.blendMode = BlendMode.srcOver,
    this.isAntiAlias = true,
    this.dashPattern = const [],
    this.scaleStroke = true,
  });

  /// Stable id, so a binding can target this paint.
  final String? id;
  final Expr<Color> color;

  /// A gradient or image ([Paint] JSON), over [color].
  final Paint? shader;
  final PaintingStyle style;
  final Expr<double> strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeMiterLimit;
  final BlendMode blendMode;
  final bool isAntiAlias;

  /// Dash and gap lengths, alternating; empty is solid.
  final List<double> dashPattern;

  /// False: [strokeWidth] and [dashPattern] are in the box's pixels however
  /// the view box and groups scale the drawing.
  final bool scaleStroke;

  static const keys = {
    'id', 'color', 'shader', 'style', 'strokeWidth', 'strokeCap', 'strokeJoin', 'strokeMiterLimit', 'blendMode', //
    'isAntiAlias', 'dashPattern', 'scaleStroke',
  };

  /// Only a color: written as the color alone.
  bool get _isColorOnly => this == DrawPaint(color: color);

  static DrawPaint? fromJson(Object? json) {
    if (json is String || json is int) {
      final c = Expr.read<Color>(json, Color.fromJson);
      return c == null ? null : DrawPaint(color: c);
    }
    final m = readMap(json);
    if (m == null) return null;
    final width = _num(m['strokeWidth']);
    return DrawPaint(
      id: readString(m['id']),
      color: Expr.read<Color>(m['color'], Color.fromJson) ?? const Expr(Color.black),
      shader: Paint.fromJson(m['shader']),
      style: readEnum(PaintingStyle.values, m['style'], PaintingStyle.fill),
      strokeWidth: width == null || (width.value ?? 0) < 0 ? const Expr(0.0) : width,
      strokeCap: readEnum(StrokeCap.values, m['strokeCap'], StrokeCap.butt),
      strokeJoin: readEnum(StrokeJoin.values, m['strokeJoin'], StrokeJoin.miter),
      strokeMiterLimit: readDouble(m['strokeMiterLimit']) ?? 4,
      blendMode: readEnum(BlendMode.values, m['blendMode'], BlendMode.srcOver),
      isAntiAlias: readBool(m['isAntiAlias']) ?? true,
      dashPattern: [...?readList(m['dashPattern'])?.map(readDouble).nonNulls.where((v) => v >= 0)],
      scaleStroke: readBool(m['scaleStroke']) ?? true,
    );
  }

  Object toJson() {
    if (_isColorOnly) return color.toJson((c) => c.toJson())!;
    final j = <String, Object?>{};
    put(j, 'id', id);
    if (color != const Expr(Color.black)) j['color'] = color.toJson((c) => c.toJson());
    put(j, 'shader', shader?.toJson());
    put(j, 'style', style.name, PaintingStyle.fill.name);
    if (strokeWidth != const Expr(0.0)) j['strokeWidth'] = _numOut(strokeWidth);
    put(j, 'strokeCap', strokeCap.name, StrokeCap.butt.name);
    put(j, 'strokeJoin', strokeJoin.name, StrokeJoin.miter.name);
    put(j, 'strokeMiterLimit', writeDouble(strokeMiterLimit), 4);
    put(j, 'blendMode', blendMode.name, BlendMode.srcOver.name);
    put(j, 'isAntiAlias', isAntiAlias, true);
    if (dashPattern.isNotEmpty) j['dashPattern'] = dashPattern.map(writeDouble).toList();
    put(j, 'scaleStroke', scaleStroke, true);
    return j;
  }

  DrawPaint copyWith({
    String? id,
    Expr<Color>? color,
    Paint? shader,
    PaintingStyle? style,
    Expr<double>? strokeWidth,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    BlendMode? blendMode,
    bool? isAntiAlias,
    List<double>? dashPattern,
    bool? scaleStroke,
  }) => DrawPaint(
    id: id ?? this.id,
    color: color ?? this.color,
    shader: shader ?? this.shader,
    style: style ?? this.style,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    strokeCap: strokeCap ?? this.strokeCap,
    strokeJoin: strokeJoin ?? this.strokeJoin,
    strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
    blendMode: blendMode ?? this.blendMode,
    isAntiAlias: isAntiAlias ?? this.isAntiAlias,
    dashPattern: dashPattern ?? this.dashPattern,
    scaleStroke: scaleStroke ?? this.scaleStroke,
  );

  List<Object?> get _props => [
    id, color, shader, style, strokeWidth, strokeCap, strokeJoin, strokeMiterLimit, blendMode, isAntiAlias, //
    dashPattern, scaleStroke,
  ];

  @override
  bool operator ==(Object other) => identical(this, other) || other is DrawPaint && jsonEquality.equals(other._props, _props);

  @override
  int get hashCode => jsonEquality.hash(_props);
}

/// An op's `paint`: one paint, or several drawn in order (a fill then a
/// stroke of the same shape, as two Flutter calls would). Each may be an
/// expression.
List<Expr<DrawPaint>> readPaints(Object? json) {
  Expr<DrawPaint>? one(Object? j) => Expr.isSource(j) ? Expr<DrawPaint>.source(j as String) : DrawPaint.fromJson(j)?.let(Expr.new);
  if (json is List) return [...json.map(one).nonNulls];
  return [?one(json)];
}

/// [readPaints]' JSON: a single paint unwrapped.
Object? writePaints(List<Expr<DrawPaint>> paints) {
  Object? one(Expr<DrawPaint> p) => p.toJson((v) => v.toJson());
  return paints.length == 1 ? one(paints.single) : [for (final p in paints) one(p)];
}

// --- draw ops ----------------------------------------------------------------------

/// One draw operation: `{"op": name, ...}`. Every op may carry an [id]
/// (editor selection, a binding path `customPaint.painter.<id>.<field>`)
/// and [when] (false skips it). Keys an op doesn't know are kept in
/// [extra] and written back.
@immutable
sealed class DrawOp {
  const DrawOp({this.id, this.when, this.extra = const {}});

  /// The JSON `op`.
  String get op;
  final String? id;

  /// Drawn only while it holds (Flutter's `if (cond)`); null: always.
  final Expr<bool>? when;

  /// Keys this version doesn't model.
  final Json extra;

  /// The op names, each with what it is in Flutter.
  static const Map<String, String> names = {
    'path': 'Canvas.drawPath',
    'line': 'Canvas.drawLine',
    'rect': 'Canvas.drawRect',
    'rrect': 'Canvas.drawRRect',
    'circle': 'Canvas.drawCircle',
    'oval': 'Canvas.drawOval',
    'arc': 'Canvas.drawArc',
    'points': 'Canvas.drawPoints',
    'paragraph': 'Canvas.drawParagraph',
    'image': 'Canvas.drawImageRect',
    'group': 'Canvas.save / saveLayer … restore',
    'repeat': 'for (final (index, item) in list.indexed)',
  };

  /// [v] as an op name: one of [names], also spelled as the Canvas method
  /// (`drawRRect`, `drawImageRect`) or `text` for `paragraph`. Null when
  /// [v] isn't text.
  static String? opName(Object? v) {
    if (v is! String || v.isEmpty) return null;
    var s = v.trim();
    if (s.startsWith('draw') && s.length > 4) s = s.substring(4);
    s = s.toLowerCase();
    return switch (s) {
      'text' => 'paragraph',
      'imagerect' => 'image',
      'save' || 'savelayer' => 'group',
      _ when names.containsKey(s) => s,
      _ => v,
    };
  }

  static DrawOp? fromJson(Object? json) {
    final m = readMap(json);
    final name = opName(m?['op']);
    if (m == null || name == null) return null;
    final c = _Common(m);
    return switch (name) {
      'path' => PathOp._read(m, c),
      'line' => LineOp._read(m, c),
      'rect' => RectOp._read(m, c),
      'rrect' => RRectOp._read(m, c),
      'circle' => CircleOp._read(m, c),
      'oval' => OvalOp._read(m, c),
      'arc' => ArcOp._read(m, c),
      'points' => PointsOp._read(m, c),
      'paragraph' => ParagraphOp._read(m, c),
      'image' => ImageOp._read(m, c),
      'group' => GroupOp._read(m, c),
      'repeat' => RepeatOp._read(m, c),
      _ => UnknownDrawOp(m),
    };
  }

  static List<DrawOp> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  /// This op's own fields, sparse.
  void _write(Json j);

  Json toJson() {
    final j = <String, Object?>{...extra, 'op': op};
    put(j, 'id', id);
    if (when != null) j['when'] = when!.toJson();
    _write(j);
    return j;
  }

  List<Object?> get _props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawOp &&
          other.runtimeType == runtimeType &&
          other.id == id &&
          other.when == when &&
          jsonEquality.equals(other.extra, extra) &&
          jsonEquality.equals(other._props, _props);

  @override
  int get hashCode => Object.hash(runtimeType, id, when, jsonEquality.hash(extra), jsonEquality.hash(_props));

  @override
  String toString() => 'DrawOp(${toJson()})';
}

/// The fields every op reads.
extension type const _Common(Json m) {
  String? get id => readString(m['id']);
  Expr<bool>? get when => Expr.read<bool>(m['when'], readBool);
  Json extra(Set<String> own) => {
    for (final e in m.entries)
      if (e.key != 'op' && e.key != 'id' && e.key != 'when' && !own.contains(e.key)) e.key: e.value,
  };
}

/// An op that draws a shape: its [paint]s, and [hit], which makes it a hit
/// region (Flutter's `CustomPainter.hitTest`).
sealed class ShapeOp extends DrawOp {
  const ShapeOp({super.id, super.when, super.extra, this.paint = const [], this.hit});

  /// Each paint draws the shape once, in order. Empty: nothing is drawn
  /// (with [hit], an invisible target).
  final List<Expr<DrawPaint>> paint;

  /// The region id a pointer on this shape reports (`${result.region}`).
  final String? hit;

  static const _shapeKeys = {'paint', 'hit'};

  void _writeShape(Json j) {
    if (paint.isNotEmpty) j['paint'] = writePaints(paint);
    put(j, 'hit', hit);
  }
}

Expr<double> _numOr(Object? j, double fallback) => _num(j) ?? Expr(fallback);
void _putNum(Json j, String k, Expr<double>? v, [double? fallback]) {
  if (v == null || (fallback != null && v == Expr(fallback))) return;
  j[k] = _numOut(v);
}

void _putVec(Json j, String k, Expr<Vec>? v) {
  if (v != null) j[k] = writeExprVec(v);
}

const _point = {2};
const _rect = {4};

/// One call of Flutter's `Path` builder: [method] (`moveTo`, `lineTo`,
/// `quadraticBezierTo`, `cubicTo`, `close`) with its positional arguments
/// [args] (each a literal or an expression), made only while [when] holds
/// (`if (cond) path.lineTo(x, y)`). JSON: `{"lineTo": [x, y]}`,
/// `{"quadraticBezierTo": [x1, y1, x2, y2]}`, `{"close": true}`, with an
/// optional `"when"`.
@immutable
final class PathCommand {
  const PathCommand(this.method, [this.args = const [], this.when]);

  /// The `Path` method, one of [arity]'s keys.
  final String method;
  final Vec args;
  final Expr<bool>? when;

  /// The methods and how many numbers each takes.
  static const arity = {'moveTo': 2, 'lineTo': 2, 'quadraticBezierTo': 4, 'cubicTo': 6, 'close': 0};

  /// [json] as a command; null when it names no method of [arity] or its
  /// arguments don't fit.
  static PathCommand? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    for (final e in arity.entries) {
      if (!m.containsKey(e.key)) continue;
      final when = Expr.read<bool>(m['when'], readBool);
      if (e.value == 0) return readBool(m[e.key]) == false ? null : PathCommand(e.key, const [], when);
      final args = readVec(m[e.key], {e.value});
      return args == null ? null : PathCommand(e.key, args, when);
    }
    return null;
  }

  Json toJson() => {
    method: method == 'close' ? true : writeVec(args),
    if (when != null) 'when': when!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathCommand && other.method == method && other.when == when && jsonEquality.equals(other.args, args);

  @override
  int get hashCode => Object.hash(method, when, jsonEquality.hash(args));
}

/// A list of [PathCommand]s; unreadable entries are dropped.
List<PathCommand>? readPathCommands(Object? json) => readList(json)?.map(PathCommand.fromJson).nonNulls.toList();

/// `Canvas.drawPath`: SVG path data [d]; or the `Path` builder's calls
/// [commands]; or [points] joined by straight lines ([close]d back to the
/// first). [trimStart]–[trimEnd] of its length (`PathMetric.extractPath`).
final class PathOp extends ShapeOp {
  const PathOp({
    super.id,
    super.when,
    super.extra,
    super.paint,
    super.hit,
    this.d,
    this.commands,
    this.points,
    this.close = false,
    this.fillType = PathFillType.nonZero,
    this.trimStart = const Expr(0.0),
    this.trimEnd = const Expr(1.0),
  });

  /// SVG path data; may hold `${...}`.
  final String? d;

  /// Without [d]: the path built call by call, as Flutter code builds it
  /// (`Path()..moveTo(..)..quadraticBezierTo(..)`), exact numbers and no
  /// SVG text in between.
  final List<PathCommand>? commands;
  final Expr<List<Vec?>>? points;
  final bool close;
  final PathFillType fillType;
  final Expr<double> trimStart, trimEnd;

  @override
  String get op => 'path';
  static const keys = {'d', 'commands', 'points', 'close', 'fillType', 'trimStart', 'trimEnd', ...ShapeOp._shapeKeys};

  static PathOp _read(Json m, _Common c) => PathOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    d: readString(m['d']),
    commands: readPathCommands(m['commands']),
    points: readExprPoints(m['points']),
    close: readBool(m['close']) ?? false,
    fillType: readEnum(PathFillType.values, m['fillType'], PathFillType.nonZero),
    trimStart: _numOr(m['trimStart'], 0),
    trimEnd: _numOr(m['trimEnd'], 1),
  );

  @override
  void _write(Json j) {
    put(j, 'd', d);
    if (commands != null) j['commands'] = [for (final c in commands!) c.toJson()];
    if (points != null) j['points'] = writeExprPoints(points!);
    put(j, 'close', close, false);
    put(j, 'fillType', fillType.name, PathFillType.nonZero.name);
    _putNum(j, 'trimStart', trimStart, 0);
    _putNum(j, 'trimEnd', trimEnd, 1);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, d, commands, points, close, fillType, trimStart, trimEnd];

  PathOp copyWith({
    String? id,
    Expr<bool>? when,
    List<Expr<DrawPaint>>? paint,
    String? hit,
    String? d,
    List<PathCommand>? commands,
    Expr<List<Vec?>>? points,
    bool? close,
    PathFillType? fillType,
    Expr<double>? trimStart,
    Expr<double>? trimEnd,
  }) => PathOp(
    id: id ?? this.id,
    when: when ?? this.when,
    extra: extra,
    paint: paint ?? this.paint,
    hit: hit ?? this.hit,
    d: d ?? this.d,
    commands: commands ?? this.commands,
    points: points ?? this.points,
    close: close ?? this.close,
    fillType: fillType ?? this.fillType,
    trimStart: trimStart ?? this.trimStart,
    trimEnd: trimEnd ?? this.trimEnd,
  );
}

/// `Canvas.drawLine(p1, p2, paint)`.
final class LineOp extends ShapeOp {
  const LineOp({super.id, super.when, super.extra, super.paint, super.hit, this.p1, this.p2});

  final Expr<Vec>? p1, p2;

  @override
  String get op => 'line';
  static const keys = {'p1', 'p2', ...ShapeOp._shapeKeys};

  static LineOp _read(Json m, _Common c) => LineOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    p1: readExprVec(m['p1'], _point),
    p2: readExprVec(m['p2'], _point),
  );

  @override
  void _write(Json j) {
    _putVec(j, 'p1', p1);
    _putVec(j, 'p2', p2);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, p1, p2];

  LineOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, Expr<Vec>? p1, Expr<Vec>? p2}) =>
      LineOp(id: id ?? this.id, when: when ?? this.when, extra: extra, paint: paint ?? this.paint, hit: hit ?? this.hit, p1: p1 ?? this.p1, p2: p2 ?? this.p2);
}

/// `Canvas.drawRect(rect, paint)`; [rect] is `[left, top, width, height]`.
final class RectOp extends ShapeOp {
  const RectOp({super.id, super.when, super.extra, super.paint, super.hit, this.rect});

  final Expr<Vec>? rect;

  @override
  String get op => 'rect';
  static const keys = {'rect', ...ShapeOp._shapeKeys};

  static RectOp _read(Json m, _Common c) => RectOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    rect: readExprVec(m['rect'], _rect),
  );

  @override
  void _write(Json j) {
    _putVec(j, 'rect', rect);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, rect];

  RectOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, Expr<Vec>? rect}) =>
      RectOp(id: id ?? this.id, when: when ?? this.when, extra: extra, paint: paint ?? this.paint, hit: hit ?? this.hit, rect: rect ?? this.rect);
}

Expr<BorderRadius> _radiusOr(Object? j) =>
    Expr.isSource(j) ? Expr<BorderRadius>.source(j as String) : Expr(j == null ? BorderRadius.zero : BorderRadius.fromJson(j));

void _putRadius(Json j, String k, Expr<BorderRadius> r) {
  if (r != const Expr(BorderRadius.zero)) j[k] = r.toJson((v) => v.toJson());
}

/// `Canvas.drawRRect(RRect.fromRectAndCorners(rect, ...), paint)`; [radius]
/// as a decoration's (`8`, `[x, y]`, `[tl, tr, br, bl]`).
final class RRectOp extends ShapeOp {
  const RRectOp({super.id, super.when, super.extra, super.paint, super.hit, this.rect, this.radius = const Expr(BorderRadius.zero)});

  final Expr<Vec>? rect;
  final Expr<BorderRadius> radius;

  @override
  String get op => 'rrect';
  static const keys = {'rect', 'radius', ...ShapeOp._shapeKeys};

  static RRectOp _read(Json m, _Common c) => RRectOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    rect: readExprVec(m['rect'], _rect),
    radius: _radiusOr(m['radius']),
  );

  @override
  void _write(Json j) {
    _putVec(j, 'rect', rect);
    _putRadius(j, 'radius', radius);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, rect, radius];

  RRectOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, Expr<Vec>? rect, Expr<BorderRadius>? radius}) =>
      RRectOp(id: id ?? this.id, when: when ?? this.when, extra: extra, paint: paint ?? this.paint, hit: hit ?? this.hit, rect: rect ?? this.rect, radius: radius ?? this.radius);
}

/// `Canvas.drawCircle(c, radius, paint)`.
final class CircleOp extends ShapeOp {
  const CircleOp({super.id, super.when, super.extra, super.paint, super.hit, this.c, this.radius = const Expr(0.0)});

  /// The center, `[x, y]`. JSON also reads `center`.
  final Expr<Vec>? c;
  final Expr<double> radius;

  @override
  String get op => 'circle';
  static const keys = {'c', 'radius', ...ShapeOp._shapeKeys};

  static CircleOp _read(Json m, _Common c) => CircleOp(
    id: c.id,
    when: c.when,
    extra: c.extra({...keys, 'center'}),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    c: readExprVec(m['c'] ?? m['center'], _point),
    radius: _numOr(m['radius'], 0),
  );

  @override
  void _write(Json j) {
    _putVec(j, 'c', c);
    _putNum(j, 'radius', radius, 0);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, c, radius];

  CircleOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, Expr<Vec>? c, Expr<double>? radius}) =>
      CircleOp(id: id ?? this.id, when: when ?? this.when, extra: extra, paint: paint ?? this.paint, hit: hit ?? this.hit, c: c ?? this.c, radius: radius ?? this.radius);
}

/// `Canvas.drawOval(rect, paint)`.
final class OvalOp extends ShapeOp {
  const OvalOp({super.id, super.when, super.extra, super.paint, super.hit, this.rect});

  final Expr<Vec>? rect;

  @override
  String get op => 'oval';
  static const keys = {'rect', ...ShapeOp._shapeKeys};

  static OvalOp _read(Json m, _Common c) => OvalOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    rect: readExprVec(m['rect'], _rect),
  );

  @override
  void _write(Json j) {
    _putVec(j, 'rect', rect);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, rect];

  OvalOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, Expr<Vec>? rect}) =>
      OvalOp(id: id ?? this.id, when: when ?? this.when, extra: extra, paint: paint ?? this.paint, hit: hit ?? this.hit, rect: rect ?? this.rect);
}

/// `Canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint)`: angles
/// in radians, clockwise from 3 o'clock, as Flutter's.
final class ArcOp extends ShapeOp {
  const ArcOp({
    super.id,
    super.when,
    super.extra,
    super.paint,
    super.hit,
    this.rect,
    this.startAngle = const Expr(0.0),
    this.sweepAngle = const Expr(0.0),
    this.useCenter = false,
  });

  final Expr<Vec>? rect;
  final Expr<double> startAngle, sweepAngle;
  final bool useCenter;

  @override
  String get op => 'arc';
  static const keys = {'rect', 'startAngle', 'sweepAngle', 'useCenter', ...ShapeOp._shapeKeys};

  static ArcOp _read(Json m, _Common c) => ArcOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    rect: readExprVec(m['rect'], _rect),
    startAngle: _numOr(m['startAngle'], 0),
    sweepAngle: _numOr(m['sweepAngle'], 0),
    useCenter: readBool(m['useCenter']) ?? false,
  );

  @override
  void _write(Json j) {
    _putVec(j, 'rect', rect);
    _putNum(j, 'startAngle', startAngle, 0);
    _putNum(j, 'sweepAngle', sweepAngle, 0);
    put(j, 'useCenter', useCenter, false);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, rect, startAngle, sweepAngle, useCenter];

  ArcOp copyWith({
    String? id,
    Expr<bool>? when,
    List<Expr<DrawPaint>>? paint,
    String? hit,
    Expr<Vec>? rect,
    Expr<double>? startAngle,
    Expr<double>? sweepAngle,
    bool? useCenter,
  }) => ArcOp(
    id: id ?? this.id,
    when: when ?? this.when,
    extra: extra,
    paint: paint ?? this.paint,
    hit: hit ?? this.hit,
    rect: rect ?? this.rect,
    startAngle: startAngle ?? this.startAngle,
    sweepAngle: sweepAngle ?? this.sweepAngle,
    useCenter: useCenter ?? this.useCenter,
  );
}

/// `Canvas.drawPoints(pointMode, points, paint)`.
final class PointsOp extends ShapeOp {
  const PointsOp({super.id, super.when, super.extra, super.paint, super.hit, this.pointMode = PointMode.points, this.points});

  final PointMode pointMode;
  final Expr<List<Vec?>>? points;

  @override
  String get op => 'points';
  static const keys = {'pointMode', 'points', ...ShapeOp._shapeKeys};

  static PointsOp _read(Json m, _Common c) => PointsOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    pointMode: readEnum(PointMode.values, m['pointMode'], PointMode.points),
    points: readExprPoints(m['points']),
  );

  @override
  void _write(Json j) {
    put(j, 'pointMode', pointMode.name, PointMode.points.name);
    if (points != null) j['points'] = writeExprPoints(points!);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, pointMode, points];

  PointsOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, PointMode? pointMode, Expr<List<Vec?>>? points}) =>
      PointsOp(
        id: id ?? this.id,
        when: when ?? this.when,
        extra: extra,
        paint: paint ?? this.paint,
        hit: hit ?? this.hit,
        pointMode: pointMode ?? this.pointMode,
        points: points ?? this.points,
      );
}

/// `Canvas.drawParagraph` (what `TextPainter(text: TextSpan(text, style))
/// ..layout(maxWidth: maxWidth)..paint(canvas, offset)` draws): [text] (may
/// hold `${...}`) in [style], laid out up to [maxWidth] and [maxLines],
/// with the point [anchor] names (top left by default) at [offset]. A
/// [paint] is the text's `TextStyle.foreground`.
final class ParagraphOp extends ShapeOp {
  const ParagraphOp({
    super.id,
    super.when,
    super.extra,
    super.paint,
    super.hit,
    this.text = '',
    this.style = TextStyle.empty,
    this.offset,
    this.anchor = Alignment.topLeft,
    this.maxWidth,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final Expr<Vec>? offset;
  final Alignment anchor;
  final Expr<double>? maxWidth;
  final TextAlign textAlign;
  final int? maxLines;

  @override
  String get op => 'paragraph';
  static const keys = {'text', 'style', 'offset', 'anchor', 'maxWidth', 'textAlign', 'maxLines', ...ShapeOp._shapeKeys};

  static ParagraphOp _read(Json m, _Common c) => ParagraphOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    text: readString(m['text']) ?? (m['text'] is num ? '${m['text']}' : ''),
    style: TextStyle.fromJson(m['style']),
    offset: readExprVec(m['offset'], _point),
    anchor: Alignment.fromJson(m['anchor']) ?? Alignment.topLeft,
    maxWidth: _num(m['maxWidth']),
    textAlign: readEnum(TextAlign.values, m['textAlign'], TextAlign.start),
    maxLines: readInt(m['maxLines'])?.let((n) => n > 0 ? n : null),
  );

  @override
  void _write(Json j) {
    put(j, 'text', text, '');
    if (!style.isEmpty) j['style'] = style.toJson();
    _putVec(j, 'offset', offset);
    if (anchor != Alignment.topLeft) j['anchor'] = anchor.toJson();
    _putNum(j, 'maxWidth', maxWidth);
    put(j, 'textAlign', textAlign.name, TextAlign.start.name);
    put(j, 'maxLines', maxLines);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, text, style, offset, anchor, maxWidth, textAlign, maxLines];

  ParagraphOp copyWith({
    String? id,
    Expr<bool>? when,
    List<Expr<DrawPaint>>? paint,
    String? hit,
    String? text,
    TextStyle? style,
    Expr<Vec>? offset,
    Alignment? anchor,
    Expr<double>? maxWidth,
    TextAlign? textAlign,
    int? maxLines,
  }) => ParagraphOp(
    id: id ?? this.id,
    when: when ?? this.when,
    extra: extra,
    paint: paint ?? this.paint,
    hit: hit ?? this.hit,
    text: text ?? this.text,
    style: style ?? this.style,
    offset: offset ?? this.offset,
    anchor: anchor ?? this.anchor,
    maxWidth: maxWidth ?? this.maxWidth,
    textAlign: textAlign ?? this.textAlign,
    maxLines: maxLines ?? this.maxLines,
  );
}

/// `Canvas.drawImageRect(image, src, dst, paint)`: the image at [url] (may
/// hold `${...}`), its [src] rect (source pixels; null: the whole image)
/// drawn into [dst] (null: the whole drawing). Without a [paint], Flutter's
/// default `Paint()`.
final class ImageOp extends ShapeOp {
  const ImageOp({super.id, super.when, super.extra, super.paint, super.hit, this.url = '', this.src, this.dst});

  final String url;
  final Expr<Vec>? src, dst;

  @override
  String get op => 'image';
  static const keys = {'url', 'src', 'dst', ...ShapeOp._shapeKeys};

  static ImageOp _read(Json m, _Common c) => ImageOp(
    id: c.id,
    when: c.when,
    extra: c.extra(keys),
    paint: readPaints(m['paint']),
    hit: readString(m['hit']),
    url: readString(m['url']) ?? '',
    src: readExprVec(m['src'], _rect),
    dst: readExprVec(m['dst'], _rect),
  );

  @override
  void _write(Json j) {
    put(j, 'url', url, '');
    _putVec(j, 'src', src);
    _putVec(j, 'dst', dst);
    _writeShape(j);
  }

  @override
  List<Object?> get _props => [paint, hit, url, src, dst];

  ImageOp copyWith({String? id, Expr<bool>? when, List<Expr<DrawPaint>>? paint, String? hit, String? url, Expr<Vec>? src, Expr<Vec>? dst}) =>
      ImageOp(
        id: id ?? this.id,
        when: when ?? this.when,
        extra: extra,
        paint: paint ?? this.paint,
        hit: hit ?? this.hit,
        url: url ?? this.url,
        src: src ?? this.src,
        dst: dst ?? this.dst,
      );
}

/// A rounded clip: Flutter's `RRect` as `{"rect": [l, t, w, h], "radius"}`.
@immutable
final class DrawRRect {
  const DrawRRect({required this.rect, this.radius = const Expr(BorderRadius.zero)});
  final Expr<Vec> rect;
  final Expr<BorderRadius> radius;

  static DrawRRect? fromJson(Object? json) {
    final m = readMap(json);
    final rect = readExprVec(m?['rect'], _rect);
    if (m == null || rect == null) return null;
    return DrawRRect(rect: rect, radius: _radiusOr(m['radius']));
  }

  Json toJson() {
    final j = <String, Object?>{'rect': writeExprVec(rect)};
    _putRadius(j, 'radius', radius);
    return j;
  }

  @override
  bool operator ==(Object other) => other is DrawRRect && other.rect == rect && other.radius == radius;

  @override
  int get hashCode => Object.hash(rect, radius);
}

/// `canvas.save()` (`saveLayer` with [opacity] or [blendMode]), then
/// `translate`, `scale`, `rotate` (radians) and `transform` (a `Matrix4`'s
/// 16 numbers, column-major as `Matrix4.storage`), in that order, then
/// `clipRect`, `clipRRect`, `clipPath`; its [ops]; `canvas.restore()`.
final class GroupOp extends DrawOp {
  const GroupOp({
    super.id,
    super.when,
    super.extra,
    this.ops = const [],
    this.translate,
    this.scale,
    this.rotate,
    this.transform,
    this.clipRect,
    this.clipRRect,
    this.clipPath,
    this.opacity = const Expr(1.0),
    this.blendMode = BlendMode.srcOver,
  });

  final List<DrawOp> ops;

  /// `[dx, dy]`.
  final Expr<Vec>? translate;

  /// `sx`, or `[sx, sy]`.
  final Expr<Vec>? scale;

  /// Radians, clockwise.
  final Expr<double>? rotate;
  final Expr<Vec>? transform;
  final Expr<Vec>? clipRect;
  final DrawRRect? clipRRect;

  /// SVG path data; may hold `${...}`.
  final String? clipPath;

  /// 0–1: below 1 the group is a layer drawn at this opacity.
  final Expr<double> opacity;
  final BlendMode blendMode;

  @override
  String get op => 'group';
  static const keys = {'ops', 'translate', 'scale', 'rotate', 'transform', 'clipRect', 'clipRRect', 'clipPath', 'opacity', 'blendMode'};

  static GroupOp _read(Json m, _Common c) {
    final opacity = _numOr(m['opacity'], 1);
    return GroupOp(
      id: c.id,
      when: c.when,
      extra: c.extra(keys),
      ops: DrawOp.listFromJson(m['ops']),
      translate: readExprVec(m['translate'], _point),
      scale: readExprVec(m['scale'], const {1, 2}),
      rotate: _num(m['rotate']),
      transform: readExprVec(m['transform'], const {16}),
      clipRect: readExprVec(m['clipRect'], _rect),
      clipRRect: DrawRRect.fromJson(m['clipRRect']),
      clipPath: readString(m['clipPath']),
      opacity: opacity.value == null ? opacity : Expr(opacity.value!.clamp(0, 1).toDouble()),
      blendMode: readEnum(BlendMode.values, m['blendMode'], BlendMode.srcOver),
    );
  }

  @override
  void _write(Json j) {
    if (ops.isNotEmpty) j['ops'] = [for (final o in ops) o.toJson()];
    _putVec(j, 'translate', translate);
    _putVec(j, 'scale', scale);
    _putNum(j, 'rotate', rotate);
    _putVec(j, 'transform', transform);
    _putVec(j, 'clipRect', clipRect);
    put(j, 'clipRRect', clipRRect?.toJson());
    put(j, 'clipPath', clipPath);
    _putNum(j, 'opacity', opacity, 1);
    put(j, 'blendMode', blendMode.name, BlendMode.srcOver.name);
  }

  @override
  List<Object?> get _props => [ops, translate, scale, rotate, transform, clipRect, clipRRect, clipPath, opacity, blendMode];

  GroupOp copyWith({
    String? id,
    Expr<bool>? when,
    List<DrawOp>? ops,
    Expr<Vec>? translate,
    Expr<Vec>? scale,
    Expr<double>? rotate,
    Expr<Vec>? transform,
    Expr<Vec>? clipRect,
    DrawRRect? clipRRect,
    String? clipPath,
    Expr<double>? opacity,
    BlendMode? blendMode,
  }) => GroupOp(
    id: id ?? this.id,
    when: when ?? this.when,
    extra: extra,
    ops: ops ?? this.ops,
    translate: translate ?? this.translate,
    scale: scale ?? this.scale,
    rotate: rotate ?? this.rotate,
    transform: transform ?? this.transform,
    clipRect: clipRect ?? this.clipRect,
    clipRRect: clipRRect ?? this.clipRRect,
    clipPath: clipPath ?? this.clipPath,
    opacity: opacity ?? this.opacity,
    blendMode: blendMode ?? this.blendMode,
  );
}

/// Its [ops] once per item of [each] (an expression giving a list; a map
/// gives its values), or [count] times: Flutter's
/// `for (final (index, item) in list.indexed) { ... }`. Inside, the item is
/// named [as] (`item`), its position [indexAs] (`index`), and `count` is
/// how many there are.
final class RepeatOp extends DrawOp {
  const RepeatOp({super.id, super.when, super.extra, this.each, this.count, this.as = 'item', this.indexAs = 'index', this.ops = const []});

  /// An expression giving the list (`${cells}`).
  final String? each;

  /// Without [each]: how many times.
  final Expr<double>? count;
  final String as, indexAs;
  final List<DrawOp> ops;

  @override
  String get op => 'repeat';
  static const keys = {'each', 'count', 'as', 'indexAs', 'ops'};

  static RepeatOp _read(Json m, _Common c) {
    String name(Object? v, String fallback) => v is String && RegExp(r'^[A-Za-z_]\w*$').hasMatch(v) ? v : fallback;
    return RepeatOp(
      id: c.id,
      when: c.when,
      extra: c.extra(keys),
      each: readString(m['each']),
      count: _num(m['count']),
      as: name(m['as'], 'item'),
      indexAs: name(m['indexAs'], 'index'),
      ops: DrawOp.listFromJson(m['ops']),
    );
  }

  @override
  void _write(Json j) {
    put(j, 'each', each);
    _putNum(j, 'count', count);
    put(j, 'as', as, 'item');
    put(j, 'indexAs', indexAs, 'index');
    if (ops.isNotEmpty) j['ops'] = [for (final o in ops) o.toJson()];
  }

  @override
  List<Object?> get _props => [each, count, as, indexAs, ops];

  RepeatOp copyWith({String? id, Expr<bool>? when, String? each, Expr<double>? count, String? as, String? indexAs, List<DrawOp>? ops}) =>
      RepeatOp(
        id: id ?? this.id,
        when: when ?? this.when,
        extra: extra,
        each: each ?? this.each,
        count: count ?? this.count,
        as: as ?? this.as,
        indexAs: indexAs ?? this.indexAs,
        ops: ops ?? this.ops,
      );
}

/// An op this version doesn't know: kept whole and written back; it draws
/// nothing.
final class UnknownDrawOp extends DrawOp {
  UnknownDrawOp(this.json) : super(id: readString(json['id']));

  final Json json;

  @override
  String get op => '${json['op']}';

  @override
  Json toJson() => {...json};

  @override
  void _write(Json j) {}

  @override
  List<Object?> get _props => [json];
}

// --- the behavior ----------------------------------------------------------------

/// Flutter's `CustomPaint` on a node: [painter] drawn behind the node's
/// content (its decoration and children) and [foregroundPainter] over it,
/// both in the node's box (inside its transform and opacity, outside its
/// clip). The node's layout is `CustomPaint.size`; its content is `child`.
///
/// [viewBox] is the ops' coordinate space, `[minX, minY, width, height]`
/// (JSON also `[width, height]`), mapped onto the box by [fit] (`fill`
/// stretches, as the `path` node's view box does); null: the box's own
/// pixels. In expressions `size.width` and `size.height` are the view
/// box's size when there is one, else the box's.
@immutable
final class CustomPaint {
  const CustomPaint({
    this.painter = const [],
    this.foregroundPainter = const [],
    this.viewBox,
    this.fit = BoxFit.fill,
    this.isComplex = false,
    this.willChange = false,
  });

  final List<DrawOp> painter;
  final List<DrawOp> foregroundPainter;

  /// `[minX, minY, width, height]`, width and height above 0.
  final List<double>? viewBox;
  final BoxFit fit;

  /// Raster cache hints (`CustomPaint.isComplex`, `willChange`).
  final bool isComplex, willChange;

  static const keys = {'painter', 'foregroundPainter', 'viewBox', 'fit', 'isComplex', 'willChange'};

  /// A view box: `[width, height]` or `[minX, minY, width, height]` with a
  /// positive size, as `[minX, minY, width, height]`; else null.
  static List<double>? readViewBox(Object? json) {
    final l = readList(json)?.map(readDouble).toList();
    if (l == null || l.any((v) => v == null)) return null;
    final v = l.length == 2 ? [0.0, 0.0, l[0]!, l[1]!] : (l.length == 4 ? l.cast<double>() : null);
    return v == null || v[2] <= 0 || v[3] <= 0 ? null : v;
  }

  /// [readViewBox]'s JSON: `[width, height]` when it starts at the origin.
  static List<num> writeViewBox(List<double> v) =>
      v[0] == 0 && v[1] == 0 ? [writeDouble(v[2]), writeDouble(v[3])] : v.map(writeDouble).toList();

  static CustomPaint? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return CustomPaint(
      painter: DrawOp.listFromJson(m['painter']),
      foregroundPainter: DrawOp.listFromJson(m['foregroundPainter']),
      viewBox: readViewBox(m['viewBox']),
      fit: readEnum(BoxFit.values, m['fit'], BoxFit.fill),
      isComplex: readBool(m['isComplex']) ?? false,
      willChange: readBool(m['willChange']) ?? false,
    );
  }

  Json toJson() {
    final j = <String, Object?>{};
    if (painter.isNotEmpty) j['painter'] = [for (final o in painter) o.toJson()];
    if (foregroundPainter.isNotEmpty) j['foregroundPainter'] = [for (final o in foregroundPainter) o.toJson()];
    put(j, 'viewBox', viewBox == null ? null : writeViewBox(viewBox!));
    put(j, 'fit', fit.name, BoxFit.fill.name);
    put(j, 'isComplex', isComplex, false);
    put(j, 'willChange', willChange, false);
    return j;
  }

  CustomPaint copyWith({
    List<DrawOp>? painter,
    List<DrawOp>? foregroundPainter,
    List<double>? viewBox,
    BoxFit? fit,
    bool? isComplex,
    bool? willChange,
  }) => CustomPaint(
    painter: painter ?? this.painter,
    foregroundPainter: foregroundPainter ?? this.foregroundPainter,
    viewBox: viewBox ?? this.viewBox,
    fit: fit ?? this.fit,
    isComplex: isComplex ?? this.isComplex,
    willChange: willChange ?? this.willChange,
  );

  /// Every op of both lists, groups' and repeats' ops included, depth first.
  Iterable<DrawOp> get allOps sync* {
    Iterable<DrawOp> walk(List<DrawOp> ops) sync* {
      for (final o in ops) {
        yield o;
        if (o is GroupOp) yield* walk(o.ops);
        if (o is RepeatOp) yield* walk(o.ops);
      }
    }

    yield* walk(painter);
    yield* walk(foregroundPainter);
  }

  /// Whether a shape in it is a hit region.
  bool get hasHitRegions => allOps.any((o) => o is ShapeOp && o.hit != null);

  List<Object?> get _props => [painter, foregroundPainter, viewBox, fit, isComplex, willChange];

  @override
  bool operator ==(Object other) => identical(this, other) || other is CustomPaint && jsonEquality.equals(other._props, _props);

  @override
  int get hashCode => jsonEquality.hash(_props);

  @override
  String toString() => 'CustomPaint(${toJson()})';
}
