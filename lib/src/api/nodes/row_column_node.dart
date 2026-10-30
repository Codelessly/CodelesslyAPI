import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';

part 'row_column_node.g.dart';

/// Shared layout behavior for Flutter [Row] and [Column] nodes.
@JsonSerializable()
class RowColumnNode extends ParentNode
    with RowColumnMixin, ScrollableMixin, CornerMixin {
  @override
  @JsonKey(includeFromJson: false)
  String get type => switch (rowColumnType) {
    RowColumnType.row => 'row',
    RowColumnType.column => 'column',
  };

  @override
  final bool supportsPadding = true;

  /// A row/column scrolls along its main axis. One that [wrap]s scrolls
  /// along its cross axis instead, through its runs: its main axis is where
  /// it wraps, so it needs a bounded extent there.
  @JsonKey(includeFromJson: false)
  @override
  AxisC get scrollDirection => (rowColumnType == RowColumnType.row) != wrap
      ? AxisC.horizontal
      : AxisC.vertical;

  @override
  set scrollDirection(AxisC value) {}

  /// Whether this node wraps its children into runs: [wrap] is on and it is
  /// a row.
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get wrapsChildren => wrap && rowColumnType == RowColumnType.row;

  /// Creates a [RowColumnNode] with the given data.
  RowColumnNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    required super.children,
    required RowColumnType rowColumnType,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
    double spacing = 0,
    bool wrap = false,
    double runSpacing = 0,
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
    super.opacity,
    super.isMask,
    super.effects,
    super.blendMode,
    super.fills,
    super.strokes,
    super.strokeWeight,
    super.strokeMiterLimit,
    super.strokeAlign,
    super.strokeCap,
    super.dashPattern,
    super.strokeSide,
    super.reactions,
    super.parentID,
    super.clipsContent = false,
    // [CornerMixin] properties.
    CornerRadius cornerRadius = CornerRadius.zero,
    double cornerSmoothing = 0,
    // [ScrollableMixin] properties.
    bool isScrollable = false,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.platformDependent,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,
    bool shouldAlwaysScroll = true,
  }) {
    setCornerMixin(
      cornerRadius: cornerRadius,
      cornerSmoothing: cornerSmoothing,
    );

    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      wrap: wrap,
      runSpacing: runSpacing,
    );

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

  /// Rows and columns are the usual buttons and cards of a layout, so they
  /// take taps, long presses and holds.
  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.click,
    TriggerType.longPress,
    TriggerType.hold,
  ];

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'wrap': BoolFieldAccess(
      'Wrap',
      'Whether a row starts a new line when its children do not fit.',
      () => wrap,
      (value) => wrap = value,
      defaultValue: () => false,
      requiresLayout: true,
    ),
    'spacing': NumFieldAccess<double>(
      'Spacing',
      'Gap between consecutive children along the main axis; between children of a run when wrapping.',
      () => spacing,
      (value) => spacing = value,
      min: 0,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
    'runSpacing': NumFieldAccess<double>(
      'Run Spacing',
      'Gap between runs along the cross axis when wrapping.',
      () => runSpacing,
      (value) => runSpacing = value,
      min: 0,
      defaultValue: () => 0,
      requiresLayout: true,
    ),
  };

  /// Creates a [RowColumnNode] from a canonical row or column wire value.
  factory RowColumnNode.fromJson(Map json) {
    final kind = switch (json['type']) {
      'row' => RowColumnType.row,
      'column' => RowColumnType.column,
      _ => throw FormatException('Unknown row/column wire type: ${json['type']}'),
    };
    if (json['rowColumnType'] != null && json['rowColumnType'] != kind.name) {
      throw FormatException('Conflicting row/column axis: ${json['rowColumnType']}');
    }
    final value = _$RowColumnNodeFromJson({...json, 'rowColumnType': kind.name});
    return kind == RowColumnType.row
        ? RowNode.fromRowColumn(value)
        : ColumnNode.fromRowColumn(value);
  }

  /// Returns a new concrete Flutter class for a changed layout axis.
  /// No retired wire value is decoded or inferred from child shape.
  RowColumnNode withAxis(RowColumnType axis) => RowColumnNode.fromJson({
    ...toJson(), 'type': axis.name, 'rowColumnType': axis.name,
  });

  @override
  Map toJson() {
    if ((this is RowNode && rowColumnType != RowColumnType.row) ||
        (this is ColumnNode && rowColumnType != RowColumnType.column)) {
      throw StateError('Row/Column class identity cannot change in place');
    }
    return _$RowColumnNodeOmitDefaults(this, _$RowColumnNodeToJson(this))
      ..['type'] = type;
  }
}

/// Flutter's horizontal [Row] with an immutable row wire identity.
@FlutterNode('Row', family: 'widgets', nodeType: 'row')
class RowNode extends RowColumnNode {
  /// Creates a row with shared row/column layout properties.
  RowNode({required super.id, required super.name, required super.basicBoxLocal,
    required super.children, super.mainAxisAlignment, super.crossAxisAlignment,
    super.spacing, super.wrap, super.runSpacing,
    super.outerBoxLocal, super.retainedOuterBoxLocal, super.visible, super.enabled,
    super.rotationDegrees, super.alignment, super.margin, super.padding,
    super.horizontalFit, super.verticalFit, super.flex, super.constraints,
    super.edgePins, super.aspectRatioLock, super.positioningMode, super.opacity,
    super.isMask, super.effects, super.blendMode, super.fills, super.strokes,
    super.strokeWeight, super.strokeMiterLimit, super.strokeAlign, super.strokeCap,
    super.dashPattern, super.strokeSide, super.reactions, super.parentID,
    super.clipsContent, super.cornerRadius, super.cornerSmoothing,
    super.isScrollable, super.reverse, super.physics, super.primary,
    super.shrinkWrap, super.keyboardDismissBehavior,
    super.useFlutterListView, super.shouldAlwaysScroll})
      : super(rowColumnType: RowColumnType.row);

  /// Restores a row from canonical JSON.
  factory RowNode.fromJson(Map json) {
    if (json['type'] != 'row') throw const FormatException('Expected row wire type');
    return RowColumnNode.fromJson(json) as RowNode;
  }

  RowNode.fromRowColumn(RowColumnNode source)
    : super(id: source.id, name: source.name, basicBoxLocal: source.basicBoxLocal,
      children: source.childrenOrEmpty, rowColumnType: RowColumnType.row,
      mainAxisAlignment: source.mainAxisAlignment,
      crossAxisAlignment: source.crossAxisAlignment,
      spacing: source.spacing, wrap: source.wrap, runSpacing: source.runSpacing,
      visible: source.visible, enabled: source.enabled,
      rotationDegrees: source.rotationDegrees, alignment: source.alignment,
      margin: source.margin, padding: source.padding,
      horizontalFit: source.horizontalFit, verticalFit: source.verticalFit,
      flex: source.flex, constraints: source.constraints,
      edgePins: source.edgePins, aspectRatioLock: source.aspectRatioLock,
      positioningMode: source.positioningMode, opacity: source.opacity,
      isMask: source.isMask, effects: source.effects, blendMode: source.blendMode,
      fills: source.fills, strokes: source.strokes,
      strokeWeight: source.strokeWeight, strokeMiterLimit: source.strokeMiterLimit,
      strokeAlign: source.strokeAlign, strokeCap: source.strokeCap,
      dashPattern: source.dashPattern, strokeSide: source.strokeSide,
      reactions: source.reactions, clipsContent: source.clipsContent,
      cornerRadius: source.cornerRadius, cornerSmoothing: source.cornerSmoothing,
      isScrollable: source.isScrollable, reverse: source.reverse,
      physics: source.physics, primary: source.primary,
      keyboardDismissBehavior: source.keyboardDismissBehavior,
      useFlutterListView: source.useFlutterListView,
      shouldAlwaysScroll: source.shouldAlwaysScroll) {
    _copyRowState(source, this);
  }
}

/// Flutter's vertical [Column] with an immutable column wire identity.
@FlutterNode('Column', family: 'widgets', nodeType: 'column')
class ColumnNode extends RowColumnNode {
  /// Creates a column with shared row/column layout properties.
  ColumnNode({required super.id, required super.name, required super.basicBoxLocal,
    required super.children, super.mainAxisAlignment, super.crossAxisAlignment,
    super.spacing, super.wrap, super.runSpacing,
    super.outerBoxLocal, super.retainedOuterBoxLocal, super.visible, super.enabled,
    super.rotationDegrees, super.alignment, super.margin, super.padding,
    super.horizontalFit, super.verticalFit, super.flex, super.constraints,
    super.edgePins, super.aspectRatioLock, super.positioningMode, super.opacity,
    super.isMask, super.effects, super.blendMode, super.fills, super.strokes,
    super.strokeWeight, super.strokeMiterLimit, super.strokeAlign, super.strokeCap,
    super.dashPattern, super.strokeSide, super.reactions, super.parentID,
    super.clipsContent, super.cornerRadius, super.cornerSmoothing,
    super.isScrollable, super.reverse, super.physics, super.primary,
    super.shrinkWrap, super.keyboardDismissBehavior,
    super.useFlutterListView, super.shouldAlwaysScroll})
      : super(rowColumnType: RowColumnType.column);

  /// Restores a column from canonical JSON.
  factory ColumnNode.fromJson(Map json) {
    if (json['type'] != 'column') throw const FormatException('Expected column wire type');
    return RowColumnNode.fromJson(json) as ColumnNode;
  }

  ColumnNode.fromRowColumn(RowColumnNode source)
    : super(id: source.id, name: source.name, basicBoxLocal: source.basicBoxLocal,
      children: source.childrenOrEmpty, rowColumnType: RowColumnType.column,
      mainAxisAlignment: source.mainAxisAlignment,
      crossAxisAlignment: source.crossAxisAlignment,
      spacing: source.spacing, wrap: source.wrap, runSpacing: source.runSpacing,
      visible: source.visible, enabled: source.enabled,
      rotationDegrees: source.rotationDegrees, alignment: source.alignment,
      margin: source.margin, padding: source.padding,
      horizontalFit: source.horizontalFit, verticalFit: source.verticalFit,
      flex: source.flex, constraints: source.constraints,
      edgePins: source.edgePins, aspectRatioLock: source.aspectRatioLock,
      positioningMode: source.positioningMode, opacity: source.opacity,
      isMask: source.isMask, effects: source.effects, blendMode: source.blendMode,
      fills: source.fills, strokes: source.strokes,
      strokeWeight: source.strokeWeight, strokeMiterLimit: source.strokeMiterLimit,
      strokeAlign: source.strokeAlign, strokeCap: source.strokeCap,
      dashPattern: source.dashPattern, strokeSide: source.strokeSide,
      reactions: source.reactions, clipsContent: source.clipsContent,
      cornerRadius: source.cornerRadius, cornerSmoothing: source.cornerSmoothing,
      isScrollable: source.isScrollable, reverse: source.reverse,
      physics: source.physics, primary: source.primary,
      keyboardDismissBehavior: source.keyboardDismissBehavior,
      useFlutterListView: source.useFlutterListView,
      shouldAlwaysScroll: source.shouldAlwaysScroll) {
    _copyRowState(source, this);
  }
}

void _copyRowState(RowColumnNode source, RowColumnNode target) {
  target.variables = source.variables;
  target.multipleVariables = source.multipleVariables;
  target.componentId = source.componentId;
  target.markerType = source.markerType;
  target.componentVersion = source.componentVersion;
  target.componentSchema = source.componentSchema;
  target.squeezable = source.squeezable;
  target.widthFactor = source.widthFactor;
  target.heightFactor = source.heightFactor;
  target.interactionStates = source.interactionStates;
  target.tooltip = source.tooltip;
  target.zoomable = source.zoomable;
  target.loopAnimation = source.loopAnimation;
  target.transitionMs = source.transitionMs;
  target.drawScale = source.drawScale;
  target.pulse = source.pulse;
  target.motion = source.motion;
  target.drag = source.drag;
  target.inkWell = source.inkWell;
  target.transition = source.transition;
}
