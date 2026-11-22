# Layout

Sizes, rows, columns, stacks, flex and scrolling: every layout key and the layout words. Open it when a size, a
place or a scroll is more than `w`, `h`, `gap`, `pad`, `grow` and the alignment words.

## Sizes

`w` and `h` take a number (fixed), `fill` or `hug`. A size that keeps its design size is its JSON
(`w={"fill":390}`): a printed document writes it so. `grow` shares the room left in a Row or Column (a box that
grows in a column is as tall as the room left, so `Column scroll grow` under a bar scrolls in it); a bare
`Spacer` takes the room left and pushes what follows to the end; `basis=320` on a child of a wrapping Row is the
width it starts from.

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
where `align` puts it on both axes (`align=center` is `x={"align":0} y={"align":0}`, and the child is as wide as
it is). `{"align":a}` runs from -1 (against the start edge) through 0 (centred) to 1 (against the end edge), as
Flutter's `Alignment`: `y={"align":0.5}` is three quarters of the free room down, not halfway (a child 352
tall in a Stack 844 tall sits at 369; at `{"align":0}`, 246). A negative place puts it past that edge (`x=-5`, `y={"end":-12}`: a bubble's tail, a badge
on a corner), drawn there with `clipBehavior=none`. A Stack that hugs is as big as its largest child; a child that
fills it with no number (`w=fill`) is as big as its content there. Only a Stack places: under a Column, a Row or a
`Box` its lines sit in turn and `x` and `y` are not read (a label over a picture: a Stack holding both).

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

## A word given a condition

A word of a line (`end`, `center`, `middle`, `between`, `bold` on a type that has it…) may be given a condition in
braces: `Row w=fill end={m.mine}` is at its end while `m.mine` holds and as the line is without the word while it
does not; `Column center={count==1}`, `Text "…" center={wide}`. `word=true` is the word and `word=false` is the line
without it, so a word of your own can pass a parameter on (`define Bubble mine=false`, then `Row end={mine}`). A
word that sets nothing a value can follow (`keep`, a Stack's place for its children) says so: write the line under
`if` with the word and under `else` without it. A variant is part of the word (`Button.outline`): one chosen by a
condition is the line written twice, under `if` and under `else`.

`scale={zoom}`, `rotate=12`, `translateX={panX}` and `translateY={panY}` draw a line scaled, turned (degrees) or moved
(pixels) from where it is laid out, with nothing around it moved: they are its `motion.scale`, `motion.rotate`,
`motion.translateX` and `motion.translateY` ([animation.md](animation.md)), on a line whose type has no key of that
name. `x=` and `y=` place a line in a Stack.

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
