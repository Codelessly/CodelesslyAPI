import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'for_each_action.g.dart';

/// Runs [actions] once for every item of a list.
///
/// [items] is a variable path that resolves to a list, e.g. `${photos}`.
/// While the actions run, `${result.item}` is the current item and
/// `${result.index}` its index.
@JsonSerializable()
class ForEachAction extends ActionModel with Equatable, SerializableMixin {
  /// A variable path that resolves to the list to iterate.
  final String items;

  /// Actions to run, in order, for each item.
  final List<ActionModel> actions;

  /// Creates a [ForEachAction].
  ForEachAction({
    this.items = '',
    List<ActionModel>? actions,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       super(type: ActionType.forEach);

  /// Duplicates this action with the given values replaced.
  ForEachAction copyWith({String? items, List<ActionModel>? actions}) =>
      ForEachAction(
        items: items ?? this.items,
        actions: actions ?? this.actions,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  @override
  List<Object?> get props => [items, actions];

  /// Creates an instance from a JSON object.
  factory ForEachAction.fromJson(Map json) => _$ForEachActionFromJson(json);

  @override
  Map toJson() =>
      _$ForEachActionOmitDefaults(this, _$ForEachActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitForEachAction(this);
}
