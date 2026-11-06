import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'drag_track.g.dart';

/// The geometry a [DragTrackModel] moves its node along.
enum DragTrackShape {
  /// A straight segment from ([DragTrackModel.x1], [DragTrackModel.y1]) to
  /// ([DragTrackModel.x2], [DragTrackModel.y2]): a fader or a slider.
  line,

  /// A rotation from [DragTrackModel.startAngle] to
  /// [DragTrackModel.endAngle] around the node's centre, or around
  /// ([DragTrackModel.pivotX], [DragTrackModel.pivotY]): a knob, a dial, or
  /// a handle orbiting a ring.
  arc,

  /// Any curve, as SVG path data ([DragTrackModel.path]): the node's centre
  /// follows it by arc length.
  path;

  /// Displayable name.
  String get prettify => switch (this) {
    DragTrackShape.line => 'Line',
    DragTrackShape.arc => 'Arc (rotate)',
    DragTrackShape.path => 'Path',
  };
}

/// How pointer movement turns into movement along a [DragTrackModel].
enum DragTrackInput {
  /// The node follows the pointer along the track: the pointer's angle
  /// around the pivot for an arc, its nearest point for a line or path.
  follow,

  /// Dragging up raises the value and down lowers it, whatever the track's
  /// shape, [DragTrackModel.pixelsPerRange] pixels for the whole range: the
  /// usual way to turn a small knob.
  vertical,

  /// Dragging right raises the value and left lowers it.
  horizontal;

  /// Displayable name.
  String get prettify => switch (this) {
    DragTrackInput.follow => 'Follow pointer',
    DragTrackInput.vertical => 'Drag up / down',
    DragTrackInput.horizontal => 'Drag left / right',
  };
}

/// Turns a node into a value control by giving it a track to be dragged
/// along: any styled node (a knob cap, a fader cap, a handle) becomes a
/// knob, fader or slider by composition, laid over whatever faceplate it
/// sits on.
///
/// The track maps a numeric variable ([variable], from [min] to [max],
/// snapped to [step]) to a position on the track: a line, an arc the node
/// rotates through, or an SVG path. The node is drawn at the variable's
/// value as a transform over its layout (the space it takes up never
/// changes, like [MotionModel]); dragging it writes the variable, so
/// everything bound to the variable follows, and changing the variable
/// elsewhere moves the node. Double tap resets to [defaultValue], the mouse
/// wheel and the arrow keys (see [keyboard]) step the value.
///
/// Positions are in logical pixels relative to where the node is laid out:
/// a fader cap laid out at the bottom of its slot has `y2: -250` for a
/// 250px throw. Angles are in degrees, clockwise, 0 pointing up.
///
/// While dragged, the node and its children read `${track.value}`,
/// `${track.progress}` (0 to 1), `${track.dragging}` and
/// `${track.focused}`. Each change runs the node's `changed` reactions with
/// `${result.value}`; letting go runs its `dragEnd` reactions.
@JsonSerializable()
class DragTrackModel with Equatable, SerializableMixin {
  /// The track's geometry.
  final DragTrackShape shape;

  /// The variable the track reads and writes, by name (an integer or
  /// decimal variable).
  final String variable;

  /// The variable's value at the start of the track.
  final double min;

  /// The variable's value at the end of the track. May be less than [min]
  /// to run the other way.
  final double max;

  /// Steps the value snaps to; 0 is continuous. A stepped selector with 5
  /// positions from 0 to 4 has step 1.
  final double step;

  /// The value a double tap resets to; null turns double-tap reset off.
  final double? defaultValue;

  /// How the pointer moves the node.
  final DragTrackInput input;

  /// For [DragTrackInput.vertical] and [DragTrackInput.horizontal]: how many
  /// pixels of drag cover the whole range.
  final double pixelsPerRange;

  /// Start of a [DragTrackShape.line], relative to the node's rest position.
  final double x1;

  /// See [x1].
  final double y1;

  /// End of a [DragTrackShape.line], relative to the node's rest position.
  final double x2;

  /// See [x2].
  final double y2;

  /// Rotation at [min] for a [DragTrackShape.arc], degrees clockwise from up.
  final double startAngle;

  /// Rotation at [max] for a [DragTrackShape.arc].
  final double endAngle;

  /// The centre an arc turns around, relative to the node's centre; (0, 0)
  /// turns the node in place (a knob). (0, 80) swings it around a point 80px
  /// below, like a handle on a ring.
  final double pivotX;

  /// See [pivotX].
  final double pivotY;

  /// Whether the node turns with the arc. Off, it orbits the pivot without
  /// turning (a dot moving round a ring).
  final bool rotate;

  /// SVG path data for [DragTrackShape.path], relative to the node's rest
  /// centre, e.g. `M0 0 Q 80 -120 160 0`.
  final String? path;

  /// For a path: turn the node to follow the path's direction.
  final bool orientToPath;

  /// With [orientToPath], keeps the node from turning upside down: the
  /// path's direction is folded into -90 to 90 degrees (turned half round
  /// where the path heads left), as [MotionModel.orientUpright] does.
  final bool orientUpright;

  /// Tapping anywhere along the track moves the node there, then the drag
  /// goes on from there: a fader cap jumps to where its slot was tapped
  /// (the nearest point of a line or path), a dial to the angle tapped
  /// around its pivot, anywhere within the circle the node sweeps (the
  /// nearest valid value, snapped to [step]). Only for
  /// [DragTrackInput.follow].
  final bool jumpOnTap;

  /// Whether the mouse wheel steps the value.
  final bool wheel;

  /// How magnetic the [step]s are while dragging, from 0 to 1. At 0 (the
  /// default) the node jumps from step to step; above 0 it still follows
  /// the pointer that share of the way past the nearest step, so each step
  /// feels like a detent pulling it in (a rating dial at 0.35). The value
  /// itself always snaps. Letting go settles the node on its step over
  /// [settleMs].
  final double detent;

  /// How far the node can be dragged past either end of the track, as a
  /// share of the pointer's travel there, from 0 (it stops at the end, the
  /// default) to 1. A deck of cards rubber-bands at 0.35 past its first
  /// and last card. Letting go springs it back over [settleMs].
  final double overscroll;

  /// How long the node takes to glide to its value's place when it isn't
  /// following the pointer: on letting go (from a detent or overscroll),
  /// when a tap or an action changes the variable, a double tap reset or a
  /// wheel step. 0 (the default) jumps there.
  final int settleMs;

  /// The easing of that glide. [MotionCurve.spring] runs real spring
  /// physics ([settleStiffness], [settleDamping]) and ignores [settleMs]
  /// for its length; letting go mid-fling starts the spring at the
  /// pointer's speed, so a flung deck carries on into its settle (and an
  /// action that moves the variable right after, e.g. to the card the
  /// fling heads for, keeps that speed too).
  final MotionCurve settleCurve;

  /// The stiffness of the [MotionCurve.spring] settle (mass 1): higher
  /// snaps faster. A swipeable deck uses about 260.
  final double settleStiffness;

  /// The damping of the [MotionCurve.spring] settle: lower overshoots more,
  /// about 2 × √[settleStiffness] stops without overshooting (a damping
  /// ratio of 0.86 at stiffness 260 is about 27.7).
  final double settleDamping;

  /// Where the node is parked while the variable is outside the range
  /// (below [min], above [max]) or empty or not a number, as a progress
  /// along the track that may lie outside 0 to 1: an unrated 1 to 5 dial
  /// over -120..120 degrees parks its knob at -150 degrees with -0.125.
  /// Lines and arcs go on past their ends; a path stops at its ends. Null
  /// (the default) draws such a value at the nearest end.
  ///
  /// Dragging a parked node starts from the nearest end, and the node
  /// glides ([settleMs]) between its parked place and the track. While
  /// parked, `${track.progress}` reads this progress.
  final double? parkedProgress;

  /// Whether the track takes keyboard focus (tapping or dragging it
  /// focuses it, Tab reaches it) and the keys move it while focused: the
  /// right and up arrows step the value up by [step] (1% of the range
  /// without one), left and down step it down, Page Up and Page Down by 10
  /// steps, Home to [min] and End to [max]. Each key runs the node's
  /// `changed` reactions like a drag. On by default; `${track.focused}`
  /// tells whether it has focus, for a node to draw its own focus ring.
  /// The track is a slider to screen readers either way.
  final bool keyboard;

  /// Creates a [DragTrackModel].
  const DragTrackModel({
    this.shape = DragTrackShape.line,
    required this.variable,
    this.min = 0,
    this.max = 1,
    this.step = 0,
    this.defaultValue,
    this.input = DragTrackInput.follow,
    this.pixelsPerRange = 200,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = -100,
    this.startAngle = -135,
    this.endAngle = 135,
    this.pivotX = 0,
    this.pivotY = 0,
    this.rotate = true,
    this.path,
    this.orientToPath = false,
    this.orientUpright = false,
    this.jumpOnTap = false,
    this.wheel = true,
    this.detent = 0,
    this.overscroll = 0,
    this.settleMs = 0,
    this.settleCurve = MotionCurve.easeOutCubic,
    this.settleStiffness = 380,
    this.settleDamping = 20,
    this.parkedProgress,
    this.keyboard = true,
  });

  /// The names of the live values the `track` variable has.
  static const List<String> liveValues = [
    'value',
    'progress',
    'dragging',
    'focused',
  ];

  /// The names of the values a `dragEnd` reaction gets in `${result}`:
  /// the final `value`, the `startValue` the drag began at, and the
  /// `velocity` the pointer let go with, in the variable's units per second
  /// along the track (positive toward [max]), so a deck can fling to the
  /// next card: `${= round(result.value + result.velocity * 0.18)}`.
  static const List<String> endValues = ['value', 'startValue', 'velocity'];

  /// The settings that can follow data: a binding in the node's variables
  /// under [variableKey] (e.g. `track.max` = `${= hive.frames - 1}`)
  /// replaces the saved value wherever the track is built, at runtime and
  /// on the design canvas.
  static const List<String> bindableProperties = [
    'min',
    'max',
    'step',
    'pixelsPerRange',
    'x1',
    'y1',
    'x2',
    'y2',
  ];

  /// The key in a node's variables that binds [property] (one of
  /// [bindableProperties]): `track.<property>`.
  static String variableKey(String property) => 'track.$property';

  /// A copy with the bindable [property] set to [value]; unknown names
  /// leave it as it is.
  DragTrackModel withValue(String property, double value) => switch (property) {
    'min' => copyWith(min: value),
    'max' => copyWith(max: value),
    'step' => copyWith(step: value < 0 ? 0 : value),
    'pixelsPerRange' => value == 0 ? this : copyWith(pixelsPerRange: value),
    'x1' => copyWith(x1: value),
    'y1' => copyWith(y1: value),
    'x2' => copyWith(x2: value),
    'y2' => copyWith(y2: value),
    _ => this,
  };

  /// Where [value] is along the track, from 0 at [min] to 1 at [max].
  double progressOf(double value) {
    if (max == min) return 0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  /// Whether [value] is drawn at [parkedProgress]: outside the range or not
  /// a number (NaN stands for an empty variable), when the track has one.
  bool isParked(double value) {
    if (parkedProgress == null) return false;
    if (value.isNaN) return true;
    final double lo = min < max ? min : max;
    final double hi = min < max ? max : min;
    return value < lo || value > hi;
  }

  /// Where the node is drawn for [value]: its [progressOf], or
  /// [parkedProgress] when [isParked].
  double restProgressOf(double value) =>
      isParked(value) ? parkedProgress! : (value.isNaN ? 0 : progressOf(value));

  /// The value at [progress] along the track, snapped to [step].
  double valueAt(double progress) =>
      snap(min + (max - min) * progress.clamp(0.0, 1.0));

  /// [value] snapped to [step] (counted from [min]) and kept in range.
  double snap(double value) {
    final double lo = min < max ? min : max;
    final double hi = min < max ? max : min;
    double v = value.clamp(lo, hi);
    if (step > 0) {
      v = min + ((v - min) / step).round() * step;
      v = v.clamp(lo, hi);
      // Keep 0.1 steps from turning into 0.30000000000000004.
      v = double.parse(v.toStringAsFixed(6));
    }
    return v;
  }

  /// How far one wheel notch (or one arrow key) moves the value.
  double get wheelStep => step > 0 ? step : (max - min).abs() / 100;

  /// The rotation of an arc at [progress], in degrees.
  double angleAt(double progress) =>
      startAngle + (endAngle - startAngle) * progress.clamp(0.0, 1.0);

  /// Returns a copy with the given values replaced.
  DragTrackModel copyWith({
    DragTrackShape? shape,
    String? variable,
    double? min,
    double? max,
    double? step,
    double? defaultValue,
    bool clearDefault = false,
    DragTrackInput? input,
    double? pixelsPerRange,
    double? x1,
    double? y1,
    double? x2,
    double? y2,
    double? startAngle,
    double? endAngle,
    double? pivotX,
    double? pivotY,
    bool? rotate,
    String? path,
    bool? orientToPath,
    bool? orientUpright,
    bool? jumpOnTap,
    bool? wheel,
    double? detent,
    double? overscroll,
    int? settleMs,
    MotionCurve? settleCurve,
    double? settleStiffness,
    double? settleDamping,
    double? parkedProgress,
    bool clearParked = false,
    bool? keyboard,
  }) => DragTrackModel(
    shape: shape ?? this.shape,
    variable: variable ?? this.variable,
    min: min ?? this.min,
    max: max ?? this.max,
    step: step ?? this.step,
    defaultValue: clearDefault ? null : (defaultValue ?? this.defaultValue),
    input: input ?? this.input,
    pixelsPerRange: pixelsPerRange ?? this.pixelsPerRange,
    x1: x1 ?? this.x1,
    y1: y1 ?? this.y1,
    x2: x2 ?? this.x2,
    y2: y2 ?? this.y2,
    startAngle: startAngle ?? this.startAngle,
    endAngle: endAngle ?? this.endAngle,
    pivotX: pivotX ?? this.pivotX,
    pivotY: pivotY ?? this.pivotY,
    rotate: rotate ?? this.rotate,
    path: path ?? this.path,
    orientToPath: orientToPath ?? this.orientToPath,
    orientUpright: orientUpright ?? this.orientUpright,
    jumpOnTap: jumpOnTap ?? this.jumpOnTap,
    wheel: wheel ?? this.wheel,
    detent: detent ?? this.detent,
    overscroll: overscroll ?? this.overscroll,
    settleMs: settleMs ?? this.settleMs,
    settleCurve: settleCurve ?? this.settleCurve,
    settleStiffness: settleStiffness ?? this.settleStiffness,
    settleDamping: settleDamping ?? this.settleDamping,
    parkedProgress: clearParked
        ? null
        : (parkedProgress ?? this.parkedProgress),
    keyboard: keyboard ?? this.keyboard,
  );

  @override
  List<Object?> get props => [
    shape,
    variable,
    min,
    max,
    step,
    defaultValue,
    input,
    pixelsPerRange,
    x1,
    y1,
    x2,
    y2,
    startAngle,
    endAngle,
    pivotX,
    pivotY,
    rotate,
    path,
    orientToPath,
    orientUpright,
    jumpOnTap,
    wheel,
    detent,
    overscroll,
    settleMs,
    settleCurve,
    settleStiffness,
    settleDamping,
    parkedProgress,
    keyboard,
  ];

  /// Creates a [DragTrackModel] from JSON.
  factory DragTrackModel.fromJson(Map json) => _$DragTrackModelFromJson(json);

  @override
  Map toJson() =>
      _$DragTrackModelOmitDefaults(this, _$DragTrackModelToJson(this));
}
