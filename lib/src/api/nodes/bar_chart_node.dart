import 'package:json_annotation/json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'bar_chart_node.g.dart';

/// The default width of a bar chart.
const double kBarChartDefaultWidth = 320;

/// The default height of a bar chart.
const double kBarChartDefaultHeight = 160;

/// A column chart for a short series, e.g. energy per hour.
///
/// Each value is a bar scaled against [BarChartProperties.max]; a null value
/// (data that doesn't exist yet) draws as a short dash on the baseline. One
/// bar can be highlighted, with the rest dimmed. Horizontal grid lines with
/// labels in a right-hand gutter and a label under each bar are optional.
///
/// [values], [labels] and [highlight] can be bound to variables or formulas
/// (`values`, `labels`, `highlight`).
@JsonSerializable()
class BarChartNode extends SceneNode with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'barChart';

  @override
  covariant BarChartProperties properties;

  /// The series. Null entries draw as empty slots.
  List<double?> values;

  /// A label under each bar; empty strings leave that bar unlabeled.
  List<String> labels;

  /// Index of the highlighted bar, or null to draw every bar at full
  /// strength.
  int? highlight;

  @override
  bool get supportsPadding => false;

  /// Creates a bar chart preview. Strictly used for previews, e.g. in the
  /// components panel.
  BarChartNode.empty()
    : properties = BarChartProperties(),
      values = [2, 5, 9, 7, 4, null],
      labels = ['a', '', 'c', '', 'e', ''],
      highlight = 4,
      super(
        id: 'barChart',
        name: 'Bar Chart',
        basicBoxLocal: NodeBox(
          0,
          0,
          kBarChartDefaultWidth,
          kBarChartDefaultHeight,
        ),
      );

  /// Creates a [BarChartNode] with the given data.
  BarChartNode({
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
    // Custom properties.
    List<double?>? values,
    List<String>? labels,
    this.highlight,
    required this.properties,
    super.variables,
    super.multipleVariables,
  }) : values = values ?? [],
       labels = labels ?? [] {
    setVariablesMixin(
      variables: variables,
      multipleVariables: multipleVariables,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<BarChartProperties>(
      'Properties',
      'properties of the bar chart',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    values,
    labels,
    highlight,
    properties,
    variables,
    multipleVariables,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    ObjectValue(name: 'values', value: values),
    ObjectValue(name: 'labels', value: labels),
    IntValue(name: 'highlight', value: highlight ?? -1),
    ColorValue(name: 'color', value: properties.color),
  ];

  /// Creates a [BarChartNode] from a JSON object.
  factory BarChartNode.fromJson(Map json) => _$BarChartNodeFromJson(json);

  @override
  Map toJson() => _$BarChartNodeOmitDefaults(this, _$BarChartNodeToJson(this));
}

/// Configurable properties of a [BarChartNode].
@JsonSerializable()
class BarChartProperties extends CustomProperties with FieldsHolder {
  /// The value of a full-height bar. 0 scales to the largest value.
  double max;

  /// Bar color. Bindable as `color`.
  ColorRGBA color;

  /// Opacity of the bars that aren't highlighted, when a bar is.
  double dimmedOpacity;

  /// Space between bars.
  double barGap;

  /// Radius of a bar's top corners.
  double barRadius;

  /// Color of the dash drawn for a null value.
  ColorRGBA emptyColor;

  /// Height of the dash drawn for a null value.
  double emptyHeight;

  /// Number of horizontal grid lines, evenly spaced up to the top.
  int gridLines;

  /// Grid line color.
  ColorRGBA gridColor;

  /// Labels for the grid lines from the bottom one up. Shown in a gutter on
  /// the right when not empty.
  List<String> gridLabels;

  /// Width of the right-hand gutter for [gridLabels].
  double gridLabelWidth;

  /// Color of the baseline under the bars. Transparent for none.
  ColorRGBA baselineColor;

  /// Font family of bar and grid labels.
  String labelFontFamily;

  /// Font size of bar and grid labels.
  double labelFontSize;

  /// Color of bar and grid labels.
  ColorRGBA labelColor;

  /// Color of the highlighted bar's label.
  ColorRGBA highlightLabelColor;

  /// Space between the baseline and the bar labels.
  double labelGap;

  /// Whether bar heights animate when values change.
  bool animate;

  /// Animation duration in milliseconds.
  int animationDurationInMillis;

  /// Creates [BarChartProperties] with the given data.
  BarChartProperties({
    this.max = 0,
    this.color = const ColorRGBA(r: 0.95, g: 0.76, b: 0.19, a: 1),
    this.dimmedOpacity = 0.55,
    this.barGap = 3,
    this.barRadius = 1,
    this.emptyColor = const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
    this.emptyHeight = 2,
    this.gridLines = 3,
    this.gridColor = const ColorRGBA(r: 0.17, g: 0.19, b: 0.22, a: 1),
    List<String>? gridLabels,
    this.gridLabelWidth = 40,
    this.baselineColor = const ColorRGBA(r: 0.23, g: 0.25, b: 0.28, a: 1),
    this.labelFontFamily = 'JetBrains Mono',
    this.labelFontSize = 10,
    this.labelColor = const ColorRGBA(r: 0.42, g: 0.45, b: 0.49, a: 1),
    this.highlightLabelColor = const ColorRGBA(r: 0.91, g: 0.92, b: 0.93, a: 1),
    this.labelGap = 6,
    this.animate = true,
    this.animationDurationInMillis = 700,
  }) : gridLabels = gridLabels ?? [];

  /// Duplicates these properties with the given overrides.
  BarChartProperties copyWith({
    double? max,
    ColorRGBA? color,
    double? dimmedOpacity,
    double? barGap,
    double? barRadius,
    ColorRGBA? emptyColor,
    double? emptyHeight,
    int? gridLines,
    ColorRGBA? gridColor,
    List<String>? gridLabels,
    double? gridLabelWidth,
    ColorRGBA? baselineColor,
    String? labelFontFamily,
    double? labelFontSize,
    ColorRGBA? labelColor,
    ColorRGBA? highlightLabelColor,
    double? labelGap,
    bool? animate,
    int? animationDurationInMillis,
  }) => BarChartProperties(
    max: max ?? this.max,
    color: color ?? this.color,
    dimmedOpacity: dimmedOpacity ?? this.dimmedOpacity,
    barGap: barGap ?? this.barGap,
    barRadius: barRadius ?? this.barRadius,
    emptyColor: emptyColor ?? this.emptyColor,
    emptyHeight: emptyHeight ?? this.emptyHeight,
    gridLines: gridLines ?? this.gridLines,
    gridColor: gridColor ?? this.gridColor,
    gridLabels: gridLabels ?? this.gridLabels,
    gridLabelWidth: gridLabelWidth ?? this.gridLabelWidth,
    baselineColor: baselineColor ?? this.baselineColor,
    labelFontFamily: labelFontFamily ?? this.labelFontFamily,
    labelFontSize: labelFontSize ?? this.labelFontSize,
    labelColor: labelColor ?? this.labelColor,
    highlightLabelColor: highlightLabelColor ?? this.highlightLabelColor,
    labelGap: labelGap ?? this.labelGap,
    animate: animate ?? this.animate,
    animationDurationInMillis:
        animationDurationInMillis ?? this.animationDurationInMillis,
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'max': NumFieldAccess<double>(
      'Max',
      'The value of a full-height bar, 0 for the largest value',
      () => max,
      (value) => max = value,
    ),
    'color': ColorFieldAccess<ColorRGBA>(
      'Color',
      'Bar color',
      () => color,
      (value) => color = value,
    ),
    'gridLines': NumFieldAccess<int>(
      'Grid Lines',
      'Number of horizontal grid lines',
      () => gridLines,
      (value) => gridLines = value,
    ),
  };

  @override
  List<Object?> get props => [
    max,
    color,
    dimmedOpacity,
    barGap,
    barRadius,
    emptyColor,
    emptyHeight,
    gridLines,
    gridColor,
    gridLabels,
    gridLabelWidth,
    baselineColor,
    labelFontFamily,
    labelFontSize,
    labelColor,
    highlightLabelColor,
    labelGap,
    animate,
    animationDurationInMillis,
  ];

  /// Creates [BarChartProperties] from a JSON object.
  factory BarChartProperties.fromJson(Map json) =>
      _$BarChartPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$BarChartPropertiesOmitDefaults(this, _$BarChartPropertiesToJson(this));
}
