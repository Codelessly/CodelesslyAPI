# Migrating to schema 3

Schema 3 is the format break that finishes the API cleanup: the model's classes and decoders know only the
current shape. Documents written before it (schema 2) keep working: they are migrated **once, in memory, when
they are read**, by a pure-JSON function. Nothing an app loads has to change, and nothing a loader reads is
written back.

## What you need to do

* **Apps (the SDK):** nothing. Published apps hold schema 2; every loader (Firestore, HTTP, an asset bundle,
  memory) reads 2 and 3, migrating 2 in memory. A schema newer than the SDK reads is refused, naming the update.
* **New documents:** write `"schema": 3`. A document without `"schema"` is read as schema 2 and migrated.
* **Your own schema-2 files:** migrate them once with the command, and read its report:

```sh
dart run tool/migrate.dart <file|dir>... [--write] [--report report.json] [--markdown report.md]
```

Without `--write` it only says what it would change. It finds every document in a file (a layout, a publish
model or bundle, a component definition, a site manifest, a plugin package, a file holding several). A stored
payload (text with a digest) is left as it is and migrated when it is read.

* **Dart code** that reads documents: `LayoutDocument.fromJson` migrates for you. Code that decodes a node, a
  behavior or an action on its own (`Node.fromJson`, `Behaviors.fromJson`, `ActionDef.fromJson`) from schema-2
  JSON migrates it first: `Node.fromJson(migrateNode2to3(json))`.

```dart
final report = MigrationReport(document: 'home.json');
final json = migrate2to3(schema2Json, report: report); // pure: the input is not changed; never throws
for (final e in report.unconvertible) print('$e\n  instead: ${e.instead}');
```

* **Validation:** `validateDocument` reads 2 and 3. A schema-2 document gets a `schema_outdated` note (info, not
  a warning) and the other diagnostics are of the migrated document. A value the migration had to keep (see
  below) is a `legacy_value` warning.

## The report

`MigrationReport` lists, per document, every rewrite (step id, node, JSON pointer, old → new), every value that
could not be converted (kept on the node as `legacy.<name>`, unread, with what to write instead) and every
behavior that changes. `migrationReportMarkdown(report)` renders it. The report of the migration over the
reference apps and the experiments is `docs/design/schema-3-migration-report.md`.

## What is rewritten (same behavior)

| Schema 2 | Schema 3 | Step |
|---|---|---|
| `loops[i]`, `effectAnimations[i]`, `motion.pulseKey` | `animations` presets (`loop<i>`, the effect's name, `pulse`) | `motion.legacy` |
| `motion` timing (`duration`, `delay`, `curve`, `spring*`, `rotateCurve`, `fadeShare`) | `transitions` | `motion.legacy` |
| `motion` entrance, loop, spin, keyframes, shimmer, `revealOnScroll` | `animations` presets `enter`, `loop`, `spin`, `shimmer`, and `shimmer` | `motion.legacy` |
| `motion.opacity`, `motion.blur` | the node's `opacity` (multiplied in), a `motionBlur` layer blur | `motion.legacy` |
| `motion.originX/Y`, the flat path keys (`pathProgress`, `orientToPath`...) | `motion.alignment`, `motion.path` | `motion.legacy` |
| a bound `motion.originX/Y` | one binding of `motion.alignment` (`${= [x, y]}`) | `motion.legacy` |
| `loops[i].*`, `effectAnimations[i].*`, `motion.*` binding paths | the paths of what they became | `motion.legacy` |
| a pose's `originX/Y` and flat path keys (`pageMotion`, a route transition side's `motion`) | `alignment`, `path` | `pose.legacy` |
| `drag` | `track`, `dismissible` (its old defaults written out), `pan` or `reorderHandle`; `drag.*` paths | `drag.split` |
| a track's `endAngle`, `endless`, `jumpOnTap`, `wheel`, `keyboard`, `momentum`/`friction`, `gain` (a pixel rate), the path string with `viewBoxWidth/Height` and `orientToPath/Upright`, `write: false`, `settleStiffness/Damping` | `sweepAngle`, `clamp`, `allowedInteraction`, `wheelStep`, `keyStep`, `physics`, `pixelsPerRange`, `path`, a bound `track.value`, `settleSpring` | `track.legacy` |
| `zoomable: true` | `transformGesture: {target: content, pan: whenZoomed}` | `zoomable` |
| a draggable's `whileDragging`, `feedbackNodeId`, `feedbackAnchor`/`dragAnchorStrategy`, `spring`, `springStiffness/Damping`, `physics`, `returnSpring: true` | `childWhenDragging`, `feedback`, `dragAnchor`, `returnSpring` | `draggable.legacy` |
| a `physics` object's flat `stiffness`, `damping`, `mass`, `bounce`, `duration` | `physics.spring` | `physics.flatSpring` |
| `transitions` as `{style, opacity, size}` or a property map | the list | `transitions.legacy` |
| a paint's `gradientUnits: "subpath"` | `gradientPerSubpath: true` | `paint.gradientUnits` |
| `playAnimation` | `animate` (forward from 0) | `action.playAnimation` |
| `animateVariable` | `animate {variable}` | `action.animateVariable` |
| `setVariable` with `animateMs` (a set, add or subtract by one formula) | `animate {variable, command: animateTo}` | `action.setVariable.animateMs` |
| `controlDrag` | `controlTrack`, `controlDismissible`, `controlTransform` | `action.controlDrag` |
| the `clock` trigger (`every`, `runWhen`) | `timer` (`intervalMs`, `when`) | `trigger.clock` |
| a state or media patch holding any of these | the schema-3 patch that gives the same node | `patches.legacy` |
| `openModal.showCloseButton`, `fullHeight` (never read) | dropped | `openModal.unread` |

### Flutter's reading where schema 2 had its own

Schema 3 reads these fields as Flutter does. The migration writes out (or drops) what schema 2 did, so a migrated
document renders the same; a schema-3 document written new gets Flutter's behavior.

| Schema 2 | Schema 3 | Migration | Step |
|---|---|---|---|
| a text style with no `height` was drawn at 1.33 (Material's `bodySmall`), unless it said `naturalHeight: true` (or the project's theme `naturalLineHeight`) | the inherited `defaultTextStyle`'s height (Flutter's `DefaultTextStyle`), else the font's own line height (Flutter's `height: null`, CSS `line-height: normal`); `naturalHeight` and `naturalLineHeight` are gone | `"defaultTextStyle": {"height": 1.33}` on each top-level node of the document (one place per tree, not per style: 380 over 106 corpus documents, +0.08% bytes); a node with a `naturalHeight` style gets `"defaultTextStyle": {}` and 1.33 written on its other styles. Reported: a natural run beside 1.33 runs, a theme style a natural node names, a patch or binding switching it, a theme's `naturalLineHeight` or style's `naturalHeight` (a project's theme is not in its documents: remove `defaultTextStyle` from the top-level nodes of its migrated documents) | `text.lineHeight` |
| a text's `layout.padding` was ignored (the lines sat at the node's edge; a hugging text did not grow) | applied around the lines, as `Padding(child: Text)`, and counted in a hugging size | dropped from text nodes, their `layout.padding` bindings, the state patches that target a text and a text's media patches (it did nothing) | `text.padding` |

### Paths an action names

A `setValue`'s `values[].path` is not migrated: it is read against the node it targets when it runs, which may be
in another document, a component or a list item. A schema-2 path there (`motion.originX`, `loops[0].duration`,
`drag.track.min`, `props.style.naturalHeight`...) is refused where it is used: the validator reports it as
`unknown_bind_path` with the schema-3 path to write, and at run time the SDK sets nothing for it and says so once
(`Codelessly: setValue on <node>: "<path>" is a schema-2 path, which schema 3 does not read (nothing set); write
...`); the other values of the action still apply. `schema2PathHint(path)` gives the schema-3 spelling. None of
the corpus's documents names one.

## What is dropped (behavior changes)

These one-app fields had no generic schema-3 form (docs/design/02–04 say why, field by field). A value that did
something is kept on the node as `legacy.<behavior>.<field>`, unread, and reported with what to write instead:

| Field | Write instead | Used by |
|---|---|---|
| `track.defaultValue`, `doubleTapValues` | the variable's own default; a `doubleTap` reaction with `controlTrack animateTo` | lamplight |
| `track.parkedProgress` | bind `track.value` | apiary |
| `track.fineStep`, `finePixelsPerRange`, `fineHold`, `fineVariable` | a boolean variable set by key and hold reactions, bound into `track.step` and `track.pixelsPerRange` | cutroom, cutroom_v2, darkroom |
| `track.smooth` | `detent: 1` with a settle spring (approximate) | safecracker |
| `track.gain` round an arc followed by angle | change `sweepAngle` | safecracker |
| `dismissible`/`pan` `rotateFactor`, `originX/Y`, `shakeWhenDisabled`, `disabledFollow`, `shareAs`, `follow` | bind `motion.rotate` to the drag; a `dragEnd` reaction; `xVariable`/`yVariable`; the plain `drag` trigger | flashcards, gesture_lab |
| `dismissible.restX/Y`, `xVariable/yVariable`, `flyOutRotate` | `motion.translateX/Y`; a `drag` reaction; an animation the `dismissed` reaction plays | flashcards |
| a path's `pacing: area`, `focus` | bind `path.progress` to a formula of time | orrery |
| `orient: uprightFlip` (`uprightMirror`) | `upright`, and bind `motion.scaleX` to −1 while it heads left | lineworks_v2 |
| a transition's `arc` | different curves on `motion.translateX` and `motion.translateY`, or a `motion.path` | lineup |
| `dropTarget.fullIf` and the `dropFull` trigger | fold it into `acceptIf`; react to `dropRejected` | lamplight, seedbox |
| `dropTarget.slotWhenRefused` | none: the slot opens for accepted drags only | mixtape |
| `dropTarget.hoverDelay` and the `dragHover` trigger | `dragEnter` (with a timer for a delay) | none |
| a snap's `projectVelocity: false` | none: a snap projects the fling | none |
| `transformGesture.rotationSnap` | round the bound `rotationVariable` | none |
| a `setVariable` glide that is not one formula | `animate {variable, command: animateTo}` | (one raw export) |

### State patches that targeted no node

A state patch names the node it patches by id (`"states": {"pressed": {"<node id>": {...}}}`), in every schema.
Generated schema-2 documents also wrote `self` and `@<key>` there (the node's `key`, which an inserted tree's
values were resolved from but its map keys were not), so those patches matched no node and never ran: in the
corpus, 1131 patches in 9 documents, every one naming the node its states are on. Step `states.target` rewrites
`self` to the node's id and `@<key>` to the id of the node with that key (the node itself first, else the one node
with it), and reports a behavior change: the hover, press and selection styles now apply. A target that names no
node by any spelling stays and validation reports it. In a schema-3 document `self` and `@<key>` are refused
(`unknown_target_node`) with the id to write.

## 30.1.0: one spelling for each concept

codelessly_api 30.1.0 keeps `"schema": 3` and gives three concepts that 30.0.0 could say two ways one spelling
each, under Flutter's name:

* **One `Transform`.** A node's `scale` (Flutter's `Transform.scale`) and `layout.rotation` (`Transform.rotate`: it
  was drawn, never laid out) are its `motion`: `motion.scale` and `motion.rotate`.
* **One `Hero`.** `flightKey` and `flight` (fly in from where the node with the same key was) are a `hero` that
  flies in place: `{"hero": {"tag": "...", "flies": "inPlace", "flight": {...}}}`. A hero's flight look (30.0.0's
  `hero.flight`, a name) is its `flightShuttle`, Flutter's `flightShuttleBuilder`.
* **One `CustomPaint`, one decorated shape.** A line through points (`strokePath`) and a path's shapes painted one
  by one (`subpathColors`, `gradientPerSubpath`) are `customPaint` path ops; a box drawn as an SVG path (a box's
  `props.path`, `strokeJoin`, `strokeMiterLimit`) is a `path` node.

**Schema-2 documents** reach the one spelling through `migrate2to3`, whose last steps are these (in memory, when
read, as above). **A document marked `"schema": 3` is read as it is**: one written with 30.0.0's spellings must
be updated once. Validation reports each earlier spelling as an error naming the one to write (`unknown_node_key`,
`unknown_layout_key`, `unknown_prop`, `unknown_field`, `unknown_bind_path` for a binding, transition, track,
`setValue` or condition path, `wrong_type` for a look written as `hero.flight`); the SDK sets nothing for a moved
path set at run time and says so once (`movedPathHint`). What was rewritten:

| 30.0.0 | 30.1.0 | Step |
|---|---|---|
| `"scale": s` | `"motion": {"scale": s × the motion's own}` | `transform.fold` |
| `"layout": {"rotation": r}` | `"motion": {"rotate": r + the motion's own}`; with an uneven margin, the pivot's offset (half the margin's difference, which 30.0.0 turned about) as `motion.translateX/Y` | `transform.fold` |
| `bind` `scale`, `layout.rotation` | `motion.scale`, `motion.rotate` (a formula times / plus the other part when both have one) | `transform.fold` |
| a `scale` / `layout.rotation` transition | a `motion.scale` / `motion.rotate` transition (its own timing, beside the motion's) | `transform.fold` |
| a scale or rotation that changes with no transition, beside a `motion` transition | `{"property": "motion.scale"}` (no duration: it still snaps) | `transform.fold` |
| animation tracks on `scale` / `layout.rotation`; replacing tracks and keyframes on the motion of a scaled or turned node | the motion paths, values moved by the node's own | `transform.fold` |
| a state or media patch's `scale`, `layout.rotation` | `motion.scale`, `motion.rotate`, at the patched node's values, set explicitly | `patches.moved` |
| `flightKey`, `flight`, bound `flightKey` / `flight.*` | `hero` with `"flies": "inPlace"` and its `flight`; `hero.tag`, `hero.flight.*` | `hero.flight` |
| `hero.flight` (a look), bound `hero.flight` | `hero.flightShuttle` | `hero.flight` |
| a `setValue` or condition path `scale`, `layout.rotation`, `flightKey`, `flight.*` | the moved path (a value moved by the target's own motion) | `paths.moved` |
| `"strokePath": {...}` | a `customPaint` path op with id `strokePath`, first in `painter` (last in `foregroundPainter` for `inFront`): `points` (a share of the box as `"${= 0.25 * size.width}"`), curves and `untilWidth` as `commands`, `progress` as `trimEnd`, `fillColor` a closed op under it; bound `points`, `progress`, `color` move into the op | `paint.strokePath` |
| a box with `props.path` (and `strokeJoin`, `strokeMiterLimit`) | a `path` node, the path as `props.data`; a box without a path drops the two props it never read | `paint.boxPath` |
| a path's `subpathColors`; `gradientPerSubpath` on its fills or strokes | one `customPaint` path op per color (the shapes of that color as its `d`), or per shape with the gradient as its `shader`; the path's view box is the custom paint's | `paint.perShape` |
| a state or media patch setting any of these | the patch of the migrated node | `paint.patches` |

The migration rewrites these all the same and says so in the report:

* a node scale or rotation under a motion turned about another point than its center, a 3D motion turn, a
  shimmer, a flip or a tilt (30.0.0 drew the scale and rotation inside those; 30.1.0 in the motion, outside);
* a rotation or margin set while the app runs (bound, `setValue`, a condition) with an uneven margin: the pivot's
  offset can't be a fixed translation;
* a node scale and a motion scale that both change, timed differently: one key, one timing;
* a `motion` transition's keyframes naming `scale` when the node's scale gets a transition of its own;
* a preset that replaces `motion.scale` or `motion.rotate` with values of its own on a node with its own scale or
  rotation;
* a node with both a hero and a flight key: it keeps its hero; the flight key and flight are kept as
  `legacy.flightKey` / `legacy.flight`;
* a stroke path's draw-on animation (`drawMs`) is an animation of the op's `trimEnd` from 0 and a transition of
  it (docs/design/01-paint-node.md, "30.1.0"); the one difference: a progress that changes while the line is still
  drawing on carries on toward the new value instead of restarting from where it is; a stroke path with no exact op (a
  binding of another field, bound points in fractions or with curves, a fill fading with a bound progress, beside
  a custom paint's view box) is kept whole as `legacy.strokePath`;
* a box path whose fill reaches past its box (now filled there), is clipped to rounded corners, has a gradient
  stroke, foreground fills, inner shadows, blending fills, more than one dash and gap, or a bound path;
* per-shape colors or gradients beside visible effects, a blending, image or noise fill, or a gradient laid out
  across the box: kept as `legacy.props.subpathColors` / `legacy.decoration.<list>.<i>.gradientPerSubpath`.

Over the reference apps and the SDK's documents (docs/design/schema-3-migration-report.md, "30.1.0's one-way steps") only a box path's
behavior changes occur, 5 of them in two m05 experiments: 172 rotations, 6 bound rotations, 6 scale transitions,
330 state scales, 10 hero looks, 140 stroke path rewrites, 133 box path ones and 45 per-shape color ones are
rewritten, and the documents that use them render as before (pixel for pixel, but a box path's filled edge within
4/255: docs/design/03-motion.md, "Done in 30.1.0"; docs/design/01-paint-node.md, "30.1.0").

### The shapes

```json
{"motion": {"scale": 1.2, "rotate": -8, "alignment": [0, 0]},
 "transitions": [{"property": "motion", "duration": 240}, {"property": "motion.scale", "duration": 120}]}

{"hero": "avatar-1"}
{"hero": {"tag": "card-1", "flightShuttle": "containerTransform", "placeholder": "source"}}
{"hero": {"tag": "react", "flies": "inPlace", "flight": {"duration": 720, "curve": "easeInOutCubic", "lift": 110}}}
```

`flies: betweenScreens` (the default) is Flutter's `Hero`: it flies while a navigation plays, between the two
screens' nodes with the tag. `flies: inPlace` flies the node in when it appears, from where the node with its tag
was a moment ago (hidden, removed, a dropped drag copy, on a closing screen), on a spring without a `flight`.
Heroes of the two kinds don't fly to each other.

## After 30.1.0: the last special cases

The 21 fields that were one look or one rule each are said with mechanisms the model already has, by steps at the
end of `migrate2to3` (`steps_special.dart`). As in 30.1.0, a document marked `"schema": 3` that writes one is not
rewritten on load: validation reports it as `unknown_prop` naming the form to write, and a `setValue` path into one
is rewritten where it has a place (`props.displayFormat` → `props.format`, `props.highlightStart`/`End` →
`props.runs[0].start`/`end`) and otherwise reported.

| Removed | Written instead | Step |
|---|---|---|
| text `countUp`, `countUpDuration`, `countUpCurve`, `countUpOnShow` | `"transitions": [{"property": "props.text", "duration": d, "curve": c}]` and, with `countUpOnShow` (the default), `"animations": [{"id": "countUp", "duration": d, "curve": c, "tracks": [{"path": "props.text", "from": 0}]}]` | `text.countUp` |
| slider `rulerTicks`, `rulerMajorEvery`, `rulerTickColor`, `rulerMinorTickColor` (and a `ruler` track's default ticks) | `customPaint.painter` ops `rulerBaseline` (a `line`) and `rulerTicks` (a `repeat` of `line`s, long ones `when` `index % every == 0`) | `slider.paint` |
| slider `markerValue`, `markerColor`, `markerWidth`, `markerHeight` | a `rect` op `marker` in `painter` at `slider.trackRect.left + slider.trackRect.width * (value − slider.min) / (slider.max − slider.min)` | `slider.paint` |
| slider `activeTrackStartOpacity` | an `rrect` op `activeTrackFade` over the active track: the inactive track's color from 1 − opacity to transparent | `slider.paint` |
| slider `thumbGripColor` | a `rect` op `thumbGrip` in `foregroundPainter` at `slider.thumbCenter` | `slider.paint` |
| slider `deriveOverlayColorFromThumb` | nothing: no renderer read it | `slider.paint` |
| text field `highlightStart`, `highlightEnd`, `highlightStyle` | `"runs": [{"start": s, "end": e, "style": {...}}]` (bound ends: `props.runs` bound to a list formula) | `textField.runs` |
| table `selectedRowEdgeColor`, `selectedRowEdgeWidth` | the `cell` template's `"states": {"selected": {"<cell>": {"decoration": {"strokes": [...], "strokeWidth": w, "strokeSides": "left"}}}}` with `"bind": {"selected": "${= item.rowIndex == (<selected row>) && item.columnIndex == 0}"}` | `tableView.rowEdge` |
| date/time input `displayFormat` | `format` | `dateTimeInput.format` |

A slider draws its own `customPaint` between its parts: `painter` over the track and under the thumb,
`foregroundPainter` over the thumb, both in the slider's own frame, reading `size` and `slider` (`value`, `min`,
`max`, `trackRect`, `thumbCenter`). Reported where the drawing differs: a marker or fade that made the slider draw a
plain rounded track (its track is now its `trackShape`'s), a fade over an inactive track that is not one fixed,
opaque color (not drawn), a table edge on a cell template that does not fill its cell (drawn on the cell's box), a
date/time pattern that was a `formatDate` named style (`full`, `short`...). A `ruler` track in a schema-3 document
no longer draws ticks of its own: add the ops above.
