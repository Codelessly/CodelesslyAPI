import '../props.dart';
import '../values/enums.dart';
import 'scroll.dart';

/// `Row` and `Column`: the same props, different main axis.
abstract final class FlexProps {
  static const mainAxisAlignment = PropDef<MainAxisAlignment>(
      'mainAxisAlignment', EnumCodec(MainAxisAlignment.values), MainAxisAlignment.start);
  static const crossAxisAlignment = PropDef<CrossAxisAlignment>(
      'crossAxisAlignment', EnumCodec(CrossAxisAlignment.values), CrossAxisAlignment.center);

  /// Space between children along the main axis.
  static const spacing = PropDef<double>('spacing', Codecs.positive, 0);

  /// Wraps children onto new runs when they overflow (`Wrap`).
  static const wrap = PropDef<bool>('wrap', Codecs.bool, false);

  /// Space between runs when wrapping.
  static const runSpacing = PropDef<double>('runSpacing', Codecs.positive, 0);

  static const List<PropDef<Object?>> all = [
    mainAxisAlignment,
    crossAxisAlignment,
    spacing,
    wrap,
    runSpacing,
    ...ScrollProps.all,
  ];

  static const row = WidgetSpec('row', props: all, children: ChildModel.list, decorated: true, doc: 'Flutter `Row`.');
  static const column =
      WidgetSpec('column', props: all, children: ChildModel.list, decorated: true, doc: 'Flutter `Column`.');
}
