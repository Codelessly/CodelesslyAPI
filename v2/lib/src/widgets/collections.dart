// Widget declarations: collections. One WidgetSpec per type; props with Flutter's
// names and defaults (see ../props.dart).
//
// Lists, grids and page views repeat their first child (the item template)
// once per item; tabs, accordions and expansion tiles show some of their
// children.
import '../json.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/text.dart';


Object? _colorOut(Color? c) => c?.toJson();
Object? _offsetOut(Offset? o) => o?.toJson();
Offset? _offsetIn(Object? j) => readList(j)?.length == 2 ? Offset.fromJson(j) : null;
Object? _radiusOut(BorderRadius r) => r.toJson();
Object? _jsonOut(Json j) => j;
Json? _jsonIn(Object? j) => readMap(j);
Object? _jsonListOut(List<Json> v) => v;
List<Json>? _jsonListIn(Object? j) => readList(j)?.map(readMap).nonNulls.toList();

const _optionalColor = ValueCodec<Color?>(Color.fromJson, _colorOut);
const _radius = ValueCodec<BorderRadius>(BorderRadius.fromJson, _radiusOut);
const _json = ValueCodec<Json>(_jsonIn, _jsonOut);
const _jsonList = ValueCodec<List<Json>>(_jsonListIn, _jsonListOut);
const _optionalDouble = OptionalDoubleCodec();
const _optionalPositive = OptionalDoubleCodec(min: 0);

/// How the items of a run are placed along it (Flutter's `WrapAlignment`).
enum WrapAlignment { start, end, center, spaceBetween, spaceAround, spaceEvenly }

/// How the items of a run are placed across it (`WrapCrossAlignment`).
enum WrapCrossAlignment { start, end, center }

/// What a list draws between its items.
enum ListSeparator {
  none,

  /// Empty space, [ListViewProps.spacing] long; a negative spacing overlaps
  /// the items, each drawn over the one before.
  space,

  /// A `Divider` (`VerticalDivider` in a horizontal list), the spacing long.
  divider,
}

/// How a list arranges its items.
enum ListLayout {
  /// One after another along the scroll direction.
  list,

  /// Layered in the list's padded box, each at the item's position
  /// ([ListViewProps.itemPosition], or its bound x/y). Nothing scrolls.
  stack,

  /// Layered and centred at the top, the first item on top (a card deck).
  deck,
}

/// When a view's keyboard is dismissed (`ScrollViewKeyboardDismissBehavior`).
enum KeyboardDismissBehavior { manual, onDrag }

/// The props every scrolling collection shares (`ScrollView`'s parameters).
abstract final class CollectionScrollProps {
  static const scrollDirection = PropDef<Axis>(
    'scrollDirection',
    EnumCodec(Axis.values),
    Axis.vertical,
    doc: 'The axis it scrolls along.',
  );
  static const reverse = PropDef<bool>('reverse', Codecs.bool, false);
  static const physics = PropDef<ScrollPhysicsType>(
    'physics',
    EnumCodec(ScrollPhysicsType.values),
    ScrollPhysicsType.platform,
  );

  /// Scrolls even when the content fits (`AlwaysScrollableScrollPhysics`).
  static const alwaysScroll = PropDef<bool>('alwaysScroll', Codecs.bool, true);
  static const primary = PropDef<bool>('primary', Codecs.bool, false);
  static const keyboardDismissBehavior = PropDef<KeyboardDismissBehavior>(
    'keyboardDismissBehavior',
    EnumCodec(KeyboardDismissBehavior.values),
    KeyboardDismissBehavior.manual,
  );
  static const clipBehavior = PropDef<Clip>('clipBehavior', EnumCodec(Clip.values), Clip.hardEdge);

  /// The number of items; null repeats the item without end (or one per
  /// value of the bound `data`).
  static const itemCount = PropDef<int?>('itemCount', OptionalIntCodec(), null);
  static const cacheExtent = PropDef<double?>('cacheExtent', _optionalPositive, null);

  /// Where the items come from in a running app: a cloud query
  /// (`{"collectionPath", "limit", "whereFilters", "orderByFilters",
  /// "paging", "loadRelated", "statusVariable"}`). Runtime only.
  static const query = PropDef<Json>('query', _json, {});

  static const List<PropDef<Object?>> all = [
    scrollDirection, reverse, physics, alwaysScroll, primary, keyboardDismissBehavior, clipBehavior, //
    itemCount, cacheExtent, query,
  ];
}

/// Flutter `ListView`: its first child repeated per item.
abstract final class ListViewProps {
  /// False builds every item without a viewport when the count is known
  /// and the list hugs its items (or stretches them across a cross axis it
  /// hugs).
  static const scrollable = PropDef<bool>('scrollable', Codecs.bool, true);

  /// Each item's extent along the scroll direction.
  static const itemExtent = PropDef<double?>('itemExtent', _optionalPositive, null);
  static const separator = PropDef<ListSeparator>('separator', EnumCodec(ListSeparator.values), ListSeparator.none);

  /// The separator's extent; negative overlaps the items.
  static const spacing = PropDef<double>('spacing', Codecs.double, 0);
  static const dividerThickness = PropDef<double>('dividerThickness', Codecs.positive, 1);
  static const dividerColor = PropDef<Color>('dividerColor', Codecs.color, Color.black);
  static const dividerIndent = PropDef<double>('dividerIndent', Codecs.double, 0);
  static const dividerEndIndent = PropDef<double>('dividerEndIndent', Codecs.double, 0);

  static const layout = PropDef<ListLayout>('layout', EnumCodec(ListLayout.values), ListLayout.list);

  /// Paints a layered list's items in the opposite order.
  static const reversePaintOrder = PropDef<bool>('reversePaintOrder', Codecs.bool, false);

  /// A [ListLayout.stack] list: where the item sits in the padded box when
  /// its x/y aren't bound.
  static const itemPosition = PropDef<Offset?>('itemPosition', ValueCodec(_offsetIn, _offsetOut), null);

  /// Flows the items onto further runs (`Wrap`) instead of one line.
  static const wrap = PropDef<bool>('wrap', Codecs.bool, false);
  static const wrapSpacing = PropDef<double>('wrapSpacing', Codecs.positive, 0);
  static const runSpacing = PropDef<double>('runSpacing', Codecs.positive, 0);
  static const wrapAlignment = PropDef<WrapAlignment>(
    'wrapAlignment',
    EnumCodec(WrapAlignment.values),
    WrapAlignment.start,
  );
  static const wrapCrossAlignment = PropDef<WrapCrossAlignment>(
    'wrapCrossAlignment',
    EnumCodec(WrapCrossAlignment.values),
    WrapCrossAlignment.start,
  );

  /// Every item as thick across the list as the thickest beside it.
  static const stretchItems = PropDef<bool>('stretchItems', Codecs.bool, false);

  static const spec = WidgetSpec(
    'listView',
    props: [
      ...CollectionScrollProps.all, scrollable, itemExtent, separator, spacing, dividerThickness, dividerColor, //
      dividerIndent, dividerEndIndent, layout, reversePaintOrder, itemPosition, wrap, wrapSpacing, runSpacing,
      wrapAlignment, wrapCrossAlignment, stretchItems,
    ],
    children: ChildModel.list,
    doc: 'Flutter `ListView`; the first child is the item.',
  );
}

/// Flutter `GridView` with a fixed cross-axis count
/// (`SliverGridDelegateWithFixedCrossAxisCount`) or, when
/// [maxCrossAxisExtent] is set, a maximum cell extent
/// (`SliverGridDelegateWithMaxCrossAxisExtent`).
abstract final class GridViewProps {
  static const crossAxisCount = PropDef<int>('crossAxisCount', IntCodec(min: 1), 2);
  static const maxCrossAxisExtent = PropDef<double?>('maxCrossAxisExtent', _optionalPositive, null);
  static const mainAxisSpacing = PropDef<double>('mainAxisSpacing', Codecs.double, 0);
  static const crossAxisSpacing = PropDef<double>('crossAxisSpacing', Codecs.double, 0);
  static const childAspectRatio = PropDef<double>('childAspectRatio', DoubleCodec(min: 0.0001), 1);
  static const mainAxisExtent = PropDef<double?>('mainAxisExtent', _optionalPositive, null);

  /// Each row (column, scrolling horizontally) as long as its longest item
  /// instead of a fixed extent.
  static const shrinkWrapRows = PropDef<bool>('shrinkWrapRows', Codecs.bool, false);

  static const spec = WidgetSpec(
    'gridView',
    props: [
      ...CollectionScrollProps.all, crossAxisCount, maxCrossAxisExtent, mainAxisSpacing, crossAxisSpacing, //
      childAspectRatio, mainAxisExtent, shrinkWrapRows,
    ],
    children: ChildModel.list,
    doc: 'Flutter `GridView`; the first child is the item.',
  );
}

/// Flutter `PageView`: its first child repeated per page.
abstract final class PageViewProps {
  static const pageSnapping = PropDef<bool>('pageSnapping', Codecs.bool, true);
  static const padEnds = PropDef<bool>('padEnds', Codecs.bool, true);
  static const keepPage = PropDef<bool>('keepPage', Codecs.bool, true);
  static const initialPage = PropDef<int>('initialPage', IntCodec(min: 0), 0);
  static const viewportFraction = PropDef<double>('viewportFraction', DoubleCodec(min: 0.0001), 1);
  static const allowImplicitScrolling = PropDef<bool>('allowImplicitScrolling', Codecs.bool, false);

  /// How long a change of the bound page index animates, in ms (0 jumps).
  static const animationDuration = PropDef<int>('animationDuration', IntCodec(min: 0), 0);

  /// The curve of that animation, by `Curves` name.
  static const animationCurve = PropDef<String>('animationCurve', Codecs.string, 'easeOutCubic');

  static const spec = WidgetSpec(
    'pageView',
    props: [
      CollectionScrollProps.scrollDirection, CollectionScrollProps.reverse, CollectionScrollProps.physics, //
      CollectionScrollProps.alwaysScroll, CollectionScrollProps.clipBehavior, CollectionScrollProps.itemCount,
      pageSnapping, padEnds, keepPage, initialPage, viewportFraction, allowImplicitScrolling, animationDuration,
      animationCurve,
    ],
    children: ChildModel.list,
    doc: 'Flutter `PageView`; the first child is the page.',
  );
}

/// A `TabBar` over the selected child: one tab per child, titled by
/// [titles].
abstract final class TabsProps {
  static const titles = PropDef<List<String>>('titles', ListCodec(Codecs.string), []);
  static const initialIndex = PropDef<int>('initialIndex', IntCodec(min: 0), 0);
  static const spec = WidgetSpec(
    'tabs',
    props: [titles, initialIndex],
    children: ChildModel.list,
    doc: 'Tabs: a `TabBar` over its selected child.',
  );
}

/// What a tab shows.
enum TabContent { label, icon, labelAndIcon }

/// How the selected tab is marked.
enum TabIndicatorStyle { underline, filled, border, none }

/// Flutter's `TabBarIndicatorSize`.
enum TabBarIndicatorSize { tab, label }

/// Flutter's `TabAlignment`.
enum TabAlignment { start, startOffset, fill, center }

/// Flutter `TabBar` (labels only; no pages).
abstract final class TabBarProps {
  /// `[{"id", "label", "icon"?}]`; `icon` as IconProps.icon.
  static const tabs = PropDef<List<Json>>('tabs', _jsonList, []);
  static const initialIndex = PropDef<int>('initialIndex', IntCodec(min: 0), 0);
  static const isScrollable = PropDef<bool>('isScrollable', Codecs.bool, false);
  static const physics = PropDef<ScrollPhysicsType>(
    'physics',
    EnumCodec(ScrollPhysicsType.values),
    ScrollPhysicsType.platform,
  );
  static const indicatorColor = PropDef<Color>('indicatorColor', Codecs.color, Color.black);
  static const indicatorWeight = PropDef<double>('indicatorWeight', Codecs.positive, 2);
  static const indicatorSize = PropDef<TabBarIndicatorSize>(
    'indicatorSize',
    EnumCodec(TabBarIndicatorSize.values),
    TabBarIndicatorSize.label,
  );
  static const indicatorPadding = PropDef<EdgeInsets>('indicatorPadding', Codecs.insets, EdgeInsets.zero);
  static const indicatorStyle = PropDef<TabIndicatorStyle>(
    'indicatorStyle',
    EnumCodec(TabIndicatorStyle.values),
    TabIndicatorStyle.underline,
  );

  /// The indicator's shape for the filled and border styles:
  /// `roundedRectangle`, `stadium`, `circle`, `beveledRectangle`,
  /// `continuousRectangle`.
  static const indicatorShape = PropDef<String>('indicatorShape', Codecs.string, 'roundedRectangle');
  static const indicatorRadius = PropDef<BorderRadius>('indicatorRadius', _radius, BorderRadius.zero);
  static const labelColor = PropDef<Color?>('labelColor', _optionalColor, Color.black);
  static const unselectedLabelColor = PropDef<Color?>('unselectedLabelColor', _optionalColor, Color.black);
  static const labelStyle = PropDef<TextStyle>('labelStyle', Codecs.textStyle, TextStyle.empty);
  static const unselectedLabelStyle = PropDef<TextStyle>('unselectedLabelStyle', Codecs.textStyle, TextStyle.empty);
  static const labelPadding = PropDef<EdgeInsets>('labelPadding', Codecs.insets, EdgeInsets.zero);
  static const overlayColor = PropDef<Color?>('overlayColor', _optionalColor, null);
  static const dividerColor = PropDef<Color?>('dividerColor', _optionalColor, Color.black);
  static const dividerHeight = PropDef<double?>('dividerHeight', _optionalDouble, null);
  static const tabAlignment = PropDef<TabAlignment?>('tabAlignment', _OptionalEnumCodec(TabAlignment.values), null);
  static const content = PropDef<TabContent>('content', EnumCodec(TabContent.values), TabContent.labelAndIcon);

  /// How a tab's icon and label are laid out: side by side (horizontal) or
  /// the icon above (vertical).
  static const iconDirection = PropDef<Axis>('iconDirection', EnumCodec(Axis.values), Axis.horizontal);

  /// The gap between a tab's icon and label.
  static const gap = PropDef<double>('gap', Codecs.positive, 10);

  static const spec = WidgetSpec(
    'tabBar',
    props: [
      tabs, initialIndex, isScrollable, physics, indicatorColor, indicatorWeight, indicatorSize, //
      indicatorPadding, indicatorStyle, indicatorShape, indicatorRadius, labelColor, unselectedLabelColor,
      labelStyle, unselectedLabelStyle, labelPadding, overlayColor, dividerColor, dividerHeight, tabAlignment,
      content, iconDirection, gap,
    ],
    doc: 'Flutter `TabBar`.',
  );
}

final class _OptionalEnumCodec<T extends Enum> extends PropCodec<T?> {
  const _OptionalEnumCodec(this.values);
  final List<T> values;
  @override
  T? decode(Object? json) {
    for (final v in values) {
      if (v.name == json) return v;
    }
    return null;
  }

  @override
  Object? encode(T? value) => value?.name;
}

/// An accordion: its first child is the header (with a toggle button over
/// its end), its second the content shown while [expanded].
abstract final class AccordionProps {
  static const expanded = PropDef<bool>('expanded', Codecs.bool, true);
  static const mainAxisAlignment = PropDef<MainAxisAlignment>(
    'mainAxisAlignment',
    EnumCodec(MainAxisAlignment.values),
    MainAxisAlignment.start,
  );
  static const crossAxisAlignment = PropDef<CrossAxisAlignment>(
    'crossAxisAlignment',
    EnumCodec(CrossAxisAlignment.values),
    CrossAxisAlignment.center,
  );
  static const spec = WidgetSpec(
    'accordion',
    props: [expanded, mainAxisAlignment, crossAxisAlignment],
    children: ChildModel.list,
    doc: 'Accordion: a header and collapsible content.',
  );
}

/// Which side of a tile its control sits on (`ListTileControlAffinity`).
enum ListTileControlAffinity { leading, trailing, platform }

/// Flutter `ExpansionTile`. The `tile` slot is a list tile whose `leading`,
/// `title`, `subtitle` and `trailing` slots make the header; the children
/// are shown while expanded.
abstract final class ExpansionTileProps {
  static const initiallyExpanded = PropDef<bool>('initiallyExpanded', Codecs.bool, false);
  static const maintainState = PropDef<bool>('maintainState', Codecs.bool, false);
  static const backgroundColor = PropDef<Color?>('backgroundColor', _optionalColor, null);
  static const collapsedBackgroundColor = PropDef<Color?>('collapsedBackgroundColor', _optionalColor, null);
  static const tilePadding = PropDef<EdgeInsets?>('tilePadding', ValueCodec(_insetsIn, _insetsOut), null);
  static const childrenPadding = PropDef<EdgeInsets?>('childrenPadding', ValueCodec(_insetsIn, _insetsOut), null);
  static const expandedAlignment = PropDef<Alignment?>(
    'expandedAlignment',
    ValueCodec(Alignment.fromJson, _alignOut),
    null,
  );
  static const expandedCrossAxisAlignment = PropDef<CrossAxisAlignment?>(
    'expandedCrossAxisAlignment',
    _OptionalEnumCodec(CrossAxisAlignment.values),
    null,
  );
  static const iconColor = PropDef<Color?>('iconColor', _optionalColor, null);
  static const collapsedIconColor = PropDef<Color?>('collapsedIconColor', _optionalColor, null);
  static const textColor = PropDef<Color?>('textColor', _optionalColor, null);
  static const collapsedTextColor = PropDef<Color?>('collapsedTextColor', _optionalColor, null);
  static const controlAffinity = PropDef<ListTileControlAffinity?>(
    'controlAffinity',
    _OptionalEnumCodec(ListTileControlAffinity.values),
    null,
  );

  /// `[horizontal, vertical]` (`VisualDensity`).
  static const visualDensity = PropDef<Offset?>('visualDensity', ValueCodec(_offsetIn, _offsetOut), null);
  static const showDividers = PropDef<bool>('showDividers', Codecs.bool, true);
  static const showTrailingIcon = PropDef<bool>('showTrailingIcon', Codecs.bool, true);

  /// Expanded and collapsed outline shapes (as [TabBarProps.indicatorShape]),
  /// rounded by [radius].
  static const shape = PropDef<String?>('shape', _OptionalStringCodec(), null);
  static const collapsedShape = PropDef<String?>('collapsedShape', _OptionalStringCodec(), null);
  static const radius = PropDef<BorderRadius>('radius', _radius, BorderRadius.zero);

  static const spec = WidgetSpec(
    'expansionTile',
    props: [
      initiallyExpanded, maintainState, backgroundColor, collapsedBackgroundColor, tilePadding, childrenPadding, //
      expandedAlignment, expandedCrossAxisAlignment, iconColor, collapsedIconColor, textColor, collapsedTextColor,
      controlAffinity, visualDensity, showDividers, showTrailingIcon, shape, collapsedShape, radius,
    ],
    children: ChildModel.list,
    slots: ['tile'],
    doc: 'Flutter `ExpansionTile`.',
  );
}

EdgeInsets? _insetsIn(Object? j) => j == null ? null : EdgeInsets.fromJson(j);
Object? _insetsOut(EdgeInsets? e) => e?.toJson();
Object? _alignOut(Alignment? a) => a?.toJson();

final class _OptionalStringCodec extends PropCodec<String?> {
  const _OptionalStringCodec();
  @override
  String? decode(Object? json) => json is String ? json : null;
  @override
  Object? encode(String? value) => value;
}

const List<WidgetSpec> collectionsSpecs = [
  ListViewProps.spec,
  GridViewProps.spec,
  PageViewProps.spec,
  TabsProps.spec,
  TabBarProps.spec,
  AccordionProps.spec,
  ExpansionTileProps.spec,
];
