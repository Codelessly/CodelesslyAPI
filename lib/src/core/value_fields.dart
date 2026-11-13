// The fields of the core value types and of a node's layout and
// decoration, declared as PropDefs: each key is the value's JSON key (and
// Flutter's name), with its codec and default. With the widgets' own props
// they describe everything a node holds, so a properties panel, docs or
// codegen read one kind of declaration for all of it (see PropType).
//
// The models keep their own fromJson/toJson; test/document/declared_fields_test.dart
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
  /// The font family (`"Inter"`); `fontWeight` picks its file. Without one: the platform's default (Roboto).
  static const fontFamily = PropDef<String?>('fontFamily', Codecs.optionalString, null);

  /// Flutter's `FontWeight`: 100–900, in hundreds.
  static const fontWeight = PropDef<int?>('fontWeight', FontWeightCodec(), null);
  /// `normal` or `italic`.
  static const fontStyle = PropDef<FontStyle?>('fontStyle', OptionalEnumCodec(FontStyle.values), null);
  /// The font size in logical pixels. Without one: 12.
  static const fontSize = PropDef<double?>('fontSize', Codecs.optionalPositive, null);
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const foreground = PropDef<Paint?>('foreground', Codecs.paint, null);
  static const letterSpacing = PropDef<double?>('letterSpacing', Codecs.optionalDouble, null);

  /// Line height, as a multiple of the font size (Flutter's `height`).
  static const height = PropDef<double?>('height', Codecs.optionalPositive, null,
      doc: 'Line height as a multiple of the font size. Unset: the inherited defaultTextStyle\'s, else the font\'s own '
          '(Flutter\'s height: null, CSS line-height: normal).');
  /// A line through the text: `underline`, `overline`, `lineThrough` or `none`.
  static const decoration = PropDef<TextDecoration?>('decoration', OptionalEnumCodec(TextDecoration.values), null);
  /// The colour of the `decoration` line; without one, the text's colour.
  static const decorationColor = PropDef<Color?>('decorationColor', Codecs.optionalColor, null);

  /// Painted behind the glyphs.
  static const backgroundColor = PropDef<Color?>('backgroundColor', Codecs.optionalColor, null);
  /// The `decoration` line's style: `solid`, `double`, `dotted`, `dashed`, `wavy`.
  static const decorationStyle = PropDef<TextDecorationStyle?>(
    'decorationStyle',
    OptionalEnumCodec(TextDecorationStyle.values),
    null,
  );
  /// The `decoration` line's thickness, as a multiple of the font's default.
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

  /// The project's named text style this one starts from.
  static const from = PropDef<String?>('from', Codecs.optionalString, null,
      doc: 'The name of one of the project\'s text styles (the site manifest\'s `theme.textStyles`) this style starts from, '
          'as `Theme.of(context).textTheme.titleLarge.merge(...)`: the fields written here change it. '
          '`"style": "title"` is short for `{"from": "title"}`.');

  static const List<PropDef<Object?>> all = [
    from, fontFamily, fontWeight, fontStyle, fontSize, color, foreground, letterSpacing, height, decoration, //
    decorationColor, backgroundColor, decorationStyle, decorationThickness, tabularFigures, fontFeatures, leadingDistribution,
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
  /// The line's colour.
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  /// The line's width in pixels.
  static const width = PropDef<double>('width', Codecs.positive, 1);
  /// `solid` or `none`.
  static const style = PropDef<BorderStyle>('style', EnumCodec(BorderStyle.values), BorderStyle.solid);
  /// Where the line sits on the edge: inside, centered on it, or outside.
  static const strokeAlign = PropDef<StrokeAlign>('strokeAlign', EnumCodec(StrokeAlign.values), StrokeAlign.inside);
  static const List<PropDef<Object?>> all = [color, width, style, strokeAlign];
}

List<PropDef<Object?>> borderSideFields() => BorderSideFields.all;

// --- Paint -------------------------------------------------------------------

abstract final class ColorStopFields {
  /// Where the colour sits along the gradient, 0 (its start) to 1 (its end).
  static const position = PropDef<double>('position', DoubleCodec(min: 0, max: 1), 0);
  /// The colour at `position`.
  static const color = PropDef<Color>('color', Codecs.color, Color.black);
  static const List<PropDef<Object?>> all = [position, color];
}

List<PropDef<Object?>> colorStopFields() => ColorStopFields.all;

abstract final class ImagePaintFields {
  /// The image's URL: `https://`, a `data:image/...` URL, or (for the render command's drafts) a path relative to
  /// the document.
  static const url = PropDef<String?>('url', Codecs.optionalString, null);
  /// A project asset's id, for images uploaded to the project.
  static const assetId = PropDef<String?>('assetId', Codecs.optionalString, null);
  /// How the image fills the box (Flutter's `BoxFit`): `cover`, `contain`, `fill`, `fitWidth`...
  static const fit = PropDef<BoxFit>('fit', EnumCodec(BoxFit.values), BoxFit.cover);
  /// Where the image sits in the box when it does not fill it, or which part shows when it is cropped.
  static const alignment = PropDef<Alignment>('alignment', Codecs.alignment, Alignment.center);
  /// Whether the image repeats to fill the box (Flutter's `ImageRepeat`).
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
  /// What the paint is: `solid` (a colour), `linear`, `radial`, `sweep` or `diamond` (a gradient of `stops`),
  /// `image`, or `noise`. Without one: an image if it has `image`, a linear gradient if it has `stops`, else solid.
  static const type = PropDef<PaintType>('type', EnumCodec(PaintType.values), PaintType.solid);
  static const id = PropDef<String?>('id', Codecs.optionalString, null);
  /// False keeps the paint but does not draw it.
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  /// The paint's opacity, 0 to 1, multiplied with its colours' own alpha.
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);
  /// How the paint blends with what is under it (CSS `mix-blend-mode`).
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const stops = PropDef<List<ColorStop>>(
    'stops',
    ListCodec(ValueCodec(_stopIn, _out, PropType.object('ColorStop', colorStopFields))),
    [],
  );

  /// The gradient's transform: `[a, b, tx, c, d, ty]` maps a point (x, y)
  /// of the box, in its unit square (0..1 each way), to the gradient's
  /// unit square: u = a·x + b·y + tx, v = c·x + d·y + ty.
  static const transform = PropDef<List<double>?>(
    'transform',
    ValueCodec(_doublesIn, _same, PropType.list(PropType.number())),
    null,
    doc: 'Six numbers `[a, b, tx, c, d, ty]` mapping a point (x, y) of the box, in its unit square (0 to 1 each way), into the '
        'gradient\'s unit square: u = a·x + b·y + tx, v = c·x + d·y + ty. A linear gradient runs along u from 0 to 1; '
        '`[20, 0, 0, 0, 1, 0]` with `"tileMode": "repeated"` repeats it 20 times across the box. '
        'Simpler: `begin`/`end` (linear) or `center`/`radius` (radial).',
  );

  /// A linear gradient's start (Flutter `LinearGradient.begin`).
  static const begin = PropDef<Alignment?>('begin', Codecs.optionalAlignment, null,
      doc: 'Linear: where the gradient starts, an alignment (`[-1, 0]` or `"centerLeft"`, Flutter `LinearGradient.begin`). '
          'Read into `transform`; default the left edge.');

  /// A linear gradient's end (Flutter `LinearGradient.end`).
  static const end = PropDef<Alignment?>('end', Codecs.optionalAlignment, null,
      doc: 'Linear: where the gradient ends (Flutter `LinearGradient.end`). `"begin": [0, -1], "end": [0, 1]` runs top to bottom; '
          '`"begin": [-1, 0], "end": [-0.9, 0]` with `"tileMode": "repeated"` repeats it every 5% of the width.');

  /// A radial gradient's center (Flutter `RadialGradient.center`).
  static const center = PropDef<Alignment?>('center', Codecs.optionalAlignment, null,
      doc: 'Radial: its center, an alignment (`[0, -1]`: the middle of the top edge; Flutter `RadialGradient.center`). '
          'Read into `transform`; default the box\'s center.');
  /// What a gradient does past `begin` and `end`: `clamp` (keeps the end colours), `repeated`, `mirror`, `decal`.
  static const tileMode = PropDef<TileMode>('tileMode', EnumCodec(TileMode.values), TileMode.clamp);
  static const image = PropDef<ImagePaint?>(
    'image',
    ValueCodec(_imageIn, _out, PropType.object('ImagePaint', imagePaintFields)),
    null,
  );
  /// A radial gradient's radius as a share of the box's shortest side.
  static const radius = PropDef<double?>('radius', Codecs.optionalPositive, null,
      doc: "Radial: the radius as a share of the box's shortest side (Flutter's RadialGradient); null: half the box's width "
          "(as the transform maps it). Past the last stop the gradient keeps the last stop's color (`tileMode` clamp): "
          'end a glow on a transparent stop, or it fills the rest of the box.');
  /// A gradient's length in pixels (CSS `repeating-linear-gradient(..., 80px)`).
  static const length = PropDef<double?>('length', Codecs.optionalPositive, null,
      doc: 'A gradient\'s length in logical pixels, whatever the box\'s size: linear, from `begin` toward `end` (only their '
          'direction counts then); radial, its radius. With `"tileMode": "repeated"` the stops repeat every `length` px: '
          'CSS `repeating-linear-gradient(to bottom, #1F2937 0 1px, transparent 1px 80px)` is '
          '`{"type": "linear", "begin": "topCenter", "end": "bottomCenter", "length": 80, "tileMode": "repeated", "stops": '
          '[{"position": 0, "color": "#FF1F2937"}, {"position": 0.0125, "color": "#FF1F2937"}, {"position": 0.0125, "color": "#00000000"}, '
          '{"position": 1, "color": "#00000000"}]}`: a 1 px line every 80 px (a background grid is two such paints).');

  /// A `noise` paint's noise (SVG `feTurbulence`).
  static const noise = PropDef<NoisePaint?>(
    'noise',
    ValueCodec(_noiseIn, _out, PropType.object('NoisePaint', noisePaintFields)),
    null,
    doc: 'Type `noise`: procedural grain, as SVG `<feTurbulence>`: `{"baseFrequency": 0.8, "numOctaves": 3, "seed": 0, '
        '"type": "fractalNoise"}`. With `color` the grain is that color, its alpha the noise; without, the four noise '
        'channels feTurbulence gives. Fade it with `opacity` (a film grain: 0.05 to 0.12) and set a `blendMode` '
        '(`overlay`, `softLight`) as CSS `mix-blend-mode`. Drawn as a seamless 256 px tile repeated over the box.',
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
    begin,
    end,
    center,
    tileMode,
    image,
    radius,
    length,
    noise,
  ];
}

NoisePaint? _noiseIn(Object? j) => NoisePaint.fromJson(j);

List<PropDef<Object?>> noisePaintFields() => NoisePaintFields.all;

/// [NoisePaint]: SVG `feTurbulence`'s attributes.
abstract final class NoisePaintFields {
  static const baseFrequency = PropDef<double>('baseFrequency', DoubleCodec(min: 0, max: 4), 0.8,
      doc: 'Lattice cells per pixel (feTurbulence `baseFrequency`): 0.8 a fine grain, 0.05 soft clouds.');
  static const numOctaves = PropDef<int>('numOctaves', IntCodec(min: 1), 3,
      doc: 'Octaves summed, each twice the frequency at half the amplitude.');
  static const seed = PropDef<int>('seed', Codecs.int, 0, doc: 'The random seed: the same seed draws the same grain.');
  static const type = PropDef<NoiseType>('type', EnumCodec(NoiseType.values), NoiseType.fractalNoise,
      doc: '`fractalNoise` (a soft grain) or `turbulence` (ridged).');
  static const List<PropDef<Object?>> all = [baseFrequency, numOctaves, seed, type];
}

List<PropDef<Object?>> paintFields() => PaintFields.all;

// --- Effect ------------------------------------------------------------------

abstract final class EffectFields {
  /// The effect: `dropShadow`, `innerShadow`, `layerBlur` (blurs the node) or `backgroundBlur` (blurs what is
  /// behind it: frosted glass). Required: an effect without a type is dropped.
  static const type = PropDef<EffectType>('type', EnumCodec(EffectType.values), EffectType.dropShadow);
  /// An id a binding can select the effect by (`decoration.effects.glow.color`).
  static const id = PropDef<String?>('id', Codecs.optionalString, null);
  /// False keeps the effect but does not draw it.
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  /// The shadow's colour.
  static const color = PropDef<Color>('color', Codecs.color, Color(0x40000000));
  /// The shadow's offset `[dx, dy]` in pixels.
  static const offset = PropDef<Offset>('offset', Codecs.offset, Offset.zero);
  /// How soft the shadow or blur is, in pixels.
  static const blurRadius = PropDef<double>('blurRadius', Codecs.positive, 0);
  /// How far the shadow grows past the box before blurring, in pixels.
  static const spreadRadius = PropDef<double>('spreadRadius', Codecs.double, 0);
  /// How the effect blends with what is under it.
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);

  /// A rectangle (rounded by radius) or a circle (BoxShape.circle).
  static const shape = PropDef<DecorationShape>('shape', EnumCodec(DecorationShape.values), DecorationShape.rectangle);
  static const List<PropDef<Object?>> all = [type, id, visible, color, offset, blurRadius, spreadRadius, blendMode];
}

List<PropDef<Object?>> effectFields() => EffectFields.all;

// --- Layout ------------------------------------------------------------------

/// A node's [Layout], field by field (JSON under `layout`).
///
/// [width], [height], [constraints], [padding] and [aspectRatio] are the
/// node's own box; [margin] is its outer spacing;
/// the rest only mean something under a given parent ([parentData]).
abstract final class LayoutFields {
  /// The node's width: a number (fixed), `{"hug": n}` (its content), `{"fill": n}` (the room its parent gives) or
  /// `{"flexible": n}` (up to n). n is the design size. Without one the node is 0 wide.
  static const width = PropDef<AxisSize>('width', ValueCodec(_sizeIn, _out, axisSizeType), AxisSize.fixed(0));
  /// The node's height: a number (fixed), `{"hug": n}`, `{"fill": n}` or `{"flexible": n}`, as `width`. Without one
  /// the node is 0 high.
  static const height = PropDef<AxisSize>('height', ValueCodec(_sizeIn, _out, axisSizeType), AxisSize.fixed(0));
  /// `{"minWidth", "maxWidth", "minHeight", "maxHeight"}`: limits on the size, whatever the mode (Flutter's
  /// `ConstrainedBox`). A fill width with `maxWidth` grows with its parent up to the cap.
  static const constraints = PropDef<BoxConstraints>('constraints', Codecs.constraints, BoxConstraints.none);
  static const margin = PropDef<EdgeInsets>('margin', Codecs.insets, EdgeInsets.zero);
  static const padding = PropDef<EdgeInsets>('padding', Codecs.insets, EdgeInsets.zero);

  static const aspectRatio = PropDef<double?>('aspectRatio', OptionalDoubleCodec(min: 0, ratio: true), null);

  /// Under a row/column: share of the free space (`Expanded.flex`).
  static const flex = PropDef<int>('flex', IntCodec(min: 0), 1);

  /// Under a row/column: a hugging child that may shrink (`Flexible`).
  static const squeezable = PropDef<bool>('squeezable', Codecs.bool, false);

  /// Under a freeform parent (`Positioned` / `Align`).
  static const x = PropDef<AxisPosition>('x', ValueCodec(_positionIn, _out, axisPositionType), AxisPosition.zero);
  static const y = PropDef<AxisPosition>('y', ValueCodec(_positionIn, _out, axisPositionType), AxisPosition.zero);

  /// Under a row/column: alignment in its slot (`Align`).
  static const align = PropDef<Alignment?>('align', Codecs.optionalAlignment, null);

  /// Under a row, column or flex: CSS `order`, the position it is laid out
  /// and painted at (ascending; equal orders keep the children's order).
  static const order = PropDef<int>('order', IntCodec(), 0,
      doc: 'CSS `order`: under a row, column or flex, children are laid out and painted by ascending order (equal orders as listed). '
          'Patch it per screen size (`media`) to reorder at a width.');

  /// Under a wrapping row, column or flex: CSS `flex-basis`.
  static const basis = PropDef<double?>('basis', OptionalDoubleCodec(min: 0), null,
      doc: 'CSS `flex-basis`, under a wrapping row, column or flex: the main size the child counts when lines are broken; '
          'a child that fills the main axis (`{"fill": n}`) then grows by its `flex` share of the room left on its line '
          '(`flex: 1 1 280px`). Cards with `basis: 280` sit three across at 900 px, two at 600, one at 390, with no breakpoints.');

  /// The node's own box.
  static const List<PropDef<Object?>> box = [width, height, constraints, margin, padding, aspectRatio];

  /// What a parent reads (Flutter's parent data).
  static const List<PropDef<Object?>> parentData = [flex, squeezable, x, y, align, order, basis];
  static const List<PropDef<Object?>> all = [...box, ...parentData];
}

// --- Decoration --------------------------------------------------------------

/// A node's [Decoration], field by field (JSON under `decoration`).
abstract final class DecorationFields {
  /// Paints for the box, bottom to top: a colour, a gradient, an image or noise.
  static const fills = PropDef<List<Paint>>('fills', Codecs.paints, []);
  static const foregroundFills = PropDef<List<Paint>>('foregroundFills', Codecs.paints, []);
  /// Paints for the border, drawn `strokeWidth` wide.
  static const strokes = PropDef<List<Paint>>('strokes', Codecs.paints, []);
  /// The border's width in pixels. Without `strokes` it draws nothing.
  static const strokeWidth = PropDef<double>('strokeWidth', Codecs.positive, 1);
  /// Where the border sits on the box's edge: `inside`, `center` or `outside`.
  static const strokeAlign = PropDef<StrokeAlign>('strokeAlign', EnumCodec(StrokeAlign.values), StrokeAlign.inside);
  /// Which sides the border is drawn on: `all`, `top`, `bottom`, `left`, `right`, `topBottom`, `leftRight`...
  static const strokeSides = PropDef<StrokeSides>('strokeSides', EnumCodec(StrokeSides.values), StrokeSides.all);
  /// The ends of a dashed border's dashes.
  static const strokeCap = PropDef<StrokeCap>('strokeCap', EnumCodec(StrokeCap.values), StrokeCap.butt);
  static const dashPattern = PropDef<List<double>>('dashPattern', ListCodec(Codecs.positive), []);
  /// The corners' radius: a number, `[x, y]`, or `[topLeft, topRight, bottomRight, bottomLeft]`.
  static const radius = PropDef<BorderRadius>('radius', Codecs.radius, BorderRadius.zero);
  /// Shadows and blurs: each `{"type": "dropShadow" | "innerShadow" | "layerBlur" | "backgroundBlur", ...}`.
  static const effects = PropDef<List<Effect>>('effects', Codecs.effects, []);
  static const clip = PropDef<Clip>('clip', EnumCodec(Clip.values), Clip.none);
  /// How the node's paint blends with what is under it (CSS `mix-blend-mode`).
  static const blendMode = PropDef<BlendMode>('blendMode', EnumCodec(BlendMode.values), BlendMode.srcOver);
  /// A rectangle (rounded by radius) or a circle (BoxShape.circle).
  static const shape = PropDef<DecorationShape>('shape', EnumCodec(DecorationShape.values), DecorationShape.rectangle);
  static const List<PropDef<Object?>> all = [
    fills, strokes, strokeWidth, strokeAlign, strokeSides, strokeCap, dashPattern, radius, effects, clip, //
    blendMode, foregroundFills, shape,
  ];
}

// --- Node --------------------------------------------------------------------

/// A node's own top-level fields.
abstract final class NodeFields {
  /// False hides the node. Hidden by a binding, a condition or a media rule it takes no room; written `false` with
  /// nothing to show it, it keeps its room empty.
  static const visible = PropDef<bool>('visible', Codecs.bool, true);
  /// The node's opacity, 0 to 1, with its children (Flutter's `Opacity`).
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);
  static const List<PropDef<Object?>> all = [visible, opacity];
}
