# Animation and motion

## When to use

Anything that moves: a change that animates (implicit transitions), keyframe animations and presets, moving,
scaling and turning a node without changing layout (`motion`), shared-element flights (`hero`), reveal on
scroll, shimmer, typewriter text, particles, flip cards and tilt, and the timer and frame triggers for clocks and
games.

## Minimal example

A habit check-off: tapping the circle toggles `done`; its fill and scale change through bindings, and
`transitions` animate the change (a small overshoot), while the label fades.

{{example:pages/animation}}

## Reference

{{reference}}

## Patterns

### Animate a change (transitions)

`transitions` is Flutter's implicit animation: when the value at a path changes (a binding, a condition, a state
patch), the node tweens from what it shows to the new value. One entry per path or prefix: `{"property": "motion",
"duration": 250, "curve": "easeOutBack"}`, `"opacity"`, `"decoration"`, `"layout.height"`; `"*"` for every path.
This is the simplest way to animate a check-off, a selected card or an opening panel.

### Move, scale or turn without changing layout (motion)

`motion` is a transform painted over the node's layout (Flutter's `Transform`): `translateX`/`translateY` in pixels,
`scale`, `rotate` in degrees, 3D `rotateX`/`rotateY` with `perspective`, about `alignment` (the center by default).
It is the one way to scale or turn a node: there is no node `scale` and no `layout.rotation` (a turned node keeps
its unturned box in the layout, as `Transform.rotate` does; Flutter's `RotatedBox` has no counterpart). Nothing else
moves. Bind a field (`"motion.rotate": "${= open ? 180 : 0}"`) and add a transition to animate it; a transition on
`motion.scale` times the scale apart from the rest of the motion (`AnimatedScale` beside `AnimatedSlide`).

### Play an animation (animations and presets)

`animations` holds a node's controllers: each runs 0 → 1 over `duration` (or a `spring`), after `delay`, once or
`repeat`ed, and drives `tracks` of keyframes on its paths. A `preset` names a ready-made one (fade in, slide up,
pulse...) with its `params`. `autoplay` false waits for the `animate` action (`forward`, `reverse`, `stop`...) or a
change of `playKey`. A screen-wide animation sits on the canvas.

### Reveal on scroll, view progress, sticky effects

An entrance when a node scrolls into view (CSS scroll-reveal) is an **animation with `visibleFraction`**: it waits
until that share of the node is in view, then plays.

```json
"animations": [{"id": "enter", "duration": 600, "curve": "easeOut", "visibleFraction": 0.3,
                "tracks": [{"path": "opacity", "from": 0, "to": 1}, {"path": "motion.translateY", "from": 24, "to": 0}]}]
```

The `reveal` behavior is not an entrance, despite its name: it **scrolls** the node into view (a chat's newest
line). `viewProgress` gives `${view.progress}` (0–1 through the viewport) to bind to, for effects that follow the
scroll; the `enterViewport` and `exitViewport` triggers run actions. A page's reading progress:
[scroll progress](@layout-scroll-progress).

### Shared elements (hero)

`hero` is Flutter's `Hero`: a tag (`"hero": "avatar-${item.id}"`) flies the node from its place on the screen a
navigation leaves to the node with the same tag on the screen it opens; `flightShuttle` picks what flies (`morph`,
`containerTransform`...). With `"flies": "inPlace"` it flies when it appears instead, from where the node with its
tag was a moment ago on screen (a picked emoji flying from its picker to its chip, a card dropped into a column):
`{"hero": {"tag": "react", "flies": "inPlace", "flight": {"duration": 720, "lift": 110}}}`, on a spring without a
`flight`.

### Count up a number

A figure that counts up when the page opens is a number variable the `animate` action plays
(`AnimationController.animateTo`), shown through a formula that formats it: `thousands` (or `formatNumber`) puts
in the thousands separators (`12,480`), which `round` alone does not.

```json
"variables": {"home": [{"name": "trees", "type": "decimal", "value": 0}, {"name": "people", "type": "decimal", "value": 0}]},
"actions": [{"trigger": {"type": "load"}, "actions": [
  {"type": "animate", "variable": "trees", "command": "animateTo", "target": "12480", "duration": "1300", "curve": "easeOutCubic", "nonBlocking": true},
  {"type": "animate", "variable": "people", "command": "animateTo", "target": "3680", "duration": "1000", "curve": "easeOutCubic", "nonBlocking": true}]}]
```

with `"text": "${= thousands(trees)} trees planted"`. A chain waits for each `animate` to end before the next, so
several in one `load` count **one after another**; `"nonBlocking": true` on each runs them **together** (or give
each its own `load` reaction). The render command captures once every counting variable has arrived.

### Clocks and game loops

A canvas's `timer` trigger (`"intervalMs": 1000`, `"when"`: a formula that must hold) runs every interval
(`${result.tick}` counts); `frame` runs every frame while `when` holds (`${result.dt}` ms since the last), for
physics and game loops. Keep the state in variables and the work in a script when it has several steps.

A clock written by a timer (`"value": "${= now()}"`) changes in every capture. To check a countdown's states, pin
the time with the render command's `--now 2026-11-13T09:00:00Z` (`now()` returns it, so the timer writes it); a
`--set clock=...` also holds against the timer for the capture. No test-only variable is needed.

## Pitfalls

- `motion` (its scale and rotate too) does not change layout: neighbours do not move. To make room, animate a
  layout field.
- A transition animates changes only; a value that never changes needs an animation that autoplays.
- An animation's `id` is what `animate` names; without `autoplay` it waits.
- Animations run in a running app. The render command settles about a second after each step, so a short
  animation is over when it captures (a counting variable is waited for until it arrives, up to 20 s); to check
  one mid-flight, lengthen its duration in a copy.

## See also

[Interaction](@page-interaction) (state changes to animate) · [layout](@layout-overlap-and-bleed) (motion for
overlap) · [navigation](@page-navigation) (route transitions) · [decoration](@page-decoration) (custom drawing).
