import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';
import 'package:equatable/equatable.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'progressbar_node.g.dart';

/// The default width of the progress bar.
const double kProgressBarDefaultWidth = 150;

/// The default height of the progress bar.
const double kProgressBarDefaultHeight = 10;

/// Progress bar is a widget that displays the current progress of an ongoing
/// process. For example, an image being downloaded.
@FlutterNode('CodelesslyProgressBar', family: 'codelessly', nodeType: 'progressBar')
@JsonSerializable()
class ProgressBarNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'progressBar';

  /// Holds configurable properties of the progress bar.
  @override
  covariant ProgressBarProperties properties;

  /// Current progress value of the progress bar.
  @FlutterProp('currentValue', type: 'number', group: 'State', control: 'number', bindable: true)
  double currentValue = 0;

  @override
  bool get supportsPadding => false;

  /// Creates a mock progress bar preview.
  /// Strictly used for previews. e.g in components panel.
  ProgressBarNode.empty()
    : properties = ProgressBarProperties(),
      super(
        id: 'progressbar',
        name: 'ProgressBar',
        basicBoxLocal: NodeBox(
          0,
          0,
          kProgressBarDefaultWidth,
          kProgressBarDefaultHeight,
        ),
      );

  /// Creates progress bar from the given properties.
  /// Strictly used for previews. e.g in components panel.
  ProgressBarNode.fromProperties(this.properties)
    : super(
        id: 'progressbar',
        name: 'ProgressBar',
        basicBoxLocal: NodeBox(
          0,
          0,
          kProgressBarDefaultWidth,
          kProgressBarDefaultHeight,
        ),
      );

  /// Creates a [ProgressBarNode] instance with the given data.
  ProgressBarNode({
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
    this.currentValue = 0,
    required this.properties,
    super.variables,
    super.multipleVariables,
  }) {
    setVariablesMixin(
      variables: variables,
      multipleVariables: multipleVariables,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<ProgressBarProperties>(
      'Properties',
      'properties of the progress bar',
      () => properties,
      (value) => properties = value,
    ),
  };

  @override
  List<Object?> get props => [
    ...super.props,
    properties,
    variables,
    multipleVariables,
  ];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    DoubleValue(name: 'currentValue', value: currentValue),
  ];

  /// Creates a [ProgressBarNode] instance from a JSON object.
  factory ProgressBarNode.fromJson(Map json) => _$ProgressBarNodeFromJson(json);

  @override
  Map toJson() =>
      _$ProgressBarNodeOmitDefaults(this, _$ProgressBarNodeToJson(this));
}

/// Holds configurable properties of the progress bar.
@JsonSerializable()
class ProgressBarProperties extends CustomProperties with FieldsHolder {
  /// Maximum value of the progress bar, i.e., when the progress is complete.
  @FlutterProp('maxValue', type: 'number', group: 'Range', control: 'number', field: 'properties.maxValue')
  double maxValue;

  /// Color of progress bar's background.
  ColorRGBA backgroundColor;

  /// Color that indicates progress, i.e., color of the foreground bar.
  ColorRGBA progressColor;

  /// Whether the bar is vertically oriented.
  bool isVertical;

  /// Corner radii of the bar.
  CornerRadius cornerRadius;

  /// Whether the bar animates to show progress.
  bool animate;

  /// Duration of animation in milliseconds.
  int animationDurationInMillis;

  /// A straight bar, or an arc like a dial or gauge.
  @JsonKey(unknownEnumValue: ProgressBarShape.bar)
  ProgressBarShape shape;

  /// Arc only: where the arc starts, in degrees clockwise from 3 o'clock.
  /// The default 150 with a 240 sweep makes a dial open at the bottom.
  double arcStartAngle;

  /// Arc only: how far the arc runs, in degrees.
  double arcSweepAngle;

  /// Arc only: thickness of the track and progress.
  double arcStrokeWidth;

  /// Arc only: color of a needle pointing at the value, or null for none.
  /// The needle goes past the end of the arc a little when the value is
  /// over the max, so an overrun shows.
  ColorRGBA? needleColor;

  /// Arc only: tick marks dividing the track evenly, drawn in [tickColor].
  int tickCount;

  /// Arc only: color of the tick marks.
  ColorRGBA tickColor;

  /// Arc only: colored zones drawn just outside the track, e.g. green up to
  /// 90% and amber after.
  List<ProgressBand> bands;

  /// Creates a [ProgressBarProperties] instance with the given data.
  ProgressBarProperties({
    this.maxValue = 100,
    this.backgroundColor = ColorRGBA.grey10,
    this.progressColor = ColorRGBA.black,
    this.isVertical = false,
    this.cornerRadius = CornerRadius.zero,
    this.animate = false,
    this.animationDurationInMillis = 300,
    this.shape = ProgressBarShape.bar,
    this.arcStartAngle = 150,
    this.arcSweepAngle = 240,
    this.arcStrokeWidth = 12,
    this.needleColor,
    this.tickCount = 0,
    this.tickColor = ColorRGBA.white,
    List<ProgressBand>? bands,
  }) : bands = bands ?? [];

  /// Duplicates this [ProgressBarProperties] instance with the given data
  /// overrides.
  ProgressBarProperties copyWith({
    double? maxValue,
    ColorRGBA? backgroundColor,
    ColorRGBA? progressColor,
    bool? isVertical,
    CornerRadius? cornerRadius,
    bool? animate,
    int? animationDurationInMillis,
    ProgressBarShape? shape,
    double? arcStartAngle,
    double? arcSweepAngle,
    double? arcStrokeWidth,
    ColorRGBA? needleColor,
    bool clearNeedle = false,
    int? tickCount,
    ColorRGBA? tickColor,
    List<ProgressBand>? bands,
  }) {
    return ProgressBarProperties(
      maxValue: maxValue ?? this.maxValue,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      progressColor: progressColor ?? this.progressColor,
      isVertical: isVertical ?? this.isVertical,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      animate: animate ?? this.animate,
      animationDurationInMillis:
          animationDurationInMillis ?? this.animationDurationInMillis,
      shape: shape ?? this.shape,
      arcStartAngle: arcStartAngle ?? this.arcStartAngle,
      arcSweepAngle: arcSweepAngle ?? this.arcSweepAngle,
      arcStrokeWidth: arcStrokeWidth ?? this.arcStrokeWidth,
      needleColor: clearNeedle ? null : needleColor ?? this.needleColor,
      tickCount: tickCount ?? this.tickCount,
      tickColor: tickColor ?? this.tickColor,
      bands: bands ?? this.bands,
    );
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'maxValue': NumFieldAccess<double>(
      'Max Value',
      'Maximum value of the progress bar',
      () => maxValue,
      (value) => maxValue = value,
    ),
    'backgroundColor': ColorFieldAccess<ColorRGBA>(
      'Background Color',
      'Color of progress bar\'s background',
      () => backgroundColor,
      (value) {
        backgroundColor = value;
      },
    ),
    'progressColor': ColorFieldAccess<ColorRGBA>(
      'Progress Color',
      'Color that indicates progress, i.e., color of the foreground bar',
      () => progressColor,
      (value) {
        progressColor = value;
      },
    ),
    'isVertical': BoolFieldAccess(
      'Is Vertical',
      'Whether the bar is vertically oriented',
      () => isVertical,
      (value) => isVertical = value,
      requiresLayout: true,
    ),
    'cornerRadius': RadiusFieldAccess(
      'Corner Radius',
      'Corner radii of the bar',
      () => cornerRadius,
      (value) => cornerRadius = value,
    ),
    'animate': BoolFieldAccess(
      'Animate',
      'Whether the bar animates to show progress',
      () => animate,
      (value) => animate = value,
    ),
    'animationDurationInMillis': NumFieldAccess<int>(
      'Animation Duration',
      'Duration of animation in milliseconds',
      () => animationDurationInMillis,
      (value) => animationDurationInMillis = value,
    ),
    'shape': EnumFieldAccess<ProgressBarShape>(
      'Shape',
      'A straight bar, or an arc like a dial or gauge',
      () => shape,
      (value) => shape = value,
      options: () => ProgressBarShape.values,
      defaultValue: () => ProgressBarShape.bar,
    ),
    'arcStartAngle': NumFieldAccess<double>(
      'Arc Start',
      'Arc only: start angle in degrees, clockwise from 3 o\'clock',
      () => arcStartAngle,
      (value) => arcStartAngle = value,
    ),
    'arcSweepAngle': NumFieldAccess<double>(
      'Arc Sweep',
      'Arc only: how far the arc runs, in degrees',
      () => arcSweepAngle,
      (value) => arcSweepAngle = value,
    ),
    'arcStrokeWidth': NumFieldAccess<double>(
      'Arc Thickness',
      'Arc only: thickness of the track and progress',
      () => arcStrokeWidth,
      (value) => arcStrokeWidth = value,
    ),
    'needleColor': ColorFieldAccess<ColorRGBA?>(
      'Needle Color',
      'Arc only: color of a needle pointing at the value; empty for none',
      () => needleColor,
      (value) => needleColor = value,
    ),
    'tickCount': NumFieldAccess<int>(
      'Ticks',
      'Arc only: how many tick marks divide the track',
      () => tickCount,
      (value) => tickCount = value,
    ),
    'tickColor': ColorFieldAccess<ColorRGBA>(
      'Tick Color',
      'Arc only: color of the tick marks',
      () => tickColor,
      (value) => tickColor = value,
    ),
  };

  @override
  List<Object?> get props => [
    maxValue,
    backgroundColor,
    progressColor,
    isVertical,
    cornerRadius,
    animate,
    animationDurationInMillis,
    shape,
    arcStartAngle,
    arcSweepAngle,
    arcStrokeWidth,
    needleColor,
    tickCount,
    tickColor,
    bands,
  ];

  /// Creates a [ProgressBarProperties] instance from a JSON object.
  factory ProgressBarProperties.fromJson(Map json) =>
      _$ProgressBarPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProgressBarPropertiesOmitDefaults(
    this,
    _$ProgressBarPropertiesToJson(this),
  );
}

/// The shape of a [ProgressBarNode].
enum ProgressBarShape {
  /// A straight horizontal or vertical bar.
  bar,

  /// An arc, like a dial or gauge.
  arc,
}

/// A colored zone of an arc progress bar, from [start] to [end] as fractions
/// of the max value (0 to 1).
@JsonSerializable()
class ProgressBand extends Equatable with SerializableMixin {
  /// Where the zone starts, as a fraction of the max value.
  final double start;

  /// Where the zone ends, as a fraction of the max value.
  final double end;

  /// The zone's color.
  final ColorRGBA color;

  /// Creates a [ProgressBand].
  const ProgressBand({
    required this.start,
    required this.end,
    required this.color,
  });

  /// Creates a [ProgressBand] from JSON.
  factory ProgressBand.fromJson(Map json) => _$ProgressBandFromJson(json);

  @override
  Map toJson() => _$ProgressBandToJson(this);

  @override
  List<Object?> get props => [start, end, color];
}
