import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../codelessly_api.dart';

part 'transform_gesture.g.dart';

/// What a [TransformGestureModel] moves.
enum TransformTarget {
  /// The node itself, over its parent: a sticker on a board, or a map's
  /// content inside a clipped viewport frame. Bounds are the parent's box.
  node,

  /// The node's content, inside the node's own clipped box, which stays
  /// put: a photo frame. Bounds are the node's own box.
  content;

  /// Displayable name.
  String get prettify => switch (this) {
    TransformTarget.node => 'Node (moves over its parent)',
    TransformTarget.content => 'Content (zooms inside the node)',
  };
}

/// When one finger (or a mouse) pans a [TransformGestureModel].
enum TransformPan {
  /// Always.
  always,

  /// Only while zoomed in past [TransformGestureModel.minScale]; at rest a
  /// one-finger drag goes to the parent (a photo pager, a dismiss drag).
  whenZoomed,

  /// Never; two fingers still move the focal point while pinching.
  never;

  /// Displayable name.
  String get prettify => switch (this) {
    TransformPan.always => 'Always',
    TransformPan.whenZoomed => 'When zoomed in',
    TransformPan.never => 'Never',
  };
}

/// What the mouse wheel does over a [TransformGestureModel].
enum WheelZoom {
  /// Nothing; the wheel scrolls the page.
  none,

  /// Control (or Command) + wheel zooms around the pointer, as browsers
  /// send trackpad pinches; a plain wheel scrolls the page.
  ctrlZoom,

  /// A plain wheel zooms around the pointer.
  zoom,

  /// A plain wheel pans; Control + wheel zooms.
  pan;

  /// Displayable name.
  String get prettify => switch (this) {
    WheelZoom.none => 'None',
    WheelZoom.ctrlZoom => 'Ctrl + wheel zooms',
    WheelZoom.zoom => 'Wheel zooms',
    WheelZoom.pan => 'Wheel pans, ctrl zooms',
  };
}

/// On-canvas handles that make a node an editable object, as in a sticker
/// or collage editor or a floor plan: corner handles scale it, edge handles
/// stretch it, a knob rotates it. See [TransformGestureModel.handles].
@JsonSerializable()
class TransformHandlesModel with Equatable, SerializableMixin {
  /// Corner handles scale the node (uniformly with [aspectLock]).
  final bool corners;

  /// Edge handles stretch one axis ([TransformGestureModel.scaleXVariable],
  /// [TransformGestureModel.scaleYVariable]). Hidden with [aspectLock].
  final bool edges;

  /// A knob above the top edge rotates the node around its centre.
  final bool rotateKnob;

  /// Degrees the knob snaps to, e.g. 15; 0 is free (Shift snaps to 15°).
  final double snapAngle;

  /// Corner handles keep the aspect ratio.
  final bool aspectLock;

  /// The smallest drawn width, in logical pixels.
  final double minWidth;

  /// The smallest drawn height.
  final double minHeight;

  /// The largest drawn width; 0 for no limit.
  final double maxWidth;

  /// The largest drawn height; 0 for no limit.
  final double maxHeight;

  /// Draws a selection outline around the transformed box.
  final bool outline;

  /// Colour of the outline and handles, as hex (`#2F80ED`).
  final String color;

  /// Size of a handle in logical pixels; its touch target is at least 32.
  final double handleSize;

  /// A text variable holding the selected object's key: handles show only
  /// while it equals [selectionKey], and tapping the node writes its key.
  /// Empty: handles always show.
  final String selectionVariable;

  /// This node's key in [selectionVariable], e.g. `${item.id}`; empty for
  /// the node's id.
  final String selectionKey;

  /// Creates a [TransformHandlesModel].
  const TransformHandlesModel({
    this.corners = true,
    this.edges = false,
    this.rotateKnob = true,
    this.snapAngle = 0,
    this.aspectLock = true,
    this.minWidth = 16,
    this.minHeight = 16,
    this.maxWidth = 0,
    this.maxHeight = 0,
    this.outline = true,
    this.color = '#2F80ED',
    this.handleSize = 12,
    this.selectionVariable = '',
    this.selectionKey = '',
  });

  /// Returns a copy with the given values replaced.
  TransformHandlesModel copyWith({
    bool? corners,
    bool? edges,
    bool? rotateKnob,
    double? snapAngle,
    bool? aspectLock,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    bool? outline,
    String? color,
    double? handleSize,
    String? selectionVariable,
    String? selectionKey,
  }) => TransformHandlesModel(
    corners: corners ?? this.corners,
    edges: edges ?? this.edges,
    rotateKnob: rotateKnob ?? this.rotateKnob,
    snapAngle: snapAngle ?? this.snapAngle,
    aspectLock: aspectLock ?? this.aspectLock,
    minWidth: minWidth ?? this.minWidth,
    minHeight: minHeight ?? this.minHeight,
    maxWidth: maxWidth ?? this.maxWidth,
    maxHeight: maxHeight ?? this.maxHeight,
    outline: outline ?? this.outline,
    color: color ?? this.color,
    handleSize: handleSize ?? this.handleSize,
    selectionVariable: selectionVariable ?? this.selectionVariable,
    selectionKey: selectionKey ?? this.selectionKey,
  );

  @override
  List<Object?> get props => [
    corners,
    edges,
    rotateKnob,
    snapAngle,
    aspectLock,
    minWidth,
    minHeight,
    maxWidth,
    maxHeight,
    outline,
    color,
    handleSize,
    selectionVariable,
    selectionKey,
  ];

  /// Creates a [TransformHandlesModel] from JSON.
  factory TransformHandlesModel.fromJson(Map json) =>
      _$TransformHandlesModelFromJson(json);

  @override
  Map toJson() => _$TransformHandlesModelOmitDefaults(
    this,
    _$TransformHandlesModelToJson(this),
  );
}

/// Makes a node pannable, zoomable and rotatable by touch, mouse and
/// trackpad: pinch and ctrl+wheel zoom around the focal point, one finger
/// pans, two fingers rotate, a double tap zooms to a point, a release
/// flings and settles by [physics] within [bounds] and [minScale] to
/// [maxScale]. Optional [handles] make it an editable object.
///
/// The pose (x, y, scale, rotation, scaleX, scaleY) binds two-way to
/// variables ([xVariable], ...): the gesture writes them, and a change from
/// elsewhere (a zoom slider) springs the node there. Inside the node the
/// pose reads as `${transform.x}`, `${transform.scale}`, ...; each change
/// runs its `changed` reactions and the end of a gesture its `changeEnd`
/// reactions, both with the pose in `${result}`.
///
/// See `CodelesslyEditor/docs/gestures_api.md`.
@JsonSerializable()
class TransformGestureModel with Equatable, SerializableMixin {
  /// Whether the gestures work. Bindable as `transform.enabled`.
  final bool enabled;

  /// What moves.
  @JsonKey(unknownEnumValue: TransformTarget.node)
  final TransformTarget target;

  /// When one finger pans.
  @JsonKey(unknownEnumValue: TransformPan.always)
  final TransformPan pan;

  /// Whether pinch, wheel and double tap zoom.
  final bool zoom;

  /// Whether two fingers rotate.
  final bool rotate;

  /// The smallest scale. Past it the scale rubber-bands and springs back.
  final double minScale;

  /// The largest scale.
  final double maxScale;

  /// What the node is kept inside of.
  @JsonKey(unknownEnumValue: GestureBounds.cover)
  final GestureBounds bounds;

  /// The scale a double tap zooms to, around the tapped point; a double tap
  /// while zoomed goes back to [minScale]. 0 turns double tap zoom off.
  final double doubleTapScale;

  /// What the mouse wheel does.
  @JsonKey(unknownEnumValue: WheelZoom.ctrlZoom)
  final WheelZoom wheel;

  /// Degrees the rotation settles to a multiple of on release; 0 is free.
  final double rotationSnap;

  /// The fling, spring and overscroll; null for [PhysicsModel.standard].
  final PhysicsModel? physics;

  /// A number variable holding the horizontal offset in pixels, two-way.
  final String xVariable;

  /// A number variable holding the vertical offset, two-way.
  final String yVariable;

  /// A number variable holding the scale, two-way: a zoom slider.
  final String scaleVariable;

  /// A number variable holding the rotation in degrees, two-way.
  final String rotationVariable;

  /// A number variable holding the horizontal stretch from edge handles.
  final String scaleXVariable;

  /// A number variable holding the vertical stretch from edge handles.
  final String scaleYVariable;

  /// Handles that make the node an editable object; null for none.
  final TransformHandlesModel? handles;

  /// Creates a [TransformGestureModel].
  const TransformGestureModel({
    this.enabled = true,
    this.target = TransformTarget.node,
    this.pan = TransformPan.always,
    this.zoom = true,
    this.rotate = false,
    this.minScale = 1,
    this.maxScale = 4,
    this.bounds = GestureBounds.cover,
    this.doubleTapScale = 2.5,
    this.wheel = WheelZoom.ctrlZoom,
    this.rotationSnap = 0,
    this.physics,
    this.xVariable = '',
    this.yVariable = '',
    this.scaleVariable = '',
    this.rotationVariable = '',
    this.scaleXVariable = '',
    this.scaleYVariable = '',
    this.handles,
  });

  /// What the first form, [BaseNode.zoomable], amounts to: content zooms
  /// inside the node up to 4×, pans once zoomed, a double tap zooms 2.5×.
  static const TransformGestureModel zoomable = TransformGestureModel(
    target: TransformTarget.content,
    pan: TransformPan.whenZoomed,
  );

  /// The keys in [BaseNode.variables] that bind the pose from data
  /// (read-only), and [enabledVariableKey].
  static const List<String> poseKeys = [
    'transform.x',
    'transform.y',
    'transform.scale',
    'transform.rotation',
    'transform.scaleX',
    'transform.scaleY',
  ];

  /// The key in [BaseNode.variables] that binds [enabled].
  static const String enabledVariableKey = 'transform.enabled';

  /// The names of the live values the `transform` variable has.
  static const List<String> liveValues = [
    'x',
    'y',
    'scale',
    'rotation',
    'scaleX',
    'scaleY',
    'active',
    'selected',
  ];

  /// The physics in effect.
  PhysicsModel get effectivePhysics => physics ?? PhysicsModel.standard;

  /// Whether one finger may pan at [scale].
  bool pansAt(double scale) => switch (pan) {
    TransformPan.always => true,
    TransformPan.whenZoomed => scale > minScale + 0.001,
    TransformPan.never => false,
  };

  /// The variable names this model reads and writes, by pose key.
  Map<String, String> get boundVariables => {
    for (final (String key, String name) in [
      ('x', xVariable),
      ('y', yVariable),
      ('scale', scaleVariable),
      ('rotation', rotationVariable),
      ('scaleX', scaleXVariable),
      ('scaleY', scaleYVariable),
    ])
      if (name.trim().isNotEmpty) key: name.trim(),
  };

  /// Returns a copy with the given values replaced.
  TransformGestureModel copyWith({
    bool? enabled,
    TransformTarget? target,
    TransformPan? pan,
    bool? zoom,
    bool? rotate,
    double? minScale,
    double? maxScale,
    GestureBounds? bounds,
    double? doubleTapScale,
    WheelZoom? wheel,
    double? rotationSnap,
    PhysicsModel? physics,
    bool clearPhysics = false,
    String? xVariable,
    String? yVariable,
    String? scaleVariable,
    String? rotationVariable,
    String? scaleXVariable,
    String? scaleYVariable,
    TransformHandlesModel? handles,
    bool clearHandles = false,
  }) => TransformGestureModel(
    enabled: enabled ?? this.enabled,
    target: target ?? this.target,
    pan: pan ?? this.pan,
    zoom: zoom ?? this.zoom,
    rotate: rotate ?? this.rotate,
    minScale: minScale ?? this.minScale,
    maxScale: maxScale ?? this.maxScale,
    bounds: bounds ?? this.bounds,
    doubleTapScale: doubleTapScale ?? this.doubleTapScale,
    wheel: wheel ?? this.wheel,
    rotationSnap: rotationSnap ?? this.rotationSnap,
    physics: clearPhysics ? null : physics ?? this.physics,
    xVariable: xVariable ?? this.xVariable,
    yVariable: yVariable ?? this.yVariable,
    scaleVariable: scaleVariable ?? this.scaleVariable,
    rotationVariable: rotationVariable ?? this.rotationVariable,
    scaleXVariable: scaleXVariable ?? this.scaleXVariable,
    scaleYVariable: scaleYVariable ?? this.scaleYVariable,
    handles: clearHandles ? null : handles ?? this.handles,
  );

  @override
  List<Object?> get props => [
    enabled,
    target,
    pan,
    zoom,
    rotate,
    minScale,
    maxScale,
    bounds,
    doubleTapScale,
    wheel,
    rotationSnap,
    physics,
    xVariable,
    yVariable,
    scaleVariable,
    rotationVariable,
    scaleXVariable,
    scaleYVariable,
    handles,
  ];

  /// Creates a [TransformGestureModel] from JSON.
  factory TransformGestureModel.fromJson(Map json) =>
      _$TransformGestureModelFromJson(json);

  @override
  Map toJson() => _$TransformGestureModelOmitDefaults(
    this,
    _$TransformGestureModelToJson(this),
  );
}

/// The gesture presets the Editor offers and `gestures.preset` applies:
/// what each writes on a node, by node property.
abstract final class GesturePresets {
  /// Preset names and what they set: `transformGesture`, `drag`.
  static Map<String, Map<String, Object?>> get all => {
    'photoViewer': {
      'transformGesture': const TransformGestureModel(
        target: TransformTarget.content,
        pan: TransformPan.whenZoomed,
        maxScale: 5,
        wheel: WheelZoom.ctrlZoom,
        physics: PhysicsModel(bounce: 0, durationMs: 350),
      ).toJson(),
    },
    'mapCanvas': {
      'transformGesture': const TransformGestureModel(
        minScale: 0.5,
        maxScale: 6,
        doubleTapScale: 2,
        wheel: WheelZoom.zoom,
        scaleVariable: 'mapZoom',
        physics: PhysicsModel(bounce: 0.1, durationMs: 400),
      ).toJson(),
    },
    'bottomSheetFling': {
      'drag': const DragModel(
        axis: DragAxis.vertical,
        release: DragRelease.stay,
        minY: -560,
        maxY: 0,
        yVariable: 'sheetY',
        physics: PhysicsModel(
          bounce: 0.12,
          durationMs: 420,
          snap: SnapModel(
            points: [SnapPoint(), SnapPoint(y: -280), SnapPoint(y: -560)],
          ),
        ),
      ).toJson(),
    },
    'sticker': {
      'transformGesture': const TransformGestureModel(
        rotate: true,
        minScale: 0.3,
        maxScale: 4,
        bounds: GestureBounds.contain,
        doubleTapScale: 0,
        wheel: WheelZoom.ctrlZoom,
        physics: PhysicsModel(fling: false, bounce: 0.2, durationMs: 300),
        handles: TransformHandlesModel(snapAngle: 15),
      ).toJson(),
    },
    'puck': {
      'drag': const DragModel(
        release: DragRelease.stay,
        bounds: GestureBounds.contain,
        physics: PhysicsModel(friction: 0.6, overscroll: 0, bounce: 0.3),
      ).toJson(),
    },
  };

  /// Displayable names of [all].
  static const Map<String, String> names = {
    'photoViewer': 'Photo viewer',
    'mapCanvas': 'Map canvas',
    'bottomSheetFling': 'Bottom sheet fling',
    'sticker': 'Sticker',
    'puck': 'Air-hockey puck',
  };
}
