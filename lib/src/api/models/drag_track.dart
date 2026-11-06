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

  /// Pressing anywhere along the track (or anywhere in the [hitArea]) moves
  /// the node there, and dragging from there follows the pointer: a fader
  /// cap jumps to where its slot was tapped, an arc handle to the pointer's
  /// angle round the arc (clamped to its ends). Only for
  /// [DragTrackInput.follow].
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
    this.jumpOnTap = false,
    this.wheel = true,
    this.wheelStep,
    this.doubleTapValues = const [],
    this.keyStep,
    this.hitArea = DragTrackHitArea.self,
    this.units = DragTrackUnits.pixels,
  });

  /// The names of the live values the `track` variable has.
  static const List<String> liveValues = ['value', 'progress', 'dragging'];

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
  double progressOf(double value) {
    if (max == min) return 0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  /// The value at [progress] along the track, snapped to [step].
  double valueAt(double progress) => snap(min + (max - min) * progress.clamp(0.0, 1.0));

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
    bool? jumpOnTap,
    bool? wheel,
    double? wheelStep,
    bool clearWheelStep = false,
    List<double>? doubleTapValues,
    double? keyStep,
    bool clearKeyStep = false,
    DragTrackHitArea? hitArea,
    DragTrackUnits? units,
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
    jumpOnTap: jumpOnTap ?? this.jumpOnTap,
    wheel: wheel ?? this.wheel,
    wheelStep: clearWheelStep ? null : (wheelStep ?? this.wheelStep),
    doubleTapValues: doubleTapValues ?? this.doubleTapValues,
    keyStep: clearKeyStep ? null : (keyStep ?? this.keyStep),
    hitArea: hitArea ?? this.hitArea,
    units: units ?? this.units,
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
    jumpOnTap,
    wheel,
    wheelStep,
    doubleTapValues,
    keyStep,
    hitArea,
    units,
  ];

  /// Creates a [DragTrackModel] from JSON.
  factory DragTrackModel.fromJson(Map json) => _$DragTrackModelFromJson(json);

  @override
  Map toJson() =>
      _$DragTrackModelOmitDefaults(this, _$DragTrackModelToJson(this));
}
