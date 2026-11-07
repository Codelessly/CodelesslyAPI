import '../json.dart';
import '../props.dart';
import '../value_fields.dart';

/// How a screen fits the device.
enum ScaleMode { responsive, autoScale }


/// A screen (`Scaffold`): its `body` slot is the page content.
abstract final class CanvasProps {
  static const scaleMode = PropDef<ScaleMode>('scaleMode', EnumCodec(ScaleMode.values), ScaleMode.responsive);

  /// While true, going back (the system or browser back button, a back
  /// gesture) keeps the user on this screen and runs its `backPressed`
  /// reactions instead. Usually bound (`${= dirty}`). A navigate pop from
  /// the screen's own actions is never blocked.
  static const blockBack = PropDef<bool>('blockBack', Codecs.bool, false);
  static const spec = WidgetSpec('canvas',
      props: [scaleMode, blockBack], children: ChildModel.slots, slots: ['body', 'appBar', 'floatingActionButton', 'bottomNavigationBar'],
      decorated: true, doc: 'Flutter `Scaffold`.');
}

/// Shows one of several variants of its content (by id, or by breakpoint).
abstract final class VarianceProps {
  /// `[{"id", "name", "children": [ids], "breakpoint"?, "overrides"?}]`.
  static const variants = PropDef<List<Json>>('variants', Codecs.jsonList, []);
  static const current = PropDef<String>('current', Codecs.string, '');
  static const spec = WidgetSpec('variance',
      props: [variants, current],
      children: ChildModel.list,
      decorated: true,
      childFields: [LayoutFields.x, LayoutFields.y],
      doc: 'Variant switcher.');
}
