// Widget declarations: media (vector paths, video, audio, web views) and
// slots filled by the app (placeholders, external components). One
// WidgetSpec per type; props with Flutter's names and defaults (see
// ../props.dart).
import '../json.dart';
import '../props.dart';
import '../values/enums.dart';

/// A size `[width, height]`, or null.
List<double>? _sizeIn(Object? j) {
  final l = readList(j)?.map(readDouble).toList();
  if (l == null || l.length != 2 || l.any((v) => v == null || v < 0)) return null;
  return l.cast<double>();
}

Object? _sizeOut(List<double>? s) => s?.map(writeDouble).toList();

/// `[width, height]` (a view box, a maximum size).
const _size = ValueCodec<List<double>?>(_sizeIn, _sizeOut, PropType.value('Size'));
const _strings = Codecs.strings;

/// An SVG path, filled and stroked with the node's decoration
/// (Flutter `CustomPaint`).
abstract final class PathProps {
  /// SVG path data (`M0 0 L10 10 Z`).
  static const data = PropDef<String>('data', Codecs.string, '');

  /// The coordinate space of [data], `[width, height]`, scaled to the box.
  /// Null: [data] is in the box's own pixels.
  static const viewBox = PropDef<List<double>?>('viewBox', _size, null);

  /// Whether the stroke (its width and dash lengths) is in [viewBox] units,
  /// scaled with the drawing as in SVG, instead of the box's pixels (an
  /// icon's line keeps its weight at any size; a diagram's grows with it).
  static const scaleStroke = PropDef<bool>('scaleStroke', Codecs.bool, false);

  /// The stroked part of the path, as fractions of its length.
  static const trimStart = PropDef<double>('trimStart', DoubleCodec(min: 0, max: 1), 0);
  static const trimEnd = PropDef<double>('trimEnd', DoubleCodec(min: 0, max: 1), 1);

  /// How segments meet when stroked (`Paint.strokeJoin`).
  static const strokeJoin = PropDef<StrokeJoin>('strokeJoin', EnumCodec(StrokeJoin.values), StrokeJoin.miter);

  /// The miter limit of [StrokeJoin.miter] corners (`Paint.strokeMiterLimit`).
  static const strokeMiterLimit = PropDef<double>('strokeMiterLimit', Codecs.positive, 4);

  static const spec = WidgetSpec('path',
      props: [data, viewBox, scaleStroke, trimStart, trimEnd, strokeJoin, strokeMiterLimit],
      decorated: true,
      doc: 'Flutter `CustomPaint` of an SVG path.');
}

/// A widget the app builds (`Codelessly`'s external component builders).
abstract final class ExternalProps {
  /// The id of the app's builder.
  static const builderId = PropDef<String>('builderId', Codecs.string, '');
  static const spec = WidgetSpec('external', props: [builderId], doc: 'A widget built by the app.');
}

/// An empty slot shown at design time (Flutter `SizedBox`).
abstract final class PlaceholderProps {
  static const text = PropDef<String>('text', Codecs.string, '');
  static const leadingAsset = PropDef<String>('leadingAsset', Codecs.string, '');
  static const spec = WidgetSpec('placeholder', props: [text, leadingAsset], doc: 'An empty slot (`SizedBox`).');
}

/// A slot that shows its one child, or keeps its size when empty.
abstract final class SinglePlaceholderProps {
  /// The node types the slot accepts (empty: any) and refuses.
  static const allowedTypes = PropDef<List<String>>('allowedTypes', _strings, []);
  static const deniedTypes = PropDef<List<String>>('deniedTypes', _strings, []);

  /// The largest child it accepts, `[width, height]`.
  static const maxAllowedSize = PropDef<List<double>?>('maxAllowedSize', _size, null);

  /// Its child is temporary (not kept when the slot is filled again).
  static const ephemeral = PropDef<bool>('ephemeral', Codecs.bool, false);

  static const spec = WidgetSpec('singlePlaceholder',
      props: [allowedTypes, deniedTypes, maxAllowedSize, ephemeral],
      children: ChildModel.list,
      doc: 'A one-child slot.');
}

/// The core's media-like types: vector paths and slots the app fills.
const List<WidgetSpec> pathAndSlotSpecs = [
  PathProps.spec,
  ExternalProps.spec,
  PlaceholderProps.spec,
  SinglePlaceholderProps.spec,
];
