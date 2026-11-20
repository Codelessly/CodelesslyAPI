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

{{reference}}

{{examples}}
