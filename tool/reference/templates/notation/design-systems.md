# Design systems

A design system's components and words, and words defined in the text (`define`). Open it when a session gives
you a design system, or an answer needs a word the notation does not have.

## A design system

A design system is a folder (its manifest, its components, DESIGN.md and PATTERNS.md); a site names it, and its
pages call its components by name, like any word ([components.md](components.md)). Its theme gives the named
colors and text styles (`color=primary`). Its manifest is JSON; see the JSON reference's
[design-systems.md](../design-systems.md).

## Defined words

`define` at the margin, and the word as a line would use it, each value its default; under it, indented, the lines
it stands for. Those lines read the word's strings and keys by name in braces; `...` on a line of its own is where
the lines written under a use go. A defined word is written out where it is used.

```notation expands
define Pill "text" tone="neutral"
  Row gap=4 pad=[8,2,8,2] radius=12 fill=#FFF3F4F6
    Text "{text}"
Column gap=8
  Pill "New"
  Pill "Old"
```

{{reference}}

{{examples}}
