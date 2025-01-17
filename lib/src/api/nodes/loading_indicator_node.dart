import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'loading_indicator_node.g.dart';

/// A node that displays a loading indicator.
@JsonSerializable()
class LoadingIndicatorNode extends SceneNode
    with CustomPropertiesMixin, FixedAspectRatioMixin, FieldsHolder {
  @override
  final String type = 'loadingIndicator';

  /// Holds configurable properties of the loading indicator.
  @override
  covariant LoadingIndicatorProperties properties;

  @override
  bool get supportsPadding => false;

  @override
  double get aspectRatio => 1;

  /// Strictly used for previews. e.g in components panel.
  LoadingIndicatorNode.fromProperties(this.properties)
      : super(
          id: 'loadingIndicator',
          name: 'LoadingIndicator',
          basicBoxLocal: NodeBox(0, 0, 24, 24),
        );

  /// Creates a [LoadingIndicatorNode] with given data.
  LoadingIndicatorNode({
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
    required this.properties,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<LoadingIndicatorProperties>(
          'Properties',
          'Properties of the loading indicator.',
          () => properties,
          (value) => properties = value,
        ),
      };

  /// Creates a [LoadingIndicatorNode] from a JSON data.
  factory LoadingIndicatorNode.fromJson(Map json) =>
      _$LoadingIndicatorNodeFromJson(json);

  @override
  Map toJson() => _$LoadingIndicatorNodeToJson(this);

  @override
  BoxConstraintsModel internalConstraints({
    required SizeFit horizontalFit,
    required SizeFit verticalFit,
  }) {
    return super
        .internalConstraints(
            horizontalFit: horizontalFit, verticalFit: verticalFit)
        .union(const BoxConstraintsModel(minWidth: 2, minHeight: 2));
  }

  @override
  EdgeInsetsModel minimumPadding() {
    final double stroke = (properties is MaterialLoadingIndicatorProperties
        ? (properties as MaterialLoadingIndicatorProperties).strokeWidth / 2
        : 0);

    return EdgeInsetsModel.all(stroke);
  }
}

/// Holds configurable properties of the loading indicator.
abstract class LoadingIndicatorProperties extends CustomProperties
    with FieldsHolder {
  /// Type of the loading indicator
  // TODO: how to support this for dynamic settings?
  late final String type;

  /// Creates a [LoadingIndicatorProperties].
  LoadingIndicatorProperties();

  /// Whether this represents properties for a material loading indicator.
  bool get isMaterial => this is MaterialLoadingIndicatorProperties;

  /// Whether this represents properties for a cupertino loading indicator.
  bool get isCupertino => this is CupertinoLoadingIndicatorProperties;

  /// Casts this to [MaterialLoadingIndicatorProperties].
  MaterialLoadingIndicatorProperties asMaterial() =>
      this as MaterialLoadingIndicatorProperties;

  /// Casts this to [CupertinoLoadingIndicatorProperties].
  CupertinoLoadingIndicatorProperties asCupertino() =>
      this as CupertinoLoadingIndicatorProperties;

  /// Creates a [LoadingIndicatorProperties] from a JSON data.
  factory LoadingIndicatorProperties.fromJson(Map json) {
    switch (json['type']) {
      case 'cupertino':
        return CupertinoLoadingIndicatorProperties.fromJson(json);
      case 'material':
        return MaterialLoadingIndicatorProperties.fromJson(json);
      default:
        throw Exception('Unknown type: ${json['type']}');
    }
  }
}

/// Holds configurable properties of a material loading indicator.
/// Refer to Flutter's [CircularProgressIndicator](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html)
/// for more information.
@JsonSerializable()
class MaterialLoadingIndicatorProperties extends LoadingIndicatorProperties
    with FieldsHolder {
  @override
  final String type = 'material';

  /// Color of the loading indicator.
  ColorRGBA color;

  /// Background color of the loading indicator.
  ColorRGBA backgroundColor;

  /// Thickness of the loading indicator.
  double strokeWidth;

  /// Progress of the loading indicator.
  double? value;

  /// Stroke cap of the loading indicator.
  StrokeCapEnum strokeCap;

  /// Creates a new [MaterialLoadingIndicatorProperties].
  MaterialLoadingIndicatorProperties({
    required this.color,
    this.backgroundColor = ColorRGBA.transparent,
    this.strokeWidth = 4,
    this.value,
    this.strokeCap = StrokeCapEnum.square,
  });

  /// Duplicates this [MaterialLoadingIndicatorProperties] with given data
  /// overrides.
  MaterialLoadingIndicatorProperties copyWith({
    ColorRGBA? color,
    ColorRGBA? backgroundColor,
    double? strokeWidth,
    double? value,
    StrokeCapEnum? strokeCap,
  }) {
    return MaterialLoadingIndicatorProperties(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      value: value ?? this.value,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      strokeCap: strokeCap ?? this.strokeCap,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'color': ColorFieldAccess<ColorRGBA>(
          'Color',
          'Color of the loading indicator.',
          () => color,
          (value) => color = value,
        ),
        'backgroundColor': ColorFieldAccess<ColorRGBA>(
          'Background Color',
          'Background color of the loading indicator.',
          () => backgroundColor,
          (value) => backgroundColor = value,
        ),
        'strokeWidth': NumFieldAccess<double>(
          'Stroke Width',
          'Thickness of the loading indicator.',
          () => strokeWidth,
          (value) => strokeWidth = value,
        ),
        'strokeCap': EnumFieldAccess<StrokeCapEnum>(
          'Stroke Cap',
          'Stroke cap of the loading indicator.',
          () => strokeCap,
          (value) => strokeCap = value,
          defaultValue: () => StrokeCapEnum.square,
          options: () => StrokeCapEnum.values,
        ),
      };

  @override
  List<Object?> get props =>
      [type, color, strokeWidth, value, backgroundColor, strokeCap];

  @override
  Map<String, dynamic> toJson() =>
      _$MaterialLoadingIndicatorPropertiesToJson(this);

  /// Creates a [MaterialLoadingIndicatorProperties] from a JSON data.
  factory MaterialLoadingIndicatorProperties.fromJson(Map json) =>
      _$MaterialLoadingIndicatorPropertiesFromJson(json);
}

/// Holds configurable properties of a cupertino loading indicator.
/// Refer to Flutter's [CupertinoActivityIndicator](https://api.flutter.dev/flutter/cupertino/CupertinoActivityIndicator-class.html)
/// for more information.
@JsonSerializable()
class CupertinoLoadingIndicatorProperties extends LoadingIndicatorProperties
    with FieldsHolder {
  @override
  final String type = 'cupertino';

  /// Color of the loading indicator.
  ColorRGBA color;

  /// Radius of the loading indicator.
  double radius;

  /// Creates a new [CupertinoLoadingIndicatorProperties].
  CupertinoLoadingIndicatorProperties({
    required this.color,
    this.radius = 10,
  });

  /// Duplicate this [CupertinoLoadingIndicatorProperties] with given data
  /// overrides.
  CupertinoLoadingIndicatorProperties copyWith({
    ColorRGBA? color,
    double? radius,
  }) {
    return CupertinoLoadingIndicatorProperties(
      color: color ?? this.color,
      radius: radius ?? this.radius,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'color': ColorFieldAccess<ColorRGBA>(
          'Color',
          'Color of the loading indicator.',
          () => color,
          (value) => color = value,
        ),
        'radius': NumFieldAccess<double>(
          'Radius',
          'Radius of the loading indicator.',
          () => radius,
          (value) => radius = value,
        ),
      };

  @override
  List<Object?> get props => [type, color, radius];

  @override
  Map<String, dynamic> toJson() =>
      _$CupertinoLoadingIndicatorPropertiesToJson(this);

  /// Creates a [CupertinoLoadingIndicatorProperties] from a JSON data.
  factory CupertinoLoadingIndicatorProperties.fromJson(Map json) =>
      _$CupertinoLoadingIndicatorPropertiesFromJson(json);
}
