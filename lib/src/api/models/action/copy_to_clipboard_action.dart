import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'copy_to_clipboard_action.g.dart';

/// Copies a text to the clipboard, e.g. a link to share. Pair it with a
/// toast to say so.
@JsonSerializable()
class CopyToClipboardAction extends ActionModel
    with Equatable, SerializableMixin {
  /// The text to copy. Supports variables and formulas, e.g.
  /// `https://nook.homes/homes/${route.homeId}`.
  final String text;

  /// Creates a [CopyToClipboardAction].
  CopyToClipboardAction({this.text = '', super.nonBlocking, super.enabled})
    : super(type: ActionType.copyToClipboard);

  /// Duplicates this action with the given values replaced.
  CopyToClipboardAction copyWith({String? text}) => CopyToClipboardAction(
    text: text ?? this.text,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [text];

  /// Creates an instance from a JSON object.
  factory CopyToClipboardAction.fromJson(Map json) =>
      _$CopyToClipboardActionFromJson(json);

  @override
  Map toJson() => _$CopyToClipboardActionOmitDefaults(
    this,
    _$CopyToClipboardActionToJson(this),
  );

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitCopyToClipboardAction(this);
}
