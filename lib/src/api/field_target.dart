import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'field_target.g.dart';

/// A class that represents a single field or a collection of fields to be
/// accessed dynamically by a [FieldsHolder].
@JsonSerializable(explicitToJson: true, createFactory: false)
sealed class FieldTarget with EquatableMixin {
  /// A user-facing label of the field.
  final String label;

  /// A user-facing description of the field.
  final String description;

  /// Determines the real type of this field target. Eg: double, int, text,
  /// color, radius, etc...
  /// 'group' is used to represent a group of fields.
  final String type;

  FieldTarget({
    required this.label,
    required this.description,
    required this.type,
  });

  /// Converts this object to a JSON-serializable map.
  Map<String, dynamic> toJson();

  factory FieldTarget.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'group') {
      return GroupOfFieldTargets.fromJson(json);
    } else if (json['target'] != null) {
      return SingleFieldTarget.fromJson(json);
    } else {
      return MultiFieldTarget.fromJson(json);
    }
  }
}

/// A single field target that targets a single node. Represents a single
/// field that can be accessed dynamically by a [FieldsHolder], and targets
/// a single node with that particular field.
@JsonSerializable()
final class SingleFieldTarget extends FieldTarget {
  /// A json-path to the target field of a particular node.
  /// eg. `my_node_id.fills.2.color`
  /// eg. `properties.thumbShape.size`
  final String target;

  /// The default value of the target field. If the target field is to be
  /// reset, this value can be used to represent a default state.
  final Object? defaultValue;

  /// Supplementary data that can be used to provide additional information
  /// about the field, such as constraints, regex input pattern, min/max
  /// ranges, enum options, etc...
  ///
  /// This is used by the dynamic settings panel to provide a more comprehensive
  /// and exhaustive user experience.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic>? extras;

  /// Creates a [SingleFieldTarget] with the given values.
  SingleFieldTarget({
    required super.label,
    required super.description,
    required super.type,
    required this.target,
    required this.defaultValue,
    this.extras,
  });

  /// Converts this object to a JSON-serializable map.
  factory SingleFieldTarget.fromJson(Map<String, dynamic> json) =>
      _$SingleFieldTargetFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$SingleFieldTargetToJson(this),
        // Forcefully flatten the extras map instead of nesting it as a field
        // in the json output.
        ...?extras,
      };

  @override
  List<Object?> get props => [label, description, type, target, defaultValue];
}

/// A single field target that targets multiple nodes. Represents a single
/// field that can be accessed dynamically by a [FieldsHolder], and targets
/// multiple nodes with that particular field.
///
/// Example: A field target that targets the a color property of multiple nodes
/// at a time. One color field may be in a fills array at index 1, while another
/// target may point to a color field in a stroke array at index 0.
///
/// The field can only support a single field type.
@JsonSerializable()
final class MultiFieldTarget extends FieldTarget {
  /// A list of json-paths to the target fields of multiple nodes.
  /// Example:
  /// [
  ///   "0RhPTVSn0wBWIz4f2Uzd.fills.0.color",
  ///   "24RhPTVSn0wBWIz4f2Uz.strokes.2.color",
  /// ]
  final List<String> targets;

  /// Creates a [MultiFieldTarget] with the given values.
  MultiFieldTarget({
    required super.label,
    required super.description,
    required super.type,
    required this.targets,
  });

  /// Converts this object to a JSON-serializable map.
  factory MultiFieldTarget.fromJson(Map<String, dynamic> json) =>
      _$MultiFieldTargetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MultiFieldTargetToJson(this);

  @override
  List<Object?> get props => [label, description, type, targets];
}

/// A group of field targets. Represents a group of fields that can be accessed
/// dynamically by a [FieldsHolder].
///
/// This is useful in the settings panel ui, where a group of fields can be
/// displayed together under a single section in an intuitive manner.
///
/// Example: A group of fields that represent the properties of a shape node.
/// The group may contain fields for the fill color, stroke color, stroke width,
/// corner radius, etc... Meanwhile, another group may represent the properties
/// of a text node, containing fields for the font size, font family,
/// font color, etc...
@JsonSerializable()
final class GroupOfFieldTargets extends FieldTarget {
  /// A list of field targets that are part of this group.
  ///
  /// Example:
  ///   {
  ///     "type": "group",
  ///     "label": "Range",
  ///     "properties": [
  ///       {
  ///         "label": "enabled",
  ///         "key": "enabled",
  ///         ...
  ///       },
  ///       {
  ///         "label": "Splash Radius",
  ///         "key": "properties.splashRadius",
  ///         ...
  ///       },
  ///       {
  ///         "label": "Color",
  ///         "key": "properties.activeTickMarkColor",
  ///         ...
  ///       },
  ///       {
  ///         "label": "Thumb Size",
  ///         "target": "properties.thumbShape.size",
  ///         ...
  ///       }
  ///     ]
  ///   }
  final List<FieldTarget> properties;

  /// Creates a [GroupOfFieldTargets] with the given values.
  GroupOfFieldTargets({
    required super.label,
    required super.description,
    required this.properties,
  }) : super(type: 'group');

  /// Converts this object to a JSON-serializable map.
  factory GroupOfFieldTargets.fromJson(Map<String, dynamic> json) =>
      _$GroupOfFieldTargetsFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        // Optimized out by codelessly_json_annotation.
        'type': type,
        ..._$GroupOfFieldTargetsToJson(this),
      };

  @override
  List<Object?> get props => [label, description, type, properties];
}
