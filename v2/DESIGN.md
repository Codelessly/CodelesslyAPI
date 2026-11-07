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
| `bind` | `{path: expression}` | Properties bound to variables or formulas (`"props.text": "${user.name}"`; paths §5.1). |
| `actions` | `[Reaction]` | Trigger → the chain of actions it runs (§5.2). |
| `motion`, `scale`, `loops`, `transitions`, `inkWell`, `states`, ... | | Behaviours (§4.1), flat in the node. |
| `component` | `ComponentLink` | The component this node is the main node or an instance of (§4.2). |
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

`BorderRadius` corners are circular or elliptical, as Flutter's `Radius`:
`8` (every corner), `[16, 8]` (every corner 16 across, 8 down) or
`[tl, tr, br, bl]`, each a number or `[x, y]`. In Dart a corner's
`topLeft` is its horizontal radius and `topLeftY` its vertical one (the
same unless given).

Props hold their declared type: `Props.set` / `Node.withProp` coerce a value
through the prop's codec (`withProp(FlexProps.spacing, 31)` stores `31.0`)
and throw an `ArgumentError` for a value it can't read.

### 4.0 Prop types: what a panel reads

Every codec states what its values are (`PropCodec.type`, a `PropType`):
a kind (`boolean`, `integer`, `number`, `string`, `enumeration`, `value`,
`list`, `object`, `json`), the **Flutter type name** (`double`, `Color`,
`EdgeInsets`, `MainAxisAlignment`, `List<Paint>`, `ButtonStyle`), enum
value names, bounds, a list's item type and an object's fields (each a
`PropDef`). A prop is nullable when its default is null (`PropDef.nullable`).

The same declarations cover the rest of a node, so one kind of declaration
describes everything it holds: `LayoutFields` (`box`: width, height,
constraints, margin, padding, rotation, aspectRatio; `parentData`: flex,
squeezable, x, y, align), `DecorationFields`, `NodeFields`, and the fields
of every model type (`TextStyleFields`, `PaintFields`, `EffectFields`,
`BorderSideFields`, `ButtonStyleFields`, `InputDecorationFields`, the
chart records...). A parent declares what it reads from each child
(`WidgetSpec.childFields`: Flutter's parent data — `x`, `y` for a stack or
variance, `flex`, `squeezable`, `align` for a row or column), so a panel
shows a child's placement from its parent's declaration, apart from the
child's own API. Behaviours (§4.1) are declared too: `BehaviourFields`
has one field per flat node key (`motion`, `loops`, `drag`, `hero`...),
and each behaviour model has its own (`MotionFields`, `DragMotionFields`,
`ParticleEmitterFields`...; curves are the `AnimationCurve` enumeration,
durations whole milliseconds). A properties panel is generated from these alone; a
test (`value_fields_test.dart`) round-trips a sample value of every field
through its model's real JSON.

### 4.1 Behaviours

What a node does beyond its layout and paint is the same for every type, so
it isn't in `props`: it's `Node.behaviours` (`lib/src/behaviours.dart`), stored
flat in the node's JSON. Every key is optional and sparse.

| Key | Value | Flutter / meaning |
|---|---|---|
| `motion` | `Motion` | A transform over the layout (translate, scale, rotate, 3D, shift, origin, opacity, blur, path), and how it moves: transitions to new values, an entrance (`enter`, `enterFrom`), a loop, a spin, keyframes. Its values are the rest pose. |
| `scale` | number | `Transform.scale` about the centre; layout unchanged. |
| `loops` | `[LoopAnimation]` | Repeating animations (pulse, fade, scale, spin, bob, sway), outermost first. v1's `pulse` and `loopAnimation` both migrate here. |
| `transitions` | `{style, opacity, size}` | Implicit animations (`AnimatedOpacity`, `AnimatedSize`): `style` for opacity, scale, fills and visibility; `opacity` over it; `size`. |
| `inkWell` | `InkWellStyle` | `InkWell` colours: `overlayColor`, `splashColor`, `highlightColor`, `hoverColor`, `focusColor`. |
| `states` | `{WidgetState: {nodeId: patch}}` | What the node and its descendants change to while `hovered`, `focused`, `pressed`, `selected`, `disabled`, `dragged`: a JSON merge patch over each target's v2 JSON (`Node.patched`). |
| `tooltip`, `ignorePointer`, `zoomable`, `floating` | | `Tooltip`, `IgnorePointer`, `InteractiveViewer`, drawn above the screen at runtime. |
| `hero`, `flightKey` | tag or `{tag, flight}`; string | `Hero`; flying in from where the node with the same key was. |
| `draggable`, `dropTarget`, `drag` | `DragSource`, `DropTarget`, `DragMotion` | `Draggable`, `DragTarget`; a node that follows the pointer (swipe, spring back), or with a `DragTrack` a value control (knob, fader). |
| `reveal`, `strokePath`, `effectAnimations`, `particles`, `textDirection` | | Scroll into view; a line through points; one-shot effects; confetti; `Directionality`. |

Blur effects (`layerBlur`, `backgroundBlur`) stay in `decoration.effects`, which
a type without a box decoration (text, icon) keeps for its blurs only: they act
on whatever the node paints (`ImageFiltered`, `BackdropFilter`).

Durations are whole milliseconds; curves are `AnimationCurve`, Flutter's
`Curves` names. A behaviour bound to data keeps its binding in `bind` (`scale`,
`textDirection`, `motion.rotate`, ...).

**Editor state stays out.** v1's `aspectRatioLock` only locks the editor's
resize handles; it isn't a runtime property (`layout.aspectRatio` is), so the
API doesn't model it: the migration drops its default (`false`) and leaves
`true` under the node's `v1` key with the other editor metadata
(`createdTimestamp`), for the editor to move into its own state.

### 4.2 Components

A component is a node tree saved to a project's library and placed as
instances (`lib/src/components.dart`).

* **`ComponentDefinition`** (the library entry, stored outside pages; v1's
  `CustomComponent` / `PublicComponent`): `id`, `name`, `version`, `size`
  (the root's design size), `document` (a `LayoutDocument` whose single
  root is the component's top node, with its nodes, variables and
  conditions), `preview` (`url`, `blurhash`), `source` (`project`, `page`,
  `node`: where it was made from) and `createdAt` (ms since the epoch).
* **`ComponentLink`** (`Node.component`): on the component's main node
  (`"role": "main"`, v1's `component` marker) and on the top node of each
  instance (`role` defaults to `instance`), with the component `id` and the
  `version` it was made from or last updated to; an instance below the
  definition's version has an update.
* **An instance is a copy**: the component's nodes with their own ids under
  the linked top node. Editing them is overriding; updating an instance
  replaces its nodes with the definition's (keeping the top node's place
  and sizing), as v1 did.
* **Settings** (`ComponentLink.settings`, v1's `componentSchema`): what the
  component lets an instance customise, shown by the editor as a panel.
  Each is `{label, type, value, targets}`, or a `group` with its own
  `settings`; `type` names the control (`string`, `number`, `bool`,
  `color`, `radius`, `spacing`, `options`, `icon`...), `value` is the
  component's value (what reset restores), and control options (`min`,
  `max`, `fractionDigits`, `options`, `insetType`...) ride along. A target
  is a node and a binding path (§5.1), as a condition's `set` entry:
  `{"node": "label", "path": "props.text"}`. Targets name the ids of the
  tree they sit in, so a copy remaps them (`ComponentLink.remapped`).

```json
"card": {"type": "stack", "children": ["label"],
         "component": {"id": "cmp1", "role": "main", "version": 3, "settings": [
           {"label": "Title", "type": "string", "value": "Hello",
            "targets": [{"node": "label", "path": "props.text"}]}]}}
```

External components (widgets the app builds by a builder id) are a widget
type, `external`, not components.

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

A node's behaviours are layers of its render chain, outermost first, as SDK
8.x wrapped a node: margin → constraints → track pose → motion → scale →
rotation → (hover/press tracking) → loops → opacity → blurs → stroke path →
content. A design canvas draws them at rest (the motion's values, each loop's
first frame, a track at its variable's value); a running app
(`NodeView(interactive: true)`) plays them with tickers in the render objects
and applies interaction state patches to the nodes they target.

The render layer comes from the prototype's `api_tree.dart`, with v1's
`SizeFit`, pins and boxes replaced by §3's layout. The layout render objects
(`RenderFitBox`, `RenderCodelesslyFlex`, `RenderFreeformLayout`,
`RenderHugCross`) are the SDK's own, moved over unchanged in behaviour.

### 5.1 Variables, conditions and bindings

**Variables** (`Variable`, `lib/src/variables.dart`): a name, a `VariableType`
(`integer`, `text`, `decimal`, `boolean`, `color`, `list`, `map`, `image`,
`choice`) and a default `value` held as its type holds it (JSON-native:
`3`, `4.5`, `true`, `"#FFFF0000"`, `[...]`, `{...}`), or a `formula` (what goes
in `${= ...}`) that computes it; a formula with `parameters` is a function
formulas call by name. Choice variables list their `options`. v1 stored
every value as text and a formula as a `${= ...}` value: the migration
types them once.

**Conditions** (`Condition`, `lib/src/conditions.dart`): an ordered list of
branches, `if` / `else if` / `else`. A branch has a `when` (`Predicate`: a
`Comparison` `{left, op, right}` with v1's loose operators, or a `Junction`
`{"and"|"or": [...]}`; none for `else`) and `set`, the node properties it
gives values (`{node, path, value}`; a string value is an expression). For a
property, the first branch that holds and sets it wins; conditions win over
the node's own binding, which wins over the node's value (v1's precedence).

**Where they live**: per screen, in the layout document next to the nodes
(read typed through `LayoutLogic` / `doc.logic`):

```json
"variables":  {"canvas-a": [{"name": "count", "type": "integer", "value": 0}]},
"conditions": {"canvas-a": [{"id": "c1", "branches": [
  {"when": {"left": "${count}", "op": "greaterThan", "right": "5"},
   "set": [{"node": "badge", "path": "visible", "value": true}]},
  {"set": [{"node": "badge", "path": "visible", "value": false}]}]}]}
```

**Expressions**: `${path}` reads a value (`user.name`, `cart[0].qty`,
`title.length`, `pal[item.kind]`), `${= formula}` computes one (SDK 8.x's
formula language, unchanged). A binding that is exactly one of them gives
the value as is (a list stays a list); any other text with `${...}` is text.
A text node's own `props.text` may hold `${...}`: it is interpolated run by
run. Names come from scopes: the screen's variables, the list item (`item`,
`index`, `parent`), and what the app provides (`route`, `screen`,
`storage`, `auth`, `data`...).

**Binding paths** (`Node.bind` keys, `BindPaths` in `lib/src/bindings.dart`):
a path into the node's v2 JSON, with `[i]` for a list index, a paint or
effect id for the item with that id, and `*` for every item.

| Path | Value | v1 key |
|---|---|---|
| `visible` | bool; false collapses the node (no space, no gap) | `visible` |
| `opacity` | 0–1 | `opacity` |
| `layout.width`, `layout.height` | a number (design size, fit kept) or `{"fill": n}`... | `width`, `height` |
| `layout.flex` | int ≥ 1 | `flex` |
| `layout.rotation` | degrees | `rotation`, `rotationDegrees` |
| `layout.margin`, `layout.padding` | n, `[h, v]`, `[l, t, r, b]` or `{top: n}` | `margin`, `padding` |
| `layout.x`, `layout.y` | distance from the start, or a position map | `x`, `y` |
| `layout.<field>` | any other layout field, as its JSON | |
| `decoration.fills[0]` | a color, image URL or paint: the first fill | `fill` (box types) |
| `decoration.fills.<paintId>` | the same, for that paint | `fill-<id>` |
| `decoration.fills.<paintId>.color` | a color (opacity kept) | |
| `decoration.fills.<paintId>.image.url` | the image | `fill-image-<id>` |
| `decoration.fills[0].stops[i].color` | `#RRGGBB` keeps the stop's alpha | `fill-stop-<i>` |
| `decoration.strokes[0]`, `decoration.strokes.<paintId>` | a stroke paint | `stroke`, `stroke-paint-<id>` |
| `decoration.strokeWidth`, `decoration.radius` | number; radius also `[x, y]` or `[tl, tr, br, bl]` (each n or `[x, y]`) | `strokeWeight`, `cornerRadius` |
| `decoration.effects.*.visible`, `.<effectId>.visible` | bool | `effectsVisible`, `effect-visible-<id>` |
| `decoration.effects.*.color` / `.offset.dx` / `.offset.dy` / `.blurRadius` / `.spreadRadius` | shadows | `effectsColor`, `effectsOffsetX`... `shadow-color-<id>` |
| `props.<prop>` | the widget's prop, by its declaration's codec | per type (`value`, `max`, `spacing`...) |
| `props.<prop>.<field>` | a field of a structured prop | `fillColor` → `props.decoration.fillColor` |
| `props.style.<field>` (text) | the base style and every run's | `fill`/`textColor` → `props.style.color`, `fontSize`, `fontWeight`... |
| `data` | the items a list, grid or page view builds one per (its item count follows) | `data` |
| `scale`, `textDirection`, `motion.<field>`, `flightKey`, `tooltip`... | a behaviour (§4.1) | `drawScale`, `layoutDirection`, `motion.*` |
| `selected`, `disabled`, `semantics.*`, `enabled` | reserved: kept, not applied yet | `selected`, `semanticLabel`, `node_enabled` |

Values are read loosely, as v1 read them (`"12"` is a number, `1` true,
`"#F00F00"` a color); a value that can't be read leaves the property as it
was. The SDK compiles a node's bindings once (`NodeBindings`) and applies
them on the typed node (no JSON round trip for the common paths), watching
only the names each binding reads.

### 5.2 Reactions and actions

**Reactions** (`Node.actions`, `Reaction`, `lib/src/triggers.dart`): a
`Trigger` and the chain of actions it runs, in order. All the reactions of a
node to one trigger run as one chain.

```json
"actions": [
  {"id": "r1", "trigger": {"type": "click"},
   "actions": [
     {"type": "setVariable", "variable": "count", "op": "add", "value": "1"},
     {"type": "if", "condition": {"left": "${count}", "op": "greaterThan", "right": "9"},
      "then": [{"type": "navigate", "mode": "replace", "to": "done", "params": {"n": "${count}"}}]}]}
]
```

**Triggers** (`TriggerType`): pointer ones on the node's box (`click`,
`doubleTap`, `longPress`, `hold`, `secondaryClick`, `pointerDown`/`Up`,
`hover`, `cursorEnter`/`Exit`, `swipeLeft`/`Right`/`Up`/`Down`, `drag`,
`dragEnd`, `wheel`, `pinch`), an input's (`changed`, `changeEnd`,
`submitted`, `editingComplete`, `focusGained`/`Lost`), a screen's (`load`,
`valueChanged`, `timer`, `clock`, `keyDown`/`Up`, `backPressed`: back was
pressed while the canvas's `props.blockBack` holds, usually bound to
`${= dirty}`; the screen stays and these run, a navigate pop from them is
never blocked), scrolling and viewport (`scroll`, `scrollEnd`,
`enterViewport`, `exitViewport`), drag and drop (`dropFull`: let go on a
target whose `fullIf` holds) and `reorder`. Settings are sparse: `debounceMs`, `variable`, `intervalMs`,
`key` (`KeyCombo`: `Meta+Enter`), `when`, `holdMs`, `every`/`runWhen`/
`lookaheadMs`, `visibleFraction`.

**Actions** (`ActionDef`, sealed, one immutable class per type,
`lib/src/actions.dart`): `navigate` (push, pop, replace, reset; params,
base, transition), `openModal` (dialog, sheets, full screen, popover),
`closeModal` (its result is the opener's `${result}`), `openLink`,
`submitForm`, `setValue` (node properties at binding paths: set, toggle,
sync), `setVariant`, `setVariable` (a `ValueWrite`: `op` set, toggle,
add, subtract, insert, insertAll, removeAt, remove, update; `index`,
`mapKey`; a number glides over `animateMs` along `curve`, the chain
waiting), `animateVariable` (a number variable's timeline: play, pause,
resume, stop, seek), `callFunction`, `runScript` (a layout script, below;
`onError` reads `${result.error}`), `callApi` (`onSuccess` / `onError`),
`setStorage`, `cloudDocuments`, `loadCloudData`, `cloudData`, `cloudBatch`,
`cloudFiles`, `auth`, `if`, `forEach` (each turn reads `${loop.item}`,
`${loop.index}`), `delay`, `showToast`, `confirm` (their cosmetics in
`look`), `copyToClipboard`, `editText`, `focus`, `scrollTo` (`axis`: only
the scroll views along it), `speak`, `playSound`, `paywall`,
`controlDrag` (`step` turns a drag track `steps`), `playAnimation`,
`haptic` (`HapticFeedback`: selection, light, medium, heavy, vibrate).
`navigate` and `openModal` take a `routeTransition` (`RouteTransition`,
`lib/src/route_transition.dart`; or a bare preset name): the incoming
screen's `enter` and the covered one's `exit` sides (a `Motion`, a
`reveal` clip, a curve, `delayMs`, `durationMs`), `popEnter`/`popExit`
for closing, `durationMs`, `barrierColor`, `opaque`, `swipeBack`, a
`dismiss` drag; a `preset` (`iosPush`, `sharedAxisX`, `cube`...) fills in
what's left out. Every action can be off
(`enabled: false`), not awaited (`nonBlocking`), or run only while a
predicate holds (`when`, §5.1's `Predicate`). Text fields are expressions;
`${result}` is what the previous action gave (the trigger's event first).
An unknown type decodes as `UnknownAction` and round-trips.

**Scripts** (`ScriptDef`, `lib/src/scripts.dart`): JavaScript a layout
runs, in its document's `scripts` list (project scripts, then page scripts
with a `pageId`; a page script wins by name): `name`, `params`
(`{name, defaultValue}`), `source`, `capabilities` (`variables.read`,
`variables.write`, `nodes.read`, `navigation`, `api`, `cloud`, `actions`,
`clock`), `timeoutMs`, `memoryLimitMb`, `tests`. The SDK asks the app's
`ScriptRunner` (`Services.scripts`) to run one; none by default.

**Variables** can `persist`: the app keeps the value on the device
(starting from it next time, saving every change). The publish model
carries the app's `appIdentity` (`AppIdentity`: name, title template,
description, theme color, per-page overrides, and the web host's icons,
social card, manifest and splash kept as they are, in its own JSON:
colors CSS hex).

The SDK runs them (`runtime/actions`): `CodelesslyActions` (the
`ActionRunner`) with one typed handler per type over an `ActionContext`
(no `BuildContext`); UI effects go through an `ActionUi` the app shell
implements (`NavigatorActionUi` is a Navigator-based default). A failing
action stops its chain and is reported; a chain stops when its node leaves
the tree. `TreeReactions` wires triggers into the render tree of an
interactive `NodeView`.

## 6. Migration from v1

`v2/migrate` is a separate package. It depends on the v1 API, so it can use
v1's own decoders and box geometry, and it writes plain v2 JSON. It never
imports v2, so both versions coexist without a name clash. Uses:

* the one-time batch migration of stored projects and published layouts;
* the parity fixtures: every page in `CodelesslyEditor/test/fixtures/legacy_pages`
  is migrated, and v2 must decode and render it.

A node's component marker (`componentId`, `markerType`, `componentVersion`,
`componentSchema`) becomes its `component` link (§4.2): each setting's v1
field paths (`label.characters`, `card.fills.0.color`) become targets on
binding paths, and one with no v2 path keeps its v1 path (`"v1"`) and is
reported. `migrateComponent` converts a stored component to a
`ComponentDefinition`. v1 corner radii keep each corner's x and y; a
linked elliptical radius (SDK 8.x drew the node's ellipse) becomes the
node's design size, `[w, h]`.

v1 binding keys (`BaseNode.variables`) become §5.1's paths; a bare v1
value (`dLen`, which v1 read as `${dLen}`) is written as `${dLen}`, and
one that read nothing in v1 (`74.2`) is dropped. A layout's v1 canvas
variables and conditions (the publish model's `SDKLayoutVariables` /
`SDKLayoutConditions`) are passed to `migrateDocument(variables:,
conditions:)` and become its `variables` and `conditions` keys; each
condition's set-value actions become `set` entries on binding paths.

v1 reactions (a node's, an app bar icon's, a navigation item's, an input
icon's, a condition's other actions) become §5.2's reactions: one per v1
reaction, its trigger and a chain of its one action, every v1 action type
mapped (`navigation` → `navigate`, `showDialog` → `openModal`, `link` →
`openLink`, `conditional` → `if`, `setCloudStorage` → `cloudDocuments`,
`loadFromCloudStorage` → `loadCloudData`, the `interval` trigger → `timer`,
`keyPress` → `keyDown`; a set variable's typed operation → its `op`; a set
value's property names → the target node's binding paths; a toast's and
a confirm's cosmetics → their `look`; a haptic's `when` formula → the
common `when`, `isTrue`; a canvas's `blockBack` binding →
`props.blockBack`). A publish layout's `SDKLayoutVariables.scripts`
become its document's `scripts`, `VariableData.persists` a variable's
`persist`, the model's `appIdentity` the v2 one (normalized by v1's
decoder). Publish
layouts carry their variables and conditions this way too, and the publish
model's APIs as v2 `HttpApi`s.

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
