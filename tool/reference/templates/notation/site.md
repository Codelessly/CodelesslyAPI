# The site

A site's files: its pages, its components, the state they share (`app.txt`) and its manifest, `site.json`: a page
order, a theme (colors, text styles, spacing, radii, dark colors), fonts, a design system and dictionaries. Open it
when you lay out a site's folder, share state between pages, or write or change `site.json`.

## The files

```
my-app/
  pages/home.txt          one screen a file; its file name is its name (go home)
  pages/budgets.txt
  components/BudgetRow.txt   one word a file: define BudgetRow … (components.md)
  app.txt                 the state every page and component shares
  site.json               only for a theme of the app's own or a page order
```

A folder that holds `pages/*.txt`, `components/*.txt` or `app.txt` is a site: it needs no `site.json`. With none,
its pages are the files of `pages/` with `home` first and the others by name, it has no theme of its own (the
design system's, or the notation's plain looks) and its shared state is `app.txt`'s. `expand <folder>` writes the
expanded site to `site/` in it: a JSON document for each page and component, and a `site/site.json` a render reads
(the pages in order and `app.txt`'s state as variables; it is marked `"expand"`, and is not the site's source: the
next expand writes it again). A site that has a `site.json` of its own (`site/site.json`, or `site.json` in the
folder) keeps it: `expand` adds `app.txt`'s state to its `variables` and lists those names under `"expand"`.
Expand the folder again after `app.txt` changes.

## Shared state: app.txt

`app.txt` holds `state` lines, exactly as a page writes them ([state.md](state.md)), and comments. Every page and
component reads and sets what it declares by name, with no `state` line of their own, and a value one page sets
another shows.

```
// Ledgerly: what every page shares
state income=4800 saved
state currency="USD" saved
state txns=[
  {"id":"t1","merchant":"Green Grocer","amount":54.2,"category":"Groceries"},
  {"id":"t2","merchant":"Metro Card","amount":32,"category":"Transport"},
]
state spent={sum(txns,t=>t.amount)}
state left={income-spent}
state clamp01(v):decimal={min(1, max(0, v))}
```

- One state a line. A typed state (`state rate:decimal=0.2`), a formula (`state left={income-spent}`), a function
  (`state clamp01(v):decimal={…}`) and `saved` (kept on the device: the manifest's `persist`) are as on a page.
- A long list is written one item a line: `state txns=[` at the end of a line opens it, each item follows on a
  line of its own (a comma after the last is fine), `]` closes it. As the file is written, each whole line is
  read: the pages show the items that have arrived.
- A formula with no type may read another whichever is written first; one that reads itself is an issue.
- Only state: a node, a `define`, an `every`, `key` or `on` line is an issue that names the line and says where it
  belongs (a page, a component's file). A timer or a key runs on the page that writes it.
- A name `app.txt` and `site.json`'s `variables` both declare is an issue at its line of `app.txt`; `app.txt`'s
  is the one used. Declare each name in one place: `app.txt`.
- A page or a component that writes a `state` of a shared name does not make its own: the app's is read.
  State only one page uses stays a `state` line on that page.

Write the first page before `app.txt`: it draws at once with its structure, its lists empty, and fills in as
`app.txt` declares what it reads.

## A whole manifest

```json
{
  "schema": 3,
  "pages": ["home.json", "pricing.json", "account.json"],
  "designSystem": "../design_systems/desk",
  "variables": {
    "cart": [],
    "plan": "pro",
    "favourites": {"value": [], "persist": true},
    "draft": {"type": "text", "value": "", "persist": true}
  },
  "theme": {
    "primary": "#FF2F6B4F",
    "onPrimary": "#FFFFFFFF",
    "surface": "#FFFBF8F2",
    "onSurface": "#FF1F2A24",
    "colors": {"ink": "#FF1F2A24", "paper": "#FFFBF8F2", "rule": "#FFE3DDD2", "accent": "#FF2F6B4F"},
    "textStyles": {
      "body": {"fontSize": 15, "height": 1.5, "color": "ink"},
      "title": {"fontSize": 28, "fontWeight": 600, "color": "ink"},
      "caption": {"fontSize": 12, "color": "#FF6B7280"}
    },
    "spacing": {"sm": 8, "md": 16, "lg": 32},
    "radii": {"control": 6, "card": 10},
    "fontFamily": "Inter",
    "mode": "system",
    "dark": {
      "surface": "#FF141815",
      "onSurface": "#FFE8EDE9",
      "colors": {"ink": "#FFE8EDE9", "paper": "#FF141815", "rule": "#FF2C332E"}
    }
  },
  "fonts": [{"family": "Inter", "fonts": [{"asset": "fonts/Inter-Regular.ttf"}, {"asset": "fonts/Inter-SemiBold.ttf", "weight": 600}]}]
}
```

## Its keys

- **`pages`**: the site's pages, in order: `"home.json"` (beside `site.json`), `"home"` (the same) or a record
  `{"id": "home", "file": "home.json"}`. Each `pages/<name>.txt` expands to its page; `go home` goes to it. With
  no `pages` (or none listed), every page of `pages/` is shown, `home` first and the others by name. The
  site's folder expands 1440 wide unless `--width` says otherwise, so its pages and components get reflow's rules
  for a tablet and a phone ([responsive.md](responsive.md#responsive-what-reflow-does)): a site made for a phone is
  expanded with `--width 390`.
- **`variables`**: shared state as JSON, the older place for it: write shared state in `app.txt` (above), as
  `state` lines. What every page and component reads and sets by name, with no `state` line of their own
  (`{cart}`, `onTap={plan="team"}`; `project cart=[]` on a page says it is the site's). Written by name, a value
  (`"cart": []`) or a record: `value`, `type` (text, integer, decimal, boolean, list, map: else the value's; `null`
  is text, so one that starts empty and later holds a record is `"replyTo": {"type": "map", "value": null}`) and
  `persist: true`, which keeps it on the device across reloads (a page's own `state … saved` is the same). A list of
  records (`[{"name": "cart", "type": "list", "value": []}]`) reads too.
- **`theme`**: the names a line uses for its looks. `colors` by name (`fill=paper`, `color=ink`; in a formula
  `theme.paper`, `fill={done ? theme.paper : theme.ink}`, each its dark value in dark mode); `textStyles` by
  name (`style=title`, `Text.caption`; `body` is a plain Text's); the roles `primary`, `onPrimary`, `surface`,
  `onSurface`, `error`, `success`, `warning` (built-in controls take them); `spacing`, `radii` and `sizes`, scales by
  name, read as `{theme.spacing.md}`, `{theme.radii.card}`; `fontFamily` and `titleFontFamily`; `mode` (`light`,
  `dark` or `system`: which colors the site opens in, and where `setThemeMode` starts); `dark`, the colors and
  roles that differ in dark mode. **A site that is dark says `"mode": "dark"`**: it then opens in the dark colors
  (its own `dark` over its design system's dark side) on every device, in a render, in an app and in the
  editor, with nothing else written; `"theme": {"primary": "#FFC6F432", "mode": "dark"}` is a whole dark theme
  under a design system that has a dark side. With no `mode` the site follows the device, and a picture of it is
  light. A color
  is `"#AARRGGBB"` (or `"#RRGGBB"`) or the name of one `colors` defines (`"surface": "paper"`). A key a theme does
  not have (`"background"`), and a color name nothing defines, is said with the line of `site.json` it is on.
- **`fonts`**: font files shipped beside `site.json`, by family: `{"family": "Inter", "fonts": [{"asset":
  "fonts/Inter-Regular.ttf"}, {"asset": "…", "weight": 600}]}` (`.ttf`, `.otf`, `.woff`).
- **`designSystem`**: a design system's folder (relative to `site.json`) or id: its theme is the base the site's
  is merged over, and its components are called by name ([design-systems.md](design-systems.md)). The site's roles
  reach what the design system draws under names of its own: `primary` its accent and everything made from it
  (tints, the focus ring, a chosen row, links), with the text on it dark on a light accent; `surface` the ground
  of a page and `onSurface` its ink, and from the two every neutral of the design system: its cards, panels,
  sidebar and bars, tinted bands, fields, table heads, hairlines and its second and third inks each keep their
  place between the site's ground and the site's ink, so a cream or a dark site has no white card and no grey
  left from the design system (its hues, a status tint or a label's, stay); `fontFamily` its text styles and
  `titleFontFamily` its titles and headings; `radius` its scale of radii in proportion. A `surface` that is dark
  where the design system's is light (a near-black written as the light theme's ground) draws the design
  system's dark side on that ground. A color the site names itself (`"colors": {"card": "#FFFFFFFF"}`) is the
  site's.
- **`dictionary`**: folders of definitions (a `<Word>.txt` each, a `define`), relative to `site.json`, or one as a
  string: a word the page, the site and its design system do not define is read from the first of them that does
  ([components.md](components.md#components-calling-one)).
- **`now`**: the time the site's seed data is written for (`"now": "2026-11-16T09:00:00"`): what `now()` and
  `today()` give in a render of the site when no `--now` is passed, so a calendar, a countdown or a "due today"
  is drawn on the day its data means. A running app does not read it.
- **`components`**: the expanded components' JSON, when not `components/<Name>.json`; components written in the
  notation are `components/<Name>.txt` ([components.md](components.md)).
- **`breakpoints`**: the widths that are a phone, a tablet and a desktop, when not the defaults
  ([responsive.md](responsive.md)).
