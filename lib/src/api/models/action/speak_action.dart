import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'speak_action.g.dart';

/// Reads a bindable number stored as a string, accepting a plain JSON number
/// too, so `{"rate": 0.6}` and `{"rate": "0.6"}` both read as `'0.6'`.
String _bindableNumberFromJson(Object? value) =>
    _optionalBindableNumberFromJson(value) ?? '1';

String? _optionalBindableNumberFromJson(Object? value) => switch (value) {
  null => null,
  final String text => text,
  final num number => number.toString(),
  _ => value.toString(),
};

/// Speaks a text aloud with the platform's text-to-speech, e.g. a phrase in
/// the language it is written in. A new phrase replaces the one being spoken.
/// With [stop] it stops any speech instead of speaking.
@JsonSerializable()
class SpeakAction extends ActionModel with Equatable, SerializableMixin {
  /// The text to speak. Supports variables and formulas, e.g.
  /// `${route.phrase.text}`.
  final String text;

  /// The BCP-47 language tag to speak in, e.g. `ar-EG` or `ja-JP`. May be a
  /// variable or formula, e.g. `${route.phrase.lang}`. Empty uses the
  /// platform's default voice.
  final String language;

  /// The speaking rate: `1` is normal, `0.6` slow. A number, variable or
  /// formula, e.g. `${= slow ? 0.6 : 1}`.
  @JsonKey(fromJson: _bindableNumberFromJson)
  final String rate;

  /// The voice pitch, `1` by default. A number, variable or formula.
  @JsonKey(fromJson: _optionalBindableNumberFromJson)
  final String? pitch;

  /// Whether this action stops any speech instead of speaking.
  final bool stop;

  /// Creates a [SpeakAction].
  SpeakAction({
    this.text = '',
    this.language = '',
    this.rate = '1',
    this.pitch,
    this.stop = false,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.speak);

  /// Duplicates this action with the given values replaced.
  SpeakAction copyWith({
    String? text,
    String? language,
    String? rate,
    String? pitch,
    bool clearPitch = false,
    bool? stop,
  }) => SpeakAction(
    text: text ?? this.text,
    language: language ?? this.language,
    rate: rate ?? this.rate,
    pitch: clearPitch ? null : pitch ?? this.pitch,
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
