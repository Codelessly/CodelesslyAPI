# 02 · AnimationController, Tween and Ticker as data

Status: proposal. Depends on nothing; docs 01, 03 and 04 depend on it.
Usage counts are apps whose `editor/` or `tool/` build sources name the key
(text grep: an upper bound for common words, and a lower bound where a
generator sets the key through a helper).

## 1. Problem

The model has no animation controller. It has ten features that each embed
one:

| Mechanism | Where | Apps |
|---|---|---|
| `loops[]` (`pulse`, `fade`, `scale`, `spin`, `bob`, `sway`, `flicker`) | `behaviors.dart:931, 973` (15 fields) | 12 |
| `motion.loop` / `repeat` / `phase` / `paused` | `behaviors.dart:406-425` | `loop` 27, `paused` 17 (both common words) |
| `motion.spin` / `spinRamp` | `behaviors.dart:404-405` | 12 / 1 |
| `motion.keyframes` | `behaviors.dart:289, 416` | 16 |
| `motion.enter` / `enterFrom` / `replayKey` | `behaviors.dart:408-410` | 25 / 30 / 5 |
| `motion.pulseKey` | `behaviors.dart:417` | 2 (chairlift, flashcards). **The SDK never reads it**: `grep -rn pulseKey CodelesslySDK/lib` is empty |
| `motion.shimmer` | `behaviors.dart:236` | 6 |
| `effectAnimations[]` + `playAnimation` / `playKey` / `playOnAppear` | `behaviors.dart:2097, 2102`; `actions.dart:2499` | 10 / 5 / 2 / 2 |
| `animateVariable` action | `actions.dart:897` | 6 |
| `setVariable.animateMs` | `actions.dart:825` | 8 |
| `strokePath.draw*`, `typewriter`, text `countUp`, `flip`, `flight` | `behaviors.dart:2482, 2636`; `widgets/text.dart:31`; `gestures.dart:276`; `behaviors.dart:2388` | 0 / 1 / 2 / 12 / 9 |

And three clocks:

| Clock | Where | Apps |
|---|---|---|
| `timer` trigger, minimum 16 ms | `triggers.dart:103, 274` | 24 |
| `clock` trigger, documented as "a steady audio clock" | `triggers.dart:105-108` | 25. It is the same `Timer.periodic` as `timer` (`CodelesslySDK/lib/src/runtime/actions/wiring.dart:308`). `lookaheadMs` (`triggers.dart:219`) is set by 3 apps and **read nowhere** in the SDK |
| `nowMs()` in formulas, rebuilt every frame | `CodelesslySDK/lib/src/runtime/expressions/formula.dart:129` | 11 (backline, burrow, burrow_v2, cutroom, darkroom, lineup, mixtape, orrery, petri, safecracker, seedbox) |

Six spring shapes, with five different defaults:

| Shape | Where | Default (stiffness / damping / mass) |
|---|---|---|
| `GesturePhysics` | `gestures.dart:105` | 380 / 32 / 1, or `bounce` + `duration` |
| `Motion.springStiffness/Damping` | `behaviors.dart:402-403` | 380 / 20 (0 apps set them) |
| `DragSource.springStiffness/Damping` | `behaviors.dart:1349-1350` | 260 / 14 |
| `DragTrack.settleStiffness/Damping` | `behaviors.dart:1576-1577` | 380 / 20 |
| `FlipSpring` | `gestures.dart:247` | 380 / 36 / 1 |
| `TransitionSpring` | `route_transition.dart:203` | 380 / 36 / 1 |

Each player is its own code in the SDK: `RenderLoops` and `RenderMotion`
(`render/behaviors.dart:744, 810`), `RenderEffects` (`render/play.dart:170`),
`VariableAnimator` (`runtime/actions/variable_animator.dart`),
`render/typewriter.dart`, `render/count_up.dart`. Those five files total
2,873 lines (not all of it animation).

## 2. Flutter grounding

| Flutter (checked in `/opt/flutter/packages/flutter/lib/src`) | Mirrored as |
|---|---|
| `AnimationController({duration, reverseDuration, lowerBound, upperBound})`, `.unbounded` (`animation/animation_controller.dart:286`) | `NodeAnimation`: `duration`, `reverseDuration`; a variable track with no values is unbounded |
| `forward({from})`, `reverse({from})`, `toggle`, `repeat({reverse, count})` (`:714`), `animateTo(target, {duration, curve})`, `animateBack`, `stop`, `reset`, `value =`, `animateWith(Simulation)` | the `animate` action's commands |
| `AnimationStatus { dismissed, forward, reverse, completed }` (`animation/animation.dart:24-33`) | `${animation.<name>.status}` |
| `Tween`, `ColorTween`..., `TweenSequence` / `TweenSequenceItem({tween, weight})` (`animation/tween_sequence.dart:121`) | a track's `from`/`to` or `keyframes` |
| `Interval(begin, end, {curve})` (`animation/curves.dart:158`), `CurveTween` (`animation/tween.dart:557`), `Curves.*` | a track's `interval` and `curve`; `AnimationCurve` (`behaviors.dart:24`) |
| `SpringDescription({mass, stiffness, damping})`, `.withDurationAndBounce({duration = 500 ms, bounce = 0})` (`physics/spring_simulation.dart:27, 70`), `SpringSimulation`, `FrictionSimulation(drag, position, velocity)` (`physics/friction_simulation.dart:40`) | one `Spring` value; `GesturePhysics.friction` (doc 04) |
| `Ticker(TickerCallback onTick)`, `typedef TickerCallback = void Function(Duration elapsed)` (`scheduler/ticker.dart:24, 78`) | the `frame` trigger |
| `Timer.periodic` (`dart:async`) | the `timer` trigger |

## 3. Proposed model

### 3.1 `animations`: controllers with tracks

`animations` is a behavior key, a list, on any node. A screen-level
controller is one on the canvas node: no second mechanism.

```dart
/// One `AnimationController` and the tweens it drives.
@immutable
final class NodeAnimation {
  const NodeAnimation({
    required this.name,
    this.preset,
    this.params = const {},
    this.duration = 300,
    this.reverseDuration,
    this.delay = 0,
    this.curve = AnimationCurve.linear,
    this.repeat,
    this.autoplay = true,
    this.playKey,
    this.paused = false,
    this.phase = 0,
    this.spring,
    this.progress,
    this.tracks = const [],
    this.previewAt,
  });

  /// Unique on the node. Read as `${animation.<name>.*}`; named by `animate`.
  final String name;

  /// A named preset this animation is short for (§5), with its [params].
  /// Other fields given here override the preset's.
  final String? preset;
  final Json params;

  /// `AnimationController.duration` / `reverseDuration` (ms).
  final int duration;
  final int? reverseDuration;

  /// Wait before a play starts (ms).
  final int delay;

  /// Applied to the controller's value before every track
  /// (`CurvedAnimation(parent: controller, curve:)`).
  final AnimationCurve curve;

  /// `controller.repeat(reverse:, count:)`; null plays once.
  final AnimationRepeat? repeat;

  /// Plays when the node appears. False: waits for [playKey] or an action.
  final bool autoplay;

  /// A change of this value plays from the start (`forward(from: 0)`).
  /// Not when the node first shows. Bindable.
  final String? playKey;

  /// Holds the controller where it is while true (`stop()`), carries on
  /// when false. Held before it starts, it waits at its start. Bindable.
  final bool paused;

  /// Where a play starts, 0–1 of one run: `forward(from: phase)`. Bindable
  /// (`${= index / count}` staggers copies).
  final double phase;

  /// Runs on a spring instead of [duration] and [curve]:
  /// `controller.animateWith(SpringSimulation(spring, from, to, velocity))`.
  final Spring? spring;

  /// An expression giving the controller's value directly (0–1): scroll
  /// progress (`${view.progress}`), a variable, a drag. With it the
  /// animation has no clock; [spring] (when set) eases toward each new value.
  final String? progress;

  final List<AnimationTrack> tracks;

  /// Where the design canvas draws it (0–1). Null: not applied (§6).
  final double? previewAt;
}

/// `repeat(reverse:, count:)`. [count] 0 is forever.
final class AnimationRepeat { final bool reverse; final int count; }

/// One tween: a property (or variable) driven by the controller.
@immutable
final class AnimationTrack {
  /// A binding path on [node] (`motion.rotate`, `opacity`,
  /// `decoration.fills[0].color`, `layout.width`,
  /// `customPaint.painter.<id>.trim`), any path `BindPaths` accepts.
  final String path;

  /// The target node's id or key; empty: the node carrying the animation.
  final String node;

  /// Instead of [path]: a screen variable the value is written to.
  final String variable;

  /// `Tween(begin: from, end: to)`. Null means the target's own value: an
  /// entrance gives only `from`, an exit only `to`.
  final Object? from, to;

  /// `TweenSequence`: values at times 0–1, each segment with its own curve.
  /// When given, [from]/[to] are ignored.
  final List<Keyframe> keyframes;   // {at, value, curve}

  /// `Interval(begin, end)`: the part of the run this track plays in.
  final List<double> interval;      // default [0, 1]

  /// `CurveTween` over the track (inside its interval).
  final AnimationCurve curve;       // default linear
}

/// Flutter's `SpringDescription`. Either the physical triple or
/// `withDurationAndBounce`.
@immutable
final class Spring {
  const Spring({this.stiffness, this.damping, this.mass = 1, this.duration = 500, this.bounce = 0});
  final double? stiffness, damping;  // both set: SpringDescription(mass:, stiffness:, damping:)
  final double mass;
  final int duration;                // else: withDurationAndBounce(duration:, bounce:)
  final double bounce;
}
```

Values are interpolated by the path's declared type (its `PropCodec`):
numbers, `Color`, `Offset`, `EdgeInsets`, `BorderRadius` lerp; anything
else switches at the segment's end (`ConstantTween`).

**Exposed state**, in the node's scope like `${track.*}` (a canvas-level
animation is visible to the whole screen):

| Read | Value |
|---|---|
| `${animation.<name>.value}` | the controller's value after `curve` |
| `${animation.<name>.status}` | `dismissed`, `forward`, `reverse`, `completed` |
| `${animation.<name>.isAnimating}` | bool |

A node reacts to an animation ending with the existing `valueChanged`
trigger on `animation.<name>.status`.

### 3.2 One action: `animate`

```json
{"type": "animate", "node": "card", "animation": "pop", "command": "forward", "from": "0"}
```

| Field | Type | Default | Meaning |
|---|---|---|---|
| `node` | String | the reacting node | Whose animation |
| `animation` | String | | Its name |
| `variable` | String | | Instead of `node` + `animation`: an unbounded controller the screen keeps for this number variable |
| `command` | `forward`, `reverse`, `toggle`, `repeat`, `stop`, `reset`, `animateTo`, `animateBack`, `set` | `forward` | The `AnimationController` method (`set` is `controller.value = target`) |
| `from` | expression | | `forward(from:)` / `reverse(from:)`; for `animateTo` on a variable, the start value |
| `target` | expression | | `animateTo` / `animateBack` / `set` |
| `duration` | expression (ms) | the animation's | Override |
| `curve` | `AnimationCurve` | the animation's | Override |
| `spring` | `Spring` | | `animateWith(SpringSimulation)` to `target` |

The chain waits for the `TickerFuture` unless the action is `nonBlocking`,
as `animateVariable` does today.

### 3.3 The `frame` trigger (Ticker)

```json
{"trigger": {"type": "frame", "when": "${playing}"},
 "actions": [{"type": "runScript", "script": "advance", "arguments": {"dt": "${result.dt}"}}]}
```

| `${result}` key | Value |
|---|---|
| `dt` | ms since the previous tick delivered to this chain |
| `elapsed` | ms since the ticker started (`TickerCallback`'s `elapsed`) |
| `frame` | tick count |

The ticker runs only while `when` holds and the node is on stage (muted
like `TickerMode` otherwise; a design canvas never ticks). If the chain is
still running when the next frame comes, that frame is skipped and its time
is added to the next `dt`.

### 3.4 Timers

| Today | Proposed |
|---|---|
| `timer` (`intervalMs`, int) | kept: `Timer.periodic`. `intervalMs` becomes an expression; `${result.tick}` counts. Minimum stays 16 ms; anything per-frame uses `frame` |
| `clock` (`every`, `runWhen`, `lookaheadMs`) | **removed.** Decodes as `timer` (`every` → `intervalMs`, `runWhen` → `when`). `lookaheadMs` is dropped: nothing ever read it. Sample-accurate audio scheduling is `playSound`'s `at`, not a trigger |
| `nowMs()` | kept as a wall clock for formulas, but no longer the way to animate: `frame`'s `dt` or an animation replaces hand-rolled deltas |

### 3.5 Worked examples

**cheers_v2's card entrance** (today `motion.enterFrom` + `rotateCurve:
elasticOut` + `fadeShare: 0.33`, `cheers_v2/blockers.md`): two one-app fields
become two track settings.

```json
"animations": [{"name": "enter", "duration": 700, "tracks": [
  {"path": "motion.translateY", "from": -260, "curve": "easeOutCubic"},
  {"path": "motion.rotate", "from": -14, "curve": "elasticOut"},
  {"path": "opacity", "from": 0, "interval": [0, 0.33], "curve": "easeOut"}]}]
```

**orrery's planets** (today `nowMs()` deltas and `motion.pathPacing: area`):
one screen controller is the year; each planet's path progress is a formula
of it.

```json
"canvas":  {"animations": [{"name": "year", "duration": 60000, "repeat": {}}],
            "bind": {"animations.year.paused": "${= !running}"}},
"mercury": {"bind": {"motion.path.progress": "${= keplerProgress(animation.year.value * 4.15, 0.2056)}"}}
```

**tally's counting total** (today `animateVariable`):

```json
{"type": "animate", "variable": "shownTotal", "command": "animateTo",
 "target": "${total}", "duration": "800", "curve": "easeOutCubic"}
```

**Short form** (what authors and agents write; §5):

```json
"animations": [{"name": "halo", "preset": "pulse", "params": {"scaleTo": 1.4, "opacityTo": 0}, "duration": 1600}]
```

## 4. Editor panel

`NodeAnimationFields`, `AnimationTrackFields`, `KeyframeFields`,
`SpringFields`, `AnimateActionFields` are `PropDef` lists. The Animations
section lists the node's animations; each shows Preset (a menu from the
catalog, with that preset's `params` as generated fields), Timing
(duration, delay, curve or spring, repeat), Start (autoplay, play key,
paused, phase), and Tracks (a path picker fed by `BindPaths`, from/to or a
keyframe strip). "Expand preset" replaces a preset by its tracks for
editing. A badge marks each track's cost class (§7).

## 5. Presets: the short forms stay, the SDK has one player

A preset is a pure function `NodeAnimation Function(Json params)` plus a
`PropDef` list for its params. They live in the API package
(`lib/src/animation_presets.dart`), registered in the catalog (doc 05) so
plugins add their own. `NodeAnimation.expanded` returns the primitive form;
the SDK plays only that. JSON keeps the short form (round trip), as
`GesturePhysics.presets` does today (`gestures.dart:119`).

| Preset | Was | Expands to |
|---|---|---|
| `pulse` | `loops` pulse | `repeat`; tracks `motion.scale` and `opacity`, `from`/`to` |
| `fade`, `scale` | `loops` fade, scale | one of those tracks |
| `spin` (`turns`, or `perSecond`) | `loops` spin; `motion.spin` | `repeat`, linear; `motion.rotate` 0 → 360 × turns |
| `bob` (`distance`) | `loops` bob | `repeat`; `motion.translateY` keyframes 0, −d, 0 on `easeInOutSine` |
| `sway` (`angle`) | `loops` sway | `repeat`; `motion.rotate` keyframes 0, a, 0, −a, 0 |
| `flicker` | `loops` flicker | `repeat`; `motion.scale`/`opacity` keyframes sampled from `flickerAt` (32 samples: close, not bit-identical) |
| `shake`, `bounce`, `pop`, `wiggle`, `jelly`, `flash` (`amount`, `cycles`) | `effectAnimations` | `autoplay: false`; keyframes on `motion.translateX` / `translateY` / `scale` / `rotate` / `scaleX`+`scaleY` / `opacity` |
| `keyframes` (`frames`) | `effectAnimations` keyframes; `motion.keyframes` | one track per property named in the frames |
| `enter` (`from`) | `motion.enter` + `enterFrom` | one track per value in `from`, `to` omitted (the node's own value) |
| `loop` (`from`, `mode`) | `motion.loop` restart / reverse / swing | `repeat` (`reverse` for reverse; sine keyframes about rest for swing) |
| `shimmer` | `motion.shimmer` | `repeat`; one track on `shimmer.position` 0 → 1; `previewAt: 0.5` (the band itself stays a paint effect, doc 03) |
| `draw` | `strokePath.drawMs` | one track on the op's `trim` end, 0 → 1 |
| `typewriter` | `typewriter` | one track on `props.maxVisible` (characters shown) |
| `countUp` | text `countUp*` | one track on `props.text`'s number, from the previous value |
| `flip` | `flip` turning | one track on `motion.rotateY` 0 → 180, on a `Spring` |

`typewriter`, `countUp` and `flip` keep their behavior or props for what is
not animation (caret, number formatting, two faces, tap and drag to flip);
only their clocks move here.

## 6. The design canvas: at rest

A design canvas (a non-interactive `NodeView`) runs no controller. It draws
the node's stored values, with no track applied. Because a track's omitted
`from`/`to` means "the node's own value", an entrance rests at its end pose
and a loop at its start, which is what the canvas draws today ("the
motion's values, each loop's first frame", DESIGN.md §5). An animation
whose rest frame says nothing (a shimmer) sets `previewAt`. The editor's
"play" button runs a node's animations in place.

## 7. Per-frame cost

A track's target decides what a frame costs. The compiler sorts tracks
into three classes when the node is built:

| Class | Paths | Per frame |
|---|---|---|
| Composite | `motion.*`, `opacity` | Written straight into the node's `RenderPose` (`render/behaviors.dart:524`) by a ticker in the render object: no binder, no node rebuild, `markNeedsPaint` on a repaint boundary. What `RenderLoops`/`RenderMotion` do today |
| Paint | `decoration.*`, `customPaint.*`, text style colors | The typed node patch `NodeBindings` applies, then repaint; no layout |
| Layout / data | `layout.*`, `props.*` that size, `variable` | A node patch and relayout, or a variable write through the binder: everything bound to it re-evaluates. Fine for one number per frame; wrong for hundreds |

`${animation.x.value}` read from a binding is the third class. The `frame`
trigger costs one action chain per frame: meant for a simulation step
(petri_v2's `advance`), not for moving a node.

## 8. SDK implementation

| Piece | Replaces | LOC (estimate) |
|---|---|---|
| `AnimationPlayer` per node: controllers, compiled tracks, scope | `RenderLoops`, the temporal half of `RenderMotion` (about 400 of its lines), `RenderEffects`, `VariableAnimator`, the clocks in `typewriter.dart` and `count_up.dart` | +600, −1,300 |
| `frame` trigger in `TreeReactions`; `clock` folded into `timer` (`wiring.dart:269-311`) | | +60, −40 |
| Presets | `LoopAnimation.poseAt`, `EffectPlayers` (`play.dart:132`) | in the API package: +350, −450 |

## 9. Migration

Flutter spelling is what a model writing Dart would write for the new form.

| Today | New | How | Flutter spelling | Apps |
|---|---|---|---|---|
| `loops[i]` | `animations[]` preset of the same `type`; `enabled: false` → `paused: true`; `lag` → `phase − lag / loop` | mechanical | `controller.repeat(reverse: true)` + `ScaleTransition`/`FadeTransition` | 12 |
| `loops[i].phase`, `.lag` bindings | `animations.<name>.phase` | mechanical | `forward(from:)` | 2 (`lag`) |
| `motion.enter`, `enterFrom` | preset `enter` | mechanical | `TweenAnimationBuilder` / `SlideTransition` + `FadeTransition` | 30 |
| `motion.replayKey` | that animation's `playKey` | mechanical | `didUpdateWidget` → `forward(from: 0)` | 5 |
| `motion.loop`, `repeat`, `phase`, `paused` | preset `loop` with `repeat.count`, `phase`, `paused` | mechanical | `controller.repeat` | 27 (upper bound) |
| `motion.spin` | preset `spin` (`perSecond`) | mechanical | `RotationTransition(turns: controller)` | 12 |
| `motion.spinRamp` | removed; a first `easeIn` animation then the loop, or `frame` integrating a speed | by hand | — | 1 (lineworks_v2) |
| `motion.keyframes` | preset `keyframes` | mechanical | `TweenSequence` | 16 |
| `motion.pulseKey` | removed (never implemented in the SDK); a `playKey` animation with keyframes rest → pose → rest | by hand | `forward().then((_) => reverse())` | 2 |
| `motion.rotateCurve`, `fadeShare` | a track's `curve` / `interval` | mechanical | `CurveTween`, `Interval` | 1, 1 (cheers_v2) |
| `motion.enterHeld` | the enter animation's `paused` binding | mechanical | deferred `forward()` | 1 (burrow_v2) |
| `motion.revealOnScroll`, `revealFraction` | `autoplay: false` + a generated `enterViewport` reaction (`visibleFraction`) → `animate forward` | mechanical | `VisibilityDetector` → `forward()` | 3 |
| `motion.duration`, `delay`, `curve`, `springStiffness/Damping` (implicit) | `transitions` (doc 03) | mechanical | `AnimatedContainer(duration:, curve:)` | 44 use `motion` |
| `motion.shimmer` | preset `shimmer` | mechanical | `ShaderMask` + `controller.repeat()` | 6 |
| `effectAnimations[i]` (`name`, `type`, `amount`, `cycles`, `delay`, `duration`, `originX/Y`, `curve`, `keyframes`) | `animations[]` preset, `autoplay: false`; `playOnAppear` → `autoplay: true`; origin → `motion.alignment` | mechanical unless two effects on a node have different origins | `controller.forward(from: 0)` | 10 |
| `effectAnimations[i].playKey` binding | `animations.<name>.playKey` | mechanical | | 2 |
| `playAnimation {node, animation}` | `animate {node, animation, command: forward, from: 0}` | mechanical, in the action decoder | `controller.forward(from: 0)` | 5 |
| `animateVariable` play / pause / resume / stop / seek | `animate {variable}`: `animateTo` (+`from`) / `stop` / `forward` / `stop` / `set` | mechanical | `AnimationController.unbounded`; `animateTo` | 6 |
| `setVariable.animateMs` + `curve` | `animate {variable, command: animateTo, target, duration, curve}` (for `add`/`subtract`, target is the sum) | mechanical for `set`, `add`, `subtract`; other ops never animated | `animateTo` | 8 |
| `strokePath.drawMs/drawDelayMs/drawCurve/drawKey` | preset `draw` (`duration`, `delay`, `curve`, `playKey`) | mechanical | `PathMetric.extractPath` + controller | 0 |
| `typewriter.charsPerSecond/delayMs/playKey/holdAtMs` | preset `typewriter`; caret fields stay | mechanical | `IntTween` over `text.length` | 1 |
| text `countUp`, `countUpDuration`, `countUpCurve`, `countUpOnShow` | preset `countUp` | mechanical | `TweenAnimationBuilder<double>` | 2 |
| `FlipSpring`, `TransitionSpring`, `Motion.spring*`, `DragSource.spring*`, `DragTrack.settle*`, `GesturePhysics.stiffness/damping/mass/bounce/duration` | `Spring` | mechanical; each legacy default is written out explicitly on migration so nothing moves differently | `SpringDescription` | — |
| `clock` trigger | `timer` | mechanical | `Timer.periodic` | 25 |
| `Trigger.lookaheadMs` | removed | mechanical | — | 3 |
| `nowMs()` deltas | `frame` trigger or an animation | by hand, optional (`nowMs()` stays) | `Ticker` | 11 |

## 10. Compatibility

`"schema": 2` stays. `Behaviors.fromJson` reads `loops`, `effectAnimations`
and the temporal keys of `motion` and returns `animations`; the action
decoders read `playAnimation`, `animateVariable` and `setVariable.animateMs`
and return `AnimateAction`; `Trigger.fromJson` reads `clock`. Encoders write
only the new shape. Bind keys (`loops[i].phase`, `motion.paused`,
`effectAnimations[i].playKey`) are rewritten to `animations.<name>.*`; a
migrated animation's name is deterministic (`loop0`, `enter`, the effect's
own name).

Not mechanical: `spinRamp` (1 app), `pulseKey` (2 apps, already inert),
`flicker` (sampled), two effects with different origins on one node (not
counted), and any script that calls the removed action types by name.

## 11. Open questions for the owner

1. **Variable tracks.** Recommended: allowed, with the cost class shown.
   The alternative (only `${animation.x.value}` bindings, no writes) is
   cheaper to reason about but leaves `animateVariable`'s users without a
   target that scripts can read.
2. **`duration` default.** Flutter has none. 300 ms proposed; presets carry
   the old per-type defaults (1000 for loops, 520 for effects).
3. **Remove `clock` now or deprecate for a release?** Recommended: remove
   from the model now (it decodes as `timer`; behavior is identical because
   the implementation already is).
4. **`nowMs()`**: keep (recommended) or remove once `frame` exists.

## 12. Rollout

1. API: `NodeAnimation`, `AnimationTrack`, `Spring`, `AnimateAction`,
   `frame`, presets with their `*Fields`; decoders for every legacy key.
2. SDK: `AnimationPlayer` behind the existing render objects, proven by
   replaying the current goldens and `behaviors_test`/`play` tests through
   migrated documents.
3. Delete `RenderLoops`, `RenderEffects`, `VariableAnimator` and the
   temporal half of `RenderMotion`.
4. Editor: Animations section, preset menu, track editor.
5. Docs 03 and 04 land on top (they delete the fields this doc empties).

## Deviations from the proposal

Implemented in `lib/src/animation.dart` and `animation_presets.dart` (parts of `behaviors.dart`), declared in
`behavior_fields.dart` and `action_fields.dart`; SDK: `lib/src/render/animations.dart` (the player), the
`animate` handler in `runtime/actions/handlers.dart`, `frame` and the timer in `runtime/actions/wiring.dart`.
Flutter names were checked against `/opt/flutter/packages/flutter/lib/src/animation/animation_controller.dart`
and `physics/spring_simulation.dart`; the SDK's controller is tested against a real `AnimationController` +
`Tween` (`test/animations_test.dart`).

1. **`id`, not `name`.** Every other list entry of the model is addressed by `id`, and `BindPaths` selects a list
   item by its `id` (`animations.year.paused`, `animations.enter.tracks.fade.from`). `name` is read too. Tracks
   take an optional `id` for the same reason.
2. **`TrackBlend` (`replace`, `add`, `multiply`) and `Wave` were added.** The loops and effects composed *on top
   of* the node's pose (a loop's scale multiplied `motion.scale`, a fade multiplied the node's opacity); a
   `replace` tween can't say that without changing every node that has both. `add`/`multiply` are what a
   `SlideTransition`/`RotationTransition`/`ScaleTransition`/`FadeTransition` wrapped around the node does, and
   their tracks pose the player's own layer (where the loops were in the chain), about the animation's
   `alignment` (`ScaleTransition(alignment:)`), which also carries an effect's `originX/Y`. The effects and
   `bob`/`sway`/`flicker` are sines; keyframes would only approximate them (the proposal accepted 32 samples for
   `flicker`). A `wave` list (`amplitude · sin(2π(cycles·t + phase)) · (1 − decay·t)`, `rectify` for |sin|)
   reproduces every one of them exactly (tested against the old formulas to 1e-9), `flicker` included.
3. **`enabled` was added** (as actions have it). A disabled loop showed the node untransformed; `paused` holds
   it where it is, which is not the same picture.
4. **`phase` is a share of one cycle**, a run there and back when `repeat.reverse`: a loop's `phase` and
   `lag / loop` were, and `forward(from: phase)` alone can't start on the way back. For a non-repeating
   animation it is `forward(from: phase)`.
5. **Fields a preset fills are nullable** (`duration`, `curve`, `repeat`, `autoplay`, `alignment`,
   `previewAt`): null takes the preset's, else Flutter's default (300 ms, linear, once, true, center, not
   drawn). This keeps presets short in JSON without the `named` bookkeeping `Motion` needed.
6. **`previewAt` is a share of a cycle after `phase`**, so a loop rests at its first frame (as the canvas drew
   it) even when its phase is bound per copy.
7. **A spring is unbounded.** Flutter clamps a bounded controller's spring to 0–1; the player lets the bounce
   show (else `spring` on a 0–1 animation could never overshoot).
8. **Play keys fire on a new value that isn't empty, `0`, `false` or `null`**, not only non-empty: the
   reference apps cue with `${= cond ? tick : 0}`, which made a node play when its cue went *away*. This is a
   behaviour change for an effect whose bound key turns to `0`/`false` (it no longer plays then).
9. **A replay or `stop` completes the waiting chain** (the legacy effects did), where Flutter's `TickerFuture`
   never completes once stopped. On a variable, `stop` holds the timeline and its waiting chain stays waiting
   until `forward` (the legacy `pause`); the legacy `stop` mode now behaves as `pause` did.
10. **`timer.intervalMs` is an `Expr<int>`** (the `ExprCodec` precedent of doc 01), and a bare legacy `every`
    formula reads as `${= formula}`. Its interval is worked out again when a name it or `when` reads changes; a
    reaction whose `when` is false doesn't set the timer's pace (the clock's rule, now every timer's).
11. **No new `PropKind`s**: `params`, `from`, `to` and `value` are `Codecs.any`, a track list is
    `List<AnimationTrack>`.
12. **The animate action finds a node's player through the tree** (`NodeBox.animations`), so the render core keeps
    no registry: `EffectPlayers` (a process-wide map) is gone. An action can only reach nodes of its own tree.
13. **A replacing track's patch of a non-composite path** (`decoration.*`, `layout.*`, `props.*`) is held per
    node by `RenderTree.setAnimatedValues` and applied over the node as shown, before the frame lays out (a
    microtask), not through `NodeBindings` itself.

14. **The temporal half of `motion` plays on the player** (doc 03): `enter`/`enterFrom`/`replayKey`/`enterHeld`/
    `revealOnScroll` are the `enter` preset (`params.from`, `params.frames`: the legacy keyframes on one monotone
    cubic; `paused` the hold, `visibleFraction` the reveal), `loop`/`repeat`/`phase`/`paused` the `loop` preset
    (`params.mode: swing`; a reverse loop's `phase` halved, as it was a share of one way), `spin`/`spinRamp` the
    `spin` preset (`params.perSecond`, `ramp`), `shimmer` the `shimmer` preset, the implicit timing a `motion`
    transition. `rotateCurve` and `fadeShare` are per-track curves and intervals (`params.curve`, `rotateCurve`,
    `fadeShare` on the preset; the animation's own curve is then linear). A counted loop with bound values
    replays when they change (a generated `playKey` binding), as the motion restarted it.
15. **`NodeAnimation.ramp` and `visibleFraction`**, **`AnimationTrack.interpolation`**, swings as waves on a
    replacing track, overshooting numbers, Flutter's ends for a counted repeat: doc 03's deviations 9–13.
16. **`setVariable.animateMs` reads as `animate {variable, command: animateTo}`** for `set`, `add` and `subtract`
    (the target `${= name + (value)}` read when the action runs); a path into a variable, another op or a
    templated value stays a `setVariable` glide. An `animateTo` on a variable is a glide: a plain set takes over
    from it (`controller.value =` stops a Flutter controller), and it stops with its chain. Before, a plain set
    didn't stop an `animateVariable` play. A `spring` on `animate {variable}` runs a `SpringSimulation`.
17. **A repeat with no duration holds still** (a spin at 0 turns a second; with a ramp it slows to a stop).

## Not yet migrated

Kept readable and working exactly as before; each still has its own code in the SDK.

- **`typewriter`, text `countUp`, `flip`'s turn**: their clocks are their own (the second
  wave did doc 03's steps 1–3 first; their presets are the next step).
- **`progress` with a `spring`** reads the value directly; easing toward each new value is not built.
- **Legacy binding paths set at run time** (`setValue` with `loops[0].phase` or `effectAnimations[1].playKey`):
  only a node's `bind` map is rewritten when it decodes.
- **Effects now sit inside the motion and rotation layers** (where loops were), not outside them; an effect on a
  node that also scales or rotates through `motion` or `layout.rotation` moves in that frame. Two effects playing
  at once compose first-outermost (they composed last-outermost), and a keyframes effect's scale and rotation
  compose scale-then-rotate. None of the SDK's tests or fixtures has such a node.
- **A legacy spin turns in the player's layer** (about the motion's old origin), like the `spin` preset: inside
  the flip, tilt, `scale` and `layout.rotation` layers rather than inside the motion's matrix, so a spinning node
  that also turns in 3D (`rotateX/Y`, a flip) composes the spin last. No reference build source combines them.

## Done in schema 3

Schema 3 (codelessly_api 30.0.0) moved every legacy reader of this document into the one-time migration
(`migrate2to3`, lib/src/core/migrate): `loops`, `effectAnimations`, motion's temporal keys and `pulseKey`
(step `motion.legacy`), `playAnimation`, `animateVariable`, `setVariable.animateMs` (a glide that is not a
set, add or subtract by one formula now sets at once, reported), `clock` (`trigger.clock`), the flat and
legacy springs (`physics.flatSpring`, `draggable.legacy`, `track.legacy`), and the bound legacy paths in a
node's `bind` (`loops[i].*`, `effectAnimations[i].*`, `motion.*`). The model decodes only the schema-3 shape.
Still as above: `typewriter`, `countUp` and `flip` keep their own clocks (`strokePath.draw*` is an animation of the
path op's `trimEnd` and a transition of it since the stroke path became a custom paint op: doc 01, "30.1.0"); legacy paths set
at run time (`setValue` with `loops[0].phase`) are not rewritten (only stored documents are migrated).
