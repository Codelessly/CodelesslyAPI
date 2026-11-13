# Migrating to schema 4

[Guide](README.md) · Previous: [Migrating to schema 3](12-migrating-to-schema-3.md)

Schema 4 gives two concepts that schema 3 could say two ways one home each, under Flutter's name:

* **One `Transform`.** A node's `scale` (Flutter's `Transform.scale`) and `layout.rotation` (`Transform.rotate`: it
  was drawn, never laid out) are its `motion`: `motion.scale` and `motion.rotate`.
* **One `Hero`.** `flightKey` and `flight` (fly in from where the node with the same key was) are a `hero` that
  flies in place: `{"hero": {"tag": "...", "flies": "inPlace", "flight": {...}}}`. A hero's flight look (schema 3's
  `hero.flight`) is its `flightShuttle`, Flutter's `flightShuttleBuilder`.

Documents written before it keep working: a schema-3 document (or a schema-2 one, through schema 3) is migrated
**once, in memory, when it is read**, and draws what it drew.

## What you need to do

* **Apps (the SDK):** nothing. Every loader reads schemas 2, 3 and 4 and migrates the older ones in memory; a
  schema newer than the SDK reads is refused, naming the update.
* **New documents:** write `"schema": 4`, and scale and turn a node with `motion`.
* **Your own files:** `dart run tool/migrate.dart <file|dir>... [--write] [--report report.json] [--markdown
  report.md]` takes schema 2 and 3 to 4 (`migrateJson`). Without `--write` it only says what it would change.
* **Dart code:** `LayoutDocument.fromJson` migrates for you (`migrateDocument` does it to JSON). Code that decodes
  a node on its own from older JSON migrates it first: `Node.fromJson(migrateNode(json, from: 3))`.

```dart
final report = MigrationReport(document: 'home.json');
final json = migrate3to4(schema3Json, report: report); // pure; never throws
for (final e in report.behaviourChanges) print('$e\n  instead: ${e.instead}');
```

* **Validation:** a schema-3 document gets the `schema_outdated` note (info) and is validated as migrated. In a
  schema-4 document, `scale`, `layout.rotation`, `flightKey`, `flight` and a string `hero.flight` are reported with
  where they went (`motion.scale`, `motion.rotate`, `hero.tag`, `hero.flight`, `hero.flightShuttle`), and a bind path
  of schema 3 with the path to write.

## What is rewritten (same picture)

| Schema 3 | Schema 4 | Step |
|---|---|---|
| `"scale": s` | `"motion": {"scale": s × the motion's own}` | `transform.fold` |
| `"layout": {"rotation": r}` | `"motion": {"rotate": r + the motion's own}`; with an uneven margin, the pivot's offset (half the margin's difference, which schema 3 turned about) as `motion.translateX/Y` | `transform.fold` |
| `bind` `scale`, `layout.rotation` | `motion.scale`, `motion.rotate` (a formula times / plus the other part when both have one) | `transform.fold` |
| a `scale` / `layout.rotation` transition | a `motion.scale` / `motion.rotate` transition (its own timing, beside the motion's) | `transform.fold` |
| a scale or rotation that changes with no transition, beside a `motion` transition | `{"property": "motion.scale"}` (no duration: it still snaps) | `transform.fold` |
| animation tracks on `scale` / `layout.rotation`; replacing tracks and keyframes on the motion of a scaled or turned node | the motion paths, values moved by the node's own | `transform.fold` |
| a state or media patch's `scale`, `layout.rotation` | `motion.scale`, `motion.rotate`, at the patched node's values, set explicitly | `patches.schema4` |
| `flightKey`, `flight`, bound `flightKey` / `flight.*` | `hero` with `"flies": "inPlace"` and its `flight`; `hero.tag`, `hero.flight.*` | `hero.flight` |
| `hero.flight` (a look), bound `hero.flight` | `hero.flightShuttle` | `hero.flight` |
| a `setValue` or condition path `scale`, `layout.rotation`, `flightKey`, `flight.*` | the schema-4 path (a value moved by the target's own motion) | `paths.schema4` |

A path set while the app runs from outside the document (a script, another document) isn't migrated: the
validator reports it as `unknown_bind_path` with the schema-4 path, and the SDK sets nothing for it and says so
once (`schema3PathHint`).

## What is reported (not the same picture)

The migration folds these all the same and says so in the report:

* a node scale or rotation under a motion turned about another point than its center, a 3D motion turn, a
  shimmer, a flip or a tilt (schema 3 drew the scale and rotation inside those; schema 4 in the motion, outside);
* a rotation or margin set while the app runs (bound, `setValue`, a condition) with an uneven margin: the pivot's
  offset can't be a fixed translation;
* a node scale and a motion scale that both change, timed differently: one key, one timing;
* a `motion` transition's keyframes naming `scale` when the node's scale gets a transition of its own;
* a preset that replaces `motion.scale` or `motion.rotate` with values of its own on a node with its own scale or
  rotation;
* a node with both a hero and a flight key: it keeps its hero; the flight key and flight are kept as
  `legacy.flightKey` / `legacy.flight`.

Over the reference apps and the SDK's documents (docs/design/schema-4-migration-report.md) none of these occurs:
172 rotations, 6 bound rotations, 6 scale transitions, 330 state scales and 10 hero looks are rewritten, and the
documents that use them render pixel for pixel as before (docs/design/03-motion.md, "Done in schema 4").

## The shapes

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
