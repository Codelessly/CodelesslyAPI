# 04 · Drag, dismiss, pan and the value track

Status: proposal. Builds on doc 02 (`Spring`, `animate`, presets) and doc 03
(`PathFollow`, `transitions`). Usage counts are apps whose `editor/` or
`tool/` build sources name the key (text grep; an upper bound for common
words such as `smooth`, `snap`, `follow`, `write`).

## 1. Problem

Five types hold 151 fields, and one of them holds three unrelated things.

| Type | Where | Fields | What is wrong |
|---|---|---|---|
| `DragMotion` (`drag`) | `behaviors.dart:1910` | 33 | Three modes in one: pointer follow / swipe to dismiss, `track` (a whole value control nested inside), `reorder`. Swipe-deck fields used by one app |
| `DragTrack` (`drag.track`) | `behaviors.dart:1547` | 51 | A slider, knob and dial in one; three coordinate systems (`relative`, `units`, `viewBoxWidth/Height`); four ways to move to a value (`snap`, `settle`, `smooth`, `momentum`); fine mode in four fields |
| `DragSource`, `DropTarget` | `behaviors.dart:1334, 1442` | 17 + 11 | Two return-spring shapes on one type; five list-insertion fields that duplicate the list's own `reorder` (`widgets/collections_models.dart:260-288`) |
| `TransformGesture` + `TransformHandles` | `gestures.dart:554, 437` | 25 + 14 | An editor's selection box (corner, edge and rotate handles) inside a gesture behavior. Pan-only use duplicates `drag` |
| `controlDrag` action | `actions.dart:2366-2370` | 7 commands | One action over three render objects (`CodelesslySDK/lib/src/runtime/actions/handlers.dart:179-193`): `step` is a track, `zoom`/`pose` a transform gesture, `fling`/`returnFrom`/`shake` a swipe card, `reset` either |

Special-case fields and their users:

| Field | Apps |
|---|---|
| `parkedProgress` | 1 (apiary) |
| `fineStep`, `finePixelsPerRange`, `fineHold`, `fineVariable` | 2 (cutroom, darkroom), 2 (cutroom_v2, darkroom), 1 (cutroom_v2), 1 (darkroom) |
| `doubleTapValues`, `keyStep` | 1 each (lamplight) |
| `endless`, `momentum` | 2 each (chordbook_v2, safecracker) |
| `smooth: true` | 1 (safecracker); the bare word matches 6 |
| `gain` | 5 (backline, crate_digger, safecracker, tally_v2, tuneup) |
| `detent` | 4 (apiary, chordbook, chordbook_v2, safecracker) |
| `hitArea` | 3 (chordbook_v2, cutroom_v2, lamplight) |
| `settleStiffness`, `settleDamping` | 1 (apiary) |
| `slotWhenRefused` | 1 (mixtape) |
| `fullIf` (+ the `dropFull` trigger) | 2 (lamplight, seedbox); 1 (seedbox) |
| `hoverDelay` | 0 |
| `rotateFactor`, `flyOutRotate`, `shakeWhenDisabled`, `disabledFollow`, `verticalThreshold` | 1 each (flashcards) |
| `flyOutDistance`, `flyOutCurve` | 0 |
| `flyOut` | 1 (strata_v2) |
| `shareAs` | 2 (flashcards, gesture_lab) |
| `restX` / `restY` | 1 (orrery) / 0 |
| `drag.reorder: true` | 3 (backline, cutroom, formsmith_v2) |
| `rotationSnap`, `scaleXVariable`, `scaleYVariable` | 0 |
| `zoomable: true` | 1 (strata_v2) |
| `selectionVariable` (handles) | 2 (cutroom_v2, gesture_lab) |
| `controlDrag` | 4 (flashcards, gesture_lab, lineworks_v2, safecracker) |

## 2. Flutter grounding and the split

| Behavior key | Flutter (checked in `/opt/flutter/packages/flutter/lib/src`) | Replaces |
|---|---|---|
| `draggable` | `Draggable({data, axis, feedback, childWhenDragging, dragAnchorStrategy, affinity, ...})`, `LongPressDraggable` (`widgets/drag_target.dart:184`) | `DragSource` |
| `dropTarget` | `DragTarget({onWillAcceptWithDetails, onAcceptWithDetails, onLeave, onMove, builder})` (`:627`) | `DropTarget` minus list insertion |
| `dismissible` | `Dismissible({direction, dismissThresholds, movementDuration, resizeDuration, crossAxisEndOffset, confirmDismiss, onUpdate, onDismissed})` (`widgets/dismissible.dart:102`) | `drag` with `release: dismiss` |
| `transformGesture` | `InteractiveViewer({panEnabled, scaleEnabled, panAxis, minScale, maxScale, boundaryMargin, interactionEndFrictionCoefficient, transformationController})` (`widgets/interactive_viewer.dart`) | itself, `zoomable`, and `drag` used to follow the pointer |
| `track` | `Slider({value, min, max, divisions, onChanged, onChangeStart, onChangeEnd, allowedInteraction})`, `SliderInteraction { tapAndSlide, tapOnly, slideOnly, slideThumb }` (`material/slider.dart:55-190`), generalised from a straight line to a path | `drag.track` |
| list `reorder` prop | `ReorderableListView({onReorder, proxyDecorator, ...})` (`material/reorderable_list.dart`) | `drag.reorder`, `dropTarget.listNodeId/slot*` |
| `Spring`, `GesturePhysics` | `SpringDescription`, `SpringSimulation`, `FrictionSimulation` | six spring shapes (doc 02 §1) |

`drag` disappears as a key. The `drag` and `dragEnd` *triggers* stay
(`GestureDetector.onPanUpdate`): a node that only needs to hear a drag uses
them and moves nothing.

## 3. Proposed model

### 3.1 One physics type

```dart
/// How a released node moves on its own. Used by `dismissible`,
/// `transformGesture` and `track`.
final class GesturePhysics {
  const GesturePhysics({
    this.spring = const Spring(),      // doc 02; SpringDescription
    this.fling = true,                 // keep the pointer's velocity
    this.friction = 0.135,             // FrictionSimulation drag: speed kept after a second
    this.minFlingVelocity = 50,        // kMinFlingVelocity
    this.maxFlingVelocity = 8000,      // kMaxFlingVelocity
    this.overscroll = 0.5,             // stretch past the bounds, 0 hard stop
    this.snap,                         // GestureSnap: points, grid, edges (unchanged)
  });
}
```

Seven fields (eleven today). `stiffness`, `damping`, `mass`, `bounce`,
`duration` move into `spring`. `friction` takes Flutter's meaning (the
`drag` argument of `FrictionSimulation`); today it is the share *lost*
(`gestures.dart:147`, default 0.865), so the decoder writes `1 − old`.

### 3.2 `track`: a value control, 18 fields

A top-level behavior key. The node carrying it is the thumb.

```dart
/// A value the user sets by dragging: Flutter's `Slider`, along any path
/// or by turning.
final class Track {
  // --- the value (Slider) ---
  final bool enabled;                       // true
  final String variable;                    // '' : read and written
  final double? value;                      // null; bound as `track.value`: drawn at it instead of reading [variable]
  final double min, max;                    // 0, 1
  final double step;                        // 0 continuous. Slider.divisions = (max - min) / step
  final bool clamp;                         // true. False: the value may leave min–max (a combination dial)

  // --- input ---
  final TrackInput input;                   // path | horizontal | vertical | both | angular
  final SliderInteraction allowedInteraction; // slideThumb (default) | tapAndSlide | tapOnly | slideOnly
  final double pixelsPerRange;              // 200; horizontal, vertical, both
  final double startAngle, sweepAngle;      // -135, 270; angular: degrees for min, and for the whole range
  final Alignment pivot;                    // center; angular: the point turned about, in the node's parent
  final double? wheelStep, keyStep;         // null: [step], else 1% of the range. 0: off

  // --- where the thumb is drawn ---
  final PathFollow? path;                   // doc 03. Null: the node stays put (a knob)

  // --- feel ---
  final double detent;                      // 0. 0–1: how far the thumb follows between steps before the next one takes it
  final GesturePhysics? physics;            // null: stops where released. fling = momentum; spring = settle; overscroll
}
```

Rules that replace fields:

* **One coordinate system.** A track's geometry is its `path`
  (`PathFollow`): pixels from the node's place, or a `viewBox` stretched
  over the parent. A line is `M0 0 L0 -100`; "full width of the parent" is
  `viewBox: [1, 1]`, `M0 0.5 L1 0.5`. `relative`, `units`, `x1…y2`,
  `viewBoxWidth/Height` go.
* **A knob does not move; it turns.** `input: angular`, no `path`, and the
  node binds its own rotation:
  `"motion.rotate": "${= -135 + 270 * track.progress}"`. `rotate`,
  `pivotX/Y`, `startAngle/endAngle` reduce to `pivot`, `startAngle`,
  `sweepAngle`.
* **A bound `value` is drawn where it maps, even outside min–max.** Input
  always produces values in range (unless `clamp` is off). That is
  `parkedProgress` without a field: `"track.value": "${= rating == null ? -0.6 : rating}"`.
* **How the thumb moves to a new value is a transition**:
  `transitions: {"track": {...}}` (doc 03 §3.2). `snap`, `snapCurve`,
  `settle`, `settleCurve` go.
* **Writes.** With `variable`, dragging writes it. Without, only the
  `changed` reaction's `${result.value}` exists. `write` goes.

Scope inside the node: `${track.value}`, `${track.progress}`,
`${track.dragging}`, `${track.focused}`. Triggers: `changed`, `dragEnd`,
`changeEnd`, as now.

### 3.3 `dismissible`: 10 fields

```dart
/// Swiped away past a threshold: Flutter's `Dismissible`.
final class DismissibleBehavior {
  final bool enabled;                              // true
  final List<DragDirection> directions;            // [left, right]  (DismissDirection.horizontal)
  final Map<DragDirection, double> dismissThresholds; // {} : 0.4 of the node's size each (`_kDismissThreshold`, :22)
  final double flingVelocity;                      // 700 px/s (`_kMinFlingVelocity`, widgets/dismissible.dart:19)
  final double resistance;                         // 0. 0–1: how much of the pointer's travel is ignored
  final int movementDuration;                      // 200 ms: the fly-off, and the return
  final AnimationCurve curve;                      // easeOut
  final Spring? returnSpring;                      // null: returns over movementDuration
  final int resizeDuration;                        // 0: no collapse (Flutter: 300; a card deck does not collapse)
  final double crossAxisEndOffset;                 // 0
}
```

Scope: `${dismiss.dx}`, `${dismiss.dy}`, `${dismiss.progress}` (0–1 toward
the threshold; `Dismissible.onUpdate`), `${dismiss.direction}`,
`${dismiss.reached}`, `${dismiss.dragging}`. Triggers: `dismissed`
(`${result.direction}`), `dismissUpdate`.

### 3.4 `transformGesture`: pan, zoom, rotate; 21 fields

Unchanged in meaning. Added: `panAxis` (`free`, `horizontal`, `vertical`;
`InteractiveViewer.panAxis`) and `boundaryMargin` (`EdgeInsets`: how far
past rest it may go; `InteractiveViewer.boundaryMargin`). Removed:
`handles`, `rotationSnap`, `scaleXVariable`, `scaleYVariable`, `scaleX`,
`scaleY`. A node that just follows the finger and springs to a stop is
`{"zoom": false, "panAxis": "vertical", "boundaryMargin": [0, 560, 0, 0], "physics": {"snap": {"points": [[0, 0], [0, -560]]}}}`:
a bottom sheet.

### 3.5 `draggable` (10) and `dropTarget` (3)

```dart
final class DragSource {
  final String group, data;
  final DragStart start;                 // auto | press | longPress  (Draggable / LongPressDraggable)
  final DragAxis axis;                   // Draggable.axis
  final DragSourceStyle childWhenDragging; // ghost | hidden | keep  (was whileDragging)
  final double ghostOpacity;             // 0.35
  final String feedback;                 // a node id drawn under the pointer; '' : the node itself
  final FeedbackAnchor dragAnchor;       // child (where grabbed) | pointer (centered)  — Draggable.dragAnchorStrategy
  final Spring? returnSpring;            // null: no return animation, as Flutter
  final bool enabled;
}
final class DropTarget {
  final List<String> accepts;
  final String acceptIf;                 // onWillAcceptWithDetails
  final bool enabled;
}
```

* The feedback's look (tilt, lift, scale, fade) is a `states.dragged` patch
  on the node (`WidgetState.dragged` exists, `behaviors.dart:1210`), applied
  to the feedback copy. `feedbackRotation` (default −2°) and
  `feedbackElevation` (default 24) were invented defaults; Flutter's
  feedback is the widget as given.
* Dropping **into a list** is the list's business: `reorder` already has
  `group`, `listKey`, `canDropIf`, `placeholder` and the
  `reorderPlaceholder` slot. It gains `accepts` (draggable groups it takes
  from outside any list) and `placeholderSize` (`item`, `own`, `none`).
* Scope on a target: `${drop.candidate}`, `${drop.rejected}` (the
  `DragTarget.builder` arguments). New trigger `dropRejected` replaces
  `fullIf` + `dropFull`.

### 3.6 Commands: three typed actions

| Action | Commands | Fields | Flutter spelling |
|---|---|---|---|
| `controlTrack` | `step`, `animateTo` | `node`, `steps`, `value` | `onChanged(value + n * step)` |
| `controlDismissible` | `dismiss`, `reset` | `node`, `direction` | removing the item / re-inserting it |
| `controlTransform` | `reset`, `scaleBy`, `animateTo` | `node`, `value` (a factor, or `{x, y, scale, rotation}`) | `transformationController.value = ...` |

`shake` is the `shake` animation preset (`animate`, doc 02).

### 3.7 Flutter spelling of the recipes

What a model writing Dart would write for each construct that replaced a
field:

| Model | Flutter |
|---|---|
| `track` with a `path` | `Slider(value:, min:, max:, divisions:, onChanged:)` with a custom `SliderTrackShape`, or `GestureDetector(onPanUpdate:)` + `PathMetric.getTangentForOffset` |
| `track` with `input: angular` + bound `motion.rotate` | `GestureDetector(onPanUpdate:)` computing `atan2` about the center; `Transform.rotate(angle:)` |
| `transitions.track` | `TweenAnimationBuilder<double>(tween: Tween(end: value), duration:, curve:)` |
| `physics.fling` + `friction` on a track | `controller.animateWith(FrictionSimulation(drag, value, velocity))` |
| `dismissible` + `bind motion.rotate: ${dismiss.dx * k}` | `Dismissible(onUpdate: (d) => setState(...))` wrapping `Transform.rotate` |
| `dismissed` trigger | `Dismissible.onDismissed` |
| `transformGesture` with `zoom: false` and snap points | `GestureDetector(onPanUpdate:, onPanEnd:)` + `SpringSimulation` to the nearest stop; `DraggableScrollableSheet(snapSizes:)` for a sheet |
| `states.dragged` patch on a draggable | `Draggable(feedback: Transform.rotate(angle: -0.035, child: Material(elevation: 24, child: card)))` |
| list `reorder` with `accepts` | `ReorderableListView(onReorder:)`; `DragTarget` around the list for outside items |
| `dropRejected` trigger | `DragTarget.onWillAcceptWithDetails` returning false, then `onLeave` |
| `controlTransform animateTo` | `transformationController.value = Matrix4...` driven by an `AnimationController` |

### 3.8 Worked examples

**flashcards' deck** (today 12 `drag` fields including `rotateFactor`,
`flyOutRotate`, `verticalThreshold`, `disabledFollow`, `shakeWhenDisabled`):

```json
{"dismissible": {"directions": ["left", "right", "up"], "dismissThresholds": {"up": 0.25},
                 "returnSpring": {"duration": 450, "bounce": 0.25}},
 "bind": {"motion.rotate": "${= dismiss.dx * 0.06}",
          "dismissible.resistance": "${= canAnswer ? 0 : 0.85}",
          "dismissible.dismissThresholds": "${= canAnswer ? {up: 0.25} : {left: 9, right: 9, up: 9}}"},
 "animations": [{"name": "no", "preset": "shake", "autoplay": false}],
 "actions": [
   {"trigger": {"type": "dismissed"}, "actions": [{"type": "runScript", "script": "answer", "arguments": {"way": "${result.direction}"}}]},
   {"trigger": {"type": "dragEnd", "when": "${= !canAnswer}"}, "actions": [{"type": "animate", "animation": "no"}]}]}
```

**safecracker's dial** (today `shape: arc`, `endless`, `momentum`,
`friction`, `smooth`, `detent`, `gain`, `rotate`):

```json
{"track": {"variable": "dialTurns", "min": 0, "max": 100, "step": 1, "clamp": false,
           "input": "angular", "startAngle": 0, "sweepAngle": 360, "detent": 1,
           "physics": {"fling": true, "friction": 0.07, "spring": {"duration": 220, "bounce": 0.2}}},
 "bind": {"motion.rotate": "${= 360 * track.progress}"}}
```

**apiary's rating dial** (today `parkedProgress`, `settleStiffness`):

```json
{"track": {"variable": "rating", "min": 1, "max": 5, "step": 1, "allowedInteraction": "tapAndSlide",
           "path": {"path": "M80 300 A220 220 0 0 1 520 300", "viewBox": [600, 320]}},
 "bind": {"track.value": "${= rating == null ? 0.4 : rating}"},
 "transitions": {"track": {"spring": {"stiffness": 380, "damping": 20}}}}
```

## 4. Editor panel

`TrackFields`, `DismissibleFields`, `DragSourceFields`, `DropTargetFields`,
`TransformGestureFields`, `GesturePhysicsFields` and the three action
`*Fields` are `PropDef` lists. The Interaction section offers five
entries by their Flutter names: Slider track, Dismissible, Interactive
viewer, Draggable, Drag target. Track shows Value, Input (with only the
fields its `input` uses), Path (shared `PathFollow` editor with on-canvas
path editing), Feel. `GesturePhysics` and `Spring` are one shared editor
with the presets `gentle`, `snappy`, `bouncy`, `heavy` (`gestures.dart:119`).

## 5. `TransformHandles` becomes a component

A selection box is content, not a gesture: corner dots, edge bars, a rotate
knob and an outline. It is rebuilt from the primitives above and shipped as
a component (a hosted plugin once doc 05 lands):

* the object carries `transformGesture` with its pose in variables;
* an overlay sized by the object's `measure` holds the handles; a corner
  handle is a node with a `drag` reaction that writes `scale` from
  `${result.dx}`, `${result.dy}`; an edge handle writes the object's
  `layout.width`/`height` variable (this is why `scaleXVariable/Y` go);
* the rotate knob is a `track` with `input: angular`, `clamp: false`,
  `step` = the snap angle, writing `rotation`;
* selection is a `visible` binding and a `click` reaction.

This has not been built; it is the acceptance test for §3. Used by 2 apps
by `selectionVariable` (cutroom_v2, gesture_lab), 5 by the word `handles`.

## 6. SDK implementation

| File (lines today) | Change | LOC (estimate) |
|---|---|---|
| `render/drag_track.dart` (1,316) | drops line/arc/units geometry (uses `PathFollow`), fine mode, double-tap cycle, park, three settle paths | −450 |
| `runtime/gestures/drag_motion.dart` (1,065) | becomes `RenderDismissible`; follow mode moves to the transform gesture; shake, disabled follow, share, fly-out rotate go | −550 |
| `render/transform_gesture.dart` (1,165) | handles removed; `panAxis`, `boundaryMargin` added | −350, +60 |
| `runtime/gestures/drag_and_drop.dart` (1,452) | list slot preview moves to the reorder code (`widgets/collections_reorder.dart`, 779), which already draws one | −250 (not measured line by line) |
| `runtime/gestures/physics.dart` (275) | one `Spring` reader | −30 |
| `runtime/actions/handlers.dart:179-193` | three handlers for three actions | ±0 |

## 7. Migration

### `DragTrack` (51 fields)

| Field | New | How | Apps |
|---|---|---|---|
| `variable`, `min`, `max`, `step`, `value` | same, under `track` (`bind` keys `drag.track.*` → `track.*`) | mechanical | 29 use a track |
| `shape: line`, `x1`, `y1`, `x2`, `y2` | `path: {path: "Mx1 y1 Lx2 y2"}` | mechanical when unbound; a bound end becomes a bound path string | 26 (`shape`) |
| `relative`, `units: parent` | `path.viewBox` over the parent | mechanical for `units: parent`; `relative` (multiples of the node's own size) needs the node's design size, mechanical for fixed-size nodes | 5, 12 |
| `viewBoxWidth`, `viewBoxHeight`, `path` | `path.viewBox`, `path.path` | mechanical | 6 |
| `shape: arc`, `startAngle`, `endAngle`, `pivotX`, `pivotY`, `rotate` | pivot at the node's center: `input: angular`, `startAngle`, `sweepAngle = end − start`, and (with `rotate`) `bind motion.rotate`. Pivot elsewhere: `path` = that arc, `orient: tangent` | mechanical unless `motion.rotate` is already bound | 18, 7 |
| `orientToPath`, `orientUpright` | `path.orient` | mechanical | |
| `input` | `follow` → `path` (or `angular` for an arc); others same | mechanical | 21 |
| `pixelsPerRange`, `gain` | `pixelsPerRange / gain` | mechanical | 9, 5 |
| `jumpOnTap`, `hitArea` | `allowedInteraction`: `jumpOnTap` → `tapAndSlide`; `hitArea: parent` without it → `slideOnly`; neither → `slideThumb` | mechanical | 12, 3 |
| `wheel`, `wheelStep` | `wheelStep` (0 = off) | mechanical | 26, 3 |
| `keyboard`, `keyStep` | `keyStep` (0 = off) | mechanical | 18, 1 |
| `detent` | same | — | 4 |
| `smooth` | `detent: 1` + `physics.spring` | approximate | 1 |
| `momentum`, `friction` | `physics: {fling: true, friction}` | mechanical (unit converted) | 2, 4 |
| `overscroll` | `physics.overscroll` | mechanical | 4 |
| `settle`, `settleCurve`, `settleStiffness`, `settleDamping` | `transitions.track` (`duration`+`curve`, or `spring`) | mechanical | 7, 2, 1, 1 |
| `snap`, `snapCurve` | `transitions.track`; when both `snap` and `settle` were set, `snap` wins for value changes and `physics.spring` takes the release | mechanical | 7, 3 |
| `endless` | `clamp: false` | mechanical | 2 |
| `write: false` | drop `variable`, `bind track.value` to it | mechanical | 6 (upper bound) |
| `defaultValue`, `doubleTapValues` | **removed.** A `doubleTap` reaction: `setVariable` (a cycle is a formula: `${= next(values, v)}`); the thumb animates by `transitions.track` | mechanical (the decoder adds the reaction) | 12 (upper bound), 1 |
| `parkedProgress` | **removed.** A bound `track.value` outside the range (§3.2) | by hand | 1 |
| `fineStep`, `finePixelsPerRange`, `fineHold`, `fineVariable` | **removed.** A boolean variable set by `keyDown`/`keyUp` (Shift) and a `hold` reaction; `bind track.step` and `track.pixelsPerRange` to it | by hand | 2–3 |

### `DragMotion` (33 fields)

| Field | New | How | Apps |
|---|---|---|---|
| `track` | top-level `track` | mechanical | 29 |
| `reorder` | the parent list's `reorder: {enabled: true}` | mechanical when the parent is a list | 3 |
| `release: dismiss`, `directions`, `distanceThreshold`, `verticalThreshold`, `velocityThreshold` | `dismissible`: `directions`, `dismissThresholds` (per direction), `flingVelocity` | mechanical | 4 `"dismiss"` literals; 1 `verticalThreshold` |
| `flyOut`, `flyOutCurve` | `movementDuration`, `curve` | mechanical | 1, 0 |
| `flyOutDistance` | removed (flies past the screen edge) | — | 0 |
| `rotateFactor`, `flyOutRotate`, `originX`, `originY` | **removed.** `bind motion.rotate: ${= dismiss.dx * factor}`, `motion.alignment` | mechanical | 1 |
| `resistance` | `dismissible.resistance` | mechanical | 2 |
| `shakeWhenDisabled` | **removed.** A `dragEnd` reaction playing the `shake` preset | mechanical (decoder adds it) | 1 |
| `disabledFollow` | **removed.** Stay enabled; bind `resistance` and unreachable `dismissThresholds` to the condition (§3.8) | by hand | 1 |
| `snapBack`, `snapCurve` | `returnSpring` (spring curve), else `movementDuration` + `curve` | mechanical | 1, 3 |
| `enabled` | each behavior's `enabled` | mechanical | |
| `release: snapBack` / `stay`, `axis`, `follow`, `bounds`, `minX…maxY`, `physics` | `transformGesture`: `zoom: false`, `panAxis`, `bounds`, `boundaryMargin`, `physics` (`snapBack` → `snap.points: [[0, 0]]`) | mechanical | 5 `"stay"` literals; `bounds` 8; `minY` 4 |
| `follow: false` | no behavior: the `drag` trigger alone | mechanical | 10 (upper bound) |
| `xVariable`, `yVariable` | `transformGesture.xVariable/yVariable` | mechanical | 8, 9 |
| `restX`, `restY` | `transformGesture.x`, `.y` | mechanical | 1, 0 |
| `shareAs` | **removed.** `xVariable`/`yVariable`, or a `dismissUpdate` reaction writing what is shared | by hand | 2 |

### `DragSource` (17), `DropTarget` (11)

| Field | New | How | Apps |
|---|---|---|---|
| `group`, `data`, `start`, `axis`, `enabled`, `ghostOpacity` | same | — | 13 use `draggable` |
| `whileDragging` | `childWhenDragging` | rename | 9 |
| `feedbackNodeId` | `feedback` | rename | 9 |
| `feedbackAnchor: grab/center` | `dragAnchor: child/pointer` | rename | 2 |
| `feedbackRotation`, `feedbackScale`, `feedbackOpacity`, `feedbackElevation` | `states.dragged` patch (`motion.rotate`, `motion.scale`, `opacity`, a drop shadow) | mechanical; the old defaults (−2°, 24) are written out so nothing changes | 11, —, —, 10 |
| `returnSpring`, `springStiffness`, `springDamping`, `physics` | `returnSpring: Spring` (old default written out) | mechanical | 4 |
| `accepts`, `acceptIf`, `enabled` | same | — | 13 use `dropTarget`; `acceptIf` 10 |
| `key`, `listNodeId`, `slot`, `slotNodeId`, `slotSize` | the list's `reorder`: `listKey`, `accepts`, `placeholder: slot` + the `reorderPlaceholder` slot, `placeholderSize` (`dragged` → `item`, `node` → `own`, `inGap` → `none`) | mechanical when the target is the list or inside it; a target outside the list (a column's tab) becomes a plain `dropTarget` with an insert action, by hand | 5, 4, 2 |
| `slotWhenRefused` | removed: the slot opens for accepted drags only | behavior change where it was left at its default `true` and `acceptIf` refuses | 1 sets it |
| `fullIf` | **removed.** Fold into `acceptIf`; react to `dropRejected` | mechanical (`dropFull` → `dropRejected` with `when: <fullIf>`) | 2 |
| `hoverDelay` | removed | — | 0 |

### `TransformGesture` (25), `TransformHandles` (14), others

| Field | New | How | Apps |
|---|---|---|---|
| `enabled`, `target`, `pan`, `zoom`, `rotate`, `minScale`, `maxScale`, `bounds`, `doubleTapScale`, `wheel`, `physics`, `x`, `y`, `scale`, `rotation`, `xVariable`, `yVariable`, `scaleVariable`, `rotationVariable` | same | — | 11 |
| `rotationSnap`, `scaleXVariable`, `scaleYVariable`, `scaleX`, `scaleY` | removed | — | 0 |
| `handles` (all 14 fields) | the Selection box component (§5) | **by hand** | 2–5 |
| `zoomable: true` | `transformGesture: {target: content, pan: whenZoomed}` (`TransformGesture.zoomable`, `gestures.dart:585`) | mechanical | 1 |
| `GesturePhysics.stiffness/damping/mass/bounce/duration` | `physics.spring` | mechanical | 10 use `physics` |
| `FlipCard.spring` (`FlipSpring`) | `Spring` | mechanical | |
| `controlDrag` `step` | `controlTrack step` | mechanical | 4 use `controlDrag` |
| `controlDrag` `fling`, `returnFrom` | `controlDismissible dismiss` / `reset` | mechanical | |
| `controlDrag` `reset` | `controlTransform reset` on a transform gesture, else `controlDismissible reset` | mechanical only when the decoder can see the target node; otherwise decided at run time for one release | |
| `controlDrag` `zoom`, `pose` | `controlTransform scaleBy` / `animateTo` | mechanical | |
| `controlDrag` `shake` | `animate` a `shake` preset the decoder adds to the node | mechanical within one document | |
| `${drag.*}` on a swipe card | `${dismiss.*}` (`dx`, `dy`, `progress`, `direction`, `dragging`) | mechanical in bindings; `left/right/up/down`, `settling`, `snapIndex`, `dismissed` are dropped (formulas of `dx`, `dy`) | |
| `${track.fine}` | removed | — | |
| `${drag.*}` during drag and drop | unchanged | — | |

## 8. Compatibility

`"schema": 2` stays. `Behaviors.fromJson` reads `drag` and returns `track`,
`dismissible` or `transformGesture`; `ActionDef.fromJson` reads
`controlDrag`. Encoders write only the new keys.

Not mechanical: the selection box (`handles`), fine mode, `parkedProgress`,
`disabledFollow`, `shareAs`, drop targets outside their list, `smooth`
(approximate), a `relative` track on a node without a fixed size, and
`controlDrag reset` when its target is computed. A node whose `drag` had
both `track` and swipe fields keeps the track: the SDK only follows the
pointer when `track` is null and `reorder` is false
(`CodelesslySDK/lib/src/runtime/gestures/drag_motion.dart:126-131`).

## 9. Target field counts

| Type | Today | Proposed |
|---|---|---|
| `DragTrack` → `Track` | 51 | 18 (+ shared `PathFollow`) |
| `DragMotion` | 33 | 0 (`DismissibleBehavior` 10) |
| `DragSource` | 17 | 10 |
| `DropTarget` | 11 | 3 (list `reorder` +2) |
| `TransformGesture` | 25 | 21 |
| `TransformHandles` | 14 | 0 (a component) |
| `GesturePhysics` | 11 | 7 (+ shared `Spring`) |
| Spring shapes | 6 | 1 |
| `controlDrag` | 1 action, 7 commands | 3 actions, 7 commands |
| Total fields | 162 | 69 |

## 10. Open questions for the owner

1. **The track stays on the thumb** (recommended; mechanical migration), or
   moves to the track area with a `thumb` child, as `Slider` is built.
   The second is closer to Flutter and makes a two-thumb range slider
   natural, but moves the behavior to another node in 29 apps.
2. **Pointer-follow merges into `transformGesture`** (recommended), or
   gets its own small `pan` behavior.
3. **`draggable.returnSpring` default null** (Flutter: the feedback just
   disappears) and **no default feedback tilt or shadow**. Migration keeps
   every existing document identical; only new documents change.
4. **Rename `transformGesture` to `interactiveViewer`?** Not recommended
   now: it does more than `InteractiveViewer` (rotation, `target: node`).
5. **Slot for refused drags** (the `slotWhenRefused` default flips).

## 11. Rollout

1. API: `Spring` in `GesturePhysics`; `Track`, `DismissibleBehavior`, the
   slimmer `DragSource`/`DropTarget`; three actions; legacy decoders.
2. SDK: `RenderDragTrack` on `PathFollow` and `transitions.track`;
   `RenderDismissible`; pan in the transform gesture; replay
   `gestures_test`, `dial_track_test` and the goldens through migrated
   documents.
3. Build the Selection box component; port cutroom_v2 and gesture_lab to
   it; then delete `TransformHandles`.
4. Editor: the five Interaction entries.
5. Rebuild the hand-migrated spots (apiary, cutroom, cutroom_v2, darkroom,
   flashcards, gesture_lab, safecracker); delete the legacy readers one
   release later.
