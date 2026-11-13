# 8. Animation: `animations`, `animate`, `frame` and `Spring`

[Guide](README.md) · Previous: [Drawing with `customPaint`](07-custom-paint.md)

Animation is Flutter's `AnimationController` and `Tween` as data (`lib/src/animation.dart`). A node's
`animations` is a list of controllers; each drives *tracks*, tweens on any binding path of the node (or of
another node, or on a variable). One action, `animate`, calls the controller's methods; one trigger, `frame`,
is a `Ticker`; one value, `Spring`, is every spring. What a Flutter developer would write translates line by
line:

```dart
final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
final drop = Tween(begin: -260.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)).animate(c);
final fade = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0, 0.33, curve: Curves.easeOut))).animate(c);
```

```json
{"animations": [{"id": "enter", "duration": 700, "tracks": [
  {"id": "drop", "path": "motion.translateY", "from": -260, "curve": "easeOutCubic"},
  {"id": "fade", "path": "opacity", "from": 0, "interval": [0, 0.33], "curve": "easeOut"}]}]}
```

A track that leaves out `to` (or `from`) tweens to (from) the property's own value: the entrance above ends
where the node is laid out, which is also where the design canvas draws it.

## The controller: `NodeAnimation`

| Key | Default | Flutter |
|---|---|---|
| `id` | | Unique on the node: what `animate` names, `${animation.<id>.*}` reads and a binding addresses (`animations.<id>.paused`) |
| `duration`, `reverseDuration` | 300 (or the preset's) | `AnimationController.duration`, `reverseDuration` (ms) |
| `delay` | 0 | A wait before each play (ms); the value holds at its start |
| `curve` | `linear` (or the preset's) | `CurvedAnimation(parent: controller, curve:)`, before every track |
| `repeat` | once (or the preset's) | `controller.repeat(reverse:, count:)`: `{}` is forever, `{"reverse": true, "count": 3}` |
| `autoplay` | `true` (or the preset's) | `forward()` (or `repeat()`) when the node appears |
| `playKey` | | A change to a value that isn't empty, `0`, `false` or `null` plays it from the start (`forward(from: 0)`); not when the node first shows. Usually bound |
| `paused` | `false` | `stop()` while true; carries on when false |
| `phase` | 0 | Where a play starts, a share of one cycle (`forward(from: phase)`; with `repeat.reverse`, of the run there and back): `${= index / count}` staggers copies |
| `enabled` | `true` | False: no track applies and nothing runs (the node shows its own values) |
| `spring` | | `animateWith(SpringSimulation(spring, 0, 1, 0))` instead of `duration` and `curve` |
| `progress` | | An expression giving the value (0–1) with no clock: `${view.progress}`, a variable |
| `alignment` | center (or the preset's) | The point an adding or multiplying track's scale and rotation are about (`ScaleTransition(alignment:)`) |
| `previewAt` | none (or the preset's) | Where the design canvas draws it, a share of one cycle after its `phase`; none: not drawn there |
| `tracks` | `[]` | The tweens, below |
| `preset`, `params` | | A short form, below |

The state reads as `${animation.<id>.value}` (after `curve`), `${animation.<id>.status}` (`dismissed`, `forward`,
`reverse`, `completed`) and `${animation.<id>.isAnimating}` in the node and the nodes inside it. A canvas-level
animation is visible to the whole screen; a node reacts to its end with `valueChanged` on
`animation.<id>.status`.

## Tracks: `AnimationTrack`

| Key | Default | Flutter |
|---|---|---|
| `id` | | Stable within the animation (`animations.enter.tracks.fade.from`) |
| `path` | | A binding path: `motion.rotate`, `opacity`, `decoration.fills[0].color`, `layout.width`, `props.value` |
| `node` | the animation's node | Another node's id or key |
| `variable` | | Instead of `path`: a number variable written each frame |
| `from`, `to` | the property's own | `Tween(begin:, end:)`: numbers, colors (`ColorTween`) or `${...}` expressions read when a play starts; anything else switches at the end |
| `keyframes` | `[]` | `TweenSequence`: `{at, value, curve}` stops, `curve` easing the segment that ends there |
| `interval` | `[0, 1]` | `Interval(begin, end)` |
| `curve` | `linear` | `CurveTween` inside the interval |
| `blend` | `replace` | `add` or `multiply`: the value adds to (multiplies) the property's own, as a `SlideTransition` / `RotationTransition` (`ScaleTransition` / `FadeTransition`) wrapped around the node would |
| `wave` | `[]` | Sines added to `from`: `{cycles, amplitude, phase, decay, rectify}`, `amplitude · sin(2π(cycles·t + phase)) · (1 − decay·t)` |

What a frame costs follows the path: `motion.*` and `opacity` are drawn by the node's render objects without
rebuilding it; any other path patches the node as shown (it is built again, laid out when the path sizes it);
a variable track writes the variable, and everything bound to it follows. One number per frame is fine; a
hundred bound nodes are not.

Two nodes driven by one screen controller, the year of an orrery:

```json
{"animations": [{"id": "year", "duration": 60000, "repeat": {}}],
 "bind": {"animations.year.paused": "${= !running}"}}
```

```json
{"bind": {"motion.pathProgress": "${= keplerProgress(animation.year.value * 4.15, 0.2056)}"}}
```

## Presets: the short forms

A preset names tracks and timing; the fields given beside it override the preset's, and JSON keeps the short
form. `NodeAnimation.expanded` is the primitive form the SDK plays.

```json
{"animations": [{"id": "halo", "preset": "pulse", "params": {"scaleTo": 1.4, "opacityTo": 0}, "duration": 1600}]}
```

| Preset | Params (defaults) | Timing | Tracks |
|---|---|---|---|
| `pulse`, `fade`, `scale` | `scaleFrom`, `scaleTo`, `opacityFrom`, `opacityTo` (1) | 1000 ms, forever, drawn at its start | `motion.scale`, `opacity` multiplied |
| `spin` | `turns` (1), or `perSecond` | 1000 ms, forever | `motion.rotate` added, 0 → 360 × turns |
| `bob` | `distance` (10) | 1000 ms, forever | `motion.translateY` added, a half sine up |
| `sway` | `angle` (4) | 1000 ms, forever | `motion.rotate` added, a sine |
| `flicker` | as `pulse` | 1000 ms, forever | `motion.scale`, `opacity` multiplied, three detuned sines |
| `shake`, `wiggle`, `jelly`, `flash` | `amount` (1), `cycles` (4, 3, 2, 2) | 520 ms, on cue | decaying sines on `translateX`, `rotate`, `scaleX`/`scaleY`, `opacity` |
| `bounce`, `pop` | `amount` (1) | 520 ms, on cue | hops with a squash; a swell |
| `keyframes` | `frames` (`[{t, translateX, translateY, scale, scaleX, scaleY, rotate, opacity}]`), `amount` | 520 ms, on cue | from rest through the frames back to rest |
| `enter` | `from` (`{translateY: 20, opacity: 0}`) | 300 ms, `easeOutCubic`, once | one track per value, to the node's own |

A one-shot effect is an animation with `"autoplay": false`, played by `animate` or its `playKey`:

```json
{"animations": [{"id": "nudge", "preset": "shake", "params": {"cycles": 3}}],
 "bind": {"animations.nudge.playKey": "${= shake.cell == item.i ? shake.tick : ''}"}}
```

## The `animate` action

`AnimationController`'s methods: `forward`, `reverse`, `toggle`, `repeat`, `stop`, `reset`, `animateTo`,
`animateBack`, `set` (`controller.value = target`). The chain waits for the play to end (a `TickerFuture`)
unless the action is `nonBlocking`. `command` defaults to `forward`; `node` to the reacting node.

```json
{"type": "animate", "node": "card", "animation": "nudge", "from": "0"}
```

On a number variable it runs an unbounded timeline the screen keeps (`animateTo` from `from` or where the value
is, `stop` holds it, `forward` carries on, `set` jumps):

```json
{"type": "animate", "variable": "shownTotal", "command": "animateTo", "target": "${total}", "duration": "800", "curve": "easeOutCubic"}
```

## The `frame` trigger and the timer

`frame` is a `Ticker`: every frame while the node is on stage and `when` holds, with `${result.dt}` (ms since
the frame this chain last got), `${result.elapsed}` and `${result.frame}`. A frame that comes while the chain
still runs is skipped and its time added to the next `dt`. It is meant for a simulation step, not for moving
a node (an animation does that without a chain).

```json
{"trigger": {"type": "frame", "when": "${playing}"},
 "actions": [{"type": "runScript", "script": "advance", "arguments": {"dt": "${result.dt}"}}]}
```

`timer` is `Timer.periodic`: `intervalMs` a number or an expression (at least 16 ms), `${result.tick}` counting.

```json
{"trigger": {"type": "timer", "intervalMs": "${= 60000 / bpm}", "when": "${playing}"},
 "actions": [{"type": "playSound", "sound": "tick"}]}
```

## `Spring`

Flutter's `SpringDescription`: `{"stiffness": 380, "damping": 20, "mass": 1}`, or
`SpringDescription.withDurationAndBounce` as `{"duration": 500, "bounce": 0.3}`. It is the value of an
animation's and an `animate` action's `spring`, a motion's `spring` curve, `GesturePhysics.spring`,
`draggable.spring`, `drag.track.settleSpring`, `flip.spring` and a route dismiss's `spring`. A physical spring
that gives one constant takes the owner's default for the other, and is written over it (`{"stiffness": 200}`).

```json
{"animations": [{"id": "flip", "autoplay": false, "spring": {"duration": 450, "bounce": 0.3},
  "tracks": [{"path": "motion.rotateY", "from": 0, "to": 180}]}]}
```

## The legacy keys

Documents written before keep loading and playing the same. The decoders read every older shape and return
the new one; the encoders write only the new one:

| Written before | Reads as |
|---|---|
| `loops[i]` | animation `loop<i>`, preset of its `type`; `lag` folded into `phase`, `reverse` into `repeat.reverse`, `enabled` kept |
| `effectAnimations[i]` | an animation named after it (`effect<i>` unnamed), preset of its `type`, on cue; `playOnAppear` → `autoplay`, `originX/Y` → `alignment` |
| `motion.pulseKey` (which no SDK ever read) | animation `pulse`: the motion's keyframes from its values and back, on that key |
| bindings `loops[i].*`, `effectAnimations[i].*`, `motion.pulseKey` | `animations.<id>.*` (a loop's `phase` and `lag` as one formula) |
| `playAnimation {node, animation}` | `animate {node, animation, from: "0"}` |
| `animateVariable` `play`/`pause`/`resume`/`stop`/`seek` | `animate {variable}` `animateTo`/`stop`/`forward`/`stop`/`set` |
| `clock {every, runWhen, lookaheadMs}` | `timer {intervalMs, when}` |
| `FlipSpring`, `TransitionSpring`, `springStiffness`/`springDamping`, `settleStiffness`/`settleDamping`, `GesturePhysics`' flat `stiffness`/`damping`/`mass`/`bounce`/`duration` | `Spring`, with each owner's old defaults |

```json legacy
{"loops": [{"type": "pulse", "scaleFrom": 0.65, "duration": 1400, "reverse": true, "lag": 175}],
 "effectAnimations": [{"name": "nudge", "type": "shake", "cycles": 3}],
 "bind": {"effectAnimations[0].playKey": "${hits}"}}
```

```json
{"animations": [
  {"id": "loop0", "preset": "pulse", "params": {"scaleFrom": 0.65}, "duration": 1400, "repeat": {"reverse": true}, "phase": 0.9375},
  {"id": "nudge", "preset": "shake", "params": {"cycles": 3}}],
 "bind": {"animations.nudge.playKey": "${hits}"}}
```

Not yet moved (they keep their keys and behave as before): the temporal half of `motion` (`enter`,
`enterFrom`, `loop`, `spin`, `keyframes`, `replayKey`, `shimmer`, its transition `duration`/`curve`),
`setVariable.animateMs`, `strokePath`'s drawing, `typewriter` and text `countUp`; see
[docs/design/02-animation.md](../design/02-animation.md), "Not yet migrated".
