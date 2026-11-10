import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';

part 'reorder.g.dart';

/// How a drag of a list item to a new place starts.
enum ReorderStart {
  /// From a node inside the item whose drag has `reorder` set
  /// (`DragModel.reorder`): a ≡ handle.
  handle,

  /// A long press anywhere on the item.
  longPress,

  /// Any press and drag on the item.
  press;

  /// Displayable string representation.
  String get prettify => switch (this) {
    handle => 'Drag handle',
    longPress => 'Long press anywhere',
    press => 'Press anywhere',
  };
}

/// What a reorder (or a swipe action that removes the item) changes on its
/// own, before the list's `reorder` reactions run.
enum ListApply {
  /// Nothing: the reactions store the new order (e.g. with
  /// `${= move(list, result.from, result.to)}`).
  none,

  /// The list variable bound to the list's data, moving the item in it
  /// (and, between lists, from one list's variable to the other's).
  variable,

  /// The documents of the list's cloud query: the moved document's
  /// [ReorderModel.orderField] is set between its new neighbours', and
  /// between lists its [ReorderModel.listField] too.
  cloud;

  /// Displayable string representation.
  String get prettify => switch (this) {
    none => 'Run reactions only',
    variable => 'Update bound list',
    cloud => 'Write order to collection',
  };
}

/// What shows where the dragged item would land.
enum ReorderPlaceholder {
  /// An empty space the size of the item.
  gap,

  /// [ReorderModel.placeholderNodeId], at the size of the item.
  node;

  /// Displayable string representation.
  String get prettify => switch (this) {
    gap => 'Gap',
    node => 'Node',
  };
}

/// Lets the user reorder a list's items by dragging them, within the list
/// and, with a [group], into other lists of the same group (a Kanban board).
///
/// A drop runs the reorder reactions of the list (and of a handle node, as
/// before) with `${result.from}` and `${result.to}` (indexes),
/// `${result.item}` (the moved item's data), and `${result.fromList}` and
/// `${result.toList}` (the lists' [listKey]s). With [apply] the list updates
/// its data itself first.
///
/// It builds on the existing pieces: a handle is a `DragModel` with
/// `reorder` set, and a move between lists is a drag and drop between two
/// lists, each the drop target (`DropTargetModel.listNodeId`) of its own
/// items.
@JsonSerializable()
class ReorderModel with Equatable, SerializableMixin {
  /// Whether items can be reordered now.
  final bool enabled;

  /// How a drag starts.
  @JsonKey(unknownEnumValue: ReorderStart.handle)
  final ReorderStart start;

  /// Lists that share a group can take each other's items; empty to
  /// reorder within this list only.
  final String group;

  /// Identifies this list in `${result.fromList}` and `${result.toList}`:
  /// text with `${...}`, e.g. `${item.id}` for a column in a board of
  /// columns. Defaults to the list's id.
  final String listKey;

  /// A condition evaluated for each item (`${item}`, `${index}`) that must
  /// hold for it to be picked up, e.g. `${= !item.locked}`. Empty for all.
  final String canReorderIf;

  /// A condition that must hold for a drop: `${result}` holds the drop as
  /// it would be (from, to, item, fromList, toList), e.g. a WIP limit
  /// `${= result.fromList == result.toList || count(todo) < 5}`. Empty for
  /// any.
  final String canDropIf;

  /// The shadow under the dragged item.
  final double proxyElevation;

  /// How much the dragged item grows, 1 for not at all.
  final double proxyScale;

  /// How opaque the dragged item is.
  final double proxyOpacity;

  /// What shows where the item would land.
  @JsonKey(unknownEnumValue: ReorderPlaceholder.gap)
  final ReorderPlaceholder placeholder;

  /// The node drawn for [ReorderPlaceholder.node], a child of the list.
  final String placeholderNodeId;

  /// Whether the list scrolls while the dragged item is near its edges.
  final bool autoScroll;

  /// How close to an edge, in pixels, the list starts scrolling.
  final double autoScrollEdge;

  /// Whether a focused item moves with Alt (Option) and the arrow keys, and
  /// is announced, for keyboard and screen reader users.
  final bool keyboard;

  /// What the list updates itself.
  @JsonKey(unknownEnumValue: ListApply.none)
  final ListApply apply;

  /// The numeric field holding a document's position, for [ListApply.cloud].
  final String orderField;

  /// The field holding the list a document is in (its column), for a move
  /// between lists with [ListApply.cloud]: it is set to the [listKey] of
  /// the list it is dropped in.
  final String listField;

  /// Creates a [ReorderModel].
  const ReorderModel({
    this.enabled = true,
    this.start = ReorderStart.handle,
    this.group = '',
    this.listKey = '',
    this.canReorderIf = '',
    this.canDropIf = '',
    this.proxyElevation = 6,
    this.proxyScale = 1,
    this.proxyOpacity = 1,
    this.placeholder = ReorderPlaceholder.gap,
    this.placeholderNodeId = '',
    this.autoScroll = true,
    this.autoScrollEdge = 48,
    this.keyboard = true,
    this.apply = ListApply.none,
    this.orderField = 'order',
    this.listField = '',
  });

  /// Whether items can move to other lists.
  bool get betweenLists => group.trim().isNotEmpty;

  /// Duplicates this instance with the given data overrides.
  ReorderModel copyWith({
    bool? enabled,
    ReorderStart? start,
    String? group,
    String? listKey,
    String? canReorderIf,
    String? canDropIf,
    double? proxyElevation,
    double? proxyScale,
    double? proxyOpacity,
    ReorderPlaceholder? placeholder,
    String? placeholderNodeId,
    bool? autoScroll,
    double? autoScrollEdge,
    bool? keyboard,
    ListApply? apply,
    String? orderField,
    String? listField,
  }) => ReorderModel(
    enabled: enabled ?? this.enabled,
    start: start ?? this.start,
    group: group ?? this.group,
    listKey: listKey ?? this.listKey,
    canReorderIf: canReorderIf ?? this.canReorderIf,
    canDropIf: canDropIf ?? this.canDropIf,
    proxyElevation: proxyElevation ?? this.proxyElevation,
    proxyScale: proxyScale ?? this.proxyScale,
    proxyOpacity: proxyOpacity ?? this.proxyOpacity,
    placeholder: placeholder ?? this.placeholder,
    placeholderNodeId: placeholderNodeId ?? this.placeholderNodeId,
    autoScroll: autoScroll ?? this.autoScroll,
    autoScrollEdge: autoScrollEdge ?? this.autoScrollEdge,
    keyboard: keyboard ?? this.keyboard,
    apply: apply ?? this.apply,
    orderField: orderField ?? this.orderField,
    listField: listField ?? this.listField,
  );

  @override
  List<Object?> get props => [
    enabled,
    start,
    group,
    listKey,
    canReorderIf,
    canDropIf,
    proxyElevation,
    proxyScale,
    proxyOpacity,
    placeholder,
    placeholderNodeId,
    autoScroll,
    autoScrollEdge,
    keyboard,
    apply,
    orderField,
    listField,
  ];

  /// Creates a [ReorderModel] from a JSON object.
  factory ReorderModel.fromJson(Map json) => _$ReorderModelFromJson(json);

  @override
  Map toJson() => _$ReorderModelOmitDefaults(this, _$ReorderModelToJson(this));
}
