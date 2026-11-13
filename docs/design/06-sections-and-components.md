# 06 · Sections, nested documents and components by reference

Status: proposal. Line references are to this worktree, to
`CodelesslySDK/lib/src/...` and to `CodelesslyEditor/lib/...` as read on
2026-11-13.

The owner's request: "A Milestone 2 but we need to solve now due to
architecture, is that a page can actually be broken into it's smaller
sections. So we can have data nesting, and data components reused."

## 1. Problem

**A page is one flat document, and reuse is by copy.**

* A `LayoutDocument` is `roots` plus one flat `nodes` map, with variables,
  conditions and scripts per canvas in `extra` (`document.dart:16-38`,
  `logic.dart:21-37`). Nothing in it can point at another document's nodes.
* A project component's instance **is a copy**: the definition's nodes,
  given fresh ids, under a top node that carries a `ComponentLink`
  (`components.dart:1-10, 37-62`). What an instance may change is a list
  of `ComponentSetting`s whose targets are node + binding path pairs that
  must be remapped on every copy (`components.dart:86-87, 254-267`).
  Updating an instance deletes its nodes and re-instantiates them with new
  ids, re-reading each setting from its *first* target only; any other
  edit is lost (`CodelesslyEditor/lib/editor/components.dart:274-320`).
* A managed instance is a snapshot built by `buildManagedInstance` (ids
  `topId__nodeId`, values written to targets, theme tokens **substituted as
  constants**, slots grafted, events spliced; `managed_components.dart:791,
  821-938`). Its contract's variables go on the page's canvas
  (`:388-390`), so two instances share them.
* A hosted plugin node type is already a component by reference: one node
  in the page, a node tree with `${props.*}` in scope
  (`plugins.dart:194-213`). But the SDK renders it as an island: its own
  `NodeTree`, `VariableScope` and element subtree per node, sized by a
  fixed-size fit box, with slots and events not wired
  (`CodelesslySDK/lib/src/features/hosted/hosted.dart:67-109`; doc 05
  "Not done").

Three mechanisms (copy, snapshot, island), and none splits a page into
parts stored and edited on their own.

**Measured cost** (the six m05 authoring runs; method in §9.4):

| Page | Canvases | Nodes | Pretty bytes | Minified bytes | ≈ tokens | Redundant byte-identical nodes |
|---|---|---|---|---|---|---|
| Casa Brasa menu, c1/A | 1 | 202 | 67,183 | 57,435 | 16.4k | 20 (10%) |
| Casa Brasa menu, c1/B | 1 | 254 | 75,144 | 67,602 | 19.3k | 43 (17%) |
| Casa Brasa menu, c1p/B | 3 | 466 | 183,403 | 116,651 | 33.3k | 125 (27%) |
| Relay pricing, c1/A | 1 | 253 | 112,580 | 73,839 | 21.1k | 43 (17%) |
| Relay pricing, c1/B | 1 | 189 | 80,216 | 51,349 | 14.7k | 9 (5%) |
| Relay pricing, c1p/B | 1 | 293 | 117,279 | 76,081 | 21.7k | 33 (11%) |

Byte-identical copies understate it: Relay c1/A's three plan cards (84
nodes, a third of the page) differ only by an index and were stamped out by
a generator (`saas-landing-A/src/build.py`, friction #1). Relay's six
reference pages share header, drawer and footer
(`reference/saas-landing/SPEC.md:7-18`); each would carry a copy. An agent
fixing one card rewrites a 74 KB document.

## 2. Flutter grounding

| Construct here | Flutter spelling |
|---|---|
| component definition | a `StatelessWidget` / `StatefulWidget` class |
| its `widget` declaration (`props`) | the constructor's named parameters, types, defaults |
| call node `{"type": "PlanCard", "props": {...}}` | `PlanCard(popular: true, ...)` |
| `${props.price}` inside the definition | `widget.price` / a `build` parameter |
| local `variables` (per instance) | `State` fields |
| `children` / named slots, `slot` node | `child`, `children`, `Widget leading` parameters, placed in `build` |
| events, `componentEvent` | `VoidCallback` / `ValueChanged<T>` parameters (`onChanged`) |
| `variable` parameter | a `ValueNotifier<T>` (controller) passed in |
| a section | a widget class used once, in its own file (`hero_section.dart`) |
| `previews` | `@Preview(name:, size:)` (`flutter/lib/src/widget_previews/widget_previews.dart:68-127`) |
| site manifest | `lib/` of an app: the `pubspec`, `main.dart`'s routes and globals |

## 3. The decisions in one place

1. **One unit: a component is a document.** A section is a component used
   once. There is no third kind; the difference between a section and a
   reusable component is an authoring rule (§8.4).
2. **A call is one node whose `type` is the component's id**, exactly as a
   plugin node is (`{"type": "codelessly.sparkline"}`). Its `props` are the
   declared parameters; its `children`/`slots` fill the declared slots; its
   reactions with an `event` trigger handle the declared events.
3. **Ids are local to their document.** Nothing stored refers to a node in
   another document. The SDK keys an instance's boxes by
   `(nodeId, ComponentInstance(outer, callId))`, the scheme list items
   already use. Tools address nodes across the boundary by a **path** of
   ids, `plans/card1/cta`.
4. **A definition sees only** its parameters (`${props.x}`), its own
   variables (one set per instance), project variables and the runtime's
   ambient scopes (`screen`, `route`, `theme`, `auth`, `storage`, ...). It
   never sees the caller's variables. Shared page state crosses as a
   `variable` parameter.
5. **No overrides.** An instance changes what the definition declares as
   parameters and slots, nothing else. Detaching makes a copy.
6. **One mechanism, three distribution scopes**: document (`components` in
   a document), project (one file per definition), hosted (a plugin
   package, versioned on the managed machinery).
7. **Instances are ordinary boxes in the one render tree**, not islands.

## 4. Sections: a page composed of documents

### 4.1 The unit

Of the three candidates, a component document wins:

| Candidate | Independently loadable/editable | Validated alone | Reused across pages | Verdict |
|---|---|---|---|---|
| A root in a multi-root document | no: one file, one write | no | no | rejected |
| A fragment sharing the page's scope | yes | no: it reads names only the page declares | only with the same page variables | rejected |
| A component document | yes | yes, with its declared parameters and previews | yes | **chosen** |

It is a `LayoutDocument` with one non-canvas root, a `widget`
declaration and optional `variables`, `conditions`, `scripts`, `previews`:
today's `ComponentDefinition.document` (`components.dart:321-323`) with the
contract moved from `ComponentLink.settings` into the document.

### 4.2 The page and the call node

```json
{"schema": 2, "id": "pricing", "roots": ["pricing"],
 "variables": {"pricing": [{"name": "annual", "type": "boolean", "value": false},
                           {"name": "menuOpen", "type": "boolean", "value": false}]},
 "nodes": {
  "pricing": {"type": "canvas", "name": "Pricing", "path": "pricing", "slots": {"body": "root"},
              "layout": {"width": 1440, "height": 900}, "decoration": {"fills": [{"color": "#FF080D0E"}]}},
  "root":    {"type": "stack", "children": ["page", "drawer", "header"],
              "layout": {"width": {"fill": 1440}, "height": {"fill": 900}}},
  "page":    {"type": "column", "children": ["hero", "plans", "compare", "faq", "cta", "footer"],
              "layout": {"width": {"fill": 1440}, "height": {"fill": 900}, "x": {"start": 0, "end": 0},
                         "y": {"start": 0, "end": 0}, "padding": [0, 92, 0, 0]},
              "props": {"scrollable": true, "crossAxisAlignment": "stretch"},
              "bind": {"layout.padding": "${= [0, rv(92, 72, 72), 0, 0]}"}},
  "hero":    {"type": "PricingHero", "layout": {"width": {"fill": 1440}, "height": {"hug": 640}},
              "props": {"annual": "annual"}},
  "plans":   {"type": "PlansSection", "layout": {"width": {"fill": 1440}, "height": {"hug": 1200}},
              "bind": {"props.annual": "${annual}"}},
  "compare": {"type": "CompareSection", "layout": {"width": {"fill": 1440}, "height": {"hug": 1300}}},
  "faq":     {"type": "FaqSection", "layout": {"width": {"fill": 1440}, "height": {"hug": 800}}},
  "cta":     {"type": "FinalCta", "layout": {"width": {"fill": 1440}, "height": {"hug": 700}}},
  "footer":  {"type": "SiteFooter", "layout": {"width": {"fill": 1440}, "height": {"hug": 420}}},
  "drawer":  {"type": "MobileDrawer", "props": {"menuOpen": "menuOpen"},
              "layout": {"width": {"fill": 1440}, "height": {"fill": 900}, "x": {"start": 0, "end": 0}, "y": {"start": 0, "end": 0}},
              "bind": {"visible": "${= menuOpen && !screen.isDesktop}"}},
  "header":  {"type": "SiteHeader", "props": {"menuOpen": "menuOpen"},
              "layout": {"width": {"fill": 1440}, "height": 92, "x": {"start": 0, "end": 0}, "y": {"start": 0}},
              "bind": {"layout.height": "${= rv(92, 72, 72)}"}}
 }}
```

This is the measured Relay c1/A rewrite (§9), 1,788 bytes minified.

A call node carries `type`, `name`, `key`, `layout` (size and placement,
§4.5), `visible`, `opacity`, `props`, `children`, `slots`, `bind`,
`actions` (pointer triggers act on the root box; `event` triggers handle
events) and behaviors (over the root's own, key by key). Not `decoration`
or `layout.padding`: the inside belongs to the definition
(`call_field_not_allowed`).

**Type names.** A component's id is its node type: UpperCamelCase like a
Dart class (`PlanCard`), unique in the project; core types stay
lowerCamelCase (`row`), plugins `vendor.name` (doc 05 §4). The display
`name` changes freely; renaming the id is a refactor, as renaming a Dart
class is. The editor derives the id from the name at creation.

**Resolution**: the document's `components`, the project's, then the
catalog (plugins). One id in two scopes is `duplicate_component`: no
shadowing.

### 4.3 Ids, addresses and box keys

Ids are unique per document and mean nothing outside it. Definition ids
should be short names (`cta`, `title`): they never collide with a page's.

| Who | Names a node by | Example |
|---|---|---|
| stored data (children, slots, actions, conditions, setting targets, variant children) | its id, in the same document only | `"node": "cta"` in PlanCard's own action |
| the SDK's box map | `RenderTree.keyOf(id, instance)` (`CodelesslySDK/lib/src/render/node_tree.dart:498`) with a `ComponentInstance` | box key `plans/card1/cta` |
| tools (editor selection, render command `--tap`, diagnostics, `--dump-layout`, goldens) | a path: call ids from the page down, then the inner id | `--tap plans/card1/cta`, `--tap faq/faqItem#2` |

`ComponentInstance` is the sibling of `ProvidedItem`
(`runtime/expressions/bindings.dart:35-61`) and of the list-item record
`('item', outer, listId, k)` (`widgets/collections.dart:59`):

```dart
@immutable
final class ComponentInstance {
  const ComponentInstance(this.outer, this.call, this.component);
  final Object? outer;      // the call node's own instance (null on the page, a list item, another ComponentInstance)
  final String call;        // the call node's id in the outer document
  final String component;   // the definition id
  // == and hashCode on (outer, call); toString prints the path: '$outer/$call' or '$call'
}
```

A card repeated by a list inside a section composes without new rules:
`ComponentInstance(('item', ComponentInstance(null, 'plans', 'PlansSection'), 'cardList', 2), 'card', 'PlanCard')`.

`topId__nodeId` (`managed_components.dart:791`) is **not** the scheme; it
survives only in flattened copies (legacy snapshots, §10.2).

An action in a definition naming a node (`scrollTo`, `animate`, `focus`)
acts in the instance it runs in; the runner carries it (`run.instance`,
`runtime/actions/handlers.dart:407`). A page targets a section's call node,
never a node inside it.

### 4.4 What crosses the boundary

| Thing | Crosses? | How |
|---|---|---|
| caller's variables (canvas, `page_variables`) | no | as a value parameter (`bind: {"props.annual": "${annual}"}`) or a `variable` parameter (`"props": {"annual": "annual"}`) |
| caller's `item`, `index`, node scopes (`drag`, `track`, `flip`, `tilt`) | no | pass as a parameter (`"props.plan": "${item}"`) |
| project variables (`site.json`, published as `PublishModel.variables`) | yes | by name; collisions are an error (§7) |
| `${screen}` | yes | the call site's: the project's breakpoint, or the one restated by an enclosing variance with its own switch points (DESIGN.md §5.3) |
| breakpoints, per-breakpoint patches, `states` | yes | the project's set; patches inside a definition respond to the screen like any node. Container-relative queries are not proposed |
| `${theme.*}` tokens | yes | live bindings, not substituted at build time as managed snapshots do (`managed_components.dart:886-901`) |
| `${route}`, `auth`, `storage`, `data`, `perf` | yes | ambient runtime scopes |
| navigation targets (`navigate.to`, `openModal`) | yes | screens are project-wide |
| a reaction that sets a page variable | only through a `variable` parameter or an event | `setVariable "variable": "props.menuOpen"`, or `componentEvent` handled by the page |
| scripts | project scripts yes; page scripts no | as today's precedence (DESIGN.md §5.2) minus the page |

### 4.5 Layout at the seam

The call and the definition's root render as **one box**. The call
supplies size and placement (`width`, `height`, `flex`, `margin`, `x`, `y`,
`align`, `constraints`, `aspectRatio`, `rotation`); the root supplies the
inside (`padding`, decoration, props, children). The root's own sizes are
the design size for previews and new calls.

* `hug` on the call: the root hugs its content, as a hugging column does.
* `fill` / `flexible` / `flex` on the call: the root takes the space its
  parent gives the call; the parent's child-fit rules (`childFits`,
  `props.dart:557`) are checked against the call's parent, not the root's.
* A root's bindings on size or placement are dropped
  (`root_placement_bound`): the caller sizes it, as Flutter's constraints do.
* `visible` is the AND of the call's and the root's; `opacity` the product.

### 4.6 Cycles, depth, missing and late definitions

* **Cycles**: project validation walks the call graph across documents
  (`component_cycle`, with the path); `PluginPackage.problems` today catches
  only direct self-containment (`plugins.dart:362`). The SDK stops at 32
  nested instances with an empty box (`component_depth`).
* **Missing**: an empty box of the call's size, as for an unknown type
  (DESIGN.md §2.1); `unknown_component` in validation, `component_missing`
  in the render command and the app's error log.
* **Late**: the same box until the definition arrives, so a section streams
  in on its own.

### 4.7 Storage, publish and loading

| Where | Today | Proposed |
|---|---|---|
| Editor library | one Firestore document `custom_components/{projectId}` holding every definition in a `components` map (`CodelesslyEditor/lib/editor/components.dart:32, 157`) | one document per definition, `custom_components/{projectId}/components/{id}`, so two people or agents write two sections without contending, and the 1 MiB document limit applies per component |
| Publish | `publish/{projectId}` model + `.../layouts/{id}` (DESIGN.md §2.1) | adds `.../components/{id}`: `{"schema": 2, "id", "version", "digest", "document": {...}}` |
| Publish model | `layouts` map of `PublishLayoutInfo` with `fonts`, `apis` (`publish_model.dart:94-140`) | adds `components: {id: {version, digest, lastUpdated}}`; each `PublishLayoutInfo` lists the closure it calls, `components: [ids]` |
| `PublishLoader` | `loadModel`, `loadLayout` (`CodelesslySDK/lib/src/app/loader.dart:26-32`) | adds `loadComponent(source, id)`; HTTP and asset bundles gain a `components` map |
| `PublishCache` | keys are publish paths (`loader.dart:273`) | the same, so `publish/{p}/components/{id}` caches like a layout |
| Live updates | a layout whose entry got newer is dropped and reloads when shown (DESIGN.md §5.4) | the same per component: the definition's source is replaced, every instance updates in place (§6.3) |

A screen loads its layout, then its listed closure in parallel; the header
used by every page loads once per app.

## 5. Components by reference

### 5.1 The declaration

The `widget` key **is the catalog's widget JSON** (`catalog_json.dart:160-179`)
plus `events`: `Catalog.fromJson` reads it, so editor panels, the reference
and strict validation come from it with no second schema. `WidgetSpec`
gains `events` (`props.dart:526-537`).

```json
{"schema": 2, "id": "PlanCard", "roots": ["card"],
 "widget": {"type": "PlanCard", "doc": "One pricing plan: name, price, estimate, call to action, features.",
   "children": "none",
   "props": [
     {"key": "plan", "type": {"kind": "json", "flutter": "Plan"}, "default": {}},
     {"key": "price", "type": {"kind": "number", "flutter": "double"}, "default": 0},
     {"key": "annual", "type": {"kind": "boolean", "flutter": "bool"}, "default": false},
     {"key": "responders", "type": {"kind": "integer", "flutter": "int", "min": 1}, "default": 10},
     {"key": "overLimit", "type": {"kind": "boolean", "flutter": "bool"}, "default": false},
     {"key": "popular", "type": {"kind": "boolean", "flutter": "bool"}, "default": false}],
   "events": [{"key": "onChoose", "payload": {"kind": "string", "flutter": "String"}}]},
 "variables": {"card": [{"name": "noun", "type": "text", "formula": "props.responders == 1 ? 'responder' : 'responders'"}]},
 "previews": [{"name": "Team, annual", "size": [432, 760],
               "props": {"popular": true, "annual": true, "price": 47, "plan": {"name": "Team", "cta": "Start trial", "features": ["SSO"]}}}],
 "nodes": {
  "card":  {"type": "column", "children": ["badge", "in"], "layout": {"width": {"fill": 432}, "height": {"hug": 716}},
            "decoration": {"fills": [{"color": "#FF131C1C"}], "strokes": [{"color": "#FF2C3C38"}]},
            "props": {"crossAxisAlignment": "stretch"},
            "bind": {"decoration.fills[0]": "${= props.popular ? '#FF182522' : '#FF131C1C'}",
                     "decoration.strokes[0]": "${= props.popular ? '#FFB9F34C' : '#FF2C3C38'}"}},
  "badge": {"type": "row", "children": ["badgeText"], "bind": {"visible": "${props.popular}"}, "...": "..."},
  "name":  {"type": "text", "props": {"text": "${props.plan.name}", "style": {"fontSize": 30, "color": "#FFF0F4ED"}}, "...": "..."},
  "amount":{"type": "text", "props": {"text": "${= text(props.price)}", "style": {"fontSize": 64, "color": "#FFF0F4ED"}}, "...": "..."},
  "cta":   {"type": "row", "children": ["ctaText", "ctaIcon"], "...": "...",
            "actions": [{"trigger": {"type": "click"},
                         "actions": [{"type": "componentEvent", "event": "onChoose", "value": "${props.plan.id}"}]}]},
  "feat":  {"type": "listView", "children": ["fItem"], "bind": {"data": "${props.plan.features}"}, "...": "..."}
 }}
```

(`"...": "..."` marks fields cut for the page; the measured file has them.)

And a call, from `PlansSection`:

```json
"card1": {"type": "PlanCard", "props": {"popular": true},
          "layout": {"width": 432, "height": {"hug": 716}},
          "bind": {"layout.width": "${cardW}", "props.plan": "${plans[1]}", "props.price": "${= pp(1)}",
                   "props.annual": "${props.annual}", "props.responders": "${responders}"},
          "actions": [{"trigger": {"type": "event", "event": "onChoose"},
                       "actions": [{"type": "navigate", "to": "contact", "params": {"plan": "${result}"}}]}]}
```

`previews` are Flutter's `@Preview`: named parameter sets with a size, which
the render command and the editor's component canvas render.

### 5.2 Parameters

* Declared as `PropDef` JSON (`propDefToJson`, `catalog_json.dart:52-58`):
  key, `PropType`, default, `nullable`, `doc`. A new `"required": true`
  makes a missing value an error (`missing_prop`).
* Read inside as **`${props.<key>}`**, the hosted plugins' name
  (`plugins.dart:6`, `hosted.dart:88-93`): one namespace, no collision with
  variables, and the key the caller writes is the name the definition reads.
* Set at the call like any node's props: literal in `props`, expressions in
  `bind` (`"props.price": "${= pp(1)}"`; reference index §18 rule 7).
* **`variable` parameters**: `{"kind": "variable", "of": {"kind": "boolean"}}`.
  The call passes a variable *name* of its scope (`"props": {"annual": "annual"}`),
  validated to exist with a compatible type. Inside, `${props.annual}`
  reads it live and `{"type": "setVariable", "variable": "props.annual", "op": "toggle"}`
  writes it: Flutter's `ValueNotifier` parameter, replacing the managed
  contract's canvas variables. In the Relay rewrite the hero's switch
  writes the page's `annual`; header and drawer share `menuOpen`.

### 5.3 Slots

The definition places slot content with a `slot` node; the call fills it
with its `children` (the `children` slot, Flutter's `children`) or a named
entry of `slots` (one node, Flutter's `Widget title`), the existing node
`slots` map (`node.dart:57-58`).

```json
{"id": "SectionShell", "roots": ["shell"],
 "widget": {"type": "SectionShell", "children": "list", "slots": ["actions"],
            "props": [{"key": "title", "type": {"kind": "string", "flutter": "String"}, "default": ""}]},
 "nodes": {
  "shell": {"type": "column", "children": ["head", "body"], "...": "..."},
  "head":  {"type": "row", "children": ["title", "acts"], "...": "..."},
  "title": {"type": "text", "props": {"text": "${props.title}"}, "...": "..."},
  "acts":  {"type": "slot", "props": {"name": "actions"}},
  "body":  {"type": "slot", "props": {"name": "children"}, "children": ["emptyNote"]}
 }}
```

```json
"faq": {"type": "SectionShell", "props": {"title": "Questions"}, "slots": {"actions": "contactLink"},
        "children": ["q1", "q2"], "layout": {"width": {"fill": 1440}, "height": {"hug": 800}}}
```

* A `slot` node is **replaced** in its parent's child list by the content,
  so a passed `flex: 1` button still flexes in the definition's row. With
  no content its own `children` show (the default).
* Content nodes belong to the caller: stored in its document (their
  parent is the call node), reading its scope, as a Flutter `child` is
  built in the parent's `build`.
* `ManagedSlot.node` (a node whose children are replaced,
  `managed_components.dart:297-327`) and `PluginWidget.slots` (slot → host
  node, `plugins.dart:206-207`) both become `slot` nodes.

### 5.4 Events

* Declared in `widget.events`: key, payload `PropType`, doc.
* Fired with **`componentEvent`** (`{"event", "value"}`), the placeholder
  managed components and hosted plugins already name
  (`managed_components.dart:48`). It moves from the managed library to the
  core as a real `CoreAction`, because document components fire events.
* Handled by the call's reactions with a new trigger
  `{"type": "event", "event": "onChoose"}`, `${result}` the value: the one
  way a node runs a chain, replacing `ManagedComponentRef.events`
  (`managed_components.dart:187`) and the splicing at `:849-861`. An
  unhandled event does nothing; a handler for an undeclared one is
  `unknown_event`.

### 5.5 Local state

The definition's `variables` (keyed by its root id, as a canvas's are) and
`conditions` exist **once per instance**, like a `State` object. Relay's
`openFaqs` becomes `FaqSection`'s own; the estimator's `responders`,
`respInput` and the five formulas over them become `PlansSection`'s.
`persist: true` on a component variable persists per instance path.

### 5.6 Variants

No variants concept. A visual variant is a parameter (an enumeration, or
`popular: bool`) read by bindings, `states` patches and per-breakpoint
patches. A structural variant uses the existing `variance` node inside the
definition with `"bind": {"props.current": "${props.size}"}`
(`widgets/canvas.dart:58-70`); responsive variances work unchanged.

### 5.7 Overrides: none

| Policy | AI editing | Updates | Verdict |
|---|---|---|---|
| Nothing beyond parameters and slots | to change one card, add a parameter: two small edits, both validated | always safe: the contract is the declaration | **chosen** |
| Declared parts only (an "exposed" list) | a second contract beside parameters | safe | rejected: two ways |
| Patch by inner node key | one edit, but invisible coupling to inner ids | a renamed or removed inner node silently drops the patch; every instance is a potential fork | rejected |

Starting with none is the reversible direction: patches can be added later
without breaking a document; removing them later would. **Detach** becomes
*Inline* (replace the call by a copy of the definition's nodes with the
parameters substituted, the same expansion as §10.2) and *Duplicate as new
component*.

### 5.8 One mechanism at three scopes

| Scope | Where the definition lives | Versioning | Today's equivalent |
|---|---|---|---|
| document | the document's `"components": {"Id": {definition}}` | the document's | none (a pasted single-file page; a plugin package's private parts) |
| project | `components/{Id}.json`; editor `custom_components/{p}/components/{Id}`; publish `publish/{p}/components/{Id}` | `version` + `digest` per publish | `ComponentDefinition` + copy instances |
| hosted | a plugin package's `implementation.widgets` (`plugins.dart:288-329`), each entry a definition document | `ManagedComponentMaster` channels, pins, rollouts, digests (`managed_components.dart:621`) | hosted plugin widgets (islands), managed components (snapshots) |

Call, declaration, scoping, rendering and validation are identical at
every scope; only fetching and version choice differ, and stay in the
managed library.

### 5.9 What happens to today's copies

| Today | Becomes | Readable |
|---|---|---|
| `ComponentLink` `role: main` on the node a component was made from | the definition document is the source; the editor converts the main node into a call | forever (decoder unchanged) |
| copy instance with `ComponentLink` + `settings` and no edits beyond its settings | a call: each setting becomes a parameter (`effectiveKey` → `key`; `string`/`number`/`bool` → same kinds, `color` → `value` `Color`, `options` → `enumeration`, `icon` → `value` `IconData`, `radius`/`spacing` → `value`), each target becomes `bind[path] = "${props.key}"` on that definition node, the instance's values become call props | yes |
| copy instance with other inner edits | stays a copy; the editor marks it "has overrides" and offers convert (listing what is lost) or "make a component of it" | forever |
| managed snapshot (`buildManagedInstance`) | a call to the hosted type: `values` → props, `slots` → call slots, `events` → `event` reactions, `tokens` → `${theme.*}` (live), contract `variables` → the definition's own | the snapshot decodes and renders as today until the project republishes |
| `replaceManagedInstance`, `managedUpdateTarget` | not needed: an update swaps the definition, not the page's nodes | kept one release |
| hosted plugin island (`_HostedRecipe`) | the plugin's widgets register as hosted-scope definitions | n/a (no stored change) |

## 6. Rendering

### 6.1 Resolving a call in `RenderTree`

Today a `RenderTree` has one `NodeSource` (`render/node_tree.dart:152, 267`)
whose `node`, `parentOf` and `watch` take an id only (`render/source.dart:7-11`).
Changes:

1. **`ComponentRegistry`**: id → a `DocumentSource` per definition (shared by
   every instance) and its `WidgetSpec`; it notifies when a definition
   arrives or changes. One per `Codelessly`; the render command and the
   editor fill it from files.
2. **`RenderTree.sourceOf(Object? instance)`**: the innermost
   `ComponentInstance`'s definition source, else the page's. `nodeOf(id,
   instance)`, `parentOf(id, instance)` replace `source.node(...)` and
   `source.parentOf(...)` at the 42 call sites in 9 SDK files (`grep -rn
   "source\.node(\|source\.parentOf(\|source\.watch("`); `NodeBox._subscribe`
   (`node_tree.dart:895`) watches `tree.sourceOf(instance).watch(id)`.
3. **`_syncChildren`** (`node_tree.dart:1969-1997`): a child id whose node
   is a call obtains the definition root's box with
   `instance: ComponentInstance(thisInstance, childId, type)`; a child that
   is a `slot` node is spliced into the caller's content ids with the
   instance's `outer`. Both are the same move the list makes for items.
4. **The root's node as shown** is the root seamed with its call (§4.5),
   computed in `resolveBound`, cached per (call, root) pair. A lookup by the
   call's id (`--tap plans`, `scrollTo`) resolves to that root box.
5. **Conditions**: a `ConditionIndex` (`bindings.dart:151-166`) per
   definition, beside the page's.

Each node of each instance is one `NodeBox`; nothing builds an element
subtree.

### 6.2 Scopes and bindings

`NodeBinder.scopeFor` walks parents to find list item and node scopes
(`runtime/expressions/bindings.dart:465-509`). The walk stops at a
definition's root, and the base scope there is the instance's
`ComponentScope`:

* `props`: the call node's props as bound in the **caller's** scope
  (`bind(source, call, outer)`), so `${props.price}` updates when the
  caller's `pp(1)` does; a `variable` parameter is a reference to the
  caller's variable;
* the definition's variables and conditions, one set per instance;
* parent: the app's variables (`appVariables`,
  `CodelesslySDK/lib/src/app/codelessly.dart:164`) and the call site's
  `${screen}`.

Watching is by root name (`_watchers`, `bindings.dart:339-348`): a changed
parameter re-applies that instance's boxes that read `props`. Finer
granularity needs no format change.

### 6.3 Incremental updates across the boundary

* **Editing a definition** replaces its `DocumentSource.document`; only
  nodes that differ by `==` notify (`render/source.dart:21-31`), and each
  notifier has every instance's box of that node as a listener. Changing a
  card's title style re-applies three boxes, not the page.
* **Editing a call** re-binds it; that instance's `props` readers re-apply.
  A changed `widget` declaration re-decodes the calls of its type.

### 6.4 Performance

`NodeBindings` are compiled once per `Node` identity (`bindings.dart:123-126`):
per copy today, once per definition node for all instances. An instance
costs a copy's boxes plus one `ComponentScope`, with less compilation and
memory. A list of 300 `PlanCard`s is 300 item instances each wrapping one
`ComponentInstance`; paged lists stay islands over the template's boxes as
today (DESIGN.md §5 "Running lists"). The target to measure before phase 2
ships: a 300-item at-rest list of a 25-node component within 10% of the
same list with the nodes inlined (frame build time, `benchmark/`).

### 6.5 Hosted plugins on the same path

`hostedPluginFeature` registers each `PluginWidget` as a hosted-scope
definition instead of a recipe; `_HostedRecipe` and `_HostedNodeView`
(`features/hosted/hosted.dart:60-110`) are deleted. What hosted widgets
gain: hug and fill through the seam (the island is a fit box at the node's
design size, `:67`), interaction, slots and events (doc 05 "Not done"),
per-node watching instead of one `props` map set wholesale (`:98`). The
plugin's formula functions become the definition's function variables.

## 7. Shared data

Two readings of "data nesting, and data components reused":

**(a) UI components as data** is §4–6.

**(b) Content and computed values defined once.** Project variables exist
at run time: `PublishModel.variables` (`publish_model.dart:305-308`) is
declared into `appVariables`, parent of every page and canvas scope
(`CodelesslySDK/lib/src/app/codelessly.dart:160-164, 220-240`). Authors can
write them only through a v1 `app_variables` key in a layout
(`codelessly.dart:574`, `codelessly_widget.dart:902`), which the validator
rejects (`unknown_scope`). Proposed:

* The site manifest declares them (content records, screen-only helpers
  like `rv`, app state like a cart); publish writes `PublishModel.variables`.
* Every document reads them by bare name; a page, canvas or component
  variable of the same name is `duplicate_variable`.
* Named data sources (`DataSourceSpec`, doc 05 §6.3) may be declared there,
  so two sections bind one query.

Scoping rules that keep a part independently editable and testable:

1. A definition reads only `props`, its own variables, project variables
   and ambient scopes (§4.4). Validation enforces it with the existing
   `unknown_name`.
2. Data a section shares with **its page** is a parameter: a value
   parameter for reading, a `variable` parameter for writing.
3. A **hosted** component reads no project variables (it cannot know
   them; doc 05 §5.4). A project component may read shared content and
   helpers (`PlanCard` reads `polish` and `rv`), but takes the record it
   shows (the plan, the dish) as a parameter, so one definition serves
   every record.
4. Every parameter has a default, and previews supply realistic values, so
   any part renders alone.

## 8. Authoring by AI

### 8.1 The files an agent works in

```
site/
  site.json                  manifest: pages, project variables, theme, breakpoints, fonts
  pages/pricing.json         canvases and section calls (11 nodes)
  components/PlanCard.json   one definition per file; file stem = id
  components/PlansSection.json
  components/SiteHeader.json ...
```

```json
{"schema": 2, "pages": ["pages/pricing.json"],
 "variables": [{"name": "plans", "type": "list", "value": [{"id": "starter", "name": "Starter", "monthly": 29, "annual": 23}]},
               {"name": "rv", "type": "decimal", "parameters": ["d", "t", "m"],
                "formula": "screen.isDesktop ? d : (screen.isTablet ? t : m)"}],
 "breakpoints": [{"id": "mobile", "minWidth": 0}, {"id": "tablet", "minWidth": 600}, {"id": "desktop", "minWidth": 1024}]}
```

The flat format makes this cheap: a reference is one node, a call one node
with props, reordering sections one id list; two agents editing
`PlansSection.json` and `FaqSection.json` touch different files.

### 8.2 The render command

* A directory is a site: `site.json` if present; documents whose roots are
  canvases are pages; one non-canvas root plus `widget` is a component (id
  = file stem, else `component_id_mismatch`). Without `site.json` nothing
  changes.
* `--component PlanCard` renders the component alone, once per preview, at
  the preview's size (`<out>/PlanCard@432x760-team-annual.png`);
  `--props '<json>'` renders one ad-hoc parameter set. Steps (`--tap cta`,
  `--set`) name the definition's ids.
* Steps on a page take paths: `--tap plans/card1/cta`; `<path>#<n>` keeps
  its meaning for list copies. `--dump-layout` writes paths.

The edit-and-look loop on the card is a 29-node file rendered at one size,
not a 253-node page at three.

### 8.3 Strict validation of calls

Per call, against `widget` (the code that checks any node against its
`WidgetSpec`): `unknown_prop`, `wrong_type`,
`out_of_range`, `missing_prop`, `unknown_slot`, `children_not_allowed`,
`unknown_event`, and for `variable` parameters `unknown_variable` /
`wrong_type` against the caller's scope. Per definition: `unknown_name`
(reading a page variable is exactly this), `slot_outside_component`,
`root_placement_bound`, `call_field_not_allowed`. Per project:
`unknown_component`, `duplicate_component`, `component_cycle`.
`duplicate_id` across documents (`lib/src/validate/diagnostic.dart:140`)
goes: paths make such ids unambiguous.

### 8.4 When to make what

* **List template**: N repeats of one shape from data inside one parent.
  When the repeated item is more than about five nodes, or appears
  elsewhere, the template is a single call node (`"props.plan": "${item}"`).
* **Component**: the same structure in two or more places with different
  values (buttons, cards, chips, rows), or a unit others will reuse. Data in
  through parameters.
* **Section**: a top-level band of a page (header, hero, plans, FAQ,
  footer), its own file whenever it is more than about 15 nodes or someone
  will edit it alone, even if used once. Parameters only for what crosses
  (§7 rule 2).

### 8.5 Token budget

Measured on the Relay rewrite (§9): changing the plan card means reading
and writing 9.4 KB (≈2.7k tokens) instead of 73.8 KB (≈21.1k); reordering
or adding a section, 1.8 KB (≈0.5k); the largest file is the comparison
section at 13.9 KB (≈4.0k). An agent editing `PlansSection` needs
`PlanCard`'s declaration (562 bytes), not its nodes.

## 9. Worked example: Relay pricing, c1/A

### 9.1 What was rewritten

`c1/saas-landing-A/site/pricing.json`: one canvas, 253 nodes, three plan
cards stamped from one template by `src/build.py`. Rewritten mechanically by
a script (not committed; described in §9.4) into the files of §8.1:
eight sections (`SiteHeader`, `MobileDrawer`, `PricingHero`,
`PlansSection`, `CompareSection`, `FaqSection`, `FinalCta`, `SiteFooter`),
one `PlanCard` from the three copies, and a page of section calls.

Where state went (from the page's 20 variables): content and screen-only
helpers (`plans`, `polish`, `site`, `faqs`, `cmpRows`, `pricing`, `rv`,
`gut`, `cw`) to project variables; `annual` and `menuOpen` stay on the page
and cross as `variable` parameters (hero writes `annual`, plans read it;
header and drawer share `menuOpen`); `openFaqs` became `FaqSection`'s;
`responders`, `respInput`, `invalid`, `noun`, `starterOver`, `pp`,
`cardGap`, `cardW` became `PlansSection`'s, and `PlanCard` takes six
parameters.

### 9.2 Before and after

| File | Nodes | Minified bytes | ≈ tokens |
|---|---|---|---|
| **before**: `pricing.json` | 253 | 73,839 | 21,097 |
| `site.json` (project variables) | 0 | 6,476 | 1,850 |
| `pages/pricing.json` | 11 | 1,788 | 511 |
| `components/SiteHeader.json` | 15 | 3,485 | 996 |
| `components/MobileDrawer.json` | 5 | 1,659 | 474 |
| `components/PricingHero.json` | 14 | 4,659 | 1,331 |
| `components/PlansSection.json` | 30 | 9,664 | 2,761 |
| `components/PlanCard.json` | 29 | 9,370 | 2,677 |
| `components/CompareSection.json` | 61 | 13,893 | 3,969 |
| `components/FaqSection.json` | 13 | 3,532 | 1,009 |
| `components/FinalCta.json` | 10 | 3,233 | 924 |
| `components/SiteFooter.json` | 22 | 4,985 | 1,424 |
| **after, total** | **210** (−17%) | **62,744** (−15%) | **17,927** |

Rendered boxes: 257 (the 253 plus a hidden badge in two cards). Redundant
byte-identical nodes: 43 before, 12 after: the logo mark and text, in both
header and footer (a `Logo` component), and the comparison table's value
cells, written once for the wide table and once for the mobile one. One
difference is approximated: the popular card's hover color (a `states`
patch is not bound to `props.popular` in this rewrite).

The single-page saving is modest; the gains are the working set (§8.5)
and reuse across pages. Projected, not measured: Relay's six pages share
header, drawer and footer (10,129 bytes here), five the final CTA (3,233);
written once, that is about 63 KB (≈18k tokens) less across the site.

### 9.3 Not rewritten

Casa Brasa c1p/B (466 nodes, three canvases of one screen) is the larger
win, but most of its duplication is the per-breakpoint canvases, which the
responsive work (`flex`, per-breakpoint patches) removes, not this
proposal. Its header, footer and dish rows would become calls the same way.

### 9.4 How it was measured

* Nodes: `len(doc["nodes"])`. Bytes: file size (pretty) and
  `json.dumps(doc, separators=(",", ":"), ensure_ascii=False)` (minified).
* Tokens: minified bytes ÷ 3.5. No tokenizer was available; the ratio is an
  assumption, applied identically before and after.
* Redundant nodes: nodes whose JSON, without `children` and `slots`
  (sorted keys), equals an earlier node's. This counts copies beyond the
  first; it gives 5–27%, not the 11–26% quoted in the brief, whose method
  is not known.
* The rewrite: strip the `s-` prefix from the starter card's ids; replace
  `plans[0]`, `pp(0)`, `starterOver`, `annual`, `responders` with
  `props.*`; add the popular card's badge and color differences as
  bindings on `props.popular`; move each section root's size and placement
  (not padding) to its call. The output was **not rendered**: the format
  does not exist yet.

## 10. Compatibility and rollout

### 10.1 Format

`"schema": 2` stays; everything is additive: document keys `widget`,
`components`, `previews`; a `slot` node type; an `event` trigger; a
`componentEvent` core action (its JSON is today's placeholder);
`PropKind.variable`; publish paths `components/{id}`. `ComponentLink` and
managed snapshots decode and render as today. A call decoded without its
definition keeps its props raw (`Props.unknown`) and round-trips
(DESIGN.md §2.1).

### 10.2 Published apps on older SDKs

An old SDK draws a call as an empty box. So until a support window ends,
publish also writes each layout **flattened**: every instance expanded into
plain nodes with ids `callPath__nodeId`, each parameter a computed canvas
variable `callPath__key` whose formula is the call's binding (so
`${props.price}` is renamed `${plans__card1__price}`), local variables
renamed the same way, `variable` parameters renamed to the caller's
variable, slots grafted, `componentEvent` replaced by the call's chain:
`buildManagedInstance` generalised from values to expressions. New SDKs read
the composed form, gated by a `minSdk` the publish model gains.

### 10.3 Phases

| Phase | API | SDK | Render command, docs | Editor |
|---|---|---|---|---|
| **1** sections and local components | `widget` (+`events`) on documents; `Catalog` built from definitions; `slot` node; `componentEvent` to core; `event` trigger; `variable` kind; `previews`; site manifest with project variables; project validation (§8.3) | `ComponentInstance`, `ComponentRegistry`, instance-aware `RenderTree`/`NodeBinder` (§6.1–6.2), seam, events, `variable` parameters | directory as site, `--component`, `--props`, paths in steps; reference index: "Sections and components", rules for §8.4 | nothing |
| **2** publish and load | `PublishModel.components`, `PublishLayoutInfo.components`, `minSdk`, flattener (§10.2) | `loadComponent`, cache, live updates, placeholders, depth guard; benchmark §6.4 | — | write definitions per document; publish both forms |
| **3** hosted scope | plugin widgets as definitions; managed versions carry definitions; `ManagedComponentRef` → call | delete `_HostedRecipe`; managed resolver swaps definitions | guide 09 updated | plugin browser inserts calls |
| **4** migrate copies | converter §5.9 | — | — | convert, "has overrides", inline, duplicate |

Phase 1 has the most value and least risk: no editor or published data
changes, nothing ships to apps, and agents get files per part and the
isolated render loop at once.

**What the editor will need** (not ported now): definitions as separate
documents (undo, save, presence); a component canvas with previews; instance
panels from `widget`; slot drop zones; event handlers in the reactions
panel; read-only selection into instances with "edit component"; a sections
outline; inline/duplicate; the §5.9 converter; an insert menu over all
three scopes; rename-id refactor.

**Import boundary.** Calls, `widget`, `slot`, `componentEvent`, the
`event` trigger, scoping and the SDK's render path are **core** (doc 05 §6):
a renderer-only build renders sections. Masters, channels, rollouts,
digests and the hosted package format stay in `managed.dart`; the publish
paths in `publish.dart`.

## 11. Open decisions for the owner, ranked

1. **Id scoping and addressing** (hard to reverse). Recommended:
   document-local ids, `ComponentInstance` in box keys, `/` paths for tools
   only. Prefixed copies (`top__id`) are the copy model again. Changing
   later rewrites every definition, tool output and box-naming test.
2. **Parameter name inside a definition** (hard to reverse). Recommended:
   `${props.x}`, the hosted plugins'. Bare `${x}` collides with variables;
   `${widget.x}` is Flutter's but a second word for the JSON key `props`.
   Changing later rewrites every definition's bindings.
3. **Override policy** (hard to reverse in one direction). Recommended:
   none. Adding key patches later is additive; removing them would break
   documents.
4. **Sections are isolated components** with `variable` parameters for
   shared page state, not fragments sharing page scope. Relaxing later is
   additive; tightening later breaks every section that reached out.
5. **Component id as node type**, UpperCamelCase, unprefixed. Alternative:
   `{"type": "use", "component": "PlanCard"}`, which is not Flutter's shape
   and differs from plugin nodes. Changing later is a mechanical rewrite.
6. **Project variables by bare name** with collisions as errors.
   Alternative: a namespace (`${app.plans}`). Medium cost to change.
7. **Flattened fallback for old SDKs** and how long to keep it.
   Recommended: two SDK releases after phase 2.
8. **Expressions inline in call props** (`"props": {"price": "${= pp(1)}"}`).
   Recommended: not now (one rule for all nodes); cheap to add later as a
   decoder that moves them into `bind`.
9. **One editor document per definition.** Recommended; it is what makes
   parallel editing possible.

## Not verified

* Nothing was prototyped or rendered; the Relay rewrite was checked by
  counting and reading. `hug` through the seam needs the parity goldens.
* Token counts are estimates (bytes ÷ 3.5).
* The 42 SDK call sites are a text grep; some may not need an instance.
* The flattener's expression renaming (§10.2) is designed from
  `buildManagedInstance` and `Expressions.readsOf`, not tried.
* The 10% performance target (§6.4) is a target, not a measurement.
* Editor behavior is from `lib/editor/components.dart` only.

## Where the code surprised

* Updating a project instance re-creates its inner nodes with new ids and
  reads each setting back from its first target only
  (`CodelesslyEditor/lib/editor/components.dart:274-320`), so references
  into an instance break on every update.
* Managed snapshots freeze theme tokens into constants and put their
  variables on the page's canvas, shared by every instance (§1; SDK
  `app/managed_components.dart:155`).
* Project-wide variables work at run time, but the only way to author them
  is a v1 scope name the validator rejects (§7).

## Implementation notes (phase 1, 2026-11-13)

Implemented in `codelessly_api` (`lib/src/core/sections.dart`, `props.dart`,
`catalog_json.dart`, `triggers.dart`, `actions.dart`,
`lib/src/validate/components.dart`) and `codelessly_sdk`
(`lib/src/render/components.dart`, `render/node_tree.dart`,
`runtime/expressions/component_scopes.dart`, `runtime/expressions/bindings.dart`,
`runtime/actions/runner.dart`, `tool/render/src/site.dart`). The Relay pricing
page of m05 round 2 (run B) rewritten as a page of section calls and ten
component files is `codelessly_sdk/examples/relay-pricing`: every state it was
checked in, at every size, renders byte-identical PNGs to the one-document page.

### Deviations from the proposal

1. **No `PropKind.variable`.** Following the `ExprCodec` precedent (docs 01, 02),
   a `variable` parameter is `PropType.variable(of)`: its `kind` is `string` (the
   variable's name, so a panel switching over the kinds shows a text field), its
   new field `variableOf` is the variable's type, and its JSON is the proposal's
   `{"kind": "variable", "of": {...}}`. `PropType.isVariable` tells it apart.
2. **The definition lives in `LayoutDocument.extra`** (`widget`, `previews`), read
   through an extension (`ComponentDocument`), rather than new fields on
   `LayoutDocument`: the document round-trips byte for byte and nothing else
   changes. A document-scope `components` map (§5.8, "document" scope) is not read
   yet.
3. **Preview file names** are `<Type>-<preview>@<w>x<h>.png`, not
   `<Type>@<w>x<h>-<preview>.png`: the render command names every capture
   `<screen>@<size>`, and the preview is the screen.
4. **`duplicate_id` stays for pages**: ids are local to a component (no report
   between a component and another document), but two pages sharing an id are
   still reported, because render-command steps name page nodes by bare id.
5. **Box keys print the full instance** (`(item, null, list, 2)/card/cta`), not
   the tool path: two copies a list repeats must not share a key. Tool paths
   (`componentPath`, `RenderTree.pathOf`, `boxAtPath`) are computed apart and use
   `#n` for the n-th copy on screen.
6. **The call keeps its own node** besides the definition's: a call is a node of
   its page (counted in the page's nodes), and the definition's root box is the
   call's box. The proof's node count went from 196 to 206 (one per call) while
   the boxes rendered stayed 550.
7. **Media rules and bindings of a section root's size and placement move to the
   call** when a page is split (the root's padding and decoration stay): the seam
   takes the call's layout but for padding, after both are resolved.
8. **Project variables in the app** come from `PublishModel.variables` (declared
   into `Codelessly.appVariables`, as before); `NodeBinder.projectScope` names the
   scope a definition reads them from (the app passes `appVariables`). Without it
   the outermost variable scope around the page is taken when there are several.
9. **Ambient scopes are the caller's root's**: an instance reads `screen`,
   `route`, `theme`... from the screen around its caller, not from a variance
   around the call that restates `screen` with its own switch points (§4.4).
10. **The validator's `unknown_slot` and `children_not_allowed` on a call** are the
    generic ones (the call's spec is the component's declaration); `unknown_slot`
    also reports a definition's `slot` node naming an undeclared slot.
11. **`root_placement_bound` is a warning**, as the binding is dropped, not
    misread.

### Not done

* **Loading from a publish (phase 2).** The app's components come from memory
  only: `Codelessly(components: ComponentRegistry([...]))`, filled by the app (the
  render command fills it from a site's files). To do: `PublishModel.components`
  (`{id: {version, digest, lastUpdated}}`), `PublishLayoutInfo.components` (the
  closure each layout calls, `ComponentLibrary.closureOf`), the publish path
  `publish/{p}/components/{id}` (`{"schema": 2, "id", "version", "digest",
  "document"}`), `PublishLoader.loadComponent(source, id)` (Firestore, HTTP,
  asset bundle and `MemoryPublishLoader`; `PublishBundle` gains a `components`
  map), `PublishCache` keys by that path, `Codelessly._loadLayout` loading the
  closure in parallel before the screen shows and defining it in
  `Codelessly.components`, live updates replacing a definition's document
  (`ComponentRegistry.define` already updates instances in place), and the fonts
  of called components preloaded with the layout's (the render command does this
  itself: `publishPages(components:)`). Missing definitions render the call's
  empty box and are listed in `ComponentRegistry.missing` (`component_missing`
  in the render command); nothing logs them to the app's analytics yet.
* **Hosted plugins on this path** (§6.5): `hostedPluginFeature` still renders a
  plugin node type in an island. The step is to register each `PluginWidget` as a
  definition in the app's registry (its `document` with a `widget` built from the
  plugin's catalog entry) and drop `_HostedRecipe`; its formula functions need to
  become the definition's function variables first.
* **Actions naming a node inside a definition** (`scrollTo`, `animate`, `focus`,
  `setValue`, `editText`) act on every instance's box of that id, not only the
  instance they run in (`run.instance` is carried but not yet used to narrow).
  `setValue` reads the node from the page's source.
* **Slot content inside a list in the definition**: a slot placed inside a list
  the definition repeats shows the caller's content box once (content is keyed in
  the caller's instance).
* **Per-instance scopes are kept until the binder is disposed** (one
  `ComponentScopes` per instance that was shown): a long-scrolling list of
  component items keeps the scopes of items that left.
* **A changed declaration** (`widget`) re-places its calls but does not re-decode
  the pages that call it: a call's props stay typed with the old declaration until
  the page is decoded again (values are read through the new declaration anyway).
* **`persist: true`** on a component variable is not persisted per instance path.
* **The document scope** (`components` inside a document), `previews`' slot
  content, inline/duplicate/convert in the editor, and the flattener for old SDKs
  (§10.2) are later phases.
* **The editor** is not ported. Call sites of what changed, read-only:
  `CodelesslyEditor/lib/editor/managed_prebuilts.dart:163,195,289` and
  `lib/editor/managed_components.dart:492,515` (`kComponentEventAction`: same
  string; a decoded one is now a `ComponentEventAction`, not an `UnknownAction`);
  `lib/api/node_json.dart:715` (`TriggerType.values` now has `event`);
  `packages/codelessly_properties/lib/src/reactions_editor.dart:18`
  (`triggerFieldsOf` should show `TriggerFields.event` for `event`) and `:192,
  305` (the trigger menu lists `event`); `packages/codelessly_properties/test/
  reactions_test.dart:29` (renders every trigger type). Panels for `PropDef.required`,
  `PropType.variable` and `WidgetSpec.events` are new UI.

### Measured

* Relay pricing (m05 c2/B): 1 file, 196 nodes, 54,727 bytes minified, became 12
  files, 206 nodes, 59,253 bytes (+8%: declarations and call layouts; the page
  already repeated its cards and questions from lists). The largest file an editor
  of one section opens is 11,225 bytes (CompareSection), the plan card 8,982, the
  page 1,600. Render command runs: 7.8–8.3 s before, 7.8–8.9 s after (whole runs,
  three full-page sizes per state).
* A 500-item list whose template is a 15-node component builds and scrolls with
  the same number of box applies as the same list inlined (835 at rest, in the
  test's viewport), in about the same time (`test/components/components_perf_test.dart`);
  a variable nothing in it reads re-applies none of its boxes.
