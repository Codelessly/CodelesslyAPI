# Animation and motion

## When to use

Anything that moves: a change that animates (implicit transitions), keyframe animations and presets, moving,
scaling and turning a node without changing layout (`motion`), shared-element flights between screens, reveal on
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
`scale`, `rotate` in degrees, 3D `rotateX`/`rotateY` with `perspective`, about `alignment`. Nothing else moves. Bind
a field (`"motion.rotate": "${= open ? 180 : 0}"`) and add a transition to animate it.

### Play an animation (animations and presets)

`animations` holds a node's controllers: each runs 0 → 1 over `duration` (or a `spring`), after `delay`, once or
`repeat`ed, and drives `tracks` of keyframes on its paths. A `preset` names a ready-made one (fade in, slide up,
pulse...) with its `params`. `autoplay` false waits for the `animate` action (`forward`, `reverse`, `stop`...) or a
change of `playKey`. A screen-wide animation sits on the canvas.

### Reveal on scroll, view progress, sticky effects

`reveal` plays when the node scrolls into view; `viewProgress` gives `${view.progress}` (0–1 through the viewport)
to bind to; the `enterViewport` and `exitViewport` triggers run actions.

### Shared elements between screens

`hero` (a tag) flies the node from one screen to the matching one on the next; `flightKey` flies a node in from
where the node with the same key just was (a card that becomes a detail header), with `flight` saying how.

### Clocks and game loops

A canvas's `timer` trigger (`"intervalMs": 1000`, `"when"`: a formula that must hold) runs every interval
(`${result.tick}` counts); `frame` runs every frame while `when` holds (`${result.dt}` ms since the last), for
physics and game loops. Keep the state in variables and the work in a script when it has several steps.

## Pitfalls

- `motion` and `scale` do not change layout: neighbours do not move. To make room, animate a layout field.
- A transition animates changes only; a value that never changes needs an animation that autoplays.
- An animation's `id` is what `animate` names; without `autoplay` it waits.
- Animations run in a running app; the render command captures the frame at the moment of capture (`--wait <ms>`
  to let one finish).

## See also

[Interaction](@page-interaction) (state changes to animate) · [layout](@layout-overlap-and-bleed) (motion for
overlap) · [navigation](@page-navigation) (route transitions) · [decoration](@page-decoration) (custom drawing).
