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

### Runs: links and marks in a text

A part of a text in its own style, or a link, is a run over its characters: `runs=[…]`, each
[TextRun](@type-TextRun) a range `start` to `end` (the end not included) with its `style` and its `link`, over the
text's own style. A run holds no text of its own; it styles the text that is there (a run written with `"text"` and
no `start` is that text where the line first has it; a text the line does not have is said). A run written whole is
a record:

```notation
Text "Feeling stuck? Find help here." runs=[{"start":15,"end":29,"style":{"color":"#FF545CEA","fontWeight":600},"link":"https://example.com/help"}]
```

A run with a `link` takes a tap of its own: the tap opens the link (`https://…`, `mailto:…`, `tel:…`), or, when the text has
`onLinkTap`, runs it instead with `result.link`, `result.text`, `result.start` and `result.end`, so a link may name
anything of the app (`link="restart"`). The rest of the text keeps the text's own `onTap`. Runs are usually worked
out: `regexMatches(text, pattern)` gives each match of a pattern and where it is, `matchRanges(text, query)` the
parts that match a search; `map` makes each a run, and `concat` puts kinds of run together. A run written later
wins where two style the same characters (a search mark inside a link keeps both looks).

```notation
state msg="Write care@nocd.com or call +1 555 010 2233 for help."
state legal="By continuing you agree to the Terms and the Privacy Policy."
state q="help"
state opened=""
Column gap=8
  Text "{msg}" runs={concat(map(regexMatches(msg, "[\w.+-]+@[\w-]+(\.[\w-]+)+|\+?\d[\d ]{6,}\d"), m => {start: m.start, end: m.end, link: contains(m.text, "@") ? "mailto:" + m.text : "tel:" + replace(m.text, " ", ""), style: {color: "#FF2563EB", decoration: "underline"}}), map(matchRanges(msg, q), r => {start: r[0], end: r[1], style: {backgroundColor: "#FFFDE68A"}}))}
  Text "{legal}" runs={map(regexMatches(legal, "Terms|Privacy Policy"), m => {start: m.start, end: m.end, link: m.text, style: {fontWeight: 700}})} onLinkTap={opened=result.link}
  Text "Opened: {opened}"
```

A count in braces inside a formula's text (`\d{3}`, `{2,4}`, `{,5}`) is the pattern's, not a value read.

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

A site that is dark by design says so in its theme, `"mode": "dark"` in `site.json` with its dark colors under
`dark` ([site.md](site.md)): it opens dark everywhere, with no action. The theme also names what the page words
draw in: a style `<look>Page` beside `<look>` (`heading1Page`, `leadPage`, `bodyPage`) is a text's on a website's
page, `colors.card` a card's ground, `colors.selectedRow` a chosen row's fill; and a band of a page with a
ground of its own (`Section fill=`, `gradient=`, `image=`) gives its texts the ink that reads on it
([navigation.md](navigation.md)).

{{reference}}

{{examples}}
