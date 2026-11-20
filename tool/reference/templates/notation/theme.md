# Text and theme

Text, its looks and its style keys, the theme's names for colors and styles, and text direction. Open it when a text
needs a size, weight, font, line height or a theme color, or the page has a dark mode.

## Text

`Text "…"` is body text; a look is a variant (`Text.title`, `Text.muted`; the list is in
[NOTATION.md](NOTATION.md#notation-words)). `size`, `weight` and `color` set its style; any other field of its
style is a key by its own name (`letterSpacing`, `fontFamily`, `height` for the line height, `decoration`).
`{name}` in the text shows a value.

```notation
Column gap=4
  Text.heading2 "Hello" size=32 color=#FF2563EB
  Text "Two lines at most" maxLines=2 overflow=ellipsis
  Text.title "In the theme's primary" color=primary
```

A theme color or text style is written by its name (`color=primary`, `color=onSurface`, `style=title`): the
document's theme gives it. A key written after a named style changes only that key, at every width:
`style=title size=13` and `style=title phone.size=13` are the title at 13, its colour and weight kept (`from=title`
is the same; no `size=null` is needed). The theme itself is in the site's files ([design-systems.md](design-systems.md)).

A color of the site's own (its theme's `colors` in `site.json`, [site.md](site.md)) is read by its name in a
formula too, as `theme.<name>`, on a page and in a defined word: `fill={mine ? theme.mine : theme.theirs}`,
`border={theme.line}`. Written plain, `color=theme.ink` is `color=ink`. Either way it is the color the theme gives
as the page runs: its value under `dark` in dark mode. A defined word that reads a name the theme does not declare
is said, with the names it does; the color is added to the theme's `colors` (its dark value under `dark`).

```notation
state mine=true
Column gap=4 pad=12 fill={mine ? theme.mine : theme.theirs} radius=18
  Text "Booked it" color={mine ? "#FFFFFFFF" : theme.ink}
```

```notation
Button "Dark mode" onTap={setThemeMode mode=dark}
```

`setThemeMode dark` and `setThemeMode {isDark ? "light" : "dark"}` (its one value written alone) are the same.

{{reference}}

{{examples}}
