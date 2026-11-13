# Schema 2 → 3: the migration over the corpus

106 documents migrated; 3502 rewrites, 24 unconvertible values, 29 behaviour changes.

## Entries per step

| Step | Rewrites | Unconvertible | Behaviour changes | Documents |
|---|---|---|---|---|
| `action.animateVariable` | 3 | 0 | 0 | 1 |
| `action.playAnimation` | 42 | 0 | 0 | 4 |
| `drag.split` | 180 | 0 | 0 | 7 |
| `hero.flight` | 10 | 0 | 0 | 4 |
| `motion.legacy` | 1789 | 0 | 0 | 33 |
| `openModal.unread` | 4 | 0 | 0 | 1 |
| `paint.boxPath` | 133 | 0 | 5 | 24 |
| `paint.perShape` | 45 | 0 | 0 | 1 |
| `paint.strokePath` | 140 | 0 | 0 | 7 |
| `patches.moved` | 330 | 0 | 0 | 9 |
| `text.lineHeight` | 380 | 0 | 0 | 106 |
| `text.padding` | 27 | 0 | 0 | 9 |
| `track.legacy` | 30 | 0 | 0 | 5 |
| `track.oneApp` | 0 | 24 | 24 | 5 |
| `transform.fold` | 362 | 0 | 0 | 7 |
| `transitions.legacy` | 6 | 0 | 0 | 2 |
| `trigger.clock` | 21 | 0 | 0 | 9 |

## Unconvertible values (kept as `legacy.<name>`)

- **`track.oneApp`**: `track.fineStep` (deprecated, one app) has no schema-3 form; kept as `legacy.track.fineStep`. Instead: A boolean variable set by keyDown/keyUp (Shift) and a hold reaction, bound into "track.step" and "track.pixelsPerRange".
  - `CodelesslyEditor/references/cutroom/editor/publish-local.json#/result/layouts/cutroom`: ho1st9hlcw-12x/track/fineStep = `0.01`; ho1st9hlcw-12y/track/fineStep = `0.01`; ho1st9hlcw-16l/track/fineStep = `0.01`; ho1st9hlcw-16m/track/fineStep = `0.01`; ho1st9hlcw-1aa/track/fineStep = `0.01`; ho1st9hlcw-1ab/track/fineStep = `0.01`
  - `CodelesslyEditor/references/cutroom/editor/seed.json`: ho1st9hlcw-12x/track/fineStep = `0.01`; ho1st9hlcw-12y/track/fineStep = `0.01`; ho1st9hlcw-16l/track/fineStep = `0.01`; ho1st9hlcw-16m/track/fineStep = `0.01`; ho1st9hlcw-1aa/track/fineStep = `0.01`; ho1st9hlcw-1ab/track/fineStep = `0.01`
- **`track.oneApp`**: `track.smooth` (deprecated, one app) has no schema-3 form; kept as `legacy.track.smooth`. Instead: "detent": 1 with a settle spring is the nearest (approximate).
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_r8kVBcPqHLqHcBXL_raw.json#/result`: 0SgcJ3bjodZMX9N94iq_/track/smooth = `true`; 0SgcJ3bicqGlqYEPjTaD/track/smooth = `true`; 0SgcJ2uWDMSv1dbP5MrE/track/smooth = `true`; 0SgcJ2uWDMSv1dbP5MqV/track/smooth = `true`; 0SgcJ23SBFamvxOoninv/track/smooth = `true`; 0SgcJ23SBFamvxOoninC/track/smooth = `true`
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_rBb4H5uJLh77NDKr_raw.json#/result`: 0SgaqW7XhgQeMSEHHpLb/track/smooth = `true`; 0SgaqVbOWybKkCF5Kz4h/track/smooth = `true`; 0SgaqVIw3MHCAHG9Lso8/track/smooth = `true`
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_rCME4aBQcdyOppRp_raw.json#/result`: 0SgaqYOHd70ap2miX3Y4/track/smooth = `true`; 0SgaqY9xib6qDnNIr5Ah/track/smooth = `true`; 0SgaqXwj3MO0xD2G4jKl/track/smooth = `true`

## Behaviour changes

- **`track.oneApp`**: `track.fineStep` no longer acts: A boolean variable set by keyDown/keyUp (Shift) and a hold reaction, bound into "track.step" and "track.pixelsPerRange". Instead: Used by: cutroom, cutroom_v2, darkroom.
  - `CodelesslyEditor/references/cutroom/editor/publish-local.json#/result/layouts/cutroom`: ho1st9hlcw-12x/track/fineStep = `0.01`; ho1st9hlcw-12y/track/fineStep = `0.01`; ho1st9hlcw-16l/track/fineStep = `0.01`; ho1st9hlcw-16m/track/fineStep = `0.01`; ho1st9hlcw-1aa/track/fineStep = `0.01`; ho1st9hlcw-1ab/track/fineStep = `0.01`
  - `CodelesslyEditor/references/cutroom/editor/seed.json`: ho1st9hlcw-12x/track/fineStep = `0.01`; ho1st9hlcw-12y/track/fineStep = `0.01`; ho1st9hlcw-16l/track/fineStep = `0.01`; ho1st9hlcw-16m/track/fineStep = `0.01`; ho1st9hlcw-1aa/track/fineStep = `0.01`; ho1st9hlcw-1ab/track/fineStep = `0.01`
- **`track.oneApp`**: `track.smooth` no longer acts: "detent": 1 with a settle spring is the nearest (approximate). Instead: Used by: safecracker.
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_r8kVBcPqHLqHcBXL_raw.json#/result`: 0SgcJ3bjodZMX9N94iq_/track/smooth = `true`; 0SgcJ3bicqGlqYEPjTaD/track/smooth = `true`; 0SgcJ2uWDMSv1dbP5MrE/track/smooth = `true`; 0SgcJ2uWDMSv1dbP5MqV/track/smooth = `true`; 0SgcJ23SBFamvxOoninv/track/smooth = `true`; 0SgcJ23SBFamvxOoninC/track/smooth = `true`
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_rBb4H5uJLh77NDKr_raw.json#/result`: 0SgaqW7XhgQeMSEHHpLb/track/smooth = `true`; 0SgaqVbOWybKkCF5Kz4h/track/smooth = `true`; 0SgaqVIw3MHCAHG9Lso8/track/smooth = `true`
  - `CodelesslyEditor/references/safecracker/editor/exports/0Sg_rCME4aBQcdyOppRp_raw.json#/result`: 0SgaqYOHd70ap2miX3Y4/track/smooth = `true`; 0SgaqY9xib6qDnNIr5Ah/track/smooth = `true`; 0SgaqXwj3MO0xD2G4jKl/track/smooth = `true`
- **`paint.boxPath`**: The path reaches outside the box: its fill is drawn there too (the box filled only the part inside its rectangle). Instead: Clip it: put it in a box with "decoration": {"clip": "antiAlias"}, or keep the path inside its box.
  - `experiments/m05/c2/saas-landing-A/site/pricing.json`: logo-mark/props/data; footer-logo-mark/props/data
  - `experiments/m05/c2/saas-landing-A/src/pricing.base.json`: logo-mark/props/data; footer-logo-mark/props/data
- **`paint.boxPath`**: While the bound path is empty the node draws nothing (a box drew its rectangle). Instead: Bind "visible" to whether the path is empty, with a box beside it.
  - `experiments/m05/c3/restaurant-B/site/menu.json`: menuIcon/bind/props.path

## Checks

- 106 documents in 1353 files (106 schema 2) migrated without throwing.
- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for every one.
- New validation errors against the schema-2 validator: 0.
- Encoded size of the schema-2 documents: 15998177 bytes before, 16090474 after (+0.58%).

## 30.1.0's one-way steps

`migrate2to3` ends with the steps that give each concept one spelling (docs/guide/12-migrating-to-schema-3.md,
"30.1.0"): `transform.fold`, `hero.flight`, `paths.moved`, then the paint steps (`paint.patches`,
`paint.strokePath`, `paint.boxPath`, `paint.perShape`), then `patches.moved`. Of the totals above they made 1020
rewrites (`transform.fold` 362, `patches.moved` 330, `hero.flight` 10, `paint.strokePath` 140, `paint.boxPath` 133,
`paint.perShape` 45), nothing unconvertible, and the 5 behaviour changes of `paint.boxPath`, in two m05 experiments
(a logo mark's path reaching past its box, a bound path); the other 2482 rewrites, 24 unconvertible values and 24
behaviour changes are schema 2's steps, as in 30.0.0. Run again on their own output, the one-way steps change
nothing in any document.

- **A document marked `"schema": 3` is read as it is.** One written with 30.0.0's spellings (`scale`,
  `layout.rotation`, `flightKey`, `flight`, a string `hero.flight`, `strokePath`, a box's `path`, `strokeJoin`,
  `strokeMiterLimit`, a path's `subpathColors`, a paint's `gradientPerSubpath`, and the moved binding, transition,
  track, `setValue` and condition paths) is not upgraded on load: validation reports each as an error naming the
  one spelling, and the SDK sets nothing for a moved path set at run time and says so once (`movedPathHint`).
- **`legacy.<name>`.** What a step keeps (the paint steps can keep `legacy.strokePath.draw`, `legacy.strokePath`,
  `legacy.props.subpathColors` and `legacy.decoration.<list>.<i>.gradientPerSubpath`; `hero.flight`
  `legacy.flightKey` and `legacy.flight`; none in this corpus) stays on the node as given: the model holds it in
  `Node.extra` and writes it back unchanged, the renderer never reads it (a kept draw-on animation shows the line
  at its progress at once), and validation reports it as `legacy_value` (a warning) pointing here.
- The corpus is CodelesslyEditor/references, experiments/m05 and the SDK's examples, test/fixtures and benchmark
  (`dart run tool/migration_corpus.dart <dirs> --baseline-errors <schema-2 errors> --strip /home/user/`); 1353
  JSON files this time, 1385 when 30.0.0's report was taken (the same 106 documents).
