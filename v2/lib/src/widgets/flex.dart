import '../child_fits.dart';
import '../props.dart';
import '../value_fields.dart';
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

  /// What a row/column reads from a child: its flex share (`Expanded` /
  /// `Flexible`), whether a hugging child may shrink, its slot alignment.
  static const childFields = [LayoutFields.flex, LayoutFields.squeezable, LayoutFields.align];

  static const row = WidgetSpec('row',
      props: all, children: ChildModel.list, decorated: true, childFields: childFields, childFits: flexChildFits, doc: 'Flutter `Row`.');
  static const column = WidgetSpec('column',
      props: all, children: ChildModel.list, decorated: true, childFields: childFields, childFits: flexChildFits, doc: 'Flutter `Column`.');
}
