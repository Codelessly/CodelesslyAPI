import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';
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
@FlutterNode('CodelesslyVariance', family: 'codelessly', nodeType: 'variance')
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
  List<String> get children => childrenOf(currentVariant);

  /// The children [variant] shows: its own, or the default variant's when it
  /// only overrides their properties.
  List<String> childrenOf(Variant variant) => variant.sharesDefaultChildren
      ? defaultVariant.children
      : variant.children;

  /// Get all the children from all the variants.
  List<String> get allVariantsChildren =>
      variants.expand((e) => e.children).toList();

  /// Get all the children from all the variants except the currently loaded
  /// variant (and the default variant's, when the current variant shows
  /// them with overrides).
  List<String> get unloadedVariantsChildren {
    final Set<String> loaded = childrenOf(currentVariant).toSet();
    return variants
        .where((element) => element.id != currentVariantId)
        .expand((e) => e.children)
        .where((id) => !loaded.contains(id))
        .toList();
  }

  /// Whether this node is a responsive layout: its variants map to screen
  /// breakpoints ([Variant.breakpoint]) and the one shown follows the width of
  /// the canvas it is on, instead of [currentVariantId] or a variable.
  bool get isResponsive =>
      variants.any((variant) => variant.breakpoint != null);

  /// The variant mapped to [breakpoint], or the nearest one when none is:
  /// the variant whose breakpoint is fewest steps away, the smaller one on a
  /// tie (a narrower layout fits a wider screen better than the reverse).
  /// Null when no variant has a breakpoint.
  Variant? variantForBreakpoint(ScreenBreakpoint breakpoint) {
    Variant? best;
    int bestDistance = 1 << 30;
    for (final Variant variant in variants) {
      final ScreenBreakpoint? own = variant.breakpoint;
      if (own == null) continue;
      final int distance = (own.index - breakpoint.index).abs();
      if (distance < bestDistance ||
          (distance == bestDistance && own.index < best!.breakpoint!.index)) {
        best = variant;
        bestDistance = distance;
      }
    }
    return best;
  }

  /// The variant a responsive node shows on a canvas [width] wide, or the
  /// current variant when the node is not responsive.
  Variant variantForWidth(double width) =>
      variantForBreakpoint(ScreenBreakpoint.forWidth(width)) ?? currentVariant;

  /// Whether this node shows the status of a cloud list: it has a variant
  /// with the id of a query status ([kQueryStatusLoading],
  /// [kQueryStatusEmpty] or [kQueryStatusError]), and its current variant is
  /// bound to the list's status variable.
  bool get isQueryStatus => variants.any(
    (variant) => const {
      kQueryStatusLoading,
      kQueryStatusEmpty,
      kQueryStatusError,
    }.contains(variant.id),
  );

  /// The variant that is loaded by default.
  Variant get defaultVariant =>
      variants.firstWhereOrNull((e) => e.id == 'default') ?? variants.first;

  @override
  set children(List<String> value) {
    if (variants.isEmpty) return;
    final Variant variant = currentVariant;
    (variant.sharesDefaultChildren ? defaultVariant : variant).children = value;
  }

  /// Currently loaded variant's ID.
  @FlutterProp('currentVariantId', type: 'string', group: 'State', control: 'text')
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
  }) : assert(variants.isNotEmpty),
       currentVariantId = currentVariantId ?? variants[0].id,
       properties = properties ?? const VarianceProperties(),
       super(children: [], allowedTypes: [], deniedTypes: [], ephemeral: false);

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'currentVariantId': VariantAccess(
      'Variant',
      'Select a variant to load',
      () => currentVariant.name,
      (String name) {
        final String? newId = variants
            .firstWhereOrNull((e) => e.name == name)
            ?.id;
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
  Map toJson() => _$VarianceNodeOmitDefaults(this, _$VarianceNodeToJson(this));
}

/// [Variant] is used in [VarianceNode] to define a variation of the same node.
@JsonSerializable()
class Variant with SerializableMixin, Equatable {
  /// Variant's name, set by user.
  String name;

  /// ID is used to identify and switch variants.
  String id;

  /// All the child nodes' IDs that the variant contains.
  List<String> children;

  /// The screen breakpoint this variant is the layout for, when its
  /// [VarianceNode] is responsive. Null for an ordinary state.
  ScreenBreakpoint? breakpoint;

  /// When not null, this variant is a property-override state: it shows the
  /// default variant's children with these property changes (node id to a
  /// sparse patch of that node) instead of a copy of them, and its own
  /// [children] stay empty.
  PropertyOverrides? overrides;

  /// Whether this variant overrides the default variant's properties instead
  /// of holding its own copy of the children.
  bool get isOverride => overrides != null;

  /// Whether this variant shows the default variant's children as a
  /// shimmering skeleton (for a loading state) instead of its own children.
  @JsonKey(defaultValue: false)
  bool skeleton;

  /// Whether this variant shows the default variant's children rather than
  /// its own: it overrides their properties or shows them as a skeleton.
  bool get sharesDefaultChildren => isOverride || skeleton;

  /// Creates a [Variant] instance with the given data.
  Variant({
    required this.id,
    required this.name,
    required this.children,
    this.breakpoint,
    this.overrides,
    this.skeleton = false,
  });

  /// The name to show for this variant: its breakpoint's label when it has
  /// one, otherwise its [name].
  String get label => breakpoint?.label ?? name;

  @override
  List<Object?> get props => [
    id,
    name,
    children,
    breakpoint,
    overrides,
    skeleton,
  ];

  @override
  Map toJson() => _$VariantOmitDefaults(this, _$VariantToJson(this));

  /// Creates a [Variant] instance from a JSON object.
  factory Variant.fromJson(Map json) => _$VariantFromJson(json);
}

/// [VarianceProperties] is used to store custom properties of a [VarianceNode].
@JsonSerializable()
class VarianceProperties extends CustomProperties {
  /// Creates a [VarianceProperties] instance with the given data.
  const VarianceProperties();

  @override
  Map<String, dynamic> toJson() =>
      _$VariancePropertiesOmitDefaults(this, _$VariancePropertiesToJson(this));

  /// Creates a [VarianceProperties] instance from a JSON object.
  factory VarianceProperties.fromJson(Map<String, dynamic> json) =>
      _$VariancePropertiesFromJson(json);

  @override
  List<Object?> get props => [];
}
