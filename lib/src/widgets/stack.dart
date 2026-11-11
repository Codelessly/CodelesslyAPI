import '../props.dart';
import '../value_fields.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import 'scroll.dart';

/// A freeform container: children placed by `layout.x`/`layout.y`
/// (Flutter `Stack` with `Positioned`/`Align` children).
abstract final class StackProps {
  /// Scales the children, laid out at the stack's design size, into the
  /// stack's box (Flutter `FittedBox`): `cover` fills it and crops,
  /// `contain` letterboxes. `none` lays them out in the box itself.
  static const contentFit = PropDef<BoxFit>('contentFit', EnumCodec(BoxFit.values), BoxFit.none,
      doc: 'Scales the content, designed at the stack\'s design size, into its box (FittedBox).');

  /// Where scaled content sits in the box (`FittedBox.alignment`).
  static const contentAlignment = PropDef<Alignment>('contentAlignment', Codecs.alignment, Alignment.center);

  static const spec = WidgetSpec('stack',
      props: [...ScrollProps.all, contentFit, contentAlignment],
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
