## Unreleased

- `strictEditCheck` passes its options' `theme` on to the validator (it dropped it): a session with a design system
  checks each op against the design system's tokens, so a theme color or text style name (`primaryBackground`,
  `sectionTitle`) is no longer rejected as `unknown_theme_name`.
- `TrustProfile.withComponents(library)`: the profile with a component library's types allowed. A session given a
  design system checks ops with it (the SDK's `UiSession(designSystem:)`): `TrustProfile.agent` lists the core's node
  types only, so every call to a design system component was `capability_not_allowed`.

## 30.1.0

**No special cases left: the last 21 one-look fields are general mechanisms.** Documents stay `"schema": 3`.
Each removed field is migrated by a one-way step at the end of `migrate2to3` (`steps_special.dart`); in a
schema-3 document each is an `unknown_prop` whose message names the form to write, and a `setValue` path into one
is rewritten where it has a place (`props.displayFormat`, `props.highlightStart`/`End`) or reported. No document in
the corpus or either repository used one. Name conformance (docs/design/name-conformance.md, regenerated): 853
fields, 62% Flutter's name and meaning, 77% of those with a Flutter counterpart, none (d).

| Removed | Instead | Step |
|---|---|---|
| text `countUp`, `countUpDuration`, `countUpCurve`, `countUpOnShow` | a transition of `props.text` with the timing, and (with `countUpOnShow`, the default) an animation `countUp` with a track on `props.text` from 0 | `text.countUp` |
| slider `rulerTicks`, `rulerMajorEvery`, `rulerTickColor`, `rulerMinorTickColor` | `customPaint.painter` ops: a baseline `line` and a `repeat` of tick `line`s (a `ruler` track's default 20 ticks too) | `slider.paint` |
| slider `markerValue`, `markerColor`, `markerWidth`, `markerHeight` | a `rect` op at the value along `slider.trackRect` | `slider.paint` |
| slider `activeTrackStartOpacity` | an `rrect` op over the active track: the inactive color fading out | `slider.paint` |
| slider `thumbGripColor` | a `rect` op in `foregroundPainter` at `slider.thumbCenter` | `slider.paint` |
| slider `deriveOverlayColorFromThumb` | nothing (no renderer read it) | `slider.paint` |
| text field `highlightStart`, `highlightEnd`, `highlightStyle` | `runs` (new on the text field: styled ranges of the typed text, as a text's; Flutter's `TextEditingController.buildTextSpan`) | `textField.runs` |
| table `selectedRowEdgeColor`, `selectedRowEdgeWidth` | the `cell` template's `selected` state style (a left stroke), `selected` bound to the cell being first in the selected row | `tableView.rowEdge` |
| date/time input `displayFormat` | `format` | `dateTimeInput.format` |

- **A number in a text counts.** `AnimationTrack.lerpValue(a, b, t, text: true)` (and `valueAt(..., text:)`,
  `sequenceAt`): a text that holds a number goes from `a`'s number to its own, written as the end writes it (the
  characters around it, decimals, thousands separators; a value a clock computes a hair under a half rounds as the
  half). `NumberInText` (`parse`, `format`). A transition or track on a text prop such as `props.text` counts.
- **A slider's custom paint** draws between its parts and reads `slider` (`value`, `min`, `max`, `trackRect`,
  `thumbCenter`): `SliderTrackShape.ruler` draws its strip and fill only; the ticks are ops.
- `TextFieldProps.runs`. `specialCaseProps` and `movedSpecialPath` (legacy_paths.dart): what each removed prop is
  now, for validation and `movedPathHint`.
- **Validation: a layout value written as it decodes is not an unknown key.** `"widthFactor": 0` (any
  `widthFactor`/`heightFactor`) was reported as `unknown_layout_key`, with a message listing `widthFactor` among
  the valid keys: `readsKey` took a value that encodes back unchanged for one kept verbatim in an extra map. It now
  probes the key with a value no reader takes.
- **Name conformance** (`tool/name_conformance.dart`): the 21 (d) verdicts go; `textField.runs` (b), the grid
  placement fields (c) and `itemSnapping` (b) are classified. docs/design/10-audit-verdict.md section 6 re-measured;
  docs/design/schema-3-migration-report.md's note after 30.1.0 regenerated over the corpus.

**A site looks like itself: theme mode, declared fonts, local images.** Additions only; documents stay

**Design systems as data; controls that are not Material-shaped.** Additions and default changes; documents stay
`"schema": 3`.

- **`DesignSystem`** (`design_system.json`: `DesignSystemManifest`): DESIGN.md (principles), the tokens (a theme),
  PATTERNS.md and component definitions by reference, plus `fonts`, `examples` and `replaces` (the base controls its
  components stand in for). `DesignSystem.load(read)` reads one from a folder or a publish; `fromJson`/`toJson` is
  one bundle. `themeUnder(site)`, `libraryUnder(site)`, `catalogOver(base)`, `list` (each component's purpose and
  minimal call).
- **`site.json`'s `designSystem`** names one (a folder relative to the manifest, or a publish id): its tokens are
  the site's base theme, its components callable by type.
- **Named theme scales**: `spacing`, `radii`, `sizes`, `shadows` (with `dark` shadows), `durations`, `curves`, read
  as `${theme.<scale>.<name>}`; `ThemeTokens.mergedWith`. `validateTheme` checks them; a binding naming a step the
  theme does not have is `unknown_theme_name`.
- **The prompt**: `runtimeStarter(designSystem:)` adds a section generated from it (principles and patterns in
  brief, tokens by name, each component with parameters, slots, events and a call) and drops the base controls it
  replaces; `docsTopic(designSystem:)` answers `design`, `patterns`, `tokens` and a component's name. A
  design-systems page joins the reference.
- **Colours that follow the theme**: `tabBar` (`indicatorColor`, `labelColor`, `unselectedLabelColor`,
  `dividerColor`), `pagination` (`textColor`, `activeColor`, `activeTextColor`, `borderColor`), the gauges', charts',
  barcode's and signature pad's palettes are now optional, unset meaning the theme's role (documented per prop):
  values and lines `primary`, tracks and grids `outlineVariant`, ticks and axes `outline`, labels
  `onSurfaceVariant`, needles, cursors and tooltips `onSurface`.
- `dropdown.underline` now means the field's border (the theme's outline), never Material's underline.

**Earlier in this release: a site looks like itself: theme mode, declared fonts, local images.** Additions only; documents stay
`"schema": 3`.

- **Theme mode** (Flutter's `ThemeMode`): `ThemeTokens.mode` (`"mode": "system" | "light" | "dark"` in a theme,
  default `system`) is the mode a site starts in, and the **`setThemeMode`** action (`{"type": "setThemeMode",
  "mode": "${= theme.isDark ? 'light' : 'dark'}"}`; `mode` is an expression, `persist` defaults to true) changes it.
  `ThemeMode.isDark(platformDark:)` and `ThemeMode.tryParse`. Validation reports a bad mode, or a `mode` inside
  `dark` or a media patch (`invalid_theme`).
- **Site fonts**: `SiteManifest.fonts`, a list of `FontFamily` (`family`, `fonts`: `FontAsset` with `asset`,
  `weight`, `style`) in the shape of a pubspec's `fonts:` section, the files beside `site.json`.
  `PublishFont.ofFamilies` publishes them one per file with `url` the path relative to the site
  (`PublishFont.isSiteFile`; ids `Family/weight/italic`, `PublishFont.idOf`). `validateSiteFonts` reports a bad shape
  (`invalid_fonts`) and a file that is not `.ttf`, `.otf` or `.woff` (`font_format`; WOFF2 is not read).
- **Site files**: `isRelativeAssetPath`, and `PublishSource.assetPath` (`publish/{slug}/files/{path}`), where a
  published site's fonts and images named by a relative path are served.
- **Reference**: theme mode, declared fonts and local images in the base (`STARTER.md`); theme.md's dark mode and
  fonts sections rewritten; decoration.md's images section (local files, `BoxFit`/`Alignment`) and a new
  illustration section, with three validated examples (a photo card with a gradient scrim, an SVG illustration and
  a `path` mark, a `customPaint` scene); render.md's `--theme` and `font_missing`.

- **Node ids are per document; only canvas ids are site-wide.** `duplicate_id` now reports a canvas id two
  documents of a project share (`navigate` and `openModal` name screens by it, so a link reaches one of them), and
  no longer every node id two pages share: a page's actions and conditions name its own nodes, a component's ids
  are its own. The base says so.
- **Did you mean, by meaning.** `nearest` (the `suggestion` of `unknown_action_key`, `invalid_enum` and the other
  name checks) falls back to the name an author usually means when none is spelled close: `target` → `node`,
  `content`/`value` → `text`, `append`/`push` → `add`, `if`/`predicate` → `condition`, `screen` → `to`. An `if`
  whose `condition` is a formula string is told the predicate to write (`{"left": "${= ...}", "op": "isTrue"}`).
- **Reference: a complete multi-page site** (components, "A complete multi-page site";
  `tool/reference/examples/site/`, validated as one project by the reference test): the manifest first with every
  page listed, a header and a footer shared by reference, route parameters with a default, storage restored on
  load, a list kept per route under a key built from `${route.id}`, and a modal opened from a component. The base
  says to list every page in `site.json` before writing pages that link to them.
- **Reference: the names authors guessed wrong, in short examples where they look**: `scrollTo.node` (layout),
  `downloadFile.fileName` and `text` (media), `copyToClipboard.text` (interaction), the `if` predicate (state),
  `setStorage` ops (`add` appends, `insert` at an `index`) and keys per route (data). New patterns: scroll progress
  (layout), entrances on scroll with `animations[].visibleFraction` versus the `reveal` behavior, which scrolls
  (animation), pinning `now()` with the render command's `--now` (animation), spacing and radius scales (theme:
  there are no such tokens; a project variable map). The render page covers `--drag`, `--navigate` with a query
  string, `--now`, `--compare-map`, what a run keeps, and full-page captures of sticky nodes, modals and navigation.

- **A stroke path's draw-on animation migrates to the general pieces.** `strokePath.drawMs` (with `drawDelayMs`,
  `drawCurve`) was kept as `legacy.strokePath.draw` and no longer drawn; `paint.strokePath` now writes an animation
  `strokePathDraw` whose track draws the line op's `trimEnd` from 0 to its own value (the fill's paint from
  transparent), played when the node appears, and a transition of that `trimEnd` with the same timing; a bound
  progress becomes a binding of `customPaint.<painter>.strokePath.trimEnd`. Frame for frame the old painter's
  drawing (codelessly_sdk's `stroke_draw_on_test.dart`), except a progress that changes while the line is still
  drawing on. A literal `drawKey` is dropped (it never changed). `legacy.strokePath.draw` is no longer written.
- **`BindPaths.declaredDefault(node, path)`**: the declared default at a binding path (`opacity`, `props.*`,
  `layout.*`, `decoration.*`, a custom paint op's field), the node's value there when its JSON omits the field. An
  animation track with no `from` or `to` uses it (codelessly_sdk), so a track can end at an op's default `trimEnd` 1.
- **Name conformance, re-measured** (`tool/name_conformance.dart`; docs/design/10-audit-verdict.md, section 6, and
  docs/design/name-conformance.md): 61% of the 863 declared fields of the Flutter-mirroring node types and shared
  groups are Flutter's name and meaning, 78% of those with a Flutter counterpart; 21 special-case fields are listed
  with a recommendation.
- **A time picker's `use24h` is `alwaysUse24HourFormat`** (Flutter's `MediaQueryData.alwaysUse24HourFormat`, which the
  picker reads). Step `props.renamed` (in `migrate2to3`'s one-way steps) renames the prop, its binding, state and media
  patches and `setValue`/condition paths in a schema-2 document; in a schema-3 document `use24h` is refused
  (`unknown_prop`) naming the new spelling, and `movedPathHint('props.use24h')` gives it. No document in the corpus or
  either repository used it.
- **State patches that targeted `self` or `@<key>` now run.** A state patch names the node it patches by id; generated
  schema-2 documents also wrote `self` and `@<key>` (the node's key), which matched no node, so those hover, press
  and selection styles never applied (1131 patches in 9 corpus documents, all naming the node their states are on).
  `migrate2to3`'s first step, `states.target`, rewrites them to the id they mean and reports a behaviour change. In a
  schema-3 document validation refuses them (`unknown_target_node`) with the id to write as the suggestion.

Forms, grid placement and scroll control, in Flutter's shape (and CSS's where the responsive model follows the web);
documents written for 30.1.0 load unchanged.

- **Forms.** `textField.validator` is Flutter's `TextFormField.validator`: an expression that reads the typed text as
  `value` and gives the error to show (`""` when valid), checked by validation with `value` as a name. The object
  form older documents saved (`{"type": "required"}`, `{"type": "email"}`, never applied) reads as the expression it
  named. `AutovalidateMode` gains Flutter's `onUserInteractionIfError`.
- **`form` behavior** (Flutter's `Form`, with `autovalidateMode`): the fields inside validate together; its nodes
  read `${form.valid}` and `${form.errors}` (`{field, label, message}`, top to bottom). `form` is a runtime scope.
- **`validate` action** (`FormState.validate()`): every field of the form (`node`, else the form around the
  reaction's node) shows its error, the first invalid one takes the focus (`focusFirstError`), `${result}` is
  whether all are valid.
- **`radioGroup` behavior** (Flutter's `RadioGroup`): radios inside take its bindable `groupValue`; choosing one runs
  the group's `changed` reactions.
- **Grid placement.** `layout.columnSpan`, `rowSpan` (CSS `grid-column: span n`) and `columnStart`, `rowStart`
  (`grid-column-start`, 1 the first) are child fields a `gridView` reads; elsewhere `layout_field_ignored`.
- **Scroll control.** `itemSnapping` on scrolling rows, columns, lists and grids (`PageView.pageSnapping` for items;
  CSS `scroll-snap-align: start`); the `scroll` and `scrollEnd` triggers document `${result.index}` (the item at the
  start of the view) and `${result.count}`.
- **Validation.** `state_no_effect`: a bound `selected` with no `states.selected` patch changes nothing (a chip's
  selection is `props.selected`).
- **Reference.** Worked, validated examples: a complete contact form (per-field errors on blur and send, a summary,
  a radio group, a success state), an editorial page at 390/834/1440 (one column, a split with a sticky rail, a
  three-column river with a spanning lead), a timetable that is a list on a phone, and a carousel with arrows, dots,
  progress and snapping. The base says to use the width at tablet and desktop. Where node-given names are read
  (`pageOffset` is a page view's, not a page's scroll), and how runs that cut an expression count, are stated.

### Earlier in 30.1.0

**One spelling for each concept; the schema stays 3.** Documents are still `"schema": 3` (`kSchemaVersion`), and
schema-2 documents still load, migrated in memory by `migrate2to3`, whose last steps now give each concept that
30.0.0 could say two ways one spelling, under Flutter's name. **30.0.0's schema-3 documents keep loading** as
schema 3; but a schema-3 document is read as it is, not upgraded, so one written with the earlier spellings below
must be updated once (the migration does it to schema-2 documents; validation reports each earlier spelling in a
schema-3 document as an error naming the one to write). docs/guide/12-migrating-to-schema-3.md ("30.1.0") is the
authors' guide; docs/design/schema-3-migration-report.md the migration over the corpus (106 documents, 0 failures,
3502 rewrites of which 1020 by the new steps; 5 behaviour changes by the new steps, all a box path's, in two m05
experiments).

| 30.0.0 (schema 3) | 30.1.0 (schema 3) |
|---|---|
| a node's `"scale": s` | `"motion": {"scale": s × the motion's own}` |
| `"layout": {"rotation": r}` | `"motion": {"rotate": r + the motion's own}` (an uneven margin's pivot offset as `motion.translateX/Y`) |
| `flightKey`, `flight` | `"hero": {"tag": ..., "flies": "inPlace", "flight": {...}}` |
| `"hero": {"flight": "<look>"}` | `"hero": {"flightShuttle": "<look>"}` |
| `"strokePath": {...}` | a `customPaint` `path` op (`points` or `commands`, `trimEnd` for the progress) |
| a box with `props.path`, `strokeJoin`, `strokeMiterLimit` | a `path` node, the path as `props.data` |
| a path's `subpathColors` | one `customPaint` `path` op per color |
| a paint's `gradientPerSubpath` | one `customPaint` `path` op per shape, the gradient as its paint's `shader` |
| binding, transition, track, `setValue` and condition paths `scale`, `layout.rotation`, `flightKey`, `flight.*`, `hero.flight` (a look), `strokePath.*`, `props.path`, `props.subpathColors` | `motion.scale`, `motion.rotate`, `hero.tag`, `hero.flight.*`, `hero.flightShuttle`, the custom paint op's fields, `props.data` |

- **Docs: controls take the theme, never Material's defaults.** The reference's base and its theme page say what
  controls take from the theme's roles (`primary` fills filled buttons and draws checks, thumbs and text-button
  labels where it reads on `surface`; `fontFamily` every control label; `buttonRadius` every button and chip), that
  without a theme they are neutral (ink on paper and the greys between), and that nothing comes from Material's
  defaults or from the host app's theme. No API change: the roles already cover it (outlines and tints are derived
  from `onSurface` over `surface`, so no `outline` role is added).
- **Breaking, Dart: fields removed.** `Behaviors.scale`, `Layout.rotation`, `BehaviorFields.scale`,
  `LayoutFields.rotation`, `BindPaths.scale`, `BindPaths.rotation`; `Behaviors.flightKey`, `Behaviors.flight`,
  `BehaviorFields.flightKey`, `BehaviorFields.flight` (`HeroTag` gains `flies`, `HeroFlies` and `flight`; its look
  is `flightShuttle`); `StrokePath`, `PathUnit`, `PathCurve`, `StrokePathFields`, `strokePathType`,
  `BehaviorFields.strokePath`, `Behaviors.strokePath`; `BoxProps.path`, `BoxProps.strokeJoin`,
  `BoxProps.strokeMiterLimit`; `PathProps.subpathColors`; `Paint.gradientPerSubpath`,
  `PaintFields.gradientPerSubpath`; the `deprecated_key` diagnostic. The catalog's declared fields go from 2121
  to 2099 for the paint fields alone.
- **Added:** a `customPaint` path op's `commands` (Flutter's `Path` calls `moveTo`, `lineTo`,
  `quadraticBezierTo`, `cubicTo`, `close`, each number a literal or a formula, each call with an optional `when`;
  `PathCommand`, `PathOpFields.commands`); `PathProps.strokeMiterLimit`; `migrateDocument`, `migrateNode` (any
  schema to 3) and `migrateJson`; `MigrationScope.document` (a node step reads the document it is in);
  `movedPathHint` and `olderSchemaPathHint` (what to write for a moved path set at run time).
- **The migration's new steps** (`steps_spellings.dart`, `steps_transform.dart`, `steps_hero.dart`,
  `steps_paint.dart`), after schema 2's: `transform.fold` (scale multiplied into `motion.scale`, rotation added to
  `motion.rotate`, the pivot kept, bindings, transitions, tracks and keyframes moved), `hero.flight`, `paths.moved`
  (`setValue` and condition paths), the paint steps (`paint.patches`, `paint.strokePath`, `paint.boxPath`,
  `paint.perShape`; what has no exact form is kept as `legacy.<name>` and reported, e.g. the draw-on animation as
  `legacy.strokePath.draw`), then `patches.moved` (state and media patches). Rendered before and after, every
  affected corpus node draws the same pixels except a box path's filled edge (at most 4/255) and a box path
  reaching outside its box, now filled there too (reported).
- **Validation:** an earlier spelling in a schema-3 document is an error naming the one spelling
  (`unknown_node_key`, `unknown_layout_key`, `unknown_prop`, `unknown_field`, `unknown_bind_path` for a binding,
  transition, track, `setValue` or condition path, `wrong_type` for a look written as `hero.flight`). A custom
  paint's ops may read `size`, and its `viewBox` may be `[width, height]` (as the decoder reads and writes it). A
  `legacy.<name>` is `legacy_value` (a warning), held in `Node.extra`, never drawn.
- The plot chart's Cartesian props stay: they are the chart's general features (docs/design/01-paint-node.md,
  "30.1.0").
- **Reference:** regenerated; one spelling for each concept throughout.


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
