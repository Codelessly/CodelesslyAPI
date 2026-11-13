# Codelessly: the base

<!-- if files -->
You write Codelessly user interfaces directly as JSON files: screens, their layout, their look, their data and their
behavior. This file is the **base**: read it in full first; it is enough to build most pages. Everything else is on
a page of its own in this folder, linked from here and listed in the [index](#base-index) at the end (the same
index, with an A–Z of every name, is `index.md`). Open a page when you need what it covers; do not read the folder
end to end. On a page, *Patterns* is usually what you need; *Reference* holds the generated tables to look one prop
up. This describes `codelessly_api` {{version}}; every example here is checked by a test.
<!-- end -->
<!-- if runtime noScripts -->
You build and edit user interfaces by calling the ui_apply tool with edit ops. A UI is a Codelessly document: a
flat map of nodes by id, each a Flutter widget as data. The app renders it natively while your ops stream in. You
never write code. This is the base: enough for most UIs.
<!-- end -->
<!-- if runtime scripts -->
You build and edit user interfaces by calling the ui_apply tool with edit ops. A UI is a Codelessly document: a
flat map of nodes by id, each a Flutter widget as data. The app renders it natively while your ops stream in. You
never write code except small sandboxed scripts. This is the base: enough for most UIs.
<!-- end -->
<!-- if runtime docsTool -->
For anything else, call ui_docs with a topic from the index at the end (a page, a section, or any name).
<!-- end -->

<!-- if runtime -->
## Answering

<!-- end -->
<!-- if runtime docsTool -->
- Answer with exactly one ui_apply call (first look up what the base does not cover with ui_docs). At most one
  short sentence of text before it; none after.
<!-- end -->
<!-- if runtime noDocsTool -->
- Answer with exactly one ui_apply call. At most one short sentence of text before it; none after.
<!-- end -->
<!-- if runtime card -->
- An inline card: one canvas, "layout": {"width": 390, "height": {"hug": 400}}, no fill on the canvas; its body is a
  column with the card's fill, radius and padding.
<!-- end -->
<!-- if runtime app -->
- An app or game: one canvas of 390 × 760 (a fixed height) whose body is a column; state in variables, every
  interaction a reaction that changes them, the UI bound to them.
<!-- end -->
<!-- if runtime page -->
- A page: a canvas of 1440 × 900 whose body is a scrollable column; it must also work at 390 wide (rows that wrap,
  media rules).
<!-- end -->
<!-- if runtime -->
- Order, so the UI paints as it streams: the roots op, the canvas, then the visible structure top-down (a
  container, then its children, section by section). Declare variables in a vars op just before the first node
  that reads them, not at the start.
- The JSON must be balanced: one closing brace per opening brace. Write each op as {"op": ..., "id": ..., "node":
  {...}}: everything about the node (layout, props, bind, actions) inside "node".
- Every id you list in "children" (or a slot) must be defined by a set op in the same call. Short readable ids
  ("title", "opt2Price"); never reuse one.
- To change a UI, send the smallest ops: patch the fields that change, move to reorder, remove, set only new
  nodes. Never re-send or rebuild what exists.
- The tool result lists rejected ops (code, path, expected, suggestion) and pending ids, and says how to fix them:
  fix by patching the document as it is (same ids). Never start over with new roots or a new canvas.
- Text uses the app's font: letters, digits and common punctuation only. Arrows, check marks, stars and other
  symbols are icon nodes (Material icon names: arrow_forward, check, star), not characters.
- A button has a visible label with an explicit colour: {{button}}.
<!-- end -->
<!-- if runtime scripts -->
- Scripts: prefer a script (a scripts op) to long formulas for multi-step state changes, a puzzle's checks or a
  physics step; a reaction runs it ({"type": "runScript", "script": "name"}), a formula calls it
  (script.name(...)). A script cannot draw: it reads and sets variables (capabilities {{scriptCapabilities}}) that
  the UI binds to. More: [scripts](@state-scripts).
<!-- end -->

## The model in one table

Each node is a Flutter widget as data. The base types and what they correspond to:

| Node type | Flutter |
|---|---|
| `canvas` | a screen (`Scaffold`: slots `body`, `appBar`, `bottomNavigationBar`, `floatingActionButton`) |
| `row`, `column` | `Row`, `Column`, which also carry their own padding and decoration (a `Container` around them) |
| `flex` | `Flex`: a row or column whose `direction` can change at a width |
| `stack` | `Stack` with `Positioned` / `Align` children |
| `box` | a `Container` with no child (a shape, a rule, an image) |
| `text`, `icon` | `Text` / `Text.rich`, `Icon` |
| `spacer` | `Spacer` (with no size) / `SizedBox` (with one) |
| buttons, inputs, `listView`, `gridView` | Material's buttons and inputs, `ListView.builder`, `GridView.builder` |

Single-child wrapper widgets are fields of the node they would wrap: `Padding`, `SizedBox`, `Expanded`,
`Flexible`, `Positioned`, `Align`, `ConstrainedBox` and `AspectRatio` are in its `layout`; `DecoratedBox`,
`ClipRRect` and shadows in its `decoration`; `Opacity` and `Visibility` are `opacity` and `visible`. A "card" is
one `column` with a fill, a radius and padding, not three nested widgets.

## The document

A layout document is one JSON object holding one or more **canvases** (screens) and all their nodes in a single
flat map:

{{documentKeys}}

The smallest useful document: a canvas whose `body` slot holds a column with two texts. Every key not written takes
its default.

{{example:minimal}}

<!-- if files -->
A page is one file. A **site** is a folder with a `site.json` (its pages, components, theme and shared variables);
see [checking your work](#base-checking-your-work) and [components](@page-components).
<!-- end -->

## Theme first: named colours and text styles

Declare a palette and a type scale once and name them everywhere, as a Flutter app declares `ThemeData` and its
widgets read `Theme.of(context)`. **Write the theme before the first node**: a name per colour the design uses, a
name per kind of text (display, title, body, label, eyebrow...).

<!-- if files -->
The theme is the `theme` of the site manifest, `site.json`, next to the pages:

{{example:theme/site}}
<!-- end -->

- `colors` maps a name to `"#AARRGGBB"` (or another colour's name). Wherever a colour is accepted (a fill, a
  stroke, a text's colour, a shadow, an input's border), write its name: `"color": "ember"`.
- `textStyles` maps a name to a [TextStyle](@type-TextStyle); a style may start `from` another (`"title": {"from":
  "body", "fontSize": 32}`). A text names its style: `"style": "title"`; to change a few fields of it,
  `"style": {"from": "title", "color": "ember"}`.
- In a binding a name is not read: bind the value, `"${theme.colors.ember}"`.
- Validation reports a name the theme does not have (`unknown_theme_name`, with the nearest name).
<!-- if runtime -->
- The theme belongs to the app: use the names it gives you; without one, write each colour and style in full.
<!-- end -->

Controls (buttons, chips, fields, switches, pickers, tabs) take the colours and fonts their props leave unset
from the theme's roles (`primary`, `onPrimary`, `surface`, `onSurface`, `error`, `fontFamily`, `buttonRadius`...).
Without a theme they are neutral: ink on paper and the greys between. Nothing comes from Material's defaults or
from the app the layout is shown in.

Dark mode, a theme that changes with the screen size, every theme key: [theme](@page-theme).

## Nodes, ids, children and slots

`nodes` maps each node's **id** (the map key; do not repeat it inside the node) to the node. A parent lists its
children's ids in `children`, or names them in `slots`; a child does not name its parent. Every node except a
canvas has exactly one parent; `roots` lists the canvases, and a canvas is never a child. Ids are any text: use
short readable ones and keep them unique across a site's documents (actions, diagnostics and the render command
name nodes by id). A node's main keys: `type`, `layout`, `decoration`, `props` (the type's own parameters),
`children` / `slots`, `bind`, `actions`, `media`, `visible`, `opacity`, `name`.

Which types take children, which take named slots, which take neither:

{{childrenTable}}

A type with "no decoration" draws no box: put it inside a `box`, `row`, `column` or `stack` that has the fill or
border.

## Layout

`layout` says how big a node is and where it sits in its parent. Every field: [layout fields](@layout-layout-fields).

### Width and height

Each axis has a **mode** and a **number**:

| JSON | Mode | Size |
|---|---|---|
| `120` | fixed | Exactly 120. |
| `{"hug": 120}` | hug | The size of the content (a text's lines, a row's children plus padding). |
| `{"fill": 120}` | fill | All the room the parent gives: the free space along a row's or column's main axis (shared by `flex`), the whole cross axis, the whole box of a stack or canvas slot. |
| `{"flexible": 120}` | flexible | Up to 120, less if a row or column runs out of room (main axis only). |

The number is the **design size**: the size of a fixed node, and the size used where a mode cannot apply (a fill
inside something that scrolls on that axis, or inside a parent that hugs that axis: `fill_fallback`). For `hug` and
`fill` it does not limit the size: cap a fill with `"constraints": {"maxWidth": 760}`. **A node without `width` or
`height` is 0 × 0 and draws nothing** (`zero_size`); give every node both, except a `canvas` and a `spacer`.

### Rows, columns and flex

`row` and `column` lay their children along their **main axis**; `flex` is the same with a `direction`
(`horizontal` | `vertical`) a media rule can change. Props: `mainAxisAlignment` (default `start`;
`spaceBetween`...), `crossAxisAlignment` (default **`center`**: write `start` for left-aligned content, `stretch` to
fill), `spacing` (the gap), `wrap` (flow onto new lines, like `Wrap`; `runSpacing` between lines). A child of a row
or column may set in its own `layout`:

- `flex`: its share of the free space when its main-axis size is `fill` or `flexible` (default 1);
- `align`: its alignment in its slot, `[x, y]` from -1 to 1 or a name (`"centerRight"`);
- `order` (CSS `order`): children are laid out by ascending order, equal orders as listed;
- `basis` (CSS `flex-basis`, in a **wrapping** row): the size the child counts when lines break; with a `fill`
  main size it then grows by its `flex` share of its line. `"width": {"fill": 300}, "basis": 280` is CSS
  `flex: 1 1 280px`: three across at 1000 px, two at 700, one at 390.

A child hidden by a binding or a media rule takes no room (CSS `display: none`). A `spacer` takes the free space
only in a row or column that has some (a fill or fixed main size).

### Padding, margin, constraints, a capped width

- `padding` is space inside the node's box, `margin` outside it: a number (all sides) or **four** numbers
  `[left, top, right, bottom]` (two numbers are not read).
- `constraints`: `{"minWidth", "maxWidth", "minHeight", "maxHeight"}`. `aspectRatio`: width / height.
- **A full-width band with capped, centered content** (CSS `max-width: 1200px; margin: 0 auto`): the band fills
  the width and holds the background; its one child fills with `"constraints": {"maxWidth": 1200}`, centered by the
  band's `crossAxisAlignment` (`center`, the default). [The capped band, with an example](@layout-a-capped-band).
- A negative margin does not overlap a neighbour: to overlap, move what the node paints with `"motion":
  {"translateY": -36}` (layout unchanged), or use a stack. [Overlap and bleed](@layout-overlap-and-bleed).

### Stacks

A `stack` places each child by its `layout.x` and `layout.y`: `16` or `{"start": 16}` from the left/top,
`{"end": 16}` from the right/bottom, `{"start": 16, "end": 16}` stretched between, `{"align": 0}` aligned (-1 start,
0 center, 1 end). Later children paint on top. `x`/`y` mean nothing under a row or column, `flex`/`align` nothing
under a stack (`layout_field_ignored`).

{{example:stack}}

## Decoration

`decoration` paints the node's box:

- `fills`: paints, bottom to top. `{"color": "#FF2563EB"}` is solid; a gradient is `{"type": "linear", "stops":
  [{"position": 0, "color": ...}, {"position": 1, "color": ...}]}` (`"begin"`/`"end"` alignments; also `radial`,
  `sweep`); an image is `{"type": "image", "image": {"url": "...", "fit": "cover"}}` (give the box the image's size
  or an `aspectRatio`).
- `strokes` with `strokeWidth` (default 1): the border. `radius`: a number or `[topLeft, topRight, bottomRight,
  bottomLeft]`. `shape: "circle"`.
- `effects`: `{"type": "dropShadow", "color": "#1F000000", "offset": [0, 4], "blurRadius": 12}`; an effect needs
  its `type`.
- `clip: "antiAlias"` clips the children to the rounded box.

Colours are `"#AARRGGBB"` (alpha first: `#FF` opaque, `#80` half), `"#RRGGBB"` or a theme colour's name; `"#FFF"`,
`rgb()` and CSS names are not read. Patterns in pixels, grain, foreground scrims, icons, paths and custom drawing:
[decoration](@page-decoration).

{{example:decoration}}

## Text

A `text` node has `props.text` and `props.style`: a theme style's name (`"style": "body"`) or a TextStyle
(`fontSize`, `fontWeight` 100–900, `fontFamily`, `color`, `height` as a multiple of the size, `letterSpacing`,
`decoration`, `fontStyle`), plus `textAlign`, `maxLines` and `overflow` (`ellipsis`).

- **No `color`: the text is painted white.** Always set it (in the style or the named style).
- No `fontSize`: 12. No `fontWeight`: 400. No `fontFamily`: the platform's default (Roboto). No `height`: the
  nearest `defaultTextStyle`'s, else the font's own line height ([text](@theme-text)).
- Size: one line `{"hug": n}` × `{"hug": n}`; a paragraph `{"fill": n}` wide (it wraps) × `{"hug": n}` high.
- `text` may hold expressions: `"Hello, ${user.name}"`; `"$${price}"` shows `$47`.
- Symbols the font has no glyph for (✦, ✓, →) draw as empty boxes (`missing_glyph`): use an `icon` node.

Runs (parts in another style), superscripts, links in text: [text](@theme-text).

## The base node types

The props that matter most; each type's page lists all of them.

{{baseTypes}}

- **Buttons**: the text is `label` (not `text`); colours, corners and the label's style are in `style` (a
  [ButtonStyle](@type-ButtonStyle): `backgroundColor`, `foregroundColor`, `textStyle`, `shape`), not in
  `decoration`. Give a button a fixed width or a fill: a hugging button is only as wide as its label. For full
  control, use a `row` with a fill, padding, a text child and a `click` reaction.
- **Inputs** (`textField`, `checkbox`, `switch`, `radio`, `slider`, `dropdown`, `segmentedButton`) report a new
  value through their `changed` trigger as `${result}`: store it with `setVariable`. **Two-way**: bind the value
  prop to the variable (`"bind": {"props.initialValue": "${query}"}` for a text field, `"props.value"` for the
  others). A text field's label, hint, border and fill are in `props.decoration` (an
  [InputDecoration](@type-InputDecoration)). Styling every control, validation: [forms](@page-forms).
- **Lists**: a `listView` or `gridView` repeats its **first child** once per item of its `data` binding:
  `"bind": {"data": "${plans}"}`; inside, `${item.name}` and `${index}`. An item fills the list across (its
  cross-axis size is `fill`). In a page that scrolls, give the list
  `"scrollable": false` (a gridView: `"physics": "never"`). A grid of as many equal columns as fit:
  `minCrossAxisExtent` (CSS `repeat(auto-fit, minmax(280px, 1fr))`); equal-height cards: `"shrinkWrapRows": true`.
  Nested lists, tables, pagination: [lists](@page-lists).
- **Icons**: `props.icon` is a Material icon name (`"arrow_forward"`, `"check_circle"`; `_outlined`, `_rounded`
  suffixes), with `color` and `size`.
- **Images**: an image fill on a `box` (see Decoration). **Divider**: `divider` with `thickness` and `color`, or a
  `box` 1 high with a fill.

## Variables, bindings and expressions

**Variables** hold state. Declare them in the document's `variables` under a canvas id (that screen) or
`"page_variables"` (every canvas of the document):

```json
"variables": {"page_variables": [
  {"name": "annual", "type": "boolean", "value": false},
  {"name": "plans", "type": "list", "value": [{"name": "Team", "monthly": 39}]},
  {"name": "price", "type": "number", "formula": "annual ? plans[0].monthly * 0.8 : plans[0].monthly"},
  {"name": "usd", "type": "text", "parameters": ["n"], "formula": "'$' + round(n)"}
]}
```

Types: {{variableTypes}}. A variable with a `formula` is **computed**: read-only, it follows what it reads. With
`parameters` it is a **function** any formula calls (`${= usd(price * 12)}`). Write a rule once, not in every
binding.

**Expressions**: `${name}` or `${path}` reads a value (`${user.name}`, `${items[0].price}`, `${item.title}`);
`${= formula}` computes one (`${= count * price}`, `${= annual ? 'Yearly' : 'Monthly'}`, a list
`${= popular ? [0, 0, 0, 0] : [0, 28, 0, 0]}`). A text that is exactly one expression keeps the value's type. `${false}` reads a variable called `false`: a literal is `${= false}`.
Every formula function, grouped (text, numbers, money, lists, dates): [formula functions](@state-formula-functions).

**Bindings** put an expression on a field: `"bind": {path: expression}`, updated whenever what it reads changes.

```json
"bind": {"props.text": "${= 'Total: ' + money(count * price, '$')}", "visible": "${= count > 0}",
         "decoration.fills[0].color": "${= selected ? '#FFDBEAFE' : '#FFFFFFFF'}"}
```

Paths: `visible`, `opacity`, `layout.<field>`, `decoration.<field>` (`fills[0].color`), `props.<prop>` and
`props.<prop>.<field>`, `data`, `selected`, `disabled`, behavior keys. Other fields are literal: `"opacity":
"${x}"` is an error; bind it. What each path expects: [binding paths](@state-binding-paths).

## Reactions

A node's `actions` is a list of **reactions**: a trigger and the actions it runs, in order:

```json
"actions": [{"trigger": {"type": "click"},
             "actions": [{"type": "setVariable", "variable": "count", "op": "add", "value": "1"},
                         {"type": "navigate", "to": "thanks"}]}]
```

- Triggers: `click`, `hover`, `changed` (an input's value), `submitted`, `load` (on a canvas), `valueChanged`,
  `timer`... (all of them: [triggers](@interaction-triggers)).
- `setVariable` (`op`: `set` (default), `toggle`, `add`, `subtract`, `insert`, `removeAt`...; `value` is an
  expression), `navigate` (`to`: a canvas id; `"mode": "pop"` goes back), `openModal` / `closeModal`, `showToast`,
  `if` (`"condition"`: a predicate, `{"left": "${count}", "op": "greaterThan", "right": "5"}` or `{"left":
  "${= valid}", "op": "isTrue"}`; `then` and `else`: action lists), `scrollTo`, `componentEvent` (a component's event, or at run time the event
  to the host app). Action types here: {{actionTypes}}.
- In a chain `${result}` is the trigger's event (a text field's text) until an action gives another value.
- A tap on a control inside a tappable row runs the control's reaction only: to toggle from the whole row, give the
  control `"ignorePointer": true` and bind its value.

Hover and pressed styles (`states`), drag, gestures: [interaction](@page-interaction). Screens and modals:
[navigation](@page-navigation).

## Screen sizes: media rules

1. Prefer layout that fits any width: wrapping rows with `basis`, a `gridView` with `minCrossAxisExtent`, a capped
   band.
2. A node's `media` is a list of CSS media queries over the node: `[{"minWidth": 600, "patch": {"props": {"style":
   {"fontSize": 40}}}}]`. `minWidth`/`maxWidth` are px (inclusive) or a breakpoint name (`"tablet"`).
3. The `patch` is shaped like the node (`props`, `layout`, `decoration`, `visible`, `motion`, `bind`) and merged
   over it; later rules win (the cascade). Write for phones, add `minWidth` rules (mobile first).
4. A row that becomes a column: a `flex` with a rule patching `"direction": "vertical"`; another order: patch
   `layout.order`; hidden: `"visible": false`.
5. A field both patched and bound shows the binding (`media_overridden`): put the binding in the rule's patch.

Breakpoints, sticky headers, scrolling, a canvas per breakpoint: [responsive layout](@page-layout).

## Rules that are easy to get wrong

1. Every node needs `layout.width` and `layout.height`; without them it is 0 × 0.
2. Every text needs a colour; without one it is white.
3. Padding and margin are a number or four numbers, never two.
4. Colours are `#AARRGGBB`, `#RRGGBB` or a theme colour's name; define the theme first and name its colours and
   styles.
5. Columns center their children across by default: `"crossAxisAlignment": "start"` for left-aligned content.
6. A screen taller than the window needs a scrolling body column (`"scrollable": true`, `fill` both ways).
7. Values in `props`, `layout` and `decoration` are literal; expressions go in `bind` (except `props.text`).
8. `x`/`y` only work under a `stack`; `flex`/`align` only under a `row`, `column` or `flex`.
9. Ids are map keys; a child is listed in exactly one parent; canvases are only in `roots`.
10. `fill` takes all the room it is given: cap it with `constraints.maxWidth`. Under a parent that hugs that
    axis, a fill is its design number (`fill_fallback`).
11. A backslash in a formula is written twice in JSON: `"${= matches(code, '^\\d{4}$')}"`.
12. Buttons: `label`, colours in `style`. Inputs: `changed` + `setVariable`, two-way by binding the value prop.
13. Repeated content comes from data: one template in a `listView` / `gridView`, not copies.

<!-- if files -->
## Checking your work

Decoding is lenient: a misspelled key or a value of the wrong shape is silently dropped. Never trust a document
that has not been checked. Run the render command from the SDK repository:

```sh
tool/render/render.sh site/ --out shots/ --sizes 390x844,834x1112,1440x900 --full-page
```

It validates every document strictly, renders each screen at each size (`shots/<screen>@<w>x<h>.png`,
`shots/diagnostics.json`) and prints one line per problem: a code, the JSON pointer
(`/nodes/hero-title/props/style/fontSize`) and what to do. It exits 1 on errors. Steps before the capture:
`--tap <id>` (`<id>#<n>` for the n-th list item), `--hover`, `--focus`, `--type <id>=<text>`,
`--set <variable>=<json>`, `--scroll <id>=<px>`, `--navigate <canvas>`, `--label <name>`. Look at the
screenshots: validation cannot tell you a page is ugly. Every option and diagnostic code: [render](@page-render).

## Sites and components as files

A page longer than a screen or two is easier to write, fix and reuse as parts, each a file: a **component** is a
document with one root and a `widget` declaration of its parameters, slots and events, read inside as
`${props.price}`; a page **calls** it with one node of that type (`{"type": "PlanCard", "props": {"price": 47}}`),
as Flutter builds `PlanCard(price: 47)`. A component never reads its page's variables: pass what it needs as
parameters, and shared state as a `variable` parameter. A folder with `site.json` (pages, components, theme,
project variables) is a site.

- **List template**: one shape repeated from data in one parent.
- **Component**: the same structure in two or more places with different values (a card, a chip).
- **Section**: a top-level band of a page (header, hero, pricing, FAQ, footer), in its own file when it is more
  than about 15 nodes.

Parameter kinds, slots, events, the manifest, rendering one part: [components](@page-components).
<!-- end -->

<!-- if runtime -->
## Ops

`{"ops": [op, ...]}`, applied in order:

{{ops}}

## Examples

Build (a card with a selectable list and a labelled button):

{{buildExample}}

Change it ("make it say Lisbon and add a note"):

{{editExample}}

Every op rule, streaming and the retry protocol: [edit ops](@page-edit-ops).
<!-- end -->

<!-- if index -->
## Index

{{index}}
<!-- end -->
