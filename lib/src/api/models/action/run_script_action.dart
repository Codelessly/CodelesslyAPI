import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'run_script_action.g.dart';

/// Runs a script ([ScriptModel]) and makes its result the chain's
/// `${result}`.
///
/// [arguments] maps the script's parameter names to values: text that may
/// hold variables and formulas, e.g. `{"principal": "${loan.amount}",
/// "years": "30"}`. A value that is exactly one variable or formula passes
/// that value as is (a number stays a number, a list stays a list). Other
/// text has its variables filled in and passes as JSON when it is JSON
/// (`30` is a number, `true` a boolean, `[1, 2]` a list), else as text.
/// Parameters without an argument get their default.
///
/// When the script succeeds, `${result}` is its result and the chain goes
/// on. When it fails (it threw, used up its time or memory, or called a
/// host API it wasn't granted), [onError] runs with `${result}` set to
/// `{error: {type, message, line, column}, logs}`. As with a Call API
/// action, a failure handled by [onError] actions doesn't stop the chain;
/// without them a failure stops the chain and is reported to the error
/// log.
@JsonSerializable()
class RunScriptAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the script to run.
  final String scriptId;

  /// The script's arguments, by parameter name.
  final Map<String, String> arguments;

  /// The name of a variable to store the result in, or null.
  final String? resultVariable;

  /// Actions to run, in order, when the script fails.
  final List<ActionModel> onError;

  /// Creates a [RunScriptAction].
  RunScriptAction({
    required this.scriptId,
    Map<String, String>? arguments,
    this.resultVariable,
    List<ActionModel>? onError,
    super.nonBlocking,
    super.enabled,
  })  : arguments = arguments ?? {},
        onError = onError ?? [],
        super(type: ActionType.runScript);

  @override
  List<Object?> get props => [scriptId, arguments, resultVariable, onError];

  /// A copy with the given fields replaced.
  RunScriptAction copyWith({
    String? scriptId,
    Map<String, String>? arguments,
    String? resultVariable,
    bool clearResultVariable = false,
    List<ActionModel>? onError,
  }) =>
      RunScriptAction(
        scriptId: scriptId ?? this.scriptId,
        arguments: arguments ?? this.arguments,
        resultVariable:
            clearResultVariable ? null : resultVariable ?? this.resultVariable,
        onError: onError ?? this.onError,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  /// Creates a [RunScriptAction] from JSON.
  factory RunScriptAction.fromJson(Map json) => _$RunScriptActionFromJson(json);

  @override
  Map toJson() =>
      _$RunScriptActionOmitDefaults(this, _$RunScriptActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitRunScriptAction(this);
}
