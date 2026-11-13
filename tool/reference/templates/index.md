# Codelessly layout documents: a guide for authors

This guide is for writing Codelessly user interfaces directly as JSON: screens, their layout, their look, their
data and their behavior. It describes `codelessly_api` {{version}}, the data model the Codelessly SDK renders. Every
example on this page is checked by a test: it decodes, passes strict validation and was rendered with the SDK.

The rest of the reference is generated from the declarations in the code, so it lists every node type, prop,
field, enum value, trigger, action and formula function with its type and default:
{{page:nodes.md|node types}}, {{page:layout.md|layout}}, {{page:decoration.md|decoration}},
{{page:values.md|value types, models and enums}}, {{page:behaviors.md|behaviors}}, {{page:triggers.md|triggers}},
{{page:actions.md|actions}}, {{page:bindings.md|bindings}}, {{page:formulas.md|formula functions}},
{{page:variables-conditions-scripts.md|variables, conditions and scripts}}. `catalog.json` holds the same
information as data and `document.schema.json` is a JSON Schema for a document.

Contents: 1 [The document](#guide-document) · 2 [Nodes, ids and children](#guide-nodes) ·
3 [Layout](#guide-layout) · 4 [Decoration](#guide-decoration) · 5 [Text](#guide-text) ·
6 [Screens and navigation](#guide-screens) · 7 [Responsive design](#guide-responsive) ·
8 [Variables, bindings and expressions](#guide-variables) · 9 [Conditions](#guide-conditions) ·
10 [Reactions: triggers and actions](#guide-reactions) · 11 [Hover, press and other states](#guide-states) ·
12 [Scrolling](#guide-scrolling) · 13 [Lists and repeated data](#guide-lists) · 14 [Forms and inputs](#guide-forms) ·
15 [Modals and toasts](#guide-modals) · 16 [Images, icons and fonts](#guide-images) ·
17 [Checking your work](#guide-checking) · 18 [Rules that are easy to get wrong](#guide-pitfalls)

<a id="guide-document"></a>
## 1. The document

A layout document is one JSON object. It holds one or more **canvases** (screens) and all their nodes in a
single flat map.

{{documentKeys}}

The smallest useful document: a canvas whose `body` slot holds a column with two texts.

{{example:minimal}}

Nothing else is needed: every key not written takes its default. A document is a **page**; a site with several
pages is either one document with several canvases in `roots`, or several documents (one file each) checked and
rendered together ([section 6](#guide-screens)).

<a id="guide-nodes"></a>
## 2. Nodes, ids and children

`nodes` maps each node's **id** to the node. The id is the map key; do not repeat it inside the node. Ids are
any text; use short readable ones (`hero-title`), and keep them unique across all documents of a site, because
actions, conditions, diagnostics and the render command name nodes by id.

Every node has a `type` (one of the {{page:nodes.md|node types}}). Its keys:

{{nodeKeys}}

**The tree is made of ids.** A parent lists its children's ids; a child does not name its parent:

- `children` is an ordered list of ids, for the types that take children: `row`, `column`, `stack`, `listView`,
  `gridView`, `pageView`, `variance` and a few more (the "Children" column below).
- `slots` maps a slot name to one id, for types with named places: a `canvas` has `body`, `appBar`,
  `floatingActionButton` and `bottomNavigationBar` (placed as Flutter's `Scaffold` places them: the app bar across
  the top at its own height, the bottom bar across the bottom, the body between, the button 16 px from the right
  and above the bottom bar); a `listTile` has `leading`, `title`, `subtitle`, `trailing`.
- Every node except a canvas has exactly one parent. A node listed under two parents, or not listed under any,
  is an error or a warning in validation. To show the same thing twice, write two nodes with their own ids.
- `roots` lists the canvases. A canvas is never a child.

There is no `Padding`, `SizedBox`, `Expanded`, `Positioned`, `Align`, `DecoratedBox` or `Opacity` node: those
Flutter wrappers are fields of the node itself (`layout`, `decoration`, `opacity`). A "card" is one `column` with
a fill, a radius and padding, not three nested widgets.

{{nodeTypeSummary}}

"Decoration: blurs only" means the type draws no box: give it a fill or a border by putting it inside a `box`,
`row`, `column` or `stack` that has the decoration.

<a id="guide-layout"></a>
## 3. Layout

`layout` says how big a node is and where it sits in its parent. Full field list: {{page:layout.md|layout}}.

### Width and height

Each axis has a **mode** and a **number**:

| JSON | Mode | Size |
|---|---|---|
| `120` | fixed | Exactly 120. |
| `{"hug": 120}` | hug | The size of the content (a text's lines, a row's children plus padding). |
| `{"fill": 120}` | fill | All the room the parent gives: the free space along a row's or column's main axis (shared by `flex`), the whole cross axis of a row or column, the whole box of a stack or canvas slot. |
| `{"flexible": 120}` | flexible | Up to 120, less if a row or column runs out of room (only along a row's or column's main axis). |

The number is the **design size**: the size of a fixed node, and the size used when a mode cannot apply (a fill
inside something that scrolls on that axis, for instance). For `hug` and `fill` it does not limit the size:
`{"fill": 760}` in a 1300 wide column is 1300 wide. Write the size you expect, and use
`"constraints": {"maxWidth": 760}` to cap it.

**A node without `width` or `height` is fixed at 0 and draws nothing.** Validation warns (`zero_size`). Give every
node both, except a `canvas` (its size is the screen's) and a `spacer`.

{{example:sizing}}

In this example the text hugs its content, the red box fills the column's width, and in the row the green box
and the blue box share the free space 1 : 2 (`flex`) beside a fixed grey box.

### Rows, columns and flex

`row` and `column` lay their children along their **main axis** (horizontal for a row, vertical for a column).
`flex` is Flutter's `Flex`, the widget both extend: the same props plus `direction` (`horizontal` | `vertical`),
which a media rule or a binding can change, so the same children become a column at a width. They take
these props: `mainAxisAlignment` (default `start`), `crossAxisAlignment` (default **`center`**: children are
centered across the axis unless you say `start`, `end` or `stretch`), `spacing` (gap between children, default
0), `wrap` (flow onto new lines, like `Wrap`; `runSpacing` between lines), `squeezeChildren` (default true: if
the children do not fit, they shrink toward their content size instead of overflowing).

Under a row or column a child may also set, in its own `layout`:

- `flex`: its share of the free space when its main-axis size is `fill` or `flexible` (default 1);
- `align`: its alignment within its slot, as `[x, y]` from -1 to 1 or a name (`"centerRight"`); the node's box
  then spans the slot and its content sits at that alignment;
- `squeezable`: a hugging child that may shrink below its content when room runs out;
- `order` (CSS `order`): children are laid out and painted by ascending order, equal orders as listed;
- `basis` (CSS `flex-basis`, in a **wrapping** row, column or flex): the main size the child counts when lines are
  broken; a child that also fills the main axis (`{"fill": n}`) then grows by its `flex` share of what its line
  leaves. `"width": {"fill": 300}, "basis": 280` is CSS `flex: 1 1 280px`: three across at 1000 px, two at 700, one
  at 390 ([section 7](#guide-responsive)). Without `basis`, children of a wrapping row keep their own size. In a
wrapping row `crossAxisAlignment: stretch` makes the children of each line as tall as its tallest (CSS
`align-items: stretch`: equal-height cards per line).

A child hidden by a binding, a condition or a media rule takes no room and no slot: `spaceBetween` spreads the
children that show (CSS `display: none`; in Flutter, leaving it out of the list). A node written with
`"visible": false` and nothing that shows it keeps its room empty.

A `spacer` is Flutter's `Spacer`: in a row or column it takes the free space (`flex` shares it) unless it is given
a fixed size along the main axis; in a row whose width hugs its children there is no free space to take.

### Padding, margin, constraints, aspect ratio

- `padding` is space inside the node's box, around its content and children; `margin` is space outside it. A
  `text` has no padding (its box is its lines; validation warns): use `margin`, or a row with the padding around it. A negative margin does not overlap neighbours (Flutter has none):
  overlap in a stack with a negative offset.
  Both are a number (all sides) or a list of **four** numbers `[left, top, right, bottom]`. A list of two is not
  read (it becomes 0 on every side; validation reports it).
- `constraints`: `{"minWidth", "maxWidth", "minHeight", "maxHeight"}`, each optional. A `fill` width with
  `"maxWidth": 1100` gives a content column that grows with the window up to 1100; its parent's
  `crossAxisAlignment` (center by default) places it.
- `aspectRatio`: width / height the node keeps (`1.5`).
- `rotation`: degrees, clockwise, about the center; layout is unchanged.

### Stacks: placing children freely

A `stack` places each child by its `layout.x` and `layout.y`, measured inside the stack's padding to the child's
margin box. Each axis takes one of:

| JSON | Placement |
|---|---|
| `{"start": 16}` (or just `16`) | 16 from the left (x) or top (y) |
| `{"end": 16}` | 16 from the right or bottom |
| `{"start": 16, "end": 16}` | Stretched between: 16 from both edges. Works for fixed and fill sizes; a `hug` size keeps its own size and sits at the start. |
| `{"align": 0}` | Aligned like `Align`: -1 start, 0 center, 1 end |
| `{"relative": 300}` | 300 from the start at the stack's design size, keeping its share of the free space as the stack resizes |

`x`, `y` mean nothing under a row or column, and `flex`, `align` nothing under a stack: validation warns
(`layout_field_ignored`). Children paint in order: later ones on top. A child may sit partly outside a stack with
a fixed or fill size (a negative `start`, as Flutter's `Positioned(top: -40)`); it is clipped only if the stack's
`decoration.clip` says so. A stack that hugs its children grows to hold them, so there a negative offset is 0
(`layout_clamped`).

{{example:stack}}

Which modes each parent allows (from the parents' own rules):

{{childFits}}

<a id="guide-decoration"></a>
## 4. Decoration

`decoration` paints the node's box (types with "box decoration" above). Full list: {{page:decoration.md|decoration}}.

- `fills`: a list of paints, bottom to top. `{"color": "#FF2563EB"}` is a solid color. A gradient is
  `{"type": "linear" | "radial" | "sweep" | "diamond", "stops": [{"position": 0, "color": ...}, {"position": 1, "color": ...}]}`.
  As Flutter's `LinearGradient`, a linear one runs from `"begin"` to `"end"` (alignments; default left to right;
  `[0, -1]` to `[0, 1]` is top to bottom), with `"tileMode": "repeated"` repeating it past them (thin stripes:
  `"begin": [-1, 0], "end": [-0.96, 0]`). As `RadialGradient`, a radial one has a `"center"` (alignment, default
  the middle) and a `"radius"` (a share of the box's shortest side; default half its width); past the last stop
  it keeps that stop's color, so end a glow on a transparent stop. `transform` is the general form
  ({{link:values.md#type-Paint|Paint}}). An image is `{"type": "image", "image": {"url": "...", "fit": "cover"}}`.
  A paint without `type` is an image if it has `image`, a linear gradient if it has `stops`, else a solid color.
  There is no noise or texture paint: a grain needs an image file (a repeated image fill, `"repeat": "repeat"`).
- `strokes`: paints for the border, with `strokeWidth` (default 1), `strokeAlign` (`inside`, `center`,
  `outside`), `strokeSides` (`all`, `bottom`, `topBottom`...) and `dashPattern` (`[6, 4]`). `strokeWidth` without
  `strokes` draws nothing.
- `radius`: corner radius: a number, `[x, y]`, or `[topLeft, topRight, bottomRight, bottomLeft]`.
- `shape`: `"circle"` paints a circle the box's shortest side across.
- `effects`: shadows and blurs, each `{"type": "dropShadow" | "innerShadow" | "layerBlur" | "backgroundBlur", ...}`
  with `color`, `offset` (`[dx, dy]`), `blurRadius`, `spreadRadius`. **An effect needs its `type`**; without it the
  effect is dropped.
- `clip`: `"antiAlias"` (or `hardEdge`) clips the content to the rounded box.

Colors are always `"#AARRGGBB"` (alpha first: `#FF` opaque, `#80` half, `#00` invisible) or `"#RRGGBB"` (opaque).
`"#FFF"`, `"rgb(...)"` and names are not read.

{{example:decoration}}

<a id="guide-text"></a>
## 5. Text

A `text` node has `props.text` and `props.style`, a {{link:values.md#type-TextStyle|TextStyle}}:
`fontSize`, `fontWeight` (100–900), `fontFamily`, `color`, `height` (line height as a multiple of the font size),
`letterSpacing`, `decoration` (`underline`...), `fontStyle` (`italic`). Also `textAlign`, `maxLines` and
`overflow` (`ellipsis`).

What a text looks like when the style leaves something out:

- **No `color`: the text is painted white.** On a light background it is invisible. Always set `color`.
- No `fontSize`: 12. No `height`: 1.33 × the font size per line. No `fontWeight`: 400. No `letterSpacing`: 0.
- No `fontFamily`: the platform's default font (Roboto on Android and the web).

Sizing: a single line `{"hug": n}` × `{"hug": n}`; a paragraph `{"fill": n}` wide (it wraps) × `{"hug": n}` high.
A fixed height shorter than the lines clips them (the render command reports `text_clipped`).

Characters the font has no glyph for (✦, ✳ in Roboto) are drawn as empty boxes; the render command reports
them (`missing_glyph`). Draw a small mark with an `icon` or a `box` with a `path` instead.

`runs` style parts of the text: `[{"start": 0, "end": 5, "style": {"fontWeight": 700}}]` (character offsets, end
exclusive), merged over `style`; a run may carry a `"link"` URL. `text` may contain expressions:
`"Hello, ${user.name}"` ([section 8](#guide-variables)).

<a id="guide-screens"></a>
## 6. Screens and navigation

Each canvas in `roots` is a screen, unless canvases are grouped: canvases with the same `props.screen` are **one
screen**, one canvas per breakpoint ([section 7](#guide-responsive)). A canvas is the Flutter `Scaffold` of its
screen: put the page content in its `body` slot, usually a column filling it (`{"fill": n}` both ways). Its
`decoration.fills` is the page background. Its `layout` width and height are its design size; on a device the
canvas takes the screen's size.

Going from screen to screen is an action ([section 10](#guide-reactions)):
`{"type": "navigate", "to": "<canvas id>"}` pushes the screen; `"mode": "pop"` goes back; `"replace"` and
`"reset"` replace the history. `to` names a canvas: for a screen with a canvas per breakpoint, name any of
them; the canvas shown is the one for the current width. `"params": {"id": "${item.id}"}` passes values the
destination reads as `${route.id}`.

A site's pages may be separate documents (one file per page, checked and rendered together); `navigate` then
names a canvas id of another document. Give a canvas a `"path"` (`"pricing"`, a top-level key of the canvas
node, not a prop) for its URL; without one it gets a path from its name. The first screen of the first document
is the entry screen.

{{example:navigation}}

<a id="guide-responsive"></a>
## 7. Responsive design

Responsive layout works as on the web: flexbox and grid lay content out so it fits any width, and media queries
change what must change at a width. Use these, in this order:

1. **Intrinsic layout, no breakpoints.** A wrapping row (CSS `flex-wrap: wrap`) whose children set
   `layout.basis` (CSS `flex-basis`) and fill the main axis: lines break by the basis, and the children on each line
   grow (by `flex`, CSS `flex-grow`) to share it. Three `{"fill": n}` cards with `"basis": 280` sit three across at
   1000 px, two at 700 and one at 390; a text and a photo with `"basis": 320` sit side by side, then stack. For
   repeated data, a `gridView` with `minCrossAxisExtent` (CSS `repeat(auto-fit, minmax(280px, 1fr))`) makes as many
   equal columns as fit. A content column capped and centered (CSS `max-width` + `margin: auto`) is a `{"fill": n}`
   width with `constraints.maxWidth`, centered by its parent's `crossAxisAlignment` (`center`, the default). A
   share of the parent (CSS `width: 60%`) is `layout.widthFactor: 0.6`.
2. **Media rules** for what must change at a width: direction, order, visibility, type size, padding. A node's
   `media` is a list of rules, each a CSS media query over the node itself:
   `{"minWidth": "tablet", "patch": {"props": {"style": {"fontSize": 40}}}}` is
   `@media (min-width: 600px) { #title { font-size: 40px } }`. `minWidth` and `maxWidth` are pixels (inclusive, as in
   CSS) or a breakpoint name (`minWidth: "tablet"`: from tablet's min width; `maxWidth: "tablet"`: up to the next
   breakpoint, so tablet and narrower); `orientation` is `portrait` or `landscape`; all conditions of a rule must
   hold. The `patch` is shaped like the node (`props`, `layout`, `decoration`, `visible`, `opacity`) and merged over
   it (objects merge, `null` removes). Rules apply in order, a later one winning where two set the same field (the
   CSS cascade): write the node for phones and add `minWidth` rules for wider screens (mobile first), or the other
   way round with `maxWidth`. Validation checks every patched value as the node's own.
   - **A row that becomes a column**: a `flex` node (Flutter `Flex`) with `"direction": "horizontal"` and a rule
     patching `"direction": "vertical"`. Its children stay the same nodes, keeping their state.
   - **Another order at a width**: each child's `layout.order` (CSS `order`; ascending, equal orders as listed),
     patched in the child's own rule: `{"maxWidth": "mobile", "patch": {"layout": {"order": -1}}}` puts it first.
   - **Hidden at a width**: `{"maxWidth": "tablet", "patch": {"visible": false}}`. A hidden node takes no room and
     no slot (CSS `display: none`).
   - Precedence: the node's own values, then its media rules, then an active interaction state's patch
     ([section 11](#guide-states)), then its bindings, then conditions. A field both patched and bound shows the
     binding (validation warns: `media_overridden`).
3. **Bindings on `${screen}`** for values computed from the size, the escape hatch:
   `"bind": {"layout.width": "${= min(screen.width - 32, 760)}"}`. `${screen}` has `width`, `height`,
   `breakpoint` (the id), `is.<name>` and `atLeast.<name>` (`${= screen.atLeast.tablet ? 3 : 1}`), and
   `isMobile`/`isTablet`/`isDesktop` (one per breakpoint id). `${screen.width}` prints a decimal (`390.0`);
   `${= screen.width}` prints `390`. Nothing can check such a formula's result type: prefer media rules.
4. **A canvas per breakpoint**, only for screens that are genuinely different designs. Canvases with the same
   `props.screen` are one screen; each sets `props.breakpoint` to the breakpoint it is for. At a given width the
   screen shows the canvas whose breakpoint's `minWidth` is the highest at or below the width, else its narrowest.
   Each canvas has its own nodes; share state with `page_variables` ([section 8](#guide-variables)). A `variance`
   node does the same for one part of a screen.

The project's **breakpoints** name size classes by minimum width. Unless a document's `breakpoints` key says
otherwise they are:

{{breakpointDefaults}}

This page uses all four web patterns: a header whose links collapse to a menu icon below desktop (media rules on
`visible`), a 3 → 2 → 1 card grid from data with no breakpoint (`minCrossAxisExtent`), a text-and-photo section
that stacks with the photo first on phones (`basis` in a wrapping row, the photo's `order` patched), and a title
whose size steps up with the width (media rules on `fontSize`), inside a content column capped at 1200 and
centered:

{{example:responsive_web}}

The same page in CSS:

```css
#nav { display: none } @media (min-width: 1024px) { #nav { display: flex } #menu { display: none } }
#plans { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px }
#split { display: flex; flex-wrap: wrap; gap: 16px 48px } #split > * { flex: 1 1 320px }
@media (max-width: 599px) { #split-photo { order: -1 } }
#title { font-size: 32px } @media (min-width: 600px) { #title { font-size: 40px } }
@media (min-width: 1024px) { #title { font-size: 56px } }
#content { max-width: 1200px; margin: 0 auto }
```

<!-- guide-only -->
Older documents use a canvas per breakpoint:

{{example:responsive}}

{{example:variance}}
<!-- /guide-only -->

<a id="guide-variables"></a>
## 8. Variables, bindings and expressions

**Variables** hold a screen's state. Declare them in the document's `variables`, under a canvas id (that canvas
only) or under `"page_variables"` (every canvas of the document, kept while the user moves between them):

```json
"variables": {"page_variables": [{"name": "annual", "type": "boolean", "value": false}]}
```

Types: {{variableTypes}}. `value` is written as the type holds it in JSON: `3`, `2.5`, `true`, `"text"`,
`"#FF2563EB"`, `[...]`, `{...}`.

**Computed variables** define a value once: a variable with a `formula` (what goes in `${= ...}`) is read-only and
follows what it reads. **Function variables** add `parameters` and are called by name from any formula. Declare
them in `page_variables` to share them with every canvas of the document (a screen's breakpoint canvases too):

```json
"variables": {"page_variables": [
  {"name": "query", "type": "text", "value": ""},
  {"name": "dishes", "type": "list", "value": [{"name": "Lamb", "vegan": false}, {"name": "Squash", "vegan": true}]},
  {"name": "shown", "type": "list", "formula": "filter(dishes, d => contains(lower(d.name), lower(query)))"},
  {"name": "count", "type": "integer", "formula": "length(shown)"},
  {"name": "usd", "type": "text", "parameters": ["n"], "formula": "'$' + round(n)"}
]}
```

`${shown}` feeds a list, `${count}` a label, `${= usd(price * 12)}` any text, wherever they are needed: write a
filter or a rule once, not in every binding. A function variable's name must not be a formula function's
({{page:formulas.md|formula functions}}): the built-in one wins.

**Expressions** are text that reads values:

- `${name}` or `${path}` reads a value: `${count}`, `${user.name}`, `${items[0].price}`, `${item.title}`.
- `${= formula}` computes one: `${= count * price}`, `${= annual ? 'Yearly' : 'Monthly'}`,
  `${= money(total, '$')}`. Operators: `+ - * / %`, comparisons, `&&`, `||`, `!`, `a ? b : c`; functions are
  listed in {{page:formulas.md|formula functions}}.
- A text that is exactly one expression gives its value with its type (a number stays a number, a list a list);
  any other text with `${...}` is text with the values inserted.

Names an expression can start with: the screen's variables and {{scopes}}. `screen` and `route` are described
above; `item` and `index` exist inside a list's item ([section 13](#guide-lists)); `result` is what the previous
action of a chain gave.

**Bindings** put an expression on a field. `bind` maps a **binding path** to an expression; the field takes the
value whenever the names it reads change:

```json
"bind": {"props.text": "${= 'Total: ' + money(count * price, '$')}", "visible": "${= count > 0}"}
```

Literals are not names: `${false}` reads a variable called `false`; write `${= false}` (or just `false` in the
field, without a binding).

Paths: `visible`, `opacity`, `layout.<field>` (`layout.width`), `decoration.fills[0].color`,
`decoration.radius`, `props.<prop>` and `props.<prop>.<field>` (`props.style.color`), `data` (a list's items),
`selected`, `disabled`, and behavior keys. Full list: {{page:bindings.md|bindings}}. Values are read loosely
(`"12"` is a number, `"#FF0000"` a color); a value that cannot be read leaves the field as it was. A text's
`props.text` may hold `${...}` directly, without `bind`. Other fields do not evaluate expressions written in them:
`"opacity": "${x}"` is an error; write `"bind": {"opacity": "${x}"}`.

{{example:counter}}

<a id="guide-conditions"></a>
## 9. Conditions

A condition sets node fields while a test holds: an ordered list of branches (if, else if, ..., else). It lives
in the document's `conditions`, under a canvas id. Each branch has `when` (a predicate; none for the final else)
and `set`, a list of `{"node": id, "path": binding path, "value": value}`. A predicate is
`{"left": "${annual}", "op": "isTrue"}`, `{"left": "${count}", "op": "greaterThan", "right": "5"}`, or
`{"and": [...]}` / `{"or": [...]}`.

{{conditionOps}}

For one field the first branch that holds and sets it wins; a condition wins over the node's binding, which wins
over the node's own value. A binding with a formula is often simpler; conditions suit setting several nodes at
once.

{{example:conditions}}

<a id="guide-reactions"></a>
## 10. Reactions: triggers and actions

A node's `actions` is a list of **reactions**. A reaction is a **trigger** and the chain of **actions** it runs, in
order:

```json
"actions": [{"trigger": {"type": "click"},
             "actions": [{"type": "setVariable", "variable": "count", "op": "add", "value": "1"},
                         {"type": "navigate", "to": "thanks"}]}]
```

- Triggers ({{page:triggers.md|all}}): `click`, `hover`, `cursorEnter`/`cursorExit`, `longPress`, `changed`
  (an input's value changed), `submitted`, `load` (on a canvas: the screen appeared), `valueChanged` (a variable
  changed), `timer`, `scroll`, `enterViewport`... A trigger may be written as just its type: `"trigger": "click"`.
- Actions ({{page:actions.md|all}}) include `setVariable` (`op`: `set` (default), `toggle`, `add`, `subtract`,
  `insert`, `removeAt`...; `value` is an expression), `navigate`, `openModal`, `closeModal`, `showToast`,
  `openLink` (`url`), `if` (`condition`: a predicate; `then` and `else`: action lists), `delay` (`ms`),
  `scrollTo` (`node`), `setValue`, `submitForm`, `callApi`.
- In a chain `${result}` is what the previous action (first: the trigger's event) gave: for a text field's
  `changed`, its text.
- Every action also takes `enabled`, `nonBlocking` and `when` (a predicate: run only while it holds).

Write each action's fields flat in the action object, exactly as named in {{page:actions.md|actions}};
a misspelled key is dropped silently by the runtime and reported by validation (`unknown_action_key`).

<a id="guide-states"></a>
## 11. Hover, press and other states

`states` on a node changes it and its descendants while it is `hovered`, `pressed`, `focused`, `selected`,
`disabled` or `dragged`. Each state maps node ids (the node itself or nodes inside it) to a **patch**: partial node
JSON merged over that node (objects merge, other values replace, `null` removes).

`selected` and `disabled` follow bindings: `"bind": {"selected": "${= tab == 'pricing'}"}` puts the node in its
`selected` state. `hovered` needs a mouse: on touch screens it never happens, so do not hide anything behind it.

{{example:states}}

<a id="guide-scrolling"></a>
## 12. Scrolling

A screen scrolls only if something in it scrolls. Make the canvas's body column scroll:
`"props": {"scrollable": true}` with `{"fill": n}` width and height. Its children keep their sizes and the column
scrolls when they are taller than the screen. Without it, content past the bottom of the screen is cut off on a
device (the render command reports `offscreen`). Inside a scrolling column, a child cannot `fill` the scrolling
axis (there is no end to fill to). Rows scroll sideways with `"scrollable": true, "scrollDirection": "horizontal"`.

{{example:scrolling}}

<a id="guide-lists"></a>
## 13. Lists and repeated data

A `listView` (or `gridView`, `pageView`) repeats its **first child** once per item of its `data` binding:
`"bind": {"data": "${questions}"}`. Inside the repeated child, `${item}` is the item (`${item.title}`) and `${index}`
its position from 0. A list in a scrolling page sets `"scrollable": false` so it lays out every item at its full
height; `spacing` separates items. Items fill the list's width.

For cards in columns from one list, inside a scrolling page, use a `gridView` with `minCrossAxisExtent` (CSS
`repeat(auto-fit, minmax(280px, 1fr))`: as many equal columns as fit), `"shrinkWrapRows": true` (each row as tall
as its tallest card, the cards stretched to it: equal heights) and `"physics": "never"` (it lays out every item and
the page scrolls), as in [section 7](#guide-responsive). A `listView` with `"wrap": true` lays its items out at
their own sizes in runs along its `scrollDirection`: with the default `vertical` they flow top to bottom into
columns (`vertical_wrap`); set `"scrollDirection": "horizontal"` for chips side by side.

{{example:list}}

The same item template can carry reactions: a click on an item runs with that item's `item` and `index`.

<a id="guide-forms"></a>
## 14. Forms and inputs

Inputs are Material widgets: `textField`, `checkbox`, `switch`, `radio`, `slider`, `dropdown`,
`segmentedButton`, `datePicker`. Each reports its value through its `changed` trigger as `${result}`; store it in a
variable with `setVariable`. A text field's label and hint are in `props.decoration`
({{link:values.md#type-InputDecoration|InputDecoration}}: `labelText`, `hintText`, `helperText`, `filled`,
`fillColor`, `border`...).

Validate with variables: keep the values, set a `tried` flag on submit, and show error texts with `visible`
bindings (or bind `props.decoration.errorText`). The `validator` prop of a text field is declared but not applied
by the SDK, and `inputFormatter` only applies `{"type": "regex", "pattern": ..., "allow": true}`. An outlined
field (`"border": {"type": "outline", ...}`) needs `"contentPadding": [14, 16, 14, 16]` in its decoration to keep
its text off the border.

**A text field bound to a variable**: bind its `props.initialValue` to the variable (`"bind": {"props.initialValue": "${query}"}`).
That is a two-way binding, as a Flutter `TextEditingController` held in state: typing sets the variable (its
`changed` reaction also runs), and setting the variable elsewhere (a clear button, `--set`) changes the text, keeping
the caret. The render command types with `--type <id>=<text>`.

{{example:form}}

Buttons (`elevatedButton`, `filledButton`, `outlinedButton`, `textButton`) take `label` and `style`
({{link:values.md#type-ButtonStyle|ButtonStyle}}: `backgroundColor`, `foregroundColor`, `textStyle`, `shape`...).
Their label text is 12 px unless `style.textStyle.fontSize` says otherwise. Give buttons a fixed width: a hugging
button is only as wide as its label, without padding. For full control of a button's look, use a `row` with a
decoration, padding, a text child and a `click` reaction, as in [section 11](#guide-states).

<a id="guide-modals"></a>
## 15. Modals and toasts

`{"type": "openModal", "to": "<canvas id>"}` shows another canvas over the screen, at its design size
(`presentation`: `dialog`, `bottomSheet`, `fullScreen`...). Inside it, `{"type": "closeModal"}` closes it. The modal
canvas is a root like any screen; give it the size of the dialog.
`{"type": "showToast", "message": "Saved", "style": "success"}` shows a short message.
See the navigation example in [section 6](#guide-screens).

<a id="guide-images"></a>
## 16. Images, icons and fonts

- **Images** are image fills: `{"type": "image", "image": {"url": "...", "fit": "cover"}}` in `decoration.fills`
  of a box (give the box the image's size or an `aspectRatio`). The SDK loads `https://` URLs and `data:image/...`
  URLs. For drafts, the render command also reads a path relative to the document (`"assets/photo.png"`) and
  inlines it; a real publish needs the image uploaded and its URL. The render command does not fetch network
  images: it reports them (`image_network`) and leaves them blank.
- **Icons**: an `icon` node with `props.icon` set to a Material icon name (`"check_circle"`, `"menu"`,
  `"arrow_forward"`, `"north_east"`; any name at fonts.google.com/icons; `_outlined`, `_rounded`, `_sharp` suffixes
  pick the style) and `props.color`. An icon is written the same way everywhere: a text field's
  `decoration.prefixIcon` is `{"icon": "search", "size": 18}`. A name the renderer does not know draws nothing
  (`icon_not_drawn`).
- **Fonts**: `style.fontFamily` names a family (`"Inter"`), with `fontWeight` choosing the file. An app fetches
  Google Fonts by name. The render command uses font files from `--fonts <dir>` (read by their real family and
  weight) plus Roboto, and reports a family it does not have (`font_fallback`).

{{example:image}}

<a id="guide-checking"></a>
## 17. Checking your work

Decoding is lenient: a misspelled key, a value of the wrong shape or an unknown enum value is silently ignored or
replaced by its default. Never trust a document that has not been checked.

Run the render command from the SDK repository (`tool/render/README.md` there has the details):

```sh
tool/render/render.sh site/ --out shots/ --sizes 390x844,834x1112,1440x900 --full-page
```

It validates every document strictly, renders each screen with the SDK at each size, writes
`shots/<screen>@<w>x<h>.png` and `shots/diagnostics.json`, and prints one line per problem with a code, the
JSON pointer of the value (`/nodes/hero-title/props/style/fontSize`) or the node, and what to do. It exits 1 when
there are errors. Interactions before the capture, in order: `--tap <id>` (`<id>#<n>` for the n-th copy of a list
item; a node out of view or under an overlay is scrolled to the middle first, and a tap that would land on another
node is reported, not made), `--hover <id>`, `--focus <id>`, `--type <id>=<text>`, `--set <variable>=<json>`,
`--scroll <id or screen>=<px>`, `--navigate <canvas id>`, `--wait <ms>`. A step may name a node by its `name`
too: give the matching nodes of a screen's breakpoint canvases the same `name` and one step reaches whichever is
shown. `--label <name>` keeps the screenshots and `diagnostics-<name>.json` of each state apart. `--full-page`
captures the page's own scroll height, with content fixed to the window drawn in the first window.
Look at the screenshots: validation cannot tell you that a page is ugly.

<!-- guide-only -->
Validation codes (from `package:codelessly_api/validate.dart`):

{{diagnosticCodes}}
<!-- /guide-only -->
<!-- starter-only -->
The validation codes are listed in `index.md`, section 17.
<!-- /starter-only -->

The render step adds what only rendering shows: `render_exception` (naming the node), `action_error`,
`interaction_failed`, `tap_no_reaction`, `layout_overflow`, `offscreen`, `text_clipped`, `text_truncated`,
`text_no_color`, `missing_glyph`, `icon_not_drawn`, `expression_not_evaluated`, `path_overflow`, `font_fallback`,
`image_failed`, `image_network`, `empty_screen`, `invalid_json`; formulas are parsed by the SDK's own parser
there, so formula syntax errors and unknown names in formulas are reported only by the render command.

<a id="guide-pitfalls"></a>
## 18. Rules that are easy to get wrong

1. Every node needs `layout.width` and `layout.height`; without them it is 0 × 0.
2. Every text needs `style.color`; without it, it is white.
3. Padding and margin are a number or four numbers, never two.
4. Colors are `#AARRGGBB` or `#RRGGBB`.
5. Columns center their children across by default: write `"crossAxisAlignment": "start"` for left-aligned
   content.
6. A screen taller than the window needs a scrolling body column.
7. Values in `props`, `layout` and `decoration` are literal; expressions go in `bind` (except `props.text`).
8. `x`/`y` only work under a `stack`; `flex`/`align` only under a `row` or `column`.
9. Ids are map keys; a child is listed in exactly one parent; canvases are only in `roots`.
10. Per-breakpoint canvases have separate nodes: shared state lives in `page_variables`.
11. `fill` takes all the room it is given; cap it with `constraints.maxWidth`.
12. A backslash inside a formula is written twice in JSON: `"${= matches(code, '^\\d{4}$')}"`.
13. `${...}` reads a name; a literal value is a formula: `${= false}`, not `${false}`.
14. A node hidden by a binding, condition or media rule takes no room or slot; `"visible": false` written on the
    node with nothing to show it keeps its room.
15. A `path` (and a box's `path`) is drawn in its box's own pixels from the top left and is not clipped to the box
    (as Flutter's `CustomPaint`): give a `path` node a `viewBox` to scale it, or clip an ancestor.
16. A `spacer` takes the free space only in a row or column with room to spare (a `fill` or fixed main size).
17. Where CSS and Flutter differ, the model follows Flutter, except where it says so: rows and columns shrink
    children that do not fit toward their content (`squeezeChildren`, default true, as CSS flex items shrink; false
    is Flutter's overflow); `basis`, `order` and `minCrossAxisExtent` are CSS's; a negative margin is not CSS's.
18. Repeated content from data: a `gridView` with `minCrossAxisExtent` for columns, a `listView` for a list; a
    wrapping `listView` runs along its `scrollDirection`.
