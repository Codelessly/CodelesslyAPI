// Widget declarations: collections. One WidgetSpec per type; props with Flutter's
// names and defaults (see ../props.dart).
//
// Lists, grids and page views repeat their first child (the item template)
// once per item; tabs, accordions and expansion tiles show some of their
// children.
import '../behavior_fields.dart';
import '../behaviors.dart';
import '../json.dart';
import '../child_fits.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/enums.dart';
import '../values/geometry.dart';
import '../values/text.dart';
import 'collections_models.dart';

export 'collections_models.dart';



const _optionalColor = Codecs.optionalColor;
const _radius = Codecs.radius;
const _json = Codecs.json;
const _jsonList = Codecs.jsonList;
const _optionalDouble = Codecs.optionalDouble;
const _optionalPositive = Codecs.optionalPositive;

/// How the items of a run are placed along it (Flutter's `WrapAlignment`).
enum WrapAlignment { start, end, center, spaceBetween, spaceAround, spaceEvenly }

/// How the items of a run are placed across it (`WrapCrossAlignment`).
enum WrapCrossAlignment { start, end, center }

/// What a list draws between its items.
enum ListSeparator {
  /// Nothing: the items touch whatever [ListViewProps.spacing] says.
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

  /// Layered and centered at the top, the first item on top (a card deck).
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
  /// What goes between the items: space by default, so [spacing] alone
  /// spaces them like a column's spacing (`ListView.separated` with a
  /// `SizedBox`).
  static const separator = PropDef<ListSeparator>('separator', EnumCodec(ListSeparator.values), ListSeparator.space);

  /// The room between the items along the list (the separator's extent);
  /// negative overlaps the items.
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
  static const itemPosition = PropDef<Offset?>('itemPosition', Codecs.optionalOffset, null);

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

  /// Loads the items page by page, with pull to refresh (its footers are
  /// the `loading`, `error` and `end` slots).
  static const pagination = PropDef<Pagination?>('pagination', CollectionCodecs.pagination, null);

  /// Lets the user drag the items to a new place.
  static const reorder = PropDef<ListReorder?>('reorder', CollectionCodecs.reorder, null);

  /// Groups the items under headers (the `sectionHeader` slot).
  static const sections = PropDef<ListSections?>('sections', CollectionCodecs.sections, null);

  /// Actions revealed behind a swiped item.
  static const swipeActions = PropDef<SwipeActions?>('swipeActions', CollectionCodecs.swipeActions, null);

  static const spec = WidgetSpec(
    'listView',
    props: [
      ...CollectionScrollProps.all, scrollable, itemExtent, separator, spacing, dividerThickness, dividerColor, //
      dividerIndent, dividerEndIndent, layout, reversePaintOrder, itemPosition, wrap, wrapSpacing, runSpacing,
      wrapAlignment, wrapCrossAlignment, stretchItems, pagination, reorder, sections, swipeActions,
    ],
    children: ChildModel.list,
    slots: CollectionSlots.list,
    childFits: listChildFits,
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

  /// Natural-height items in independent lanes, cycling in reading order.
  static const masonry = PropDef<bool>('masonry', Codecs.bool, false);

  /// Loads the items page by page (see [ListViewProps.pagination]).
  static const pagination = ListViewProps.pagination;

  /// Lets the user drag the items to a new place.
  static const reorder = ListViewProps.reorder;

  static const spec = WidgetSpec(
    'gridView',
    props: [
      ...CollectionScrollProps.all, crossAxisCount, maxCrossAxisExtent, mainAxisSpacing, crossAxisSpacing, //
      childAspectRatio, mainAxisExtent, shrinkWrapRows, masonry, pagination, reorder,
    ],
    slots: CollectionSlots.grid,
    children: ChildModel.list,
    childFits: cellChildFits,
    doc: 'Flutter `GridView`; the first child is the item.',
  );
}

Object? _motionOut(Motion? m) => m?.toJson();

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

  /// A 3D look for the pages as they scroll (coverflow, cube, carousel):
  /// the motion a page has one page after the current one. The current page
  /// is at rest, pages between are interpolated by their distance (clamped
  /// to two pages) and pages before are mirrored (`translateX`, `shiftX`,
  /// `rotate`, `rotateY`, `originX` change sign). Null: flat pages.
  static const pageMotion =
      PropDef<Motion?>('pageMotion', ValueCodec(Motion.fromJson, _motionOut, motionType), null);

  static const spec = WidgetSpec(
    'pageView',
    props: [
      CollectionScrollProps.scrollDirection, CollectionScrollProps.reverse, CollectionScrollProps.physics, //
      CollectionScrollProps.alwaysScroll, CollectionScrollProps.clipBehavior, CollectionScrollProps.itemCount,
      pageSnapping, padEnds, keepPage, initialPage, viewportFraction, allowImplicitScrolling, animationDuration,
      animationCurve, pageMotion,
    ],
    children: ChildModel.list,
    childFits: cellChildFits,
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
  static const tabAlignment = PropDef<TabAlignment?>('tabAlignment', OptionalEnumCodec(TabAlignment.values), null);
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
  static const tilePadding = PropDef<EdgeInsets?>('tilePadding', Codecs.optionalInsets, null);
  static const childrenPadding = PropDef<EdgeInsets?>('childrenPadding', Codecs.optionalInsets, null);
  static const expandedAlignment = PropDef<Alignment?>(
    'expandedAlignment',
    Codecs.optionalAlignment,
    null,
  );
  static const expandedCrossAxisAlignment = PropDef<CrossAxisAlignment?>(
    'expandedCrossAxisAlignment',
    OptionalEnumCodec(CrossAxisAlignment.values),
    null,
  );
  static const iconColor = PropDef<Color?>('iconColor', _optionalColor, null);
  static const collapsedIconColor = PropDef<Color?>('collapsedIconColor', _optionalColor, null);
  static const textColor = PropDef<Color?>('textColor', _optionalColor, null);
  static const collapsedTextColor = PropDef<Color?>('collapsedTextColor', _optionalColor, null);
  static const controlAffinity = PropDef<ListTileControlAffinity?>(
    'controlAffinity',
    OptionalEnumCodec(ListTileControlAffinity.values),
    null,
  );

  /// `[horizontal, vertical]` (`VisualDensity`).
  static const visualDensity = PropDef<Offset?>('visualDensity', Codecs.optionalOffset, null);
  static const showDividers = PropDef<bool>('showDividers', Codecs.bool, true);
  static const showTrailingIcon = PropDef<bool>('showTrailingIcon', Codecs.bool, true);

  /// Expanded and collapsed outline shapes (as [TabBarProps.indicatorShape]),
  /// rounded by [radius].
  static const shape = PropDef<String?>('shape', Codecs.optionalString, null);
  static const collapsedShape = PropDef<String?>('collapsedShape', Codecs.optionalString, null);
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



/// Page controls for a list's pagination (found by its name,
/// [controller]): first, previous, page numbers with ellipses
/// (1 … 4 5 6 … 16), next, last, a page size select and a summary. Choosing
/// a page fires the node's `changed` reactions with the page as `${result}`.
abstract final class PaginationProps {
  /// The `Pagination.name` of the list this shows and moves (an expression).
  static const controller = PropDef<String>('controller', Codecs.string, '');
  static const showFirstLast = PropDef<bool>('showFirstLast', Codecs.bool, true);
  static const showPrevNext = PropDef<bool>('showPrevNext', Codecs.bool, true);
  static const showPageNumbers = PropDef<bool>('showPageNumbers', Codecs.bool, true);

  /// Page numbers on each side of the current one before an ellipsis.
  static const siblingCount = PropDef<int>('siblingCount', IntCodec(min: 0), 1);

  /// Page numbers always shown at each end.
  static const boundaryCount = PropDef<int>('boundaryCount', IntCodec(min: 0), 1);

  /// A page size select, offering the pagination's `pageSizeOptions`.
  static const showPageSize = PropDef<bool>('showPageSize', Codecs.bool, false);
  static const showSummary = PropDef<bool>('showSummary', Codecs.bool, true);

  /// `{from}`, `{to}`, `{total}`, `{page}`, `{pageCount}` are replaced; an
  /// unknown total shows as "many".
  static const summaryText = PropDef<String>('summaryText', Codecs.string, 'Showing {from}–{to} of {total}');
  static const pageSizeLabel = PropDef<String>('pageSizeLabel', Codecs.string, 'Rows per page');
  static const firstLabel = PropDef<String>('firstLabel', Codecs.string, '«');
  static const previousLabel = PropDef<String>('previousLabel', Codecs.string, '‹');
  static const nextLabel = PropDef<String>('nextLabel', Codecs.string, '›');
  static const lastLabel = PropDef<String>('lastLabel', Codecs.string, '»');

  /// How the parts are placed along the node (as a `Wrap`'s alignment).
  static const alignment = PropDef<WrapAlignment>('alignment', EnumCodec(WrapAlignment.values), WrapAlignment.spaceBetween);
  static const fontSize = PropDef<double>('fontSize', DoubleCodec(min: 1), 14);
  static const fontWeight = PropDef<int>('fontWeight', IntCodec(min: 100), 400);
  static const textColor = PropDef<Color>('textColor', Codecs.color, Color(0xFF333842));
  static const buttonColor = PropDef<Color?>('buttonColor', _optionalColor, null);
  static const activeColor = PropDef<Color>('activeColor', Codecs.color, Color(0xFF2663EA));
  static const activeTextColor = PropDef<Color>('activeTextColor', Codecs.color, Color.white);
  /// A button's outline; transparent for none.
  static const borderColor = PropDef<Color>('borderColor', Codecs.color, Color(0xFFD8DDE5));
  static const borderWidth = PropDef<double>('borderWidth', Codecs.positive, 1);
  static const cornerRadius = PropDef<double>('cornerRadius', Codecs.positive, 6);

  /// The least width and height of a button.
  static const buttonSize = PropDef<double>('buttonSize', Codecs.positive, 32);
  static const spacing = PropDef<double>('spacing', Codecs.positive, 4);

  /// A button that can't be pressed (previous on page 1).
  static const disabledOpacity = PropDef<double>('disabledOpacity', DoubleCodec(min: 0, max: 1), 0.4);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  static const spec = WidgetSpec(
    'pagination',
    props: [
      controller, showFirstLast, showPrevNext, showPageNumbers, siblingCount, boundaryCount, showPageSize, //
      showSummary, summaryText, pageSizeLabel, firstLabel, previousLabel, nextLabel, lastLabel, alignment, fontSize,
      fontWeight, textColor, buttonColor, activeColor, activeTextColor, borderColor, borderWidth, cornerRadius,
      buttonSize, spacing, disabledOpacity, enabled,
    ],
    doc: 'Page controls for a list\'s pagination.',
  );

  /// The page numbers to show for [page] of [pageCount], null where an
  /// ellipsis goes: page 5 of 16 with one sibling and one boundary page is
  /// `[1, null, 4, 5, 6, null, 16]`. An ellipsis never stands for one page.
  static List<int?> pageItems({required int page, required int pageCount, int siblingCount = 1, int boundaryCount = 1}) {
    if (pageCount <= 0) return const [];
    final current = page.clamp(1, pageCount);
    final shown = <int>{
      for (var i = 1; i <= boundaryCount && i <= pageCount; i++) i,
      for (var i = pageCount - boundaryCount + 1; i <= pageCount; i++)
        if (i >= 1) i,
      for (var i = current - siblingCount; i <= current + siblingCount; i++)
        if (i >= 1 && i <= pageCount) i,
    };
    final result = <int?>[];
    for (final number in shown.toList()..sort()) {
      if (result.isNotEmpty) {
        final previous = result.last!;
        if (number - previous == 2) {
          result.add(previous + 1);
        } else if (number - previous > 2) {
          result.add(null);
        }
      }
      result.add(number);
    }
    return result;
  }
}

/// Flutter's `TableView` (two_dimensional_scrollables): a table that
/// scrolls on both axes, with a header row and column that stay pinned.
/// Rows are the bound `data` (or [rowCount]); columns are [columns] (or
/// bound `props.columns`). Its slots are templates built per cell with
/// `${item}`: `cell` (`{value, row, column, rowIndex, columnIndex}`),
/// `columnHeader` (`{label, column, columnIndex}`), `rowHeader` (`{row,
/// rowIndex}`) and `corner`.
abstract final class TableViewProps {
  static const columns = PropDef<List<TableColumn>>('columns', ListCodec<TableColumn>(tableColumnCodec), []);

  /// The rows when no data is bound.
  static const rowCount = PropDef<int?>('rowCount', OptionalIntCodec(), null);
  static const rowHeight = PropDef<double>('rowHeight', Codecs.positive, 40);
  static const headerHeight = PropDef<double>('headerHeight', Codecs.positive, 44);

  /// A column's width unless it sets its own.
  static const columnWidth = PropDef<double>('columnWidth', Codecs.positive, 120);
  static const rowHeaderWidth = PropDef<double>('rowHeaderWidth', Codecs.positive, 120);
  static const pinHeaderRow = PropDef<bool>('pinHeaderRow', Codecs.bool, true);
  static const pinHeaderColumn = PropDef<bool>('pinHeaderColumn', Codecs.bool, true);

  /// The lines between cells; transparent for none.
  static const gridLineColor = PropDef<Color>('gridLineColor', Codecs.color, Color(0xFFE0E2E8));
  static const gridLineWidth = PropDef<double>('gridLineWidth', Codecs.positive, 1);

  /// Every other body row's background.
  static const stripeColor = PropDef<Color?>('stripeColor', _optionalColor, null);

  /// The header row's and column's background.
  static const headerColor = PropDef<Color?>('headerColor', _optionalColor, null);
  static const cacheExtent = PropDef<double?>('cacheExtent', _optionalPositive, null);
  static const clipBehavior = PropDef<Clip>('clipBehavior', EnumCodec(Clip.values), Clip.hardEdge);

  static const cell = 'cell', columnHeader = 'columnHeader', rowHeader = 'rowHeader', corner = 'corner';

  static const spec = WidgetSpec(
    'tableView',
    props: [
      columns, rowCount, rowHeight, headerHeight, columnWidth, rowHeaderWidth, pinHeaderRow, pinHeaderColumn, //
      gridLineColor, gridLineWidth, stripeColor, headerColor, cacheExtent, clipBehavior,
    ],
    children: ChildModel.slots,
    slots: [cell, columnHeader, rowHeader, corner],
    doc: 'Flutter `TableView`; its slots are the cell templates.',
  );
}

const List<WidgetSpec> collectionsSpecs = [
  ListViewProps.spec,
  GridViewProps.spec,
  PageViewProps.spec,
  TabsProps.spec,
  TabBarProps.spec,
  AccordionProps.spec,
  ExpansionTileProps.spec,
  PaginationProps.spec,
  TableViewProps.spec,
];
