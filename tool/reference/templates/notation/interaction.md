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

What a writer from the web expects that is otherwise here:

- A key reaction is the screen's, wherever it is written: `onKeyDown(key=alt+ArrowRight)` on a card fires on every
  card of the board at once, whatever has the focus. To act on the focused one, keep which one it is (`picked`, set by
  its `onTap`, which Enter also runs) and write one `key alt+ArrowRight when picked != '' onPress={…}` for the screen.
- Several keys on one line are one `onKeyDown(key=…)` each (`onKeyDown(key=ArrowDown)={…}
  onKeyDown(key=ArrowUp)={…}`), or one `onKeyDown` that reads `result.key` (`result.key == 'Arrow Down'`: a key's name
  as the keyboard gives it, with its space; `result.shift`, `result.alt`, `result.meta`). The same key twice on one
  line is said.
- The plus key is `key +` (or `key plus`), with a modifier `key mod++`.
- While a dialog (a canvas opened with `openModal`) is open, its own `key` lines run and the page's under it do not.
- A `key` line with no Ctrl, Cmd or Alt (`key j`, `key Enter`) waits while a text field has the caret: the field
  takes the key. `key Escape`, and a key with `mod` or `alt`, run while typing.
- A letter is its own key with Shift or without: `key j` is not Shift+J; write `key shift+j` for that. A sign typed
  with Shift is written as itself: `key ?`, `key !` (not `key shift+/`).
- `focus search` reaches a field inside a component the page calls when it is the only one of that id on screen;
  `focus filters/search` names it by the call's id (`FilterBar#filters`) and its own.
- The Tab order is the order of the lines; nothing reorders it.

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
