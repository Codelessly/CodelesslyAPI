import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'scroll_to_action.g.dart';

/// Scrolls every scroll view around a node so that the node comes into
/// view: a stats screen opened on a selected day scrolls its calendar into
/// view. Does nothing when the node isn't built (e.g. an item of a lazy
/// list that is far off screen).
@JsonSerializable()
class ScrollToAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the node to scroll to.
  final String nodeId;

  /// How long the scroll takes, in milliseconds. 0 jumps there.
  final int durationMs;

  /// The easing of the scroll.
  final MotionCurve curve;

  /// Where the node ends up in the scroll view: 0 puts its top (or start)
  /// at the top of the view, 0.5 centers it and 1 puts its bottom at the
  /// bottom.
  final double alignment;

  /// Extra pixels to scroll past the aligned position; negative leaves
  /// that much room before the node, e.g. under a pinned header.
  final double offset;

  /// Which scroll views to move: `horizontal` or `vertical` scrolls only
  /// those along that axis and leaves the others where they are; null (the
  /// default) scrolls every scroll view around the node. A phone's trail
  /// map in a sideways-scrolling window centres a point of the map
  /// (`horizontal`) without scrolling the page under it.
  final String? axis;

  /// Creates a [ScrollToAction].
  ScrollToAction({
    this.nodeId = '',
    this.durationMs = 400,
    this.curve = MotionCurve.easeInOut,
    this.alignment = 0,
    this.offset = 0,
    this.axis,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.scrollTo);

  /// Duplicates this action with the given values replaced.
  ScrollToAction copyWith({
    String? nodeId,
    int? durationMs,
    MotionCurve? curve,
    double? alignment,
    double? offset,
    String? axis,
  }) => ScrollToAction(
    nodeId: nodeId ?? this.nodeId,
    durationMs: durationMs ?? this.durationMs,
    curve: curve ?? this.curve,
    alignment: alignment ?? this.alignment,
    offset: offset ?? this.offset,
    axis: axis ?? this.axis,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    nodeId,
    durationMs,
    curve,
    alignment,
    offset,
    axis,
  ];

  /// Creates an instance from a JSON object.
  factory ScrollToAction.fromJson(Map json) => _$ScrollToActionFromJson(json);

  @override
  Map toJson() =>
      _$ScrollToActionOmitDefaults(this, _$ScrollToActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitScrollToAction(this);
}
