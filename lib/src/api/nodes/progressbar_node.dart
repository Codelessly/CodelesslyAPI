import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

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
@JsonSerializable()
class ProgressBarNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'progressBar';

  /// Holds configurable properties of the progress bar.
  @override
  covariant ProgressBarProperties properties;

  /// Current progress value of the progress bar.
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
              0, 0, kProgressBarDefaultWidth, kProgressBarDefaultHeight),
        );

  /// Creates progress bar from the given properties.
  /// Strictly used for previews. e.g in components panel.
  ProgressBarNode.fromProperties(this.properties)
      : super(
          id: 'progressbar',
          name: 'ProgressBar',
          basicBoxLocal: NodeBox(
              0, 0, kProgressBarDefaultWidth, kProgressBarDefaultHeight),
        );

  /// Creates a [ProgressBarNode] instance with the given data.
  ProgressBarNode({
    bool? value,
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
    // [BlendMixin] properties.
    double opacity = 1,
    bool isMask = false,
    List<Effect> effects = const [],
    BlendModeC blendMode = BlendModeC.srcOver,
    // Custom properties.
    this.currentValue = 0,
    required this.properties,
    super.variables,
    super.multipleVariables,
  }) {
    setVariablesMixin(
        variables: variables, multipleVariables: multipleVariables);
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
  Map toJson() => _$ProgressBarNodeToJson(this);
}

/// Holds configurable properties of the progress bar.
@JsonSerializable()
class ProgressBarProperties extends CustomProperties with FieldsHolder {
  /// Maximum value of the progress bar, i.e., when the progress is complete.
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

  /// Creates a [ProgressBarProperties] instance with the given data.
  ProgressBarProperties({
    this.maxValue = 100,
    this.backgroundColor = ColorRGBA.grey10,
    this.progressColor = ColorRGBA.black,
    this.isVertical = false,
    this.cornerRadius = CornerRadius.zero,
    this.animate = false,
    this.animationDurationInMillis = 300,
  });

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
            if (value != null) backgroundColor = value;
          },
        ),
        'progressColor': ColorFieldAccess<ColorRGBA>(
          'Progress Color',
          'Color that indicates progress, i.e., color of the foreground bar',
          () => progressColor,
          (value) {
            if (value != null) progressColor = value;
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
      ];

  /// Creates a [ProgressBarProperties] instance from a JSON object.
  factory ProgressBarProperties.fromJson(Map json) =>
      _$ProgressBarPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProgressBarPropertiesToJson(this);
}
