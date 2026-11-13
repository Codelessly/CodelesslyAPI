import '../child_fits.dart';
import '../node.dart';
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

  /// Children that overflow a bounded main axis shrink to fit it (by how
  /// far each can, never below its content), as the editor lays them out;
  /// false lays them out at their own sizes and lets them run past the end,
  /// as Flutter's `Row`/`Column` does.
  static const squeezeChildren = PropDef<bool>('squeezeChildren', Codecs.bool, true);

  /// A scrolling row/column's content is at least as long as its viewport
  /// (`ConstrainedBox(minHeight: viewport)` in a `SingleChildScrollView`):
  /// alignment and expanded children use the whole viewport while it fits.
  /// Already so when it centers or spreads its children or has a flex
  /// child; this makes it so in every case.
  static const fillViewport = PropDef<bool>('fillViewport', Codecs.bool, false);

  static const List<PropDef<Object?>> all = [
    mainAxisAlignment,
    crossAxisAlignment,
    spacing,
    wrap,
    runSpacing,
    squeezeChildren,
    ...ScrollProps.all,
    fillViewport,
  ];

  /// What a row/column reads from a child: its flex share (`Expanded` /
  /// `Flexible`), whether a hugging child may shrink, its slot alignment.
  static const childFields = [LayoutFields.flex, LayoutFields.squeezable, LayoutFields.align, LayoutFields.order, LayoutFields.basis];

  /// The main axis of a `flex` node (Flutter's `Flex.direction`): a row
  /// runs [Axis.horizontal], a column [Axis.vertical]. A row is a `flex`
  /// fixed horizontal, a column one fixed vertical; a `flex` can change
  /// direction at runtime (a binding or a responsive patch) and keeps its
  /// children.
  static const direction = PropDef<Axis>('direction', EnumCodec(Axis.values), Axis.horizontal,
      doc: 'The main axis (Flutter `Flex.direction`): `horizontal` lays the children out as a row, `vertical` as a column. '
          'Bindable and patchable per breakpoint (`responsive`), so a row becomes a column without copying its children.');

  static const row = WidgetSpec('row',
      props: all, children: ChildModel.list, decorated: true, childFields: childFields, childFits: flexChildFits, doc: 'Flutter `Row`.');
  static const column = WidgetSpec('column',
      props: all, children: ChildModel.list, decorated: true, childFields: childFields, childFits: flexChildFits, doc: 'Flutter `Column`.');

  /// Flutter's `Flex`, the widget `Row` and `Column` extend: their props
  /// plus [direction].
  static const flex = WidgetSpec('flex',
      props: [direction, ...all], children: ChildModel.list, decorated: true, childFields: childFields, childFits: flexChildFits, doc: 'Flutter `Flex`.');

  /// The flex node types: `row`, `column` and `flex`.
  static const types = {'row', 'column', 'flex'};
}

/// The main axis of a row, column or flex node (a `flex` by its
/// [FlexProps.direction]); null for any other node.
Axis? flexAxisOf(Node n) => switch (n.type) {
      'row' => Axis.horizontal,
      'column' => Axis.vertical,
      'flex' => n.props.get(FlexProps.direction),
      _ => null,
    };
