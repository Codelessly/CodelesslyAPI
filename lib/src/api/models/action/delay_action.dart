import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'delay_action.g.dart';

/// Waits before the next action runs, e.g. to let a toast show before
/// navigating away.
@JsonSerializable()
class DelayAction extends ActionModel with Equatable, SerializableMixin {
  /// How long to wait, in milliseconds.
  final int milliseconds;

  /// A variable or formula giving the wait in milliseconds, e.g.
  /// `${= networkMode == 'slow' ? 4000 : 900}`. When it gives a number, it is
  /// used instead of [milliseconds].
  final String? duration;

  /// Creates a [DelayAction].
  DelayAction({
    this.milliseconds = 500,
    this.duration,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.delay);

  /// Duplicates this action with the given values replaced.
  DelayAction copyWith({
    int? milliseconds,
    String? duration,
    bool clearDuration = false,
  }) => DelayAction(
    milliseconds: milliseconds ?? this.milliseconds,
    duration: clearDuration ? null : duration ?? this.duration,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [milliseconds, duration];

  /// Creates an instance from a JSON object.
  factory DelayAction.fromJson(Map json) => _$DelayActionFromJson(json);

  @override
  Map toJson() => _$DelayActionOmitDefaults(this, _$DelayActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitDelayAction(this);
}
