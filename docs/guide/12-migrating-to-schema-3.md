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
behaviour that changes. `migrationReportMarkdown(report)` renders it. The report of the migration over the
reference apps and the experiments is `docs/design/schema-3-migration-report.md`.

## What is rewritten (same behaviour)

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
document renders the same; a schema-3 document written new gets Flutter's behaviour.

| Schema 2 | Schema 3 | Migration | Step |
|---|---|---|---|
| a text's `layout.padding` was ignored (the lines sat at the node's edge; a hugging text did not grow) | applied around the lines, as `Padding(child: Text)`, and counted in a hugging size | dropped from text nodes, their `layout.padding` bindings, the state patches that target a text and a text's media patches (it did nothing) | `text.padding` |

## What is dropped (behaviour changes)

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
