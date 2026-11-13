# API design proposals

Proposals for `codelessly_api`. The first five were written after the audit
of the model that grew while about 60 reference apps were rebuilt; the sixth
after the m05 authoring experiments; the seventh and eighth map the
generative-UI landscape and propose the API for AI built on it. Each is meant to be
approved or changed by the product owner, then implemented from. Breaking
changes behind migration are accepted.

## Governing rules

Distilled from the owner's direction. Every proposal is checked against
them.

1. **Flutter's name and shape first.** A construct that exists in Flutter
   takes Flutter's name, parameters and defaults. Each proposal states the
   Flutter spelling of every construct it adds.
2. **Additions are allowed only if generic, reusable and declared.**
   Something Flutter lacks (a chart, a value track along a path) may exist
   if any app could use it and it is declared as `PropDef`s, so the editor
   has controls for it.
3. **No one-app fields.** A field one reference app needed is made generic
   or removed, with the binding or formula recipe that replaces it written
   down.
4. **One way to do each thing.** Short forms survive as presets that expand
   to the one primitive; the SDK has one player.
5. **Feature layers sit on a registry; the core is unaware of them.** Auth,
   data, commerce, media and publishing are libraries that add to a catalog.
   A renderer-only build is visible as one import.

## The documents

| # | Document | What it decides |
|---|---|---|
| 1 | [CustomPaint as data](01-paint-node.md) | A `customPaint` draw list mirroring `Canvas`, with `repeat`, a view box, hit regions, and a path built from `Path` calls. 30.1.0 moves `strokePath`, `subpathColors` and `gradientPerSubpath` onto it and a box's `path` onto the path node; `plotChart`'s Cartesian props stay as the chart's general features |
| 2 | [Animation](02-animation.md) | `animations` (an `AnimationController` with tween tracks on any binding path), one `animate` action, a `frame` trigger, one `Spring`. Loops, effects, entrances, spins, keyframes become presets. `clock` folds into `timer` |
| 3 | [Motion](03-motion.md) | `Motion` from 50 fields to a 14-field transform plus a shared `PathFollow`; `transitions` per property; one way to scale and rotate |
| 4 | [Drag and track](04-drag-and-track.md) | `drag` splits into `dismissible`, `track`, pan in `transformGesture`, and the list's `reorder`. 162 fields to 69. `controlDrag` becomes three typed actions. Transform handles become a component |
| 5 | [Plugins and layers](05-plugins-and-layers.md) | A `Catalog` passed to decode; `ActionSpec`; hosted plugins as data on the managed-component machinery; native plugins as the second tier; the core/feature library split with an import-boundary test; catalog and JSON Schema export with strict validation |
| 6 | [Sections and components](06-sections-and-components.md) | A page composed of component documents by reference: a call is one node whose `type` is the component id; parameters (`${props.x}`, PropDef-declared), slots, events, per-instance state; document-local ids with instance-keyed boxes; no overrides; one mechanism at document, project and hosted scope replacing copies, managed snapshots and plugin islands; project variables; the render command per component |
| 7 | [Generative-UI landscape](07-landscape.md) | Research, 2026-11-13: A2UI 1.0 (and Express), Vercel's UI SDK (2026-11-12) and json-render, MCP Apps, OpenAI, AG-UI/CopilotKit, code-into-sandbox, Flutter options and code generators, verified from primary sources; a comparison table with an honest Codelessly column; what to adopt from each |
| 8 | [The API for AI](08-ai-developer-experience.md) | Positioning (the app as an editable document); six id-addressed edit ops with merge patch per node and per-op validation; a headless `codelessly` CLI/MCP for design-time agents; a runtime `UiSession` with two LLM tools (`ui_apply`, `ui_read`), streaming with placeholders, events and undo; trust profile as a restricted catalog; A2UI/MCP Apps/AG-UI interop; build order, paired-corpus evaluation and ranked decisions |
| 9 | [Inline generative UI: the use cases](09-genui-use-cases.md) | What A2UI, json-render, the OpenAI Apps SDK, assistant-ui and Tool UI show an assistant rendering in a conversation; thirteen use-case types ranked by sources; our streaming test list and the briefs to add; the demo page |
| 10 | [The audit's verdict](10-audit-verdict.md) | What the audit found, what changed, what has no Flutter counterpart and why it stays, the verdict on the path (Flutter API → data model → renderer → feature layers), and what is not finished |

## AI authoring

The product's core idea is: a natural-language description becomes an app
as data, and the app is then edited as data. Language models write Flutter
far better than they write a schema they have never seen, which is why
other systems restrict them to a small catalog. These proposals take the
other route: make the data so close to Flutter that translating between
widget code and data is mechanical in both directions.

| Flutter a model would write | The data |
|---|---|
| `Padding`, `SizedBox`, `Expanded`, `Flexible`, `Positioned`, `Align`, `ConstrainedBox`, `AspectRatio` | `layout` |
| `DecoratedBox`, `ClipRRect`, `BoxShadow`, `BackdropFilter` | `decoration` |
| `Row`, `Column`, `Stack`, `Text`, `ListView`, Material widgets | node types of the same name, props by parameter name |
| `Transform`, `FractionalTranslation` | `motion` (doc 03) |
| `AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale` | `transitions` (doc 03) |
| `AnimationController` + `Tween` + `Interval`, `TweenSequence` | `animations` (doc 02) |
| `CustomPaint` + `Canvas` calls | `customPaint` (doc 01) |
| `Hero`, `Draggable`, `DragTarget`, `Dismissible`, `InteractiveViewer`, `Slider` | behaviors of those names (doc 04) |
| `onTap`, `onChanged`, `Navigator.push`, `setState` | `actions`: triggers, `navigate`, `setVariable` |
| a widget from a package | a plugin node type (doc 05) |

Each document carries a "Flutter spelling" column or line for its new
constructs. Doc 05 supplies the other half an agent needs: a catalog it
can be handed in full or in a slice, a JSON Schema, and strict validation
with typed error codes, so a wrong answer is rejected with a path and an
expected type instead of being silently defaulted.

Where a rule and authoring pull apart, the choice was made for authoring:
draw ops and actions hold expressions inline (a model writes
`"rotate": "${= index * 6}"` where it would write the Dart expression),
and presets keep `{"preset": "pulse"}` short.

## Decisions the owner must make, ranked

Ranked by how much later work depends on them.

1. **Unseal `ActionDef` and pass a `Catalog` to decode** (doc 05 §3, §10.1).
   Everything about plugins, layers and the agent catalog depends on it.
   Recommended: yes, with per-family sealed classes and a coverage test.
2. **Hosted plugins are data on the managed-component machinery; native
   plugins are the second tier** (doc 05 §5). Confirms the capability
   boundary and who may publish (recommended: first-party and the project's
   own organisation first).
3. **`customPaint` as a behavior on any node, not a new node type**
   (doc 01 §10.1). Recommended; it makes `strokePath` and `box.path`
   migrate without inserting nodes.
4. **Inline expressions in draw ops** (doc 01 §10.2), as actions already
   have them, rather than every bound value in the node's `bind` map.
5. **One animation primitive with presets, and removal of `loops`,
   `effectAnimations`, `playAnimation`, `animateVariable`,
   `setVariable.animateMs`, `clock`** (doc 02). Includes whether tracks may
   write variables (recommended: yes, with the cost shown).
6. **`Motion` is a transform only**: `opacity` and `blur` leave it;
   `layout.rotation` and the node-level `scale` fold into it (doc 03 §9).
   This reaches into the Figma-shaped envelope in one place.
   *Done:* `opacity` and `blur` in schema 3; `layout.rotation` and `scale` in
   30.1.0, still schema 3 (doc 03, "Done in 30.1.0"), with `flightKey`/`flight`
   folded into `hero` (doc 04, "Done in 30.1.0").
7. **The `drag` split**: pointer-follow merges into `transformGesture`; the
   track stays on the thumb node (doc 04 §10.1–2).
8. **Flutter's defaults where the model invented its own**:
   `draggable` with no return spring, no feedback tilt and no shadow by
   default; the slot for refused drops (doc 04 §10.3, 10.5); `Stroke.width`
   1 vs Flutter's 0 (doc 01 §10.3). Existing documents are migrated to look
   the same; only new ones change.
9. **How long legacy keys stay readable.** Proposed everywhere: decoders
   read them for one release after the SDK no longer needs them, and
   strict validation reports each as `deprecatedKey` from day one.
10. **Libraries in one package, or separate packages** (doc 05 §10.6).
    Recommended: libraries now.

## Sequencing

| Phase | Work | Depends on |
|---|---|---|
| A | Doc 05 steps 1–3: `Catalog`, `ActionSpec`, file moves, boundary test, catalog JSON, strict validation | — |
| B | Doc 02: `Spring`, `animations`, `animate`, `frame`, presets, legacy decoders; SDK player | — (parallel with A) |
| C | Doc 01: `customPaint`, compiler, hit regions; petri_v2 benchmark | A for the `DrawOp` union type in panels; B for animated drawings |
| D | Doc 03: slim `Motion`, `PathFollow`, `transitions` | B |
| E | Doc 04: `track`, `dismissible`, physics, typed commands; Selection box component | B, D |
| F | Doc 05 steps 4–6: native plugin declarations, hosted plugins, first widgets moved to hosted data | A, B, C |
| G | Rebuild the hand-migrated reference spots; delete legacy readers and the emptied SDK code | all |

A and B can start now and do not conflict. Each phase lands with decoders
that read the old keys, so the reference apps keep running between phases.

## Compatibility, in one place

*Superseded by schema 3:* documents are `"schema": 3`. Schema 3 (codelessly_api 30.0.0; 30.1.0 added one-way steps
that give each concept one spelling, docs/guide/12-migrating-to-schema-3.md, "30.1.0"): a schema-2 document is
migrated once, in memory, by `migrate2to3`, and the legacy readers described below live in that migration,
not in the decoders (docs/guide/12-migrating-to-schema-3.md, docs/design/schema-3-migration-report.md). The
text below is the schema-2 plan as it was: documents kept `"schema": 2`; loaders rejected other numbers, so
nothing here bumped it. Every change is made in decoders (`Behaviors.fromJson`,
`Motion.fromJson`, `ActionDef.fromJson`, `Trigger.fromJson`,
`Node.fromJson`): they read the legacy keys, return the new values and
rewrite `bind` keys; encoders write only the new shape. Each document lists
exactly what a decoder cannot do. The hand work, all of it:

| Spot | Apps | Doc |
|---|---|---|
| `plotChart` Cartesian graph → draw list | plotter_v2 | 01 |
| Bound-box grids → one painter (optional, for speed) | petri_v2, apiary | 01 |
| `subpathColors` | apiary, northstar | 01 |
| `spinRamp`, `arc`, `pathPacing: area`, `pulseKey` | lineworks_v2, lineup, orrery, chairlift, flashcards | 02, 03 |
| Fine mode, `parkedProgress`, `disabledFollow`, `shareAs` | cutroom, cutroom_v2, darkroom, apiary, flashcards, gesture_lab | 04 |
| Transform handles → Selection box component | cutroom_v2, gesture_lab (and up to 3 more) | 04 |
| Drop targets outside their list | not counted | 04 |

## How the evidence was gathered

* Model facts cite `file:line` in this worktree; SDK facts cite
  `CodelesslySDK/lib/src/...`; Flutter names were checked against
  `/opt/flutter/packages/flutter/lib/src`.
* "N apps" means: apps under `CodelesslyEditor/references/` whose `editor/`
  or `tool/` build sources (`.json`, `.py`, `.mjs`, `.js`, `.cjs`, `.dart`)
  contain the key as `"key"`, `'key'`, `key:` or `key=`. It is a text grep.
  It over-counts common words (`loop`, `phase`, `smooth`, `follow`, `arc`,
  `write`) and can under-count a key a generator sets through a helper
  under another name. Where a count is known to be inflated the document
  says so.
* Flutter-side painter count: `grep -rn "extends CustomPainter" references/*/lib`
  (250 in 51 apps).

Not verified: the audit's totals (228 blockers, 44% one-app) were not
re-derived; `dart:ui` `Canvas` method names were not checked against source
(not in the Flutter tree used); A2UI's component count is as given in the
brief; every LOC figure is an estimate from file sizes and reading, not a
measured diff; no proposed design was prototyped, and the performance
targets in doc 01 need the benchmark named there.

## Where the code differs from the audit summary

* `plotChart` has 68 props in its spec (`widgets/indicators.dart:539-549`),
  not 69.
* `motion.pulseKey` is declared and used by two apps' build sources but the
  SDK never reads it: it is not a working one-shot mechanism.
* `widgets/collections*.dart` do not import the cloud query model. The
  coupling is by name (`query` as untyped JSON, `PaginationSource.cloud`,
  `apiId`), so there is no import edge to cut there, only a vocabulary to
  move (doc 05 §6.3).
* `drag.reorder` duplicates a list-level `reorder` prop that already exists
  (`widgets/collections_models.dart:260-288`); `DropTarget`'s list-slot
  fields duplicate it too.
* `layout.rotation` was a paint transform in the SDK
  (`render/node_tree.dart:1003`), not layout: 30.1.0 made it `motion.rotate`.
* `hoverDelay`, `flyOutDistance`, `flyOutCurve`, `rotationSnap`,
  `scaleXVariable/Y`, `Motion.springStiffness/Damping` have no user in any
  reference build source.
* Confirmed as stated: `clock` is the same `Timer.periodic` as `timer`
  (`runtime/actions/wiring.dart:308`) and `lookaheadMs` is read nowhere;
  `Motion` 50, `DragTrack` 51, `DragMotion` 33 fields; `ActionDef` sealed
  with a private decoder map (42 entries).
