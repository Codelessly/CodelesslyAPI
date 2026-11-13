## Unreleased

**Edit operations and streaming (docs/design/08, phases 1 and the API half of 4)**

- Six id-addressed edit ops in the core (`lib/src/core/edit`): `SetOp`, `PatchOp` (RFC 7396 merge patch on one
  node), `MoveOp`, `RemoveOp`, `VarsOp`, `RootsOp`, each declared once (`EditOp.specs`); `decodeOps` reads a
  `ui_apply` tool input leniently, with typed diagnostics carrying the op index.
- `applyOps(document, ops, catalog:, profile:, check:, atomic:, revisions:, baseRev:, author:, incomplete:)` →
  `EditResult` (new document, applied/rejected indices, per-op `EditDiagnostic`s, inverse ops, revision, per-field
  revisions, pending ids, changed and created ids, `toModelJson()`). Each op is checked on its own: structure,
  `TrustProfile`, and an `EditCheck` on what it touched: `catalogCheck` (core) or `strictEditCheck()`
  (`validate.dart`: the strict validator on the touched nodes, their parents and children). New codes
  (`EditCodes`): `invalid_op`, `missing_field`, `unknown_id`, `structural_key_in_patch`, `stale_rev`,
  `would_orphan`, `multiple_parents`, `cycle`, `canvas_as_child`, `invalid_parent`, `dangling_child`,
  `unreachable_node`, `capability_not_allowed`, `limit_exceeded`, `truncated_op`, `invalid_json`,
  `invalid_variable`, `unknown_variable`.
- Forward references: with `incomplete: true` a child listed before its node is pending and a reference to what has
  not arrived is a warning; `endOfStream` reports what never came; `pendingIds`, `inverseOps`, `validateEdited`.
- `OpStreamDecoder` / `decodeOpStream`: ops out of a tool input's text deltas as soon as each is complete (nodes of
  a `set` with `nodes` one by one), independent of the chunking, robust to truncation (`OpStreamEnd`).
- `outline`, `outlineRow`, `readUi` (the `ui_read` tool); `uiTools`, `uiApplyInputSchema`, `uiReadInputSchema`,
  `nodeSchema`, `opSchema` (JSON Schemas generated from the declarations); `opsFromDocument`, `toolInputText`.
- `TrustProfile` (`none`, `agent`, `restrict`, `checkNode`), `NavigationLimit`, `Catalog.select` (extension
  `CatalogSelect`).
- `strictEditCheck` accepts a `componentEvent` in a document that is not a component: the event to its host.
- Reference: guide §20 (ops, rules, streaming, the tools, the trust profile, the codes; its examples are applied by
  a test), `docs/reference/ui_tools.json`; guide chapter 11.
