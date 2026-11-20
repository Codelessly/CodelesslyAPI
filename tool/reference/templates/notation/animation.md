# Motion

Entrances and loops (`animate=`), animations with tracks, transitions of a changing value, and the motion keys.
Open it when a line moves, fades, springs or follows a value over time.

## The animate words

`animate=<word>` on any line plays a preset; `duration`, `delay` (milliseconds) and `curve` (its easing, a
[curve](values.md#enum-AnimationCurve) by name) beside it, and under an `each`, `stagger` (each copy that much later).

```notation
Column w=40 h=40 fill=#FFE5E7EB animate=fade duration=400
```

```notation expands
Text "Sent" animate=fadeIn duration=200 curve=easeIn
```

{{animateWords}}

### This starts when that ends

`after=<id>` beside it (or on an `animation` line) holds it at its start until node `<id>` has settled: its own
entrances and the animations inside it have ended, and a lifted node in it (`hero.flies=lift`) has landed. Then its
`delay` counts. A menu that grows in under a lifted bubble once the bubble has landed, its line a little after,
with no delay repeating the flight's time:

```notation expands
Column gap=12 center
  Column#bubble w=240 h=48 radius=12 fill=#FF545CEA hero.tag="m1" hero.flies=lift
  Column w=250 radius=13 fill=#FFF1F1F1 animate=scale duration=220 after=bubble
    Row w=fill h=43 pad=[16,0,18,0] animate=fade duration=180 delay=80 after=bubble
      Text "Copy" grow
```

## Animation lines

Any other animation is an `animation#id` line under its node, with its fields by name; its tracks are `track`
lines under it (a track animates one path of the node, a variable, or another node's).

```notation
Column w=40 h=40 fill=#FFE5E7EB
  animation#enter duration=520 curve=easeOutCubic
    track path=opacity from=0 to=1
    track path=motion.translateY from=14 to=0
```

The `animate` action plays, reverses or sets one: `onTap={animate node=card command=forward}`. A `playKey={…}` that
reads values plays it from the start whenever what it gives changes to one that isn't empty, `0`, `false` or
`null`, and a track's `from={…}` is worked out as it plays. A wizard's step slides in from the end going forward and
from the start going back: the buttons say the direction, the key is the step (written `"s{step}"`, so that the
first step's `0` plays it too):

```notation expands
state step=0
state dir=1
Column gap=16
  Column w=fill h=200 clip=antiAlias
    Column w=fill h=fill pad=24
      animation#slide duration=320 curve=easeOutCubic playKey="s{step}"
        track path=motion.translateX from={dir * 342} to=0
        track path=opacity from=0 to=1
      Text "Step {step + 1}"
  Row gap=12
    Button.ghost "Back" enabled={step > 0} onTap={dir=-1; step=step - 1}
    Button "Next" enabled={step < 2} onTap={dir=1; step=step + 1}
```

Steps that are screens of their own slide the same way with `go step2 transition=slideLeft` forward and `navigate
mode=pop` back: a pop plays the push's transition in reverse.

An animation that loops says `repeat=true` (`repeat.reverse=true` back and forth, `repeat.count=3`; there is no
`loop`). A track that passes through values on its way takes them as its `keyframes`, a list on its own line
(`at` 0 to 1 of the run), not lines under it. A turn is `motion.rotate` in degrees (not `rotation`; from
radians, `{degrees(a)}`).

```notation
Column w=40 h=40 fill=#FFE5E7EB
  animation#shine duration=1500 repeat=true curve=linear
    track path=opacity from=0 to=0 keyframes=[{"at":0.2,"value":1},{"at":0.8,"value":1}]
```

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

### A box that eases to its content's size

`transition property=layout` eases a box's own size: when what it holds changes its size (a line that shows, an
accordion opening, a composer growing a line), the box grows or shrinks to the new size over the transition, and
what is under it moves with it. Its fill, border and corners follow the box; what doesn't fit yet is clipped.
`layout.height` or `layout.width` eases that side only (over a bound fixed width, `layout.width` eases that number,
as before); `*` eases no size.

```notation expands
state open=false
Column w=fill radius=12 fill=#FFFFFFFF border=#FFE2E8F0 clip=antiAlias
  transition property=layout duration=300 curve=easeOutCubic
  Row w=fill pad=16 between onTap={open=!open}
    Text "What is ERP?" weight=600
    Icon "{open ? 'expand_less' : 'expand_more'}" size=22
  if open
    Text "Facing the fear, and letting the urge pass." pad=[16,0,16,16]
```

### A field's looks over time

On an `Input` (a text field), `transition property=decoration duration=167 curve=easeOut` eases its frame's border
and fill between their enabled, hovered, focused, error and disabled looks (`decoration.focusedBorder…`). Without it
they change at once.

```notation expands
state email=""
Column gap=8
  Input "Email" @email decoration.focusedBorder.borderSide.color=#FF00A3AD
    transition property=decoration duration=167 curve=easeOut
```

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
