# Design systems

A design system's components and words, and words defined in the text (`define`). Open it when a session gives
you a design system, or an answer needs a word the notation does not have.

## A design system

A design system is a folder (its manifest, its components, DESIGN.md and PATTERNS.md); a site names it, and its
pages call its components by name, like any word ([components.md](components.md)). Its theme gives the named
colors and text styles (`color=primary`). Its manifest is JSON; see the JSON reference's
[design-systems.md](../design-systems.md).

## Defined words

Before a `define` (or a `primitive`), look the word up in [index.md](index.md): the notation may have it already
(`copy` and `focus` are actions, `Splitter` a control), and a word it has is not defined again. A verb such as
`copy` is in the verbs table on [events.md](events.md#events-actions); the index lists its action,
`copyToClipboard`.

`define` at the margin, and the word as a line would use it, each value its default; under it, indented, the lines
it stands for. Those lines read the word's strings and keys by name in braces; `...` on a line of its own is where
the lines written under a use go. A defined word is written out where it is used. A word that keeps a value is
written with `@value=…` in its head (`define Stepper @value=0 min=0`), its lines binding `@value`; a use binds its
own variable (`Stepper @qty`). A key read where an action goes is the use's actions, whatever its name
(`define Act "label" save` over `Button "{label}" onTap={save}`, used as `Act "Go" save={n=n+1}`); an id of its lines
named like a variable they bind (`Toggle#shown @shown`) is the use's own, the variable the page's.

```notation expands
define Pill "text" tone="neutral"
  Row gap=4 pad=[8,2,8,2] radius=12 fill=#FFF3F4F6
    Text "{text}"
Column gap=8
  Pill "New"
  Pill "Old"
```

A use takes the keys its head names. `...` at the end of one of its lines gives that line every other key a use
writes, a place in a Stack among them; without it, `x=` on a use is refused. Each id in its lines is the use's own:
`#ini` is `ini_portrait1` in the first use and `ini_portrait2` in the next, as a render step names it.

```notation expands
define Portrait "initials"
  Column w=32 h=32 radius=16 fill=#FFE5E7EB center middle ...
    Text#ini "{initials}"
Stack w=120 h=40
  Portrait "AS" x=0 y=4
  Portrait "BK" x=24 y=4
```

A defined word's lines may read the looks the theme gives the notation's own words as `{theme.<name>}`, worked out
as the word is used, under whatever theme the page is read with (a design system's, the site's, or the notation's
own looks): `accent`, `accentText`, `line`, `selectedFill`, `surface`, `overlaySurface`, `track`, `band`, `siteFill`,
`paneFill`, `sideFill`, `iconTile`, `hoverFill`, `quietInk`, `mutedInk`, `faintInk` (colors; some are nothing under a
theme that has none, and a key given nothing is left out), `contentWidth`, `narrowWidth`, `sidebarWidth`,
`sidebarRail`, `sectionPad`, `gutter`, `siteHeadline` (sizes), and `theme.style.<name>`, a text style's name when the
theme has it. They work in an expression too (`{coalesce(theme.mutedInk, "#FF6B7280")}`,
`Text.{coalesce(theme.style.caption, "muted")}`); any other `theme.` name is the theme read as the page runs. A
color the site's theme names itself (`"colors": {"mine": …}`) is read so too: `fill={mine ? theme.mine :
theme.theirs}` is the theme's color as the page runs, its dark value in dark mode. A name none of these give is
said, with the names the theme has.

```notation expands
define Tag "label"
  Row gap=4 pad=[8,2,8,2] radius=12 fill={theme.selectedFill} border={theme.line}
    Text "{label}" color={theme.accent}
Column gap=8
  Tag "New"
```

A word whose lines are an overlay (`Sheet`, `Dialog`, `Drawer`…) is that overlay: write its use after the page at
the margin with an id, and `open <id>` shows it. Its own `state` lines, written before the overlay, are the
overlay's (a search sheet's query, kept apart for each use).

```notation expands
state country="Chile"
define PickSheet "title" @value="" items=[]
  state query=""
  Sheet "{title}" ...
    Input "" "Search" @query
    each option in fuzzy(items, query, o => o)
      Row h=44 onTap={value=option; close}
        Text "{option}"
Column gap=8
  Button "Country" onTap={open countries}
  Text "{country}"
PickSheet#countries "Country" @country items=["Chile","China","Denmark"]
```

{{reference}}

{{examples}}
