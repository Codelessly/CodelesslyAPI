import '../props.dart';
import 'scroll.dart';

/// A freeform container: children placed by `layout.x`/`layout.y`
/// (Flutter `Stack` with `Positioned`/`Align` children).
abstract final class StackProps {
  static const spec = WidgetSpec('stack',
      props: ScrollProps.all, children: ChildModel.list, decorated: true, doc: 'Flutter `Stack`.');
}

/// A leaf box: Flutter `Container` with a decoration and no child.
abstract final class BoxProps {
  /// An SVG path drawn instead of the rectangle (shapes, vectors).
  static const path = PropDef<String>('path', Codecs.string, '');
  static const spec = WidgetSpec('box', props: [path], decorated: true, doc: 'Flutter `Container`.');
}

/// Flexible empty space in a row/column (`Spacer`), or a fixed gap.
abstract final class SpacerProps {
  static const spec = WidgetSpec('spacer', props: [], doc: 'Flutter `Spacer`.');
}
