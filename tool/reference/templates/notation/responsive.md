# Responsive

A line's keys at other widths (media rules), the named sizes, breakpoints, and the looks of a line's states. Open
it when a page must work on a phone, a tablet and a desktop, or a line looks different while hovered or pressed.

## Keys at other widths

A key with a condition before it holds only where the condition does: `phone.pad=16`, `tablet.direction=vertical`,
`max899.hidden`, `minDesktop.visible=true`. The key after the condition is any key the line reads, its value as
the line writes it. Keys with the same condition are one rule; rules hold in the order written.

{{mediaSizes}}

The other conditions:

- `min700`, `max899`: a width in pixels (from, up to).
- `minTablet`, `maxMobile`: from a breakpoint's width, or up to the next one's.
- `portrait`, `landscape`: the orientation.
- Conditions combine: `min700.tablet.size=14` holds from 700 to the tablet's upper bound.

```notation
Column gap=24 pad=48 phone.pad=16
  Text "Wide" phone.size=14 hide=tablet
  Text "Narrow only" max899.hidden
  Text "From a tablet up" minTablet.size=20
  Text "Upright" portrait.size=12
```

`hide=phone` leaves a line out on a phone, `hide=tablet` on a tablet and a phone; `show=phone` shows it on a
phone only. `tablet.hidden=true` (or `tablet.hidden`) is `hide=tablet`. A Row that is a column at some width is
written `Row … phone.direction=vertical` (it is read as a `Flex`, which takes `scroll` and the alignment words too).

## What reflow does

A page written for a desktop (expanded at 700 wide or more) is given rules of its own for a tablet (up to 1023)
and a phone (up to 699): reflow is on unless the expander is run with `--no-reflow`. It works like a website's
defaults:

- A band of blocks (cards beside cards, content beside a rail) wraps; a grid takes fewer columns; a headline gets
  smaller; a box wider than a phone fits it; a table's columns share the row, and a phone keeps the ones it has
  room for; a `Nav` hides its links on a phone.
- An app's window stays a window. A Row that fills the height (`h=fill`, or `grow` in a column) with one pane that
  grows beside panes of a fixed width (a sidebar, a list, an inspector) is laid out as `App` is: a tablet drops
  the fixed panes after the one that grows, a phone shows that one alone. It is never wrapped or stacked.
- A Row keeps its line when it has a height of its own (a toolbar, `h=56`), is a row of a list (under an `each`,
  in a `ListView`), sits in something of a fixed width a phone holds (a 232 sidebar, a 96 track head) or in a Row
  that scrolls sideways, or holds only labels and buttons inside an app's window.
- What you lay out by width is yours: a line with its own rules (`tablet.w=64`, `hide=phone`, `phone.pad=8`) gets
  none of reflow's over them, and a Row whose own line or a line right under it has such rules is not wrapped.
- `keep` on a line (`Row#window keep`) leaves it and everything in it as written at every width.

Write the rules you want where reflow's default is not the one: they win, and they turn reflow off for that line.

A desktop page that changes at a tablet's width and again at a phone's: the side-by-side `Flex` turns into a
column and closes up, the side panel leaves, the title and the margins get smaller on a phone.

```notation width=1280 expands
state projects=["One","Two","Three"]
Flex direction=horizontal gap=32 pad=48 tablet.direction=vertical tablet.gap=16 phone.pad=16
  Column gap=8 grow
    Text.title "Projects" phone.size=22
    Grid cols=3 gap=16
      each item in projects
        Text "{item}"
  Column w=280 hide=tablet
    Text.heading "Filters"
```

## Breakpoints

{{breakpoints}}

## States

A line's look while it is hovered, pressed, focused, selected, disabled or dragged is written as a key at another
width is, the state's name before the key: `hovered.fill=#FFE5E7EB`, `pressed.opacity=0.8`,
`focused.border=#FF2563EB`, `disabled.opacity=0.4`. The key after the state is any key the line reads. `selected`
follows the line's `selected={…}`, `disabled` its `enabled={…}`; the others follow the pointer and the focus. A line
inside it follows its state by its id: `btn.selected.color=#FFFFFFFF` on the icon in `Row#btn` turns it white while
the row is selected. A state written replaces the look `selected=` gives a box by itself.

```notation expands
state on=false
Column gap=12
  Row#btn gap=8 pad=[16,10,16,10] fill=#FFF3F4F6 radius=8 selected={on} hovered.fill=#FFE5E7EB pressed.opacity=0.8 focused.border=#FF2563EB selected.fill=#FF2563EB onTap={on=!on}
    Icon "star" size=18 btn.selected.color=#FFFFFFFF
    Text "Favourite" btn.selected.color=#FFFFFFFF
  Input "Name" focused.fill=#FFEFF6FF
  Button "Save" enabled={on} disabled.opacity=0.4
```

`hovered` needs a mouse: on a touch screen it never holds, so hide nothing behind it. The states, each as the
parser reads it on a box (`states` is the record, [StateStyles](@type-StateStyles)):

{{states}}

{{reference}}

{{examples}}
