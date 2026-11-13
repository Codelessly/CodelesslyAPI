// A node's behaviors and the fields of their models, declared as PropDefs
// like value_fields.dart declares layout and decoration: each key is the
// JSON key the model reads and writes, with its codec and default. A
// properties panel builds the behavior sections from these alone.
//
// The models keep their own fromJson/toJson (behaviors.dart); the codecs
// here call them, and test/document/declared_fields_test.dart proves each declaration
// matches the model's JSON. Durations are whole milliseconds.
import 'behaviors.dart';
import 'custom_paint.dart' show CustomPaint;
import 'custom_paint_fields.dart' show customPaintType;
import 'json.dart';
import 'path_follow.dart';
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
const pathFollowType = PropType.object('PathFollow', pathFollowFields);
const poseType = PropType.object('Pose', poseFields);
const nodeAnimationType = PropType.object('NodeAnimation', nodeAnimationFields);
const animationTrackType = PropType.object('AnimationTrack', animationTrackFields);
const keyframeType = PropType.object('Keyframe', keyframeFields);
const waveType = PropType.object('Wave', waveFields);
const animationRepeatType = PropType.object('AnimationRepeat', animationRepeatFields);
const springType = PropType.object('Spring', springFields);
const transitionType = PropType.object('Transition', transitionFields);
const inkWellStyleType = PropType.object('InkWellStyle', inkWellStyleFields);
const stateStylesType = PropType.object('StateStyles', stateStylesFields);
const heroTagType = PropType.object('HeroTag', heroTagFields);
const dragSourceType = PropType.object('DragSource', dragSourceFields);
const dropTargetType = PropType.object('DropTarget', dropTargetFields);
const trackType = PropType.object('Track', trackFields);
const dismissibleType = PropType.object('DismissibleBehavior', dismissibleFields);
const panType = PropType.object('Pan', panFields);
const revealType = PropType.object('Reveal', revealFields);
const stickyType = PropType.object('Sticky', stickyFields);
const viewProgressType = PropType.object('ViewProgress', viewProgressFields);
const measureType = PropType.object('Measure', measureFields);
const strokePathType = PropType.object('StrokePath', strokePathFields);
const typewriterType = PropType.object('Typewriter', typewriterFields);
const particleEmitterType = PropType.object('ParticleEmitter', particleEmitterFields);
const flightType = PropType.object('Flight', flightFields);
const shimmerType = PropType.object('Shimmer', shimmerFields);
const gesturePhysicsType = PropType.object('GesturePhysics', gesturePhysicsFields);
const gestureSnapType = PropType.object('GestureSnap', gestureSnapFields);
const flipCardType = PropType.object('FlipCard', flipCardFields);
const tiltType = PropType.object('Tilt', tiltFields);
const transformGestureType = PropType.object('TransformGesture', transformGestureFields);
const transformHandlesType = PropType.object('TransformHandles', transformHandlesFields);

const _physics = ValueCodec(GesturePhysics.fromJson, _out, gesturePhysicsType);

/// A [Spring] codec over its owner's default (what the model writes).
Spring? _springIn(Object? j) => Spring.fromJson(j);
Spring? _settleSpringIn(Object? j) => Spring.fromJson(j, fallback: Track.defaultSettleSpring);
Object? _settleSpringOut(Spring s) => s.toJsonOver(Track.defaultSettleSpring);
Spring? _physicsSpringIn(Object? j) => Spring.fromJson(j, fallback: GesturePhysics.defaultSpring);
Object? _physicsSpringOut(Spring s) => s.toJsonOver(GesturePhysics.defaultSpring);
Spring? _flipSpringIn(Object? j) => Spring.fromJson(j, fallback: FlipCard.defaultSpring);
Object? _flipSpringOut(Spring s) => s.toJsonOver(FlipCard.defaultSpring);

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

/// [Motion]: a transform over the node's layout (Flutter's `Transform`).
abstract final class MotionFields {
  /// Pixels.
  static const translateX = PropDef<double>('translateX', Codecs.double, 0);
  static const translateY = PropDef<double>('translateY', Codecs.double, 0);

  /// Times the node's size (`FractionalTranslation`).
  static const shiftX = PropDef<double>('shiftX', Codecs.double, 0);
  static const shiftY = PropDef<double>('shiftY', Codecs.double, 0);

  /// The axis factors multiply [scale].
  static const scale = PropDef<double>('scale', Codecs.double, 1);
  static const scaleX = PropDef<double>('scaleX', Codecs.double, 1);
  static const scaleY = PropDef<double>('scaleY', Codecs.double, 1);

  /// Degrees, about z.
  static const rotate = PropDef<double>('rotate', Codecs.double, 0);

  /// Degrees, in 3D.
  static const rotateX = PropDef<double>('rotateX', Codecs.double, 0);
  static const rotateY = PropDef<double>('rotateY', Codecs.double, 0);

  /// How strongly a 3D rotation is seen in depth (0 flat).
  static const perspective = PropDef<double>('perspective', Codecs.double, 1);

  /// The point scale and rotation are about (`Transform.alignment`).
  static const alignment = PropDef<Alignment>('alignment', Codecs.alignment, Alignment.center);
  static const backfaceHidden = PropDef<bool>('backfaceHidden', Codecs.bool, false);

  /// A path the node sits on.
  static const path = PropDef<PathFollow?>('path', ValueCodec(PathFollow.fromJson, _out, pathFollowType), null);

  static const List<PropDef<Object?>> all = [
    translateX, translateY, shiftX, shiftY, scale, scaleX, scaleY, rotate, rotateX, rotateY, perspective, //
    alignment, backfaceHidden, path,
  ];
}

List<PropDef<Object?>> motionFields() => MotionFields.all;

/// [PathFollow]: a place along an SVG path.
abstract final class PathFollowFields {
  /// SVG path data.
  static const path = PropDef<String>('path', Codecs.string, '');

  /// The path's coordinate space `[width, height]`, stretched over the
  /// node's parent; empty: pixels from the node's place.
  static const viewBox = PropDef<List<double>>('viewBox', Codecs.doubles, []);

  /// 0–1 of its length; wraps on a closed path.
  static const progress = PropDef<double>('progress', Codecs.double, 0);
  static const orient = PropDef<PathOrient>('orient', EnumCodec(PathOrient.values), PathOrient.none);

  static const List<PropDef<Object?>> all = [path, viewBox, progress, orient];
}

List<PropDef<Object?>> pathFollowFields() => PathFollowFields.all;

/// [Pose]: a [Motion] with a fade and a blur (flat).
abstract final class PoseFields {
  static const opacity = PropDef<double>('opacity', DoubleCodec(min: 0, max: 1), 1);
  static const blur = PropDef<double>('blur', Codecs.positive, 0);
  static const List<PropDef<Object?>> all = [...MotionFields.all, opacity, blur];
}

List<PropDef<Object?>> poseFields() => PoseFields.all;

/// [Shimmer]: a band of light across the node.
abstract final class ShimmerFields {
  static const color = PropDef<Color>('color', Codecs.color, Color.white);
  static const strength = PropDef<double>('strength', DoubleCodec(min: 0, max: 1), 0.8);

  /// A share of the node's size along the sweep.
  static const width = PropDef<double>('width', Codecs.double, 0.44);

  /// Degrees: 0 left to right, 90 top to bottom.
  static const angle = PropDef<double>('angle', Codecs.double, 0);

  /// 0 off the start side, 1 off the end (the `shimmer` preset sweeps it).
  static const position = PropDef<double>('position', Codecs.double, 0.5);
  static const List<PropDef<Object?>> all = [color, strength, width, angle, position];
}

List<PropDef<Object?>> shimmerFields() => ShimmerFields.all;

// --- animations -----------------------------------------------------------------

/// [NodeAnimation]: an `AnimationController` and its tracks.
abstract final class NodeAnimationFields {
  /// Unique on the node; what `animate` and `${animation.<id>}` name.
  static const id = PropDef<String>('id', Codecs.string, '');

  /// A short form ([AnimationPresets]); its params below.
  static const preset = PropDef<String?>('preset', Codecs.optionalString, null);
  static const params = PropDef<Object?>('params', Codecs.any, null);
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// Milliseconds; empty: the preset's, else 300.
  static const duration = PropDef<int?>('duration', Codecs.optionalInt, null);
  static const reverseDuration = PropDef<int?>('reverseDuration', Codecs.optionalInt, null);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const curve = PropDef<AnimationCurve?>('curve', OptionalEnumCodec(AnimationCurve.values), null);
  static const repeat = PropDef<AnimationRepeat?>(
    'repeat',
    ValueCodec(AnimationRepeat.fromJson, _out, animationRepeatType),
    null,
  );
  static const autoplay = PropDef<bool?>('autoplay', Codecs.optionalBool, null);

  /// A change plays it from the start (bindable).
  static const playKey = PropDef<String?>('playKey', Codecs.optionalString, null);
  static const paused = PropDef<bool>('paused', Codecs.bool, false);

  /// Where a play starts in its cycle (0–1).
  static const phase = PropDef<double>('phase', DoubleCodec(min: 0, max: 1), 0);
  static const spring = PropDef<Spring?>('spring', ValueCodec(_springIn, _out, springType), null);

  /// An expression giving its value (0–1) instead of a clock.
  static const progress = PropDef<String?>('progress', Codecs.optionalString, null);
  static const alignment = PropDef<Alignment?>('alignment', Codecs.optionalAlignment, null);
  static const tracks = PropDef<List<AnimationTrack>>(
    'tracks',
    ListCodec(ValueCodec(AnimationTrack.fromJson, _out, animationTrackType)),
    [],
  );

  /// Where the design canvas draws it (a share of a cycle); empty: not
  /// applied there.
  static const previewAt = PropDef<double?>('previewAt', Codecs.optionalDouble, null);

  /// Ms to speed up from still, and to slow to a stop when paused.
  static const ramp = PropDef<int>('ramp', _ms, 0);

  /// Waits to start until this share of the node is in view.
  static const visibleFraction = PropDef<double?>('visibleFraction', Codecs.optionalDouble, null);
  static const List<PropDef<Object?>> all = [
    id, preset, params, enabled, duration, reverseDuration, delay, curve, repeat, autoplay, playKey, paused, phase, //
    spring, progress, alignment, tracks, previewAt, ramp, visibleFraction,
  ];
}

List<PropDef<Object?>> nodeAnimationFields() => NodeAnimationFields.all;

/// [AnimationTrack]: one tween.
abstract final class AnimationTrackFields {
  static const id = PropDef<String>('id', Codecs.string, '');

  /// A binding path (`motion.rotate`, `opacity`, `decoration.fills[0].color`).
  static const path = PropDef<String>('path', Codecs.string, '');
  static const node = PropDef<String>('node', Codecs.string, '');
  static const variable = PropDef<String>('variable', Codecs.string, '');

  /// A number, a color or an expression; empty: the property's own value.
  static const from = PropDef<Object?>('from', Codecs.any, null);
  static const to = PropDef<Object?>('to', Codecs.any, null);
  static const keyframes = PropDef<List<Keyframe>>(
    'keyframes',
    ListCodec(ValueCodec(Keyframe.fromJson, _out, keyframeType)),
    [],
  );
  static const wave = PropDef<List<Wave>>('wave', ListCodec(ValueCodec(Wave.fromJson, _out, waveType)), []);

  /// `Interval(begin, end)`.
  static const interval = PropDef<List<double>>('interval', Codecs.doubles, [0, 1]);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const blend = PropDef<TrackBlend>('blend', EnumCodec(TrackBlend.values), TrackBlend.replace);
  static const interpolation = PropDef<KeyframeInterpolation>(
    'interpolation',
    EnumCodec(KeyframeInterpolation.values),
    KeyframeInterpolation.linear,
  );
  static const List<PropDef<Object?>> all = [
    id, path, node, variable, from, to, keyframes, wave, interval, curve, blend, interpolation, //
  ];
}

List<PropDef<Object?>> animationTrackFields() => AnimationTrackFields.all;

/// [Keyframe]: a `TweenSequence` stop.
abstract final class KeyframeFields {
  static const at = PropDef<double>('at', DoubleCodec(min: 0, max: 1), 0);
  static const value = PropDef<Object?>('value', Codecs.any, null);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const List<PropDef<Object?>> all = [at, value, curve];
}

List<PropDef<Object?>> keyframeFields() => KeyframeFields.all;

/// [Wave]: a sine added to a track.
abstract final class WaveFields {
  static const cycles = PropDef<double>('cycles', Codecs.double, 1);
  static const amplitude = PropDef<double>('amplitude', Codecs.double, 1);
  static const phase = PropDef<double>('phase', Codecs.double, 0);
  static const decay = PropDef<double>('decay', Codecs.double, 0);
  static const rectify = PropDef<bool>('rectify', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [cycles, amplitude, phase, decay, rectify];
}

List<PropDef<Object?>> waveFields() => WaveFields.all;

/// [AnimationRepeat]: `repeat(reverse:, count:)`.
abstract final class AnimationRepeatFields {
  static const reverse = PropDef<bool>('reverse', Codecs.bool, false);

  /// 0: forever.
  static const count = PropDef<int>('count', IntCodec(min: 0), 0);
  static const List<PropDef<Object?>> all = [reverse, count];
}

List<PropDef<Object?>> animationRepeatFields() => AnimationRepeatFields.all;

/// [Spring]: Flutter's `SpringDescription`, physical or by duration and
/// bounce.
abstract final class SpringFields {
  static const stiffness = PropDef<double?>('stiffness', Codecs.optionalDouble, null);
  static const damping = PropDef<double?>('damping', Codecs.optionalDouble, null);
  static const mass = PropDef<double>('mass', Codecs.double, 1);

  /// `withDurationAndBounce`: ms, and 0 (none) to 1.
  static const duration = PropDef<int>('duration', IntCodec(min: 1), 500);
  static const bounce = PropDef<double>('bounce', Codecs.double, 0);
  static const List<PropDef<Object?>> all = [stiffness, damping, mass, duration, bounce];
}

List<PropDef<Object?>> springFields() => SpringFields.all;

// --- transitions --------------------------------------------------------------

/// [Transition]: how changes of one property path animate.
abstract final class TransitionFields {
  /// A binding path or a prefix of one (`motion`, `motion.rotate`,
  /// `opacity`); `*` for every path.
  static const property = PropDef<String>('property', Codecs.string, '');
  static const duration = PropDef<int>('duration', _ms, 0);
  static const delay = PropDef<int>('delay', _ms, 0);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);

  /// Replaces [duration] and [curve].
  static const spring = PropDef<Spring?>('spring', ValueCodec(_springIn, _out, springType), null);
  static const keyframes = PropDef<List<Keyframe>>(
    'keyframes',
    ListCodec(ValueCodec(Keyframe.fromJson, _out, keyframeType)),
    [],
  );
  static const interpolation = PropDef<KeyframeInterpolation>(
    'interpolation',
    EnumCodec(KeyframeInterpolation.values),
    KeyframeInterpolation.linear,
  );

  static const List<PropDef<Object?>> all = [property, duration, delay, curve, spring, keyframes, interpolation];
}

List<PropDef<Object?>> transitionFields() => TransitionFields.all;

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

/// [DragSource] (node key `draggable`): Flutter's `Draggable`.
abstract final class DragSourceFields {
  static const group = PropDef<String>('group', Codecs.string, '');
  static const data = PropDef<String>('data', Codecs.string, '');
  static const start = PropDef<DragStart>('start', EnumCodec(DragStart.values), DragStart.auto);
  static const axis = PropDef<DragAxis>('axis', EnumCodec(DragAxis.values), DragAxis.free);

  /// What stays where it was picked up.
  static const childWhenDragging = PropDef<DragSourceStyle>(
    'childWhenDragging',
    EnumCodec(DragSourceStyle.values),
    DragSourceStyle.ghost,
  );
  static const ghostOpacity = PropDef<double>('ghostOpacity', Codecs.double, 0.35);

  /// The node drawn under the pointer instead of this one.
  static const feedback = PropDef<String>('feedback', Codecs.string, '');
  static const dragAnchor = PropDef<DragAnchor>('dragAnchor', EnumCodec(DragAnchor.values), DragAnchor.child);
  static const feedbackRotation = PropDef<double>('feedbackRotation', Codecs.double, -2);
  static const feedbackScale = PropDef<double>('feedbackScale', Codecs.double, 1);
  static const feedbackOpacity = PropDef<double>('feedbackOpacity', Codecs.double, 1);
  static const feedbackElevation = PropDef<double>('feedbackElevation', Codecs.double, 24);

  /// The spring an unaccepted drop flies home on; `false`: none.
  static const returnSpring = PropDef<Spring?>(
    'returnSpring',
    ValueCodec(_returnSpringIn, _returnSpringOut, springType),
    DragSource.defaultSpring,
  );
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const List<PropDef<Object?>> all = [
    group, data, start, axis, childWhenDragging, ghostOpacity, feedback, dragAnchor, feedbackRotation, //
    feedbackScale, feedbackOpacity, feedbackElevation, returnSpring, enabled,
  ];
}

Spring? _returnSpringIn(Object? j) => DragSource.fromJson({'returnSpring': j})!.returnSpring;
Object? _returnSpringOut(Spring? s) => s == null ? false : s.toJsonOver(DragSource.defaultSpring);

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
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const slotSize = PropDef<DropSlotSize>('slotSize', EnumCodec(DropSlotSize.values), DropSlotSize.dragged);

  static const List<PropDef<Object?>> all = [
    accepts, key, acceptIf, listNodeId, slot, slotNodeId, slotSize, enabled, //
  ];
}

List<PropDef<Object?>> dropTargetFields() => DropTargetFields.all;

/// [Track] (node key `track`): a value set by dragging (Flutter's `Slider`).
abstract final class TrackFields {
  /// Off, it takes no pointer, wheel or keys.
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// The variable the control sets.
  static const variable = PropDef<String>('variable', Codecs.string, '');

  /// The value it's drawn at, from a binding; null reads [variable].
  static const value = PropDef<double?>('value', Codecs.optionalDouble, null);
  static const min = PropDef<double>('min', Codecs.double, 0);
  static const max = PropDef<double>('max', Codecs.double, 1);
  static const step = PropDef<double>('step', Codecs.positive, 0);

  /// Off, an arc turns past its ends (a combination dial).
  static const clamp = PropDef<bool>('clamp', Codecs.bool, true);
  static const input = PropDef<TrackInput>('input', EnumCodec(TrackInput.values), TrackInput.follow);
  static const allowedInteraction = PropDef<TrackInteraction>(
    'allowedInteraction',
    EnumCodec(TrackInteraction.values),
    TrackInteraction.slideThumb,
  );
  static const hitArea = PropDef<TrackHitArea>('hitArea', EnumCodec(TrackHitArea.values), TrackHitArea.self);
  static const pixelsPerRange = PropDef<double>('pixelsPerRange', Codecs.double, 200);

  /// Null: the step (else 1% of the range); 0: off.
  static const wheelStep = PropDef<double?>('wheelStep', Codecs.optionalDouble, null);
  static const keyStep = PropDef<double?>('keyStep', Codecs.optionalDouble, null);
  static const shape = PropDef<TrackShape>('shape', EnumCodec(TrackShape.values), TrackShape.line);
  static const x1 = PropDef<double>('x1', Codecs.double, 0);
  static const y1 = PropDef<double>('y1', Codecs.double, 0);
  static const x2 = PropDef<double>('x2', Codecs.double, 0);
  static const y2 = PropDef<double>('y2', Codecs.double, -100);

  /// A line's ends are multiples of the node's size.
  static const relative = PropDef<bool>('relative', Codecs.bool, false);
  static const units = PropDef<TrackUnits>('units', EnumCodec(TrackUnits.values), TrackUnits.pixels);

  /// Degrees: the arc's start, and its turn to the end.
  static const startAngle = PropDef<double>('startAngle', Codecs.double, -135);
  static const sweepAngle = PropDef<double>('sweepAngle', Codecs.double, 270);
  static const pivotX = PropDef<double>('pivotX', Codecs.double, 0);
  static const pivotY = PropDef<double>('pivotY', Codecs.double, 0);
  static const rotate = PropDef<bool>('rotate', Codecs.bool, true);

  /// A path's SVG data, view box and orientation.
  static const path = PropDef<PathFollow?>('path', ValueCodec(PathFollow.fromJson, _out, pathFollowType), null);

  /// How magnetic the steps are while dragging (0–1).
  static const detent = PropDef<double>('detent', DoubleCodec(min: 0, max: 1), 0);

  /// How far past an end it stretches (0–1).
  static const overscroll = PropDef<double>('overscroll', DoubleCodec(min: 0, max: 1), 0);

  /// A fling's coast (fling, friction); null stops where let go.
  static const physics = PropDef<GesturePhysics?>('physics', _physics, null);
  static const settle = PropDef<int>('settle', _ms, 0);
  static const settleCurve = PropDef<AnimationCurve>('settleCurve', _curve, AnimationCurve.easeOutCubic);
  static const settleSpring = PropDef<Spring>(
    'settleSpring',
    ValueCodec(_settleSpringIn, _settleSpringOut, springType),
    Track.defaultSettleSpring,
  );
  static const snap = PropDef<int>('snap', _ms, 0);
  static const snapCurve = PropDef<AnimationCurve>('snapCurve', _curve, AnimationCurve.easeOutBack);

  static const List<PropDef<Object?>> all = [
    enabled, variable, value, min, max, step, clamp, input, allowedInteraction, hitArea, pixelsPerRange, //
    wheelStep, keyStep, shape, x1, y1, x2, y2, relative, units, startAngle, sweepAngle, pivotX, pivotY, rotate,
    path, detent, overscroll, physics, settle, settleCurve, settleSpring, snap, snapCurve,
  ];
}

List<PropDef<Object?>> trackFields() => TrackFields.all;

Spring? _springOrNull(Object? j) => Spring.fromJson(j);
Map<DragDirection, double>? _thresholdsIn(Object? j) => readMap(j) == null
    ? null
    : {
        for (final d in DragDirection.values)
          if (readDouble(readMap(j)![d.name]) case final double t) d: t,
      };
Object? _thresholdsOut(Map<DragDirection, double> m) => {for (final e in m.entries) e.key.name: writeDouble(e.value)};

/// [DismissibleBehavior] (node key `dismissible`): Flutter's `Dismissible`.
abstract final class DismissibleFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);

  /// The directions it can be dismissed in.
  static const directions = PropDef<List<DragDirection>>(
    'directions',
    ListCodec(EnumCodec(DragDirection.values)),
    [DragDirection.left, DragDirection.right],
  );
  static const axis = PropDef<DragAxis>('axis', EnumCodec(DragAxis.values), DragAxis.free);

  /// Per direction, the share of the node's size to travel (0.4 when not named).
  static const dismissThresholds = PropDef<Map<DragDirection, double>>(
    'dismissThresholds',
    ValueCodec(_thresholdsIn, _thresholdsOut, PropType.json('DismissThresholds')),
    {},
  );

  /// Pixels per second.
  static const flingVelocity = PropDef<double>('flingVelocity', Codecs.positive, 700);
  static const resistance = PropDef<double>('resistance', DoubleCodec(min: 0, max: 1), 0);
  static const movementDuration = PropDef<int>('movementDuration', _ms, 200);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);

  /// Null: [movementDuration] and [curve].
  static const returnDuration = PropDef<int?>('returnDuration', Codecs.optionalInt, null);
  static const returnCurve = PropDef<AnimationCurve?>('returnCurve', OptionalEnumCodec(AnimationCurve.values), null);
  static const returnSpring = PropDef<Spring?>('returnSpring', ValueCodec(_springOrNull, _out, springType), null);

  static const List<PropDef<Object?>> all = [
    enabled, directions, axis, dismissThresholds, flingVelocity, resistance, movementDuration, curve, //
    returnDuration, returnCurve, returnSpring,
  ];
}

List<PropDef<Object?>> dismissibleFields() => DismissibleFields.all;

/// [Pan] (node key `pan`): follows the pointer.
abstract final class PanFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const axis = PropDef<DragAxis>('axis', EnumCodec(DragAxis.values), DragAxis.free);
  static const release = PropDef<PanRelease>('release', EnumCodec(PanRelease.values), PanRelease.snapBack);

  /// The spring back without physics.
  static const returnDuration = PropDef<int>('returnDuration', _ms, 450);
  static const returnCurve = PropDef<AnimationCurve>('returnCurve', _curve, AnimationCurve.spring);

  /// Its rest, from its layout's place (pixels).
  static const x = PropDef<double>('x', Codecs.double, 0);
  static const y = PropDef<double>('y', Codecs.double, 0);
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
    enabled, axis, release, returnDuration, returnCurve, x, y, xVariable, yVariable, physics, bounds, minX, maxX, //
    minY, maxY,
  ];
}

List<PropDef<Object?>> panFields() => PanFields.all;

// --- gestures -----------------------------------------------------------------

/// [GesturePhysics]: the release a drag, a drag source's return and a
/// transform gesture share.
abstract final class GesturePhysicsFields {
  static const spring = PropDef<Spring>(
    'spring',
    ValueCodec(_physicsSpringIn, _physicsSpringOut, springType),
    GesturePhysics.defaultSpring,
  );
  static const fling = PropDef<bool>('fling', Codecs.bool, true);

  /// The share of a fling's speed lost per second.
  static const friction = PropDef<double>('friction', DoubleCodec(min: 0, max: 1), 0.865);
  static const minFlingVelocity = PropDef<double>('minFlingVelocity', Codecs.double, 50);
  static const maxFlingVelocity = PropDef<double>('maxFlingVelocity', Codecs.double, 8000);
  static const overscroll = PropDef<double>('overscroll', DoubleCodec(min: 0, max: 1), 0.5);
  static const snap = PropDef<GestureSnap?>('snap', ValueCodec(GestureSnap.fromJson, _out, gestureSnapType), null);
  static const List<PropDef<Object?>> all = [spring, fling, friction, minFlingVelocity, maxFlingVelocity, overscroll, snap];
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
  static const List<PropDef<Object?>> all = [kind, points, gridX, gridY];
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
  static const spring = PropDef<Spring>('spring', ValueCodec(_flipSpringIn, _flipSpringOut, springType), FlipCard.defaultSpring);
  static const List<PropDef<Object?>> all = [axis, flipped, tapToFlip, dragToFlip, variable, spring];
}

List<PropDef<Object?>> flipCardFields() => FlipCardFields.all;


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
    enabled, target, pan, zoom, rotate, minScale, maxScale, bounds, doubleTapScale, wheel, physics, //
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

/// **Schema 3 only** ([StrokePath]): schema 4 writes a `customPaint` path op.
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
  /// Its animation controllers.
  static const animations = PropDef<List<NodeAnimation>>(
    'animations',
    ListCodec(ValueCodec(NodeAnimation.fromJson, _out, nodeAnimationType)),
    [],
  );
  /// How changes animate, one per property path.
  static const transitions = PropDef<List<Transition>>(
    'transitions',
    ListCodec(ValueCodec(Transition.fromJson, _out, transitionType)),
    [],
  );

  /// A band of light over what it paints.
  static const shimmer = PropDef<Shimmer?>('shimmer', ValueCodec(Shimmer.fromJson, _out, shimmerType), null);
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

  /// A value set by dragging (Flutter's `Slider`, along any path).
  static const track = PropDef<Track?>('track', ValueCodec(Track.fromJson, _out, trackType), null);

  /// Swiped away (Flutter's `Dismissible`).
  static const dismissible = PropDef<DismissibleBehavior?>(
    'dismissible',
    ValueCodec(DismissibleBehavior.fromJson, _out, dismissibleType),
    null,
  );

  /// Follows the pointer.
  static const pan = PropDef<Pan?>('pan', ValueCodec(Pan.fromJson, _out, panType), null);

  /// A reorderable list row's drag handle (`ReorderableDragStartListener`).
  static const reorderHandle = PropDef<bool>('reorderHandle', Codecs.bool, false);
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
  static const particles = PropDef<ParticleEmitter?>(
    'particles',
    ValueCodec(ParticleEmitter.fromJson, _out, particleEmitterType),
    null,
  );

  /// Null inherits.
  static const textDirection = PropDef<TextDirection?>('textDirection', OptionalEnumCodec(TextDirection.values), null);

  /// Flutter's `DefaultTextStyle`: the style the text below starts from.
  static const defaultTextStyle = PropDef<TextStyle?>('defaultTextStyle', _optionalTextStyle, null,
      doc: 'The text style every text style of this node and its descendants is merged over (Flutter\'s DefaultTextStyle); '
          'the nearest one wins ({} gives Flutter\'s defaults back). Unset everywhere: Flutter\'s defaults, the font\'s own line height.');

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
    motion, scale, animations, transitions, shimmer, inkWell, states, tooltip, ignorePointer, floating, hero, //
    flightKey, flight, draggable, dropTarget, track, dismissible, pan, reorderHandle, reveal, strokePath, typewriter,
    particles, textDirection, defaultTextStyle, flip, tilt, transformGesture, sticky, viewProgress, measure, customPaint,
  ];
}

TextStyle? _optionalTextStyleIn(Object? j) => readMap(j) == null ? null : TextStyle.fromJson(j);
const _optionalTextStyle = ValueCodec<TextStyle?>(_optionalTextStyleIn, _out, PropTypes.textStyle);
