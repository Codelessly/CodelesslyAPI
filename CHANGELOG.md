## Unreleased: schema 4

**Schema 4: one Transform, one Hero.** Documents are `"schema": 4` (`kSchemaVersion`). Schema 2 and 3 documents
load and are migrated in memory (`migrate2to3`, then `migrate3to4`); nothing about a schema-3 document's meaning
changed, the fields below moved. docs/guide/13-migrating-to-schema-4.md is the authors' guide;
docs/design/schema-4-migration-report.md the migration over the corpus (106 documents, 0 failures, 702 rewrites,
nothing unconvertible, no behaviour change); docs/design/03-motion.md and 04-drag-and-track.md ("Done in schema 4")
say what was decided and why.

- **Breaking: the node's `scale` and `layout.rotation` are its `motion`.** Both were paint transforms
  (`Transform.scale`, `Transform.rotate`; neither changed layout), so `motion` is the one way: `Behaviors.scale`,
  `Layout.rotation`, `BehaviorFields.scale`, `LayoutFields.rotation`, `BindPaths.scale` and `BindPaths.rotation`
  are gone. The migration (step `transform.fold`) multiplies the scale into `motion.scale` and adds the rotation to
  `motion.rotate`, keeps schema 3's rotation pivot (its center moved by half an uneven margin) as a translation,
  moves bindings (product and sum formulas), `scale`/`layout.rotation` transitions (to `motion.scale`/
  `motion.rotate`: a transition keyed by a sub-path times it apart from the rest of the motion), tracks and
  keyframes; a scale that changed with no transition beside a motion transition gets a `motion.scale` one with no
  duration, so it still snaps. State and media patches (`patches.schema4`) set the moved paths explicitly at the
  patched node's values.
- **Breaking: `flightKey` and `flight` are the `hero`.** `HeroTag` gains `flies` (`HeroFlies.betweenScreens`,
  Flutter's `Hero`, the default; `inPlace`, what `flightKey` did: fly in from where the node with the tag was) and
  `flight` (how an in-place flight moves); `HeroTag.flight` (the look) is `flightShuttle`
  (`Hero.flightShuttleBuilder`). `Behaviors.flightKey`, `Behaviors.flight`, `BehaviorFields.flightKey` and
  `BehaviorFields.flight` are gone. Step `hero.flight`; a node with both a hero and a flight key keeps its hero and
  the rest is kept as `legacy.*` and reported.
- **The migration framework:** `migrate3to4`, `schema4Steps` (`nodeSteps3to4` is where a schema-4 node step is
  appended; `patches.schema4` re-expresses patches through all of them; `movedPaths3to4`), `migrateDocument`,
  `migrateNode`, `migrateNode3to4`, `migrateJson` (any older carrier to 4); `migrate2to3` stops at 3.
  `MigrationScope.document` lets a node step read the document it is in; `MigrationScope.schema`. `setValue` and
  condition paths are rewritten (`paths.schema4`); one that reaches a running app unmigrated is named by
  `schema3PathHint` (`olderSchemaPathHint` for either older schema). `tool/migrate.dart` migrates to 4;
  `tool/migration_corpus.dart --to 3|4` reports either migration.
- **Validation:** `schema_outdated` (info) for schemas 2 and 3; `schema_version` for none or newer than 4. Schema
  3's `scale`, `flightKey`, `flight` (node keys), `layout.rotation` and a string `hero.flight` in a schema-4
  document are reported with where they went; a schema-3 bind path with the path to write.
- **Reference:** regenerated; the animation page covers the one motion and the one hero; the examples and the
  carriers' docs say `"schema": 4`.

## Unreleased

**The reference for authors is one base plus links.** `docs/reference/STARTER.md` is the base an agent reads in
full (the document and the flat node map; layout, decoration, text with a theme; the base node types and which
types take children or slots; variables, bindings, reactions; media rules; the rules that are easy to get wrong;
an index); every other feature area is a page with the same six sections (When to use, Minimal example,
Reference, Patterns, Pitfalls, See also); `index.md` maps needs and every declared name to their section. Each
node type, behavior, trigger, action, model, enum, value type and formula function is on exactly one page
(`tool/reference/src/areas.dart`; a test checks it, and that every link and anchor resolves).

- **One base, two forms.** `baseDocument({form, catalog, profile, kind, docsTool})` assembles the base from the
  generated segments of `tool/reference/templates/base.md`: `BaseForm.files` is `STARTER.md` (with checking your
  work and sites as files), `BaseForm.runtime` is `runtimeStarter()` and `RUNTIME_STARTER.md` (with the
  answering rules, the ops and two examples). The runtime base is about three times the earlier one (≈ 43k
  characters against 15k): it now carries the theme, layout patterns, the children table and the index.
- **`ui_docs` serves the pages.** `docsTopic` answers a page (When to use, minimal example, pitfalls, its
  sections), any section by its anchor, or any node type, action, trigger or behavior by name; `docsIndex` is the
  index the base ends with; `docPages`, `docTasks` are the generated data; `toRuntimeLinks` turns the files'
  links into `ui_docs` topics. Earlier topic names (`responsive`, `reactions`, `gestures`, `scripts`...) still
  answer. `starterProps`, `behaviorAreas` and `guideTopics` are gone (`baseProps`, `docPages`).
- **Machine forms.** `catalog.json` names each node type's, action's, behavior's and trigger's page and anchor
  (`docs`); `index.json` lists every topic with its file, anchor, summary and size.
- **Retired.** `nodes.md`, `behaviors.md`, `triggers.md`, `actions.md`, `bindings.md`, `formulas.md` and
  `variables-conditions-scripts.md` are stubs that keep their anchors and say where each item went; the old
  guide's `index.md#guide-...` anchors land on a table of where each section went; `API_REFERENCE.compact.md` is
  gone (the base's runtime form replaces it); `API_REFERENCE.md` is the base, the index and the pages in order.
- **Docs at the declarations** for the props and fields the base shows.

## 30.0.0

**Schema 3: the one planned format break.** Documents are `"schema": 3`. Schema 2 documents load and are
migrated in memory; write schema 3. `LayoutDocument.fromJson` (and `PublishModel`, `PublishBundle`,
`PublishLayout`, `PublishComponent`, `ComponentDefinition`, the site manifest and plugin packages, through
the documents they hold) migrates a schema-2 document (or one with no `schema`) before decoding it; encoders
write `"schema": 3`. The guide's new chapter, docs/guide/12-migrating-to-schema-3.md, is the authors' migration
guide; docs/design/schema-3-migration-report.md is the migration over the reference apps and experiments.

- **The migration:** `migrate2to3(Json document, {MigrationReport? report})` (pure, total, idempotent),
  `migrateNode2to3`, `migratePublish2to3`, `migrateJson2to3` (any file that carries documents; a stored
  payload or a stored published component, whose digest covers what was stored, is migrated when read),
  `schemaOf`, `kSchemaVersion` = 3, `kPublishSchemaVersion` = 3, `schema3Steps` (named `MigrationStep`s).
  `MigrationReport` lists every rewrite, every value with no schema-3 form (kept on the node as
  `legacy.<name>`, unread, with what to write instead) and every behaviour change; `migrationReportMarkdown`.
  Commands: `dart run tool/migrate.dart <file|dir> [--write] [--report out.json]`,
  `dart run tool/migration_corpus.dart` (corpus checks and the aggregated report).
- **Validation:** `validateDocument` reads 2 and 3: a schema-2 document gets the `schema_outdated` note
  (`Severity.info`) and is validated as migrated; `legacy_value` (warning) flags a kept value; an expression
  is accepted where a field takes one inline (`ExprCodec`: a timer's `intervalMs`).
- **Breaking (Dart): the legacy readers are gone from the model**; the migration has them. `Behaviors.migrateBind`,
  `Behaviors.legacyKeys`, `Behaviors.effectiveTransformGesture` (use `transformGesture`),
  `TransformGesture.zoomable`, `DragRelease`, `Spring.legacy`, `PathFollow.fromLegacy`, `Track.fromLegacyDrag`,
  `Track.readsOnly`, `DismissibleBehavior.fromLegacyDrag`, `Pan.fromLegacyDrag`, `AnimationPresets.fromLoop`,
  `fromEffect`, `fromMotion`, `fromPulseKey`, `legacyLoopMode`, `loopTypes`, `effectTypes`,
  `legacyMotionSpring`; `SetVariableAction.animateMs` and `curve` (`SetVariableFields.animateMs`, `curve`).
  Decoders no longer read `loops`, `effectAnimations`, motion's temporal keys, `opacity`, `blur`, `originX/Y`
  and flat path keys, `drag`, `zoomable`, a track's `endAngle`/`endless`/`jumpOnTap`/`wheel`/`keyboard`/
  `momentum`/`friction`/`write`/`settleStiffness`/path string, a draggable's `whileDragging`/`feedbackNodeId`/
  `feedbackAnchor`/`dragAnchorStrategy`/`spring*`/`physics`, flat physics springs, the `transitions` object and
  map, `gradientUnits`, `playAnimation`, `animateVariable`, `setVariable.animateMs`, `controlDrag`, the `clock`
  trigger: in a schema-3 document they are unknown keys (kept, unread).
- **Breaking (Dart and JSON): the deprecated one-app fields are removed** (the migration keeps a value that
  did something as `legacy.<behavior>.<field>` and reports what to write instead): `Track.defaultValue`,
  `doubleTapValues`, `parkedProgress`, `fineStep`, `finePixelsPerRange`, `fineHold`, `fineVariable`, `smooth`,
  `gain` (and `hasFine`, `isParked`, `doubleTapTarget`, `effectiveFinePixelsPerRange`, `${track.fine}`);
  `DismissibleBehavior.restX`, `restY`, `xVariable`, `yVariable`, `flyOutRotate`; on `DismissibleBehavior` and
  `Pan`: `rotateFactor`, `originX`, `originY`, `shakeWhenDisabled`, `disabledFollow`, `shareAs`, `follow`;
  `PathFollow.pacing`, `focus`, `pacedByArea`, `headsLeft`, `PathPacing`, `PathOrient.uprightFlip` (now
  `upright`); `Transition.arc`; `DropTarget.fullIf`, `slotWhenRefused` (the slot opens for accepted drags
  only), `hoverDelay`, and the `dropFull` and `dragHover` triggers; `GestureSnap.projectVelocity` (a snap
  always projects the fling); `TransformGesture.rotationSnap`; `OpenModalAction.showCloseButton`,
  `fullHeight` (never read). Their `*Fields` declarations go with them.
- **Flutter's reading where schema 2 had its own** (the migration writes out what schema 2 did, so migrated
  documents render the same): a text's `layout.padding` is applied (`Padding(child: Text)`, counted in a hugging
  size); schema 2 ignored it and the migration drops it from schema-2 texts (step `text.padding`, with the
  bindings and state and media patches that set it). The `layout_field_ignored` warning for a text's padding is
  gone. A text style without a `height` takes the inherited `defaultTextStyle` (new behavior on any node,
  Flutter's `DefaultTextStyle`: the nearest one wins, `{}` gives Flutter's defaults back), else the font's own
  line height (Flutter's `height: null`), not 1.33; the migration keeps 1.33 for schema-2 documents with one
  `"defaultTextStyle": {"height": 1.33}` per top-level node (step `text.lineHeight`; +0.08% bytes over the
  corpus). **Breaking (Dart and JSON):** `TextStyle.naturalHeight` (`TextStyleFields.naturalHeight`),
  `ThemeTokens.naturalLineHeight` and `StyleSheet.naturalLineHeight` are removed; the migration turns a natural
  style into its node's `"defaultTextStyle": {}`, and drops (reporting) a theme's flags, which a document
  migrated on its own cannot see. `migrateJson2to3` and `migratePublish2to3` drop them from carriers;
  `dropNaturalLineHeightFlags`. `tool/migration_corpus.dart` reports the encoded size before and after.
- **Paths an action names** (`setValue`'s `values[].path`) are not migrated: `schema2PathHint(path)` gives the
  schema-3 path for a schema-2 one, and `unknown_bind_path` says it (`motion.originX` → `motion.alignment`,
  `loops[i].<key>` → `animations.loop<i>.<key>`, `drag.track.<key>` → `track.<key>`...).
- **Behaviour changes** (all reported by the migration, per document): a track with no value is drawn at
  its minimum, not at `defaultValue`, and a double tap resets nothing; the fine mode, `smooth`, a dismissible's
  tilt and fly-off spin, disabled follow and shake, `shareAs`, area pacing, the upright flip, a transition's
  arc, `fullIf`/`dropFull` and a hover delay no longer act; a refused drag opens no list slot; a
  `setVariable` glide that is not a set, add or subtract by one formula sets at once. Over the corpus:
  cutroom's fine step and safecracker's `smooth` (docs/design/schema-3-migration-report.md).


**Streaming generative UI, hardened against real model output**

- `OpStreamDecoder` recovers every well-formed op from tool input that is not valid JSON (eager tool input
  streaming does not promise it; a recorded live generation closed one brace too many three times): a repaired copy
  of the text (stray closers dropped, missing ones inferred, trailing commas removed, missing commas inserted), op
  objects read at any depth outside another op, re-synchronisation when an op begins before the previous one
  closed. Each repair is one `malformed_input` warning with the character offset; `OpStreamEnd.repairs` and
  `.recovered`; `StreamedOp.recovered`. A set op's node fields written beside `"node"` move into it
  (`misplaced_field`). Property tests: any chunking yields the same ops; 2,000 single brace, bracket or comma
  edits lose no op but the one they land in; the three recorded live generations decode whole (24, 50, 34 ops).
- The retry protocol: `EditResult.toModelJson()` says what the document holds (ids set, patched, moved, removed;
  roots, node count, pending) and, when anything is rejected or pending, `next` (fix by patching, same ids, never
  start over); `fixInstruction`; `EditResult.withDiagnostics`. `applyOps(protectRoots: true)` answers a batch
  that would replace the roots or add a canvas with `start_over`. `explainDiagnostic` spells out the fix for the
  codes models hit (`unknown_layout_key hug`, `children_not_allowed` and `invalid_parent` with the types that take
  children, a button's `text`, `would_orphan`, `canvas_as_child`); `atOp` moves the op path with the index.
- `uiLints`: `empty_button`, `low_contrast` and, with a `GlyphCoverage`, `missing_glyph` (with the icon to use);
  codes `no_size` for renderers; `fontCodepoints` reads a font's cmap.
- The runtime docs: `runtimeStarter` is the base set a chat card or small screen needs (layout, decoration and text
  essentials; one table of the base node types with what takes children and their key props, the button family and
  the inputs and lists included; state, bindings, reactions; two examples that apply cleanly), generated from the
  declarations; `docsTopic` answers the `ui_docs` tool for any node type, action type, trigger, behavior or
  feature area (the guide's sections, `guide_topics.g.dart` written by the reference generator); `docsIndex` is the
  base's index. `uiTools(catalog, compact: true, docs: true)`: the op envelope strictly plus `ui_docs`; `ui_read`
  takes `types` (`describeTypes`). Generated: `docs/reference/RUNTIME_STARTER.md`, `ui_tools.compact.json`.
- `TrustProfile.agentApps`: `agent` plus the document's sandboxed scripts (capabilities `variables.read`,
  `variables.write`, `clock`; `TrustProfile.scriptCapabilities`). The `scripts` op sets and removes them by name
  (`ScriptsOp`, `invalid_script`), with an inverse for undo.

**Components in published apps, hosted plugins as components (sections and components, phase 2)**

- `PublishModel.components` (`{type: {version, digest, lastUpdated, fonts}}`, `PublishComponentInfo`),
  `PublishLayoutInfo.components` (the closure a layout calls), `PublishComponent` (stored at
  `PublishSource.componentPath`: `publish/{p}/components/{type}`, `{"schema": 2, "id", "version", "digest",
  "document"}`; a document decoded from a store is written back as stored), `PublishBundle.components` and
  `PublishBundle.extra`. `PublishModel.fontsOf` adds the fonts of the components a layout calls. `canonicalJson`:
  what a component's digest (sha256, computed by the publisher) is over.
- Hosted plugins on the components' path: `PluginWidget.definitionJson` and `PluginPackage.definitions` turn a
  plugin node type into a component definition (its catalog declaration as `widget`, its slots as `slot` nodes,
  its events declared, its formula functions as the root's variables). `PublishBundlePlugins`
  (`pluginVersions`, `withPluginVersions`): plugin payloads embedded in a bundle.
- Validation: `repeated_subtree`, a new `Severity.info`: a subtree of three or more nodes written several times
  over, node for node (ids and names aside), with the copies' ids: "consider a component or a list template".
  Only exact repeats; a repeat inside a reported one is not reported again.
- Docs: DESIGN.md §2.1, §4.2, §4.3, §5.4; docs/design/06 and 05 "Done" / "Not done"; the guide's components
  section (published sites, per-instance rules, slots inside lists, plugins as hosted components,
  `--components-all`, `repeated_subtree`).

**Authoring fixes from the third direct-authoring experiment (cycle 3)**

- Named colors and text styles. The site manifest declares the project's theme (`SiteManifest.theme`: colors,
  text styles, roles, `dark`, and `ThemeTokens.media`, rules that patch the theme by screen size); a color field
  may name one of its colors (`"color": "ember"`, kept through decode and encode as `Color.named`) and a text
  style may start from a named one (`"style": "title"`, or `{"from": "title", ...}`: `TextStyle.from`, merged as
  `TextStyle.merge`). `ThemeTokens.color`, `textStyle` (resolved: `from` chains, colors by name, aliases),
  `atScreen`; `ThemeRefs` / `resolveThemeRefs` resolve a node or a document by its declarations (props,
  decoration, behaviors, media and state patches), leaving the nodes that name nothing the same objects.
  `Color.fromHex` reads values only (the old `fromJson`). A media or state patch that names another style
  replaces the style; one that changes fields merges over the named style. New diagnostics `unknown_theme_name`
  (with the nearest name) and `invalid_theme`; `validateTheme`; `ValidateOptions.theme` (the manifest's by
  default). **Behaviour change (documents that validated stay the same):** a color string that is neither a hex
  color nor anything else (`"blue"`) decoded to null and now decodes as an unresolved theme name (transparent);
  validation reported it before and reports it now.
- `IconProps.size` (Flutter's `Icon.size`).
- A media rule's patch may set `bind` (bindings at its sizes only; `null` drops one of the node's) and `motion`
  (a paint-only transform). `media_overridden` says how to combine a rule and a binding.
- `layout_clamped` points to the overlap patterns (motion translate, a stack).
- Docs: the guide and the starter lead with the theme; overlapping a neighbour, bleeding past the gutter, a
  verified full-width band with capped content and a table from one cell template, form control styling,
  `foregroundFills` over children, a literal `$` before an expression, superscripts, arrow keys through
  `keyDown`, component parameter kinds; the allowed-modes table marks fill with `basis` in a wrapping row;
  `bindings.md` lists what each path expects.

**Authoring fixes from the second direct-authoring experiment (cycle 2)**
