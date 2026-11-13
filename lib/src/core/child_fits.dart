// Which size fits a child may take on each axis, as its parent decides.
//
// A fit can be meaningless or impossible under some parents: a list's items
// always fill across it, a grid sizes its children, nothing can fill along
// the axis a parent scrolls (it's unbounded), Flexible only means something
// on a row/column's main axis. A parent declares this on its spec
// (`WidgetSpec.childFits`); `childFitOptions` answers for any parent.
import 'layout.dart';
import 'node.dart';
import 'values/enums.dart';
import 'widgets/collections.dart';
import 'widgets/flex.dart';
import 'widgets/scroll.dart';

/// Why [fit] isn't allowed on a child of [parent] along the [horizontal]
/// axis, or null when it is.
typedef ChildFitRule = String? Function(Node parent, SizeFit fit, bool horizontal);

/// Every fit, each with the reason it isn't allowed under [parent] (null:
/// allowed). With no parent (a top-level node on the board), fixed, hug and
/// fill.
Map<SizeFit, String?> childFitOptions(Node? parent, {required bool horizontal}) {
  final rule = parent?.spec?.childFits ?? defaultChildFits;
  return {
    for (final f in SizeFit.values)
      f: parent == null ? (f == SizeFit.flexible ? _flexOnly : null) : rule(parent, f, horizontal),
  };
}

/// The fits allowed under [parent] along an axis.
List<SizeFit> allowedChildFits(Node? parent, {required bool horizontal}) => [
      for (final e in childFitOptions(parent, horizontal: horizontal).entries)
        if (e.value == null) e.key,
    ];

const _flexOnly = 'Flexible only applies in a row or column, along its main axis.';

bool _scrollsAlong(Node parent, bool horizontal) {
  if (!parent.props.get(ScrollProps.scrollable)) return false;
  return (parent.props.get(ScrollProps.scrollDirection) == Axis.horizontal) == horizontal;
}

/// Most parents (stacks, screens' slots...): no Flexible; no Fill along an
/// axis the parent scrolls.
String? defaultChildFits(Node parent, SizeFit fit, bool horizontal) => switch (fit) {
      SizeFit.flexible => _flexOnly,
      SizeFit.fill when _scrollsAlong(parent, horizontal) =>
        "The parent scrolls ${horizontal ? 'horizontally' : 'vertically'}: its content has no end to fill to.",
      _ => null,
    };

/// A row or column: Flexible along its main axis only; no Fill or Flexible
/// along the main axis when it wraps or scrolls.
String? flexChildFits(Node parent, SizeFit fit, bool horizontal) {
  final main = (flexAxisOf(parent) == Axis.horizontal) == horizontal;
  final wraps = parent.props.get(FlexProps.wrap);
  if (fit == SizeFit.flexible && !main) return _flexOnly;
  if ((fit == SizeFit.fill || fit == SizeFit.flexible) && main && wraps) {
    return 'A wrapping ${parent.type} lays its children out in runs: they keep their own size along it, unless they set '
        'layout.basis (CSS flex-basis): then a filling child grows to share its line.';
  }
  if ((fit == SizeFit.fill || fit == SizeFit.flexible) && _scrollsAlong(parent, horizontal)) {
    return 'The ${parent.type} scrolls: its content has no end to fill to.';
  }
  return null;
}

/// A list: its items fill across it; along it, they size themselves unless
/// the list gives each the same extent (then they fill it).
String? listChildFits(Node parent, SizeFit fit, bool horizontal) {
  // A wrapping list lays its items out in runs, as Wrap: each keeps its own
  // size on both axes (a filling one takes its design size).
  if (parent.props.get(ListViewProps.wrap)) return fit == SizeFit.flexible ? _flexOnly : null;
  final along = (parent.props.get(CollectionScrollProps.scrollDirection) == Axis.horizontal) == horizontal;
  final extent = parent.props.get(ListViewProps.itemExtent) != null;
  if (!along) return fit == SizeFit.fill ? null : 'Items in a list always fill across it.';
  if (extent) return fit == SizeFit.fill ? null : 'The list gives every item its item extent: they fill it.';
  return switch (fit) {
    SizeFit.fill || SizeFit.flexible => 'A list is unbounded along its scroll axis: items cannot fill it. Set an item extent.',
    _ => null,
  };
}

/// A grid or page view sizes its children: they fill their cell or page.
String? cellChildFits(Node parent, SizeFit fit, bool horizontal) =>
    fit == SizeFit.fill ? null : '${parent.type == 'pageView' ? 'Pages' : 'Grid cells'} size their children: they fill them.';
