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
  horizontal,

  /// Dragging up or right raises the value, down or left lowers it (the
  /// pointer's dx − dy): a knob that turns whichever way it is pulled.
  both;

  /// Displayable name.
  String get prettify => switch (this) {
    DragTrackInput.follow => 'Follow pointer',
    DragTrackInput.vertical => 'Drag up / down',
    DragTrackInput.horizontal => 'Drag left / right',
    DragTrackInput.both => 'Drag up / right',
  };
}

/// Where a [DragTrackModel]'s node takes the pointer.
enum DragTrackHitArea {
  /// On the node itself (and, with [DragTrackModel.jumpOnTap], anywhere
  /// along the track).
  self,

  /// Anywhere in the node's parent: a knob turned from anywhere in its box,
  /// tick ring included, or a playhead scrubbed from anywhere across the
  /// tracks it sits on.
  parent;

  /// Displayable name.
  String get prettify => switch (this) {
    DragTrackHitArea.self => 'The node',
    DragTrackHitArea.parent => 'Its parent',
  };
}

/// What a [DragTrackModel]'s geometry is measured in.
enum DragTrackUnits {
  /// Logical pixels.
  pixels,

  /// Fractions of the parent's size: x values (`x1`, `x2`, `pivotX` and the
  /// path's x coordinates) of its width, y values of its height. `x2: 1`
  /// runs a line across the whole parent, at any width.
  parent;

  /// Displayable name.
  String get prettify => switch (this) {
    DragTrackUnits.pixels => 'Pixels',
    DragTrackUnits.parent => 'Fraction of parent',
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
///
/// The node's `variables` can bind the track: `track.value` gives the value
/// the node is drawn at (a computed or per-item value, e.g.
/// `${= lampOf(selectedLampId).kelvin}` or `${item.kelvin}`), in place of
/// reading [variable]; with no [variable] a drag only runs the reactions,
/// which write the value wherever it lives, and the node follows the
/// pointer while dragged, then settles at the bound value. `track.min`,
/// `track.max`, `track.x1`, `track.y1`, `track.x2`, `track.y2`,
/// `track.pivotX`, `track.pivotY`, `track.startAngle`, `track.endAngle`
/// and `track.path` bind the geometry (`${= parent.width - 150}`), see
/// [bindableFields].
@JsonSerializable()
class DragTrackModel with Equatable, SerializableMixin {
  /// The track's geometry.
  final DragTrackShape shape;

  /// The variable the track reads and writes, by name (an integer or
  /// decimal variable). Empty when the node binds `track.value` and its
  /// reactions write the value.
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

  /// With both [viewBoxWidth] and [viewBoxHeight] above 0, [path] is drawn
  /// in the box of the frame the node sits in, measured in these units:
  /// (0, 0) is the frame's top left and (viewBoxWidth, viewBoxHeight) its
  /// bottom right, stretched to the frame's size on each axis. The node's
  /// centre then follows the path wherever the frame's size puts it, so a
  /// thermometer pin keeps to a mountain ridge drawn in the same box (a
  /// path node with the same viewBox) at any screen width. 0 (the default)
  /// keeps [path] in pixels relative to the node's rest centre.
  final double viewBoxWidth;

  /// See [viewBoxWidth].
  final double viewBoxHeight;

  /// Whether [path] is measured in the frame's box ([viewBoxWidth]).
  bool get usesViewBox => viewBoxWidth > 0 && viewBoxHeight > 0;
  /// For a line: [x1], [y1], [x2] and [y2] are multiples of the node's own
  /// width and height instead of pixels, so the track scales with the node.
  /// The track moves the node's centre, so a scrub area is a full-width
  /// (transparent) node with `x1: -0.5, x2: 0.5`: at a value its centre,
  /// and a knob centred in it, sits at that fraction across the space it
  /// was laid out in, and a tap anywhere on it jumps there (a time bar, a
  /// chart's scrub area).
  final bool relative;

  /// Pressing anywhere along the track (or anywhere in the [hitArea]) moves
  /// the node there, and dragging from there follows the pointer: a fader
  /// cap jumps to where its slot (the node's parent) was tapped. On an arc,
  /// a tap anywhere on the node turns it to the tapped angle (past the
  /// sweep's ends, the nearer end), so a dial drawn to the size of its ring
  /// can be tapped round its ring. Only for [DragTrackInput.follow].
  final bool jumpOnTap;

  /// Whether the mouse wheel steps the value.
  final bool wheel;

  /// How far one wheel notch moves the value; null uses [step], or 1% of
  /// the range for a continuous track.
  final double? wheelStep;

  /// Values a double tap moves between: to the one after the current value
  /// in the list, or the first when the value isn't in it. `[100, 50]`
  /// turns a knob up to 100, or to 50 when it is at 100. Empty uses
  /// [defaultValue].
  final List<double> doubleTapValues;

  /// How far an arrow key moves the value while the node has the focus
  /// (pressing it focuses it); Home and End go to [min] and [max]. Null
  /// leaves the keyboard alone.
  final double? keyStep;

  /// Where the node takes the pointer.
  final DragTrackHitArea hitArea;

  /// What the geometry ([x1] to [y2], [pivotX], [pivotY], [path]) is
  /// measured in.
  final DragTrackUnits units;
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
    this.variable = '',
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
    this.viewBoxWidth = 0,
    this.viewBoxHeight = 0,
    this.relative = false,
    this.jumpOnTap = false,
    this.wheel = true,
    this.wheelStep,
    this.doubleTapValues = const [],
    this.keyStep,
    this.hitArea = DragTrackHitArea.self,
    this.units = DragTrackUnits.pixels,
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

  /// The settings that can follow a variable or formula, as
  /// `dragTrack.<name>` keys of [BaseNode.variables]: a dial whose one turn
  /// is a month, a year or a century as the screen says binds
  /// `dragTrack.endAngle` to `${= maxDays / unitDays * 360}`. Numbers, and
  /// [path] as text.
  static const List<String> bindable = [
    'min',
    'max',
    'step',
    'defaultValue',
    'pixelsPerRange',
    'x1',
    'y1',
    'x2',
    'y2',
    'startAngle',
    'endAngle',
    'pivotX',
    'pivotY',
    'path',
  ];

  /// The key in [BaseNode.variables] that binds [setting].
  static String variableKey(String setting) => 'dragTrack.$setting';

  /// Returns a copy with [setting] (one of [bindable]) set from [value], a
  /// bound variable's value: a number or numeric text (text for [path]).
  /// Returns this unchanged when [value] can't be read as one.
  DragTrackModel withBinding(String setting, Object? value) {
    if (setting == 'path') {
      return value is String && value.trim().isNotEmpty ? copyWith(path: value.trim()) : this;
    }
    final double? n = switch (value) {
      num v => v.toDouble(),
      String v => double.tryParse(v.trim()),
      _ => null,
    };
    if (n == null || !n.isFinite) return this;
    return switch (setting) {
      'min' => copyWith(min: n),
      'max' => copyWith(max: n),
      'step' => copyWith(step: n < 0 ? 0 : n),
      'defaultValue' => copyWith(defaultValue: n),
      'pixelsPerRange' => copyWith(pixelsPerRange: n <= 0 ? pixelsPerRange : n),
      'x1' => copyWith(x1: n),
      'y1' => copyWith(y1: n),
      'x2' => copyWith(x2: n),
      'y2' => copyWith(y2: n),
      'startAngle' => copyWith(startAngle: n),
      'endAngle' => copyWith(endAngle: n),
      'pivotX' => copyWith(pivotX: n),
      'pivotY' => copyWith(pivotY: n),
      _ => this,
    };
  }

  /// The key in [BaseNode.variables] that binds [defaultValue], so a
  /// control in a list can reset to its own item's default (each knob of a
  /// pedal has one): a `${...}` path or `${= ...}` formula giving a number,
  /// e.g. `${item.knobs[0].default}`. A binding that gives no number keeps
  /// [defaultValue].
  static const String defaultValueVariable = 'track.defaultValue';

  /// The prefix of the node `variables` keys that bind a track.
  static const String bindingPrefix = 'track.';

  /// The node `variables` key that binds the value the node is drawn at.
  static const String valueBindingKey = 'track.value';

  /// The fields a node's `variables` can bind, each as `track.<field>`:
  /// `value` (the value the node is drawn at) and the geometry.
  static const List<String> bindableFields = [
    'value',
    'min',
    'max',
    'x1',
    'y1',
    'x2',
    'y2',
    'startAngle',
    'endAngle',
    'pivotX',
    'pivotY',
    'path',
  ];

  /// Whether a node's track has a variable to write.
  bool get hasVariable => variable.trim().isNotEmpty;

  /// A copy with the geometry fields given in [values] (numbers by field
  /// name, `path` a string), each one replacing the saved field: what the
  /// node's `track.<field>` bindings resolve to.
  DragTrackModel withBound(Map<String, Object?> values) {
    // Track fields, bound as `track.<field>` (not node binding keys).
    double? number(String field) => switch (values[field]) {
      num n when n.isFinite => n.toDouble(),
      String s => double.tryParse(s.trim()),
      _ => null,
    };
    final Object? path = values['path'];
    return copyWith(
      min: number('min'),
      max: number('max'),
      x1: number('x1'),
      y1: number('y1'),
      x2: number('x2'),
      y2: number('y2'),
      startAngle: number('startAngle'),
      endAngle: number('endAngle'),
      pivotX: number('pivotX'),
      pivotY: number('pivotY'),
      path: path is String && path.trim().isNotEmpty ? path : null,
    );
  }

  /// The values [doubleTapValues] (or [defaultValue]) toggles through, in
  /// order.
  List<double> get doubleTapCycle => doubleTapValues.isNotEmpty
      ? doubleTapValues
      : [?defaultValue];

  /// The value a double tap moves to from [value], or null when double tap
  /// does nothing.
  double? doubleTapTarget(double value) {
    final List<double> cycle = doubleTapCycle;
    if (cycle.isEmpty) return null;
    final double current = snap(value);
    for (int i = 0; i < cycle.length; i++) {
      if ((snap(cycle[i]) - current).abs() < 1e-6) {
        return snap(cycle[(i + 1) % cycle.length]);
      }
    }
    return snap(cycle.first);
  }

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

  /// How far one wheel notch moves the value: [wheelStep], else [step], else
  /// 1% of the range.
  double get effectiveWheelStep => switch (wheelStep) {
    final double s when s > 0 => s,
    _ => step > 0 ? step : (max - min).abs() / 100,
  };

  /// How far one arrow key press moves the value, or null when the keys
  /// are off.
  double? get effectiveKeyStep => switch (keyStep) {
    final double s when s > 0 => s,
    _ => null,
  };

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
    double? viewBoxWidth,
    double? viewBoxHeight,
    bool? relative,
    bool? jumpOnTap,
    bool? wheel,
    double? wheelStep,
    bool clearWheelStep = false,
    List<double>? doubleTapValues,
    double? keyStep,
    bool clearKeyStep = false,
    DragTrackHitArea? hitArea,
    DragTrackUnits? units,
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
    viewBoxWidth: viewBoxWidth ?? this.viewBoxWidth,
    viewBoxHeight: viewBoxHeight ?? this.viewBoxHeight,
    relative: relative ?? this.relative,
    jumpOnTap: jumpOnTap ?? this.jumpOnTap,
    wheel: wheel ?? this.wheel,
    wheelStep: clearWheelStep ? null : (wheelStep ?? this.wheelStep),
    doubleTapValues: doubleTapValues ?? this.doubleTapValues,
    keyStep: clearKeyStep ? null : (keyStep ?? this.keyStep),
    hitArea: hitArea ?? this.hitArea,
    units: units ?? this.units,
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
    viewBoxWidth,
    viewBoxHeight,
    relative,
    jumpOnTap,
    wheel,
    wheelStep,
    doubleTapValues,
    keyStep,
    hitArea,
    units,
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
