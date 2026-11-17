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
phone only. A page written for a desktop lays itself out narrower on its own when it is read with reflow (rows
stack, grids take fewer columns): write a rule only where you want something else.

## Breakpoints

{{breakpoints}}

## States

`states={…}` ([StateStyles](@type-StateStyles)) holds a line's look while it is hovered, pressed, focused,
selected or disabled. The words the parser reads for them:

{{states}}

{{reference}}

{{examples}}
