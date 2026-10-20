import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'confirm_action.g.dart';

/// Asks the user to confirm, e.g. "Leave album?", then runs [actions] when
/// they confirm and [cancelActions] when they cancel or dismiss the dialog.
@JsonSerializable()
class ConfirmAction extends ActionModel with Equatable, SerializableMixin {
  /// The dialog's title. Supports variables and formulas.
  final String title;

  /// Text under the title. Supports variables and formulas.
  final String message;

  /// Label of the confirm button.
  final String confirmLabel;

  /// Label of the cancel button.
  final String cancelLabel;

  /// Whether confirming destroys something, which colors the confirm button
  /// red.
  final bool destructive;

  /// Actions to run, in order, when the user confirms.
  final List<ActionModel> actions;

  /// Actions to run, in order, when the user cancels.
  final List<ActionModel> cancelActions;

  /// Creates a [ConfirmAction].
  ConfirmAction({
    required this.title,
    this.message = '',
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    List<ActionModel>? actions,
    List<ActionModel>? cancelActions,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       cancelActions = cancelActions ?? [],
       super(type: ActionType.confirm);

  /// Duplicates this action with the given values replaced.
  ConfirmAction copyWith({
    String? title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool? destructive,
    List<ActionModel>? actions,
    List<ActionModel>? cancelActions,
  }) => ConfirmAction(
    title: title ?? this.title,
    message: message ?? this.message,
    confirmLabel: confirmLabel ?? this.confirmLabel,
    cancelLabel: cancelLabel ?? this.cancelLabel,
    destructive: destructive ?? this.destructive,
    actions: actions ?? this.actions,
    cancelActions: cancelActions ?? this.cancelActions,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    title,
    message,
    confirmLabel,
    cancelLabel,
    destructive,
    actions,
    cancelActions,
  ];

  /// Creates an instance from a JSON object.
  factory ConfirmAction.fromJson(Map json) => _$ConfirmActionFromJson(json);

  @override
  Map toJson() =>
      _$ConfirmActionOmitDefaults(this, _$ConfirmActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitConfirmAction(this);
}
