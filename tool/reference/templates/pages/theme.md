# Theme and text

## When to use

A site's palette and type scale, declared once and named everywhere; dark mode and a type scale that changes with
the screen size; and the `text` node in depth (runs, links, superscripts, fonts, text direction).

## Minimal example

A site manifest (`site.json`) with a theme: a palette and a type scale. The page next to it names them.

{{example:theme/site}}

A page using it (a fragment of `home.json`'s `nodes`):

```json
"eyebrow": {"type": "text", "props": {"text": "OUR MENU", "style": "eyebrow"}, "layout": {"width": {"fill": 342}, "height": {"hug": 18}}},
"title":   {"type": "text", "props": {"text": "Fire, smoke and season", "style": "title"}, "layout": {"width": {"fill": 342}, "height": {"hug": 40}}},
"note":    {"type": "text", "props": {"text": "Cooked over oak.", "style": {"from": "body", "color": "ember"}}, "layout": {"width": {"fill": 342}, "height": {"hug": 24}}},
"rule":    {"type": "box", "layout": {"width": 120, "height": 4}, "decoration": {"fills": [{"color": "ember"}]}}
```

## Reference

### Theme keys

The theme (`site.json`'s `theme`, or the app's theme at run time):

{{themeKeys}}

{{reference}}

## Patterns

### Named colours and styles

- **Colours**: `colors` maps a name to `"#AARRGGBB"` (or to another colour's name: `"accent": "ember"`). Wherever a
  colour is accepted, write its name. The roles `primary`, `onPrimary`, `surface`, `onSurface`, `error`, `success`,
  `warning` (keys of the theme) are names too.
- **Text styles**: `textStyles` maps a name to a TextStyle. A style may start `from` another and name colours. A
  text names its style in one field, `"style": "title"`; to change some fields of it, `"style": {"from": "title",
  "color": "ember"}` (`textTheme.titleLarge.merge(...)`: the fields written win). Runs, a button's `textStyle` and
  an input's styles take the same two forms.
- Changing a colour or style in the theme changes every node that names it, and only those.
- In a binding a name is not read: bind the value, `"${theme.colors.ember}"` or `"${theme.text.title}"`; inside
  a formula, `${= done ? theme.colors.sage : theme.colors.mist}`.

### What controls take from the theme

A control's colours, fonts and shapes that its props leave unset come from the theme: `primary` fills filled buttons
(labelled in `onPrimary`) and draws checks, thumbs, focus rings and text-button labels where it reads on `surface`
(else `onSurface` does); `fontFamily` is every control label's font (`titleFontFamily` titles'); `buttonRadius`
shapes every kind of button and chip, `radius` dialogs, menus and pickers. Without a theme, controls are neutral:
ink on paper (near-black on white; near-white on near-black in dark mode) and the greys between, in no font of
their own. Nothing comes from Material's defaults (no purple, ripples or elevation) or from the host app's theme.

### Spacing and radius scales

The theme has no spacing or radius tokens for nodes: its `radius` and `buttonRadius` shape controls only. Write
padding, gaps and corner radii as numbers, or keep a scale as a project variable (`{"name": "space", "type": "map",
"value": {"sm": 8, "md": 16, "lg": 32}}` in `site.json`) and bind it where it varies: `"bind": {"layout.padding":
"${space.md}", "props.spacing": "${space.sm}"}`.

### A type scale that changes with the screen size

The theme's `media` rules patch the theme as a node's rules patch a node: `{"minWidth": 1024, "patch":
{"textStyles": {"title": {"fontSize": 56}}}}` makes every text using `title` grow at desktop width, written once. A
node's own media rule may switch its style (`"patch": {"props": {"style": "caption"}}`, which replaces the style)
or change some fields (`{"style": {"fontSize": 20}}`, merged over the named style).

### Dark mode

`"dark": {"colors": {"ink": "#FFEEEEEE"}}` gives the colours (and roles: `surface`, `primary`...) that differ in
dark mode; everything naming `ink` follows the mode: fills, strokes, named text styles (a style whose `color` is
`"ink"`), and the controls, which take the theme's roles. A style with a literal colour (`"#FF111111"`) does not
change: name the colour.

Which mode shows is the theme's `mode` (Flutter's `ThemeMode`, as `MaterialApp.themeMode`): `system` (the default:
the device's setting), `light` or `dark`. A site's own switch is one action:

```json
{"type": "setThemeMode", "mode": "${= theme.isDark ? 'light' : 'dark'}"}
```

`mode` is an expression giving `system`, `light` or `dark`. Every screen of the site redraws at once, the next page
opens in the same mode, and with `persist` (the default) the choice is kept in the site's local storage, so a
reload starts in it; `"persist": false` keeps it for this visit only. `${theme.mode}` reads the mode chosen and
`${theme.isDark}` (also `${screen.isDark}`) whether the screen is dark; bind a switch's value to
`${theme.isDark}` to show it. A theme without `dark` stays as designed in dark mode (its colours and controls light),
while `${theme.isDark}` still says dark (`${theme.hasDark}` is false), so a page may choose its own colours.

The render command captures either: `--theme light` or `--theme dark` (the PNG names end `-light`, `-dark`), and a
`--tap` on the switch afterwards captures the other.

### Text

A `text` node has `props.text` and `props.style`. What a text looks like when the style leaves something out: no
`color`, white; no `fontSize`, 12; no `fontWeight`, 400; no `fontFamily`, the platform's default (Roboto on Android
and the web); no `height`, the nearest `defaultTextStyle`'s (a node key, Flutter's `DefaultTextStyle`, for its
whole subtree), else the font's own line height. Sizing: one line `{"hug": n}` × `{"hug": n}`; a paragraph `{"fill": n}` wide × `{"hug": n}` high. A
fixed height shorter than the lines clips them (`text_clipped`).

`runs` style parts of the text: `[{"start": 0, "end": 5, "style": {"fontWeight": 700}}]` (character offsets, end
exclusive, `\n` counting as one), merged over `style`; a run may carry a `"link"` URL. Offsets count the text as
written, an expression keeping its run; a run that starts or ends inside a `${...}` counts the text as shown instead,
so a drop cap on a bound paragraph (`"text": "${= story.lead}"`) is `{"start": 0, "end": 1}`. A literal `$` right before an
expression is text: `"$${price}"` shows `$47`. There is no escape for a literal `${`: compute it.

### Superscripts and a raised currency sign

A raised or lowered character (a price's "$", a footnote mark): a run with `"fontFeatures": ["sups"]` (or `"subs"`)
when the font has those OpenType features; otherwise a smaller `fontSize` in a row of texts aligned
`crossAxisAlignment: start` (or `baseline`) for the exact shift.

### Fonts

`style.fontFamily` names a family (`"Inter"`), with `fontWeight` and `fontStyle` choosing the file. A site declares
the families it ships in `site.json`, in the shape of a Flutter pubspec's `fonts:` section, the files beside it:

```json
{
  "schema": 3,
  "pages": ["home.json"],
  "fonts": [
    {"family": "Fraunces", "fonts": [
      {"asset": "fonts/fraunces-latin-400-normal.woff"},
      {"asset": "fonts/fraunces-latin-700-normal.woff", "weight": 700},
      {"asset": "fonts/fraunces-latin-400-italic.woff", "style": "italic"}
    ]}
  ],
  "theme": {"fontFamily": "Fraunces", "textStyles": {"body": {"fontFamily": "Fraunces", "fontSize": 17}}}
}
```

- `family` is the name text styles use, whatever the file calls itself; each file has a `weight` (100–900, default
  400) and a `style` (`normal` or `italic`).
- Files are `.ttf`, `.otf` or `.woff` (an npm `@fontsource/<family>` package's `files/` folder has a `.woff` beside
  each `.woff2`). WOFF2 is not read (`font_format`); a declared file that is not there is `font_missing`.
- The render command loads them with no flag, before the page shows; a published site loads them from its files.
- A family a text style names that no file provides is `font_fallback`, naming the nodes that use it: declare it,
  or pass `--fonts <dir>` (`--fonts system` for the system's fonts). A family nobody declared is fetched by name
  from Google Fonts in an app.

Characters the font has no glyph for draw as empty boxes (`missing_glyph`): use an `icon`.

## Pitfalls

- A text without a colour is white (`text_no_color` when rendered): set it in the style or the named style.
- A name the theme does not have is `unknown_theme_name` (with the nearest name); a theme of the wrong shape is
  `invalid_theme`. Without a `site.json`, put the page in a folder with one: `{"schema": 3, "pages": ["home.json"],
  "theme": {...}}`.
- A theme colour's name is not read from a formula: bind `${theme.colors.ember}`.
- Run offsets count characters, `\n` as one.

## See also

[Decoration](@page-decoration) (paints that name theme colours) · [forms](@page-forms) (input and button text
styles) · [responsive layout](@layout-media-rules) (media rules).
