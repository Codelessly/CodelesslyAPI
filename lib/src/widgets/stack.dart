import '../props.dart';
import '../value_fields.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import 'scroll.dart';

/// A freeform container: children placed by `layout.x`/`layout.y`
/// (Flutter `Stack` with `Positioned`/`Align` children).
abstract final class StackProps {
  /// Scales the whole board into the box it gets (Flutter `FittedBox`
  /// around a `Stack` of the design size): children keep their design
  /// positions and sizes and grow or shrink together, as a map, a diagram
  /// or a game board does. Null lays children out in the box as is.
  static const fit = PropDef<BoxFit?>('fit', OptionalEnumCodec(BoxFit.values), null,
      doc: 'Scale the board (its design size) into the box: contain, cover, scaleDown...');

  /// Where a [fit] board sits in its box.
  static const fitAlignment = PropDef<Alignment>('fitAlignment', Codecs.alignment, Alignment.center);

  static const spec = WidgetSpec('stack',
      props: [...ScrollProps.all, fit, fitAlignment],
      children: ChildModel.list,
      decorated: true,
      childFields: [LayoutFields.x, LayoutFields.y],
      doc: 'Flutter `Stack`.');
}

/// A leaf box: Flutter `Container` with a decoration and no child.
abstract final class BoxProps {
  /// An SVG path drawn instead of the rectangle (shapes, vectors).
  static const path = PropDef<String>('path', Codecs.string, '');

  /// How the path's segments meet when stroked (`Paint.strokeJoin`).
  static const strokeJoin = PropDef<StrokeJoin>('strokeJoin', EnumCodec(StrokeJoin.values), StrokeJoin.miter);

  /// The miter limit of [StrokeJoin.miter] corners (`Paint.strokeMiterLimit`).
  static const strokeMiterLimit = PropDef<double>('strokeMiterLimit', Codecs.positive, 4);
  static const spec =
      WidgetSpec('box', props: [path, strokeJoin, strokeMiterLimit], decorated: true, doc: 'Flutter `Container`.');
}

/// Flexible empty space in a row/column (`Spacer`), or a fixed gap.
abstract final class SpacerProps {
  static const spec = WidgetSpec('spacer', props: [], doc: 'Flutter `Spacer`.');
}
