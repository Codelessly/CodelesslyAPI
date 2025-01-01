import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'variance_node.g.dart';

/// [VarianceNode] allows the user to create different variants of the same node
/// and switch them based on certain conditions. For example, it can be used to
/// create success and error states of a widget.
@JsonSerializable()
class VarianceNode extends SinglePlaceholderNode with CustomPropertiesMixin {
  @override
  final String type = 'variance';

  @override
  bool get supportsPadding => false;

  @override
  bool get canBeMarked => true;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  List<String> get children => currentVariant.children;

  /// Get all the children from all the variants.
  List<String> get allVariantsChildren =>
      variants.expand((e) => e.children).toList();

  /// Get all the children from all the variants except the currently loaded
  /// variant.
  List<String> get unloadedVariantsChildren => variants
      .where((element) => element.id != currentVariantId)
      .expand((e) => e.children)
      .toList();

  /// The variant that is loaded by default.
  Variant get defaultVariant => variants.firstWhere((e) => e.id == 'default');

  @override
  set children(List<String> value) {
    if (variants.isEmpty) return;
    currentVariant.children = value;
  }

  /// Currently loaded variant's ID.
  late String currentVariantId;

  /// Currently loaded variant.
  Variant get currentVariant =>
      variants.firstWhere((variant) => variant.id == currentVariantId);

  /// All variants of the node.
  List<Variant> variants;

  /// Holds configurable properties of the variance node.
  @override
  covariant VarianceProperties properties;

  /// Creates a [VarianceNode] instance with the given data.
  VarianceNode({
    bool? value,
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required this.variants,
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
    String? currentVariantId,
    super.maxAllowedSize,
    super.variables,
    super.multipleVariables,
    VarianceProperties? properties,
  })  : assert(variants.isNotEmpty),
        currentVariantId = currentVariantId ?? variants[0].id,
        properties = properties ?? const VarianceProperties(),
        super(
          children: [],
          allowedTypes: [],
          deniedTypes: [],
          ephemeral: false,
        );

  @override
  FieldsMap generateFields() => {
        ...super.generateFields(),
        'currentVariantId': VariantAccess(
          'Variant',
          'Select a variant to load',
          () => currentVariant.name,
          (String name) {
            final String? newId =
                variants.firstWhereOrNull((e) => e.name == name)?.id;
            if (newId != null) currentVariantId = newId;
          },
          options: () => variants.map((variant) => variant.name).toList(),
          defaultValue: () => 'default',
        ),
      };

  @override
  void setChildrenMixin({required List<String> children}) {}

  @override
  List<Object?> get props => [
        ...super.props,
        variants,
        properties,
        currentVariantId,
      ];

  /// Creates a [VarianceNode] instance from a JSON object.
  factory VarianceNode.fromJson(Map json) => _$VarianceNodeFromJson(json);

  @override
  Map toJson() => _$VarianceNodeToJson(this);
}

/// [Variant] is used in [VarianceNode] to define a variation of the same node.
@JsonSerializable()
class Variant with SerializableMixin, EquatableMixin {
  /// Variant's name, set by user.
  String name;

  /// ID is used to identify and switch variants.
  String id;

  /// All the child nodes' IDs that the variant contains.
  List<String> children;

  /// Creates a [Variant] instance with the given data.
  Variant({
    required this.id,
    required this.name,
    required this.children,
  });

  @override
  List<Object?> get props => [id, name, children];

  @override
  Map toJson() => _$VariantToJson(this);

  /// Creates a [Variant] instance from a JSON object.
  factory Variant.fromJson(Map json) => _$VariantFromJson(json);
}

/// [VarianceProperties] is used to store custom properties of a [VarianceNode].
@JsonSerializable()
class VarianceProperties extends CustomProperties {
  /// Creates a [VarianceProperties] instance with the given data.
  const VarianceProperties();

  @override
  Map<String, dynamic> toJson() => _$VariancePropertiesToJson(this);

  /// Creates a [VarianceProperties] instance from a JSON object.
  factory VarianceProperties.fromJson(Map<String, dynamic> json) =>
      _$VariancePropertiesFromJson(json);

  @override
  List<Object?> get props => [];
}
