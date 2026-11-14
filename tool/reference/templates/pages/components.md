# Components and sections

## When to use

Splitting a page into parts, each a file: a component used in several places with different values (a card, a
chip, a row), a section used once (a header, a hero, an FAQ), their parameters (every kind, `variable` included),
slots and events, the site manifest, and when to use a component, a list template or a section.

## Minimal example

A definition (`components/Chip.json`; the file is named after the type):

```json
{"schema": 3, "id": "Chip", "roots": ["chip"],
 "widget": {"type": "Chip", "doc": "A label with a remove button.", "children": "list", "slots": ["leading"],
   "props": [
     {"key": "label", "type": {"kind": "string", "flutter": "String"}, "default": "Chip", "required": true},
     {"key": "selected", "type": {"kind": "variable", "of": {"kind": "boolean", "flutter": "bool"}}, "default": ""}],
   "events": [{"key": "onRemove", "payload": {"kind": "string", "flutter": "String"}}]},
 "variables": {"chip": [{"name": "hovered", "type": "boolean", "value": false}]},
 "previews": [{"name": "Selected", "size": [240, 48], "props": {"label": "Design", "selected": true}}],
 "nodes": {
  "chip": {"type": "row", "children": ["lead", "text", "extra", "remove"], "props": {"spacing": 6},
           "layout": {"width": {"hug": 120}, "height": 36, "padding": [12, 0, 8, 0]},
           "decoration": {"fills": [{"color": "#FFE8EAF6"}], "radius": 18},
           "bind": {"decoration.fills[0].color": "${= props.selected ? '#FF3F51B5' : '#FFE8EAF6'}"},
           "actions": [{"trigger": {"type": "click"},
                        "actions": [{"type": "setVariable", "variable": "props.selected", "op": "toggle"}]}]},
  "lead": {"type": "slot", "props": {"name": "leading"}},
  "text": {"type": "text", "props": {"text": "${props.label}", "style": {"fontSize": 14, "color": "#FF1A237E"}},
           "layout": {"width": {"hug": 60}, "height": {"hug": 20}},
           "bind": {"props.style.color": "${= props.selected ? '#FFFFFFFF' : '#FF1A237E'}"}},
  "extra": {"type": "slot"},
  "remove": {"type": "icon", "props": {"icon": "close", "color": "#FF5C6BC0"},
             "layout": {"width": 20, "height": 20},
             "actions": [{"trigger": {"type": "click"},
                          "actions": [{"type": "componentEvent", "event": "onRemove", "value": "${props.label}"}]}]}
 }}
```

And calls to it, in a page's `nodes` (the page declares `tag` and `removed`):

```json
"nodes": {
  "design": {"type": "Chip", "props": {"label": "Design", "selected": "tag"},
             "slots": {"leading": "dot"}, "layout": {"width": {"hug": 120}, "height": 36},
             "actions": [{"trigger": {"type": "event", "event": "onRemove"},
                          "actions": [{"type": "setVariable", "variable": "removed", "value": "${result}"}]}]},
  "dot": {"type": "box", "layout": {"width": 8, "height": 8}, "decoration": {"fills": [{"color": "#FF4CAF50"}], "radius": 4}},
  "tags": {"type": "listView", "children": ["tagChip"], "bind": {"data": "${tags}"},
           "props": {"scrollDirection": "horizontal", "spacing": 8}, "layout": {"width": {"fill": 360}, "height": 36}},
  "tagChip": {"type": "Chip", "bind": {"props.label": "${item.name}"}, "layout": {"width": {"hug": 120}, "height": {"fill": 36}}}
}
```

## Reference

### Parameter kinds

Declared in `widget.props` as the catalog declares any prop: `key`, `type` (`kind` and the
Flutter type; `min`, `max`, enum `values`, list `item`), `default`, `doc`, and `"required": true` for one a call
must set. The kinds: `boolean` (`bool`), `integer` (`int`), `number` (`double`), `string` (`String`),
`enumeration` (with `values`), `value` (a value type: `{"kind": "value", "flutter": "Color"}`, also `EdgeInsets`,
`Alignment`, `IconData`...), `list` (with `item`), `object` (a model: `TextStyle`, `Paint`), `json` (any data: a
record, `{"kind": "json", "flutter": "Map<String, dynamic>"}`) and `variable` (with `of`, below). Inside, read them as `${props.<key>}`. A call sets them as any node's props: a literal in `props`, an
expression in `bind` (`"props.label": "${item.name}"`). Validation checks every call against the declaration:
unknown keys, wrong types and bounds, missing required ones, children and slots the component does not take.

### The site manifest

A directory with a `site.json` is a site: its pages, its components and its project variables, read by
bare name in every page and component (a page or component variable of the same name is `duplicate_variable`).

```json
{"schema": 3, "pages": ["pages/home.json"], "components": ["components/Chip.json"],
 "variables": [{"name": "tags", "type": "list", "value": [{"name": "Design"}, {"name": "Code"}]}]}
```

Without `components`, the files under `components/` are the site's components.

### Validation codes

`unknown_component` (a call to a type no definition declares),
`duplicate_component`, `component_cycle` (a component calling itself, directly or through others),
`component_id_mismatch` (the file is not named after its type), `invalid_component`, `missing_prop`,
`unknown_event`, `call_field_not_allowed`, `slot_outside_component`, `root_placement_bound`. The render command
adds `component_missing` (a call rendered without its definition: an empty box of its size).

{{reference}}

## Patterns

### Components are Flutter widget classes

A page can be split into parts, each in a file of its own: a **component** is a document with one root (not a
canvas) and a `widget` declaration, and a page (or another component) **calls** it with one node whose `type` is
the component's type. A **section** is a component used once. The declaration is the widget's constructor; a
call is `PlanCard(price: 47, ...)`.

| Here | Flutter |
|---|---|
| a component document | a `StatelessWidget` / `StatefulWidget` class, in its own file |
| `widget.props` (parameters) | the constructor's named parameters, with types and defaults |
| a call `{"type": "PlanCard", "props": {...}}` | `PlanCard(...)` in a parent's `build` |
| `${props.price}` in the definition | `widget.price` |
| the definition's own `variables` (one set per instance) | the `State`'s fields |
| a `slot` node, the call's `children` / `slots` | `child`, `children`, `Widget title` parameters, placed in `build` |
| `widget.events`, `componentEvent`, the call's `event` reaction | a `ValueChanged<T>` / `VoidCallback` parameter (`onChanged`) |
| a `variable` parameter | a `ValueNotifier<T>` passed in |
| `site.json` | the app's `lib/`: its pages and its globals |

### A complete multi-page site

A site of two pages, a modal, a header and a footer shared by reference, written in the order that avoids
`unknown_screen` errors: **the manifest first, every page listed**, then the components, then the pages. The trip
page reads its route parameter (`${route.id}`, from `navigate.params` or a link `trip?id=coast`); the saved list is
restored from storage when the home page loads; the packing list is kept per trip under a key built from the route.

`site.json`:

{{example:site/site}}

`components/Header.json` (its About link opens the modal `about`, a canvas of `pages/home.json`; canvas ids are
site-wide, so any page or component may open it):

{{example:site/components/Header}}

`components/Footer.json`:

{{example:site/components/Footer}}

`pages/home.json`: restores `saved` on `load`, lists the trips from the project variable, links each to `trip`
with its id, and holds the `about` modal canvas:

{{example:site/pages/home}}

`pages/trip.json`: the trip named by `${route.id}` (the first one when the screen opens without it), a Save button
that writes the saved list back to storage, and a packing checklist per trip (`setStorage` key
`packed.${route.id}`, read with `get(storage.packed, route.id)`):

{{example:site/pages/trip}}

Node ids are per document: both pages have `page`, `header`, `main` and `footer`, and each component its own ids.
Render it and check each state: `--tap tripCard#1 --tap packRow#0 --tap save --label saved`; `--navigate
trip?id=coast`; `--tap header/about --label about` (a node in a component instance by its call's id).

### When to make what

* **List template**: one shape repeated from data in one parent. When the item is more than about five nodes, or
  appears elsewhere too, make the template one call node (`"bind": {"props.plan": "${item}"}`).
* **Component**: the same structure in two or more places with different values (buttons, cards, chips, rows),
  or a part others will reuse. Data comes in as parameters. Four near-identical columns of a table, or three plan
  cards, are one component (or one list template) called four or three times, not four copies.
* **Section**: a top-level band of a page (header, hero, plans, FAQ, footer), in its own file when it is more
  than about 15 nodes or someone will edit it alone, even if it is used once. Parameters only for what it shares
  with its page (`variable` parameters for state both change).

### What a definition reads

Its parameters (`props`), its own variables (one set per instance: two chips are
hovered apart), the project's variables (`site.json`, below) and the runtime's scopes (`screen`, `route`,
`theme`, `auth`...); inside its own lists, `item` and `index`. **Never the caller's variables**: the same chip works
on any page. What a section needs from its page comes in as a parameter.

### Computed values inside a definition

A definition's own variables may be computed from its parameters: `{"name": "over", "type": "boolean", "formula":
"props.seats > props.limit"}` under the root's id in its `variables`, then `${over}` in any of its nodes. One rule,
read by five nodes, written once.

### Shared state: variable parameters

share state with the caller: `{"kind": "variable", "of": {"kind": "boolean"}}`. The
call passes the *name* of one of its variables (`"selected": "tag"`); inside, `${props.selected}` reads it live and
`setVariable "props.selected"` writes it. A header and a menu both taking `"menuOpen": "menuOpen"` open and close
the page's one menu.

### Slots

A `slot` node in the definition is replaced by what the call passes: the call's `children` for the
slot named `children` (the default name; declare `"children": "list"`), or the call's `slots[name]` for a named
slot (declare it in `widget.slots`). With nothing passed, the slot shows its own children. What is passed belongs
to the caller: it is stored in the page and reads the page's variables.

### Events

Declared in `widget.events`; fired inside with `{"type": "componentEvent", "event": "onRemove",
"value": ...}`; handled by the call's reaction `{"trigger": {"type": "event", "event": "onRemove"}}`, which runs in
the caller's scope with the value as `${result}`. An event nobody handles does nothing.

### Size and place

The call and the definition's root are one box: the call's `layout` sizes and places it
(width, height, flex, margin, x/y, align, constraints); the root keeps its padding, decoration and contents. A call
has no `decoration` and no `layout.padding`. The root's own size is the design size its previews and new calls
use. `visible` hides the instance when either the call or the root is hidden. The root's own placement (its
`margin`, `flex`, `align`, `x`/`y`, bound or patched) is not read: place the instance from the call (a margin that
depends on a parameter is bound on the call, `"bind": {"layout.margin": "${= item.popular ? [0, 0, 0, 0] : [0, 28,
0, 0]}"}`).

### Ids and paths

A definition's ids are its own (`text`, `remove`); a page may use the same ids, and
diagnostics name a node of an instance by its path, so the two never mix. An action inside a definition that names
a node (`scrollTo`, `animate`, `focus`) acts on that node of its own instance: two cards each scroll their own
list. Tools name a
node inside an instance by its **path**: the call ids from the page down, then the node's id
(`design/remove`, `plans/card1/cta`); `#n` picks the n-th copy a list repeats (`tagChip#2/text`).

### Rendering one part

`tool/render/render.sh site --out out --component Chip` renders the component alone, once
per preview at its size; `--props '{"label": "Long label"}'` renders one parameter set at each size, and
`--slots fixture.json` (`{"children": [ids], "slots": {"leading": id}, "nodes": {...}}`) passes slot content.
Steps take paths: `--tap design/remove`.

`--components-all` renders every component of the site that way in one run (`<Type>-<preview>@<w>x<h>.png`):
the quickest look at every part a page can call.

### Per instance

Everything a definition keeps is kept per instance, as a Flutter `State` is: its variables, its
interaction states, the values a `setValue` (or `setVariant`) sets on its nodes (set inside an instance, they change
that instance's node only). A variable with `"persist": true` is kept per instance path
(`codelessly.component.<Type>.<path>.<name>` in the app's storage). When an instance leaves the screen (a list
item scrolled away, data that shrank), what it kept goes with it, as a `State` is disposed; shown again, it starts
afresh (a persisted variable from its stored value).

### Published components

A published site carries its components beside its pages (each at
`publish/{project}/components/{Type}`, with a version and a digest; a bundle holds them in its `components` map),
and an app loads the ones a screen calls with the screen, caches them, and follows a republished one: every
instance updates where it is, without reloading the pages that call it. Nothing to write in the app: a
`CodelesslyWidget` showing a published site with components just works. A call whose component can't be loaded
is an empty box of its size until it arrives (`component_missing` in the app's error log).

## Pitfalls

- A definition never reads its caller's variables: pass values as parameters, shared state as a `variable`
  parameter.
- A slot inside a list of the definition shows what the call passes once per item, built in the caller's scope:
  it reads the caller's variables, not the item. To show the item, make it a parameter of a component the list
  calls.
- A call has no `decoration` and no `layout.padding` (`call_field_not_allowed`): style the definition's root.
- The file is named after the type (`component_id_mismatch`).
- `repeated_subtree` (an INFO) means the same subtree of three or more nodes is written several times over: make
  it a component or a list template.

## See also

[Lists](@page-lists) (a list template calling a component) · [state](@page-state) · [the render
command](@page-render) (`--component`, `--components-all`) · [publish](@page-publish).
