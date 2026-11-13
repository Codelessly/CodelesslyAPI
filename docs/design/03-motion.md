# 03 · Motion: a pose, a path, and per-property transitions

Status: proposal. Builds on doc 02 (everything temporal moves there).
Usage counts are apps whose `editor/` or `tool/` build sources name the key
(text grep; an upper bound for common words such as `loop`, `phase`, `arc`).

## 1. Problem

`Motion` (`behaviors.dart:381`, constructor `:382-433`) has **50 fields**
doing nine jobs:

| Job | Fields |
|---|---|
| Pose (a transform) | `translateX/Y`, `scale`, `scaleX/Y`, `shiftX/Y`, `rotate`, `rotateX/Y`, `perspective`, `originX/Y`, `backfaceHidden` |
| Compositing | `opacity`, `blur` |
| Implicit transition | `duration`, `delay`, `curve`, `rotateCurve`, `fadeShare`, `springStiffness`, `springDamping`, `arc` |
| Entrance | `enter`, `enterFrom`, `replayKey`, `enterHeld`, `revealOnScroll`, `revealFraction` |
| Loop | `loop`, `repeat`, `phase`, `paused` |
| Spin | `spin`, `spinRamp` |
| Keyframes, pulse | `keyframes`, `pulseKey` |
| Path following | `path`, `pathProgress`, `orientToPath`, `orientUpright`, `uprightMirror`, `pathPacing`, `pathFocusX/Y`, `pathWrap`, `pathViewBox` |
| Paint effect | `shimmer` |
| Bookkeeping | `named` (which keys the JSON gave explicitly, `:549`) |

One-app fields, with their grep basis:

| Field | Apps | Driving blocker |
|---|---|---|
| `uprightMirror` | 1 (lineworks_v2) | `lineworks_v2/blockers.md` |
| `pathPacing`, `pathFocusX/Y` | 3 name `pathPacing` (lineworks, lineworks_v2, orrery); only orrery's blockers ask for `area`; `pathFocusX/Y` appear in **no** build source | `orrery/blockers.md` row 1 (Kepler's second law) |
| `pathWrap` | 1 (orrery) | same |
| `pathViewBox` | 1 (strata_v2) | `strata_v2/blockers.md` |
| `fadeShare`, `rotateCurve` | 1 each (cheers_v2) | `cheers_v2/blockers.md` |
| `spinRamp` | 1 (lineworks_v2) | |
| `enterHeld` | 1 (burrow_v2) | `burrow_v2/blockers.md` |
| `arc` | 1 with a numeric value (lineup); the bare word matches 17 | |
| `revealOnScroll` / `revealFraction` | 3 (hookline, strata, strata_v2) / 1 (hookline) | `hookline/blockers.md` |
| `springStiffness`, `springDamping` | 0 | |
| `pulseKey` | 2, and the SDK never reads it | |

**Duplication around it.** Ways to scale a node: `scale` (node behavior,
`behaviors.dart:3025`), `motion.scale`, `motion.scaleX/Y`, `loops` scale and
pulse, `effectAnimations` pop, `transitions.style`, `transformGesture.scale`,
`draggable.feedbackScale`, a list's `reorder.proxyScale`. Ways to rotate:
`layout.rotation`, `motion.rotate`, `motion.spin`, `loops` spin and sway,
effects spin and wiggle, `drag.rotateFactor`, `drag.track.rotate`,
`orientToPath`, `transformGesture.rotation`, `draggable.feedbackRotation`.
Their order is fixed by the SDK's render chain (DESIGN.md §5: "motion → … →
scale → rotation → … → loops"), which no author can see.

`layout.rotation` is not layout: the SDK paints it with a `RenderTransform`
(`CodelesslySDK/lib/src/render/node_tree.dart:1003-1006`).

## 2. Flutter grounding

| Flutter | Mirrored as |
|---|---|
| `Transform({transform, origin, alignment, transformHitTests, filterQuality})`, `Transform.translate`, `.scale({scale, scaleX, scaleY})`, `.rotate({angle})`, `.flip` (`widgets/basic.dart:1599-1753`) | `Motion`: one matrix from named parts, `alignment` |
| `FractionalTranslation({translation})` | `shiftX`, `shiftY` |
| `Opacity` | the node's `opacity` (already a node field) |
| `ImageFiltered(imageFilter: ImageFilter.blur)` | `decoration.effects` `layerBlur` (already there) |
| `ShaderMask` (`widgets/basic.dart:433`) | the `shimmer` behavior |
| `PathMetric.getTangentForOffset` | `PathFollow` |
| `AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`, `AnimatedRotation`, `AnimatedSlide`, `AnimatedAlign`, `AnimatedPositioned`, `AnimatedSize`, `TweenAnimationBuilder` (`widgets/implicit_animations.dart`, `tween_animation_builder.dart`) | `transitions`, keyed by property |

## 3. Proposed model

### 3.1 `Motion` is a transform: 14 fields

```dart
/// A transform painted over the node's layout (Flutter's `Transform`): it
/// moves nothing else. One matrix, built in this order: the path's offset,
/// translate, shift, then about [alignment]: scale, rotate, 3D rotation.
@immutable
final class Motion {
  const Motion({
    this.translateX = 0, this.translateY = 0,
    this.shiftX = 0, this.shiftY = 0,
    this.scale = 1, this.scaleX = 1, this.scaleY = 1,
    this.rotate = 0, this.rotateX = 0, this.rotateY = 0,
    this.perspective = 1,
    this.alignment = Alignment.center,
    this.backfaceHidden = false,
    this.path,
  });

  /// Pixels (`Transform.translate`).
  final double translateX, translateY;

  /// Multiples of the node's own size (`FractionalTranslation`).
  final double shiftX, shiftY;

  /// `Transform.scale(scale:, scaleX:, scaleY:)`; the axis factors multiply [scale].
  final double scale, scaleX, scaleY;

  /// Degrees. [rotate] is about z (`Transform.rotate`); [rotateX], [rotateY]
  /// turn in 3D with [perspective].
  final double rotate, rotateX, rotateY, perspective;

  /// The point scale and rotation are about (`Transform.alignment`).
  final Alignment alignment;

  /// Not painted while its back faces the viewer.
  final bool backfaceHidden;

  /// A path the node sits on.
  final PathFollow? path;
}

/// A place along an SVG path. Shared by `motion.path` and `track.path` (doc 04).
@immutable
final class PathFollow {
  const PathFollow({required this.path, this.viewBox, this.progress = 0, this.orient = PathOrient.none});

  /// SVG path data.
  final String path;

  /// The path's coordinate space `[width, height]`, stretched over the
  /// node's parent; its points are where the node's center goes. Null: the
  /// path is in pixels, as offsets from its first point, from the node's place.
  final List<double>? viewBox;

  /// Where along the path's length, 0–1. Values outside wrap on a closed
  /// path and clamp on an open one.
  final double progress;

  /// `none`; `tangent`: turned with the path's direction; `upright`: the
  /// same, folded into −90…90 degrees so it is never upside down.
  final PathOrient orient;
}
```

Inside a node with `motion.path`, `${path.angle}` (the tangent in degrees),
`${path.x}` and `${path.y}` can be read, as `${track.*}` can today.

What left, and where it went:

* **`opacity`** → the node's own `opacity` (DESIGN.md §2.3). There was one
  too many.
* **`blur`** → a `layerBlur` effect in `decoration.effects`, which every
  type already keeps for exactly this (DESIGN.md §4.1).
* **`shimmer`** → its own behavior key, `shimmer`
  (`{color, strength, width, angle, position}`): a paint effect, not a
  transform. Its clock is the `shimmer` animation preset driving `position`
  (doc 02 §5).
* **Everything temporal** → `animations` (doc 02) or `transitions` (§3.2).
* **`named`** → gone. It existed so `enterFrom: {"opacity": 1}` could name a
  default value. A track's `from` is an explicit value, so there is nothing
  to remember.

This removes `opacity` and `blur` from the pose although the brief lists
them as pose values; the reason is the one-way rule. It is decision 1 in §9.

### 3.2 `transitions`: implicit animation per property

Today `transitions` is `{style, opacity, size}` (`behaviors.dart:1124`) and
`Motion` carries its own `duration`/`curve`. Proposed: one map from a
binding path (or a prefix of one) to a `Transition`.

```dart
/// How a change to a property animates (`AnimatedContainer(duration:, curve:)`).
final class Transition {
  const Transition({this.duration = 0, this.curve = AnimationCurve.linear, this.delay = 0, this.spring});
  final int duration, delay;      // ms
  final AnimationCurve curve;
  final Spring? spring;           // doc 02; replaces duration and curve
}
// Behaviors.transitions : Map<String, Transition>
```

```json
"transitions": {
  "motion":            {"duration": 240, "curve": "easeOutCubic"},
  "motion.rotate":     {"spring": {"duration": 500, "bounce": 0.3}},
  "opacity":           {"duration": 120},
  "decoration.fills":  {"duration": 200},
  "layout":            {"duration": 300, "curve": "easeInOut"},
  "visible":           {"duration": 200}
}
```

Semantics, those of `ImplicitlyAnimatedWidget`:

* When the resolved value at a path changes (a binding, a condition, a
  `states` patch, `setValue`), the node tweens from what it shows now to the
  new value. A change mid-flight retargets from the current value.
* The longest matching key wins (`motion.rotate` over `motion`). `"*"`
  matches every animatable path (`AnimatedContainer`).
* `layout` animates size like `AnimatedSize`/`AnimatedContainer`; `visible`
  grows the node open and closed with a fade (what `style` does today).
* A path an animation track is driving is not also transitioned.
* The design canvas shows new values at once.

### 3.3 One way to scale, one way to rotate

| Kind | The one way |
|---|---|
| A static or bound scale / rotation | `motion.scale`, `motion.scaleX/Y`, `motion.rotate` |
| Animated | an animation track on those paths (doc 02), usually via a preset |
| Changed by state | a `states` patch or binding on those paths, eased by `transitions` |
| By the user's fingers | `transformGesture` (doc 04), a separate pose outside `motion` |
| Along a path | `motion.path.orient` |

Removed: the node-level `scale` behavior and `layout.rotation` (both fold
into `motion`), `loops`, `motion.spin`, effect types (doc 02),
`drag.rotateFactor`, `drag.track.rotate`, `feedbackScale`/`feedbackRotation`
(doc 04).

**Composition order, stated once.** Outermost first:
track pose → transform gesture → `motion` (one matrix: path offset,
translate, shift, then about `alignment`: scale, rotate, rotateX/Y) →
shimmer → flip / tilt → opacity → blurs → `customPaint` → content. The two
gesture poses stay outside `motion` because the user drives them while
bindings and animations drive `motion`.

### 3.4 Worked examples

**lineworks_v2's train** (today `orientToPath`, `orientUpright`,
`uprightMirror`):

```json
{"motion": {"path": {"path": "M40 300 C 200 80, 520 80, 700 300", "viewBox": [760, 420], "orient": "upright"}},
 "bind": {"motion.path.progress": "${animation.run.value}",
          "motion.scaleX": "${= abs(path.angle) > 90 ? -1 : 1}"},
 "animations": [{"name": "run", "duration": 9000, "repeat": {}}]}
```

**orrery's Mercury** (today `pathPacing: area`, `pathFocusX/Y`, `pathWrap`):
the pacing is a formula of time, and the orrery already has Kepler's
equation as a function variable (`orrery/blockers.md` row 3).

```json
{"motion": {"path": {"path": "${orbitPath('mercury')}", "viewBox": [1000, 1000]}},
 "bind": {"motion.path.progress": "${= keplerProgress(animation.year.value * 4.15, 0.2056)}"}}
```

**A hover card** (today `motion.duration` + `transitions.style`):

```json
{"states": {"hovered": {"card": {"motion": {"translateY": -4, "scale": 1.02}}}},
 "transitions": {"motion": {"duration": 160, "curve": "easeOut"}}}
```

## 4. Editor panel

`MotionFields` (14), `PathFollowFields` (4), `TransitionFields` (4),
`ShimmerFields` (5). The Transform section shows Move (x, y, shift), Scale
(uniform with an unlink toggle for x/y), Rotate (z; 3D folded), Origin (a
nine-point picker writing `alignment`), Path (data, view box, progress,
orient). The Transitions section is a list of rows: a property picker fed
by `BindPaths`, duration, curve or spring. The canvas rotation handle writes
`motion.rotate`.

## 5. SDK implementation

| Piece | Change | LOC (estimate) |
|---|---|---|
| `RenderMotion` (`render/behaviors.dart:810-1200`) | keeps the matrix and the path; its entrance, loop, spin, keyframe, hold and reveal code goes to doc 02's player | −450 |
| `_MotionRevealWatcher` (`:1582`) | removed (an `enterViewport` reaction does it) | −30 |
| Transitions | one implicit-tween table per node in the animation player, replacing the three hard-wired ones and `Motion`'s own | +150, −200 |
| `scale`, `rotation` layers of the chain (`node_tree.dart:1003`) | removed | −30 |
| Area pacing, wrap, mirror in the path code | removed | −120 (not measured line by line) |
| `${path.*}` scope | new | +40 |

API package: `Motion` drops from 50 fields to 14, `MotionKeyframe`,
`MotionLoop`, `MotionPathPacing` go; about −500 lines in `behaviors.dart`
and `behavior_fields.dart`.

## 6. Migration: every field of `Motion`

| Field | New location | How | Flutter spelling | Apps |
|---|---|---|---|---|
| `translateX`, `translateY` | same | — | `Transform.translate(offset:)` | 16 |
| `scale`, `scaleX`, `scaleY` | same | — | `Transform.scale(scale:, scaleX:, scaleY:)` | 8 (`scaleX`) |
| `shiftX`, `shiftY` | same | — | `FractionalTranslation(translation:)` | 4, 5 |
| `rotate` | same | — | `Transform.rotate(angle:)` (radians) | — |
| `rotateX`, `rotateY`, `perspective` | same | — | `Matrix4.identity()..setEntry(3, 2, p)..rotateX(a)..rotateY(b)` | 3, 6, 9 |
| `originX`, `originY` | `alignment: [x, y]` | mechanical (same −1…1 range) | `Transform(alignment: Alignment(x, y))` | 19 |
| `backfaceHidden` | same | — | check `transform` z in the builder | 3 |
| `opacity` | node `opacity` (multiplied; two bindings become one formula product) | mechanical | `Opacity(opacity:)` | not separable |
| `blur` | `decoration.effects` += `{type: layerBlur, id: "motionBlur", blurRadius}`; `bind` key `motion.blur` → `decoration.effects.motionBlur.blurRadius` | mechanical unless the node already has a layer blur | `ImageFiltered(imageFilter: ImageFilter.blur(...))` | not separable |
| `duration`, `delay`, `curve` | `transitions.motion` (and `transitions.opacity` when the motion set opacity) | mechanical | `AnimatedContainer(duration:, curve:)`, `AnimatedSlide`, `AnimatedScale`, `AnimatedRotation` | 44 use `motion` |
| `springStiffness`, `springDamping` | `transitions.motion.spring` when `curve` was `spring` | mechanical | `SpringDescription` | 0 |
| `rotateCurve` | `transitions["motion.rotate"].curve`; in an entrance, that track's `curve` | mechanical | `CurveTween` | 1 |
| `fadeShare` | the entrance's opacity track `interval: [0, share]`, `curve: easeOut` | mechanical for entrances (its only use) | `Interval(0, share, curve: Curves.easeOut)` | 1 |
| `arc` | **removed.** Recipe: different curves on the two axes (`transitions["motion.translateX"]: easeOut`, `["motion.translateY"]: easeIn`), or a quadratic `motion.path` | by hand | `MaterialPointArcTween` | 1 (lineup) |
| `enter`, `enterFrom`, `replayKey` | `animations` preset `enter`, `playKey` | mechanical (doc 02) | `SlideTransition` + `FadeTransition` | 25, 30, 5 |
| `enterHeld` | **removed.** `bind: {"animations.enter.paused": <the same expression>}` | mechanical | deferred `forward()` | 1 |
| `revealOnScroll`, `revealFraction` | **removed.** `autoplay: false` and a reaction `{"trigger": {"type": "enterViewport", "visibleFraction": f}, "actions": [{"type": "animate", "animation": "enter"}]}` | mechanical (the decoder adds the reaction) | visibility callback → `forward()` | 3, 1 |
| `loop`, `repeat`, `phase`, `paused` | `animations` preset `loop` | mechanical (doc 02) | `controller.repeat(reverse:, count:)` | 27 (upper bound) |
| `spin` | `animations` preset `spin` | mechanical | `RotationTransition` | 12 |
| `spinRamp` | **removed.** Recipe: a one-shot `easeIn` rotation, then the loop from its `completed` status | by hand | — | 1 |
| `keyframes` | `animations` preset `keyframes` | mechanical | `TweenSequence` | 16 |
| `pulseKey` | **removed** (inert today). Recipe: a `playKey` animation with keyframes rest → pose → rest | by hand | `forward().then((_) => reverse())` | 2 |
| `path` | `path.path` | mechanical | `PathMetric.getTangentForOffset` | — |
| `pathProgress` | `path.progress`; `bind` key `motion.pathProgress` → `motion.path.progress` | mechanical | | 9 |
| `pathViewBox` | `path.viewBox` | mechanical | | 1 |
| `orientToPath`, `orientUpright` | `path.orient`: `tangent` / `upright` | mechanical | `Transform.rotate(angle: tangent.angle)` | 6, 3 |
| `uprightMirror` | **removed.** `bind: {"motion.scaleX": "${= abs(path.angle) > 90 ? -1 : 1}"}` | mechanical when `motion.scaleX` is unbound | `Transform.flip(flipX:)` | 1 |
| `pathPacing`, `pathFocusX`, `pathFocusY` | **removed.** Pacing is a function of time: bind `path.progress` to a formula (orrery's own Kepler function) or give its track a curve | by hand | a custom `Curve` | 1 needs `area` |
| `pathWrap` | **removed.** A closed path wraps `progress` by definition (§3.1) | mechanical; "the short way round" on a transition is lost | — | 1 |
| `shimmer` | behavior `shimmer` + animation preset `shimmer` (its `duration`) | mechanical | `ShaderMask` + `controller.repeat()` | 6 |
| `named` | removed | mechanical: each named default becomes an explicit `from` value | — | — |

Around `Motion`:

| Today | New | How | Flutter spelling | Apps |
|---|---|---|---|---|
| `scale` (node behavior) and its binding | `motion.scale` (multiplied in) | mechanical when `motion.alignment` is the center; see §7 | `Transform.scale` | not separable |
| `layout.rotation` and its binding | `motion.rotate` (added) | mechanical when the node has no `rotateX/Y` and a centered `alignment`; see §7 | `Transform.rotate` | not counted |
| `transitions.style` | `transitions`: `opacity`, `motion.scale`, `decoration.fills`, `visible` with that transition | mechanical | `AnimatedOpacity`, `AnimatedScale`, `AnimatedContainer` | 12 use `transitions` |
| `transitions.opacity` | `transitions.opacity` | — | `AnimatedOpacity` | |
| `transitions.size` | `transitions.layout` | mechanical | `AnimatedSize` | |

## 7. Compatibility

`"schema": 2` stays; `Motion.fromJson` and `Behaviors.fromJson` read every
legacy key and return the new values; encoders write only the new shape;
`bind` keys are rewritten alongside.

Not mechanical, exactly:

1. **`arc`** (lineup), **`spinRamp`** (lineworks_v2), **`pulseKey`**
   (chairlift, flashcards; inert), **`pathPacing: area`** (orrery).
2. **Folding `scale` / `layout.rotation` into `motion`** changes the
   picture only for a node that has one of them **and** a non-center
   `originX/Y` or a 3D rotation, because the old layers sat inside
   `motion` and turned about the center. The decoder detects that case and
   leaves the legacy keys in `extra` with a validation warning rather than
   guess. How many nodes that is was not measured.
3. **A node with both `motion.blur` and its own layer blur** (two blurs
   become one of radius √(a² + b²); bound blurs cannot be merged).
4. **`pathWrap`'s short-way-round transition.**

## 8. Target

| | Today | Proposed |
|---|---|---|
| `Motion` fields | 50 | 14 (+ `PathFollow` 4) |
| Ways to give a static scale | 3 (`scale`, `motion.scale`, `motion.scaleX/Y`) | 1 value type, `motion` |
| Ways to give a static rotation | 2 (`layout.rotation`, `motion.rotate`) | 1 |
| Implicit-transition shapes | 2 (`transitions`, `motion.duration`) | 1 |

## 9. Open questions for the owner

1. **`opacity` and `blur` out of `Motion`.** Recommended (one opacity, one
   blur). Keeping them makes migration trivial but keeps two of each.
2. **Fold `layout.rotation` into `motion.rotate`.** Recommended: it is a
   paint transform already. It touches the Figma-shaped envelope, which is
   otherwise out of scope.
3. **Keep flat `translateX`, `originX`-style names** (recommended: 44 apps
   bind `motion.*` paths; only `originX/Y` → `alignment` changes) or move to
   Flutter's value shapes (`translate: Offset`).
4. **`backfaceHidden`** (3 apps): keep as a field (recommended; it has no
   binding recipe) or fold into `flip`.

## 10. Rollout

After doc 02's player is in:

1. API: new `Motion`, `PathFollow`, `Transition` map, `Shimmer`; legacy
   decoders; `value_fields_test.dart` round trips.
2. SDK: slim `RenderMotion`; transitions table; remove the `scale` and
   `rotation` chain layers; goldens unchanged for all 66 fixture pages.
3. Editor: Transform and Transitions sections; rotation handle writes
   `motion.rotate`.
4. Rebuild the four hand-migrated spots (lineup, lineworks_v2, orrery,
   chairlift/flashcards) and delete the legacy readers one release later.

## Deviations from the proposal

Implemented in `lib/src/core/behaviors.dart` (`Motion`, `Pose`, `Shimmer`, `Transition`),
`lib/src/core/path_follow.dart` (`PathFollow`), `animation_presets.dart` (`AnimationPresets.fromMotion`, the
`enter`, `loop`, `spin`, `shimmer` presets), `node.dart` (opacity and blur); SDK: `render/behaviors.dart`
(`RenderMotion` is the matrix and the path), `render/animations.dart` (the one player, now with the transitions).
`Motion` has the 14 fields of §3.1 (50 before). Every legacy key is read (old JSON in, new model out:
`test/motion_migration_test.dart`); encoders write only the new shape; the SDK's existing motion tests pass with
their assertions (the changes are listed in the changelog).

1. **`transitions` is a list with a `property` per entry**, not a map: list entries are addressed by a key of
   their own everywhere else, and a map key with dots (`motion.rotate`) can't be a binding path. The proposal's
   map and the legacy `{style, opacity, size}` object both read. A **prefix** (`motion`) eases what's under it
   as one value, as `AnimatedContainer` eases its `transform`: a change of any number starts them together, a
   change mid-flight restarts the others from where they are, and its `keyframes` (a pose per keyframe:
   `{"at": 0.5, "value": {"scale": 1.05}}`) run on every change. That is what the legacy `motion.duration` did
   (flashcards' card swells as it turns over); per-property easing (`AnimatedScale`) is a longer key.
2. **`Transition.keyframes`/`interpolation` and `KeyframeInterpolation.monotoneCubic`** were added: the legacy
   keyframes were a monotone cubic (never past a keyframe), not a `TweenSequence`; tracks take the same option.
3. **`Transition.arc` is kept, deprecated** (lineup): bending a position change isn't expressible as two curves
   exactly (the bend is perpendicular to the way it goes). Played by the player's transition table.
4. **`PathOrient.uprightFlip`** replaces `uprightMirror` instead of the binding recipe: `${path.angle}` would
   lag a frame behind the turn and needs a binder, which the design canvas doesn't have. `PathFollow.pacing`
   and `focus` (area pacing, orrery) are kept, deprecated: a formula on `progress` needs the orrery's Kepler
   function, which is by hand.
5. **`Pose`** (a `Motion` with `opacity` and `blur`, flat JSON) is the value of a route transition's sides and
   a page view's `pageMotion`/`pageMotionBefore`: those draw a fade with the transform and have no node
   opacity to move it to. Their JSON is unchanged.
6. **Folding the node `scale` and `layout.rotation` into `motion` was not done** (see below).
7. **`opacity` moves to the node's `opacity`** (multiplied in; a bound one becomes the product formula); a
   state style's `motion.opacity` is that state's node `opacity` (exact when the node's own opacity is 1).
   **`blur`** is a `layerBlur` effect with id `motionBlur` (bound as `decoration.effects.motionBlur.blurRadius`).
   A node whose motion set either keeps a transition on it.
8. **Scroll reveal is `NodeAnimation.visibleFraction`**, played by the player itself (it checks the node's
   visible share after each frame while it waits, per object: no process-wide watcher), not a generated
   `enterViewport` reaction: reactions need the actions runtime, which a bare `NodeTree` (and the reveal's
   test) doesn't have.
9. **`NodeAnimation.ramp`** (ms) plays a spin's ramp: a repeating animation speeds up over it, slows to a stop
   when paused and eases to a new pace, exactly as `spinRamp` did (its default 800 ms applied to every spin, so
   removing it would have changed 12 apps). Stated by its pace, not by a curve.
10. **A swing** is a track whose `wave` is a share of `to − from` (the property's own value when `to` is
    omitted) on a replacing track: `{"from": 0, "wave": [{}]}` rocks between its own value and as far the other
    way, linear in time, as `loop: swing` did.
11. **Track numbers carry on past their ends** on an overshooting curve (`Tween<double>`); they were clamped,
    which flattened `elasticOut`/`easeOutBack` entrances.
12. **A counted repeat ends as Flutter's `repeat(count:)` does** (a restart at its start, a reverse at the end of
    its last way) and is `completed`/`dismissed` by its direction; it ended at its last run's end.
13. **A play asked for before the player's ticker starts counts from that frame**, as the motion's own ticker
    did (an entrance was a tick late on the player).

## Not yet migrated

- **The node `scale` behavior and `layout.rotation`** stay their own chain layers (and `_stateScales` its
  workaround). Folding them is a product (`motion.scale × scale`, `rotate + rotation`), and state styles are
  JSON merge patches over the node: a hovered `motion.scale` and a pressed `scale` both active (pressing a
  hovered button) compose by multiplication today, which a patch can't say once both are one key. They also sit
  inside the flip and tilt layers, so a fold changes the picture of a node with a 3D turn or an off-center
  alignment. Needs patches that compose (or a per-state pose) first.
- **`${path.*}`** (the path's angle and point in the node's scope) isn't published.
- **`pathWrap` on an open path** and its short-way-round transition: a closed path wraps, an open one clamps.
- **Legacy `motion.*` paths set at run time** (`setValue` with `motion.duration`): only a node's `bind` map is
  rewritten when it decodes; the pose paths and `motion.originX/Y`, `motion.pathProgress` still apply.
  *Schema 3:* such a path is refused where it is used, with the schema-3 path to write (`schema2PathHint`; the
  validator's `unknown_bind_path`; the SDK sets nothing and says so once). See docs/guide/12-migrating-to-schema-3.md.
- **Bound motion keys with no counterpart** are dropped: `rotateCurve`, `fadeShare`, `arc`, `spring*`,
  `revealOnScroll`, `revealFraction`, `pathWrap`, and a loop's or entrance's keys on a motion that has none.
- **Keyframes on a reverse loop** run backwards on the way back (the curve too, as `CurvedAnimation` over
  `repeat(reverse: true)` does); they ran forward on both ways.

## Done in schema 3

Migrated, not read by the model any more (steps `motion.legacy`, `pose.legacy`, `transitions.legacy`):
`originX/Y`, the flat path keys, motion `opacity`/`blur`, the timing, entrance, loop, spin, keyframes and
shimmer keys, the transitions object and map, and the pose keys of `pageMotion` and route transition sides;
a bound `motion.originX/Y` binds `motion.alignment`. **Removed** (dropped by the migration, the value kept as
`legacy.<name>` and reported): `Transition.arc` (lineup), `PathOrient.uprightFlip` (now `upright`;
lineworks_v2), `PathFollow.pacing`/`focus` (orrery).

**Not done in schema 3: folding the node `scale` and `layout.rotation` into `motion`** (and with it the
SDK's `_stateScales`). It needs the state-composition rule this section asks for: state patches are JSON
merge patches, and a hovered `motion.scale` with a pressed node `scale` (both active) multiply today; one
`motion.scale` key would let the later state replace the earlier. The rule to build: active states resolve
each `motion` number by `WidgetState` precedence (as Flutter's `WidgetStateProperty` resolves one value from
the set of states), with `scale` composing multiplicatively and `rotate` additively across the node's own
pose and the winning state; then migrate `scale`/`layout.rotation` (only exact with a centered alignment and
no 3D turn, else kept as legacy). Blocked on that rule and its proof against the pressed/hover tests; not
started.
