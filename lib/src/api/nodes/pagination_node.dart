import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'pagination_node.g.dart';

/// The default width of a new [PaginationNode].
const double kPaginationDefaultWidth = 520;

/// The default height of a new [PaginationNode].
const double kPaginationDefaultHeight = 40;

/// Page controls for a list's pagination controller ([PaginationModel]),
/// found by its name ([controller]): first, previous, page numbers with
/// ellipses (1 … 4 5 6 … 16), next and last buttons, a page size select and
/// a "Showing 21–40 of 312" summary. Every part can be hidden and styled.
///
/// Choosing a page fires the node's `changed` reactions with `${value}`,
/// the page, after the controller moves to it.
@FlutterNode('CodelesslyPagination', family: 'codelessly', nodeType: 'pagination')
@JsonSerializable()
class PaginationNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'pagination';

  @override
  bool get supportsPadding => true;

  @override
  bool get handlesDefaultReactionsInternally => true;

  /// The [PaginationModel.name] of the controller this node shows and moves.
  @FlutterProp(
    'controller',
    type: 'string',
    group: 'Pagination',
    control: 'text',
    field: 'controller',
    required: true,
  )
  String controller;

  @override
  covariant PaginationProperties properties;

  /// Creates a [PaginationNode] with default values, for previews.
  PaginationNode.empty()
    : controller = 'items',
      properties = PaginationProperties(),
      super(
        id: 'pagination',
        name: 'Pagination',
        basicBoxLocal: NodeBox(
          0,
          0,
          kPaginationDefaultWidth,
          kPaginationDefaultHeight,
        ),
      );

  /// Creates a [PaginationNode].
  PaginationNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.rotationDegrees,
    super.alignment,
    super.margin,
    super.padding,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.positioningMode,
    super.parentID,
    super.reactions,
    this.controller = '',
    required this.properties,
    super.variables,
    super.multipleVariables,
  });

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'controller': StringFieldAccess(
      'Controller',
      'The name of the pagination controller (a list\'s pagination) this '
          'node shows and moves.',
      () => controller,
      (value) => controller = value,
    ),
    'properties': ObjectFieldAccess<PaginationProperties>(
      'Properties',
      'Properties of the pagination controls.',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  List<Object?> get props => [
    ...super.props,
    controller,
    properties,
    variables,
    multipleVariables,
  ];

  /// Creates a [PaginationNode] from a JSON object.
  factory PaginationNode.fromJson(Map json) => _$PaginationNodeFromJson(json);

  @override
  Map toJson() =>
      _$PaginationNodeOmitDefaults(this, _$PaginationNodeToJson(this));
}

/// The parts and style of a [PaginationNode].
@JsonSerializable()
class PaginationProperties extends CustomProperties with FieldsHolder {
  /// Whether the first and last page buttons show.
  @FlutterProp(
    'showFirstLast',
    type: 'boolean',
    group: 'Parts',
    control: 'switch',
    field: 'properties.showFirstLast',
  )
  bool showFirstLast;

  /// Whether the previous and next page buttons show.
  @FlutterProp(
    'showPrevNext',
    type: 'boolean',
    group: 'Parts',
    control: 'switch',
    field: 'properties.showPrevNext',
  )
  bool showPrevNext;

  /// Whether the page number buttons show.
  @FlutterProp(
    'showPageNumbers',
    type: 'boolean',
    group: 'Parts',
    control: 'switch',
    field: 'properties.showPageNumbers',
  )
  bool showPageNumbers;

  /// How many page numbers show on each side of the current one before an
  /// ellipsis.
  @FlutterProp(
    'siblingCount',
    type: 'integer',
    group: 'Parts',
    control: 'number',
    field: 'properties.siblingCount',
  )
  int siblingCount;

  /// How many page numbers always show at each end.
  @FlutterProp(
    'boundaryCount',
    type: 'integer',
    group: 'Parts',
    control: 'number',
    field: 'properties.boundaryCount',
  )
  int boundaryCount;

  /// Whether the page size select shows; it offers the controller's
  /// `pageSizeOptions`.
  @FlutterProp(
    'showPageSize',
    type: 'boolean',
    group: 'Parts',
    control: 'switch',
    field: 'properties.showPageSize',
  )
  bool showPageSize;

  /// Whether the summary ([summaryText]) shows.
  @FlutterProp(
    'showSummary',
    type: 'boolean',
    group: 'Parts',
    control: 'switch',
    field: 'properties.showSummary',
  )
  bool showSummary;

  /// The summary, where `{from}`, `{to}`, `{total}`, `{page}` and
  /// `{pageCount}` are replaced, and `${...}` bindings resolve. A total
  /// that isn't known yet shows as "many".
  @FlutterProp(
    'summaryText',
    type: 'string',
    group: 'Parts',
    control: 'text',
    field: 'properties.summaryText',
  )
  String summaryText;

  /// The text before the page size select.
  String pageSizeLabel;

  /// The labels of the first, previous, next and last buttons.
  String firstLabel;

  /// See [firstLabel].
  String previousLabel;

  /// See [firstLabel].
  String nextLabel;

  /// See [firstLabel].
  String lastLabel;

  /// How the parts are placed along the node.
  MainAxisAlignmentC alignment;

  /// The text size.
  @FlutterProp(
    'fontSize',
    type: 'number',
    group: 'Style',
    control: 'number',
    field: 'properties.fontSize',
  )
  double fontSize;

  /// The weight of the text, 100 to 900.
  int fontWeight;

  /// The color of the text and labels.
  @FlutterProp(
    'textColor',
    type: 'object',
    group: 'Style',
    control: 'color',
    field: 'properties.textColor',
  )
  ColorRGBA textColor;

  /// The background of a button; null for none.
  ColorRGBA? buttonColor;

  /// The background of the current page's button.
  @FlutterProp(
    'activeColor',
    type: 'object',
    group: 'Style',
    control: 'color',
    field: 'properties.activeColor',
  )
  ColorRGBA activeColor;

  /// The text color of the current page's button.
  ColorRGBA activeTextColor;

  /// The outline of a button; null for none.
  ColorRGBA? borderColor;

  /// The width of [borderColor]'s outline.
  double borderWidth;

  /// The corner radius of a button.
  double cornerRadius;

  /// The width and height a button takes at least.
  double buttonSize;

  /// The gap between buttons.
  double spacing;

  /// The opacity of a button that can't be pressed (previous on page 1).
  double disabledOpacity;

  /// Creates a [PaginationProperties].
  PaginationProperties({
    this.showFirstLast = true,
    this.showPrevNext = true,
    this.showPageNumbers = true,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.showPageSize = false,
    this.showSummary = true,
    this.summaryText = 'Showing {from}–{to} of {total}',
    this.pageSizeLabel = 'Rows per page',
    this.firstLabel = '«',
    this.previousLabel = '‹',
    this.nextLabel = '›',
    this.lastLabel = '»',
    this.alignment = MainAxisAlignmentC.spaceBetween,
    this.fontSize = 14,
    this.fontWeight = 400,
    this.textColor = const ColorRGBA(r: 0.2, g: 0.22, b: 0.26, a: 1),
    this.buttonColor,
    this.activeColor = const ColorRGBA(r: 0.15, g: 0.39, b: 0.92, a: 1),
    this.activeTextColor = ColorRGBA.white,
    this.borderColor = const ColorRGBA(r: 0.85, g: 0.87, b: 0.9, a: 1),
    this.borderWidth = 1,
    this.cornerRadius = 6,
    this.buttonSize = 32,
    this.spacing = 4,
    this.disabledOpacity = 0.4,
  });

  /// The page numbers to show for [page] of [pageCount], with null where an
  /// ellipsis goes: page 5 of 16 with one sibling and one boundary page is
  /// `[1, null, 4, 5, 6, null, 16]`. An ellipsis never stands for a single
  /// page: that page is shown instead.
  static List<int?> pageItems({
    required int page,
    required int pageCount,
    int siblingCount = 1,
    int boundaryCount = 1,
  }) {
    if (pageCount <= 0) return const [];
    final int current = page.clamp(1, pageCount);
    final Set<int> shown = {
      for (int i = 1; i <= boundaryCount && i <= pageCount; i++) i,
      for (int i = pageCount - boundaryCount + 1; i <= pageCount; i++)
        if (i >= 1) i,
      for (int i = current - siblingCount; i <= current + siblingCount; i++)
        if (i >= 1 && i <= pageCount) i,
    };
    final List<int> sorted = shown.toList()..sort();
    final List<int?> result = [];
    for (final int number in sorted) {
      if (result.isNotEmpty) {
        final int previous = result.last!;
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

  /// Duplicates this instance with the given data overrides.
  PaginationProperties copyWith({
    bool? showFirstLast,
    bool? showPrevNext,
    bool? showPageNumbers,
    int? siblingCount,
    int? boundaryCount,
    bool? showPageSize,
    bool? showSummary,
    String? summaryText,
    String? pageSizeLabel,
    String? firstLabel,
    String? previousLabel,
    String? nextLabel,
    String? lastLabel,
    MainAxisAlignmentC? alignment,
    double? fontSize,
    int? fontWeight,
    ColorRGBA? textColor,
    ColorRGBA? buttonColor,
    ColorRGBA? activeColor,
    ColorRGBA? activeTextColor,
    ColorRGBA? borderColor,
    double? borderWidth,
    double? cornerRadius,
    double? buttonSize,
    double? spacing,
    double? disabledOpacity,
  }) => PaginationProperties(
    showFirstLast: showFirstLast ?? this.showFirstLast,
    showPrevNext: showPrevNext ?? this.showPrevNext,
    showPageNumbers: showPageNumbers ?? this.showPageNumbers,
    siblingCount: siblingCount ?? this.siblingCount,
    boundaryCount: boundaryCount ?? this.boundaryCount,
    showPageSize: showPageSize ?? this.showPageSize,
    showSummary: showSummary ?? this.showSummary,
    summaryText: summaryText ?? this.summaryText,
    pageSizeLabel: pageSizeLabel ?? this.pageSizeLabel,
    firstLabel: firstLabel ?? this.firstLabel,
    previousLabel: previousLabel ?? this.previousLabel,
    nextLabel: nextLabel ?? this.nextLabel,
    lastLabel: lastLabel ?? this.lastLabel,
    alignment: alignment ?? this.alignment,
    fontSize: fontSize ?? this.fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    textColor: textColor ?? this.textColor,
    buttonColor: buttonColor ?? this.buttonColor,
    activeColor: activeColor ?? this.activeColor,
    activeTextColor: activeTextColor ?? this.activeTextColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    buttonSize: buttonSize ?? this.buttonSize,
    spacing: spacing ?? this.spacing,
    disabledOpacity: disabledOpacity ?? this.disabledOpacity,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'showFirstLast': BoolFieldAccess(
      'First / Last',
      'Show the first and last page buttons.',
      () => showFirstLast,
      (value) => showFirstLast = value,
    ),
    'showPrevNext': BoolFieldAccess(
      'Previous / Next',
      'Show the previous and next page buttons.',
      () => showPrevNext,
      (value) => showPrevNext = value,
    ),
    'showPageNumbers': BoolFieldAccess(
      'Page Numbers',
      'Show the page number buttons.',
      () => showPageNumbers,
      (value) => showPageNumbers = value,
    ),
    'showPageSize': BoolFieldAccess(
      'Page Size',
      'Show the page size select.',
      () => showPageSize,
      (value) => showPageSize = value,
    ),
    'showSummary': BoolFieldAccess(
      'Summary',
      'Show the "Showing 21–40 of 312" summary.',
      () => showSummary,
      (value) => showSummary = value,
    ),
    'summaryText': StringFieldAccess(
      'Summary Text',
      'The summary; {from}, {to}, {total}, {page} and {pageCount} are '
          'replaced.',
      () => summaryText,
      (value) => summaryText = value,
    ),
    'activeColor': ColorFieldAccess<ColorRGBA>(
      'Active Color',
      'The background of the current page\'s button.',
      () => activeColor,
      (value) => activeColor = value,
    ),
    'textColor': ColorFieldAccess<ColorRGBA>(
      'Text Color',
      'The color of the text.',
      () => textColor,
      (value) => textColor = value,
    ),
  };

  @override
  List<Object?> get props => [
    showFirstLast,
    showPrevNext,
    showPageNumbers,
    siblingCount,
    boundaryCount,
    showPageSize,
    showSummary,
    summaryText,
    pageSizeLabel,
    firstLabel,
    previousLabel,
    nextLabel,
    lastLabel,
    alignment,
    fontSize,
    fontWeight,
    textColor,
    buttonColor,
    activeColor,
    activeTextColor,
    borderColor,
    borderWidth,
    cornerRadius,
    buttonSize,
    spacing,
    disabledOpacity,
  ];

  /// Creates a [PaginationProperties] from a JSON object.
  factory PaginationProperties.fromJson(Map json) =>
      _$PaginationPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaginationPropertiesOmitDefaults(
    this,
    _$PaginationPropertiesToJson(this),
  );
}
