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
/// wheel steps the value.
///
/// Positions are in logical pixels relative to where the node is laid out:
/// a fader cap laid out at the bottom of its slot has `y2: -250` for a
/// 250px throw. Angles are in degrees, clockwise, 0 pointing up.
///
/// While dragged, the node and its children read `${track.value}`,
/// `${track.progress}` (0 to 1) and `${track.dragging}`. Each change runs
/// the node's `changed` reactions with `${result.value}`; letting go runs
/// its `dragEnd` reactions.
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

  /// For a line: [x1], [y1], [x2] and [y2] are multiples of the node's own
  /// width and height instead of pixels, so the track scales with the node.
  /// The track moves the node's centre, so a scrub area is a full-width
  /// (transparent) node with `x1: -0.5, x2: 0.5`: at a value its centre,
  /// and a knob centred in it, sits at that fraction across the space it
  /// was laid out in, and a tap anywhere on it jumps there (a time bar, a
  /// chart's scrub area).
  final bool relative;

  /// Tapping the node's parent anywhere along the track moves the node
  /// there (a fader cap jumps to where its slot was tapped). Only for
  /// [DragTrackInput.follow].
  final bool jumpOnTap;

  /// Whether the mouse wheel steps the value.
  final bool wheel;

  /// A finer step for precise adjustment; 0 (the default) has no fine mode.
  /// The track is in fine mode while Shift is held, or after the pointer is
  /// pressed and held still for [fineHoldMs] before dragging: the value then
  /// moves in [fineStep]s, [finePixelsPerRange] pixels for the whole range,
  /// and `${track.fine}` is true (a FINE lamp). Shift + wheel steps by it.
  final double fineStep;

  /// Pixels of drag for the whole range in fine mode; 0 is four times
  /// [pixelsPerRange].
  final double finePixelsPerRange;

  /// How long the pointer must be held still to enter fine mode; 0 turns
  /// hold-to-fine off (Shift still works).
  final int fineHoldMs;

  /// A boolean variable, by name, the track keeps true while in fine mode,
  /// for nodes outside the track (its children read `${track.fine}`).
  final String? fineVariable;

  /// Animates the node to each new value over this many milliseconds, along
  /// [snapCurve], instead of jumping: a knob clicking from detent to detent.
  /// 0 jumps.
  final int snapMs;

  /// Whether dragging writes [variable]. Off, the track only shows the
  /// variable (which may then be a computed one, such as a timer's time
  /// left) and its `changed` / `dragEnd` reactions set whatever should
  /// change, from `${result.value}`.
  final bool write;

  /// The curve of [snapMs]: linear, easeIn, easeOut, easeInOut,
  /// easeOutCubic, easeOutBack (default, a slight overshoot), elasticOut,
  /// bounceOut.
  final String snapCurve;
  /// For an arc: the value isn't held to [min]..[max] and the node keeps
  /// turning past the arc's ends, a turn per [min]..[max] when the arc
  /// spans 360° (a combination dial: 40 numbers a turn, as many turns as
  /// you like). Read the number under an index with `mod`, e.g.
  /// `${= mod(0 - dial, 40)}`.
  final bool endless;

  /// Let go while it moves and it keeps going, slowing by [friction], then
  /// settles on a [step]: a dial spun with a flick. Off, it stops where it
  /// is let go.
  final bool momentum;

  /// How fast a [momentum] coast slows, per second: the speed falls to
  /// about a third each `1 / friction` seconds (2.6 coasts about a third of
  /// a second at full speed).
  final double friction;

  /// Draws the node where the pointer has it, between [step]s, while it is
  /// dragged or coasting, and springs it onto the nearest step when it comes
  /// to rest (the variable only ever holds whole steps). Off, the node jumps
  /// from step to step.
  final bool smooth;

  /// How far the node moves for a given pointer movement: 1 follows the
  /// pointer, 0.5 needs twice the movement (fine), 2 half (coarse). Bind it
  /// with `variables['track.gain']` to a setting such as a dial's
  /// sensitivity.
  final double gain;

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
    this.relative = false,
    this.jumpOnTap = false,
    this.wheel = true,
    this.fineStep = 0,
    this.finePixelsPerRange = 0,
    this.fineHoldMs = 380,
    this.fineVariable,
    this.snapMs = 0,
    this.snapCurve = 'easeOutBack',
    this.write = true,
    this.endless = false,
    this.momentum = false,
    this.friction = 2.6,
    this.smooth = false,
    this.gain = 1,
  });

  /// The node variable that binds [gain].
  static const String gainVariableKey = 'track.gain';

  /// The node variables that bind [min], [max] and [step] (numbers or
  /// formulas): a dial with 40 or 100 numbers a turn, from data.
  static const String minVariableKey = 'track.min';

  /// See [minVariableKey].
  static const String maxVariableKey = 'track.max';

  /// See [minVariableKey].
  static const String stepVariableKey = 'track.step';

  /// The node variables that bind [momentum] and [smooth] (a Reduce motion
  /// setting turns coasting and the snap animation off).
  static const String momentumVariableKey = 'track.momentum';

  /// See [momentumVariableKey].
  static const String smoothVariableKey = 'track.smooth';

  /// The node variables that bind a line's ends ([x1], [y1], [x2], [y2]):
  /// a slider whose throw follows its groove's laid-out width,
  /// `variables['track.x2'] = '${= parent.width - 26}'`.
  static const String x1VariableKey = 'track.x1';

  /// See [x1VariableKey].
  static const String y1VariableKey = 'track.y1';

  /// See [x1VariableKey].
  static const String x2VariableKey = 'track.x2';

  /// See [x1VariableKey].
  static const String y2VariableKey = 'track.y2';

  /// Whether the value is unbounded ([endless] on an arc).
  bool get unbounded => endless && shape == DragTrackShape.arc;

  /// The names of the live values the `track` variable has.
  static const List<String> liveValues = ['value', 'progress', 'dragging', 'fine'];

  /// Whether the track has a fine mode.
  bool get hasFine => fineStep > 0;

  /// Pixels for the whole range in fine mode.
  double get effectiveFinePixelsPerRange => finePixelsPerRange > 0 ? finePixelsPerRange : pixelsPerRange * 4;

  /// The key in [BaseNode.variables] that binds [defaultValue], so a
  /// control in a list can reset to its own item's default (each knob of a
  /// pedal has one): a `${...}` path or `${= ...}` formula giving a number,
  /// e.g. `${item.knobs[0].default}`. A binding that gives no number keeps
  /// [defaultValue].
  static const String defaultValueVariable = 'track.defaultValue';

  /// Where [value] is along the track, from 0 at [min] to 1 at [max].
  /// An [endless] arc's progress goes past 0 and 1 (2 is a second turn).
  double progressOf(double value) {
    if (max == min) return 0;
    final double p = (value - min) / (max - min);
    return unbounded ? p : p.clamp(0.0, 1.0);
  }

  /// The value at [progress] along the track, snapped to [step].
  double valueAt(double progress) =>
      snap(min + (max - min) * (unbounded ? progress : progress.clamp(0.0, 1.0)));

  /// [value] snapped to [fineStep] (counted from [min]) and kept in range.
  double snapFine(double value) => snapTo(value, hasFine ? fineStep : step);

  /// [value] snapped to [by] (counted from [min]; 0 is continuous) and kept
  /// in range.
  double snapTo(double value, double by) {
    final double lo = min < max ? min : max;
    final double hi = min < max ? max : min;
    double v = value.clamp(lo, hi);
    if (by > 0) {
      v = min + ((v - min) / by).round() * by;
      v = v.clamp(lo, hi);
      v = double.parse(v.toStringAsFixed(6));
    }
    return v;
  }

  /// [progress] held to the track (any progress on an [endless] arc).
  double clampProgress(double progress) =>
      unbounded ? progress : progress.clamp(0.0, 1.0);

  /// [value] snapped to [step] (counted from [min]) and kept in range (an
  /// [endless] arc has no range).
  double snap(double value) {
    final double lo = min < max ? min : max;
    final double hi = min < max ? max : min;
    double v = unbounded ? value : value.clamp(lo, hi);
    if (step > 0) {
      v = min + ((v - min) / step).round() * step;
      if (!unbounded) v = v.clamp(lo, hi);
      // Keep 0.1 steps from turning into 0.30000000000000004.
      v = double.parse(v.toStringAsFixed(6));
    }
    return v;
  }

  /// How far one wheel notch moves the value.
  double get wheelStep => step > 0 ? step : (max - min).abs() / 100;

  /// The rotation of an arc at [progress], in degrees.
  double angleAt(double progress) =>
      startAngle + (endAngle - startAngle) * clampProgress(progress);

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
    bool? relative,
    bool? jumpOnTap,
    bool? wheel,
    double? fineStep,
    double? finePixelsPerRange,
    int? fineHoldMs,
    String? fineVariable,
    bool clearFineVariable = false,
    int? snapMs,
    String? snapCurve,
    bool? write,
    bool? endless,
    bool? momentum,
    double? friction,
    bool? smooth,
    double? gain,
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
    relative: relative ?? this.relative,
    jumpOnTap: jumpOnTap ?? this.jumpOnTap,
    wheel: wheel ?? this.wheel,
    fineStep: fineStep ?? this.fineStep,
    finePixelsPerRange: finePixelsPerRange ?? this.finePixelsPerRange,
    fineHoldMs: fineHoldMs ?? this.fineHoldMs,
    fineVariable: clearFineVariable ? null : (fineVariable ?? this.fineVariable),
    snapMs: snapMs ?? this.snapMs,
    snapCurve: snapCurve ?? this.snapCurve,
    write: write ?? this.write,
    endless: endless ?? this.endless,
    momentum: momentum ?? this.momentum,
    friction: friction ?? this.friction,
    smooth: smooth ?? this.smooth,
    gain: gain ?? this.gain,
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
    relative,
    jumpOnTap,
    wheel,
    fineStep,
    finePixelsPerRange,
    fineHoldMs,
    fineVariable,
    snapMs,
    snapCurve,
    write,
    endless,
    momentum,
    friction,
    smooth,
    gain,
  ];

  /// Creates a [DragTrackModel] from JSON.
  factory DragTrackModel.fromJson(Map json) => _$DragTrackModelFromJson(json);

  @override
  Map toJson() =>
      _$DragTrackModelOmitDefaults(this, _$DragTrackModelToJson(this));
}
