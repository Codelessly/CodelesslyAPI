import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'focus_field_action.g.dart';

/// Moves the keyboard focus to a text field, or takes it away: a form that
/// saves and starts over puts the cursor back in its first field.
@JsonSerializable()
class FocusFieldAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the text field to focus. Empty with [unfocus] takes focus
  /// away from whatever field has it.
  final String nodeId;

  /// Takes the focus away instead (closing the keyboard).
  final bool unfocus;

  /// Creates a [FocusFieldAction].
  FocusFieldAction({
    this.nodeId = '',
    this.unfocus = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.focusField);

  /// Duplicates this action with the given values replaced.
  FocusFieldAction copyWith({String? nodeId, bool? unfocus}) =>
      FocusFieldAction(
        nodeId: nodeId ?? this.nodeId,
        unfocus: unfocus ?? this.unfocus,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  @override
  List<Object?> get props => [nodeId, unfocus];

  /// Creates an instance from a JSON object.
  factory FocusFieldAction.fromJson(Map json) =>
      _$FocusFieldActionFromJson(json);

  @override
  Map toJson() =>
      _$FocusFieldActionOmitDefaults(this, _$FocusFieldActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitFocusFieldAction(this);
}
