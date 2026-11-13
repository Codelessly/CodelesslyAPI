# Codelessly API and SDK: design

**Packages:** `codelessly_api` 24.x, `codelessly_sdk` 24.x

Both packages are built on the architecture the canvas prototype proved:
immutable nodes with no layout results in them, rendered straight into
Flutter render objects.

## 1. What each layer owns

| Package | Owns | Never contains |
|---|---|---|
| **`codelessly_api`** core (`core.dart`, `lib/src/core`) | Flutter's widget vocabulary as data: one declaration per widget, Flutter names and defaults. Immutable nodes with value equality. A flat node map. The layout document, variables, conditions, bindings, scripts, the core actions as data, and the `Catalog` that declares them (§8). JSON: sparse, total, versioned. | Flutter imports. Computed geometry. Editor state. Globals. Network code. Any feature library: the boundary test (`test/library_boundaries_test.dart`) reads the imports. |
| **`codelessly_api`** feature libraries (`data.dart`, `auth.dart`, `commerce.dart`, `media.dart`, `engage.dart`, `publish.dart`, `managed.dart`; `lib/src/features/<x>`) | Each over the core: its action family, node types, data sources and models (cloud queries, HTTP APIs, paywalls, the publish model, managed components, hosted plugins), and a `const Catalog` of its declarations. `codelessly_api.dart` exports all of them and `standardCatalog`. | Imports of another feature (except managed and engage over publish). |
| **`codelessly_sdk`** render | Nodes → Flutter render objects, one `NodeBox` per node, with no widget or element per node. Widgets that need an element tree (text fields, video, charts) are islands. | Editor flags. Data or network code. Static registries. |
| **`codelessly_sdk`** runtime | `Codelessly`, `CodelesslyWidget` and controllers. Bindings compiled once per layout. Actions as typed handlers over an `ActionContext`. Data sources, auth, navigation and analytics as plugins configured by the app. | `BuildContext` in actions. JSON round trips during a build. Hard-wired Firebase. |
| **`codelessly_sdk`** features | Auth, data, commerce, media, engage and hosted plugins as `CodelesslyFeature`s: each pairs an API library's catalog with the handlers, recipes and scopes that run it. The render core, widgets and core runtime import `package:codelessly_api/core.dart` only (`test/core_only_import_test.dart` follows the imports into the API). | Imports between features. |

The editor builds on all three; the API and SDK know nothing about it.

## 2. JSON contract

### 2.1 Versions and storage

* Every document carries `"schema": 2`. Decoders run `LayoutDocument.migrateSchema` from
  any older schema on load, so the format can keep improving without
  breaking stored data.
* A project's publish model is
  `publish/{projectId}` and each layout `publish/{projectId}/layouts/{id}`
  (`publish_preview/...` for the editor's preview, `templates/...` for
  templates), in the current format with `"schema": 2`; a layout too large for one
  Firestore document keeps its nodes gzipped and base64 encoded in
  `compressedNodes` (`{"nodes": {...}}`). A document in any other format
  fails to load with a clear message (§5.4).
* **Decoding is total.** Unknown keys round-trip in `extra`. A node type no
  declaration knows decodes as a `Node` with that type, its props kept in
  `Props.unknown` (the SDK renders it with the recipe the app gives for the
  type, `CodelesslyConfig.recipes`, else as an empty box of its size). Bad
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

`key` is a node's name in its tree: the editor API's `nodes.insertTree` gives each
node of a tree it inserts a name, so the tree's own actions and states can
name a node before it has an id, and `nodes.export` gives the tree back
with its keys. It is a node's identity in its tree, like `id` and `name`,
not a behavior or a widget parameter, so it is a top-level node field
(not in `props`, not in `extra`); it doesn't affect rendering.

### 2.3 Every node

| Key | Type | Meaning |
|---|---|---|
| `type` | string | Widget type (`row`, `text`, ...). |
| `name` | string | Display name. |
| `key` | string | The node's name in the tree it was inserted with (`"content"`), unique in that tree. See below. |
| `children` | `[id]` | Ordered children (row, column, stack, list...). |
| `slots` | `{name: id}` | Named children (`body`, `appBar`, `leading`...). |
| `visible` | bool | `false` hides the node; default `true`. |
| `opacity` | 0–1 | Default 1. |
| `layout` | `Layout` | How the node sizes itself and sits in its parent (§3). |
| `decoration` | `Decoration` | Fills, strokes, radius, shadows, blurs, clip (box types). |
| `props` | per type | The widget's own parameters, Flutter names (§4). |
| `bind` | `{path: expression}` | Properties bound to variables or formulas (`"props.text": "${user.name}"`; paths §5.1). |
| `actions` | `[Reaction]` | Trigger → the chain of actions it runs (§5.2). |
| `motion`, `scale`, `animations`, `transitions`, `inkWell`, `states`, ... | | Behaviors (§4.1), flat in the node. |
| `component` | `ComponentLink` | The component this node is the main node or an instance of (§4.2). |
| `extra` | map | Unknown keys, round-tripped. |

## 3. Layout

The model stores the layout intent, in Flutter's terms, and nothing the
renderer computes.

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
  "rotation": 15,                 // degrees, about the center
  "aspectRatio": 1.5
}
```

* **Sizing per axis** is `fixed`, `fill` (Expanded/stretch), `flexible`
  (Flexible, loose) or `hug` (size to content). The number is the design size:
  the size used for `fixed`, and the fallback when a mode can't apply.
  A child that fills the cross axis of a row or column hugging that axis
  stretches to the thickness its siblings give, and its number is measured
  as its own thickness: a timeline rail that should add no height of its
  own fills with 0.
* **Freeform position per axis** follows `Positioned`/`Align`: `{"start": d}`,
  `{"end": d}`, `{"start": a, "end": b}` (stretch between), `{"align": -1..1}`
  (`Align`, by the laid-out size) or `{"relative": d}` (d from the start at
  design size, keeping its share of the free space as the parent resizes).
  These are distances in the parent's padded box, to the child's margin box.
* `flex` and `align` apply under row/column parents; `x` and `y` apply under
  freeform parents. Values for another kind of parent are kept, so moving a
  node back restores them, and the renderer ignores them.

## 4. Widgets and props

Each widget has one declaration: its name, its props with Flutter's types and
defaults, and which slots it takes. From that one declaration a generator
emits the props class (immutable, `==`, `copyWith`, sparse JSON) and the
metadata the editor's panels and the SDK use.

The declarations are collected in catalogs (§8): `Catalog.core` holds the
core's node types (`coreWidgetSpecs`), the media library's `mediaCatalog`
holds `video`, `embeddedVideo`, `audioPlayer` and `webView`, and a plugin
adds its own `vendor.name` types. `Widgets.all` / `Widgets.of` are views of
`standardCatalog`.

| Type | Flutter |
|---|---|
| `canvas` | Scaffold (screen) |
| `stack` | Stack (freeform) |
| `box` | Container (no children) |
| `row`, `column` | Row, Column |
| `text` | Text.rich |
| `icon` | Icon / SVG |
| `spacer` | Spacer / SizedBox |
| `variance` | variant switcher |
| `pagination` | page controls for a list's pagination |
| `tableView` | TableView (two_dimensional_scrollables); slots `cell`, `columnHeader`, `rowHeader`, `corner` |
| ... | one per remaining widget type |

Value types mirror Flutter: `Color` (`#AARRGGBB`), `EdgeInsets`,
`BorderRadius`, `Alignment`, `BoxConstraints`, `TextStyle`, `BoxShadow`,
`Gradient`, and enums with Flutter's value names and defaults
(`MainAxisAlignment.start`). `TextStyle` also holds
`fontFeatures` (OpenType settings, `"lnum"`, `"liga=0"`; `tnum` as
`tabularFigures`) and `leadingDistribution`; a gradient `Paint` with
`gradientPerSubpath` (JSON also `gradientUnits: "subpath"`) is laid out in
each shape of a path.

**Lists**: `listView` and `gridView` take `pagination` (a controller named
by its `name`: source, mode, page size, pull to refresh), `reorder`
(dragging items, between lists of a `group`), and a list `sections` and
`swipeActions`. Their footers, section header and placeholder are the
list's slots (`loading`, `error`, `end`, `sectionHeader`,
`reorderPlaceholder`); the first child stays the item template. A row or
column's `squeezeChildren: false` lets children overflow as Flutter's
does; a scrolling one's `fillViewport` makes its content at least the
viewport long.

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
child's own API. Behaviors (§4.1) are declared too: `BehaviorFields`
has one field per flat node key (`motion`, `animations`, `drag`, `hero`...),
and each behavior model has its own (`MotionFields`, `DragMotionFields`,
`ParticleEmitterFields`...; curves are the `AnimationCurve` enumeration,
durations whole milliseconds). A properties panel is generated from these alone; a
test (`value_fields_test.dart`) round-trips a sample value of every field
through its model's real JSON.

### 4.1 Behaviors

What a node does beyond its layout and paint is the same for every type, so
it isn't in `props`: it's `Node.behaviors` (`lib/src/core/behaviors.dart`), stored
flat in the node's JSON. Every key is optional and sparse.

| Key | Value | Flutter / meaning |
|---|---|---|
| `motion` | `Motion` | Flutter's `Transform` over the layout, nothing temporal (docs/design/03-motion.md): `translateX/Y`, `shiftX/Y` (the node's size), `scale` times `scaleX/Y`, `rotate`, `rotateX/Y` with `perspective`, about `alignment`; `backfaceHidden`; `path` (`PathFollow`: `path`, `viewBox`, `progress`, `orient` `none`/`tangent`/`upright`/`uprightFlip`; a closed path wraps its progress). A path is followed from the node's own place (offsets from its start point), or in a `viewBox` over the parent. Its values are the rest pose; how they move is the node's `animations` and `transitions`. The legacy flat keys read: the pose's (`originX/Y`, the `path*` keys), `opacity` and `blur` as the node's opacity and a `motionBlur` layer blur, and the timing, entrance, loop, spin, keyframes and shimmer as transitions and animations (guide chapter 8). |
| `scale` | number | `Transform.scale` about the center; layout unchanged. |
| `animations` | `[NodeAnimation]` | Flutter's `AnimationController` as data, outermost first (guide chapter 8): `id`, `duration`/`reverseDuration`, `delay`, `curve`, `repeat` (`{reverse, count}`), `autoplay`, `playKey`, `paused`, `phase`, `spring`, `progress` (an expression instead of a clock), `alignment`, `previewAt`, and `tracks` (`Tween`/`TweenSequence`/`Interval`/`CurveTween` on a binding `path` of the node or of `node`, or on a `variable`; `blend` `replace`, `add` or `multiply`; `wave`s). `preset` with `params` is a short form (`pulse`, `fade`, `scale`, `spin`, `bob`, `sway`, `flicker`, `shake`, `bounce`, `pop`, `wiggle`, `jelly`, `flash`, `keyframes`, `enter`). Its state reads as `${animation.<id>.value}`, `.status`, `.isAnimating` in the node and the nodes inside it. The legacy `loops` and `effectAnimations` (and `motion.pulseKey`) read as these. |
| `transitions` | `[Transition]` | Implicit animations (`AnimatedContainer`, `AnimatedOpacity`), one per `property` path or prefix (`motion`, `motion.rotate`, `opacity`, `*`): `duration`, `delay`, `curve` or `spring`, `keyframes` (a prefix's as poses) with `interpolation`. A change there tweens from what is shown; the longest match wins; a prefix moves as one; a path an animation plays isn't transitioned. The legacy `{style, opacity, size}` object reads (`style` as `opacity`, `scale`, `decoration.fills`, `visible`; `size` as `layout`). |
| `shimmer` | `Shimmer` | A band of light over what the node paints (`ShaderMask`): `color`, `strength`, `width`, `angle`, `position`; the `shimmer` animation preset sweeps it. |
| `inkWell` | `InkWellStyle` | `InkWell` colors: `overlayColor`, `splashColor`, `highlightColor`, `hoverColor`, `focusColor`. |
| `states` | `{WidgetState: {nodeId: patch}}` | What the node and its descendants change to while `hovered`, `focused`, `pressed`, `selected`, `disabled`, `dragged`: a JSON merge patch over each target's JSON (`Node.patched`). |
| `tooltip`, `ignorePointer`, `floating` | | `Tooltip`, `IgnorePointer`, drawn above the screen at runtime. |
| `hero`, `flightKey` | tag or `{tag, flight, placeholder}`; string | `Hero` (`flight`: `standard`, `morphCorners`, `arc`, `morph`, `fadeThrough`, `containerTransform`; `placeholder: source` keeps the source drawn until the destination's image loads); flying in from where the node with the same key was. |
| `draggable`, `dropTarget` | `DragSource`, `DropTarget` | `Draggable`/`LongPressDraggable` (`childWhenDragging`, `feedback`, `dragAnchor`, a `returnSpring`), `DragTarget` (`accepts`, `acceptIf`; list insertion `listNodeId`, `slot`, `slotSize`, `slotWhenRefused`; `fullIf`). |
| `track` | `Track` | Flutter's `Slider` along a line, an arc or a `path` (`PathFollow`): `variable`/`value`, `min`, `max`, `step`, `clamp`, `input`, `allowedInteraction`, `hitArea`, `pixelsPerRange`, `wheelStep`/`keyStep` (0 off), `detent`, `overscroll`, `physics` (a coasting fling), settle and snap; guide chapter 10. |
| `dismissible` | `DismissibleBehavior` | Flutter's `Dismissible`: `directions`, `dismissThresholds`, `flingVelocity`, `resistance`, `movementDuration`/`curve`, a return (`returnDuration`/`returnCurve` or `returnSpring`). |
| `pan` | `Pan` | Follows the pointer and springs back or stays: `axis`, `release`, rest `x`/`y`, `xVariable`/`yVariable`, `physics`, `bounds`, `minX`...`maxY` (a bottom sheet). |
| `reorderHandle` | bool | A reorderable list row's drag handle (`ReorderableDragStartListener`). |
| `transformGesture` | `TransformGesture` | Pinch, pan and rotate (`InteractiveViewer` and more) with `physics`, `bounds`, wheel and double-tap zoom, two-way pose variables and `handles`. |

The legacy `drag` reads as `track` (its `track`), `reorderHandle` (`reorder: true`), `dismissible` (`release:
dismiss`, its old defaults written out) or `pan`; `zoomable: true` as `transformGesture`'s zoomable form. Only
the new keys are written (docs/design/04-drag-and-track.md).
| `flip`, `tilt` | `FlipCard`, `Tilt` | A two-sided card turning over (first child front, second back; a runtime 3D turn, not the editor's mirror); a 3D tilt toward the pointer. |
| `reveal`, `strokePath`, `particles`, `textDirection` | | Scroll into view; a line through points; confetti; `Directionality`. |
| `flight` | `Flight` | How a `flightKey` node flies in from where the node with the same key was: a spring, or a curve over a duration with lift, swell, turns and a trail. |
| `typewriter` | `Typewriter` | A text node typing its text out (the layout is the whole text's; only what's typed is painted). |
| `sticky` | `true` or `{offset}` | Pinned at its scrolling view's leading edge while its parent is in view (`SliverPersistentHeader(pinned)`); `${sticky.stuck}`. |
| `viewProgress` | `ViewProgress` | `${view.progress}`: how far the node has scrolled through the viewport, optionally written to a variable. |
| `measure` | `Measure` | The node's laid-out box, written to a variable as layout changes. |
| `customPaint` | `CustomPaint` | Flutter's `CustomPaint`: `painter` drawn behind the node's content and `foregroundPainter` over it, each a list of draw ops that are `Canvas` calls (`path`, `line`, `rect`, `rrect`, `circle`, `oval`, `arc`, `points`, `paragraph`, `image`) with a `paint` (Flutter's `Paint`), `group` (save, transforms, clips, a layer, restore) and `repeat` (over a list: `item`, `index`, `count`); values may be inline expressions; a `viewBox` with a `fit`; ops with `hit` are hit regions whose id, view point and item reach the node's pointer reactions. Guide chapter 7. |

`strokePath.progress` is a bindable fraction (0–1, default 1). It reveals the stroke by path length; dash patterns are clipped to that revealed prefix.

A spring is one value wherever it is: `Spring`, Flutter's
`SpringDescription` (`{stiffness, damping, mass}`, or `{duration, bounce}`
for `withDurationAndBounce`), on an animation, a transition, a
drag source's `returnSpring`, a track's `settleSpring`, a dismissible's
`returnSpring`, a flip card and a
route's dismiss; each owner's legacy flat keys read as it. A release's
motion is one model wherever it is: `GesturePhysics` (a fling with
`friction`, `overscroll` past `bounds`, a `spring`, a `snap` to points, a
grid or the edges; `{"preset": "bouncy"}` reads as a preset) for
`pan.physics`, `track.physics` (its coast) and `transformGesture.physics`.

Blur effects (`layerBlur`, `backgroundBlur`) stay in `decoration.effects`, which
a type without a box decoration (text, icon) keeps for its blurs only: they act
on whatever the node paints (`ImageFiltered`, `BackdropFilter`).

Durations are whole milliseconds; curves are `AnimationCurve`, Flutter's
`Curves` names. A behavior bound to data keeps its binding in `bind` (`scale`,
`textDirection`, `motion.rotate`, ...).

**Editor state stays out.** An aspect-ratio lock only locks the editor's
resize handles; it isn't a runtime property (`layout.aspectRatio` is), so the
API doesn't model it. The editor keeps such state itself.

### 4.2 Components

A component is a part of a user interface defined once and used by
reference (docs/design/06-sections-and-components.md; `lib/src/core/sections.dart`).
Its Flutter shape is a widget class: a declaration of parameters, slots
and callbacks, and a `build` that places them.

* **A definition is a document**: a `LayoutDocument` with one root that is
  not a canvas, and a `widget` declaration, which is the catalog's widget
  JSON (`type`, `doc`, `children`, `slots`, `props` as `PropDef` JSON with
  an optional `"required": true`) plus `events` (`EventSpec`: key, payload
  type, doc). Its `variables` (keyed by the root's id) exist once per
  instance, like a `State`'s fields; its `previews` are named parameter
  sets with a size (Flutter's `@Preview`). `LayoutDocument.widget`,
  `componentRoot`, `previews` and `componentVariables` read it
  (`ComponentDocument`); everything else round-trips in `extra`.
  The type name is UpperCamelCase, like a Dart class, and a project file
  is named after it (`components/PlanCard.json`).
* **A call is one node** whose `type` is the component's type, with `props`
  (literal, or bound in `bind` as `props.<key>`, like any node's), the
  `children` / `slots` it passes and reactions to its events. The
  definitions' declarations form a catalog (`ComponentLibrary.catalog`):
  a page decoded with it holds each call's props typed; without it they
  stay raw (`Props.unknown`) and round-trip.
* **Parameters** are read inside as `${props.<key>}`. A definition reads its
  parameters, its own variables, the project's variables and the runtime's
  scopes (`screen`, `route`, `theme`...), never its caller's variables.
  A **`variable` parameter** (`PropType.variable`, written
  `{"kind": "variable", "of": {...}}`; its `PropKind` is `string`, the
  variable's name, so no new kind) passes one of the caller's variables by
  name: `${props.open}` reads it live and `setVariable "props.open"` writes
  it (a `ValueNotifier` passed in).
* **Slots**: a `slot` node (`SlotProps`, prop `name`, default `children`)
  is replaced by what the call passes: its `children`, or `slots[name]`;
  with nothing passed it shows its own children. Passed nodes belong to the
  caller and read its scope.
* **Events**: `componentEvent` (`ComponentEventAction`, a core action) fires
  one of the declared events with a value; the call's reaction
  `{"trigger": {"type": "event", "event": "<key>"}}` runs in the caller's
  scope with the value as `${result}`.
* **The seam**: the call and the definition's root are one box
  (`seamCall`): the call's layout but for padding sizes and places it; the
  root keeps its padding, decoration and content; `visible` is the AND of
  both, `opacity` their product. A call has no `decoration` or
  `layout.padding`.
* **Ids are local** to each document. The SDK keys an instance's boxes by
  (node id, `ComponentInstance(outer, call id, type)`), as it keys list
  items; tools name a node inside an instance by a path of call ids
  (`plans/card1/cta`).
* **A site** (`SiteManifest`, `site.json`): its pages, its components and
  its project variables (read by bare name everywhere; a page or component
  variable of the same name is `duplicate_variable`).
* **No overrides**: an instance changes only what its definition declares
  as parameters and slots.

`validateProject` checks the definitions as a library (`invalid_component`,
`component_id_mismatch`, `duplicate_component`, `component_cycle`, found
transitively) and every call against its declaration (`unknown_component`,
`unknown_prop`, `wrong_type`, `missing_prop`, `unknown_slot`,
`children_not_allowed`, `unknown_event`, `call_field_not_allowed`, a
`variable` parameter's variable), and each definition against itself
(`unknown_name` for a page variable it reads, an undeclared slot or event,
`root_placement_bound`).

The SDK renders an instance as ordinary boxes in the screen's render tree,
one per definition node per instance, from a `ComponentRegistry`
(`Codelessly.components`); editing a definition replaces its document and
re-applies only the nodes that changed, in every instance. Loading
definitions from a publish is not done yet: an app fills the registry
itself (docs/design/06, "Not done").

**Copies, still read.** Before components by reference, a component was a
`ComponentDefinition` in the library (`id`, `name`, `version`, `size`,
`document`, `preview`, `source`, `createdAt`) and an **instance was a copy**
of its nodes with their own ids under a top node carrying a
**`ComponentLink`** (`Node.component`: the component `id`, `role` `main` or
`instance`, the `version` it was made from, and **`settings`**: what an
instance may customize, `{label, type, value, targets}` with targets as
node + binding path pairs, remapped on every copy). These decode, encode
and render exactly as before; converting them into calls is the editor's
later work (docs/design/06 §5.9).

```json
"card": {"type": "stack", "children": ["label"],
         "component": {"id": "cmp1", "role": "main", "version": 3, "settings": [
           {"label": "Title", "type": "string", "value": "Hello",
            "targets": [{"node": "label", "path": "props.text"}]}]}}
```

External components (widgets the app builds by a builder id) are a widget
type, `external`, not components.

### 4.3 Linked, Codelessly-managed components

Prebuilt UI (sign in, paywalls, inbox...) is published by Codelessly as
versioned masters that projects reference instead of copying
(`lib/src/features/managed/managed_components.dart`). Same-major releases reach every app
using one without a republish; a major never applies on its own.

The core keeps a managed instance's reference as JSON
(`ComponentLink.managedJson`); the managed library reads it as a
`ManagedComponentRef` (`ComponentLink.managed`, `withManaged`).

* **`ManagedComponentMaster`** (`managed_components/{id}`): `versions`
  (number → `{semver, minSdk, createdAt}`), `channels` (`stable`/`beta` →
  major → version number), `rollouts` (`{channel, version, percent}`,
  bucketed per project by `managedRolloutBucket`), `blocked` (rolled back
  versions). `resolve` picks what a channel offers one project for a major.
* **`ManagedComponentVersion`** (`.../versions/{n}`, immutable): `semver`,
  `minSdk`, `payload` (the JSON text of `{definition, contract}`), `digest`
  (sha256 hex of the payload's UTF-8), `changelog`.
* **`ManagedComponentContract`**: the instance panel's schema: `settings`
  (`ComponentSetting`s with a stable `key`), `slots` (`{key, label, node}`),
  `events` (`{key, label, payload}`), `tokens` (theme tokens its nodes bind as
  `${theme.primary}`), `variables` (declared on the canvas) and `requires`.
  A master's chains name an event with the placeholder action `{"type":
  "componentEvent", "event": "onSuccess"}`.
* **`ManagedComponentRef`** (`ComponentLink.managed`, on an instance's top
  node): `channel`, `pin`, the snapshot's `semver` and `digest`, and the
  instance's customization: `values` (by setting key), `slots` (slot key →
  the page's node ids), `events` (event key → action chain), `tokens`.
  `ComponentLink.version` is the version the snapshot was built from.
* **The snapshot**: the instance's nodes in the page, built by
  `buildManagedInstance(version, topId, ref)` (ids `topId__nodeId`, values
  applied by key, tokens substituted, slots grafted, event placeholders
  replaced by the instance's chains). It is what the editor shows, what a
  publish carries (`PublishLayout.extra.managed`: instance → `{id, version,
  semver, channel, pin, digest}`) and what an app falls back to.
  `managedUpdateTarget` says which newer same-major version (or, for a
  blocked snapshot, which older one) an app swaps in at run time;
  `replaceManagedInstance` swaps it, keeping slot content.
* **Forking**: editing an instance's inner nodes detaches it (a plain copy
  that no longer updates).

```json
"signin": {"type": "column", "children": ["signin__title", "..."],
           "component": {"id": "sign_in", "version": 3, "managed": {
             "semver": "1.1.0", "digest": "9f2c...", "values": {"title": "Welcome back"},
             "events": {"onSuccess": [{"type": "navigate", "to": "home"}]}}}}
```

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

A node's behaviors are layers of its render chain, outermost first: (a running app's dismissible or pan) → margin → constraints →
track pose → transform gesture → motion (one matrix: the path's offset,
translate, shift, then about its alignment scale, rotate, rotateX, rotateY) →
shimmer → flip face → tilt → flip card → scale → rotation → (drag source →
drop target → reactions →
hover/press tracking) → animations → opacity → blurs → stroke path → content. A
dismissible's and pan's follow and release physics and drag and drop run in
`runtime/gestures` (one release physics, `physics.dart`, for every
gesture). A running app drags a track (its variable written, `changed` /
`dragEnd` / `changeEnd` fired), runs transform gestures and turns flip
cards by tap, drag and variable; navigation flies shared elements (`hero`,
`runtime/actions/hero_flights.dart`) and `animate` drives a node's
animations. One player plays every animation (`render/animations.dart`): a
clock per animation (Flutter's `AnimationController`) ticking inside the
node's render object; adding and multiplying tracks pose that layer, tracks
that replace a `motion.*` value set the motion layer, `shimmer.position` the
shimmer, other paths patch the node as shown (`RenderTree.setAnimatedValues`),
variable tracks write through the render-owned `BoundValues`. The same player
plays the node's `transitions` (a tween per eased path, from what is drawn)
and starts an animation that waits to be in view (`visibleFraction`). A design
canvas draws them at rest (the motion's values, an
animation at its `previewAt` only — a loop's first frame —, a track at its variable's value); a running app
(`NodeView(interactive: true)`) plays them with tickers in the render objects
and applies interaction state patches to the nodes they target.

**Running lists.** A design canvas draws every list, grid and table at rest
(render objects, its slots not shown). A running app builds as islands
(scrolling Flutter widgets over the template's node boxes) a list that
pages, groups into `sections` or has `swipeActions` (a `CustomScrollView`;
a grid that pages, a `SliverGrid`), a list that reorders (a
`ReorderableListView`; with a reorder `group`, Draggables into a
DragTarget per list), and a `tableView` (a `TableView` over its bound
`data` and `columns`, pinned headers). Each repeat is a box in the scope
its widget gives it (`ProvidedItem` instances: a row's `${item}`/`${index}`,
a section header's `{key, count, index, start}`, a table cell's `{value,
row, column, rowIndex, columnIndex}`, a column header's `{label, column,
columnIndex}`, a row header's `{row, rowIndex}`). A pagination is a
controller per screen by its `name` (data, API or cloud source; offset,
page or cursor; pages, infinite or both ways), publishing its state as that
map variable (declared when the screen's variables are); `paginate`
actions and `pagination` nodes move it, and a pagination node fires its
`changed` reactions with the page as `${result}`.

The render layer comes from the prototype's `api_tree.dart`, laid out by §3's
layout. The layout render objects
(`RenderFitBox`, `RenderCodelesslyFlex`, `RenderFreeformLayout`,
`RenderHugCross`) are the SDK's own, moved over unchanged in behavior.

### 5.1 Variables, conditions and bindings

**Variables** (`Variable`, `lib/src/core/variables.dart`): a name, a `VariableType`
(`integer`, `text`, `decimal`, `boolean`, `color`, `list`, `map`, `image`,
`choice`) and a default `value` held as its type holds it (JSON-native:
`3`, `4.5`, `true`, `"#FFFF0000"`, `[...]`, `{...}`), or a `formula` (what goes
in `${= ...}`) that computes it; a formula with `parameters` is a function
formulas call by name. Choice variables list their `options`.

**Conditions** (`Condition`, `lib/src/core/conditions.dart`): an ordered list of
branches, `if` / `else if` / `else`. A branch has a `when` (`Predicate`: a
`Comparison` `{left, op, right}` with loose operators (§5.1's loose reading), or a `Junction`
`{"and"|"or": [...]}`; none for `else`) and `set`, the node properties it
gives values (`{node, path, value}`; a string value is an expression). For a
property, the first branch that holds and sets it wins; conditions win over
the node's own binding, which wins over the node's value.

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
`title.length`, `pal[item.kind]`), `${= formula}` computes one (the
formula language). A binding that is exactly one of them gives
the value as is (a list stays a list); any other text with `${...}` is text.
A text node's own `props.text` may hold `${...}`: it is interpolated run by
run. Names come from scopes: the screen's variables, the list item (`item`,
`index`, `parent`), what the app provides (`route`, `screen`,
`storage`, `auth`, `data`, `drag`: the layout's drag and drop session,
`perf`: the app's frame timings `{frameMs, buildMs, rasterMs, fps}`, read
from the engine only while something watches it...),
and what a node gives itself and the nodes inside it: a dismissible's live
`dismiss` and a pan's `pan` values (and both as the legacy `drag`, over the
session's; a `LocalScope`), a track's `track`
(`value`, `progress`, `dragging`, `fine`, `focused`), a transform gesture's
`transform` (the pose, `active`, `selected`), a flip card's `flip`
(`flipped`, `progress`) and a tilt's `tilt` (`x`, `y`, `active`).

**Binding paths** (`Node.bind` keys, `BindPaths` in `lib/src/core/bindings.dart`):
a path into the node's JSON, with `[i]` for a list index, a paint or
effect id for the item with that id, and `*` for every item.

| Path | Value |
|---|---|
| `visible` | bool; false collapses the node (no space, no gap) |
| `opacity` | 0–1 |
| `layout.width`, `layout.height` | a number (design size, fit kept) or `{"fill": n}`... |
| `layout.flex` | int ≥ 1 |
| `layout.rotation` | degrees |
| `layout.margin`, `layout.padding` | n, `[h, v]`, `[l, t, r, b]` or `{top: n}` |
| `layout.x`, `layout.y` | distance from the start, or a position map |
| `layout.<field>` | any other layout field, as its JSON |
| `decoration.fills[0]` | a color, image URL or paint: the first fill |
| `decoration.fills.<paintId>` | the same, for that paint |
| `decoration.fills.<paintId>.color` | a color (opacity kept) |
| `decoration.fills.<paintId>.image.url` | the image |
| `decoration.fills[0].stops[i].color` | `#RRGGBB` keeps the stop's alpha |
| `decoration.fills[0].stops[i].position` | 0–1 |
| `decoration.{fills,strokes,foregroundFills}.<paintId>.stops[i].color` / `.position` | a stop of that paint |
| `decoration.strokes[0]`, `decoration.strokes.<paintId>` | a stroke paint |
| `decoration.strokeWidth`, `decoration.radius` | number; radius also `[x, y]` or `[tl, tr, br, bl]` (each n or `[x, y]`) |
| `decoration.effects.*.visible`, `.<effectId>.visible` | bool |
| `decoration.effects.*.color` / `.offset.dx` / `.offset.dy` / `.blurRadius` / `.spreadRadius` | shadows |
| `props.<prop>` | the widget's prop, by its declaration's codec |
| `props.<prop>.<field>` | a field of a structured prop |
| `props.style.<field>` (text) | the base style and every run's |
| `data` | the items a list, grid or page view builds one per (its item count follows) |
| `scale`, `textDirection`, `motion.<field>`, `motion.path.progress`, `flightKey`, `tooltip`... | a behavior (§4.1); `animations.<id>.paused` reads loosely, `animations.<id>.params.frames` a list or its JSON text; a legacy motion's bound timing keys are rewritten to the animations and `transitions[i]` they became |
| `dismissible.<field>`, `pan.<field>`, `draggable.enabled`, `dropTarget.enabled`, `draggable.data` | a dismissible's or pan's setting (`enabled` read loosely, `pan.x`/`pan.y` its rest); a drag source's or drop target's switch; the payload |
| `track.<field>`, `track.value` | a track's setting or geometry (a number written as is reads); the value it's drawn at. The legacy `drag.track.*` and `drag.*` paths are rewritten to these when a node decodes (`drag.enabled` → the behavior's `enabled`, `drag.restX` → `pan.x`...) |
| `animations.<id>.<field>` | an animation's field (`paused`, `phase`, `playKey`, `enabled`, `params.<p>`, `tracks.<trackId>.from`...); the legacy `loops[i].*` and `effectAnimations[i].*` keys are rewritten to these when a node decodes (a loop's `phase` and `lag` into one `phase` formula) |
| `transformGesture.<pose>`, `flip.flipped` | the pose from data (`x`, `y`, `scale`, `rotation`...), `enabled`; the card's face |
| `hero.tag` | a shared element's tag (`pass-${item.id}`; the hero is then always the object form) |
| `particles.playKey` | the particles' cue |
| `selected`, `disabled` | bool: true puts the node in `WidgetState.selected` / `disabled`, so its `states` styles patch it and its descendants |
| `semantics.*`, `enabled` | reserved: kept, not applied yet |

Values are read loosely (`"12"` is a number, `1` true,
`"#F00F00"` a color); a value that can't be read leaves the property as it
was. The SDK compiles a node's bindings once (`NodeBindings`) and applies
them on the typed node (no JSON round trip for the common paths), watching
only the names each binding reads.

### 5.2 Reactions and actions

**Reactions** (`Node.actions`, `Reaction`, `lib/src/core/triggers.dart`): a
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
`valueChanged`, `timer`, `frame`, `keyDown`/`Up`, `backPressed`: back was
pressed while the canvas's `props.blockBack` holds, usually bound to
`${= dirty}`; the screen stays and these run, a navigate pop from them is
never blocked), scrolling and viewport (`scroll`, `scrollEnd`,
`enterViewport`, `exitViewport`), drag and drop (`dropFull`: let go on a
target whose `fullIf` holds) and `reorder`. Settings are sparse: `debounceMs`, `variable`, `intervalMs`,
`key` (`KeyCombo`: `Meta+Enter`), `when`, `holdMs`,
`visibleFraction`. `timer` is `Timer.periodic`: `intervalMs` a number or an
expression, `${result.tick}`; the legacy `clock` reads as it (`every` →
`intervalMs`, `runWhen` → `when`). `frame` is a `Ticker`: `${result.dt}`,
`${result.elapsed}`, `${result.frame}`, while `when` holds and the node is on
stage; a frame that comes while its chain runs is skipped. A list fires `refresh` (pulled to
refresh) and `swipeAction` (`${result.action}`, `${result.item}`).

**Actions** (`ActionDef`, one immutable class per type, each declared by an
`ActionSpec` in a catalog, §8; the core's are the sealed `CoreAction`
family in `lib/src/core/actions.dart`, each feature library's its own
family in `lib/src/features/<x>/actions.dart`): `navigate` (push, pop, replace, reset; params,
base, transition), `openModal` (dialog, sheets, full screen, popover),
`closeModal` (its result is the opener's `${result}`), `openLink`,
`submitForm`, `setValue` (node properties at binding paths: set, toggle,
sync), `setVariant`, `setVariable` (a `ValueWrite`: `op` set, toggle,
add, subtract, insert, insertAll, removeAt, remove, update; `index`,
`mapKey`; a number glides over `animateMs` along `curve`, the chain
waiting), `animate` (an `AnimationController` command — `forward`,
`reverse`, `toggle`, `repeat`, `stop`, `reset`, `animateTo`, `animateBack`,
`set` — on a node's animation or a number variable's timeline; the legacy
`playAnimation` and `animateVariable` read as it), `callFunction`, `runScript` (a layout script, below;
`onError` reads `${result.error}`), `callApi` (`onSuccess` / `onError`),
`setStorage`, `cloudDocuments`, `loadCloudData`, `cloudData`, `cloudBatch`,
`cloudFiles`, `auth`, `if`, `forEach` (each turn reads `${loop.item}`,
`${loop.index}`), `delay`, `showToast`, `confirm` (their cosmetics in
`look`; their `variables` bind look colors, sizes, the
`icon` name and a toast's `duration`; a confirm's `dialog` screen answers
by closing with `{confirmed: true, ...values}`, the values its actions'
`${result}`), `copyToClipboard`, `editText`, `focus`, `scrollTo` (`axis`: only
the scroll views along it), `speak`, `playSound`, `paywall`,
`controlTrack` (`step` a track by `steps`, `animateTo` a `value`),
`controlDismissible` (`dismiss`, `returnFrom`, `reset` toward a `direction`),
`controlTransform` (`reset`, `scaleBy`, `animateTo` a pose; the legacy
`controlDrag` reads as the one its command names),
`haptic` (`HapticFeedback`: selection, light, medium, heavy, vibrate),
`paginate` (a list's pagination by name: next, previous, goTo, first,
last, refresh, retry, setPageSize).
`navigate` and `openModal` take a `routeTransition` (`RouteTransition`,
`lib/src/core/route_transition.dart`; or a bare preset name): the incoming
screen's `enter` and the covered one's `exit` sides (a `Pose`: a `Motion` with `opacity` and `blur`, a
`reveal` clip, a curve, `delayMs`, `durationMs`), `popEnter`/`popExit`
for closing, `durationMs`, `barrierColor`, `opaque`, `swipeBack`, a
`dismiss` drag; a `preset` (`iosPush`, `sharedAxisX`, `cube`...) fills in
what's left out. Every action can be off
(`enabled: false`), not awaited (`nonBlocking`), or run only while a
predicate holds (`when`, §5.1's `Predicate`). Text fields are expressions;
`${result}` is what the previous action gave (the trigger's event first).
An unknown type decodes as `UnknownAction` and round-trips; the SDK runs it
with the handler the app gives for the type (`CodelesslyActions.handlers`),
else skips it.

**Scripts** (`ScriptDef`, `lib/src/core/scripts.dart`): JavaScript a layout
runs, in its document's `scripts` list (project scripts, then page scripts
with a `pageId`; a page script wins by name): `name`, `params`
(`{name, defaultValue}`), `source`, `capabilities` (`variables.read`,
`variables.write`, `nodes.read`, `navigation`, `api`, `cloud`, `actions`,
`clock`), `timeoutMs`, `memoryLimitMb`, `tests`; `validate()` checks names
(`isValidName`: an identifier, not a keyword or a host API in
`reservedNames`), params and limits. A publish layout keeps `scripts` in its
document. The SDK asks the app's `ScriptRunner` (`Services.scripts`) to run
one: by default `SandboxScriptRunner`, a driver in QuickJS
(`codelessly_quickjs`, which the app adds) or a Web Worker. Formulas call
them as `script.name(args)` (params in order, read capabilities only; the
path `script` is declared by the screen's `ScriptsScope`).

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

### 5.3 Breakpoints

A project defines its own breakpoints: the screen size classes its screens,
responsive layouts, `${screen}` and per-breakpoint values (a toast's
alignment) all speak of. Nothing in the API, the SDK or the editor knows
mobile, tablet, desktop, 600 or 1024 except as the default *data* below.

**Where they're defined: the project.** One set per project
(`PublishModel.breakpoints`, `Breakpoints` in
`lib/src/core/breakpoints.dart`). One device is one breakpoint
everywhere: the screen it sees, the variant its responsive layouts show,
`${screen.breakpoint}` and the toast's alignment must agree, and moving
between screens must not change it. So a layout (screen) can't redefine
the set, and nothing adds or renames a breakpoint locally. Until the
editor stores per-project data, a page's document carries the project's set
(`LayoutDocumentBreakpoints`, key `breakpoints`), as it carries project
scripts; publish copies it to the model.

**Two levels: the project's set, and a node's or screen's own switch
points.** The set names the size classes; a responsive variance
(`VarianceProps.minWidths`, `{breakpointId: width}`) and a screen's canvas
(`CanvasProps.breakpointMinWidth`, published as `CanvasBreakpoint.minWidth`)
may move where *they* switch to one of the project's breakpoints. An
override is user-authored content (the editor's switch-point fields, the
generated panel edits both): a sidebar that stays narrow up to 1100, a
screen whose tablet design starts at 768. It never adds, removes or renames
a breakpoint, and moves nothing outside its node: other nodes, other
screens, toasts and modals keep the project's widths.

**Shape.** `Breakpoint {id, name, minWidth, width, height}`:

| Field | Meaning |
|---|---|
| `id` | Stable; what everything refers to. Robust to renames. |
| `name` | Shown in the editor; `${screen}` exposes it too. |
| `minWidth` | The narrowest width it covers, inclusive. |
| `width`, `height` | The design size a canvas for it takes (and the preview). |

The set is ordered by `minWidth`, narrowest first, and min widths are
unique; that order is the only order (reordering in the editor swaps two
breakpoints' ranges), so "nearest breakpoint" and "narrowest" never
disagree with the widths. The first covers everything below the second,
whatever width it starts at (its `minWidth` is stored as 0).

**Defaults** (`Breakpoints.defaults`, editable data): `mobile` 0 (390 × 844),
`tablet` 600 (834 × 1112), `desktop` 1024 (1440 × 900). New breakpoints get a generated id.

**References, by id.** A variance variant: `{"breakpoint": "<id>"}` (a
variance with any is responsive). A canvas: `props.breakpoint` (the
breakpoint it is the design for) and `props.screen` (canvases with the same
value are one screen, one canvas per breakpoint; empty: a screen of its
own). A published layout lists its canvases' breakpoints:
`"breakpoints": [{"canvas", "breakpoint", "minWidth"?}]` (`minWidth`: the
canvas's own switch point). An Open Modal action:
`sheetBelow: "<id>"` (adaptive: a bottom sheet on breakpoints narrower than
that one, a dialog from it up; empty, or a breakpoint since removed: the
project's second breakpoint, i.e. a sheet on the narrowest only; with one
breakpoint, always a dialog). An adaptive confirm uses that default.

**Resolving a width.** The width is the screen's: the width the layout is
shown at, and in a dialog, sheet or popover the
device's, never the variance's own box.

1. *Project:* `Breakpoints.forWidth(w)`: the one with the highest
   `minWidth` at or below `w` (inclusive), else the first.
2. *With a node's own switch points:* `forWidth(w, minWidths)`: the same
   walk in the set's order, each breakpoint starting at its override when it
   has one; a breakpoint without one starts no earlier than the one before
   it as moved (a node moving desktop to 1200 isn't on a wider project
   breakpoint at 1150). The order stays the set's.
3. *Screen:* the canvas whose switch point (its own `minWidth`, else its
   breakpoint's) is the highest at or below the width, else its narrowest.
4. *Responsive variance:* step 2 with its `minWidths` gives a breakpoint;
   it shows that breakpoint's variant, else the one of the widest narrower
   breakpoint that has a variant, else its narrowest (`Breakpoints.governing`:
   each variant covers from its breakpoint, as the node moves it, up to the
   next variant's), else `current`. On the default three this is
   the nearest breakpoint, the narrower on a tie, for every combination of
   variants, and a project breakpoint no variant names never moves where
   an existing variance switches.

**`${screen}`** (`screenValues`): `modal` and `sheet` (whether the screen is
shown as a modal, and as a bottom sheet), `width`, `height`, `orientation`,
`isPortrait`, `isLandscape`, `brightness`, `isDark`; `breakpoint` (the
current id), `breakpointName`, `breakpointIndex`; `is` and `atLeast`, maps by
id and by name key (lower camel case: "Large desktop" → `largeDesktop`) to
booleans (`${screen.is.tablet}`, `${screen.atLeast.tablet}`); `breakpoints`,
the set (`[{id, name, minWidth}]`); and `is<Key>` for each id and name
(`isMobile`, `isTablet`, `isDesktop` for the defaults; they keep working
after a rename, since ids don't change). The fixed keys
win over a generated one.

**`${screen}` inside an overriding node.** Inside a variance with its own
switch points (its subtree, its bindings), `${screen}` is restated by
step 2 with its `minWidths` (`ResponsiveScreenScope`): `breakpoint`, `is`, `atLeast` and `is<Key>` agree
with the variant on show; `width`, `height` and the rest are the device's.
Everywhere else `${screen}` is the project's.

**Per-breakpoint values** (a toast look's `alignments`, `sideMargins`,
`bottomOffsets`) are keyed by breakpoint id (a name also matches); a
breakpoint with no entry uses the single value.

### 5.4 Loading published apps

`Codelessly` loads through a `PublishLoader` (model, then each layout when
first shown) and keeps what it loaded in a `PublishCache` (keys: the
publish paths), opening on the cached copy and refreshing in the
background. Loaders: `FirestorePublishLoader`
(`package:codelessly_sdk/firebase.dart`), the default for Codelessly's
Firebase (`codelesslyOnFirebase`); `HttpPublishLoader` (a slug's bundle,
`publish/{slug}.json` in storage); `AssetPublishLoader`;
`MemoryPublishLoader` (tests).

The Firestore loader reads what the editor writes
(§2.1): the document `PublishSource.modelPath` and each
`PublishSource.layoutPath`, `compressedNodes` expanded, Firestore
timestamps as milliseconds. With the app's project token
(`CodelesslyConfig.authToken`) it authenticates first (`ProjectAuth`:
anonymous sign-in, the backend's `verifyProjectAuthToken` names the token's
project and grants the claim the publish paths' rules check); a template
project reads `templates`. `CodelesslyConfig.publishSource: preview` reads
`publish_preview`. It is a `LivePublishLoader`: `Codelessly` follows the
model document (`CodelesslyConfig.liveUpdates`, on by default), and a
layout whose entry got newer is dropped and loads again when shown, so a
publish (or a preview save) reaches running apps. A
document without `"schema": 2` is not in this format: loading fails
with a `PublishLoadException` saying so.

## 6. Proving it: parity

The SDK's layout is checked against stored goldens: each node's rect on every
canvas of the 66 fixture pages (50,918 nodes), stored as JSON in
`CodelesslySDK/test/goldens`. The tests render the pages and compare rects
within 1 px, then pixels. A widget type counts as ported when it's at 100% on
the fixtures.

## 7. Release

The packages are released as `codelessly_api` and `codelessly_sdk` 24.x, from each
repository's root.

## 8. Catalogs, feature libraries and plugins

docs/design/05-plugins-and-layers.md is the design; docs/guide/09 the
how-to. What a document may contain is a `Catalog` (`lib/src/core/catalog.dart`):
node types (`WidgetSpec`), action types (`ActionSpec`: label, fields, a
decoder for its class, result, nested chain keys, required capabilities),
list data sources (`DataSourceSpec`) and formula functions (`FormulaSpec`).
A catalog is an immutable value composed with `+` or `parts` (later entries
win by type name), never a registry.

* **Decoding takes one.** `LayoutDocument`, `Node`, `Reaction`, `ActionDef`,
  `ComponentDefinition`, `PublishLayout` and `PublishBundle` decoders take
  `catalog:`; nested decodes use the same (`Catalog.current`, a scope that
  lasts for the decode). Without one they use `Catalog.core`: the core can't
  name the feature libraries. `standardCatalog` (umbrella library) is the
  core and every first-party library. A node keeps the catalog it was
  decoded with (`Node.catalog`, outside equality; `spec` reads it).
* **Undeclared types round-trip.** A node type the catalog lacks keeps its
  props raw (`Props.unknown`; reading one through a `PropDef` decodes it),
  an action type is an `UnknownAction` (`Catalog.upgrade` types it later).
  JSON is the same whatever catalog read it.
* **Families.** `ActionDef` is an `abstract base class`; `CoreAction`,
  `DataAction`, `MediaAction`, `EngageAction` are sealed families,
  `AuthAction` and `PaywallAction` one class each; a type declared without a
  class is a `DeclaredAction` (its spec and its fields as `Props`). The SDK
  switches exhaustively per family and tests that every declared type has a
  handler.
* **Export.** `catalog.toJson({compact})` / `Catalog.fromJson`: every
  declaration with its prop types, defaults, enum values, bounds and docs,
  for the generated reference, editors and agents; `JsonPropCodec` decodes
  a value of any declared `PropType`.
* **Two plugin tiers, one declaration.** A native plugin is Dart compiled
  into the app: its `WidgetSpec`s and `ActionSpec`s in a `Catalog`, its
  recipes and handlers in an SDK `CodelesslyFeature`. A hosted plugin is
  data (`PluginPackage`, `lib/src/features/managed/plugins.dart`): its
  declarations as catalog JSON, node types implemented as node trees reading
  `${props.*}`, action types as chains reading `${params.*}`, formulas,
  scripts with their capability lists, assets with digests. Its releases
  are managed component releases (`PluginVersion` at
  `plugins/{id}/versions/{n}`: payload text, sha256 digest, minSdk; a
  `ManagedComponentMaster` at `plugins/{id}`; `pluginUpdateTarget`), a
  publish lists them (`PublishModel.plugins`, `PluginRef`), and
  `PluginPackage.problems` refuses one whose trees or chains use a type the
  host lacks or a capability it doesn't list. It can do only what a
  document can do.
