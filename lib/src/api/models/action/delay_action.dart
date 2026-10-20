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

  /// Creates a [DelayAction].
  DelayAction({this.milliseconds = 500, super.nonBlocking, super.enabled})
    : super(type: ActionType.delay);

  /// Duplicates this action with the given values replaced.
  DelayAction copyWith({int? milliseconds}) => DelayAction(
    milliseconds: milliseconds ?? this.milliseconds,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [milliseconds];

  /// Creates an instance from a JSON object.
  factory DelayAction.fromJson(Map json) => _$DelayActionFromJson(json);

  @override
  Map toJson() => _$DelayActionOmitDefaults(this, _$DelayActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitDelayAction(this);
}
