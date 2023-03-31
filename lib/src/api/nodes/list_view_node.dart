import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../models/models.dart';
import 'divider_node.dart';
import 'single_placeholder_node.dart';

part 'list_view_node.g.dart';

/// A material design [ListView].
/// Refer to [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) in Flutter for more details.
@JsonSerializable()
class ListViewNode extends SinglePlaceholderNode
    with
        ScrollableMixin,
        CustomPropertiesMixin,
        VariablePropertiesMixin,
        ClipMixin {
  @override
  final String type = 'listView';

  @override
  final bool supportsPadding = true;

  @override
  bool get isScrollingEnforced => true;

  /// The properties of the [ListView].
  ListViewProperties properties;

  /// Creates a [ListViewNode].
  ListViewNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
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
    super.parentID,
    super.reactions,
    required this.properties,
    required List<String> children,
    Map<String, String>? variables,
    bool clipsContent = true,
    // scrollable
    AxisC scrollDirection = AxisC.vertical,
    bool reverse = false,
    ScrollPhysicsC physics = ScrollPhysicsC.alwaysScrollableScrollPhysics,
    bool primary = false,
    ScrollViewKeyboardDismissBehaviorC keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehaviorC.manual,
  }) : super(children: [], allowedTypes: [], deniedTypes: []) {
    setChildrenMixin(children: children);
    setVariablesMixin(variables: variables);
    setClipMixin(clipsContent: clipsContent);

    setScrollableMixin(
      isScrollable: true,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      primary: primary,
      shrinkWrap: false,
      keyboardDismissBehavior: keyboardDismissBehavior,
      useFlutterListView: true,
    );
  }

  /// Creates a [ListViewNode] from a JSON object.
  factory ListViewNode.fromJson(Map json) => _$ListViewNodeFromJson(json);

  @override
  Map toJson() => _$ListViewNodeToJson(this);

  AlignmentModel childAlignment() {
    switch (scrollDirection) {
      case AxisC.horizontal:
        return reverse ? AlignmentModel.centerRight : AlignmentModel.centerLeft;
      case AxisC.vertical:
        return reverse ? AlignmentModel.bottomCenter : AlignmentModel.topCenter;
    }
  }
}

enum ListItemSeparator {
  divider,
  space;
}

@JsonSerializable()
class ListViewProperties with SerializableMixin, EquatableMixin {
  int? itemCount;
  double? itemExtent;
  double? cacheExtent;
  double separatorSpacing;
  ListItemSeparator separator;
  bool hasSeparator;
  DividerProperties dividerProperties;

  ListViewProperties({
    this.itemCount,
    this.itemExtent,
    this.cacheExtent,
    this.separator = ListItemSeparator.space,
    this.separatorSpacing = 0,
    this.hasSeparator = false,
    DividerProperties? dividerProperties,
  }) : dividerProperties = dividerProperties ?? DividerProperties();

  ListViewProperties copyWith({
    String? bodyId,
    int? itemCount,
    ScrollPhysicsC? physics,
    AxisC? scrollDirection,
    double? itemExtent,
    double? cacheExtent,
    bool? reverse,
    ListItemSeparator? separator,
    double? separatorSpacing,
    double? dividerThickness,
    ColorRGBA? dividerColor,
    double? dividerSpacing,
    bool? hasSeparator,
    DividerProperties? dividerProperties,
  }) {
    return ListViewProperties(
      itemCount: itemCount ?? this.itemCount,
      itemExtent: itemExtent ?? this.itemExtent,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      separator: separator ?? this.separator,
      separatorSpacing: separatorSpacing ?? this.separatorSpacing,
      hasSeparator: hasSeparator ?? this.hasSeparator,
      dividerProperties: dividerProperties ?? this.dividerProperties,
    );
  }

  @override
  Map toJson() => _$ListViewPropertiesToJson(this);

  factory ListViewProperties.fromJson(Map json) =>
      _$ListViewPropertiesFromJson(json);

  @override
  List<Object?> get props => [
    itemCount,
    itemExtent,
    cacheExtent,
    separator,
    separatorSpacing,
    hasSeparator,
    dividerProperties,
  ];
}
