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
the lines written under a use go. A defined word is written out where it is used. A word that keeps a value is
written with `@value=…` in its head (`define Stepper @value=0 min=0`), its lines binding `@value`; a use binds its
own variable (`Stepper @qty`).

```notation expands
define Pill "text" tone="neutral"
  Row gap=4 pad=[8,2,8,2] radius=12 fill=#FFF3F4F6
    Text "{text}"
Column gap=8
  Pill "New"
  Pill "Old"
```

A defined word's lines may read the looks the theme gives the notation's own words as `{theme.<name>}`, worked out
as the word is used, under whatever theme the page is read with (a design system's, the site's, or the notation's
own looks): `accent`, `accentText`, `line`, `selectedFill`, `surface`, `overlaySurface`, `track`, `band`, `siteFill`,
`paneFill`, `sideFill`, `iconTile`, `hoverFill`, `quietInk`, `mutedInk`, `faintInk` (colors; some are nothing under a
theme that has none, and a key given nothing is left out), `contentWidth`, `narrowWidth`, `sidebarWidth`,
`sidebarRail`, `sectionPad`, `gutter`, `siteHeadline` (sizes), and `theme.style.<name>`, a text style's name when the
theme has it. They work in an expression too (`{coalesce(theme.mutedInk, "#FF6B7280")}`,
`Text.{coalesce(theme.style.caption, "muted")}`); any other `theme.` name is the theme read as the page runs.

```notation expands
define Tag "label"
  Row gap=4 pad=[8,2,8,2] radius=12 fill={theme.selectedFill} border={theme.line}
    Text "{label}" color={theme.accent}
Column gap=8
  Tag "New"
```

{{reference}}

{{examples}}
