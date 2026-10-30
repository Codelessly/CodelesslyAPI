import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'edit_text_action.g.dart';

/// What an [EditTextAction] does to its text field.
enum EditTextOperation {
  /// Wraps the selection in [EditTextAction.before] and
  /// [EditTextAction.after], keeping it selected, or inserts the empty pair
  /// with the cursor between: a Bold button wraps in `**`.
  wrap,

  /// Turns the lines the selection touches into `- ` list items (`1. `,
  /// `2. ` with [EditTextAction.numbered]), or back into plain lines when
  /// they all are such items already.
  toggleList,

  /// Inserts [EditTextAction.text] at the cursor, in place of the selection,
  /// with a space before it when the character before isn't whitespace: a
  /// Mention button inserts `@`.
  insert,

  /// Replaces the word ending at the cursor (the run of non-whitespace
  /// characters before it, e.g. `@ma` or `/ref`) with [EditTextAction.text]:
  /// picking a suggestion from an autocomplete menu.
  replaceWord,

  /// Replaces the whole text with [EditTextAction.text], cursor at its end.
  setText,

  /// Empties the field.
  clear,

  /// Focuses the field.
  focus;

  /// Displayable name of the operation.
  String get prettify => switch (this) {
    EditTextOperation.wrap => 'Wrap selection',
    EditTextOperation.toggleList => 'Toggle list',
    EditTextOperation.insert => 'Insert at cursor',
    EditTextOperation.replaceWord => 'Replace word at cursor',
    EditTextOperation.setText => 'Set text',
    EditTextOperation.clear => 'Clear',
    EditTextOperation.focus => 'Focus',
  };
}

/// Edits the text of a text field on the screen at its cursor, the way a
/// rich text composer's toolbar, shortcuts and autocomplete do: wrap the
/// selection in Markdown markers, toggle a list, insert a mention, replace
/// the `@query` being typed with the picked handle, set, clear or focus.
///
/// The edit updates the field's bound `inputValue` variable and runs its
/// Changed reactions, as typing does, then focuses the field (except
/// [EditTextOperation.clear] and [EditTextOperation.setText], which leave
/// focus where it is).
@JsonSerializable()
class EditTextAction extends ActionModel with Equatable, SerializableMixin {
  /// The id of the text field to edit, on the same screen.
  final String nodeId;

  /// What to do.
  final EditTextOperation operation;

  /// The text [EditTextOperation.insert], [EditTextOperation.replaceWord] and
  /// [EditTextOperation.setText] put in. Supports variables and formulas,
  /// e.g. `@${item.handle} `.
  final String text;

  /// What [EditTextOperation.wrap] puts before the selection, e.g. `**`.
  /// Supports variables and formulas.
  final String before;

  /// What [EditTextOperation.wrap] puts after the selection; null: the same
  /// as [before]. Supports variables and formulas.
  final String? after;

  /// Whether [EditTextOperation.toggleList] makes a numbered list.
  final bool numbered;

  /// Creates an [EditTextAction].
  EditTextAction({
    this.nodeId = '',
    this.operation = EditTextOperation.insert,
    this.text = '',
    this.before = '',
    this.after,
    this.numbered = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.editText);

  /// Duplicates this action with the given values replaced.
  EditTextAction copyWith({
    String? nodeId,
    EditTextOperation? operation,
    String? text,
    String? before,
    String? after,
    bool clearAfter = false,
    bool? numbered,
  }) => EditTextAction(
    nodeId: nodeId ?? this.nodeId,
    operation: operation ?? this.operation,
    text: text ?? this.text,
    before: before ?? this.before,
    after: clearAfter ? null : after ?? this.after,
    numbered: numbered ?? this.numbered,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [nodeId, operation, text, before, after, numbered];

  /// Creates an instance from a JSON object.
  factory EditTextAction.fromJson(Map json) => _$EditTextActionFromJson(json);

  @override
  Map toJson() =>
      _$EditTextActionOmitDefaults(this, _$EditTextActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitEditTextAction(this);
}
