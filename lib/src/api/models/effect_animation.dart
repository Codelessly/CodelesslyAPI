import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import 'models.dart';

part 'effect_animation.g.dart';

/// One-shot effects a node can play ([EffectAnimation]).
enum EffectAnimationType {
  /// Side to side, fading out: a wrong answer, a locked door.
  shake,

  /// Hops up and lands with a squash: a celebration.
  bounce,

  /// Grows and settles back: a confirmation, a button press.
  pop,

  /// Rocks back and forth, fading out: "look at me".
  wiggle,

  /// Squashes wide then tall, like jelly.
  jelly,

  /// Fades out and back in, twice: an alert.
  flash,

  /// One full turn.
  spin;

  /// Displayable name.
  String get prettify => switch (this) {
    EffectAnimationType.shake => 'Shake',
    EffectAnimationType.bounce => 'Bounce',
    EffectAnimationType.pop => 'Pop',
    EffectAnimationType.wiggle => 'Wiggle',
    EffectAnimationType.jelly => 'Jelly',
    EffectAnimationType.flash => 'Flash',
    EffectAnimationType.spin => 'Spin',
  };

  /// How long the effect takes by default, in milliseconds.
  int get defaultDurationMs => switch (this) {
    EffectAnimationType.shake => 520,
    EffectAnimationType.bounce => 760,
    EffectAnimationType.pop => 360,
    EffectAnimationType.wiggle => 620,
    EffectAnimationType.jelly => 640,
    EffectAnimationType.flash => 600,
    EffectAnimationType.spin => 600,
  };
}

/// A one-shot effect a node plays on cue, drawn over its layout: shake on
/// a wrong answer, bounce when a word is spelled, pop when tapped.
///
/// It plays:
/// - each time the value bound to `animations.<name>.playKey` in
///   [BaseNode.variables] changes (not when the node first appears), e.g.
///   `${slotShakes[index]}` so each slot of a list shakes on its own count;
/// - when a `playAnimation` action names the node and this animation;
/// - when the node appears, with [playOnAppear].
///
/// A node can have several, e.g. a shake for wrong drops and a bounce for
/// the celebration; their transforms combine while they overlap.
@JsonSerializable()
class EffectAnimation with Equatable, SerializableMixin {
  /// Name used by actions and bindings, unique on the node, e.g. `shake`.
  final String name;

  /// What the effect does.
  final EffectAnimationType type;

  /// How long it takes, in milliseconds.
  final int durationMs;

  /// How long it waits after its cue before it starts, in milliseconds;
  /// bindable as `animations.<name>.delayMs`, e.g. `${= index * 90}` for a
  /// wave across a list.
  final int delayMs;

  /// Strength: 1 is the effect's usual size, 2 twice as strong.
  final double amount;

  /// The point it scales and turns around, in the node's box: (-1, -1)
  /// top left, (0, 0) the centre, (1, 1) bottom right.
  final double originX;

  /// See [originX].
  final double originY;

  /// Whether it plays when the node first appears.
  final bool playOnAppear;

  /// Creates an [EffectAnimation].
  const EffectAnimation({
    required this.name,
    required this.type,
    this.durationMs = 520,
    this.delayMs = 0,
    this.amount = 1,
    this.originX = 0,
    this.originY = 0,
    this.playOnAppear = false,
  });

  /// An effect of [type] named after it, with its usual duration.
  factory EffectAnimation.preset(EffectAnimationType type, {String? name}) =>
      EffectAnimation(
        name: name ?? type.name,
        type: type,
        durationMs: type.defaultDurationMs,
        originY: type == EffectAnimationType.bounce ? 1 : 0,
      );

  /// The key in [BaseNode.variables] whose changes replay the effect named
  /// [name].
  static String playKeyVariable(String name) => 'animations.$name.playKey';

  /// The key in [BaseNode.variables] that binds [delayMs] of the effect
  /// named [name].
  static String delayVariable(String name) => 'animations.$name.delayMs';

  /// Returns a copy with the given values replaced.
  EffectAnimation copyWith({
    String? name,
    EffectAnimationType? type,
    int? durationMs,
    int? delayMs,
    double? amount,
    double? originX,
    double? originY,
    bool? playOnAppear,
  }) => EffectAnimation(
    name: name ?? this.name,
    type: type ?? this.type,
    durationMs: durationMs ?? this.durationMs,
    delayMs: delayMs ?? this.delayMs,
    amount: amount ?? this.amount,
    originX: originX ?? this.originX,
    originY: originY ?? this.originY,
    playOnAppear: playOnAppear ?? this.playOnAppear,
  );

  @override
  List<Object?> get props => [
    name,
    type,
    durationMs,
    delayMs,
    amount,
    originX,
    originY,
    playOnAppear,
  ];

  /// Creates an [EffectAnimation] from JSON.
  factory EffectAnimation.fromJson(Map json) => _$EffectAnimationFromJson(json);

  @override
  Map toJson() =>
      _$EffectAnimationOmitDefaults(this, _$EffectAnimationToJson(this));
}

/// Shapes a particle can take.
enum ParticleShape {
  /// A small rounded square of paper.
  square,

  /// A dot.
  circle,

  /// A thin strip of paper.
  strip,

  /// A five-pointed star.
  star;

  /// Displayable name.
  String get prettify => switch (this) {
    ParticleShape.square => 'Square',
    ParticleShape.circle => 'Circle',
    ParticleShape.strip => 'Strip',
    ParticleShape.star => 'Star',
  };
}

/// A particle emitter drawn over a node: bursts of confetti or stars, or a
/// rain of them. It never takes taps and isn't clipped to the node.
///
/// Particles start at [originX], [originY] (an alignment in the node's
/// box: -1 left/top, 1 right/bottom), spread over [originWidth] of its
/// width, and fly out in a cone around [direction] (degrees, 0 is up, 180
/// down) [spread] degrees either side at about [speed] px/s, slowed by air
/// and pulled down by [gravity] px/s². Paper flutters and turns over as it
/// falls; each particle fades out over the end of its [lifetimeMs].
///
/// With [emitMs] 0 it fires [count] particles at once (a burst); otherwise
/// [count] per second for [emitMs].
///
/// It fires each time the value bound to `particles.playKey` in
/// [BaseNode.variables] changes, when a `playAnimation` action names the
/// node and the animation `particles`, and, with [playOnAppear], when the
/// node appears.
@JsonSerializable()
class ParticleEmitter with Equatable, SerializableMixin {
  /// Particles per burst, or per second while emitting.
  final int count;

  /// How long to keep emitting, in milliseconds; 0 for a single burst.
  final int emitMs;

  /// Colors picked at random, as `#RRGGBB` or `#AARRGGBB`.
  final List<String> colors;

  /// Shapes picked at random.
  final List<ParticleShape> shapes;

  /// Size of a particle in logical pixels (each varies ±30%).
  final double size;

  /// Where particles start across the node: -1 left, 0 centre, 1 right.
  final double originX;

  /// Where particles start down the node: -1 top, 0 centre, 1 bottom.
  final double originY;

  /// Fraction of the node's width particles start across; 0 is a point,
  /// 1 the full width (a rain from the top edge).
  final double originWidth;

  /// The direction particles fly, in degrees: 0 up, 90 right, 180 down.
  final double direction;

  /// How far either side of [direction] particles may fly, in degrees.
  final double spread;

  /// Launch speed in logical pixels per second (each varies).
  final double speed;

  /// Downward pull in logical pixels per second squared.
  final double gravity;

  /// How long a particle lives, in milliseconds.
  final int lifetimeMs;

  /// Whether it fires when the node appears.
  final bool playOnAppear;

  /// Creates a [ParticleEmitter].
  const ParticleEmitter({
    this.count = 40,
    this.emitMs = 0,
    this.colors = ParticleEmitter.defaultColors,
    this.shapes = const [
      ParticleShape.square,
      ParticleShape.strip,
      ParticleShape.circle,
    ],
    this.size = 10,
    this.originX = 0,
    this.originY = 0,
    this.originWidth = 0,
    this.direction = 0,
    this.spread = 60,
    this.speed = 700,
    this.gravity = 900,
    this.lifetimeMs = 2600,
    this.playOnAppear = false,
  });

  /// Bright confetti colors.
  static const List<String> defaultColors = [
    '#FFC83D',
    '#FF6F61',
    '#2FD9A4',
    '#8B6CFF',
    '#3FB8FF',
    '#FF8BC6',
  ];

  /// The key in [BaseNode.variables] whose changes fire the emitter.
  static const String playKeyVariable = 'particles.playKey';

  /// The animation name a `playAnimation` action uses to fire it.
  static const String animationName = 'particles';

  /// Returns a copy with the given values replaced.
  ParticleEmitter copyWith({
    int? count,
    int? emitMs,
    List<String>? colors,
    List<ParticleShape>? shapes,
    double? size,
    double? originX,
    double? originY,
    double? originWidth,
    double? direction,
    double? spread,
    double? speed,
    double? gravity,
    int? lifetimeMs,
    bool? playOnAppear,
  }) => ParticleEmitter(
    count: count ?? this.count,
    emitMs: emitMs ?? this.emitMs,
    colors: colors ?? this.colors,
    shapes: shapes ?? this.shapes,
    size: size ?? this.size,
    originX: originX ?? this.originX,
    originY: originY ?? this.originY,
    originWidth: originWidth ?? this.originWidth,
    direction: direction ?? this.direction,
    spread: spread ?? this.spread,
    speed: speed ?? this.speed,
    gravity: gravity ?? this.gravity,
    lifetimeMs: lifetimeMs ?? this.lifetimeMs,
    playOnAppear: playOnAppear ?? this.playOnAppear,
  );

  @override
  List<Object?> get props => [
    count,
    emitMs,
    colors,
    shapes,
    size,
    originX,
    originY,
    originWidth,
    direction,
    spread,
    speed,
    gravity,
    lifetimeMs,
    playOnAppear,
  ];

  /// Creates a [ParticleEmitter] from JSON.
  factory ParticleEmitter.fromJson(Map json) => _$ParticleEmitterFromJson(json);

  @override
  Map toJson() =>
      _$ParticleEmitterOmitDefaults(this, _$ParticleEmitterToJson(this));
}
