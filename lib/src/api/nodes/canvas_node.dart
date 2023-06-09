// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import '../utils.dart';
import 'nodes.dart';

part 'canvas_node.g.dart';

/// Represents a canvas or a screen.
@JsonSerializable()
class CanvasNode extends ParentNode
    with RowColumnMixin, IsolatedMixin, ScrollableMixin, CustomPropertiesMixin {
  @override
  final String type = 'canvas';

  @override
  final bool supportsPadding = true;

  /// Time of creation.
  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  late DateTime createdTimestamp;

  /// Holds configurable properties for the canvas.
  CanvasProperties properties;

  /// Type of scaling for the canvas responsiveness.
  ScaleMode scaleMode;

  /// Whether this canvas is a scaffold.
  bool get isAScaffold => properties.isAScaffold;

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
    DateTime? createdTimestamp,
    super.clipsContent,

    // [ScrollableMixin] properties.
    bool isScrollable = false,
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.alwaysScrollableScrollPhysics,
    bool primary = true,
    bool shrinkWrap = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
    bool useFlutterListView = false,

    // Custom properties.
    required this.properties,
    Map<String, String>? variables,
  }) {
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
  });

  @override
  List<Object?> get props => [
        navigationBarPlaceholderId,
        topAppBarPlaceholderId,
        floatingActionButton,
      ];

  /// Creates a new [CanvasProperties] from a JSON data.
  factory CanvasProperties.fromJson(Map json) =>
      _$CanvasPropertiesFromJson(json);

  @override
  Map toJson() => _$CanvasPropertiesToJson(this);
}
