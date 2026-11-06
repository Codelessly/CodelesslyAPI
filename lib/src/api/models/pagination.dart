import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';
import 'color_rgba.dart';

part 'pagination.g.dart';

/// Where a [PaginationModel] reads its items from.
enum PaginationSource {
  /// The list's bound data (`variables['data']`, e.g. `${contacts}`): every
  /// item is already in memory and is shown a page at a time.
  data,

  /// The list's cloud query (its collection, filters and order, see
  /// [QueryableMixin]): pages load from the cloud database as needed.
  cloud,

  /// An API call ([PaginationModel.apiId]) that returns one page per call.
  /// Its parameters read the page asked for as `${page.page}`,
  /// `${page.offset}`, `${page.cursor}` and `${page.pageSize}`.
  api;

  /// Displayable string representation.
  String get prettify => switch (this) {
    data => 'Bound data',
    cloud => 'Cloud collection',
    api => 'API call',
  };
}

/// How a page is asked for.
enum PaginationStrategy {
  /// By the index of its first item (`${page.offset}`): 0, 20, 40...
  offset,

  /// By its number (`${page.page}`, from 1).
  page,

  /// By the cursor the previous page returned (`${page.cursor}`, read from
  /// [PaginationModel.cursorPath]): Firestore's `startAfter`, or a REST
  /// API's `next` token. A cursor source can only go to a page after
  /// loading the pages before it; those load in order and are cached.
  cursor;

  /// Displayable string representation.
  String get prettify => switch (this) {
    offset => 'Offset',
    page => 'Page number',
    cursor => 'Cursor',
  };
}

/// How a list shows the pages of its [PaginationModel].
enum PaginationMode {
  /// One page at a time, chosen with a Pagination node or Paginate actions:
  /// an admin table with page numbers.
  pages,

  /// Every loaded page one after another; the next page loads when the
  /// list nears its end (infinite scroll).
  infinite,

  /// Like [infinite], and the pages before the first one load when the list
  /// nears its start, keeping the scroll position as they are put in front
  /// (a chat thread that loads its history upward).
  bidirectional;

  /// Displayable string representation.
  String get prettify => switch (this) {
    pages => 'Pages',
    infinite => 'Infinite scroll',
    bidirectional => 'Both directions',
  };
}

/// A pagination controller: loads a list's items page by page and exposes
/// its state as a map variable named [name], read anywhere on the page:
///
/// * `${name.items}`: the items shown (the current page in [PaginationMode.pages],
///   every loaded page otherwise).
/// * `${name.page}` (from 1), `${name.pageCount}`, `${name.pageSize}`,
///   `${name.totalCount}`, `${name.from}` and `${name.to}` (1-based, for
///   "Showing 21–40 of 312").
/// * `${name.hasMore}`, `${name.hasPrevious}`, `${name.isLoading}` (the first
///   page), `${name.isLoadingMore}`, `${name.isRefreshing}`, `${name.error}`
///   (null when the last load worked) and `${name.status}` (one of the
///   `kQueryStatus*` values).
///
/// Paginate actions ([PaginateAction]) move it: next, previous, go to a
/// page, first, last, refresh, retry, and set the page size. A Pagination
/// node shows and moves it.
///
/// Items are de-duplicated by [keyPath] (a page that shifted because an item
/// was added before it repeats an item; it is shown once) and loaded pages
/// are cached until a refresh.
@JsonSerializable()
class PaginationModel with Equatable, SerializableMixin {
  /// The name of the map variable that holds the state, unique on its page:
  /// `contacts` gives `${contacts.page}`.
  final String name;

  /// How the list shows the pages.
  @JsonKey(unknownEnumValue: PaginationMode.infinite)
  final PaginationMode mode;

  /// Where the items come from.
  @JsonKey(unknownEnumValue: PaginationSource.data)
  final PaginationSource source;

  /// How many items a page holds.
  final int pageSize;

  /// The page sizes a Pagination node offers; empty to offer none.
  final List<int> pageSizeOptions;

  /// How a page is asked for. A cloud source always pages by cursor.
  @JsonKey(unknownEnumValue: PaginationStrategy.offset)
  final PaginationStrategy strategy;

  /// The path in an item of the value that identifies it (`id`, or
  /// `user.id`). Items with the same value show once. Empty keeps every
  /// item.
  final String keyPath;

  /// The page shown first, from 1.
  final int initialPage;

  /// In [PaginationMode.infinite] and [PaginationMode.bidirectional], how
  /// many items from the end (or start) of the loaded items the list may
  /// come before the next (or previous) page loads.
  final int thresholdItems;

  /// Like [thresholdItems], in pixels of scroll left. A load starts when
  /// either is reached. 0 uses [thresholdItems] alone.
  final double thresholdPixels;

  /// Whether loaded pages are kept to show again without loading. A
  /// refresh always clears them.
  final bool cachePages;

  /// The API called for each page, for [PaginationSource.api].
  final String? apiId;

  /// The API's parameters, which can read the page asked for as
  /// `${page.page}`, `${page.offset}`, `${page.cursor}` and
  /// `${page.pageSize}`, e.g. `{'offset': '${page.offset}'}`.
  final Map<String, String> parameters;

  /// The path in the API's response body of the page's items, e.g.
  /// `results` or `data.items`. Empty when the body is the list.
  final String itemsPath;

  /// The path in the API's response body of the number of items of all
  /// pages, e.g. `total`. Empty when the API doesn't count.
  final String totalPath;

  /// The path in the API's response body of the next page's cursor, e.g.
  /// `next_cursor`, for [PaginationStrategy.cursor].
  final String cursorPath;

  /// Whether the user can pull the list past its start to refresh it.
  final bool pullToRefresh;

  /// The color of the refresh indicator's arrow; null for the theme's.
  final ColorRGBA? refreshColor;

  /// The background of the refresh indicator; null for the theme's.
  final ColorRGBA? refreshBackgroundColor;

  /// How far, in pixels, the indicator settles from the list's edge.
  final double refreshDisplacement;

  /// The node shown after the items while the next page loads (a spinner,
  /// skeleton rows). Empty shows a small spinner.
  final String loadingNodeId;

  /// The node shown after the items when a page fails to load; a tap on it
  /// retries. Bind `${name.error}` to say why. Empty shows a "Retry" row.
  final String errorNodeId;

  /// The node shown after the last item once every page is loaded ("You're
  /// all caught up"). Empty shows nothing.
  final String endNodeId;

  /// Creates a [PaginationModel].
  const PaginationModel({
    required this.name,
    this.mode = PaginationMode.infinite,
    this.source = PaginationSource.data,
    this.pageSize = 20,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.strategy = PaginationStrategy.offset,
    this.keyPath = 'id',
    this.initialPage = 1,
    this.thresholdItems = 5,
    this.thresholdPixels = 0,
    this.cachePages = true,
    this.apiId,
    this.parameters = const {},
    this.itemsPath = '',
    this.totalPath = '',
    this.cursorPath = '',
    this.pullToRefresh = false,
    this.refreshColor,
    this.refreshBackgroundColor,
    this.refreshDisplacement = 40,
    this.loadingNodeId = '',
    this.errorNodeId = '',
    this.endNodeId = '',
  });

  /// The strategy actually used: a cloud query always pages by cursor.
  PaginationStrategy get effectiveStrategy =>
      source == PaginationSource.cloud ? PaginationStrategy.cursor : strategy;

  /// Whether the list loads pages as it scrolls.
  bool get autoPaginates => mode != PaginationMode.pages;

  /// The ids of the footer nodes this model shows, which are children of
  /// its list after the item template.
  List<String> get slotNodeIds => [
    if (loadingNodeId.isNotEmpty) loadingNodeId,
    if (errorNodeId.isNotEmpty) errorNodeId,
    if (endNodeId.isNotEmpty) endNodeId,
  ];

  /// Duplicates this instance with the given data overrides.
  PaginationModel copyWith({
    String? name,
    PaginationMode? mode,
    PaginationSource? source,
    int? pageSize,
    List<int>? pageSizeOptions,
    PaginationStrategy? strategy,
    String? keyPath,
    int? initialPage,
    int? thresholdItems,
    double? thresholdPixels,
    bool? cachePages,
    String? apiId,
    Map<String, String>? parameters,
    String? itemsPath,
    String? totalPath,
    String? cursorPath,
    bool? pullToRefresh,
    ColorRGBA? refreshColor,
    ColorRGBA? refreshBackgroundColor,
    double? refreshDisplacement,
    String? loadingNodeId,
    String? errorNodeId,
    String? endNodeId,
  }) => PaginationModel(
    name: name ?? this.name,
    mode: mode ?? this.mode,
    source: source ?? this.source,
    pageSize: pageSize ?? this.pageSize,
    pageSizeOptions: pageSizeOptions ?? this.pageSizeOptions,
    strategy: strategy ?? this.strategy,
    keyPath: keyPath ?? this.keyPath,
    initialPage: initialPage ?? this.initialPage,
    thresholdItems: thresholdItems ?? this.thresholdItems,
    thresholdPixels: thresholdPixels ?? this.thresholdPixels,
    cachePages: cachePages ?? this.cachePages,
    apiId: apiId ?? this.apiId,
    parameters: parameters ?? this.parameters,
    itemsPath: itemsPath ?? this.itemsPath,
    totalPath: totalPath ?? this.totalPath,
    cursorPath: cursorPath ?? this.cursorPath,
    pullToRefresh: pullToRefresh ?? this.pullToRefresh,
    refreshColor: refreshColor ?? this.refreshColor,
    refreshBackgroundColor:
        refreshBackgroundColor ?? this.refreshBackgroundColor,
    refreshDisplacement: refreshDisplacement ?? this.refreshDisplacement,
    loadingNodeId: loadingNodeId ?? this.loadingNodeId,
    errorNodeId: errorNodeId ?? this.errorNodeId,
    endNodeId: endNodeId ?? this.endNodeId,
  );

  @override
  List<Object?> get props => [
    name,
    mode,
    source,
    pageSize,
    pageSizeOptions,
    strategy,
    keyPath,
    initialPage,
    thresholdItems,
    thresholdPixels,
    cachePages,
    apiId,
    parameters,
    itemsPath,
    totalPath,
    cursorPath,
    pullToRefresh,
    refreshColor,
    refreshBackgroundColor,
    refreshDisplacement,
    loadingNodeId,
    errorNodeId,
    endNodeId,
  ];

  /// Creates a [PaginationModel] from a JSON object.
  factory PaginationModel.fromJson(Map json) =>
      _$PaginationModelFromJson(json);

  @override
  Map toJson() =>
      _$PaginationModelOmitDefaults(this, _$PaginationModelToJson(this));
}
