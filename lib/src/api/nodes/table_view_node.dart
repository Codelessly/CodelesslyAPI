import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'table_view_node.g.dart';

/// One column of a [TableViewNode].
@JsonSerializable()
class TableColumnModel with Equatable, SerializableMixin {
  /// The field of a row that the column shows: a cell reads it as
  /// `${item.value}` (and the whole row as `${item.row}`).
  final String key;

  /// The column header's text: `${item.label}` in the header node.
  final String label;

  /// The column's width; null for the table's [TableViewProperties.columnWidth].
  final double? width;

  /// Creates a [TableColumnModel].
  const TableColumnModel({this.key = '', this.label = '', this.width});

  @override
  List<Object?> get props => [key, label, width];

  /// Creates a [TableColumnModel] from a JSON object.
  factory TableColumnModel.fromJson(Map json) =>
      _$TableColumnModelFromJson(json);

  @override
  Map toJson() =>
      _$TableColumnModelOmitDefaults(this, _$TableColumnModelToJson(this));

  /// Reads a column from a bound value: a map like this model's JSON, or
  /// any other value as the column's key and label.
  static TableColumnModel fromValue(Object? value) => switch (value) {
    final Map map => TableColumnModel(
      key: '${map['key'] ?? map['id'] ?? ''}',
      label: '${map['label'] ?? map['name'] ?? map['key'] ?? ''}',
      width: (map['width'] as num?)?.toDouble(),
    ),
    _ => TableColumnModel(key: '$value', label: '$value'),
  };
}

/// A table that scrolls along both axes and builds only the cells on
/// screen, with a header row and a header column that stay pinned:
/// spreadsheets, schedules, seat maps. Flutter's `TableView`
/// (a `TwoDimensionalScrollView`).
///
/// Rows come from `variables['data']` (a list), or [TableViewProperties.rowCount]
/// for a fixed number. Columns come from [TableViewProperties.columns], or
/// a list bound to `variables['columns']`.
///
/// Its children are templates, built once per cell, each with `${item}`:
///
/// * [TableViewProperties.cellNodeId]: `{value, row, column, rowIndex,
///   columnIndex}`, `${index}` being the row's index.
/// * [TableViewProperties.columnHeaderNodeId]: `{label, column, columnIndex}`.
/// * [TableViewProperties.rowHeaderNodeId]: `{row, rowIndex}`.
/// * [TableViewProperties.cornerNodeId]: drawn where the headers meet.
///
/// A cell's taps run its own reactions with these values.
@FlutterNode('CodelesslyTableView', family: 'codelessly', nodeType: 'tableView')
@JsonSerializable()
class TableViewNode extends SinglePlaceholderNode
    with CustomPropertiesMixin, ClipMixin, FieldsHolder {
  @override
  final String type = 'tableView';

  @override
  final bool supportsPadding = true;

  /// The table's properties.
  @override
  covariant TableViewProperties properties;

  /// Creates a [TableViewNode].
  TableViewNode({
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
    required this.properties,
    required List<String> children,
    super.variables,
    super.multipleVariables,
    bool clipsContent = true,
  }) : super(
         children: [],
         allowedTypes: [],
         deniedTypes: ['tableView'],
         ephemeral: false,
       ) {
    setChildrenMixin(children: children);
    setClipMixin(clipsContent: clipsContent);
  }

  @override
  List<TriggerType> get triggerTypes => [TriggerType.scrollEnd];

  @override
  bool get canBeMarked => true;

  /// Creates a [TableViewNode] from a JSON object.
  factory TableViewNode.fromJson(Map json) => _$TableViewNodeFromJson({
    'allowedTypes': <String>[],
    'deniedTypes': ['tableView'],
    ...json,
  });

  @override
  Map toJson() {
    final json = _$TableViewNodeOmitDefaults(this, _$TableViewNodeToJson(this));
    if (deniedTypes.length == 1 && deniedTypes.single == 'tableView') {
      json.remove('deniedTypes');
    }
    if (allowedTypes.isEmpty) json.remove('allowedTypes');
    return json;
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<TableViewProperties>(
      'Properties',
      'Properties of the table.',
      () => properties,
      (value) => properties = value,
    ),
  };
}

/// The properties of a [TableViewNode].
@JsonSerializable()
class TableViewProperties extends CustomProperties with FieldsHolder {
  /// The columns, unless a list is bound to `variables['columns']`.
  List<TableColumnModel> columns;

  /// The number of rows when no data is bound.
  int? rowCount;

  /// The node built for each body cell.
  String cellNodeId;

  /// The node built for each column's header; empty for no header row.
  String columnHeaderNodeId;

  /// The node built for each row's header; empty for no header column.
  String rowHeaderNodeId;

  /// The node built where the header row and column meet.
  String cornerNodeId;

  /// The height of a body row.
  @FlutterProp(
    'rowHeight',
    type: 'number',
    group: 'Layout',
    control: 'number',
    field: 'properties.rowHeight',
  )
  double rowHeight;

  /// The height of the header row.
  double headerHeight;

  /// The width of a column that doesn't set its own.
  @FlutterProp(
    'columnWidth',
    type: 'number',
    group: 'Layout',
    control: 'number',
    field: 'properties.columnWidth',
  )
  double columnWidth;

  /// The width of the header column.
  double rowHeaderWidth;

  /// Whether the header row stays at the top while the rows scroll.
  bool pinHeaderRow;

  /// Whether the header column stays at the start while the columns
  /// scroll.
  bool pinHeaderColumn;

  /// The color of the lines between cells; null for none.
  ColorRGBA? gridLineColor;

  /// The width of the lines between cells.
  double gridLineWidth;

  /// The background of every other body row; null for none.
  ColorRGBA? stripeColor;

  /// The background of the header row and column; null for none.
  ColorRGBA? headerColor;

  /// Pixels beyond the visible area to build cells in, on each axis.
  double? cacheExtent;

  /// Creates a [TableViewProperties].
  TableViewProperties({
    this.columns = const [],
    this.rowCount,
    this.cellNodeId = '',
    this.columnHeaderNodeId = '',
    this.rowHeaderNodeId = '',
    this.cornerNodeId = '',
    this.rowHeight = 40,
    this.headerHeight = 44,
    this.columnWidth = 120,
    this.rowHeaderWidth = 120,
    this.pinHeaderRow = true,
    this.pinHeaderColumn = true,
    this.gridLineColor = const ColorRGBA(r: 0.88, g: 0.89, b: 0.91, a: 1),
    this.gridLineWidth = 1,
    this.stripeColor,
    this.headerColor,
    this.cacheExtent,
  });

  /// Whether the table has a header row.
  bool get hasHeaderRow => columnHeaderNodeId.isNotEmpty;

  /// Whether the table has a header column.
  bool get hasHeaderColumn => rowHeaderNodeId.isNotEmpty;

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'rowHeight': NumFieldAccess<double>(
      'Row Height',
      'The height of a body row.',
      () => rowHeight,
      (value) => rowHeight = value,
      requiresLayout: true,
    ),
    'columnWidth': NumFieldAccess<double>(
      'Column Width',
      'The width of a column that does not set its own.',
      () => columnWidth,
      (value) => columnWidth = value,
      requiresLayout: true,
    ),
    'pinHeaderRow': BoolFieldAccess(
      'Pin Header Row',
      'Keep the header row at the top while the rows scroll.',
      () => pinHeaderRow,
      (value) => pinHeaderRow = value,
    ),
    'pinHeaderColumn': BoolFieldAccess(
      'Pin Header Column',
      'Keep the header column at the start while the columns scroll.',
      () => pinHeaderColumn,
      (value) => pinHeaderColumn = value,
    ),
  };

  @override
  List<Object?> get props => [
    columns,
    rowCount,
    cellNodeId,
    columnHeaderNodeId,
    rowHeaderNodeId,
    cornerNodeId,
    rowHeight,
    headerHeight,
    columnWidth,
    rowHeaderWidth,
    pinHeaderRow,
    pinHeaderColumn,
    gridLineColor,
    gridLineWidth,
    stripeColor,
    headerColor,
    cacheExtent,
  ];

  /// Creates a [TableViewProperties] from a JSON object.
  factory TableViewProperties.fromJson(Map json) =>
      _$TableViewPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TableViewPropertiesOmitDefaults(
    this,
    _$TableViewPropertiesToJson(this),
  );
}
