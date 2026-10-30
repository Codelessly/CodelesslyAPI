import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'speak_action.g.dart';

/// Reads [text] aloud with the device's text-to-speech voice: a word's
/// pronunciation on a flashcard, a hint read out. The action finishes when
/// the speech ends, so the actions after it run once it has been said.
///
/// While speaking, every node can read the `speech` variable:
/// `${speech.speaking}`, `${speech.text}` (what is being said) and
/// `${speech.available}` (false where the device has no voice), so a
/// speaker button can animate while it talks and explain when it can't.
@JsonSerializable()
class SpeakAction extends ActionModel with Equatable, SerializableMixin {
  /// What to say. Supports variables and formulas, e.g. `${item.front}`.
  final String text;

  /// The voice's language as a BCP 47 tag (`es-ES`, `ja-JP`), which may
  /// also be a variable (`${deck.lang}`). Empty uses the device's default.
  final String language;

  /// Speed, where 1 is normal; 0.5 is half speed.
  final double rate;

  /// Pitch, where 1 is normal.
  final double pitch;

  /// Stops anything being said instead of saying [text].
  final bool stop;

  /// Creates a [SpeakAction].
  SpeakAction({
    this.text = '',
    this.language = '',
    this.rate = 1,
    this.pitch = 1,
    this.stop = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.speak);

  /// Duplicates this action with the given values replaced.
  SpeakAction copyWith({
    String? text,
    String? language,
    double? rate,
    double? pitch,
    bool? stop,
  }) => SpeakAction(
    text: text ?? this.text,
    language: language ?? this.language,
    rate: rate ?? this.rate,
    pitch: pitch ?? this.pitch,
    stop: stop ?? this.stop,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [text, language, rate, pitch, stop];

  /// Creates an instance from a JSON object.
  factory SpeakAction.fromJson(Map json) => _$SpeakActionFromJson(json);

  @override
  Map toJson() => _$SpeakActionOmitDefaults(this, _$SpeakActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSpeakAction(this);
}
