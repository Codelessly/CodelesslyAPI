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

### A type scale that changes with the screen size

The theme's `media` rules patch the theme as a node's rules patch a node: `{"minWidth": 1024, "patch":
{"textStyles": {"title": {"fontSize": 56}}}}` makes every text using `title` grow at desktop width, written once. A
node's own media rule may switch its style (`"patch": {"props": {"style": "caption"}}`, which replaces the style)
or change some fields (`{"style": {"fontSize": 20}}`, merged over the named style).

### Dark mode

`"dark": {"colors": {"ink": "#FFEEEEEE"}}` gives the colours that differ in dark mode; a node naming `ink` follows
the device's mode. `${theme.isDark}` is true in dark mode.

### Text

A `text` node has `props.text` and `props.style`. What a text looks like when the style leaves something out: no
`color`, white; no `fontSize`, 12; no `fontWeight`, 400; no `fontFamily`, the platform's default (Roboto on Android
and the web); no `height`, the nearest `defaultTextStyle`'s (a node key, Flutter's `DefaultTextStyle`, for its
whole subtree), else the font's own line height. Sizing: one line `{"hug": n}` × `{"hug": n}`; a paragraph `{"fill": n}` wide × `{"hug": n}` high. A
fixed height shorter than the lines clips them (`text_clipped`).

`runs` style parts of the text: `[{"start": 0, "end": 5, "style": {"fontWeight": 700}}]` (character offsets, end
exclusive, `\n` counting as one), merged over `style`; a run may carry a `"link"` URL. A literal `$` right before an
expression is text: `"$${price}"` shows `$47`. There is no escape for a literal `${`: compute it.

### Superscripts and a raised currency sign

A raised or lowered character (a price's "$", a footnote mark): a run with `"fontFeatures": ["sups"]` (or `"subs"`)
when the font has those OpenType features; otherwise a smaller `fontSize` in a row of texts aligned
`crossAxisAlignment: start` (or `baseline`) for the exact shift.

### Fonts

`style.fontFamily` names a family (`"Inter"`), with `fontWeight` choosing the file. An app fetches Google Fonts by
name. The render command uses font files from `--fonts <dir>` plus Roboto, and reports a family it does not have
(`font_fallback`). Characters the font has no glyph for draw as empty boxes (`missing_glyph`): use an `icon`.

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
