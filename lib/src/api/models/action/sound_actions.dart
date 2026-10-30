import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'sound_actions.g.dart';

/// Reads a text aloud with the device's text-to-speech voice: a word to
/// spell, a letter, an instruction. Saying something new stops what was
/// being said.
@JsonSerializable()
class SpeakAction extends ActionModel with Equatable, SerializableMixin {
  /// What to say. Supports variables and formulas, e.g. `${lower(word)}`.
  final String text;

  /// Speaking speed: 1 is normal, 0.5 half as fast. A variable or formula
  /// in [rateValue] wins.
  final double rate;

  /// A variable or formula giving the speed, e.g.
  /// `${= slowVoice ? 0.6 : 0.9}`.
  final String? rateValue;

  /// Voice pitch: 1 is normal, higher sounds younger.
  final double pitch;

  /// The language to speak in, as a BCP 47 tag such as `en-US`.
  final String language;

  /// Creates a [SpeakAction].
  SpeakAction({
    this.text = '',
    this.rate = 1,
    this.rateValue,
    this.pitch = 1,
    this.language = 'en-US',
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.speak);

  /// Duplicates this action with the given values replaced.
  SpeakAction copyWith({
    String? text,
    double? rate,
    String? rateValue,
    bool clearRateValue = false,
    double? pitch,
    String? language,
  }) => SpeakAction(
    text: text ?? this.text,
    rate: rate ?? this.rate,
    rateValue: clearRateValue ? null : rateValue ?? this.rateValue,
    pitch: pitch ?? this.pitch,
    language: language ?? this.language,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [text, rate, rateValue, pitch, language];

  /// Creates an instance from a JSON object.
  factory SpeakAction.fromJson(Map json) => _$SpeakActionFromJson(json);

  @override
  Map toJson() => _$SpeakActionOmitDefaults(this, _$SpeakActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitSpeakAction(this);
}

/// Sounds a [PlaySoundAction] can play without a file, synthesized on the
/// device.
enum SoundPreset {
  /// A short rising blip: something snapped into place.
  pop,

  /// A low wobble: wrong.
  boing,

  /// Three rising notes: well done.
  chime,

  /// A little trumpet tune: a level is finished.
  fanfare,

  /// A soft click for buttons.
  tap,

  /// A tiny blip: something was picked up.
  pick;

  /// Displayable name.
  String get prettify => switch (this) {
    SoundPreset.pop => 'Pop',
    SoundPreset.boing => 'Boing',
    SoundPreset.chime => 'Chime',
    SoundPreset.fanfare => 'Fanfare',
    SoundPreset.tap => 'Tap',
    SoundPreset.pick => 'Pick up',
  };
}

/// Plays a short sound: one of the [SoundPreset]s, or an audio file at
/// [url].
@JsonSerializable()
class PlaySoundAction extends ActionModel with Equatable, SerializableMixin {
  /// The sound to play when there is no [url].
  final SoundPreset preset;

  /// An audio file to play instead of [preset] (mp3, wav, ogg). Supports
  /// variables.
  final String url;

  /// Loudness from 0 to 1.
  final double volume;

  /// Creates a [PlaySoundAction].
  PlaySoundAction({
    this.preset = SoundPreset.pop,
    this.url = '',
    this.volume = 1,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.playSound);

  /// Duplicates this action with the given values replaced.
  PlaySoundAction copyWith({SoundPreset? preset, String? url, double? volume}) =>
      PlaySoundAction(
        preset: preset ?? this.preset,
        url: url ?? this.url,
        volume: volume ?? this.volume,
        nonBlocking: nonBlocking,
        enabled: enabled,
      );

  @override
  List<Object?> get props => [preset, url, volume];

  /// Creates an instance from a JSON object.
  factory PlaySoundAction.fromJson(Map json) => _$PlaySoundActionFromJson(json);

  @override
  Map toJson() =>
      _$PlaySoundActionOmitDefaults(this, _$PlaySoundActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitPlaySoundAction(this);
}
