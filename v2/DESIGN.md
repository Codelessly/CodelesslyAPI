# Codelessly v2: API and SDK, rebuilt

**Status:** in development · **Packages:** `codelessly_api` 7.0.0-beta,
`codelessly_sdk` 9.0.0-beta · **Date:** 2026-11-04

v2 rebuilds both packages from the ground up on the architecture the canvas
prototype proved (`CodelesslyEditor/packages/codelessly_canvas`): immutable
nodes with no layout results in them, rendered straight into Flutter render
objects.

v1 (API 6.x, SDK 8.x) stays where it is, at each repo's root, and keeps
serving deployed apps and the current editor. v2 lives in `v2/` in each repo
until it replaces v1.

## 1. What each layer owns

| Package | Owns | Never contains |
|---|---|---|
| **`codelessly_api`** (pure Dart) | Flutter's widget vocabulary as data: one declaration per widget, Flutter names and defaults. Immutable nodes with value equality. A flat node map. The layout document, publish model, variables, conditions and actions as data. JSON: sparse, total, versioned. | Flutter imports. Computed geometry. Editor state. Globals. Network code. |
| **`codelessly_sdk`** render | Nodes → Flutter render objects, one `NodeBox` per node, with no widget or element per node. Widgets that need an element tree (text fields, video, charts) are islands. | Editor flags. Data or network code. Static registries. |
| **`codelessly_sdk`** runtime | `Codelessly`, `CodelesslyWidget` and controllers. Bindings compiled once per layout. Actions as typed handlers over an `ActionContext`. Data sources, auth, navigation and analytics as plugins configured by the app. | `BuildContext` in actions. JSON round trips during a build. Hard-wired Firebase. |

The editor builds on all three; the API and SDK know nothing about it.

## 2. JSON contract

### 2.1 Versions and storage

* Every v2 document carries `"schema": 2`. Decoders run `migrate(json)` from
  any older v2 schema on load, so the format can keep improving without
  breaking stored data.
* v1 data is **not** read by the v2 SDK. Existing layouts move to v2 through a
  one-time batch migration (`v2/migrate`, §6). Published v2 layouts go to their
  own storage path, so apps on SDK 8.x keep reading their v1 publish untouched.
* **Decoding is total.** Unknown keys round-trip in `extra`. Unknown node types
  decode as `UnknownNode` (they render as an empty box of their size). Bad
  values fall back to the default. A malformed field never throws.
* **Encoding is sparse.** A field equal to its Flutter default is omitted.

### 2.2 A layout document

```json
{
  "schema": 2,
  "id": "layout-id",
  "roots": ["canvas-a"],
  "nodes": {
    "canvas-a": {"type": "canvas", "name": "Home", "slots": {"body": "col"},
                 "layout": {"width": 1440, "height": 900}},
    "col": {"type": "column", "children": ["title", "card"],
            "layout": {"width": {"fill": 1440}, "height": {"hug": 626},
                       "padding": [24, 24, 24, 24]},
            "props": {"crossAxisAlignment": "start", "spacing": 12},
            "decoration": {"fills": [{"color": "#FFFFFFFF"}], "radius": 8}},
    "title": {"type": "text", "props": {"text": "Hello",
              "style": {"fontSize": 24, "fontWeight": 700, "color": "#FF111111"}}}
  }
}
```

Parents are derived from `children` and `slots`; they are never stored.

### 2.3 Every node

| Key | Type | Meaning |
|---|---|---|
| `type` | string | Widget type (`row`, `text`, ...). |
| `name` | string | Display name. |
| `children` | `[id]` | Ordered children (row, column, stack, list...). |
| `slots` | `{name: id}` | Named children (`body`, `appBar`, `leading`...). |
| `visible` | bool | `false` hides the node; default `true`. |
| `opacity` | 0–1 | Default 1. |
| `layout` | `Layout` | How the node sizes itself and sits in its parent (§3). |
| `decoration` | `Decoration` | Fills, strokes, radius, shadows, blurs, clip (box types). |
| `props` | per type | The widget's own parameters, Flutter names (§4). |
| `bind` | `{path: expression}` | Properties bound to variables or formulas (`"props.text": "${user.name}"`). |
| `actions` | `[Reaction]` | Trigger → action list. |
| `extra` | map | Unknown keys, round-tripped. |

## 3. Layout

v1 stored a box per node (`basicBoxLocal`, `outerBoxLocal`...) and re-derived
placement from it on every render with a dozen fallbacks. v2 stores the
intent, in Flutter's terms, and nothing the renderer computes.

```json
"layout": {
  "width": {"fill": 320},       // or 320 (fixed), {"hug": 120}, {"flexible": 200}
  "height": {"hug": 48},
  "flex": 2,                      // share of a row/column's free space
  "constraints": {"minWidth": 100, "maxWidth": 600},
  "margin": [0, 8, 0, 8],         // left, top, right, bottom
  "padding": [16, 12, 16, 12],
  "x": {"start": 24},             // freeform parent only; see below
  "y": {"align": 0.5},
  "align": [0, 0],                // row/column parent only: alignment in its slot
  "rotation": 15,                 // degrees, about the centre
  "aspectRatio": 1.5
}
```

* **Sizing per axis** is `fixed`, `fill` (Expanded/stretch), `flexible`
  (Flexible, loose) or `hug` (size to content). The number is the design size:
  the size used for `fixed`, and the fallback when a mode can't apply.
* **Freeform position per axis** follows `Positioned`/`Align`: `{"start": d}`,
  `{"end": d}`, `{"start": a, "end": b}` (stretch between), `{"align": -1..1}`
  (`Align`, by the laid-out size) or `{"relative": d}` (d from the start at
  design size, keeping its share of the free space as the parent resizes).
  These are distances in the parent's padded box, to the child's margin box. The
  migration resolves v1's pins, positioning mode and stored boxes into exactly
  one of these, once.
* `flex` and `align` apply under row/column parents; `x` and `y` apply under
  freeform parents. Values for another kind of parent are kept, so moving a
  node back restores them, and the renderer ignores them.

## 4. Widgets and props

Each widget has one declaration: its name, its props with Flutter's types and
defaults, and which slots it takes. From that one declaration a generator
emits the props class (immutable, `==`, `copyWith`, sparse JSON) and the
metadata the editor's panels and the SDK use.

| v2 type | Flutter | v1 type |
|---|---|---|
| `canvas` | Scaffold (screen) | `canvas` |
| `stack` | Stack (freeform) | `frame`, `rectangle` with children, `freeformPlaceholder` |
| `box` | Container (no children) | `rectangle` |
| `row`, `column` | Row, Column | `rowColumn` |
| `text` | Text.rich | `text` |
| `icon` | Icon / SVG | `icon` |
| `spacer` | Spacer / SizedBox | `spacer` |
| `variance` | variant switcher | `variance` |
| ... | one per remaining v1 type | |

Value types mirror Flutter: `Color` (`#AARRGGBB`), `EdgeInsets`,
`BorderRadius`, `Alignment`, `BoxConstraints`, `TextStyle`, `BoxShadow`,
`Gradient`, and enums with Flutter's value names and defaults
(`MainAxisAlignment.start`, not v1's `center`).

## 5. SDK

```
codelessly_sdk/lib/src/
  render/    NodeTree, NodeBox, layout render objects (fit, flex, freeform),
             paint (decoration, strokes), text, islands
  widgets/   one recipe per widget type: node → render chain or island
  runtime/   bindings, formulas, conditions, actions (pure Dart + ActionContext)
  services/  data sources, auth, storage, analytics: interfaces + plugins
  app/       Codelessly, CodelesslyWidget, controllers, navigation
```

The render layer comes from the prototype's `api_tree.dart`, with v1's
`SizeFit`, pins and boxes replaced by §3's layout. The layout render objects
(`RenderFitBox`, `RenderCodelesslyFlex`, `RenderFreeformLayout`,
`RenderHugCross`) are the SDK's own, moved over unchanged in behaviour.

## 6. Migration from v1

`v2/migrate` is a separate package. It depends on the v1 API, so it can use
v1's own decoders and box geometry, and it writes plain v2 JSON. It never
imports v2, so both versions coexist without a name clash. Uses:

* the one-time batch migration of stored projects and published layouts;
* the parity fixtures: every page in `CodelesslyEditor/test/fixtures/legacy_pages`
  is migrated, and v2 must decode and render it.

## 7. Proving it: parity

v2 has to render existing layouts the way v1 does. Goldens come from v1 (the
SDK 8.x widget renderer): each node's rect on every canvas of the 66 fixture
pages (50,918 nodes). They're stored as JSON in `CodelesslySDK/v2/test/goldens`.
v2's tests render the migrated pages and compare rects within 1 px, then
pixels. A widget type counts as ported when it's at 100% on the fixtures.

## 8. Release

1. `7.0.0-beta.N` / `9.0.0-beta.N` on pub.dev as slices land (prerelease, so
   `^6`/`^8` constraints never resolve to them).
2. Batch-migrate projects and publish v2 data alongside v1.
3. The v2 editor (the canvas prototype, moved onto these packages) runs side by
   side with the current editor.
4. GA: v2 moves to each repo's root.
