# Interaction

Gestures, hover and press looks, focus, tooltips, drag and drop, swipes and pinches. Open it when a line reacts to
the pointer beyond a tap, or is dragged, dropped or swiped.

## Drag and drop

`drag=group(value)` lets a line be dragged carrying a value; `drop=group` takes drops of that group, and its
`onDrop={…}` reads the value as `result.data`.

```notation
state done=[]
Column gap=8
  Column w=40 h=40 drag=cards(card1)
  Column w=200 h=100 drop=cards onDrop={done=append(done,result.data)}
```

The full records (`draggable`, `dropTarget`, `pan`, `transformGesture`, `dismissible`) are keys below; each field
is a dotted key (`pan.axis=horizontal`).

## Looks by state

A line's look while hovered, pressed, focused, selected or disabled is its `states` record
([StateStyles](@type-StateStyles)). The words for them, when the parser has them, are on
[responsive.md](responsive.md#responsive-states).

{{reference}}

{{examples}}
