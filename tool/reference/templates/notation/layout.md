# Layout

Sizes, rows, columns, stacks, flex and scrolling: every layout key and the layout words. Open it when a size, a
place or a scroll is more than `w`, `h`, `gap`, `pad`, `grow` and the alignment words.

## Sizes

`w` and `h` take a number (fixed), `fill` or `hug`. A size that keeps its design size is its JSON
(`w={"fill":390}`): a printed document writes it so. `grow` shares the room left in a Row or Column; `basis=320` on
a child of a wrapping Row is the width it starts from.

```notation
Column gap=8
  Text "Fixed" w=120
  Row gap=8
    Column w=40 h=40 fill=#FFE5E7EB
    Column h=40 grow fill=#FFDBEAFE
    Column h=40 grow fill=#FFBFDBFE
```

`maxWidth=720` keeps a column from stretching; `minWidth`, `minHeight`, `maxHeight` likewise ({{constraintKeys}} are
the bounds of `constraints`).

```notation
Column maxWidth=720
  Text "Capped"
```

## Place

In a Stack a child sits where `x` and `y` put it (a number from the start, or `{"end":8}`, `{"align":0}`), or
where `align` puts it.

```notation
Stack w=200 h=120
  Text "Corner" x=8 y=8
  Text "Center" align=center
```

A Row wraps with `wrap=true` (`runSpacing` between its lines). `sticky` keeps a line in view while the page scrolls
under it.

```notation
Row gap=8 wrap=true runSpacing=8
  Text "One"
  Text "Two"
```

## Scrolling

`scroll` on a Column scrolls what is under it; on a Row, sideways. `scrollTo node=faq` and the `scroll` verb move
a scroll view to a line; `onScroll={…}` reads `result.fraction` (see [events.md](events.md)).

`measure.variable="pos"` on a line keeps its box in that variable (`pos.x`, `pos.y`, `pos.width`, `pos.height`,
`pos.centerX`, `pos.centerY`; relative to `measure.relativeTo`, else the screen): one variable per measured line,
on a box (a Column or Row around a Text). A Row that scrolls sideways takes a sideways drag itself: a child
dragged sideways inside it (a clip on a timeline) moves the row; such a child sits in a Stack moved by a value
(`x={0 - offset}`), with the row's scroll written as that value.

```notation
Column scroll h=300
  Text "Tall"
```

## Keys every line takes

Layout keys are on every line. The short words: `w`, `h`, `pad`, `grow`; the others by their own name.

{{layoutKeys}}

{{reference}}

{{examples}}
