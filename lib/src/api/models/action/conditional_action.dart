import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'conditional_action.g.dart';

/// Runs [actions] when [expression] is true and [elseActions] otherwise.
///
/// This is the logic builder's "if": it branches an action chain on a
/// variable, e.g. `${auth.isSignedIn}`, the result of a query, or a value a
/// previous action wrote. The expression is the same as a condition's.
@JsonSerializable()
class ConditionalAction extends ActionModel with Equatable, SerializableMixin {
  /// The expression to test.
  final BaseExpression expression;

  /// Actions to run, in order, when [expression] is true.
  final List<ActionModel> actions;

  /// Actions to run, in order, when [expression] is false.
  final List<ActionModel> elseActions;

  /// Creates a [ConditionalAction].
  ConditionalAction({
    required this.expression,
    List<ActionModel>? actions,
    List<ActionModel>? elseActions,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       elseActions = elseActions ?? [],
       super(type: ActionType.conditional);

  /// Duplicates this action with the given values replaced.
  ConditionalAction copyWith({
    BaseExpression? expression,
    List<ActionModel>? actions,
    List<ActionModel>? elseActions,
  }) => ConditionalAction(
    expression: expression ?? this.expression,
    actions: actions ?? this.actions,
    elseActions: elseActions ?? this.elseActions,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [expression, actions, elseActions];

  /// Creates an instance from a JSON object.
  factory ConditionalAction.fromJson(Map json) =>
      _$ConditionalActionFromJson(json);

  @override
  Map toJson() =>
      _$ConditionalActionOmitDefaults(this, _$ConditionalActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitConditionalAction(this);
}
