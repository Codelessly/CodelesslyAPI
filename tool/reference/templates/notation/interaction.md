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

A line's look while hovered, pressed, focused, selected or disabled is the state's name before a key:
`hovered.fill=#FFE5E7EB`, `pressed.opacity=0.8`, `focused.border=#FF2563EB`; a line inside it follows its state by
its id (`card.hovered.color=…`). The whole of it, with an example, is on
[responsive.md](responsive.md#responsive-states); the record is `states` ([StateStyles](@type-StateStyles)).

## Focus and the keyboard

A line with an `onTap` takes the focus and Enter presses it; `focusable=false` leaves it out. `focusGroup` on a
line around a group of items (a menu, a toolbar) makes them one Tab stop moved through with the arrows;
`focus email` in an action puts the caret in `Input#email`, `blur` takes it away. Keys of the screen are `key`
lines ([events.md](events.md)), a key on a line is `onKeyDown(key=…)`.

```notation
Column gap=8
  Column#menu focusGroup.typeAhead=true
    Text "Open" onTap={emit open}
    Text "Rename" onTap={emit rename}
  Input#email "Email" onKeyDown(key=Escape)={blur}
key mod+f onPress={focus email}
```

{{reference}}

{{examples}}
