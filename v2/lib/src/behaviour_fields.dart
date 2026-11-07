// A node's behaviours and the fields of their models, declared as PropDefs
// like value_fields.dart declares layout and decoration: each key is the
// JSON key the model reads and writes, with its codec and default. A
// properties panel builds the behaviour sections from these alone.
//
// The models keep their own fromJson/toJson (behaviours.dart); the codecs
// here call them, and test/value_fields_test.dart proves each declaration
// matches the model's JSON. Durations are whole milliseconds.
import 'behaviours.dart';
import 'json.dart';
import 'props.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';

Object? _out(Object? v) => v == null ? null : (v as dynamic).toJson();
Object? _same(Object? v) => v;
Offset? _offsetIn(Object? j) => readList(j)?.length == 2 ? Offset.fromJson(j) : null;

/// A duration or delay in milliseconds (never negative).
const _ms = IntCodec(min: 0);

/// An [AnimationCurve], by the name of its Flutter `Curves` constant. Reads
/// as leniently as the models do ([AnimationCurve.parse]).
final class AnimationCurveCodec extends PropCodec<AnimationCurve> {
  const AnimationCurveCodec();
  @override
  AnimationCurve? decode(Object? json) => AnimationCurve.parse(json);
  @override
  Object encode(AnimationCurve value) => value.name;
  @override
  PropType get type => PropType.enumeration('AnimationCurve', [for (final c in AnimationCurve.values) c.name]);
}

const _curve = AnimationCurveCodec();

// --- object types -------------------------------------------------------------

const motionType = PropType.object('Motion', motionFields);
const motionKeyframeType = PropType.object('MotionKeyframe', motionKeyframeFields);
const loopAnimationType = PropType.object('LoopAnimation', loopAnimationFields);
const transitionType = PropType.object('Transition', transitionFields);
const transitionsType = PropType.object('Transitions', transitionsFields);
const inkWellStyleType = PropType.object('InkWellStyle', inkWellStyleFields);
const stateStylesType = PropType.object('StateStyles', stateStylesFields);
const heroTagType = PropType.object('HeroTag', heroTagFields);
const dragSourceType = PropType.object('DragSource', dragSourceFields);
const dropTargetType = PropType.object('DropTarget', dropTargetFields);
const dragTrackType = PropType.object('DragTrack', dragTrackFields);
const dragMotionType = PropType.object('DragMotion', dragMotionFields);
const revealType = PropType.object('Reveal', revealFields);
const strokePathType = PropType.object('StrokePath', strokePathFields);
const effectAnimationType = PropType.object('EffectAnimation', effectAnimationFields);
const particleEmitterType = PropType.object('ParticleEmitter', particleEmitterFields);

/// One interaction state's patches: node id → a merge patch of that node's
/// JSON (see [StateStyles]). Free-form: a patch can touch any node key.
const nodePatchesType = PropType.json('NodePatches');

Map<String, Json>? _patchesIn(Object? j) {
  final m = readMap(j);
  if (m == null) return null;
  final out = <String, Json>{
    for (final e in m.entries)
      if (readMap(e.value) case final Json p) e.key: p,
  };
  return out.isEmpty ? null : out;
}

/// [HeroTag] in its object form (`{"tag", "flight"}`). The model also reads
/// and writes a bare string tag when the flight is standard.
Object? _heroOut(HeroTag? h) =>
    h == null ? null : {'tag': h.tag, if (h.flight != HeroFlightShuttle.standard) 'flight': h.flight.name};

// --- motion -------------------------------------------------------------------

/// [Motion]: the node's rest pose (a transform over its layout) and how it
/// moves to it.
abstract final class MotionFields {
  /// Pixels.
  static const translateX = PropDef<double>('translateX', Codecs.double, 0);
  static const translateY = PropDef<double>('translateY', Codecs.double, 0);
  static const scale = PropDef<double>('scale', Codecs.double, 1);
  static const scaleX = PropDef<double>('scaleX', Codecs.double, 1);
  static const scaleY = PropDef<double>('scaleY', Codecs.double, 1);

  /// Times the node's size.
  static const shiftX = PropDef<double>('shiftX', Codecs.double, 0);
  static const shiftY = PropDef<double>('shiftY', Codecs.double, 0);
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);

  /// Degrees.
  static const rotate = PropDef<double>('rotate', Codecs.double, 0);
  static const rotateX = PropDef<double>('rotateX', Codecs.double, 0);
  static const rotateY = PropDef<double>('rotateY', Codecs.double, 0);

  /// Turns per second.
  static const spin = PropDef<double>('spin', Codecs.double, 0);
  static const pathProgress = PropDef<double>('pathProgress', Codecs.double, 0);
  static const blur = PropDef<double>('blur', Codecs.positive, 0);
  static const perspective = PropDef<double>('perspective', Codecs.double, 1);

  /// The transform's origin in the box (-1–1, 0 the centre).
  static const originX = PropDef<double>('originX', Codecs.double, 0);
  static const originY = PropDef<double>('originY', Codecs.double, 0);
  static const duration = PropDef<int>('duration', _ms, 0);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.easeInOut);
  static const springStiffness = PropDef<double>('springStiffness', Codecs.double, 380);
  static const springDamping = PropDef<double>('springDamping', Codecs.double, 20);
  static const spinRamp = PropDef<int>('spinRamp', _ms, 800);
  static const loop = PropDef<MotionLoop>('loop', EnumCodec(MotionLoop.values), MotionLoop.none);

  /// Loop runs (0: forever).
  static const repeat = PropDef<int>('repeat', IntCodec(min: 0), 0);
  static const enter = PropDef<bool>('enter', Codecs.bool, false);
  static const enterFrom = PropDef<Motion?>('enterFrom', ValueCodec(Motion.fromJson, _out, motionType), null);
  static const replayKey = PropDef<String?>('replayKey', Codecs.optionalString, null);
  static const backfaceHidden = PropDef<bool>('backfaceHidden', Codecs.bool, false);

  /// An SVG path the node moves along.
  static const path = PropDef<String?>('path', Codecs.optionalString, null);
  static const orientToPath = PropDef<bool>('orientToPath', Codecs.bool, false);
  static const keyframes = PropDef<List<MotionKeyframe>>(
    'keyframes',
    ListCodec(ValueCodec(MotionKeyframe.fromJson, _out, motionKeyframeType)),
    [],
  );
  static const pulseKey = PropDef<String?>('pulseKey', Codecs.optionalString, null);
  static const revealOnScroll = PropDef<bool>('revealOnScroll', Codecs.bool, false);
  static const revealFraction = PropDef<double>('revealFraction', Codecs.double, 0.15);

  static const List<PropDef<Object?>> all = [
    translateX, translateY, scale, scaleX, scaleY, shiftX, shiftY, opacity, rotate, rotateX, rotateY, spin, //
    pathProgress, blur, perspective, originX, originY, duration, delay, curve, springStiffness, springDamping,
    spinRamp, loop, repeat, enter, enterFrom, replayKey, backfaceHidden, path, orientToPath, keyframes, pulseKey,
    revealOnScroll, revealFraction,
  ];
}

List<PropDef<Object?>> motionFields() => MotionFields.all;

/// [MotionKeyframe]: values at [t]; unset values follow the curve.
abstract final class MotionKeyframeFields {
  static const t = PropDef<double>('t', Codecs.double, 0);
  static const translateX = PropDef<double?>('translateX', Codecs.optionalDouble, null);
  static const translateY = PropDef<double?>('translateY', Codecs.optionalDouble, null);
  static const scale = PropDef<double?>('scale', Codecs.optionalDouble, null);
  static const scaleX = PropDef<double?>('scaleX', Codecs.optionalDouble, null);
  static const scaleY = PropDef<double?>('scaleY', Codecs.optionalDouble, null);
  static const opacity = PropDef<double?>('opacity', Codecs.optionalDouble, null);
  static const rotate = PropDef<double?>('rotate', Codecs.optionalDouble, null);
  static const rotateX = PropDef<double?>('rotateX', Codecs.optionalDouble, null);
  static const rotateY = PropDef<double?>('rotateY', Codecs.optionalDouble, null);
  static const pathProgress = PropDef<double?>('pathProgress', Codecs.optionalDouble, null);
  static const List<PropDef<Object?>> all = [
    t, translateX, translateY, scale, scaleX, scaleY, opacity, rotate, rotateX, rotateY, pathProgress, //
  ];
}

List<PropDef<Object?>> motionKeyframeFields() => MotionKeyframeFields.all;

// --- loops --------------------------------------------------------------------

abstract final class LoopAnimationFields {
  static const type = PropDef<LoopAnimationType>('type', EnumCodec(LoopAnimationType.values), LoopAnimationType.pulse);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const duration = PropDef<int>('duration', _ms, 1000);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const reverse = PropDef<bool>('reverse', Codecs.bool, false);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const scaleFrom = PropDef<double>('scaleFrom', Codecs.double, 1);
  static const scaleTo = PropDef<double>('scaleTo', Codecs.double, 1);
  static const opacityFrom = PropDef<double>('opacityFrom', Codecs.double, 1);
  static const opacityTo = PropDef<double>('opacityTo', Codecs.double, 1);
  static const turns = PropDef<double>('turns', Codecs.double, 1);
  static const distance = PropDef<double>('distance', Codecs.double, 10);

  /// Degrees each way.
  static const angle = PropDef<double>('angle', Codecs.double, 4);
  static const List<PropDef<Object?>> all = [
    type, enabled, duration, delay, reverse, curve, scaleFrom, scaleTo, opacityFrom, opacityTo, turns, //
    distance, angle,
  ];
}

List<PropDef<Object?>> loopAnimationFields() => LoopAnimationFields.all;

// --- transitions --------------------------------------------------------------

abstract final class TransitionFields {
  static const duration = PropDef<int>('duration', _ms, 0);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const List<PropDef<Object?>> all = [duration, curve];
}

List<PropDef<Object?>> transitionFields() => TransitionFields.all;

abstract final class TransitionsFields {
  static const style = PropDef<Transition?>('style', ValueCodec(Transition.fromJson, _out, transitionType), null);
  static const opacity = PropDef<Transition?>('opacity', ValueCodec(Transition.fromJson, _out, transitionType), null);
  static const size = PropDef<Transition?>('size', ValueCodec(Transition.fromJson, _out, transitionType), null);
  static const List<PropDef<Object?>> all = [style, opacity, size];
}

List<PropDef<Object?>> transitionsFields() => TransitionsFields.all;

// --- ink and states -----------------------------------------------------------

abstract final class InkWellStyleFields {
  static const overlayColor = PropDef<Color?>('overlayColor', Codecs.optionalColor, null);
  static const splashColor = PropDef<Color?>('splashColor', Codecs.optionalColor, null);
  static const highlightColor = PropDef<Color?>('highlightColor', Codecs.optionalColor, null);
  static const hoverColor = PropDef<Color?>('hoverColor', Codecs.optionalColor, null);
  static const focusColor = PropDef<Color?>('focusColor', Codecs.optionalColor, null);
  static const List<PropDef<Object?>> all = [overlayColor, splashColor, highlightColor, hoverColor, focusColor];
}

List<PropDef<Object?>> inkWellStyleFields() => InkWellStyleFields.all;

/// [StateStyles]: one field per [WidgetState]. Each holds that state's
/// patches (node id → a merge patch of the node's JSON), which are free-form
/// JSON ([nodePatchesType]): a patch can override any key of any node.
abstract final class StateStylesFields {
  static const _codec = ValueCodec<Map<String, Json>?>(_patchesIn, _same, nodePatchesType);
  static const hovered = PropDef<Map<String, Json>?>('hovered', _codec, null);
  static const focused = PropDef<Map<String, Json>?>('focused', _codec, null);
  static const pressed = PropDef<Map<String, Json>?>('pressed', _codec, null);
  static const selected = PropDef<Map<String, Json>?>('selected', _codec, null);
  static const disabled = PropDef<Map<String, Json>?>('disabled', _codec, null);
  static const dragged = PropDef<Map<String, Json>?>('dragged', _codec, null);

  /// In [WidgetState]'s order.
  static const List<PropDef<Object?>> all = [hovered, focused, pressed, selected, disabled, dragged];
}

List<PropDef<Object?>> stateStylesFields() => StateStylesFields.all;

// --- shared elements ----------------------------------------------------------

/// [HeroTag]. Its JSON is `{"tag", "flight"}`, or just the tag string when
/// the flight is standard.
abstract final class HeroTagFields {
  static const tag = PropDef<String>('tag', Codecs.string, '');
  static const flight = PropDef<HeroFlightShuttle>(
    'flight',
    EnumCodec(HeroFlightShuttle.values),
    HeroFlightShuttle.standard,
  );
  static const List<PropDef<Object?>> all = [tag, flight];
}

List<PropDef<Object?>> heroTagFields() => HeroTagFields.all;

// --- drag and drop ------------------------------------------------------------

abstract final class DragSourceFields {
  static const group = PropDef<String>('group', Codecs.string, '');
  static const data = PropDef<String>('data', Codecs.string, '');
  static const start = PropDef<DragStart>('start', EnumCodec(DragStart.values), DragStart.auto);
  static const axis = PropDef<DragAxis>('axis', EnumCodec(DragAxis.values), DragAxis.free);
  static const whileDragging = PropDef<DragSourceStyle>(
    'whileDragging',
    EnumCodec(DragSourceStyle.values),
    DragSourceStyle.ghost,
  );
  static const ghostOpacity = PropDef<double>('ghostOpacity', Codecs.double, 0.35);
  static const feedbackRotation = PropDef<double>('feedbackRotation', Codecs.double, -2);
  static const feedbackScale = PropDef<double>('feedbackScale', Codecs.double, 1);
  static const feedbackOpacity = PropDef<double>('feedbackOpacity', Codecs.double, 1);
  static const feedbackElevation = PropDef<double>('feedbackElevation', Codecs.double, 24);

  /// The node drawn under the pointer instead of this one.
  static const feedbackNodeId = PropDef<String>('feedbackNodeId', Codecs.string, '');
  static const returnSpring = PropDef<bool>('returnSpring', Codecs.bool, true);
  static const springStiffness = PropDef<double>('springStiffness', Codecs.double, 260);
  static const springDamping = PropDef<double>('springDamping', Codecs.double, 14);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [
    group, data, start, axis, whileDragging, ghostOpacity, feedbackRotation, feedbackScale, feedbackOpacity, //
    feedbackElevation, feedbackNodeId, returnSpring, springStiffness, springDamping, enabled,
  ];
}

List<PropDef<Object?>> dragSourceFields() => DragSourceFields.all;

abstract final class DropTargetFields {
  /// The [DragSource] groups it takes.
  static const accepts = PropDef<List<String>>('accepts', Codecs.strings, []);
  static const key = PropDef<String>('key', Codecs.string, '');

  /// A condition on the dragged data.
  static const acceptIf = PropDef<String>('acceptIf', Codecs.string, '');
  static const listNodeId = PropDef<String>('listNodeId', Codecs.string, '');
  static const slot = PropDef<DropSlot>('slot', EnumCodec(DropSlot.values), DropSlot.gap);
  static const slotNodeId = PropDef<String>('slotNodeId', Codecs.string, '');
  static const hoverDelay = PropDef<int>('hoverDelay', _ms, 0);
  static const fullIf = PropDef<String>('fullIf', Codecs.string, '');
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [
    accepts, key, acceptIf, listNodeId, slot, slotNodeId, hoverDelay, fullIf, enabled, //
  ];
}

List<PropDef<Object?>> dropTargetFields() => DropTargetFields.all;

abstract final class DragTrackFields {
  /// The variable the control sets.
  static const variable = PropDef<String>('variable', Codecs.string, '');
  static const shape = PropDef<DragTrackShape>('shape', EnumCodec(DragTrackShape.values), DragTrackShape.line);
  static const min = PropDef<double>('min', Codecs.double, 0);
  static const max = PropDef<double>('max', Codecs.double, 1);
  static const step = PropDef<double>('step', Codecs.double, 0);
  static const defaultValue = PropDef<double?>('defaultValue', Codecs.optionalDouble, null);
  static const input = PropDef<DragTrackInput>('input', EnumCodec(DragTrackInput.values), DragTrackInput.follow);
  static const pixelsPerRange = PropDef<double>('pixelsPerRange', Codecs.double, 200);
  static const x1 = PropDef<double>('x1', Codecs.double, 0);
  static const y1 = PropDef<double>('y1', Codecs.double, 0);
  static const x2 = PropDef<double>('x2', Codecs.double, 0);
  static const y2 = PropDef<double>('y2', Codecs.double, -100);

  /// Degrees about the pivot.
  static const startAngle = PropDef<double>('startAngle', Codecs.double, -135);
  static const endAngle = PropDef<double>('endAngle', Codecs.double, 135);
  static const pivotX = PropDef<double>('pivotX', Codecs.double, 0);
  static const pivotY = PropDef<double>('pivotY', Codecs.double, 0);
  static const rotate = PropDef<bool>('rotate', Codecs.bool, true);
  static const path = PropDef<String?>('path', Codecs.optionalString, null);
  static const orientToPath = PropDef<bool>('orientToPath', Codecs.bool, false);
  static const jumpOnTap = PropDef<bool>('jumpOnTap', Codecs.bool, false);
  static const wheel = PropDef<bool>('wheel', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [
    variable, shape, min, max, step, defaultValue, input, pixelsPerRange, x1, y1, x2, y2, startAngle, endAngle, //
    pivotX, pivotY, rotate, path, orientToPath, jumpOnTap, wheel,
  ];
}

List<PropDef<Object?>> dragTrackFields() => DragTrackFields.all;

abstract final class DragMotionFields {
  static const axis = PropDef<DragAxis>('axis', EnumCodec(DragAxis.values), DragAxis.free);
  static const release = PropDef<DragRelease>('release', EnumCodec(DragRelease.values), DragRelease.snapBack);

  /// The directions it flies off in.
  static const directions = PropDef<List<DragDirection>>(
    'directions',
    ListCodec(EnumCodec(DragDirection.values)),
    DragDirection.values,
  );

  /// A fraction of its size.
  static const distanceThreshold = PropDef<double>('distanceThreshold', Codecs.double, 0.35);
  static const verticalThreshold = PropDef<double?>('verticalThreshold', Codecs.optionalDouble, null);

  /// Pixels per second.
  static const velocityThreshold = PropDef<double>('velocityThreshold', Codecs.double, 800);
  static const rotateFactor = PropDef<double>('rotateFactor', Codecs.double, 0);
  static const originX = PropDef<double>('originX', Codecs.double, 0);
  static const originY = PropDef<double>('originY', Codecs.double, 0);
  static const resistance = PropDef<double>('resistance', Codecs.double, 0);
  static const snapBack = PropDef<int>('snapBack', _ms, 450);
  static const snapCurve = PropDef<AnimationCurve>('snapCurve', _curve, AnimationCurve.spring);
  static const flyOut = PropDef<int>('flyOut', _ms, 320);
  static const flyOutCurve = PropDef<AnimationCurve>('flyOutCurve', _curve, AnimationCurve.easeIn);
  static const flyOutDistance = PropDef<double?>('flyOutDistance', Codecs.optionalDouble, null);
  static const flyOutRotate = PropDef<double>('flyOutRotate', Codecs.double, 0);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const shakeWhenDisabled = PropDef<bool>('shakeWhenDisabled', Codecs.bool, false);
  static const disabledFollow = PropDef<double>('disabledFollow', Codecs.double, 0);

  /// A variable the live drag values are written to.
  static const shareAs = PropDef<String>('shareAs', Codecs.string, '');
  static const restX = PropDef<double>('restX', Codecs.double, 0);
  static const restY = PropDef<double>('restY', Codecs.double, 0);
  static const track = PropDef<DragTrack?>('track', ValueCodec(DragTrack.fromJson, _out, dragTrackType), null);
  static const reorder = PropDef<bool>('reorder', Codecs.bool, false);
  static const follow = PropDef<bool>('follow', Codecs.bool, true);
  static const xVariable = PropDef<String>('xVariable', Codecs.string, '');
  static const yVariable = PropDef<String>('yVariable', Codecs.string, '');
  static const List<PropDef<Object?>> all = [
    axis, release, directions, distanceThreshold, verticalThreshold, velocityThreshold, rotateFactor, originX, //
    originY, resistance, snapBack, snapCurve, flyOut, flyOutCurve, flyOutDistance, flyOutRotate, enabled,
    shakeWhenDisabled, disabledFollow, shareAs, restX, restY, track, reorder, follow, xVariable, yVariable,
  ];
}

List<PropDef<Object?>> dragMotionFields() => DragMotionFields.all;

// --- one-shot effects ---------------------------------------------------------

abstract final class EffectAnimationFields {
  /// The name an action plays it by.
  static const name = PropDef<String>('name', Codecs.string, '');
  static const type = PropDef<EffectAnimationType>(
    'type',
    EnumCodec(EffectAnimationType.values),
    EffectAnimationType.shake,
  );
  static const duration = PropDef<int>('duration', _ms, 520);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const amount = PropDef<double>('amount', Codecs.double, 1);
  static const originX = PropDef<double>('originX', Codecs.double, 0);
  static const originY = PropDef<double>('originY', Codecs.double, 0);
  static const playOnAppear = PropDef<bool>('playOnAppear', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [name, type, duration, delay, amount, originX, originY, playOnAppear];
}

List<PropDef<Object?>> effectAnimationFields() => EffectAnimationFields.all;

abstract final class ParticleEmitterFields {
  static const count = PropDef<int>('count', IntCodec(min: 0), 40);

  /// Over how long the particles leave (0: all at once).
  static const emit = PropDef<int>('emit', _ms, 0);
  static const colors = PropDef<List<Color>>('colors', ListCodec(Codecs.color), ParticleEmitter.defaultColors);
  static const shapes = PropDef<List<ParticleShape>>('shapes', ListCodec(EnumCodec(ParticleShape.values)), [
    ParticleShape.square,
    ParticleShape.strip,
    ParticleShape.circle,
  ]);
  static const size = PropDef<double>('size', Codecs.double, 10);
  static const originX = PropDef<double>('originX', Codecs.double, 0);
  static const originY = PropDef<double>('originY', Codecs.double, 0);
  static const originWidth = PropDef<double>('originWidth', Codecs.double, 0);

  /// Degrees.
  static const direction = PropDef<double>('direction', Codecs.double, 0);
  static const spread = PropDef<double>('spread', Codecs.double, 60);
  static const speed = PropDef<double>('speed', Codecs.double, 700);
  static const gravity = PropDef<double>('gravity', Codecs.double, 900);
  static const lifetime = PropDef<int>('lifetime', _ms, 2600);
  static const playOnAppear = PropDef<bool>('playOnAppear', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [
    count, emit, colors, shapes, size, originX, originY, originWidth, direction, spread, speed, gravity, //
    lifetime, playOnAppear,
  ];
}

List<PropDef<Object?>> particleEmitterFields() => ParticleEmitterFields.all;

// --- paint and scroll ---------------------------------------------------------

abstract final class StrokePathFields {
  /// In the box: fractions or pixels per [xUnit] / [yUnit].
  static const points = PropDef<List<Offset>>(
    'points',
    ListCodec(ValueCodec<Offset>(_offsetIn, _out, PropTypes.offset)),
    [],
  );
  static const xUnit = PropDef<PathUnit>('xUnit', EnumCodec(PathUnit.values), PathUnit.fraction);
  static const yUnit = PropDef<PathUnit>('yUnit', EnumCodec(PathUnit.values), PathUnit.pixels);
  static const curve = PropDef<PathCurve>('curve', EnumCodec(PathCurve.values), PathCurve.straight);
  static const color = PropDef<Color>('color', Codecs.color, Color.white);
  static const width = PropDef<double>('width', Codecs.double, 4);

  /// Dash and gap lengths, alternating; empty is solid.
  static const dashPattern = PropDef<List<double>>('dashPattern', Codecs.doubles, []);
  static const cap = PropDef<StrokeCap>('cap', EnumCodec(StrokeCap.values), StrokeCap.round);
  static const inFront = PropDef<bool>('inFront', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [points, xUnit, yUnit, curve, color, width, dashPattern, cap, inFront];
}

List<PropDef<Object?>> strokePathFields() => StrokePathFields.all;

abstract final class RevealFields {
  /// Where in the viewport (0 top, 1 bottom).
  static const alignment = PropDef<double>('alignment', Codecs.double, 0.5);
  static const duration = PropDef<int>('duration', _ms, 600);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const List<PropDef<Object?>> all = [alignment, duration, delay];
}

List<PropDef<Object?>> revealFields() => RevealFields.all;

// --- Behaviours -----------------------------------------------------------------

/// A node's [Behaviours], one per key of [Behaviours.keys]: stored flat in
/// the node's JSON (`"motion": {...}`, `"tooltip": "..."`), defaults as in
/// [Behaviours.none].
abstract final class BehaviourFields {
  static const motion = PropDef<Motion?>('motion', ValueCodec(Motion.fromJson, _out, motionType), null);

  /// `Transform.scale` about the centre; a value not above 0 reads as 1.
  static const scale = PropDef<double>('scale', Codecs.positive, 1);
  static const loops = PropDef<List<LoopAnimation>>(
    'loops',
    ListCodec(ValueCodec(LoopAnimation.fromJson, _out, loopAnimationType)),
    [],
  );
  static const transitions = PropDef<Transitions>(
    'transitions',
    ValueCodec(Transitions.fromJson, _out, transitionsType),
    Transitions.none,
  );
  static const inkWell = PropDef<InkWellStyle?>(
    'inkWell',
    ValueCodec(InkWellStyle.fromJson, _out, inkWellStyleType),
    null,
  );
  static const states = PropDef<StateStyles>(
    'states',
    ValueCodec(StateStyles.fromJson, _out, stateStylesType),
    StateStyles.none,
  );
  static const tooltip = PropDef<String>('tooltip', Codecs.string, '');
  static const ignorePointer = PropDef<bool>('ignorePointer', Codecs.bool, false);
  static const zoomable = PropDef<bool>('zoomable', Codecs.bool, false);
  static const floating = PropDef<bool>('floating', Codecs.bool, false);
  static const hero = PropDef<HeroTag?>('hero', ValueCodec(HeroTag.fromJson, _heroOut, heroTagType), null);
  static const flightKey = PropDef<String>('flightKey', Codecs.string, '');
  static const draggable = PropDef<DragSource?>(
    'draggable',
    ValueCodec(DragSource.fromJson, _out, dragSourceType),
    null,
  );
  static const dropTarget = PropDef<DropTarget?>(
    'dropTarget',
    ValueCodec(DropTarget.fromJson, _out, dropTargetType),
    null,
  );
  static const drag = PropDef<DragMotion?>('drag', ValueCodec(DragMotion.fromJson, _out, dragMotionType), null);
  static const reveal = PropDef<Reveal?>('reveal', ValueCodec(Reveal.fromJson, _out, revealType), null);
  static const strokePath = PropDef<StrokePath?>(
    'strokePath',
    ValueCodec(StrokePath.fromJson, _out, strokePathType),
    null,
  );
  static const effectAnimations = PropDef<List<EffectAnimation>>(
    'effectAnimations',
    ListCodec(ValueCodec(EffectAnimation.fromJson, _out, effectAnimationType)),
    [],
  );
  static const particles = PropDef<ParticleEmitter?>(
    'particles',
    ValueCodec(ParticleEmitter.fromJson, _out, particleEmitterType),
    null,
  );

  /// Null inherits.
  static const textDirection = PropDef<TextDirection?>('textDirection', OptionalEnumCodec(TextDirection.values), null);

  /// In [Behaviours.keys]' order.
  static const List<PropDef<Object?>> all = [
    motion, scale, loops, transitions, inkWell, states, tooltip, ignorePointer, zoomable, floating, hero, //
    flightKey, draggable, dropTarget, drag, reveal, strokePath, effectAnimations, particles, textDirection,
  ];
}
