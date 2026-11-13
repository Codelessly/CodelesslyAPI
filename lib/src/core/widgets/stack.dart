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
  static const spec = WidgetSpec('box', props: [], decorated: true, doc: 'Flutter `Container`.');
}

/// Flexible empty space in a row/column (`Spacer`), or a fixed gap. With no
/// size along its parent's main axis it is Flutter's `Spacer()`: it takes the
/// free space by its `layout.flex`; a fixed size there makes it a gap.
abstract final class SpacerProps {
  static const spec = WidgetSpec('spacer', props: [], doc: 'Flutter `Spacer`.');
}
