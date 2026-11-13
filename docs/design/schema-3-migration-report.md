# Schema 2 → 3: the migration over the corpus

106 documents migrated; 2482 rewrites, 24 unconvertible values, 24 behaviour changes.

## Entries per step

| Step | Rewrites | Unconvertible | Behaviour changes | Documents |
|---|---|---|---|---|
| `action.animateVariable` | 3 | 0 | 0 | 1 |
| `action.playAnimation` | 42 | 0 | 0 | 4 |
| `drag.split` | 180 | 0 | 0 | 7 |
| `motion.legacy` | 1789 | 0 | 0 | 33 |
| `openModal.unread` | 4 | 0 | 0 | 1 |
| `text.lineHeight` | 380 | 0 | 0 | 106 |
| `text.padding` | 27 | 0 | 0 | 9 |
| `track.legacy` | 30 | 0 | 0 | 5 |
| `track.oneApp` | 0 | 24 | 24 | 5 |
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

## Checks

- 106 documents in 1353 files (106 schema 2) migrated without throwing.
- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for every one.
- New validation errors against the schema-2 validator: 0.
- Encoded size of the schema-2 documents: 15998177 bytes before, 16021534 after (+0.15%).
