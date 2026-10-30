import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'play_sound_action.g.dart';

/// The built-in synthesised sounds a [PlaySoundAction] plays. Each is a
/// short click (under 80 ms), so it stays crisp at fast tempos.
enum SoundVoice {
  /// A wood block: a pitched knock.
  wood,

  /// A clean sine beep.
  beep,

  /// A two-tone cowbell.
  bell,

  /// A rim shot: a noise burst with a knock.
  rim,

  /// A closed hi-hat: bright noise.
  hat;

  /// Displayable name.
  String get prettify => switch (this) {
    SoundVoice.wood => 'Wood block',
    SoundVoice.beep => 'Beep',
    SoundVoice.bell => 'Cowbell',
    SoundVoice.rim => 'Rim shot',
    SoundVoice.hat => 'Hi-hat',
  };
}

/// Plays a short synthesised sound: a metronome click, a tap confirmation,
/// a UI tick. The sound is scheduled on the device's audio clock, so
/// several can be lined up precisely ahead of time with [at] (see the
/// `clock` trigger, whose `${result.at}` is the exact time of its tick).
///
/// Every field takes a value or a formula: `${voice}`, or a volume that
/// depends on the beat, `${= beat == 0 ? accentGain : beatGain}`.
@JsonSerializable()
class PlaySoundAction extends ActionModel with Equatable, SerializableMixin {
  /// Which sound: a [SoundVoice] name (`wood`, `beep`, `bell`, `rim`,
  /// `hat`), or a formula giving one.
  final String sound;

  /// Loudness from 0 (silent) to 1 (full); may go up to 2. A value or a
  /// formula.
  final String volume;

  /// Pitch ratio, where 1 is the sound's own pitch and 2 an octave up. A
  /// value or a formula.
  final String pitch;

  /// When to play it, in seconds on the audio clock (what the `clock`
  /// trigger's `${result.at}` gives). Empty plays it now.
  final String at;

  /// Creates a [PlaySoundAction].
  PlaySoundAction({
    this.sound = 'wood',
    this.volume = '1',
    this.pitch = '1',
    this.at = '',
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.playSound);

  /// Duplicates this action with the given values replaced.
  PlaySoundAction copyWith({
    String? sound,
    String? volume,
    String? pitch,
    String? at,
  }) => PlaySoundAction(
    sound: sound ?? this.sound,
    volume: volume ?? this.volume,
    pitch: pitch ?? this.pitch,
    at: at ?? this.at,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [sound, volume, pitch, at];

  /// Creates an instance from a JSON object.
  factory PlaySoundAction.fromJson(Map json) => _$PlaySoundActionFromJson(json);

  @override
  Map toJson() =>
      _$PlaySoundActionOmitDefaults(this, _$PlaySoundActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitPlaySoundAction(this);
}
