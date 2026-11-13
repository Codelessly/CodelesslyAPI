// A node's behaviors and the fields of their models, declared as PropDefs
// like value_fields.dart declares layout and decoration: each key is the
// JSON key the model reads and writes, with its codec and default. A
// properties panel builds the behavior sections from these alone.
//
// The models keep their own fromJson/toJson (behaviors.dart); the codecs
// here call them, and test/value_fields_test.dart proves each declaration
// matches the model's JSON. Durations are whole milliseconds.
import 'behaviors.dart';
import 'custom_paint.dart' show CustomPaint;
import 'custom_paint_fields.dart' show customPaintType;
import 'json.dart';
import 'props.dart';
import 'values/color.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/text.dart';

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
const stickyType = PropType.object('Sticky', stickyFields);
const viewProgressType = PropType.object('ViewProgress', viewProgressFields);
const measureType = PropType.object('Measure', measureFields);
const strokePathType = PropType.object('StrokePath', strokePathFields);
const typewriterType = PropType.object('Typewriter', typewriterFields);
const effectAnimationType = PropType.object('EffectAnimation', effectAnimationFields);
const particleEmitterType = PropType.object('ParticleEmitter', particleEmitterFields);
const flightType = PropType.object('Flight', flightFields);
const motionShimmerType = PropType.object('MotionShimmer', motionShimmerFields);
const gesturePhysicsType = PropType.object('GesturePhysics', gesturePhysicsFields);
const gestureSnapType = PropType.object('GestureSnap', gestureSnapFields);
const flipCardType = PropType.object('FlipCard', flipCardFields);
const flipSpringType = PropType.object('FlipSpring', flipSpringFields);
const tiltType = PropType.object('Tilt', tiltFields);
const transformGestureType = PropType.object('TransformGesture', transformGestureFields);
const transformHandlesType = PropType.object('TransformHandles', transformHandlesFields);

const _physics = ValueCodec(GesturePhysics.fromJson, _out, gesturePhysicsType);

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
Object? _heroOut(HeroTag? h) => h == null
    ? null
    : {
        'tag': h.tag,
        if (h.flight != HeroFlightShuttle.standard) 'flight': h.flight.name,
        if (h.placeholder != HeroPlaceholder.none) 'placeholder': h.placeholder.name,
      };

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

  /// The transform's origin in the box (-1–1, 0 the center).
  static const originX = PropDef<double>('originX', Codecs.double, 0);
  static const originY = PropDef<double>('originY', Codecs.double, 0);
  static const duration = PropDef<int>('duration', _ms, 0);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.easeInOut);

  /// The rotation's own curve; null follows [curve].
  static const rotateCurve = PropDef<AnimationCurve?>(
    'rotateCurve',
    OptionalEnumCodec(AnimationCurve.values),
    null,
  );

  /// The share of the duration in which the opacity arrives (easing out).
  static const fadeShare = PropDef<double>('fadeShare', DoubleCodec(min: 0, max: 1), 1);
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

  /// Holds the entrance at its start while true (bindable).
  static const enterHeld = PropDef<bool>('enterHeld', Codecs.bool, false);
  static const revealFraction = PropDef<double>('revealFraction', Codecs.double, 0.15);

  /// With [orientToPath]: never upside down.
  static const orientUpright = PropDef<bool>('orientUpright', Codecs.bool, false);

  /// With [orientUpright]: heading left mirrors the node, so its front leads.
  static const uprightMirror = PropDef<bool>('uprightMirror', Codecs.bool, false);

  /// A change of position bends this share of its distance off the line.
  static const arc = PropDef<double>('arc', Codecs.double, 0);

  /// Freezes the loop and the spin where they are.
  static const paused = PropDef<bool>('paused', Codecs.bool, false);

  /// Where the loop starts in its cycle (0–1).
  static const phase = PropDef<double>('phase', DoubleCodec(min: 0, max: 1), 0);
  static const pathPacing = PropDef<MotionPathPacing>(
    'pathPacing',
    EnumCodec(MotionPathPacing.values),
    MotionPathPacing.length,
  );

  /// The focus of area pacing, in the path's coordinates.
  static const pathFocusX = PropDef<double>('pathFocusX', Codecs.double, 0);
  static const pathFocusY = PropDef<double>('pathFocusY', Codecs.double, 0);

  /// Reads the progress modulo 1.
  static const pathWrap = PropDef<bool>('pathWrap', Codecs.bool, false);

  /// The path's coordinate space `[width, height]`, stretched over the
  /// node's parent; empty: pixels.
  static const pathViewBox = PropDef<List<double>>('pathViewBox', Codecs.doubles, []);
  static const shimmer = PropDef<MotionShimmer?>(
    'shimmer',
    ValueCodec(MotionShimmer.fromJson, _out, motionShimmerType),
    null,
  );

  static const List<PropDef<Object?>> all = [
    translateX, translateY, scale, scaleX, scaleY, shiftX, shiftY, opacity, rotate, rotateX, rotateY, spin, //
    pathProgress, blur, perspective, originX, originY, duration, delay, curve, rotateCurve, fadeShare,
    springStiffness, springDamping, spinRamp, loop, repeat, enter, enterFrom, replayKey, backfaceHidden, path,
    orientToPath, keyframes, pulseKey, revealOnScroll, enterHeld, revealFraction, orientUpright, uprightMirror, arc,
    paused, phase, pathPacing, pathFocusX, pathFocusY, pathWrap, pathViewBox, shimmer,
  ];
}

List<PropDef<Object?>> motionFields() => MotionFields.all;

/// [MotionShimmer]: a band of light sweeping across the node.
abstract final class MotionShimmerFields {
  static const color = PropDef<Color>('color', Codecs.color, Color.white);
  static const strength = PropDef<double>('strength', DoubleCodec(min: 0, max: 1), 0.8);

  /// A share of the node's size along the sweep.
  static const width = PropDef<double>('width', Codecs.double, 0.44);
  static const duration = PropDef<int>('duration', _ms, 1400);

  /// Degrees: 0 left to right, 90 top to bottom.
  static const angle = PropDef<double>('angle', Codecs.double, 0);
  static const List<PropDef<Object?>> all = [color, strength, width, duration, angle];
}

List<PropDef<Object?>> motionShimmerFields() => MotionShimmerFields.all;

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

  /// Where in its whole loop it starts (0–1).
  static const phase = PropDef<double>('phase', DoubleCodec(min: 0, max: 1), 0);

  /// Milliseconds it runs behind (a phase in time; it doesn't wait).
  static const lag = PropDef<int>('lag', Codecs.int, 0);
  static const List<PropDef<Object?>> all = [
    type, enabled, duration, delay, reverse, curve, scaleFrom, scaleTo, opacityFrom, opacityTo, turns, //
    distance, angle, phase, lag,
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
  static const placeholder = PropDef<HeroPlaceholder>(
    'placeholder',
    EnumCodec(HeroPlaceholder.values),
    HeroPlaceholder.none,
  );
  static const List<PropDef<Object?>> all = [tag, flight, placeholder];
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
  static const feedbackAnchor = PropDef<FeedbackAnchor>(
    'feedbackAnchor',
    EnumCodec(FeedbackAnchor.values),
    FeedbackAnchor.grab,
  );

  /// The return spring (over [returnSpring] and its settings).
  static const physics = PropDef<GesturePhysics?>('physics', _physics, null);
  static const List<PropDef<Object?>> all = [
    group, data, start, axis, whileDragging, ghostOpacity, feedbackRotation, feedbackScale, feedbackOpacity, //
    feedbackElevation, feedbackNodeId, feedbackAnchor, returnSpring, springStiffness, springDamping, enabled, physics,
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
  static const slotSize = PropDef<DropSlotSize>('slotSize', EnumCodec(DropSlotSize.values), DropSlotSize.dragged);

  /// Opens the slot for a drop [acceptIf] refuses too.
  static const slotWhenRefused = PropDef<bool>('slotWhenRefused', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [
    accepts, key, acceptIf, listNodeId, slot, slotNodeId, slotSize, slotWhenRefused, hoverDelay, fullIf, enabled, //
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

  /// The value it's drawn at, from a binding; null reads [variable].
  static const value = PropDef<double?>('value', Codecs.optionalDouble, null);
  static const orientUpright = PropDef<bool>('orientUpright', Codecs.bool, false);

  /// How magnetic the steps are while dragging (0–1).
  static const detent = PropDef<double>('detent', DoubleCodec(min: 0, max: 1), 0);

  /// How far past an end it stretches (0–1).
  static const overscroll = PropDef<double>('overscroll', DoubleCodec(min: 0, max: 1), 0);
  static const settle = PropDef<int>('settle', _ms, 0);
  static const settleCurve = PropDef<AnimationCurve>('settleCurve', _curve, AnimationCurve.easeOutCubic);
  static const settleStiffness = PropDef<double>('settleStiffness', Codecs.double, 380);
  static const settleDamping = PropDef<double>('settleDamping', Codecs.double, 20);

  /// Where it parks while the value is out of range or empty.
  static const parkedProgress = PropDef<double?>('parkedProgress', Codecs.optionalDouble, null);
  static const keyboard = PropDef<bool>('keyboard', Codecs.bool, true);
  static const viewBoxWidth = PropDef<double>('viewBoxWidth', Codecs.positive, 0);
  static const viewBoxHeight = PropDef<double>('viewBoxHeight', Codecs.positive, 0);

  /// A line's ends are multiples of the node's size.
  static const relative = PropDef<bool>('relative', Codecs.bool, false);
  static const wheelStep = PropDef<double?>('wheelStep', Codecs.optionalDouble, null);
  static const doubleTapValues = PropDef<List<double>>('doubleTapValues', Codecs.doubles, []);
  static const keyStep = PropDef<double?>('keyStep', Codecs.optionalDouble, null);
  static const hitArea = PropDef<DragTrackHitArea>(
    'hitArea',
    EnumCodec(DragTrackHitArea.values),
    DragTrackHitArea.self,
  );
  static const units = PropDef<DragTrackUnits>('units', EnumCodec(DragTrackUnits.values), DragTrackUnits.pixels);
  static const fineStep = PropDef<double>('fineStep', Codecs.positive, 0);
  static const finePixelsPerRange = PropDef<double>('finePixelsPerRange', Codecs.positive, 0);
  static const fineHold = PropDef<int>('fineHold', _ms, 380);
  static const fineVariable = PropDef<String>('fineVariable', Codecs.string, '');
  static const snap = PropDef<int>('snap', _ms, 0);
  static const snapCurve = PropDef<AnimationCurve>('snapCurve', _curve, AnimationCurve.easeOutBack);
  static const write = PropDef<bool>('write', Codecs.bool, true);
  static const endless = PropDef<bool>('endless', Codecs.bool, false);
  static const momentum = PropDef<bool>('momentum', Codecs.bool, false);
  static const friction = PropDef<double>('friction', Codecs.double, 2.6);
  static const smooth = PropDef<bool>('smooth', Codecs.bool, false);
  static const gain = PropDef<double>('gain', Codecs.double, 1);
  static const List<PropDef<Object?>> all = [
    variable, shape, min, max, step, defaultValue, input, pixelsPerRange, x1, y1, x2, y2, startAngle, endAngle, //
    pivotX, pivotY, rotate, path, orientToPath, jumpOnTap, wheel, value, orientUpright, detent, overscroll, settle,
    settleCurve, settleStiffness, settleDamping, parkedProgress, keyboard, viewBoxWidth, viewBoxHeight, relative,
    wheelStep, doubleTapValues, keyStep, hitArea, units, fineStep, finePixelsPerRange, fineHold, fineVariable, snap,
    snapCurve, write, endless, momentum, friction, smooth, gain,
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

  /// The release's fling, spring and snap points.
  static const physics = PropDef<GesturePhysics?>('physics', _physics, null);
  static const bounds = PropDef<GestureBounds>('bounds', EnumCodec(GestureBounds.values), GestureBounds.none);

  /// Offsets from rest it stays within (pixels; null no limit).
  static const minX = PropDef<double?>('minX', Codecs.optionalDouble, null);
  static const maxX = PropDef<double?>('maxX', Codecs.optionalDouble, null);
  static const minY = PropDef<double?>('minY', Codecs.optionalDouble, null);
  static const maxY = PropDef<double?>('maxY', Codecs.optionalDouble, null);
  static const List<PropDef<Object?>> all = [
    axis, release, directions, distanceThreshold, verticalThreshold, velocityThreshold, rotateFactor, originX, //
    originY, resistance, snapBack, snapCurve, flyOut, flyOutCurve, flyOutDistance, flyOutRotate, enabled,
    shakeWhenDisabled, disabledFollow, shareAs, restX, restY, track, reorder, follow, xVariable, yVariable, physics,
    bounds, minX, maxX, minY, maxY,
  ];
}

List<PropDef<Object?>> dragMotionFields() => DragMotionFields.all;

// --- gestures -----------------------------------------------------------------

/// [GesturePhysics]: the release a drag, a drag source's return and a
/// transform gesture share.
abstract final class GesturePhysicsFields {
  static const stiffness = PropDef<double>('stiffness', Codecs.double, 380);
  static const damping = PropDef<double>('damping', Codecs.double, 32);
  static const mass = PropDef<double>('mass', Codecs.double, 1);

  /// The spring as a bounce and a settle time, over stiffness and damping.
  static const bounce = PropDef<double?>('bounce', Codecs.optionalDouble, null);
  static const duration = PropDef<int?>('duration', Codecs.optionalInt, null);
  static const fling = PropDef<bool>('fling', Codecs.bool, true);

  /// The share of a fling's speed lost per second.
  static const friction = PropDef<double>('friction', DoubleCodec(min: 0, max: 1), 0.865);
  static const minFlingVelocity = PropDef<double>('minFlingVelocity', Codecs.double, 50);
  static const maxFlingVelocity = PropDef<double>('maxFlingVelocity', Codecs.double, 8000);
  static const overscroll = PropDef<double>('overscroll', DoubleCodec(min: 0, max: 1), 0.5);
  static const snap = PropDef<GestureSnap?>('snap', ValueCodec(GestureSnap.fromJson, _out, gestureSnapType), null);
  static const List<PropDef<Object?>> all = [
    stiffness, damping, mass, bounce, duration, fling, friction, minFlingVelocity, maxFlingVelocity, overscroll, //
    snap,
  ];
}

List<PropDef<Object?>> gesturePhysicsFields() => GesturePhysicsFields.all;

abstract final class GestureSnapFields {
  static const kind = PropDef<SnapKind>('kind', EnumCodec(SnapKind.values), SnapKind.points);

  /// Offsets from rest.
  static const points = PropDef<List<Offset>>(
    'points',
    ListCodec(ValueCodec<Offset>(_offsetIn, _out, PropTypes.offset)),
    [],
  );
  static const gridX = PropDef<double>('gridX', Codecs.positive, 0);
  static const gridY = PropDef<double>('gridY', Codecs.positive, 0);
  static const projectVelocity = PropDef<bool>('projectVelocity', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [kind, points, gridX, gridY, projectVelocity];
}

List<PropDef<Object?>> gestureSnapFields() => GestureSnapFields.all;

/// [FlipCard] (node key `flip`): a card that turns over.
abstract final class FlipCardFields {
  static const axis = PropDef<FlipAxis>('axis', EnumCodec(FlipAxis.values), FlipAxis.y);
  static const flipped = PropDef<bool>('flipped', Codecs.bool, false);
  static const tapToFlip = PropDef<bool>('tapToFlip', Codecs.bool, true);
  static const dragToFlip = PropDef<bool>('dragToFlip', Codecs.bool, false);

  /// A boolean variable it follows and writes.
  static const variable = PropDef<String>('variable', Codecs.string, '');
  static const spring = PropDef<FlipSpring>(
    'spring',
    ValueCodec(FlipSpring.fromJson, _out, flipSpringType),
    FlipSpring(),
  );
  static const List<PropDef<Object?>> all = [axis, flipped, tapToFlip, dragToFlip, variable, spring];
}

List<PropDef<Object?>> flipCardFields() => FlipCardFields.all;

abstract final class FlipSpringFields {
  static const stiffness = PropDef<double>('stiffness', Codecs.double, 380);
  static const damping = PropDef<double>('damping', Codecs.double, 36);
  static const mass = PropDef<double>('mass', Codecs.double, 1);
  static const List<PropDef<Object?>> all = [stiffness, damping, mass];
}

List<PropDef<Object?>> flipSpringFields() => FlipSpringFields.all;

abstract final class TiltFields {
  /// The motion values at the edges.
  static const max = PropDef<Motion>('max', ValueCodec(Motion.fromJson, _out, motionType), Tilt.defaultMax);
  static const hover = PropDef<bool>('hover', Codecs.bool, true);
  static const drag = PropDef<bool>('drag', Codecs.bool, true);
  static const reset = PropDef<int>('reset', _ms, 400);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.easeOutCubic);
  static const List<PropDef<Object?>> all = [max, hover, drag, reset, curve];
}

List<PropDef<Object?>> tiltFields() => TiltFields.all;

abstract final class TransformGestureFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const target = PropDef<TransformTarget>('target', EnumCodec(TransformTarget.values), TransformTarget.node);
  static const pan = PropDef<TransformPan>('pan', EnumCodec(TransformPan.values), TransformPan.always);
  static const zoom = PropDef<bool>('zoom', Codecs.bool, true);
  static const rotate = PropDef<bool>('rotate', Codecs.bool, false);
  static const minScale = PropDef<double>('minScale', Codecs.double, 1);
  static const maxScale = PropDef<double>('maxScale', Codecs.double, 4);
  static const bounds = PropDef<GestureBounds>('bounds', EnumCodec(GestureBounds.values), GestureBounds.cover);

  /// 0 turns double tap zoom off.
  static const doubleTapScale = PropDef<double>('doubleTapScale', Codecs.double, 2.5);
  static const wheel = PropDef<WheelZoom>('wheel', EnumCodec(WheelZoom.values), WheelZoom.ctrlZoom);

  /// Degrees; 0 is free.
  static const rotationSnap = PropDef<double>('rotationSnap', Codecs.double, 0);
  static const physics = PropDef<GesturePhysics?>('physics', _physics, null);
  static const xVariable = PropDef<String>('xVariable', Codecs.string, '');
  static const yVariable = PropDef<String>('yVariable', Codecs.string, '');
  static const scaleVariable = PropDef<String>('scaleVariable', Codecs.string, '');
  static const rotationVariable = PropDef<String>('rotationVariable', Codecs.string, '');
  static const scaleXVariable = PropDef<String>('scaleXVariable', Codecs.string, '');
  static const scaleYVariable = PropDef<String>('scaleYVariable', Codecs.string, '');
  static const handles = PropDef<TransformHandles?>(
    'handles',
    ValueCodec(TransformHandles.fromJson, _out, transformHandlesType),
    null,
  );

  /// The pose given from data; null for the gesture's own.
  static const x = PropDef<double?>('x', Codecs.optionalDouble, null);
  static const y = PropDef<double?>('y', Codecs.optionalDouble, null);
  static const scale = PropDef<double?>('scale', Codecs.optionalDouble, null);
  static const rotation = PropDef<double?>('rotation', Codecs.optionalDouble, null);
  static const scaleX = PropDef<double?>('scaleX', Codecs.optionalDouble, null);
  static const scaleY = PropDef<double?>('scaleY', Codecs.optionalDouble, null);
  static const List<PropDef<Object?>> all = [
    enabled, target, pan, zoom, rotate, minScale, maxScale, bounds, doubleTapScale, wheel, rotationSnap, physics, //
    xVariable, yVariable, scaleVariable, rotationVariable, scaleXVariable, scaleYVariable, handles, x, y, scale,
    rotation, scaleX, scaleY,
  ];
}

List<PropDef<Object?>> transformGestureFields() => TransformGestureFields.all;

abstract final class TransformHandlesFields {
  static const corners = PropDef<bool>('corners', Codecs.bool, true);
  static const edges = PropDef<bool>('edges', Codecs.bool, false);
  static const rotateKnob = PropDef<bool>('rotateKnob', Codecs.bool, true);

  /// Degrees the knob snaps to; 0 is free.
  static const snapAngle = PropDef<double>('snapAngle', Codecs.double, 0);
  static const aspectLock = PropDef<bool>('aspectLock', Codecs.bool, true);
  static const minWidth = PropDef<double>('minWidth', Codecs.double, 16);
  static const minHeight = PropDef<double>('minHeight', Codecs.double, 16);

  /// 0 for no limit.
  static const maxWidth = PropDef<double>('maxWidth', Codecs.double, 0);
  static const maxHeight = PropDef<double>('maxHeight', Codecs.double, 0);
  static const outline = PropDef<bool>('outline', Codecs.bool, true);
  static const color = PropDef<Color>('color', Codecs.color, TransformHandles.defaultColor);
  static const handleSize = PropDef<double>('handleSize', Codecs.double, 12);
  static const selectionVariable = PropDef<String>('selectionVariable', Codecs.string, '');
  static const selectionKey = PropDef<String>('selectionKey', Codecs.string, '');
  static const List<PropDef<Object?>> all = [
    corners, edges, rotateKnob, snapAngle, aspectLock, minWidth, minHeight, maxWidth, maxHeight, outline, color, //
    handleSize, selectionVariable, selectionKey,
  ];
}

List<PropDef<Object?>> transformHandlesFields() => TransformHandlesFields.all;

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

  /// Swings of a shake, wiggle or jelly (blinks of a flash); 0 the type's own.
  static const cycles = PropDef<double>('cycles', Codecs.positive, 0);

  /// A `keyframes` effect's poses at times 0–1 (from rest, back to rest).
  static const keyframes = PropDef<List<MotionKeyframe>>(
    'keyframes',
    ListCodec(ValueCodec(MotionKeyframe.fromJson, _out, motionKeyframeType)),
    [],
  );
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const List<PropDef<Object?>> all = [
    name, type, duration, delay, amount, originX, originY, playOnAppear, cycles, keyframes, curve, //
  ];
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

  /// Wait after the cue (ms).
  static const delay = PropDef<int>('delay', _ms, 0);

  /// Speed lost per second, e^(-drag).
  static const drag = PropDef<double>('drag', Codecs.positive, 0);

  /// The fastest fall (px/s; 0: no limit).
  static const terminalVelocity = PropDef<double>('terminalVelocity', Codecs.positive, 0);

  /// Side-to-side sway (px).
  static const sway = PropDef<double>('sway', Codecs.double, 0);

  /// Turning over in 3D (radians per second, up to).
  static const flutter = PropDef<double>('flutter', Codecs.positive, 8);

  /// Spin (degrees per second, up to).
  static const spin = PropDef<double>('spin', Codecs.double, 515);

  /// Fade out over the end of each particle's life (ms).
  static const fadeOut = PropDef<int>('fadeOut', _ms, 500);

  /// Two cannons: every other particle mirrored across the middle.
  static const mirror = PropDef<bool>('mirror', Codecs.bool, false);

  /// The text emoji particles draw.
  static const glyph = PropDef<String>('glyph', Codecs.string, '');
  /// The image `image` particles draw (a URL).
  static const image = PropDef<String>('image', Codecs.string, '');
  static const List<PropDef<Object?>> all = [
    count, emit, colors, shapes, size, originX, originY, originWidth, direction, spread, speed, gravity, //
    lifetime, playOnAppear, delay, drag, terminalVelocity, sway, flutter, spin, fadeOut, mirror, glyph, image,
  ];
}

abstract final class FlightFields {
  /// 0: on the node's spring.
  static const duration = PropDef<int>('duration', _ms, 0);
  static const curve = PropDef<AnimationCurve>('curve', EnumCodec(AnimationCurve.values), AnimationCurve.easeInOut);

  /// Rise of the path's control point above the higher end (px).
  static const lift = PropDef<double>('lift', Codecs.double, 0);

  /// The same as a share of the distance flown (the larger wins).
  static const liftShare = PropDef<double>('liftShare', Codecs.double, 0);

  /// Scale at the middle of the flight.
  static const swell = PropDef<double>('swell', Codecs.positive, 1);

  /// Turns over the flight, clockwise when flying right.
  static const turns = PropDef<double>('turns', Codecs.double, 0);

  /// Fading dots left behind.
  static const trail = PropDef<int>('trail', IntCodec(min: 0), 0);
  static const trailColor = PropDef<Color>('trailColor', Codecs.color, Color(0xFFFFC83D));
  static const List<PropDef<Object?>> all = [duration, curve, lift, liftShare, swell, turns, trail, trailColor];
}

List<PropDef<Object?>> flightFields() => FlightFields.all;

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
  static const progress = PropDef<double>('progress', DoubleCodec(min: 0, max: 1), 1, doc: 'Fraction of the stroke drawn along its length.');

  /// Dash and gap lengths, alternating; empty is solid.
  static const dashPattern = PropDef<List<double>>('dashPattern', Codecs.doubles, []);
  static const cap = PropDef<StrokeCap>('cap', EnumCodec(StrokeCap.values), StrokeCap.round);
  static const inFront = PropDef<bool>('inFront', Codecs.bool, false);

  /// How long a running app takes to draw the line along its length (when
  /// it shows, when [drawKey] changes, when [progress] changes); 0 shows it.
  static const drawMs = PropDef<int>('drawMs', _ms, 0, doc: 'Draw-on time (ms) in a running app; 0 shows it at once.');
  static const drawDelayMs = PropDef<int>('drawDelayMs', _ms, 0, doc: 'Wait (ms) before drawing.');
  static const drawCurve = PropDef<AnimationCurve>(
    'drawCurve',
    EnumCodec(AnimationCurve.values),
    AnimationCurve.easeInOut,
    doc: 'How the drawing eases.',
  );
  static const drawKey = PropDef<String>('drawKey', Codecs.string, '', doc: 'Draws again from nothing when it changes.');
  static const fillColor = PropDef<Color?>('fillColor', Codecs.color, null,
      doc: 'Fills the shape the points enclose, behind the line (fading in as it draws).');
  static const untilWidth = PropDef<bool>('untilWidth', Codecs.bool, false,
      doc: 'Draws only the segments that start within the box width (a long ruled line fits any width).');
  static const List<PropDef<Object?>> all = [
    points, xUnit, yUnit, curve, color, width, progress, dashPattern, cap, inFront, //
    drawMs, drawDelayMs, drawCurve, drawKey, fillColor, untilWidth,
  ];
}

List<PropDef<Object?>> strokePathFields() => StrokePathFields.all;

abstract final class TypewriterFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true, doc: 'Off, the whole text shows.');
  static const charsPerSecond = PropDef<double>('charsPerSecond', DoubleCodec(min: 0), 40, doc: 'Typing speed.');
  static const delayMs = PropDef<int>('delayMs', _ms, 0, doc: 'Wait (ms) before the first character.');
  static const caret = PropDef<bool>('caret', Codecs.bool, true, doc: 'A blinking block after the last character while it types.');
  static const caretColor = PropDef<Color?>('caretColor', Codecs.color, null, doc: 'Null uses the text color.');
  static const caretWidth = PropDef<double>('caretWidth', Codecs.positive, 0, doc: '0 is about half the font size.');
  static const caretHeight = PropDef<double>('caretHeight', Codecs.positive, 0,
      doc: 'Centered on the text\'s middle; 0 is about three quarters of the line.');
  static const caretGap = PropDef<double>('caretGap', Codecs.double, 1, doc: 'Space between the last character and the caret.');
  static const caretAlignStyle = PropDef<TextStyle>('caretAlignStyle', Codecs.textStyle, TextStyle.empty,
      doc: 'With a caret height: the style whose middle it centers on (empty: the text\'s).');
  static const blinkMs = PropDef<int>('blinkMs', IntCodec(min: 1), 500, doc: 'How long the caret stays on, and off.');
  static const skip = PropDef<bool>('skip', Codecs.bool, false, doc: 'Shows the rest at once.');
  static const playKey = PropDef<String>('playKey', Codecs.string, '', doc: 'Types again from the start when it changes.');
  static const holdAtMs = PropDef<int?>('holdAtMs', Codecs.optionalInt, null,
      doc: 'Stops the typing clock this many ms in (delay included): a part-typed still. Null types to the end.');
  static const grow = PropDef<bool>('grow', Codecs.bool, false,
      doc: 'Only as tall as the lines typed so far (off: the whole text\'s size from the start).');
  static const List<PropDef<Object?>> all = [enabled, charsPerSecond, delayMs, caret, caretColor, caretWidth, caretHeight, caretGap, caretAlignStyle, blinkMs, skip, playKey, holdAtMs, grow];
}

List<PropDef<Object?>> typewriterFields() => TypewriterFields.all;

abstract final class RevealFields {
  /// Where in the viewport (0 top, 1 bottom).
  static const alignment = PropDef<double>('alignment', Codecs.double, 0.5);
  static const duration = PropDef<int>('duration', _ms, 600);
  static const delay = PropDef<int>('delay', _ms, 0);

  /// Stays revealed while the content moves, until the user scrolls away.
  static const follow = PropDef<bool>('follow', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [alignment, duration, delay, follow];
}

List<PropDef<Object?>> revealFields() => RevealFields.all;

abstract final class StickyFields {
  /// Distance from the view's leading edge where it pins (px).
  static const offset = PropDef<double>('offset', Codecs.double, 0);
  static const List<PropDef<Object?>> all = [offset];
}

List<PropDef<Object?>> stickyFields() => StickyFields.all;

abstract final class ViewProgressFields {
  static const mode = PropDef<ViewProgressMode>('mode', EnumCodec(ViewProgressMode.values), ViewProgressMode.travel);

  /// Where progress is 0 (travel) or where the line is (pass): a fraction
  /// of the viewport from its leading edge.
  static const from = PropDef<double>('from', Codecs.double, 1);

  /// Where progress is 1 (travel).
  static const to = PropDef<double>('to', Codecs.double, 0);

  /// Pixels added to both.
  static const offset = PropDef<double>('offset', Codecs.double, 0);

  /// A variable the progress is written to.
  static const variable = PropDef<String>('variable', Codecs.string, '');

  /// The key it's written under, for a map variable.
  static const key = PropDef<String>('key', Codecs.string, '');
  static const List<PropDef<Object?>> all = [mode, from, to, offset, variable, key];
}

List<PropDef<Object?>> viewProgressFields() => ViewProgressFields.all;

abstract final class MeasureFields {
  /// The variable its box is written to.
  static const variable = PropDef<String>('variable', Codecs.string, '');

  /// The key it's written under, for a map variable.
  static const key = PropDef<String>('key', Codecs.string, '');

  /// An ancestor node whose box it's measured in; empty: the screen.
  static const relativeTo = PropDef<String>('relativeTo', Codecs.string, '');
  static const List<PropDef<Object?>> all = [variable, key, relativeTo];
}

List<PropDef<Object?>> measureFields() => MeasureFields.all;

// --- Behaviors -----------------------------------------------------------------

/// A node's [Behaviors], one per key of [Behaviors.keys]: stored flat in
/// the node's JSON (`"motion": {...}`, `"tooltip": "..."`), defaults as in
/// [Behaviors.none].
abstract final class BehaviorFields {
  static const motion = PropDef<Motion?>('motion', ValueCodec(Motion.fromJson, _out, motionType), null);

  /// `Transform.scale` about the center; a value not above 0 reads as 1.
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
  static const flight = PropDef<Flight?>('flight', ValueCodec(Flight.fromJson, _out, flightType), null);
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
  static const typewriter = PropDef<Typewriter?>(
    'typewriter',
    ValueCodec(Typewriter.fromJson, _out, typewriterType),
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

  /// A two-sided card that turns over (a runtime 3D turn, not a mirror).
  static const flip = PropDef<FlipCard?>('flip', ValueCodec(FlipCard.fromJson, _out, flipCardType), null);
  static const tilt = PropDef<Tilt?>('tilt', ValueCodec(Tilt.fromJson, _out, tiltType), null);
  static const transformGesture = PropDef<TransformGesture?>(
    'transformGesture',
    ValueCodec(TransformGesture.fromJson, _out, transformGestureType),
    null,
  );

  /// Pinned in its scrolling view while its parent is in view.
  static const sticky = PropDef<Sticky?>('sticky', ValueCodec(Sticky.fromJson, _out, stickyType), null);

  /// `${view.progress}` through the viewport.
  static const viewProgress = PropDef<ViewProgress?>(
    'viewProgress',
    ValueCodec(ViewProgress.fromJson, _out, viewProgressType),
    null,
  );

  /// Its laid-out box, written to a variable.
  static const measure = PropDef<Measure?>('measure', ValueCodec(Measure.fromJson, _out, measureType), null);

  /// Flutter's `CustomPaint`: draw lists behind and over the content.
  static const customPaint = PropDef<CustomPaint?>(
    'customPaint',
    ValueCodec(CustomPaint.fromJson, _out, customPaintType),
    null,
  );

  /// In [Behaviors.keys]' order.
  static const List<PropDef<Object?>> all = [
    motion, scale, loops, transitions, inkWell, states, tooltip, ignorePointer, zoomable, floating, hero, //
    flightKey, flight, draggable, dropTarget, drag, reveal, strokePath, typewriter, effectAnimations, particles,
    textDirection, flip, tilt, transformGesture, sticky, viewProgress, measure, customPaint,
  ];
}
