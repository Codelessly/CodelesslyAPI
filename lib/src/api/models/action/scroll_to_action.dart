import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'scroll_to_action.g.dart';

/// How long a [ScrollToAction] scrolls by default, in milliseconds.
const int kDefaultScrollToDurationMs = 600;

/// Scrolls the page (or the scrollable frame or list the node is in) so the
/// node [nodeId] comes into view at the top, [offset] pixels below the edge:
/// an anchor nav's link jumping to its section under a sticky header.
///
/// Every scrollable around the node scrolls, the nearest first, so a node in
/// a scrollable frame inside a scrolling page is brought into view by both.
/// Nothing happens when the node isn't shown (e.g. an item of a lazy list
/// that hasn't been built yet).
@JsonSerializable()
class ScrollToAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the node to bring into view.
  final String nodeId;

  /// How long the scroll takes, in milliseconds. 0 jumps.
  final int durationMs;

  /// The easing of the scroll.
  final MotionCurve curve;

  /// Pixels to leave between the scrollable's leading edge (its top, for a
  /// vertical one) and the node, e.g. the height of a sticky header drawn
  /// over the page. Negative scrolls past the node's start.
  final double offset;

  /// Creates a [ScrollToAction].
  ScrollToAction({
    this.nodeId = '',
    this.durationMs = kDefaultScrollToDurationMs,
    this.curve = MotionCurve.easeInOut,
    this.offset = 0,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.scrollTo);

  /// Duplicates this action with the given values replaced.
  ScrollToAction copyWith({
    String? nodeId,
    int? durationMs,
    MotionCurve? curve,
    double? offset,
  }) => ScrollToAction(
    nodeId: nodeId ?? this.nodeId,
    durationMs: durationMs ?? this.durationMs,
    curve: curve ?? this.curve,
    offset: offset ?? this.offset,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [nodeId, durationMs, curve, offset];

  /// Creates an instance from a JSON object.
  factory ScrollToAction.fromJson(Map json) => _$ScrollToActionFromJson(json);

  @override
  Map toJson() =>
      _$ScrollToActionOmitDefaults(this, _$ScrollToActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitScrollToAction(this);
}
