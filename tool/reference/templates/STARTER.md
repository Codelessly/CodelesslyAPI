# Codelessly starter: the core set

This is the small core of the Codelessly data model: the document, the core node types every layout is built
from, and how to make a page responsive. They correspond to Flutter's basic widgets:

| Node type | Flutter |
|---|---|
| `canvas` | a screen (`Scaffold`: `body`, `appBar`, `bottomNavigationBar`, `floatingActionButton` slots) |
| `row`, `column` | `Row`, `Column` (they also carry their own padding and decoration, like a `Container` around them) |
| `flex` | `Flex`, the widget `Row` and `Column` extend: its `direction` can change at a width |
| `stack` | `Stack` with `Positioned` / `Align` children |
| `box` | a `Container` with no child (a shape, a divider, an image) |
| `text` | `Text` / `Text.rich` |
| `icon` | `Icon` |
| `spacer` | `Spacer` (with no size) / `SizedBox` (with one) |

Single-child wrapper widgets are fields on the node they would wrap: `Padding`, `SizedBox`, `Expanded`,
`Flexible`, `Positioned`, `Align`, `ConstrainedBox`, `AspectRatio` and `FractionallySizedBox` are in the node's
`layout`; `DecoratedBox`, `ClipRRect` and shadows are in its `decoration`; `Opacity` and `Visibility` are `opacity`
and `visible`.

Start with what is on this page. Everything else is in the full reference, in the same folder as this file:

{{starterFiles}}

{{guide:guide-document}}

## Nodes, ids and children

`nodes` maps each node's **id** (the map key; do not repeat it inside the node) to the node. A parent lists its
children's ids in `children` (or, for a canvas, in `slots`); a child does not name its parent. Every node except a
canvas has exactly one parent; `roots` lists the canvases. Keep ids unique across a site's documents: the render
command and actions name nodes by id. A node's keys:

{{nodeKeys}}

{{guide:guide-layout}}

{{guide:guide-decoration}}

{{guide:guide-text}}

{{guide:guide-responsive}}

{{guide:guide-variables}}

## Split a page into components

A page longer than a screen or two is easier to write, fix and reuse as parts, each in its own file: a
**component** is a document with one root (not a canvas) and a `widget` declaration of its parameters
(`"props": [{"key": "price", "type": {"kind": "number"}, "default": 0}]`), slots and events, read inside as
`${props.price}`; a page **calls** it with one node of that type (`{"type": "PlanCard", "props": {"price": 47},
"layout": {...}}`), exactly as Flutter builds `PlanCard(price: 47)`. A component never reads its page's variables:
pass what it needs as parameters, and state it shares with the page as a `variable` parameter (the page's
variable's name: `"props": {"menuOpen": "menuOpen"}`). A directory with `site.json` (pages, components, the
project's shared variables) is a site; `render.sh site --component PlanCard` renders one part alone, and steps
name nodes inside parts by path (`--tap plans/card1/cta`).

* **List template**: one shape repeated from data in one parent; when it is more than about five nodes, make the
  template one call (`"bind": {"props.plan": "${item}"}`).
* **Component**: the same structure in two or more places with different values (a card, a chip, a row).
* **Section**: a top-level band of a page (header, hero, pricing, FAQ, footer), in its own file when it is more
  than about 15 nodes or someone will edit it alone, even if it is used once.

The whole story, with a complete example: {{page:index.md|the guide}}, §19 "Sections and components".

# The core node types

{{coreNodes}}

{{guide:guide-checking}}

{{guide:guide-pitfalls}}
