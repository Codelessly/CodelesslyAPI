# Responsive layout

## When to use

Sizes, rows and columns, stacks, scrolling and screen sizes beyond the base: every layout field, which sizing
modes each parent allows, media rules and breakpoints, and the web layouts agents ask for (a capped band, cards that
wrap, a row that becomes a column, overlap and bleed, a sticky header or column).

## Minimal example

The text hugs its content, the red box fills the column's width, and in the row the green and blue boxes share the
free space 1 : 2 (`flex`) beside a fixed grey box.

{{example:sizing}}

## Reference

### Layout fields

A node's `"layout"`: its size, spacing and placement in its parent. `width` and `height` are an
[AxisSize](@type-AxisSize): a number (fixed) or `{"fill" | "hug" | "flexible" | "fixed": number}`; `x` and `y` an
[AxisPosition](@type-AxisPosition).

{{layoutFields}}

### Which sizing modes each parent allows

From the parents' own rules; "fill (with `basis`)": a child of a wrapping row may fill its line's share when it sets
`layout.basis`.

{{childFits}}

Why a mode is not allowed, as the declarations say it:

{{childFitReasons}}

### Media rules

A node's `media` (and the theme's) is a list of rules, each a CSS media query over the node:

{{mediaRuleFields}}

### Breakpoints

The project's breakpoints name size classes by minimum width. Unless a document's `breakpoints` key says otherwise
they are:

{{breakpointDefaults}}

A breakpoint's fields:

{{breakpointFields}}

{{reference}}

## Patterns

### Responsive design

Responsive layout works as on the web: flexbox and grid lay content out so it fits any width, and media queries
change what must change at a width. Use these, in this order:

1. **Intrinsic layout, no breakpoints.** A wrapping row whose children set `layout.basis` and fill the main axis:
   lines break by the basis and the children on each line grow to share it. For repeated data, a `gridView` with
   `minCrossAxisExtent` makes as many equal columns as fit. A share of the parent (CSS `width: 60%`) is
   `layout.widthFactor: 0.6`.
2. **Media rules** for what must change at a width: direction, order, visibility, type size, padding. A rule's
   `patch` is merged over the node (objects merge, `null` removes a key), except that a value with several forms is
   **replaced**, as CSS replaces a declaration: `{"width": {"hug": 200}}` over `{"fill": 292}` is `{"hug": 200}`.
   Rules apply in order, a later one winning (the cascade). Validation checks every patched value and judges sizes
   at each range of widths with the rules that hold there.
3. **Bindings on `${screen}`** for values computed from the size: `"bind": {"layout.width": "${= min(screen.width -
   32, 760)}"}`. `${screen}` has `width`, `height`, `breakpoint`, `is.<name>`, `atLeast.<name>`
   (`${= screen.atLeast.tablet ? 3 : 1}`). Nothing can check such a formula's result: prefer media rules.
4. **A canvas per breakpoint**, only for screens that are genuinely different designs (below).

Precedence: the node's own values, then its media rules, then an active interaction state's patch, then its
bindings, then conditions.

This page uses the four web patterns: a header whose links collapse to a menu icon below desktop, a 3 → 2 → 1 card
grid from data (`minCrossAxisExtent`), a text-and-photo section that stacks with the photo first on phones (`basis`
in a wrapping row, the photo's `order` patched), and a title whose size steps up with the width, inside a content
column capped at 1200:

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

### A capped band

A full-width band with capped, centered content (CSS `max-width: 1200px; margin: 0 auto` inside a coloured band):
the band fills the width and holds the background; its one child fills with `constraints.maxWidth`, centered by the
band's `crossAxisAlignment` (`center`, the default). Under `crossAxisAlignment: stretch` a cap holds too, as CSS
`max-width` does: the child sits at the start, or where its `layout.align` puts it (`[0, 0]` centers it). Below, a
comparison table built from one row template and one cell template:

{{example:band}}

Across a row or column, a child's width comes out as:

| Parent's `crossAxisAlignment` | child `fill` | child `hug` | child fixed `n` |
|---|---|---|---|
| `start`, `center`, `end` | the parent's inner width, at most its `maxWidth`, placed by the alignment | its content, at most `maxWidth` | `n`, clamped by its constraints |
| `stretch` | the parent's inner width, at most its `maxWidth` (then at the start, or at its `align`) | its content, at the start | the parent's inner width, at most its `maxWidth` |

### Cards that wrap

Three plan cards three across at desktop, two at tablet, one on phones, with no breakpoint: a wrapping `row`
(`"wrap": true`, `spacing`, `runSpacing`) whose cards are `"width": {"fill": 300}, "basis": 280`. With
`crossAxisAlignment: stretch` the cards of each line are as tall as its tallest (CSS `align-items: stretch`: equal
heights). From data, use a `gridView` with `minCrossAxisExtent` and `shrinkWrapRows` instead
([equal-height cards](@lists-equal-height-cards)).

### A row that becomes a column

A `flex` node with `"direction": "horizontal"` and a rule patching `"direction": "vertical"` below a width. Its
children stay the same nodes, keeping their state. Another order at a width: each child's `layout.order`, patched in
the child's own rule (`{"maxWidth": "mobile", "patch": {"layout": {"order": -1}}}` puts it first). Hidden at a
width: `{"maxWidth": "tablet", "patch": {"visible": false}}`; a hidden node takes no room.

```json
"split": {"type": "flex", "children": ["copy", "photo"], "props": {"direction": "horizontal", "spacing": 32},
          "layout": {"width": {"fill": 1200}, "height": {"hug": 400}},
          "media": [{"maxWidth": 599, "patch": {"props": {"direction": "vertical"}}}]}
```

### A media rule and a binding on one field

Shown on phones only, and there only while a panel is closed: a patch may set `bind`, bindings that hold at its
sizes only. Write the node for the other sizes and bind in the rule: `"visible": false, "media": [{"maxWidth": 599,
"patch": {"bind": {"visible": "${= !filtersOpen}"}}}]`. The breakpoint stays in the media rule. To show a patched
value where the node binds the field at other sizes, drop the binding in the rule: `"patch": {"visible": true,
"bind": {"visible": null}}`.

### Overlap and bleed

**Overlapping a neighbour** (CSS `margin-top: -36px`, `transform: translateY(-36px)`): Flutter's answer is
`Transform.translate`: `"motion": {"translateY": -36}` moves what the node paints, not its layout, so the next node
does not move up; a node later in its parent paints over the ones before it. A media rule may patch it. A card
overlapping the bottom of a hero band: the card after the hero with `translateY: -36`, and 36 px of `margin` below it
if the next section should keep its distance. To overlap by an amount that depends on the content, use a `stack`.

**Bleeding past the gutter** (a table or photo running to the screen's edge while the text keeps its padding): put
the padding on the children, not on the band, or let the one child that bleeds translate out of it (`"motion":
{"translateX": 18}` with a width 18 larger), and keep the band's `"decoration": {"clip": "none"}` (the default). A
photo frame that overhangs its photo: a `stack` with a fixed or fill size holding the frame at a negative `x`/`y`.

### Scrolling

A screen scrolls only if something in it scrolls. Make the canvas's body column scroll: `"props": {"scrollable":
true}` with `{"fill": n}` width and height. Without it, content past the bottom of the screen is cut off
(`offscreen`). Inside a scrolling column, a child cannot `fill` the scrolling axis. Rows scroll sideways with
`"scrollable": true, "scrollDirection": "horizontal"`. `scrollTo` reveals a node (`"node"`: an id, or an expression
giving one; `"axis": "horizontal"` moves only sideways scroll views).

{{example:scrolling}}

### A sticky header or column

A header that stays at the top while the page scrolls under it: the scrolling column's first child with
`"sticky": {"offset": 0}` (CSS `position: sticky`); it is drawn above the content and is pushed on by the end of
its parent. `${sticky.stuck}` is true while it is pinned (bind a shadow or a smaller height to it). A header
fixed to the window instead (it never scrolls): a `stack` filling the canvas body, the scrolling column first and
the header after it at `"y": 0`.

A comparison table with a **sticky first column** on phones is two parts side by side: a fixed column of row
labels, and a row of plan columns that scrolls sideways (made to scroll only on phones by a media rule on its
`scrollable`); give each table row the same height in both. From data: [a table from one template](@lists-a-table-from-one-template).

### A canvas per breakpoint

Canvases with the same `props.screen` are one screen; each sets `props.breakpoint` to the breakpoint it is for. At
a given width the screen shows the canvas whose breakpoint's `minWidth` is the highest at or below the width, else
its narrowest. Each canvas has its own nodes; share state with `page_variables`. A `variance` node does the same for
one part of a screen. Older documents use this:

{{example:responsive}}

{{example:variance}}

## Pitfalls

- `fill` takes all the room it is given: cap it with `constraints.maxWidth`. Where its parent gives no room on that
  axis (it hugs it, or scrolls), a fill is its design number (`fill_fallback`, naming the parent).
- `x`/`y` mean nothing under a row or column, `flex`/`align` nothing under a stack (`layout_field_ignored`).
- A stack that hugs its children grows to hold them, so there a negative offset is 0 (`layout_clamped`). A
  negative margin does not overlap a neighbour (`layout_clamped`): translate with `motion`.
- A media patch replaces a size of another mode: `{"hug": 200}` over `{"fill": 292}` is `{"hug": 200}`. A field
  both patched and bound shows the binding (`media_overridden`): bind in the rule instead.
- `squeezeChildren` (default true) shrinks children that do not fit toward their content, as CSS flex items
  shrink; false is Flutter's overflow (`layout_overflow`).
- A `spacer` takes the free space only in a row or column with room to spare.
- Without `basis`, children of a wrapping row keep their own size.
- `${screen.width}` prints a decimal (`390.0`); `${= screen.width}` prints `390`.

## See also

[The base](STARTER.md) (sizes, rows, stacks in short) · [lists and grids](@page-lists) · [scroll-driven
animation](@page-animation) · [the render command](@page-render) (sizes, `--scroll`, `--full-page`).
