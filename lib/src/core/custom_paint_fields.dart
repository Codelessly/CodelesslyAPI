// `customPaint` declared as fields (custom_paint.dart's models), the way
// behavior_fields.dart declares the other behaviors: a properties panel
// builds the custom paint section, the op list's "add op" menu and each
// op's fields from these alone.
//
// An op is a union on its `op` key, declared as [DrawOpSpecs] (one
// [DrawOpSpec] per op, as `ActionSpecs` declares actions). A field that
// takes an expression as well as a literal has an [ExprCodec]: its
// [PropCodec.type] is the literal's, and a panel shows that control with a
// formula toggle. test/custom_paint_test.dart round-trips a sample of every
// field through the models' real JSON.
import 'custom_paint.dart';
import 'json.dart';
import 'props.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/paint.dart';
import 'values/text.dart';

Object? _out(Object? v) => v == null ? null : (v as dynamic).toJson();

/// A value or an expression (`"${...}"`) giving one: [inner] reads and
/// writes the literal, and its type is the field's type.
final class ExprCodec<T extends Object> extends PropCodec<Expr<T>> {
  const ExprCodec(this.inner);
  final PropCodec<T> inner;
  @override
  Expr<T>? decode(Object? json) => Expr.read<T>(json, inner.decode);
  @override
  Object? encode(Expr<T> value) => value.source ?? inner.encode(value.value as T);
  @override
  PropType get type => inner.type;
}

/// A list of numbers of one of [lengths] (`[x, y]`, `[l, t, w, h]`), each a
/// literal or an expression.
final class VecCodec extends PropCodec<Vec> {
  const VecCodec(this.lengths, this.type);
  final Set<int> lengths;
  @override
  final PropType type;
  @override
  Vec? decode(Object? json) =>
      lengths.contains(1) && readDouble(json) != null ? [Expr(readDouble(json)!)] : readVec(json, lengths);
  @override
  Object? encode(Vec value) => value.length == 1 ? writeExprVec(Expr(value)) : writeVec(value);
}

/// Points (`[[x, y], ...]`, a `null` breaking the line).
final class PointsCodec extends PropCodec<List<Vec?>> {
  const PointsCodec();
  @override
  List<Vec?>? decode(Object? json) => readPoints(json);
  @override
  Object? encode(List<Vec?> value) => writePoints(value);
  @override
  PropType get type => const PropType.list(PropTypes.offset);
}

/// A path op's `commands`: Flutter `Path` builder calls ([PathCommand]).
final class PathCommandsCodec extends PropCodec<List<PathCommand>> {
  const PathCommandsCodec();
  @override
  List<PathCommand>? decode(Object? json) => readPathCommands(json);
  @override
  Object? encode(List<PathCommand> value) => [for (final c in value) c.toJson()];
  @override
  PropType get type => const PropType.list(pathCommandType);
}

/// One `Path` builder call: `{"<method>": [numbers...], "when": ...}`.
const pathCommandType = PropType.json('PathCommand');

/// An op's `paint`: one [DrawPaint] or several (each may be an expression).
final class DrawPaintsCodec extends PropCodec<List<Expr<DrawPaint>>> {
  const DrawPaintsCodec();
  @override
  List<Expr<DrawPaint>>? decode(Object? json) => json == null ? null : readPaints(json);
  @override
  Object? encode(List<Expr<DrawPaint>> value) => writePaints(value);
  @override
  PropType get type => const PropType.list(drawPaintType);
}

/// A list of draw ops.
final class DrawOpsCodec extends PropCodec<List<DrawOp>> {
  const DrawOpsCodec();
  @override
  List<DrawOp>? decode(Object? json) => readList(json) == null ? null : DrawOp.listFromJson(json);
  @override
  Object? encode(List<DrawOp> value) => [for (final o in value) o.toJson()];
  @override
  PropType get type => const PropType.list(drawOpType);
}

/// One draw op: a union on `op`, its fields per [DrawOpSpecs].
const drawOpType = PropType.json('DrawOp');
const drawPaintType = PropType.object('DrawPaint', drawPaintFields);
const customPaintType = PropType.object('CustomPaint', customPaintFields);
const drawRRectType = PropType.object('DrawRRect', drawRRectFields);

const _num = ExprCodec<double>(Codecs.double);
const _positive = ExprCodec<double>(Codecs.positive);
const _fraction = ExprCodec<double>(DoubleCodec(min: 0, max: 1));
const _point = ExprCodec<Vec>(VecCodec({2}, PropTypes.offset));
const _rect = ExprCodec<Vec>(VecCodec({4}, PropType.value('Rect')));
const _points = ExprCodec<List<Vec?>>(PointsCodec());
const _radius = ExprCodec<BorderRadius>(Codecs.radius);
const _ops = DrawOpsCodec();

/// A view box: `[width, height]` or `[minX, minY, width, height]`.
const _viewBox = ValueCodec<List<double>?>(CustomPaint.readViewBox, _viewBoxOut, PropType.value('Rect'));
Object? _viewBoxOut(List<double>? v) => v == null ? null : CustomPaint.writeViewBox(v);

// --- CustomPaint -------------------------------------------------------------------

/// [CustomPaint]: the `customPaint` behavior.
abstract final class CustomPaintFields {
  static const painter = PropDef<List<DrawOp>>('painter', _ops, [], doc: 'Drawn behind the node\'s content (CustomPaint.painter).');
  static const foregroundPainter = PropDef<List<DrawOp>>('foregroundPainter', _ops, [],
      doc: 'Drawn over the node\'s content (CustomPaint.foregroundPainter).');
  static const viewBox = PropDef<List<double>?>('viewBox', _viewBox, null,
      doc: 'The ops\' coordinates, [width, height] or [minX, minY, width, height], mapped onto the box by fit. Null: box pixels.');
  static const fit = PropDef<BoxFit>('fit', EnumCodec(BoxFit.values), BoxFit.fill, doc: 'How the view box maps onto the box.');
  static const isComplex = PropDef<bool>('isComplex', Codecs.bool, false, doc: 'Raster cache hint: the drawing is costly.');
  static const willChange = PropDef<bool>('willChange', Codecs.bool, false, doc: 'Raster cache hint: the drawing changes often.');
  static const List<PropDef<Object?>> all = [painter, foregroundPainter, viewBox, fit, isComplex, willChange];
}

List<PropDef<Object?>> customPaintFields() => CustomPaintFields.all;

// --- DrawPaint ---------------------------------------------------------------------

/// [DrawPaint]: Flutter's `Paint`.
abstract final class DrawPaintFields {
  static const id = PropDef<String?>('id', Codecs.optionalString, null);
  static const color = PropDef<Expr<Color>>('color', ExprCodec<Color>(Codecs.color), Expr(Color.black));
  static const shader = PropDef<Paint?>('shader', Codecs.paint, null,
      doc: 'A gradient or image laid out in the shape\'s bounds (Gradient.createShader(rect)).');
  static const style = PropDef<PaintingStyle>('style', EnumCodec(PaintingStyle.values), PaintingStyle.fill);
  static const strokeWidth = PropDef<Expr<double>>('strokeWidth', _positive, Expr(0.0), doc: '0 is a hairline, as Flutter\'s.');
  static const strokeCap = PropDef<StrokeCap>('strokeCap', EnumCodec(StrokeCap.values), StrokeCap.butt);
  static const strokeJoin = PropDef<StrokeJoin>('strokeJoin', EnumCodec(StrokeJoin.values), StrokeJoin.miter);
  static const strokeMiterLimit = PropDef<double>('strokeMiterLimit', Codecs.double, 4);
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  static const isAntiAlias = PropDef<bool>('isAntiAlias', Codecs.bool, true);
  static const dashPattern = PropDef<List<double>>('dashPattern', ListCodec(Codecs.positive), [],
      doc: 'Dash and gap lengths, alternating; empty is solid.');
  static const scaleStroke = PropDef<bool>('scaleStroke', Codecs.bool, true,
      doc: 'Off: the stroke width and dashes stay in box pixels under a scaling view box or group.');
  static const List<PropDef<Object?>> all = [
    id, color, shader, style, strokeWidth, strokeCap, strokeJoin, strokeMiterLimit, blendMode, isAntiAlias, //
    dashPattern, scaleStroke,
  ];
}

List<PropDef<Object?>> drawPaintFields() => DrawPaintFields.all;

abstract final class DrawRRectFields {
  static const rect = PropDef<Expr<Vec>?>('rect', _rect, null);
  static const radius = PropDef<Expr<BorderRadius>>('radius', _radius, Expr(BorderRadius.zero));
  static const List<PropDef<Object?>> all = [rect, radius];
}

List<PropDef<Object?>> drawRRectFields() => DrawRRectFields.all;

// --- ops ---------------------------------------------------------------------------

/// A draw op, as an editor shows it.
final class DrawOpSpec {
  const DrawOpSpec(this.op, {required this.label, required this.flutter, required this.fields, this.doc = ''});

  /// The JSON `op`.
  final String op;
  final String label;

  /// What it is in Flutter (`Canvas.drawCircle`).
  final String flutter;

  /// Its own fields (not [DrawOpCommonFields]).
  final List<PropDef<Object?>> fields;
  final String doc;
}

/// The fields every op has.
abstract final class DrawOpCommonFields {
  static const id = PropDef<String?>('id', Codecs.optionalString, null,
      doc: 'Stable name: editor selection and binding paths (customPaint.painter.<id>.<field>).');
  static const when = PropDef<Expr<bool>?>('when', ExprCodec<bool>(Codecs.bool), null, doc: 'Drawn only while it holds.');
  static const List<PropDef<Object?>> all = [id, when];
}

/// The fields every shape op has.
abstract final class ShapeOpFields {
  static const paint = PropDef<List<Expr<DrawPaint>>>('paint', DrawPaintsCodec(), [],
      doc: 'Each paint draws the shape once, in order (Flutter\'s Paint). None: an invisible hit region.');
  static const hit = PropDef<String?>('hit', Codecs.optionalString, null,
      doc: 'Makes the shape a hit region: pointer reactions get its id as \${result.region}.');
  static const List<PropDef<Object?>> all = [paint, hit];
}

abstract final class PathOpFields {
  static const d = PropDef<String?>('d', Codecs.optionalString, null, doc: 'SVG path data.');
  static const commands = PropDef<List<PathCommand>?>('commands', PathCommandsCodec(), null,
      doc: 'Without d: Path builder calls ({"moveTo": [x, y]}, lineTo, quadraticBezierTo, cubicTo, {"close": true}), '
          'each number a literal or an expression, each call with an optional "when".');
  static const points = PropDef<Expr<List<Vec?>>?>('points', _points, null,
      doc: 'Without d or commands: points joined by straight lines ([[x, y], ...]; null breaks the line).');
  static const close = PropDef<bool>('close', Codecs.bool, false, doc: 'Points: back to the first one.');
  static const fillType = PropDef<PathFillType>('fillType', EnumCodec(PathFillType.values), PathFillType.nonZero);
  static const trimStart = PropDef<Expr<double>>('trimStart', _fraction, Expr(0.0), doc: 'Drawn from this share of its length.');
  static const trimEnd = PropDef<Expr<double>>('trimEnd', _fraction, Expr(1.0), doc: 'Drawn up to this share of its length.');
  static const List<PropDef<Object?>> all = [d, commands, points, close, fillType, trimStart, trimEnd, ...ShapeOpFields.all];
}

abstract final class LineOpFields {
  static const p1 = PropDef<Expr<Vec>?>('p1', _point, null);
  static const p2 = PropDef<Expr<Vec>?>('p2', _point, null);
  static const List<PropDef<Object?>> all = [p1, p2, ...ShapeOpFields.all];
}

abstract final class RectOpFields {
  static const rect = PropDef<Expr<Vec>?>('rect', _rect, null, doc: '[left, top, width, height].');
  static const List<PropDef<Object?>> all = [rect, ...ShapeOpFields.all];
}

abstract final class RRectOpFields {
  static const rect = RectOpFields.rect;
  static const radius = PropDef<Expr<BorderRadius>>('radius', _radius, Expr(BorderRadius.zero));
  static const List<PropDef<Object?>> all = [rect, radius, ...ShapeOpFields.all];
}

abstract final class CircleOpFields {
  static const c = PropDef<Expr<Vec>?>('c', _point, null, doc: 'The center (drawCircle\'s c).');
  static const radius = PropDef<Expr<double>>('radius', _positive, Expr(0.0));
  static const List<PropDef<Object?>> all = [c, radius, ...ShapeOpFields.all];
}

abstract final class OvalOpFields {
  static const rect = RectOpFields.rect;
  static const List<PropDef<Object?>> all = [rect, ...ShapeOpFields.all];
}

abstract final class ArcOpFields {
  static const rect = RectOpFields.rect;
  static const startAngle = PropDef<Expr<double>>('startAngle', _num, Expr(0.0), doc: 'Radians, clockwise from 3 o\'clock.');
  static const sweepAngle = PropDef<Expr<double>>('sweepAngle', _num, Expr(0.0), doc: 'Radians, clockwise.');
  static const useCenter = PropDef<bool>('useCenter', Codecs.bool, false, doc: 'A pie slice rather than an arc.');
  static const List<PropDef<Object?>> all = [rect, startAngle, sweepAngle, useCenter, ...ShapeOpFields.all];
}

abstract final class PointsOpFields {
  static const pointMode = PropDef<PointMode>('pointMode', EnumCodec(PointMode.values), PointMode.points);
  static const points = PropDef<Expr<List<Vec?>>?>('points', _points, null);
  static const List<PropDef<Object?>> all = [pointMode, points, ...ShapeOpFields.all];
}

abstract final class ParagraphOpFields {
  static const text = PropDef<String>('text', Codecs.string, '', doc: 'May hold \${...}.');
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);
  static const offset = PropDef<Expr<Vec>?>('offset', _point, null, doc: 'Where the anchor point sits.');
  static const anchor = PropDef<Alignment>('anchor', Codecs.alignment, Alignment.topLeft,
      doc: 'Which point of the laid-out text sits at offset.');
  static const maxWidth = PropDef<Expr<double>?>('maxWidth', _positive, null, doc: 'TextPainter.layout(maxWidth:); null: unbounded.');
  static const textAlign = PropDef<TextAlign>('textAlign', EnumCodec(TextAlign.values), TextAlign.start);
  static const maxLines = PropDef<int?>('maxLines', Codecs.optionalInt, null);
  static const List<PropDef<Object?>> all = [text, style, offset, anchor, maxWidth, textAlign, maxLines, ...ShapeOpFields.all];
}

abstract final class ImageOpFields {
  static const url = PropDef<String>('url', Codecs.string, '', doc: 'May hold \${...}.');
  static const src = PropDef<Expr<Vec>?>('src', _rect, null, doc: 'The source rect in image pixels; null: the whole image.');
  static const dst = PropDef<Expr<Vec>?>('dst', _rect, null, doc: 'Where it is drawn; null: the whole drawing.');
  static const List<PropDef<Object?>> all = [url, src, dst, ...ShapeOpFields.all];
}

abstract final class GroupOpFields {
  static const ops = PropDef<List<DrawOp>>('ops', _ops, []);
  static const translate = PropDef<Expr<Vec>?>('translate', _point, null, doc: 'canvas.translate(dx, dy).');
  static const scale = PropDef<Expr<Vec>?>('scale', ExprCodec<Vec>(VecCodec({1, 2}, PropType.list(PropType.number()))), null,
      doc: 'canvas.scale(sx, [sy]).');
  static const rotate = PropDef<Expr<double>?>('rotate', _num, null, doc: 'canvas.rotate(radians).');
  static const transform = PropDef<Expr<Vec>?>(
    'transform',
    ExprCodec<Vec>(VecCodec({16}, PropType.list(PropType.number()))),
    null,
    doc: 'canvas.transform: a Matrix4\'s 16 numbers, column-major.',
  );
  static const clipRect = PropDef<Expr<Vec>?>('clipRect', _rect, null);
  static const clipRRect = PropDef<DrawRRect?>('clipRRect', ValueCodec(DrawRRect.fromJson, _out, drawRRectType), null);
  static const clipPath = PropDef<String?>('clipPath', Codecs.optionalString, null, doc: 'SVG path data.');
  static const opacity = PropDef<Expr<double>>('opacity', _fraction, Expr(1.0), doc: 'Below 1: a layer (saveLayer).');
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver,
      doc: 'Not srcOver: a layer blended so.');
  static const List<PropDef<Object?>> all = [
    ops, translate, scale, rotate, transform, clipRect, clipRRect, clipPath, opacity, blendMode, //
  ];
}

abstract final class RepeatOpFields {
  static const each = PropDef<String?>('each', Codecs.optionalString, null, doc: 'An expression giving the list (\${cells}).');
  static const count = PropDef<Expr<double>?>('count', _positive, null, doc: 'Without each: how many times.');
  static const as = PropDef<String>('as', Codecs.string, 'item', doc: 'The item\'s name inside.');
  static const indexAs = PropDef<String>('indexAs', Codecs.string, 'index', doc: 'The position\'s name inside.');
  static const ops = GroupOpFields.ops;
  static const List<PropDef<Object?>> all = [each, count, as, indexAs, ops];
}

/// Every op an editor can add, by its JSON `op`.
abstract final class DrawOpSpecs {
  static const List<DrawOpSpec> all = [
    DrawOpSpec('path', label: 'Path', flutter: 'Canvas.drawPath', fields: PathOpFields.all),
    DrawOpSpec('line', label: 'Line', flutter: 'Canvas.drawLine', fields: LineOpFields.all),
    DrawOpSpec('rect', label: 'Rectangle', flutter: 'Canvas.drawRect', fields: RectOpFields.all),
    DrawOpSpec('rrect', label: 'Rounded rectangle', flutter: 'Canvas.drawRRect', fields: RRectOpFields.all),
    DrawOpSpec('circle', label: 'Circle', flutter: 'Canvas.drawCircle', fields: CircleOpFields.all),
    DrawOpSpec('oval', label: 'Oval', flutter: 'Canvas.drawOval', fields: OvalOpFields.all),
    DrawOpSpec('arc', label: 'Arc', flutter: 'Canvas.drawArc', fields: ArcOpFields.all),
    DrawOpSpec('points', label: 'Points', flutter: 'Canvas.drawPoints', fields: PointsOpFields.all),
    DrawOpSpec('paragraph', label: 'Text', flutter: 'Canvas.drawParagraph', fields: ParagraphOpFields.all),
    DrawOpSpec('image', label: 'Image', flutter: 'Canvas.drawImageRect', fields: ImageOpFields.all),
    DrawOpSpec('group', label: 'Group', flutter: 'Canvas.save … restore', fields: GroupOpFields.all,
        doc: 'Transforms, clips and a layer around its ops.'),
    DrawOpSpec('repeat', label: 'Repeat', flutter: 'for (final (index, item) in list.indexed)', fields: RepeatOpFields.all,
        doc: 'Its ops once per item (\${item}, \${index}, \${count}).'),
  ];

  static DrawOpSpec? of(String op) {
    for (final s in all) {
      if (s.op == op) return s;
    }
    return null;
  }
}
