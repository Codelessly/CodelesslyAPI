# 05 · Declaring plugins, hosting them, and splitting the layers

Status: proposal. Line references are to this worktree and to
`CodelesslySDK/lib/src/...` as read on 2026-11-13.

## 1. Problem

**No declaration side to extensibility.** The SDK can now *run* app-defined
types: per-tree `recipes` for node types whose props arrive in
`Props.unknown` (`CodelesslySDK/lib/src/app/config.dart:97`,
`render/node_tree.dart:175`, `render/recipe.dart:14`) and handlers for
`UnknownAction` (`runtime/actions/runner.dart:189`). The API package cannot
*describe* them:

* `ActionDef` is `sealed` (`actions.dart:28`) and decodes through a private
  map of 42 entries (`_decoders`, `actions.dart:105-148`). Anything else is an
  `UnknownAction` holding raw JSON (`:2611`).
* `Widgets.all` is a fixed `const` list (`widgets/widgets.dart:15-30`);
  `Node.fromJson` and `Node.spec` call the static `Widgets.of`
  (`node.dart:84, 176`). 66 node types, closed.
* The editor's panels are generated from `PropDef`s (`props.dart:473`) and
  the `*Fields` classes. An undeclared type has no fields, so no controls,
  no validation, no typed decode.

**Feature layers live in the core.** Of the 42 action types, 18 are
service features: `callApi` (`actions.dart:997`), `setStorage` (`:1054`),
`cloudDocuments`, `loadCloudData`, `reloadCloudData`, `cloudData`,
`cloudBatch`, `cloudFiles` (`:1126-1565`), `auth` (`:1667`), `paywall`
(`:2201`), `speak`, `playSound` (`:2064, 2112`), `submitForm` (`:584`),
`preloadImages`, `print`, `downloadFile`, `captureScreenshot`, `emitEvent`. They sit in the
same sealed class as `navigate` and `setVariable`.

**Import edges that tie the node model to features** (from the `import`
lines of each file):

| Edge | Where |
|---|---|
| `node.dart` → `components.dart` → `managed_components.dart` → `actions.dart`, `publish/publish_layout.dart`, `publish/theme.dart`, `bindings.dart` | `node.dart:5`, `components.dart:15`, `managed_components.dart` imports |
| `actions.dart` → `services/cloud.dart` | `actions.dart:17` |
| `actions.dart` → `publish/breakpoints.dart`; `widgets/canvas.dart` → `publish/breakpoints.dart` | `actions.dart:15` |
| `widgets/widgets.dart` → `widgets/media.dart` (video, audio, web view specs in `Widgets.all`) | `widgets/widgets.dart:9` |

So a program that imports `node.dart` compiles managed components, the
publish layout, every action and the cloud query model.

The list widgets are coupled to cloud data **by name, not by import**:
`listView.query` is an untyped `Json` prop (`widgets/collections.dart:110`),
`PaginationSource.cloud` / `.api` and `Pagination.apiId` are enum values and
a string (`widgets/collections_models.dart:55-62, 164`), `ListApply.cloud`
with `orderField` (`:212, 288`). Nothing there imports `services/cloud.dart`.

## 2. Grounding

This part has no Flutter widget to mirror; it mirrors how Flutter code is
packaged. A plugin node type is a widget class from a package; a plugin
action is a function the app calls; a hosted plugin is a widget built only
from other widgets. The "Flutter spelling" of each construct:

| Construct | Flutter spelling |
|---|---|
| `WidgetSpec` + `PropDef`s | a widget's constructor: named parameters, types, defaults |
| `ActionSpec` | a function signature |
| `Catalog` | the set of packages an app depends on |
| hosted plugin widget | a `StatelessWidget` whose `build` returns other widgets |
| native plugin widget | a widget with its own `RenderObject` or platform view |

The competitive reference is Google's A2UI catalogs. The brief states A2UI
1.0 ships 18 basic components and no styling on the wire; that was not
verified here.

## 3. The catalog: a value passed to decode

```dart
/// What a document may contain: the declared node types, action types and
/// the rest of the vocabulary. Immutable; composed, never mutated.
@immutable
final class Catalog {
  const Catalog({
    this.widgets = const [],
    this.actions = const [],
    this.dataSources = const [],
    this.animationPresets = const [],
    this.formulas = const [],
    this.instructions = '',
  });

  /// Nodes, layout, decoration, behaviors, triggers, core actions.
  static const Catalog core = ...;

  /// [core] plus the first-party features (auth, data, commerce, media,
  /// engage). The default everywhere, so today's call sites keep working.
  static const Catalog standard = ...;

  final List<WidgetSpec> widgets;
  final List<ActionSpec> actions;
  final List<DataSourceSpec> dataSources;       // §6.3
  final List<AnimationPresetSpec> animationPresets; // doc 02 §5
  final List<FormulaSpec> formulas;             // name, parameters, doc
  final String instructions;                    // authoring notes for agents (§7)

  Catalog operator +(Catalog other);            // later entries win by type name
  WidgetSpec? widget(String type);
  ActionSpec? action(String type);

  Json toJson({bool compact = false});          // §7
  Json toJsonSchema();
  List<Issue> validate(Object? documentJson);   // §7
}

/// The declaration of one action type: what `WidgetSpec` is to a node.
@immutable
final class ActionSpec<T extends ActionDef> {
  const ActionSpec(this.type, {required this.fields, required this.decode,
      this.result, this.nested = const [], this.requires = const [], this.doc = ''});
  final String type;                            // JSON `type`
  final List<PropDef<Object?>> fields;          // generated panel, validation, schema
  final T Function(Json json, ActionCommon common) decode;
  final PropType? result;                       // what `${result}` holds after it
  final List<String> nested;                    // field keys holding action lists (`then`, `onError`)
  final List<String> requires;                  // capabilities (`api`, `cloud`, `auth`...)
  final String doc;
}
```

Call sites, all with the default so nothing breaks:

```dart
LayoutDocument.fromJson(json, catalog: catalog)   // threads it to Node and Reaction decoding
Node.fromJson(json, id: id, catalog: catalog)
ActionDef.fromJson(json, catalog: catalog)
PublishLayout.fromJson(json, catalog: catalog)
```

`Node` keeps the `WidgetSpec` it was decoded with (`node.spec` becomes a
field set at decode, outside equality, instead of a static lookup).
`Widgets.of` and `ActionDef.types` remain as shorthands for
`Catalog.standard`. Uses of those statics today: 3 in the API package's
`lib`, 6 in the SDK's, 49 files in the editor (grep for `Widgets.of`,
`Widgets.all`, `ActionDef.fromJson`, `listFromJson`, `types`); only code that
wants a non-default catalog changes.

### 3.1 What happens to `sealed`

A sealed class cannot have subclasses in another library, so features and
plugins cannot join it. Proposed:

* `ActionDef` becomes an `abstract base class`.
* `sealed class CoreAction extends ActionDef` holds the core types. Each
  feature library has its own sealed family (`sealed class DataAction`,
  `AuthAction` stays one class...).
* A type declared without a Dart class (a hosted plugin's, or a native
  plugin's declared by manifest) decodes as `DeclaredAction`: its
  `ActionSpec` and a typed `Props` of its fields, the same way a `Node`
  holds `Props` for its `WidgetSpec`.
* `UnknownAction` remains for a type no catalog entry knows.

The exhaustive `switch (a)` in the SDK (`runtime/actions/handlers.dart:54`)
becomes one exhaustive switch per family, each registered in
`CodelesslyActions.handlers` by type name. The guarantee that every
declared type has a handler moves from the compiler to one test:
`for (final s in catalog.actions) expect(handlers, contains(s.type))`.
Within a family the compiler still checks exhaustiveness.

## 4. Declaring a plugin

**In Dart** (a native plugin, or a first-party feature):

```dart
abstract final class RatingProps {
  static const value = PropDef<double>('value', DoubleCodec(min: 0, max: 5), 0, doc: 'Stars filled.');
  static const color = PropDef<Color>('color', Codecs.color, Color(0xFFFFC83D));
  static const spec = WidgetSpec('acme.rating', props: [value, color], doc: 'A five-star rating.');
}
const acme = Catalog(widgets: [RatingProps.spec], actions: [ShareAction.spec]);

final doc = LayoutDocument.fromJson(json, catalog: Catalog.standard + acme);
```

**As data** (the same declaration, loadable by the editor and by the SDK
without any Dart): `Catalog.toJson` / `Catalog.fromJson`. This needs
`PropType` and `PropDef` to round-trip as JSON; `PropType` already states
kind, Flutter type name, enum values, bounds, item type and object fields
(DESIGN.md §4.0), so a `JsonPropCodec` built from a `PropType` can decode
any declared value.

```json
{"id": "acme", "widgets": [{"type": "acme.rating", "doc": "A five-star rating.", "children": "none",
   "props": [{"key": "value", "type": {"kind": "number", "flutter": "double", "min": 0, "max": 5}, "default": 0},
             {"key": "color", "type": {"kind": "value", "flutter": "Color"}, "default": "#FFFFC83D"}]}],
 "actions": [{"type": "acme.share", "fields": [{"key": "text", "type": {"kind": "string", "expression": true}, "default": ""}],
              "result": {"kind": "object", "fields": [{"key": "shared", "type": {"kind": "boolean"}}]}}]}
```

Rules: plugin type names are `vendor.name`; unprefixed names are reserved
for core and first-party features. A plugin may add node types, action
types, data sources, animation presets and formula functions. It may not
add behaviors, layout modes or triggers (decision 3 in §10).

## 5. Hosted plugins

Requirement: plugins are stored on Codelessly's hosting and downloaded by
the SDK at run time. A shipped Flutter app cannot download compiled Dart,
so **a hosted plugin is data**: declarations plus an implementation
expressed in the model itself.

### 5.1 What a hosted plugin contains

```json
{"schema": 2, "id": "codelessly.charts", "semver": "2.3.1", "minSdk": "25.0.0",
 "requires": [],
 "catalog": { "widgets": [...], "actions": [...], "animationPresets": [...], "formulas": [...] },
 "implementation": {
   "widgets":  {"codelessly.sparkline": {"document": { "roots": ["root"], "nodes": {...} },
                                        "slots": {"label": "labelHost"},
                                        "events": [{"key": "onSelect", "payload": {"index": "integer"}}]}},
   "actions":  {"codelessly.celebrate": {"chain": [{"type": "animate", "node": "${params.node}", "animation": "pop"},
                                                  {"type": "playSound", "url": "${assets.chime}"}]}},
   "formulas": [{"name": "niceStep", "parameters": ["range"], "formula": "..."}],
   "scripts":  [{"name": "qrMatrix", "source": "...", "capabilities": []}],
   "assets":   {"chime": {"url": "https://.../chime.mp3", "digest": "ab12…"}}}}
```

* A **widget implementation** is a node tree (a `LayoutDocument` with one
  root, as a `ComponentDefinition` has, `components.dart:282`) built from
  catalog types the host has, including `customPaint` (doc 01) and
  `animations` (doc 02). Inside it `${props.<key>}` reads the plugin node's
  declared props; the plugin node's slots and children are grafted where
  `slots` says; `{"type": "componentEvent", "event": "onSelect"}` fires the
  plugin node's reactions (the placeholder managed components already use,
  `managed_components.dart:50`).
* An **action implementation** is an action chain reading `${params.*}`, or
  a script by name.
* **Formulas** are function variables (`Variable` with `parameters`,
  DESIGN.md §5.1); **scripts** are `ScriptDef`s with their capability lists
  (`scripts.dart:13, 198`); **assets** are URLs with digests.

A plugin node in a page is **one node**: `{"type": "codelessly.sparkline",
"props": {...}}`. The SDK expands it at run time into a nested tree, the
way it instantiates a list's item template. This is the difference from a
managed component, whose instance is a snapshot of nodes copied into the
page (DESIGN.md §4.3). Managed components can be re-expressed as hosted
plugins later; that is not proposed here.

### 5.2 Versioning and resolution: the managed-component machinery

Reuse `managed_components.dart` as it is, with the payload generalised:

| Managed components today | Hosted plugins |
|---|---|
| `ManagedComponentMaster`: `versions`, `channels` (stable/beta → major → version), `rollouts` (percent, bucketed per project by `managedRolloutBucket`, `:114`), `blocked`; `resolve` (`:603`) | the same class and rules, stored at `plugins/{id}` |
| `ManagedComponentVersion`: `semver`, `minSdk`, `payload` (JSON text), `digest` (sha256 of the payload's UTF-8), `changelog` (`:444`) | the same, at `plugins/{id}/versions/{n}`; the payload is §5.1's JSON |
| `sdkSatisfies(sdkVersion, minSdk)` (`:106`) | the same |
| `ManagedComponentRef`: `channel`, `pin`, `semver`, `digest` (`:133`) | `PluginRef`, below |
| Same-major releases reach running apps; a major never applies on its own; a blocked snapshot rolls back (`managedUpdateTarget`) | the same |

**How a document references a plugin.** The project lists what it uses,
and every publish carries the list (like `breakpoints`, DESIGN.md §5.3):

```json
"plugins": [{"id": "codelessly.charts", "channel": "stable", "pin": 2,
             "version": 14, "semver": "2.3.1", "digest": "9f2c…"}]
```

`version` and `digest` are what the editor built and previewed with.
A node's type prefix (`codelessly.charts` declares the `codelessly.*` types
it lists) resolves to the plugin.

### 5.3 How the SDK loads, caches and verifies

1. `PublishLoader` (`CodelesslySDK/lib/src/app/loader.dart:26`) gains
   `loadPlugin(id, version)`; the Firestore, HTTP, asset and memory loaders
   implement it. The publish bundle embeds the pinned payloads, so a first
   run offline works (what the snapshot does for managed components).
2. `PublishCache` (`loader.dart:272`) stores payloads by
   `plugins/{id}/versions/{n}`.
3. Before use the SDK checks sha256(payload) against the digest in the
   publish model (for the pinned version) or in the master's version entry
   (for a same-major update), and `minSdk`. A mismatch is refused and the
   embedded version is used.
4. The SDK builds `Catalog.standard + Catalog.fromJson(plugin.catalog)` per
   project, decodes layouts with it, and registers the expansions. Plugins
   load before the first layout that uses them is decoded.

### 5.4 Trust model

* A hosted plugin is data. Its trees and chains can contain only node and
  action types in the host's catalog; anything else fails validation at
  install and at load.
* `requires` lists the capabilities it uses (`api`, `cloud`, `auth`,
  `storage`, `navigation`, `sound`...). The project's profile says which are
  allowed; the editor shows them at install; the SDK refuses a plugin whose
  `requires` exceeds the profile. An action in an implementation whose
  `ActionSpec.requires` is not covered is a validation error.
* Scripts keep their own capability lists and the sandbox's time and
  memory limits (`scripts.dart:179-183`).
* A widget implementation reads `${props.*}`, its own variables and
  `${theme}`; not the screen's variables. It reaches the page only through
  its events. An action implementation reads `${params.*}`.

### 5.5 Two tiers and the boundary between them

| | Hosted (data) | Native (Dart in the host app) |
|---|---|---|
| Declared by | catalog JSON | catalog JSON or Dart; the same `WidgetSpec`/`ActionSpec` |
| Implemented by | node trees, chains, formulas, sandboxed scripts, assets | `WidgetRecipe`s and `ActionHandler`s the app registers |
| Delivered | downloaded, versioned, rolled out | compiled into the app; a new version is an app release |
| Can do | compose any catalog widget; draw (`customPaint`); animate; gestures; compute in formulas and scripts; call the project's declared APIs when allowed; play sounds | platform channels and native views; its own render objects, shaders, text input; platform SDKs (store, auth providers, sensors); work off the frame budget |
| When missing | cannot be: the publish embeds it | the node renders as an empty box of its size, the action is skipped (today's behavior for unknown types) |

A native plugin still publishes its **declaration** to hosting
(`"implementation": "native"`), so the editor generates its panels and the
validator knows it; the SDK checks at start that the host registered a
recipe or handler for each native type and reports those it did not.

**Which of today's invented widgets could become hosted plugins** once
docs 01 and 02 exist:

| Today | Tier | Why |
|---|---|---|
| `chart`, `lineChart`, `barChart`, `plotChart`, `radialGauge`, `gaugeMeter` | hosted | paint + formulas + animation tracks. Chart data transitions (docs/guide/06) need a keyed `repeat`; to be proven with `lineChart` first |
| `barcode` | hosted | a script computes the matrix; `customPaint` draws it |
| `pagination` (page controls) | hosted | buttons bound to the pagination's state map |
| toast and confirm looks | hosted | node trees; `confirm` already takes a `dialog` screen |
| swipe deck | hosted | `dismissible` + bindings (doc 04 §3.8) |
| transform handles | hosted | doc 04 §5 |
| `activityIndicator`, loop and effect presets, `typewriter` | hosted | animation presets |
| `particles` | hosted if a benchmark allows | a `frame` trigger and one `repeat`; hundreds of particles per frame through formulas is unproven. Native until measured |
| `signature` | native for now | capture needs every pointer sample without a round trip through variables; display alone could be hosted |
| `textField` and the other inputs, pickers | native | text input, Material |
| `video`, `embeddedVideo`, `audioPlayer`, `webView` | native | platform views |
| `listView`, `gridView`, `pageView`, `tableView`, `tabs` | native | slivers, viewports |
| auth, cloud data, paywall, speech, sound engine, haptics | native | platform SDKs |

### 5.6 What the editor does

* A plugin browser lists masters (first-party and the organisation's own);
  installing adds a `PluginRef` to the project and shows `requires`.
* Property panels, the insert menu, action pickers and validation come from
  the plugin's catalog JSON: no editor release per plugin.
* The canvas renders plugin nodes through the same SDK expansion.
* Updates, pins, channels and rollbacks use the managed-component UI.
* Authoring: "publish as plugin" turns a component and its contract into a
  plugin widget (`ComponentSetting` → `PropDef`, slots → slots, events →
  events), then a version on a channel.

## 6. Splitting the package

### 6.1 Libraries

`package:codelessly_api/codelessly_api.dart` keeps exporting everything.
New entry points:

| Library | Contents (files today → new place) |
|---|---|
| `core.dart` | `json`, `values/*`, `layout`, `decoration`, `props`, `value_fields`, `behaviors` (+ `gestures`), `behavior_fields`, `bindings`, `triggers`, `conditions`, `variables`, `logic`, `document`, `node`, `components`, `route_transition`, `scripts`, `child_fits`, `catalog` (new); `publish/breakpoints.dart` → `src/core/breakpoints.dart`; `widgets/` canvas, flex, stack, text, icon, scroll, inputs, material, collections, indicators, and `path`, `external`, `placeholder` from `media.dart`; core actions (navigate … paginate) → `src/core/actions.dart` with `src/core/action_fields.dart` |
| `data.dart` | `services/cloud.dart`, `services/http_api.dart` → `src/features/data/`; `callApi`, `setStorage`, the six cloud actions, `downloadFile` → `src/features/data/actions.dart`; the `cloud` and `api` data sources (§6.3) |
| `auth.dart` | `AuthAction`, `AuthOperation` → `src/features/auth/actions.dart` |
| `commerce.dart` | `services/paywall.dart`, `PaywallAction` → `src/features/commerce/` |
| `media.dart` | `video`, `embeddedVideo`, `audioPlayer`, `webView` specs; `speak`, `playSound`, `preloadImages`, `captureScreenshot`, `print` → `src/features/media/` |
| `engage.dart` | `publish/automations.dart`, `emitEvent`, `submitForm` → `src/features/engage/` |
| `publish.dart` | `publish/publish_model.dart`, `publish_layout.dart`, `app_identity.dart`, `theme.dart`, `style_sheet.dart`, `services/config.dart` → `src/features/publish/` |
| `managed.dart` | `managed_components.dart`, the hosted-plugin package types → `src/features/managed/` |

Each feature library exports one `const Catalog` (`dataCatalog`,
`authCatalog`...). `Catalog.standard` is their sum, defined in the umbrella
library, not in core.

### 6.2 Import edges to cut

| Edge | Cut by |
|---|---|
| `components.dart` → `managed_components.dart` (`components.dart:15`) | `ComponentLink.managed` becomes raw `Json` in core; `managed.dart` adds `extension ManagedLink on ComponentLink { ManagedComponentRef? get managedRef; }`. JSON unchanged |
| `actions.dart` → `services/cloud.dart` (`:17`) | the cloud actions move to `data.dart` |
| `actions.dart`, `widgets/canvas.dart` → `publish/breakpoints.dart` | `breakpoints.dart` moves to core (a project's size classes are layout vocabulary) |
| `widgets/widgets.dart` → media specs | `Widgets.all` is replaced by `Catalog.core.widgets`; media specs are in `mediaCatalog` |
| `action_fields.dart` covering every action | split per library, next to each action family |
| `theme.dart` used by `managed_components.dart` | stays within features (`managed` → `publish`) |

### 6.3 Lists: a named data source instead of cloud by name

```dart
/// A kind of data a list, grid or pagination can load from, declared like a
/// widget so its settings get a panel.
final class DataSourceSpec {
  const DataSourceSpec(this.type, {required this.fields, this.pages = false, this.requires = const [], this.doc = ''});
  final String type;                      // 'data' (core: the bound list), 'cloud', 'api' (data library)
  final List<PropDef<Object?>> fields;
  final bool pages;                       // can serve pagination
  final List<String> requires;
}
```

| Today | New | Flutter spelling |
|---|---|---|
| `listView.query` (`Json`) | `source: {"type": "cloud", "query": {...}}` | `StreamBuilder(stream: query.snapshots())` around the list |
| `pagination.source: cloud` | `pagination.source: {"type": "cloud"}` | a paging controller's fetch callback |
| `pagination.source: api`, `apiId`, `parameters`, `itemsPath`, `totalPath`, `cursorPath` | `pagination.source: {"type": "api", "apiId": ..., ...}` | the same |
| `reorder.apply: cloud`, `orderField` | `reorder.apply: source` (the source applies the move; `orderField` is a field of the `cloud` source) | `onReorder` writing to the store |

Core knows `data` only. With `Catalog.core`, a `cloud` source decodes as an
unknown source and round-trips; the list shows its bound `data`.

### 6.4 The import-boundary test

`test/import_boundary_test.dart`, pure Dart, no analyzer dependency:

1. For every file under `lib/src/core/`, read its `import`, `export` and
   `part` directives; fail if one resolves outside `lib/src/core/` (or to a
   package other than `meta` and `collection`).
2. For every file under `lib/src/features/<x>/`, allow only core, its own
   directory, and the features listed for it in a small table in the test
   (`managed` → `publish`; `engage` → `publish`).
3. Decode a document containing an `auth` action and a `video` node with
   `Catalog.core`: the action is an `UnknownAction`, the node has no spec,
   and both re-encode byte for byte.

CI also analyzes `example/core_only.dart`, which imports only `core.dart`.
The SDK gets the mirror: `package:codelessly_sdk/render.dart` may import
only `package:codelessly_api/core.dart`. That is the "renderer only" split
made visible as two import lines.

## 7. Catalog export for agents, and strict validation

Both fall out of the registry; nothing is written twice.

* **`catalog.toJson(compact: true)`**: every node type with its props
  (key, kind, Flutter type, default, enum values, bounds, one-line doc),
  child model and slots; the shared node envelope (`LayoutFields`,
  `DecorationFields`, `BehaviorFields`) once; action types with fields and
  result; triggers; presets; formula functions; and `instructions`: short
  authoring rules per type and globally (written in the `doc` strings that
  already exist, plus `Catalog.instructions`). A profile
  (`catalog.select(widgets: [...], actions: [...])`) cuts it to what a task
  needs, so an agent can be given 18 components or all 66.
* **`catalog.toJsonSchema()`**: JSON Schema 2020-12; a node is a `oneOf`
  discriminated by `type`, an action likewise; expressions are
  `{"type": "string", "pattern": "\\$\\{"}` alternatives where a field is
  bindable.
* **Strict validation.** Decoding stays total for stored data (DESIGN.md
  §2.1). For authoring there is `catalog.validate(json)` returning typed
  issues instead of silent defaults:

```dart
final class Issue {
  final IssueCode code;      // below
  final String path;         // JSON pointer: /nodes/card/props/elevation
  final String message;
  final Object? expected;    // a PropType, or the allowed names
  final bool error;          // false: warning
}
enum IssueCode {
  unknownNodeType, unknownProp, unknownAction, unknownField, unknownTrigger,
  unknownSlot, unknownBindPath, unknownPreset, unknownDataSource,
  invalidValue, outOfRange, missingRequired, expressionSyntax, unknownName,
  danglingChild, childNotAllowed, duplicateId, cycle,
  deprecatedKey,             // a legacy key the decoder migrates (docs 01–04)
  capabilityNotAllowed, pluginMissing, digestMismatch, sdkTooOld,
}
```

`LayoutDocument.fromJson` is unchanged; `LayoutDocument.decodeStrict(json,
catalog)` returns the document and its issues. The editor API's
`nodes.insertTree` runs it, which would have caught petri_v2's "children on
a `box` answered ok" (`petri_v2/blockers.md` row 1).

The answer to small fixed catalogs: the wire carries Flutter's own
vocabulary including layout and styling, an agent is handed exactly the
slice it needs, every answer is checked against the same declarations that
generate the editor, and the catalog grows by hosted data, not by SDK
releases.

## 8. Migration and compatibility

| Change | Wire format | Dart API |
|---|---|---|
| Catalog parameter on decoders | none | additive (default `Catalog.standard`) |
| `ActionDef` unsealed; `CoreAction` and feature families sealed | none | **breaking** for code that switches exhaustively over `ActionDef` (the SDK's `handlers.dart:54`; editor not counted) |
| File moves | none | none through the umbrella export; deep `src/` imports break |
| `ComponentLink.managed` typed accessor moves to an extension | none | source-compatible when `managed.dart` (or the umbrella) is imported |
| List `source` object | **new shape**; the decoder reads `query`, `pagination.source` (a string), `apiId`, `parameters`, `itemsPath`, `totalPath`, `cursorPath`, `apply: cloud` and writes `source` | props renamed |
| Plugin types (`vendor.name`) | additive | additive |
| `plugins` list in the publish model and documents | additive key | additive |

`"schema": 2` stays. Nothing here needs a hand migration.

## 9. SDK effect

`CodelesslyConfig` gains `catalog` (default: standard + the project's
hosted plugins) next to `recipes`; `recipes` and `CodelesslyActions.handlers`
remain the native implementation side. New: plugin loading in the loaders
(about +250 lines), expansion of plugin nodes (about +300, reusing the
item-template instantiation in `widgets/collections_data_list.dart`), the
per-family handler registration (±0). The services directory already
separates by feature; the split there is import hygiene plus the mirror
boundary test.

## 10. Open questions for the owner

1. **Unseal `ActionDef`** (recommended; the per-family sealed classes and
   the coverage test keep the guarantee) or keep it sealed and wrap every
   non-core action in one `DeclaredAction` class (simpler, but first-party
   features lose their typed classes).
2. **Where hosted plugins are stored**: `plugins/{id}` beside
   `managed_components/{id}` (recommended), and whether third parties may
   publish or only Codelessly and the project's organisation at first
   (recommended: first-party and own-organisation only until the trust
   model has been exercised).
3. **May a plugin add behaviors or triggers?** Recommended: no. They change
   every node's envelope and the render chain; data cannot implement them.
4. **Is `Catalog.standard` the default** (recommended, nothing breaks), or
   must callers choose, to make the layers visible everywhere?
5. **Which first widget moves to a hosted plugin** as the proof
   (recommended: `gaugeMeter`, 2 apps, then `lineChart`).
6. **Package split or library split.** Recommended: libraries in one
   package now (one version, one changelog); separate packages only if a
   consumer needs to depend on core alone.

## 11. Rollout

1. `Catalog`, `ActionSpec`, `DataSourceSpec`; decoders take a catalog;
   `Catalog.standard` reproduces today's behavior exactly (all 53 test
   files pass unchanged).
2. Move files into `core/` and `features/`; cut the four edges; add the
   boundary test and `example/core_only.dart`. SDK: `render.dart` on core.
3. `PropType`/`PropDef` JSON; `Catalog.toJson/fromJson`, `toJsonSchema`,
   `validate` with `IssueCode`; wire `decodeStrict` into the editor API.
4. Native plugin declarations: editor panels for `Catalog.fromJson` types;
   one sample plugin end to end.
5. Hosted plugins (after docs 01 and 02): package format, `PluginRef`,
   loader, cache, digest check, expansion; `gaugeMeter` as the first.
6. Move further widgets per §5.5's table, one release each, each with its
   goldens unchanged.

## Implementation notes (2026-11-13)

Implemented in `codelessly_api` (lib/src/core/catalog.dart, catalog_json.dart,
lib/src/features/*, lib/src/standard_catalog.dart) and `codelessly_sdk`
(runtime/actions/feature.dart, runner.dart, features/hosted, app/hosted_plugins.dart).

### Deviations from the proposal

1. **The default catalog is `Catalog.core`, not `Catalog.standard`.** A
   static decoder in the core (`LayoutDocument.fromJson`) can only default to
   something the core library can name; naming the standard catalog would put
   every feature library in the core's import closure and defeat §6.4. So
   decoders default to `Catalog.current` (the catalog of an enclosing decode or
   `Catalog.run`, else `Catalog.core`), and code reading feature types passes
   `standardCatalog`. Undeclared types still round-trip byte for byte; `Props`
   decode a raw value read through its `PropDef`; `Catalog.upgrade` types an
   `UnknownAction` later (the SDK's runner does, with its catalog). The API's
   tests that decode feature types pass `standardCatalog`.
2. **`standardCatalog` is a top-level constant, not `Catalog.standard`**: a
   static of `Catalog` would live in the core. `Catalog.core` exists.
3. **Nested decodes find the catalog through a zone value** (`Catalog.current`
   while a decode runs) rather than a parameter on every codec: reactions are
   decoded inside prop codecs (`PropCodec.decode(json)` has no context). It is
   scoped to the synchronous decode, not a registry.
4. **The core stays one directory, `lib/src/core`, with `theme.dart` in it**:
   the renderer reads theme tokens (`render/node_tree.dart`), and Flutter's
   `Theme` is core Flutter. `services/config.dart` (`ServiceConfig`, which
   composes the data and commerce configs) sits at `lib/src/service_config.dart`
   with the standard catalog rather than in publish, which would then import
   two features.
5. **`submitForm` is in the data library, `downloadFile` in media**, where the
   SDK runs them (data's form services; media's file saving), so each SDK
   feature's catalog is exactly the API library it pairs with.
6. **`preloadImages`, `captureScreenshot` and `emitEvent` moved as proposed**:
   their SDK handlers moved from the core switch into the media and engage
   features.
7. **The boundary test is `test/library_boundaries_test.dart`**; its exception
   list is empty; the allowed feature dependencies are the proposal's
   (managed → publish, engage → publish).
8. **The SDK's core-only proof follows imports into the API package**
   (`test/core_only_import_test.dart`) instead of adding a `render.dart` entry:
   render, widgets, runtime and scripting import `package:codelessly_api/core.dart`
   only. That needed the video, audio, embed and web view players to move to the
   SDK's media feature (they render through `CodelesslyFeature.recipes`), cloud
   lists to take their query as JSON, and the core runtime to stop importing
   `app/fonts.dart` and `app/viewport.dart`'s barrel.
9. **Hosted plugins reuse `ManagedComponentMaster`, `Semver`, `sdkSatisfies`
   and the version storage shape**, but a release is a `PluginVersion`
   (payload: the package) rather than a `ManagedComponentVersion`, whose
   payload must be a component definition.
10. **A hosted node type renders in an island** holding its own node tree with
    the node's props in scope, rather than the list item-template expansion.
11. `IssueCode`/`validate`/`toJsonSchema` were not built here: the reference
    generator and `lib/validate.dart` (merged from the base) cover them; they
    walk `Widgets.all`, the `*Fields` classes and `ActionSpecs`, which are views
    of `standardCatalog`.

### Not done

* **The list `source` object (§6.3).** Writing `source` changes the JSON and
  the SDK's list runtime; lists keep `query`, `pagination.source`, `apiId`,
  `parameters`, `itemsPath`, `totalPath`, `cursorPath`, `apply: cloud`. The
  `data`, `cloud` and `api` sources are declared (`DataSourceSpec`) so editors
  and validators can describe them. To do: a `DataSourceSpec`-typed `source`
  prop on listView/gridView/pagination, a decoder that reads the legacy keys
  into it, the SDK list runtime resolving it through the installed features.
* ~~Hosted plugins in the running app~~ and ~~hosted widget events and slots~~: done (2026-11-13,
  docs/design/06 "Implementation notes (phase 2)"): `Codelessly` installs `model.plugins` through its loader as
  a `PluginSource` (bundle-embedded versions, `plugins/{id}/versions/{n}` over HTTP and in Firestore), a plugin
  node type is a component definition rendered on the components' path (slots, events, hug and fill, per-node
  watching), its action types run through `Codelessly.actions`. The island (deviation 10) is gone.
* **Plugin assets and scripts**: assets aren't fetched or digest-checked; plugin scripts are carried but not
  installed in the script runtime; automations run hosted action types only when the app's runner installs them.
* **Capability profile per project**: `allowed` is a parameter; nothing
  stores a project's allowed capabilities yet.
* **`animationPresets` in the catalog**: presets live in `AnimationPresets`
  (the animation work); the catalog does not list them.
* **Editor port**: panels from `Catalog.fromJson`, a plugin browser, publish
  as plugin.
