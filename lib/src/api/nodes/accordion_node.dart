import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'accordion_node.g.dart';

/// An accordion is a type of menu that displays a list of headers stacked on
/// top of one another. When clicked on (or triggered by a keyboard interaction
/// or screen reader), these headers will either reveal or hide associated
/// content.
@JsonSerializable()
class AccordionNode extends SceneNode
    with ChildrenMixin, RowColumnMixin, CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'accordion';

  @override
  covariant AccordionProperties properties;

  /// Creates a new [AccordionNode] instance.
  AccordionNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    RowColumnType rowColumnType = RowColumnType.column,
    MainAxisAlignmentC mainAxisAlignment = MainAxisAlignmentC.center,
    CrossAxisAlignmentC crossAxisAlignment = CrossAxisAlignmentC.center,
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
    required List<String> children,
    bool? isExpanded,
    super.variables,
    super.multipleVariables,
    AccordionProperties? properties,
  }) : properties =
            properties ?? AccordionProperties(isExpanded: isExpanded ?? true) {
    setChildrenMixin(children: children);
    setRowColumnMixin(
      rowColumnType: rowColumnType,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'properties': ObjectFieldAccess<AccordionProperties>(
          'Properties',
          'Properties of the accordion',
          () => properties,
          (value) => properties = value,
        ),
      };

  /// Creates a [AccordionNode] from a JSON data.
  factory AccordionNode.fromJson(Map json) => _$AccordionNodeFromJson(json);

  @override
  Map toJson() => _$AccordionNodeToJson(this);
}

/// Custom properties for an [AccordionNode].
@JsonSerializable()
class AccordionProperties extends CustomProperties with FieldsHolder {
  /// Whether the accordion is expanded or collapsed.
  bool isExpanded;

  /// Creates a new [AccordionProperties] instance.
  AccordionProperties({
    this.isExpanded = true,
  });

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'isExpanded': BoolFieldAccess(
          'Is Expanded',
          'Whether the accordion is expanded or collapsed',
          () => isExpanded,
          (value) => isExpanded = value,
        ),
      };

  @override
  Map<String, dynamic> toJson() => _$AccordionPropertiesToJson(this);

  /// Creates a [AccordionProperties] from a JSON data.

  factory AccordionProperties.fromJson(Map json) =>
      _$AccordionPropertiesFromJson(json);

  @override
  List<Object?> get props => [isExpanded];
}
