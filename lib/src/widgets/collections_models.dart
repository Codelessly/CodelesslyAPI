// Value types of the collections: a list's or grid's pagination, item
// reordering, sections and swipe actions. Each is a record of declared
// fields (decoding total, encoding sparse, equality by value), as the
// inputs' value types are. The nodes they show (a pagination's loading,
// error and end footers, a section header, a reorder placeholder) are the
// list's slots, not ids in these records.
import '../json.dart';
import '../props.dart';
import '../values/color.dart';
import '../values/geometry.dart' show BorderRadius;
import '../values/text.dart';
import 'inputs_models.dart' show FieldValue;

Object? _valueOut(FieldValue? v) => v?.toJson();

/// Codecs for the collections' value types.
abstract final class CollectionCodecs {
  static const pagination =
      ValueCodec<Pagination?>(Pagination.fromJson, _valueOut, PropType.record('Pagination', PaginationFields.spec));
  static const reorder =
      ValueCodec<ListReorder?>(ListReorder.fromJson, _valueOut, PropType.record('ListReorder', ListReorderFields.spec));
  static const sections =
      ValueCodec<ListSections?>(ListSections.fromJson, _valueOut, PropType.record('ListSections', ListSectionsFields.spec));
  static const swipeActions = ValueCodec<SwipeActions?>(
      SwipeActions.fromJson, _valueOut, PropType.record('SwipeActions', SwipeActionsFields.spec));
  static const swipeAction =
      ValueCodec<SwipeAction?>(SwipeAction.fromJson, _valueOut, PropType.record('SwipeAction', SwipeActionFields.spec));
}

/// The slots a list or grid takes besides its item template.
abstract final class CollectionSlots {
  /// Shown at the end while the next page loads.
  static const loading = 'loading';

  /// Shown at the end when a page failed to load (with a retry).
  static const error = 'error';

  /// Shown at the end once every page has loaded.
  static const end = 'end';

  /// Built for each section ([ListSections]), with `${item}` the section's
  /// `{key, count, index}`.
  static const sectionHeader = 'sectionHeader';

  /// Drawn where a dragged item would land ([ReorderPlaceholder.node]).
  static const reorderPlaceholder = 'reorderPlaceholder';

  static const list = [loading, error, end, sectionHeader, reorderPlaceholder];
  static const grid = [loading, error, end, reorderPlaceholder];
}

// --- Pagination ----------------------------------------------------------------

/// Where a pagination reads its items from.
enum PaginationSource {
  /// The list's bound data, shown a page at a time.
  data,

  /// The list's cloud query, loaded page by page.
  cloud,

  /// An API call ([Pagination.apiId]) that returns one page per call; its
  /// parameters read `${page.page}`, `${page.offset}`, `${page.cursor}`,
  /// `${page.pageSize}`.
  api,
}

/// How a page is asked for.
enum PaginationStrategy {
  /// By the index of its first item (`${page.offset}`).
  offset,

  /// By its number (`${page.page}`, from 1).
  page,

  /// By the cursor the previous page returned ([Pagination.cursorPath]).
  cursor,
}

/// How a list shows the pages.
enum PaginationMode {
  /// One page at a time, moved by a pagination node or Paginate actions.
  pages,

  /// Every loaded page; the next loads near the end (infinite scroll).
  infinite,

  /// Like [infinite], and earlier pages load near the start.
  bidirectional,
}

/// A pagination controller: loads a list's items page by page and exposes
/// its state as a map variable named [name] (`${name.items}`,
/// `${name.page}`, `${name.pageCount}`, `${name.hasMore}`,
/// `${name.isLoadingMore}`, `${name.error}`...). Paginate actions move it.
final class Pagination extends FieldValue {
  const Pagination._(super.fields);

  factory Pagination({required String name, PaginationMode mode = PaginationMode.infinite}) =>
      Pagination._(Props.empty.set(PaginationFields.name, name).set(PaginationFields.mode, mode));

  static Pagination? fromJson(Object? json) =>
      readMap(json) == null ? null : Pagination._(Props.fromJson(PaginationFields.spec, json));

  @override
  WidgetSpec get spec => PaginationFields.spec;

  Pagination set<T>(PropDef<T> field, T value) => Pagination._(fields.set(field, value));

  String get name => get(PaginationFields.name);
  PaginationMode get mode => get(PaginationFields.mode);
  PaginationSource get source => get(PaginationFields.source);
  int get pageSize => get(PaginationFields.pageSize);
  List<int> get pageSizeOptions => get(PaginationFields.pageSizeOptions);

  /// A cloud source always pages by cursor.
  PaginationStrategy get strategy =>
      source == PaginationSource.cloud ? PaginationStrategy.cursor : get(PaginationFields.strategy);
  String get keyPath => get(PaginationFields.keyPath);
  int get initialPage => get(PaginationFields.initialPage);
  int get thresholdItems => get(PaginationFields.thresholdItems);
  double get thresholdPixels => get(PaginationFields.thresholdPixels);
  bool get cachePages => get(PaginationFields.cachePages);
  String? get apiId => get(PaginationFields.apiId);
  Json get parameters => get(PaginationFields.parameters);
  String get itemsPath => get(PaginationFields.itemsPath);
  String get totalPath => get(PaginationFields.totalPath);
  String get cursorPath => get(PaginationFields.cursorPath);
  bool get pullToRefresh => get(PaginationFields.pullToRefresh);
  Color? get refreshColor => get(PaginationFields.refreshColor);
  Color? get refreshBackgroundColor => get(PaginationFields.refreshBackgroundColor);
  double get refreshDisplacement => get(PaginationFields.refreshDisplacement);
}

abstract final class PaginationFields {
  /// The map variable that holds the state, unique on its page.
  static const name = PropDef<String>('name', Codecs.string, '');
  static const mode = PropDef<PaginationMode>('mode', EnumCodec(PaginationMode.values), PaginationMode.infinite);
  static const source = PropDef<PaginationSource>('source', EnumCodec(PaginationSource.values), PaginationSource.data);
  static const pageSize = PropDef<int>('pageSize', IntCodec(min: 1), 20);

  /// The page sizes a pagination node offers; empty offers none.
  static const pageSizeOptions = PropDef<List<int>>('pageSizeOptions', ListCodec(IntCodec(min: 1)), [10, 20, 50, 100]);
  static const strategy =
      PropDef<PaginationStrategy>('strategy', EnumCodec(PaginationStrategy.values), PaginationStrategy.offset);

  /// The path in an item of the value that identifies it; items with the
  /// same value show once. Empty keeps every item.
  static const keyPath = PropDef<String>('keyPath', Codecs.string, 'id');

  /// The page shown first, from 1.
  static const initialPage = PropDef<int>('initialPage', IntCodec(min: 1), 1);

  /// How many items from the end (or start) the next page starts loading.
  static const thresholdItems = PropDef<int>('thresholdItems', IntCodec(min: 0), 5);

  /// The same in pixels of scroll left; 0 uses [thresholdItems] alone.
  static const thresholdPixels = PropDef<double>('thresholdPixels', Codecs.positive, 0);

  /// Loaded pages are kept to show again until a refresh.
  static const cachePages = PropDef<bool>('cachePages', Codecs.bool, true);

  /// The API ([PaginationSource.api]).
  static const apiId = PropDef<String?>('apiId', Codecs.optionalString, null);

  /// The API call's parameters (`${page.page}`...).
  static const parameters = PropDef<Json>('parameters', Codecs.json, {});

  /// Where in an API response the page's items, the total count and the next
  /// cursor are (empty: the response itself, unknown, none).
  static const itemsPath = PropDef<String>('itemsPath', Codecs.string, '');
  static const totalPath = PropDef<String>('totalPath', Codecs.string, '');
  static const cursorPath = PropDef<String>('cursorPath', Codecs.string, '');

  /// Pull to refresh (`RefreshIndicator`): the list's `refresh` reactions.
  static const pullToRefresh = PropDef<bool>('pullToRefresh', Codecs.bool, false);
  static const refreshColor = PropDef<Color?>('refreshColor', Codecs.optionalColor, null);
  static const refreshBackgroundColor = PropDef<Color?>('refreshBackgroundColor', Codecs.optionalColor, null);
  static const refreshDisplacement = PropDef<double>('refreshDisplacement', Codecs.positive, 40);

  static const spec = WidgetSpec('Pagination', props: [
    name, mode, source, pageSize, pageSizeOptions, strategy, keyPath, initialPage, thresholdItems, //
    thresholdPixels, cachePages, apiId, parameters, itemsPath, totalPath, cursorPath, pullToRefresh, refreshColor,
    refreshBackgroundColor, refreshDisplacement,
  ], doc: 'A list\'s pagination controller.');
}

// --- Reorder -------------------------------------------------------------------

/// How a drag of a list item to a new place starts.
enum ReorderStart {
  /// From a node in the item whose drag reorders (a handle).
  handle,

  /// A long press anywhere on the item.
  longPress,

  /// Any press and drag on the item.
  press,
}

/// What a reorder (or a swipe action that removes the item) changes on its
/// own, before the list's reactions run.
enum ListApply {
  /// Nothing: the reactions store the change.
  none,

  /// The list variable bound to the list's data.
  variable,

  /// The documents of the list's cloud query.
  cloud,
}

/// What shows where a dragged item would land.
enum ReorderPlaceholder {
  /// An empty space the size of the item.
  gap,

  /// The list's `reorderPlaceholder` slot, at the size of the item.
  node,
}

/// Dragging a list's items to a new place, within the list and, with a
/// [group], into other lists of the group (a Kanban board). A drop runs the
/// list's `reorder` reactions with `${result.from}`, `${result.to}`,
/// `${result.item}`, `${result.fromList}` and `${result.toList}`.
final class ListReorder extends FieldValue {
  const ListReorder._(super.fields);

  static const ListReorder standard = ListReorder._(Props.empty);

  static ListReorder? fromJson(Object? json) =>
      readMap(json) == null ? null : ListReorder._(Props.fromJson(ListReorderFields.spec, json));

  @override
  WidgetSpec get spec => ListReorderFields.spec;

  ListReorder set<T>(PropDef<T> field, T value) => ListReorder._(fields.set(field, value));

  bool get enabled => get(ListReorderFields.enabled);
  ReorderStart get start => get(ListReorderFields.start);
  String get group => get(ListReorderFields.group);
  String get listKey => get(ListReorderFields.listKey);
  String get canReorderIf => get(ListReorderFields.canReorderIf);
  String get canDropIf => get(ListReorderFields.canDropIf);
  double get proxyElevation => get(ListReorderFields.proxyElevation);
  double get proxyScale => get(ListReorderFields.proxyScale);
  double get proxyOpacity => get(ListReorderFields.proxyOpacity);
  ReorderPlaceholder get placeholder => get(ListReorderFields.placeholder);
  bool get autoScroll => get(ListReorderFields.autoScroll);
  double get autoScrollEdge => get(ListReorderFields.autoScrollEdge);
  bool get keyboard => get(ListReorderFields.keyboard);
  ListApply get apply => get(ListReorderFields.apply);
  String get orderField => get(ListReorderFields.orderField);
  String get listField => get(ListReorderFields.listField);
}

abstract final class ListReorderFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const start = PropDef<ReorderStart>('start', EnumCodec(ReorderStart.values), ReorderStart.handle);

  /// Lists of one group take each other's items; empty: within this list.
  static const group = PropDef<String>('group', Codecs.string, '');

  /// This list in `${result.fromList}` / `${result.toList}` (an
  /// expression); empty: the list's id.
  static const listKey = PropDef<String>('listKey', Codecs.string, '');

  /// Must hold for an item (`${item}`, `${index}`) to be picked up.
  static const canReorderIf = PropDef<String>('canReorderIf', Codecs.string, '');

  /// Must hold for a drop (`${result}` as the drop would be).
  static const canDropIf = PropDef<String>('canDropIf', Codecs.string, '');
  static const proxyElevation = PropDef<double>('proxyElevation', Codecs.positive, 6);
  static const proxyScale = PropDef<double>('proxyScale', Codecs.positive, 1);
  static const proxyOpacity = PropDef<double>('proxyOpacity', DoubleCodec(min: 0, max: 1), 1);
  static const placeholder =
      PropDef<ReorderPlaceholder>('placeholder', EnumCodec(ReorderPlaceholder.values), ReorderPlaceholder.gap);
  static const autoScroll = PropDef<bool>('autoScroll', Codecs.bool, true);
  static const autoScrollEdge = PropDef<double>('autoScrollEdge', Codecs.positive, 48);

  /// A focused item moves with Alt and the arrow keys, and is announced.
  static const keyboard = PropDef<bool>('keyboard', Codecs.bool, true);
  static const apply = PropDef<ListApply>('apply', EnumCodec(ListApply.values), ListApply.none);

  /// The numeric field of a document's position ([ListApply.cloud]).
  static const orderField = PropDef<String>('orderField', Codecs.string, 'order');

  /// The field of the list a document is in, for moves between lists.
  static const listField = PropDef<String>('listField', Codecs.string, '');

  static const spec = WidgetSpec('ListReorder', props: [
    enabled, start, group, listKey, canReorderIf, canDropIf, proxyElevation, proxyScale, proxyOpacity, placeholder, //
    autoScroll, autoScrollEdge, keyboard, apply, orderField, listField,
  ], doc: 'Reordering a list\'s items by dragging (`ReorderableListView`).');
}

// --- Sections ------------------------------------------------------------------

/// Groups a data list's consecutive items with the same [groupBy] value into
/// sections, each under the list's `sectionHeader` slot.
final class ListSections extends FieldValue {
  const ListSections._(super.fields);

  static ListSections? fromJson(Object? json) =>
      readMap(json) == null ? null : ListSections._(Props.fromJson(ListSectionsFields.spec, json));

  @override
  WidgetSpec get spec => ListSectionsFields.spec;

  ListSections set<T>(PropDef<T> field, T value) => ListSections._(fields.set(field, value));

  String get groupBy => get(ListSectionsFields.groupBy);
  bool get sticky => get(ListSectionsFields.sticky);
  bool get indexBar => get(ListSectionsFields.indexBar);
  List<String> get indexKeys => get(ListSectionsFields.indexKeys);
  TextStyle get indexStyle => get(ListSectionsFields.indexStyle);
  Color? get indexActiveColor => get(ListSectionsFields.indexActiveColor);
  Color? get indexMutedColor => get(ListSectionsFields.indexMutedColor);
  double get indexWidth => get(ListSectionsFields.indexWidth);
  bool get indexBubble => get(ListSectionsFields.indexBubble);
  Color? get indexBubbleColor => get(ListSectionsFields.indexBubbleColor);
  TextStyle get indexBubbleStyle => get(ListSectionsFields.indexBubbleStyle);
}

abstract final class ListSectionsFields {
  /// A path in the item (`group`, `date.day`) or an expression.
  static const groupBy = PropDef<String>('groupBy', Codecs.string, '');

  /// The current section's header stays pinned until the next pushes it out.
  static const sticky = PropDef<bool>('sticky', Codecs.bool, true);

  /// An index of the sections' keys along the list's edge (A–Z).
  static const indexBar = PropDef<bool>('indexBar', Codecs.bool, false);

  /// The keys the index shows, in order (`A`…`Z`); empty shows the
  /// sections'. A key no item has is drawn in [indexMutedColor] and does
  /// nothing. With a data-paged list the keys of every item count, and
  /// picking one loads pages until its section is in.
  static const indexKeys = PropDef<List<String>>('indexKeys', Codecs.strings, []);

  /// The index's text (font, size, weight, color).
  static const indexStyle = PropDef<TextStyle>('indexStyle', Codecs.textStyle, TextStyle.empty);

  /// A key while it is touched.
  static const indexActiveColor = PropDef<Color?>('indexActiveColor', Codecs.optionalColor, null);

  /// A key no item has.
  static const indexMutedColor = PropDef<Color?>('indexMutedColor', Codecs.optionalColor, null);
  static const indexWidth = PropDef<double>('indexWidth', Codecs.positive, 20);

  /// The touched key pops up large beside the index while it is dragged.
  static const indexBubble = PropDef<bool>('indexBubble', Codecs.bool, false);
  static const indexBubbleColor = PropDef<Color?>('indexBubbleColor', Codecs.optionalColor, null);
  static const indexBubbleStyle = PropDef<TextStyle>('indexBubbleStyle', Codecs.textStyle, TextStyle.empty);

  static const spec = WidgetSpec('ListSections', props: [
    groupBy, sticky, indexBar, indexKeys, indexStyle, indexActiveColor, indexMutedColor, indexWidth, indexBubble, //
    indexBubbleColor, indexBubbleStyle,
  ], doc: 'A list\'s items under section headers.');
}

// --- Swipe actions ---------------------------------------------------------------

/// One action revealed behind a list item as it is swiped.
final class SwipeAction extends FieldValue {
  const SwipeAction._(super.fields);

  factory SwipeAction({required String id, String label = '', bool removes = true}) => SwipeAction._(Props.empty
      .set(SwipeActionFields.id, id)
      .set(SwipeActionFields.label, label)
      .set(SwipeActionFields.removes, removes));

  static SwipeAction? fromJson(Object? json) =>
      readMap(json) == null ? null : SwipeAction._(Props.fromJson(SwipeActionFields.spec, json));

  @override
  WidgetSpec get spec => SwipeActionFields.spec;

  String get id => get(SwipeActionFields.id);
  String get label => get(SwipeActionFields.label);
  Json? get icon => get(SwipeActionFields.icon);
  Color get background => get(SwipeActionFields.background);
  Color get foreground => get(SwipeActionFields.foreground);
  bool get removes => get(SwipeActionFields.removes);
  String get when => get(SwipeActionFields.when);
  TextStyle get labelStyle => get(SwipeActionFields.labelStyle);
  double get iconSize => get(SwipeActionFields.iconSize);
  bool get inline => get(SwipeActionFields.inline);
}

abstract final class SwipeActionFields {
  /// The action in `${result.action}`.
  static const id = PropDef<String>('id', Codecs.string, '');
  static const label = PropDef<String>('label', Codecs.string, '');
  static const icon = PropDef<Json?>('icon', Codecs.optionalIcon, null);
  static const background = PropDef<Color>('background', Codecs.color, Color(0xFFDB2626));
  static const foreground = PropDef<Color>('foreground', Codecs.color, Color.white);

  /// Takes the item out of the list (delete, archive); otherwise it springs
  /// back.
  static const removes = PropDef<bool>('removes', Codecs.bool, true);

  /// Offered for an item only while this holds (an expression reading
  /// `${item}`, e.g. `${= item.done}`); empty: always. The first action of
  /// a side that holds is the one a full swipe runs.
  static const when = PropDef<String>('when', Codecs.string, '');

  /// The label's text (font, size, weight; its color is [foreground]).
  static const labelStyle = PropDef<TextStyle>('labelStyle', Codecs.textStyle, TextStyle.empty);
  static const iconSize = PropDef<double>('iconSize', Codecs.positive, 22);

  /// The icon beside the label instead of above it.
  static const inline = PropDef<bool>('inline', Codecs.bool, false);

  static const spec = WidgetSpec('SwipeAction',
      props: [id, label, icon, background, foreground, removes, when, labelStyle, iconSize, inline],
      doc: 'An action behind a swiped list item.');
}

/// Swipe actions on a list's items (`Dismissible`): toward the start reveals
/// [endActions], toward the end [startActions]; past [threshold] the first
/// of the side runs. Running one fires the list's `swipeAction` reactions
/// with `${result.action}`, `${result.item}`, `${result.index}`.
final class SwipeActions extends FieldValue {
  const SwipeActions._(super.fields);

  static SwipeActions? fromJson(Object? json) =>
      readMap(json) == null ? null : SwipeActions._(Props.fromJson(SwipeActionsFields.spec, json));

  @override
  WidgetSpec get spec => SwipeActionsFields.spec;

  SwipeActions set<T>(PropDef<T> field, T value) => SwipeActions._(fields.set(field, value));

  bool get enabled => get(SwipeActionsFields.enabled);
  List<SwipeAction> get startActions => get(SwipeActionsFields.startActions);
  List<SwipeAction> get endActions => get(SwipeActionsFields.endActions);
  double get threshold => get(SwipeActionsFields.threshold);
  bool get undo => get(SwipeActionsFields.undo);
  int get undoMs => get(SwipeActionsFields.undoMs);
  String get undoMessage => get(SwipeActionsFields.undoMessage);
  ListApply get apply => get(SwipeActionsFields.apply);
  BorderRadius get radius => get(SwipeActionsFields.radius);
  double get armedScale => get(SwipeActionsFields.armedScale);
  bool get armHaptic => get(SwipeActionsFields.armHaptic);
}

abstract final class SwipeActionsFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const startActions =
      PropDef<List<SwipeAction>>('startActions', ListCodec<SwipeAction>(_swipeAction), []);
  static const endActions = PropDef<List<SwipeAction>>('endActions', ListCodec<SwipeAction>(_swipeAction), []);

  /// The fraction of the item's width a swipe passes to run the first action.
  static const threshold = PropDef<double>('threshold', DoubleCodec(min: 0, max: 1), 0.4);

  /// An action that removes the item shows an Undo bar first.
  static const undo = PropDef<bool>('undo', Codecs.bool, true);
  static const undoMs = PropDef<int>('undoMs', IntCodec(min: 0), 4000);

  /// `${result.label}` reads the action's label.
  static const undoMessage = PropDef<String>('undoMessage', Codecs.string, r'${result.label}');
  static const apply = PropDef<ListApply>('apply', EnumCodec(ListApply.values), ListApply.none);

  /// The revealed actions' corners (round them to match the item's).
  static const radius = PropDef<BorderRadius>('radius', Codecs.radius, BorderRadius.zero);

  /// The action's label grows to this scale once a release would run it.
  static const armedScale = PropDef<double>('armedScale', Codecs.positive, 1);

  /// A selection click when a swipe passes the threshold either way.
  static const armHaptic = PropDef<bool>('armHaptic', Codecs.bool, false);

  static const spec = WidgetSpec('SwipeActions',
      props: [enabled, startActions, endActions, threshold, undo, undoMs, undoMessage, apply, radius, armedScale, armHaptic],
      doc: 'Actions behind a list\'s swiped items (`Dismissible`).');
}

const _swipeAction = ValueCodec<SwipeAction>(_swipeActionIn, _valueOut, PropType.record('SwipeAction', SwipeActionFields.spec));
SwipeAction? _swipeActionIn(Object? j) => SwipeAction.fromJson(j);

// --- Table columns ---------------------------------------------------------------

/// One column of a table view: the row field its cells show ([key], read
/// as `${item.value}`), its header text ([label], `${item.label}`) and its
/// width (null: the table's `columnWidth`).
final class TableColumn extends FieldValue {
  const TableColumn._(super.fields);

  factory TableColumn({required String key, String label = '', double? width}) => TableColumn._(Props.empty
      .set(TableColumnFields.key, key)
      .set(TableColumnFields.label, label)
      .set(TableColumnFields.width, width));

  /// A column from JSON, or from a bound value: a map like this one's JSON,
  /// or any other value as the column's key and label.
  static TableColumn? fromJson(Object? json) => switch (json) {
        null => null,
        final Map m => TableColumn._(Props.fromJson(TableColumnFields.spec, m)),
        final v => TableColumn(key: '$v', label: '$v'),
      };

  @override
  WidgetSpec get spec => TableColumnFields.spec;

  String get key => get(TableColumnFields.key);
  String get label => get(TableColumnFields.label);
  double? get width => get(TableColumnFields.width);
}

abstract final class TableColumnFields {
  static const key = PropDef<String>('key', Codecs.string, '');
  static const label = PropDef<String>('label', Codecs.string, '');
  static const width = PropDef<double?>('width', Codecs.optionalPositive, null);
  static const spec = WidgetSpec('TableColumn', props: [key, label, width], doc: 'A table view\'s column.');
}

const tableColumnCodec =
    ValueCodec<TableColumn>(_tableColumnIn, _valueOut, PropType.record('TableColumn', TableColumnFields.spec));
TableColumn? _tableColumnIn(Object? j) => TableColumn.fromJson(j);
