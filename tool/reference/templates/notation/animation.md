# Motion

Entrances and loops (`animate=`), animations with tracks, transitions of a changing value, and the motion keys.
Open it when a line moves, fades, springs or follows a value over time.

## The animate words

`animate=<word>` on any line plays a preset; `duration`, `delay` (milliseconds) beside it, and under an `each`,
`stagger` (each copy that much later).

```notation
Column w=40 h=40 fill=#FFE5E7EB animate=fade duration=400
```

{{animateWords}}

## Animation lines

Any other animation is an `animation#id` line under its node, with its fields by name; its tracks are `track`
lines under it (a track animates one path of the node, a variable, or another node's).

```notation
Column w=40 h=40 fill=#FFE5E7EB
  animation#enter duration=520 curve=easeOutCubic
    track path=opacity from=0 to=1
    track path=motion.translateY from=14 to=0
```

The `animate` action plays, reverses or sets one: `onTap={animate node=card command=forward}`.

### An animation's fields

{{animationFields}}

### A track's fields

{{trackFields}}

## Transitions

A `transition` line under a node animates a change of one of its values (a binding, a media rule):

```notation
Column w=40 h=40 fill=#FFE5E7EB
  transition property=opacity duration=200 curve=easeOut
```

{{transitionFields}}

## Bursts: confetti, stars, sparkles

`particles.*` keys on a line make it an emitter (the [particles](@behavior-particles) keys below): on cue, `count`
particles leave from the origin (`originX`, `originY`: an alignment in the box, -1 to 1; `originWidth`: a share of the
width they leave along), heading `direction` degrees (0 up, 90 right) within `spread` degrees either side, at `speed`
px/s give or take, slowed by `drag`, pulled down by `gravity` px/s², spinning, and fading out over the last
`fadeOut` ms of `lifetime`. `emit` spreads their leaving over that many ms (a stream rather than one pop); `shapes`
picks paper squares, strips, circles, five-point `star`s, triangles, squiggles, an `image` or an `emoji`. Each burst
is scattered afresh. The cue is `particles.playOnAppear=true` (when the line first shows) or an `animate` action
naming the line and `animation=particles`; the particles draw over the line's content and are not cut by its corners.

```notation
Column gap=12
  Stack#card h=220 fill=#FFFFFFFF radius=16 particles.count=70 particles.emit=300 particles.shapes=["star","circle","strip"] particles.originY=0.2 particles.spread=70 particles.speed=650 particles.drag=0.6 particles.lifetime=1800
    Text.heading2 "7-day streak!" size=22 x={"align":0} y={"align":0.2}
  Button "Celebrate" onTap={animate node=card animation=particles}
```

{{reference}}

{{examples}}
