import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';
import '../nodes/nodes.dart';
import 'trigger.dart';

part 'drag_and_drop.g.dart';

/// How a drag of a [DraggableModel] node starts.
enum DragStart {
  /// As soon as the pointer moves a few pixels while pressed.
  press,

  /// After the pointer is held still for a moment.
  longPress,

  /// A long press on touch screens (so scrolling still works) and a press
  /// with a mouse or stylus.
  auto;

  /// Displayable string representation.
  String get prettify => switch (this) {
    DragStart.press => 'Press',
    DragStart.longPress => 'Long press',
    DragStart.auto => 'Auto',
  };
}

/// Which way a dragged node may move.
enum DragAxis {
  /// Anywhere.
  free,

  /// Only left and right.
  horizontal,

  /// Only up and down.
  vertical;

  /// Displayable string representation.
  String get prettify => switch (this) {
    DragAxis.free => 'Free',
    DragAxis.horizontal => 'Horizontal',
    DragAxis.vertical => 'Vertical',
  };
}

/// What the node that is being dragged shows in its place.
enum DragSourceStyle {
  /// Stays, faded to [DraggableModel.ghostOpacity].
  ghost,

  /// Collapses, taking no space, so the items after it close the gap.
  hidden,

  /// Stays as it is.
  keep;

  /// Displayable string representation.
  String get prettify => switch (this) {
    DragSourceStyle.ghost => 'Ghost',
    DragSourceStyle.hidden => 'Hide',
    DragSourceStyle.keep => 'Keep',
  };
}

/// Makes a node draggable: the user can pick it up and drop it on a node
/// with a [DropTargetModel] that accepts its [group].
///
/// While a drag is in progress the predefined `drag` variable describes it
/// (`drag.active`, `drag.group`, `drag.data`, `drag.count`, `drag.over`,
/// `drag.beforeId`, `drag.index`, `drag.accepted`, ...), so any node can
/// bind to it to highlight targets or show where the drop will land.
@JsonSerializable()
class DraggableModel with Equatable, SerializableMixin {
  /// What kind of thing this is, e.g. `card` or `column`. Drop targets list
  /// the groups they accept.
  final String group;

  /// The payload the drop receives as `drag.data`: text with `${...}` paths
  /// or a `${= ...}` formula, evaluated when the drag starts, e.g.
  /// `${item.id}`. A list carries several things at once (a multi-select
  /// drag); `drag.count` is its length.
  final String data;

  /// How the drag starts.
  @JsonKey(unknownEnumValue: DragStart.auto)
  final DragStart start;

  /// Which way the node may move.
  @JsonKey(unknownEnumValue: DragAxis.free)
  final DragAxis axis;

  /// What the node shows in its place while it is dragged.
  @JsonKey(unknownEnumValue: DragSourceStyle.ghost)
  final DragSourceStyle whileDragging;

  /// The opacity of the node left in place for [DragSourceStyle.ghost].
  final double ghostOpacity;

  /// Degrees the copy that follows the pointer is tilted by.
  final double feedbackRotation;

  /// Scale of the copy that follows the pointer.
  final double feedbackScale;

  /// Opacity of the copy that follows the pointer.
  final double feedbackOpacity;

  /// Shadow blur of the copy that follows the pointer; 0 for none.
  final double feedbackElevation;

  /// A node to draw under the pointer instead of a copy of this one (e.g. a
  /// stack showing `${drag.count} cards`). Empty for a copy.
  final String feedbackNodeId;

  /// Creates a [DraggableModel].
  const DraggableModel({
    this.group = '',
    this.data = '',
    this.start = DragStart.auto,
    this.axis = DragAxis.free,
    this.whileDragging = DragSourceStyle.ghost,
    this.ghostOpacity = 0.35,
    this.feedbackRotation = -2,
    this.feedbackScale = 1,
    this.feedbackOpacity = 1,
    this.feedbackElevation = 24,
    this.feedbackNodeId = '',
  });

  /// Duplicates this instance with the given data overrides.
  DraggableModel copyWith({
    String? group,
    String? data,
    DragStart? start,
    DragAxis? axis,
    DragSourceStyle? whileDragging,
    double? ghostOpacity,
    double? feedbackRotation,
    double? feedbackScale,
    double? feedbackOpacity,
    double? feedbackElevation,
    String? feedbackNodeId,
  }) => DraggableModel(
    group: group ?? this.group,
    data: data ?? this.data,
    start: start ?? this.start,
    axis: axis ?? this.axis,
    whileDragging: whileDragging ?? this.whileDragging,
    ghostOpacity: ghostOpacity ?? this.ghostOpacity,
    feedbackRotation: feedbackRotation ?? this.feedbackRotation,
    feedbackScale: feedbackScale ?? this.feedbackScale,
    feedbackOpacity: feedbackOpacity ?? this.feedbackOpacity,
    feedbackElevation: feedbackElevation ?? this.feedbackElevation,
    feedbackNodeId: feedbackNodeId ?? this.feedbackNodeId,
  );

  @override
  List<Object?> get props => [
    group,
    data,
    start,
    axis,
    whileDragging,
    ghostOpacity,
    feedbackRotation,
    feedbackScale,
    feedbackOpacity,
    feedbackElevation,
    feedbackNodeId,
  ];

  /// Creates a [DraggableModel] from JSON data.
  factory DraggableModel.fromJson(Map json) => _$DraggableModelFromJson(json);

  @override
  Map toJson() =>
      _$DraggableModelOmitDefaults(this, _$DraggableModelToJson(this));
}

/// What a drop target shows where a drop would land in its list.
enum DropSlot {
  /// Nothing; the items stay where they are.
  none,

  /// An empty space the size of the dragged node.
  gap,

  /// [DropTargetModel.slotNodeId] drawn at the size of the dragged node.
  node;

  /// Displayable string representation.
  String get prettify => switch (this) {
    DropSlot.none => 'None',
    DropSlot.gap => 'Gap',
    DropSlot.node => 'Node',
  };
}

/// Makes a node a drop target: draggable nodes whose group it [accepts] can
/// be dropped on it, which fires its `drop` reactions with the drop in
/// `${result}` (and `${drag}`): `data`, `group`, `key`, `beforeId`,
/// `before`, `index` and `accepted`.
///
/// When the target holds a list ([listNodeId]), the drop lands between two
/// of its items: the one under the pointer's position decides, the list
/// opens a [slot] there and collapses the dragged items it holds.
@JsonSerializable()
class DropTargetModel with Equatable, SerializableMixin {
  /// The groups of draggables this target takes; empty for any.
  final List<String> accepts;

  /// Identifies this target in `drag.over` and `drag.source` while a drag
  /// is over it or started in it: text with `${...}`, e.g. `${item.id}` for a
  /// column in a list of columns. Defaults to the node's id.
  final String key;

  /// A condition (`${= ...}` formula, or `${...}` path) that must hold for
  /// the drop to be accepted, evaluated while dragging with `drag` set (e.g.
  /// a WIP limit: `${= count(...) + drag.count <= item.limit}`). Empty
  /// accepts every drop of an accepted group. `drag.accepted` tells
  /// bindings whether it holds.
  final String acceptIf;

  /// The list (or grid) whose items a drop lands between: this node's id
  /// when the target is a list, or a list inside it. Empty to drop on the
  /// target as a whole.
  final String listNodeId;

  /// What the list shows where the drop would land.
  @JsonKey(unknownEnumValue: DropSlot.gap)
  final DropSlot slot;

  /// The node drawn as the slot for [DropSlot.node].
  final String slotNodeId;

  /// Milliseconds a drag must stay over this target before its `dragHover`
  /// reactions fire (e.g. to switch to a tab's page); 0 for never.
  final int hoverDelayMs;

  /// Creates a [DropTargetModel].
  const DropTargetModel({
    this.accepts = const [],
    this.key = '',
    this.acceptIf = '',
    this.listNodeId = '',
    this.slot = DropSlot.gap,
    this.slotNodeId = '',
    this.hoverDelayMs = 0,
  });

  /// Whether a draggable of [group] may be dropped here.
  bool acceptsGroup(String group) => accepts.isEmpty || accepts.contains(group);

  /// Duplicates this instance with the given data overrides.
  DropTargetModel copyWith({
    List<String>? accepts,
    String? key,
    String? acceptIf,
    String? listNodeId,
    DropSlot? slot,
    String? slotNodeId,
    int? hoverDelayMs,
  }) => DropTargetModel(
    accepts: accepts ?? this.accepts,
    key: key ?? this.key,
    acceptIf: acceptIf ?? this.acceptIf,
    listNodeId: listNodeId ?? this.listNodeId,
    slot: slot ?? this.slot,
    slotNodeId: slotNodeId ?? this.slotNodeId,
    hoverDelayMs: hoverDelayMs ?? this.hoverDelayMs,
  );

  @override
  List<Object?> get props => [
    accepts,
    key,
    acceptIf,
    listNodeId,
    slot,
    slotNodeId,
    hoverDelayMs,
  ];

  /// Creates a [DropTargetModel] from JSON data.
  factory DropTargetModel.fromJson(Map json) => _$DropTargetModelFromJson(json);

  @override
  Map toJson() =>
      _$DropTargetModelOmitDefaults(this, _$DropTargetModelToJson(this));
}

/// The triggers a node offers in the editor.
extension AvailableTriggerTypes on ReactionMixin {
  /// [triggerTypes], plus a right click on anything that can be clicked, and
  /// the drag and drop triggers of a draggable node or drop target.
  List<TriggerType> get availableTriggerTypes {
    final List<TriggerType> own = triggerTypes;
    final Object self = this;
    return [
      ...own,
      if (own.contains(TriggerType.click) &&
          !own.contains(TriggerType.secondaryClick))
        TriggerType.secondaryClick,
      if (self is BaseNode && self.draggable != null) ...TriggerType.dragSource,
      if (self is BaseNode && self.dropTarget != null)
        ...TriggerType.dropTarget,
    ];
  }
}
