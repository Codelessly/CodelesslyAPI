// The fields of the core value types and of a node's layout and
// decoration, declared as PropDefs: each key is the value's JSON key (and
// Flutter's name), with its codec and default. With the widgets' own props
// they describe everything a node holds, so a properties panel, docs or
// codegen read one kind of declaration for all of it (see PropType).
//
// The models keep their own fromJson/toJson; test/value_fields_test.dart
// proves each declaration matches its model's JSON.
import 'decoration.dart';
import 'json.dart';
import 'layout.dart';
import 'props.dart';
import 'values/border.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/paint.dart';
import 'values/text.dart';

Object? _out(Object? v) => v == null ? null : (v as dynamic).toJson();
Object? _same(Object? v) => v;
AxisSize? _sizeIn(Object? j) => j == null ? null : AxisSize.fromJson(j);
AxisPosition? _positionIn(Object? j) => readMap(j) == null ? null : AxisPosition.fromJson(j);
ImagePaint? _imageIn(Object? j) => ImagePaint.fromJson(j);
ColorStop? _stopIn(Object? j) => ColorStop.fromJson(j);
List<double>? _rectIn(Object? j) => _doublesIn(j).let((l) => l != null && l.length == 4 ? l : null);
String? _featureIn(Object? j) => OpenTypeFeature.tryParse(j)?.toString();
List<double>? _doublesIn(Object? j) => readList(j)?.map(readDouble).nonNulls.toList();

/// `AxisSize`: a design size and how it fits (`SizedBox` / `Expanded` /
/// `Flexible` / intrinsic). JSON: a number or `{"fill"|"flexible"|"hug": v}`.
const axisSizeType = PropType.value('AxisSize');

/// `AxisPosition`: where a child of a freeform parent sits on one axis
/// (`Positioned` / `Align`).
const axisPositionType = PropType.value('AxisPosition');

/// Flutter's `FontWeight`, as its weight: 100, 200 ... 900.
final class FontWeightCodec extends PropCodec<int?> {
  const FontWeightCodec();
  @override
  int? decode(Object? json) => readInt(json).let((w) => w == null ? null : (w / 100).round().clamp(1, 9) * 100);
  @override
  Object? encode(int? value) => value;
  @override
  PropType get type => const PropType.value('FontWeight');
}

// --- TextStyle ---------------------------------------------------------------

abstract final class TextStyleFields {
  static const fontFamily = PropDef<String?>('fontFamily', Codecs.optionalString, null);

  /// Flutter's `FontWeight`: 100–900, in hundreds.
  static const fontWeight = PropDef<int?>('fontWeight', FontWeightCodec(), null);
  static const fontStyle = PropDef<FontStyle?>('fontStyle', OptionalEnumCodec(FontStyle.values), null);
  static const fontSize = PropDef<double?>('fontSize', Codecs.optionalPositive, null);
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const foreground = PropDef<Paint?>('foreground', Codecs.paint, null);
  static const letterSpacing = PropDef<double?>('letterSpacing', Codecs.optionalDouble, null);

  /// Line height, as a multiple of the font size.
  static const height = PropDef<double?>('height', Codecs.optionalPositive, null);
  static const decoration = PropDef<TextDecoration?>('decoration', OptionalEnumCodec(TextDecoration.values), null);
  static const decorationColor = PropDef<Color?>('decorationColor', Codecs.optionalColor, null);
  static const decorationStyle = PropDef<TextDecorationStyle?>(
    'decorationStyle',
    OptionalEnumCodec(TextDecorationStyle.values),
    null,
  );
  static const decorationThickness = PropDef<double?>('decorationThickness', Codecs.optionalDouble, null);
  static const tabularFigures = PropDef<bool?>('tabularFigures', Codecs.optionalBool, null);
  static const shadows = PropDef<List<Effect>>('shadows', Codecs.effects, []);

  /// OpenType feature settings (`"lnum"`, `"ss01"`, `"liga=0"`).
  static const fontFeatures = PropDef<List<String>>(
    'fontFeatures',
    ListCodec(ValueCodec<String>(_featureIn, _same, PropType.value('FontFeature'))),
    [],
  );
  static const leadingDistribution = PropDef<TextLeadingDistribution?>(
    'leadingDistribution',
    OptionalEnumCodec(TextLeadingDistribution.values),
    null,
  );

  static const List<PropDef<Object?>> all = [
    fontFamily, fontWeight, fontStyle, fontSize, color, foreground, letterSpacing, height, decoration, //
    decorationColor, decorationStyle, decorationThickness, tabularFigures, fontFeatures, leadingDistribution,
    shadows,
  ];
}

List<PropDef<Object?>> textStyleFields() => TextStyleFields.all;

abstract final class TextRunFields {
  static const start = PropDef<int>('start', Codecs.int, 0);
  static const end = PropDef<int>('end', Codecs.int, 0);
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);
  static const link = PropDef<String?>('link', Codecs.optionalString, null);
  static const List<PropDef<Object?>> all = [start, end, style, link];
}

List<PropDef<Object?>> textRunFields() => TextRunFields.all;

// --- BorderSide --------------------------------------------------------------

abstract final class BorderSideFields {
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const width = PropDef<double>('width', Codecs.positive, 1);
  static const style = PropDef<BorderStyle>('style', EnumCodec(BorderStyle.values), BorderStyle.solid);
  static const strokeAlign = PropDef<StrokeAlign>('strokeAlign', EnumCodec(StrokeAlign.values), StrokeAlign.inside);
  static const List<PropDef<Object?>> all = [color, width, style, strokeAlign];
}

List<PropDef<Object?>> borderSideFields() => BorderSideFields.all;

// --- Paint -------------------------------------------------------------------

abstract final class ColorStopFields {
  static const position = PropDef<double>('position', DoubleCodec(min: 0, max: 1), 0);
  static const color = PropDef<Color>('color', Codecs.color, Color.black);
  static const List<PropDef<Object?>> all = [position, color];
}

List<PropDef<Object?>> colorStopFields() => ColorStopFields.all;

abstract final class ImagePaintFields {
  static const url = PropDef<String?>('url', Codecs.optionalString, null);
  static const assetId = PropDef<String?>('assetId', Codecs.optionalString, null);
  static const fit = PropDef<BoxFit>('fit', EnumCodec(BoxFit.values), BoxFit.cover);
  static const alignment = PropDef<Alignment>('alignment', Codecs.alignment, Alignment.center);
  static const repeat = PropDef<ImageRepeat>('repeat', EnumCodec(ImageRepeat.values), ImageRepeat.noRepeat);
  static const scale = PropDef<double>('scale', Codecs.positive, 1);
  static const tint = PropDef<Color?>('tint', Codecs.optionalColor, null);
  static const flipX = PropDef<bool>('flipX', Codecs.bool, false);
  static const flipY = PropDef<bool>('flipY', Codecs.bool, false);
  static const saturation = PropDef<double>('saturation', Codecs.positive, 1);

  /// `[left, top, width, height]`, or null (placed by fit and alignment).
  static const rect = PropDef<List<double>?>('rect', ValueCodec(_rectIn, _same, PropType.value('Rect')), null);
  static const List<PropDef<Object?>> all = [
    url,
    assetId,
    fit,
    alignment,
    repeat,
    scale,
    tint,
    flipX,
    flipY,
    saturation,
    rect,
  ];
}

List<PropDef<Object?>> imagePaintFields() => ImagePaintFields.all;

abstract final class PaintFields {
  static const type = PropDef<PaintType>('type', EnumCodec(PaintType.values), PaintType.solid);
  static const id = PropDef<String?>('id', Codecs.optionalString, null);
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const stops = PropDef<List<ColorStop>>(
    'stops',
    ListCodec(ValueCodec(_stopIn, _out, PropType.object('ColorStop', colorStopFields))),
    [],
  );

  /// The gradient's transform, a 2D affine matrix `[a, b, c, d, tx, ty]`
  /// in the box's unit square.
  static const transform = PropDef<List<double>?>(
    'transform',
    ValueCodec(_doublesIn, _same, PropType.list(PropType.number())),
    null,
  );
  static const tileMode = PropDef<TileMode>('tileMode', EnumCodec(TileMode.values), TileMode.clamp);
  static const image = PropDef<ImagePaint?>(
    'image',
    ValueCodec(_imageIn, _out, PropType.object('ImagePaint', imagePaintFields)),
    null,
  );
  static const List<PropDef<Object?>> all = [
    type,
    id,
    visible,
    opacity,
    blendMode,
    color,
    stops,
    transform,
    tileMode,
    image,
  ];
}

List<PropDef<Object?>> paintFields() => PaintFields.all;

// --- Effect ------------------------------------------------------------------

abstract final class EffectFields {
  static const type = PropDef<EffectType>('type', EnumCodec(EffectType.values), EffectType.dropShadow);
  static const id = PropDef<String?>('id', Codecs.optionalString, null);
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  static const color = PropDef<Color>('color', Codecs.color, Color(0x40000000));
  static const offset = PropDef<Offset>('offset', Codecs.offset, Offset.zero);
  static const blurRadius = PropDef<double>('blurRadius', Codecs.positive, 0);
  static const spreadRadius = PropDef<double>('spreadRadius', Codecs.double, 0);
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  static const List<PropDef<Object?>> all = [type, id, visible, color, offset, blurRadius, spreadRadius, blendMode];
}

List<PropDef<Object?>> effectFields() => EffectFields.all;

// --- Layout ------------------------------------------------------------------

/// A node's [Layout], field by field (JSON under `layout`).
///
/// [width], [height], [constraints], [padding], [rotation] and
/// [aspectRatio] are the node's own box; [margin] is its outer spacing;
/// the rest only mean something under a given parent ([parentData]).
abstract final class LayoutFields {
  static const width = PropDef<AxisSize>('width', ValueCodec(_sizeIn, _out, axisSizeType), AxisSize.fixed(0));
  static const height = PropDef<AxisSize>('height', ValueCodec(_sizeIn, _out, axisSizeType), AxisSize.fixed(0));
  static const constraints = PropDef<BoxConstraints>('constraints', Codecs.constraints, BoxConstraints.none);
  static const margin = PropDef<EdgeInsets>('margin', Codecs.insets, EdgeInsets.zero);
  static const padding = PropDef<EdgeInsets>('padding', Codecs.insets, EdgeInsets.zero);

  /// Degrees, clockwise.
  static const rotation = PropDef<double>('rotation', Codecs.double, 0);
  static const aspectRatio = PropDef<double?>('aspectRatio', OptionalDoubleCodec(min: 0), null);

  /// Under a row/column: share of the free space (`Expanded.flex`).
  static const flex = PropDef<int>('flex', IntCodec(min: 0), 1);

  /// Under a row/column: a hugging child that may shrink (`Flexible`).
  static const squeezable = PropDef<bool>('squeezable', Codecs.bool, false);

  /// Under a freeform parent (`Positioned` / `Align`).
  static const x = PropDef<AxisPosition>('x', ValueCodec(_positionIn, _out, axisPositionType), AxisPosition.zero);
  static const y = PropDef<AxisPosition>('y', ValueCodec(_positionIn, _out, axisPositionType), AxisPosition.zero);

  /// Under a row/column: alignment in its slot (`Align`).
  static const align = PropDef<Alignment?>('align', Codecs.optionalAlignment, null);

  /// The node's own box.
  static const List<PropDef<Object?>> box = [width, height, constraints, margin, padding, rotation, aspectRatio];

  /// What a parent reads (Flutter's parent data).
  static const List<PropDef<Object?>> parentData = [flex, squeezable, x, y, align];
  static const List<PropDef<Object?>> all = [...box, ...parentData];
}

// --- Decoration --------------------------------------------------------------

/// A node's [Decoration], field by field (JSON under `decoration`).
abstract final class DecorationFields {
  static const fills = PropDef<List<Paint>>('fills', Codecs.paints, []);
  static const foregroundFills = PropDef<List<Paint>>('foregroundFills', Codecs.paints, []);
  static const strokes = PropDef<List<Paint>>('strokes', Codecs.paints, []);
  static const strokeWidth = PropDef<double>('strokeWidth', Codecs.positive, 1);
  static const strokeAlign = PropDef<StrokeAlign>('strokeAlign', EnumCodec(StrokeAlign.values), StrokeAlign.inside);
  static const strokeSides = PropDef<StrokeSides>('strokeSides', EnumCodec(StrokeSides.values), StrokeSides.all);
  static const strokeCap = PropDef<StrokeCap>('strokeCap', EnumCodec(StrokeCap.values), StrokeCap.butt);
  static const dashPattern = PropDef<List<double>>('dashPattern', ListCodec(Codecs.positive), []);
  static const radius = PropDef<BorderRadius>('radius', Codecs.radius, BorderRadius.zero);
  static const effects = PropDef<List<Effect>>('effects', Codecs.effects, []);
  static const clip = PropDef<Clip>('clip', EnumCodec(Clip.values), Clip.none);
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  static const List<PropDef<Object?>> all = [
    fills, strokes, strokeWidth, strokeAlign, strokeSides, strokeCap, dashPattern, radius, effects, clip, //
    blendMode, foregroundFills,
  ];
}

// --- Node --------------------------------------------------------------------

/// A node's own top-level fields.
abstract final class NodeFields {
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);
  static const List<PropDef<Object?>> all = [visible, opacity];
}
