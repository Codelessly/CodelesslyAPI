import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'focus_action.g.dart';

/// Moves the keyboard focus to a text field, e.g. `/` jumps to search, or
/// takes it away from whatever field has it.
@JsonSerializable()
class FocusAction extends ActionModel with Equatable, SerializableMixin {
  /// The text field to focus. Empty with [unfocus] unfocuses any field.
  final String nodeId;

  /// Removes the focus instead (from [nodeId], or from any field when
  /// [nodeId] is empty).
  @JsonKey(defaultValue: false)
  final bool unfocus;

  /// Selects the field's text when it gains focus.
  @JsonKey(defaultValue: false)
  final bool selectAll;

  /// Creates a [FocusAction].
  FocusAction({
    this.nodeId = '',
    this.unfocus = false,
    this.selectAll = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.focus);

  /// Duplicates this action with the given values replaced.
  FocusAction copyWith({String? nodeId, bool? unfocus, bool? selectAll}) =>
      FocusAction(
        nodeId: nodeId ?? this.nodeId,
        unfocus: unfocus ?? this.unfocus,
        selectAll: selectAll ?? this.selectAll,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  @override
  List<Object?> get props => [nodeId, unfocus, selectAll];

  /// Creates an instance from a JSON object.
  factory FocusAction.fromJson(Map json) => _$FocusActionFromJson(json);

  @override
  Map toJson() => _$FocusActionOmitDefaults(this, _$FocusActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitFocusAction(this);
}
