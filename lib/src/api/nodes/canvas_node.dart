import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'canvas_node.g.dart';

/// Represents a canvas or a screen.
@JsonSerializable()
class CanvasNode extends ParentNode
    with
        RowColumnMixin,
        IsolatedMixin,
        ScrollableMixin,
        CustomPropertiesMixin,
        ParentReactionMixin {
  @override
  final String type = 'canvas';

  @override
  final bool supportsPadding = true;

  @override
  bool get supportsMargin => false;

  @override
  bool get supportsRotation => false;

  /// Time of creation.
  @DateTimeConverter()
  late DateTime createdTimestamp;

  /// Holds configurable properties for the canvas.
  CanvasProperties properties;

  /// Type of scaling for the canvas responsiveness.
  ScaleMode scaleMode;

  /// Whether this canvas is a scaffold.
  bool get isAScaffold => properties.isAScaffold;

  @override
  List<TriggerType> get triggerTypes => [TriggerType.load];

  @override
  List<ReactionMixin> get reactiveChildren =>
      properties.floatingActionButton != null
          ? [properties.floatingActionButton!]
          : [];

  /// Creates a new [CanvasNode] with given data.
  CanvasNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required super.children,
    super.outerBoxLocal,
    RowColumnType rowColumnType = RowColumnType.column,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
    this.scaleMode = ScaleMode.autoScale,
    super.retainedOuterBoxLocal,
    super.visible,
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
    super.opacity,
    super.isMask,
    super.effects,
    super.blendMode,
    List<PaintModel>? fills,
    super.strokes,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    super.dashPattern,
    super.strokeSide,
    super.reactions,
    super.parentID,
    DateTime? createdTimestamp,
    super.clipsContent,

    // [ScrollableMixin] properties.
    bool isScrollable = false,
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
    bool shouldAlwaysScroll = true,

    // Custom properties.
    required this.properties,
    Map<String, String>? variables,
  }) : super(fills: fills ?? [PaintModel.whitePaint]) {
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
    setVariablesMixin(variables: variables);

    this.createdTimestamp = createdTimestamp ?? DateTime.now();

    setScrollableMixin(
      isScrollable: isScrollable,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: shrinkWrap,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: useFlutterListView,
      shouldAlwaysScroll: shouldAlwaysScroll,
    );
  }

  @override
  void onChildIDChanged(String oldID, String newID) {
    if (properties.bodyId == oldID) {
      properties.bodyId = newID;
    }
    if (properties.navigationBarPlaceholderId == oldID) {
      properties.navigationBarPlaceholderId = newID;
    }

    if (properties.topAppBarPlaceholderId == oldID) {
      properties.topAppBarPlaceholderId = newID;
    }
  }

  /// Checks if a node is symbiotic with its canvas, ie the node acts as the
  /// canvas's body or navigation bar or top app bar.
  bool isNodeAttachedToCanvas(String nodeID) =>
      properties.bodyId == nodeID ||
      properties.navigationBarPlaceholderId == nodeID ||
      properties.topAppBarPlaceholderId == nodeID;

  /// Creates a new [CanvasNode] from a JSON data.
  factory CanvasNode.fromJson(Map json) => _$CanvasNodeFromJson(json);

  @override
  Map toJson() => _$CanvasNodeToJson(this);

  @override
  List<Object?> get props => [
        ...super.props,
        id,
        name,
        rowColumnType,
        mainAxisAlignment,
        crossAxisAlignment
      ];
}

/// Holds configurable properties for the canvas.
@JsonSerializable()
class CanvasProperties with SerializableMixin, EquatableMixin {
  /// ID of the body node.
  String bodyId;

  /// ID of the navigation bar placeholder node.
  String? navigationBarPlaceholderId;

  /// ID of the top app bar placeholder node.
  String? topAppBarPlaceholderId;

  /// FAB properties if enabled.
  FloatingActionButtonProperties? floatingActionButton;

  /// Safe area properties.
  SafeAreaModel safeArea;

  /// The brightness of the system UI.
  BrightnessModel brightness;

  /// Whether this canvas is a scaffold. A scaffold can hold an app bar, drawer,
  /// bottom navigation bar, and floating action button. If any of this is
  /// present, the canvas is a scaffold.
  bool get isAScaffold =>
      navigationBarPlaceholderId != null ||
      topAppBarPlaceholderId != null ||
      floatingActionButton != null;

  /// Creates a new [CanvasProperties] with given data.
  CanvasProperties({
    required this.bodyId,
    this.navigationBarPlaceholderId,
    this.topAppBarPlaceholderId,
    this.floatingActionButton,
    this.safeArea = const SafeAreaModel.all(true),
    this.brightness = BrightnessModel.system,
  });

  /// Checks if a node is symbiotic with its canvas, ie the node acts as the
  /// canvas's body or navigation bar or top app bar.
  bool isNodeAttachedToCanvas(String nodeID) =>
      bodyId == nodeID ||
      navigationBarPlaceholderId == nodeID ||
      topAppBarPlaceholderId == nodeID;

  @override
  List<Object?> get props => [
        navigationBarPlaceholderId,
        topAppBarPlaceholderId,
        floatingActionButton,
        safeArea,
        brightness,
      ];

  /// Creates a new [CanvasProperties] from a JSON data.
  factory CanvasProperties.fromJson(Map json) =>
      _$CanvasPropertiesFromJson(json);

  @override
  Map toJson() => _$CanvasPropertiesToJson(this);
}
