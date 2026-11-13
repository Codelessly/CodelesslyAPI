# Schema 3 → 4: the migration over the corpus

106 documents migrated; 1020 rewrites, 0 unconvertible values, 5 behaviour changes.

## Entries per step

| Step | Rewrites | Unconvertible | Behaviour changes | Documents |
|---|---|---|---|---|
| `hero.flight` | 10 | 0 | 0 | 4 |
| `paint.boxPath` | 133 | 0 | 5 | 24 |
| `paint.perShape` | 45 | 0 | 0 | 1 |
| `paint.strokePath` | 140 | 0 | 0 | 7 |
| `patches.schema4` | 330 | 0 | 0 | 9 |
| `transform.fold` | 362 | 0 | 0 | 7 |

## Unconvertible values (kept as `legacy.<name>`)

None.

## Behaviour changes

- **`paint.boxPath`**: The path reaches outside the box: its fill is drawn there too (the box filled only the part inside its rectangle). Instead: Clip it: put it in a box with "decoration": {"clip": "antiAlias"}, or keep the path inside its box.
  - `experiments/m05/c2/saas-landing-A/site/pricing.json`: logo-mark/props/data; footer-logo-mark/props/data
  - `experiments/m05/c2/saas-landing-A/src/pricing.base.json`: logo-mark/props/data; footer-logo-mark/props/data
- **`paint.boxPath`**: While the bound path is empty the node draws nothing (a box drew its rectangle). Instead: Bind "visible" to whether the path is empty, with a box beside it.
  - `experiments/m05/c3/restaurant-B/site/menu.json`: menuIcon/bind/props.path

## Checks

- 106 documents in 1353 files (106 schema 3) migrated without throwing.
- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for every one.
- New validation errors against the schema-2 validator: 0.
- Encoded size of the schema-3 documents: 16021534 bytes before, 16090474 after (+0.43%).

## Notes

- The steps are `nodeSteps3to4`: `transform.fold`, `hero.flight`, `paths.schema4`, then `paintSteps4`
  (`paint.patches`, `paint.strokePath`, `paint.boxPath`, `paint.perShape`), then `patches.schema4`. The five
  behaviour changes are `paint.boxPath`'s, in two m05 experiments (a logo mark's path reaching past its box, and
  a bound path); none is in a reference app.
- **`legacy.<name>` in schema 4.** What a step keeps (none in this corpus; the paint steps can keep
  `legacy.strokePath.draw`, `legacy.strokePath`, `legacy.props.subpathColors` and
  `legacy.decoration.<list>.<i>.gradientPerSubpath`, the fold `legacy.flightKey`/`legacy.flight`) stays on the
  node as given: the model holds it in `Node.extra` and writes it back unchanged, the renderer never reads it
  (what it said is not drawn: a kept draw-on animation shows the line at its progress at once), and validation
  reports each such key as `legacy_value` (a warning) pointing here for what to write instead.
- A schema-3 paint key written in a schema-4 document (not migrated) is an error naming its schema-4 form:
  `strokePath` (`unknown_node_key`), a box's `path`, `strokeJoin`, `strokeMiterLimit` and a path's
  `subpathColors` (`unknown_prop`), a paint's `gradientPerSubpath` (`unknown_field`).
- The corpus is CodelesslyEditor/references, experiments/m05 and the SDK's examples, test/fixtures and benchmark
  (`dart run tool/migration_corpus.dart <dirs> --baseline-errors <schema-2 errors> --strip /home/user/`); its JSON
  file count is 1353 here, 1385 when the schema-4 report was first taken (the same 106 documents).
