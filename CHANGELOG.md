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

**Sections and components by reference (docs/design/06, phase 1)**

- A component is a document: one non-canvas root plus a `widget` declaration (the catalog's widget JSON with
  `events`). `ComponentDocument` (`LayoutDocument.widget`, `componentType`, `componentRoot`, `previews`,
  `componentVariables`), `ComponentPreview`, `ComponentLibrary` (definitions by type, their `catalog`, the call
  graph, `cycles`, `closureOf`), `componentCycles`, `isComponentTypeName`, `seamCall` (the call's size and
  placement over the root's inside), `callLayoutKeys`.
- A call is a node whose `type` is a component's: decode a page with `standardCatalog + library.catalog` and its
  props are typed; without it they stay raw and round-trip.
- `WidgetSpec.events` and `EventSpec`; `PropDef.required` (`"required": true`); `PropType.variable` (JSON
  `{"kind": "variable", "of": ...}`, kind `string`: no new `PropKind`). The catalog JSON reads and writes all
  three.
- New node type `slot` (`SlotProps`, prop `name`). New trigger type `event` with `Trigger.event`. New core action
  `componentEvent` (`ComponentEventAction`, `ComponentEventFields`); the managed library's
  `kComponentEventAction`, `componentEventAction` and `componentEventOf` now use it (an unknown-typed one still
  reads).
- `SiteManifest` (`site.json`: pages, components, project variables, breakpoints) and `Site`.
- `validateProject(..., manifest:)` checks component libraries and calls: new codes `unknown_component`,
  `duplicate_component`, `component_cycle`, `component_id_mismatch`, `invalid_component`, `missing_prop`,
  `unknown_event`, `call_field_not_allowed`, `slot_outside_component`, `root_placement_bound`; definitions read
  `props` and their own variables only; project variables colliding with a document's are `duplicate_variable`;
  `duplicate_id` no longer spans a component and another document. `ValidateOptions.components`.
- Copy instances (`ComponentLink`, `ComponentDefinition`) are unchanged.
- Fix: a number declared as data (`JsonPropCodec`) below its `min` no longer throws.
- Guide §19 "Sections and components", a STARTER section, and a validated example site
  (`tool/reference/examples/sections`).

**Authoring fixes from the first direct-authoring experiment (cycle 1)**

- New node type `flex` (Flutter `Flex`, the widget `Row` and `Column` extend): the row/column props plus
  `direction` (`horizontal` | `vertical`, Flutter `Axis`, default `horizontal`). Bindable and patchable per
  breakpoint, so a row becomes a column without copying its children. `FlexProps.flex`, `FlexProps.direction`,
  `FlexProps.types`, `flexAxisOf(node)`. `row` and `column` are unchanged.
- New node key `media`: the node's own fields by screen size, as CSS media queries:
  `[{"maxWidth": 599, "patch": {"props": {"direction": "vertical"}}}]`. A rule's conditions are `minWidth` /
  `maxWidth` (px, inclusive, or a breakpoint name: from its min width / up to the next breakpoint) and
  `orientation`; all must hold. The patch is a JSON merge patch over the node (`props`, `layout`, `decoration`,
  `visible`, `opacity`); rules apply in order, the later winning (the CSS cascade). `MediaRule`,
  `MediaOrientation`, `Node.media`, `Node.atScreen`, `mediaPatchAt`. Validation type-checks every patched value as
  the node's own (`invalid_enum`, `unknown_prop`... with paths into the patch) and adds `invalid_media` (shape, no
  condition, bad width, min above max, a key that cannot vary) and `media_overridden` (a patched field the node
  also binds); `unknown_breakpoint` also covers a rule's breakpoint name.
- New layout fields from the CSS flex-item model, read by a row, column or flex: `order` (CSS `order`: layout and
  paint order, ascending, equal orders as listed) and `basis` (CSS `flex-basis`, in a wrapping row/column/flex:
  the size a child counts when lines are broken; a child that fills the main axis then grows by its `flex` share
  of its line). A filling child with a `basis` in a wrapping flex no longer gets `fit_not_allowed`; `basis` under
  a flex that does not wrap is reported as `layout_field_ignored`.
- `gridView.minCrossAxisExtent`: CSS grid `repeat(auto-fit, minmax(<min>, 1fr))`, as many equal columns as fit at
  least that wide, never more than there are items.
- Gradients in Flutter's shape, declared and validated: `Paint.begin`/`end` (LinearGradient; read before but
  undeclared, so validation rejected them as `unknown_field`) and `Paint.center` (RadialGradient, new), kept as
  written and encoded back as written (before, begin/end were re-encoded as the `transform` they give). The
  `transform` doc now gives its real layout, `[a, b, tx, c, d, ty]` (it said `[a, b, c, d, tx, ty]`); a transform
  that collapses the box (a·d − b·c = 0) is `out_of_range`. The radial default extent is documented.
- Validation: new warning `layout_clamped` for a negative margin (Flutter has none: it shrinks the box) and a
  negative offset in a stack that hugs its children (clamped to 0); `layout_field_ignored` for padding on a
  `text` (a text has no padding, as the editor draws it). A `spacer` with no main-axis size is Flutter's
  `Spacer()` (the SDK now lays it out so) and is valid.
- `BoxProps.path` documents its coordinate space (the box's own pixels, not scaled or clipped).
- An icon is written the same way everywhere: `InputIcon.icon` (a text field's `prefixIcon`, `suffixIcon`, `icon`)
  reads a Material icon name string as the `icon` node's `props.icon` does (before, the string was a `wrong_type`
  error), and an untyped `{"name": "search"}` decodes as that Material icon (before, it decoded to a glyph nothing
  can draw: a bug fix).
- Validation: `${false}`, `${12}`, `${'a'}` (a literal where `${...}` reads a name) is reported as `unknown_name`
  with the suggestion `${= false}`; a wrapping `listView` no longer gets `fit_not_allowed` for its items'
  own sizes (it lays them out at their own sizes); new warning `vertical_wrap` for a wrapping list whose runs go top
  to bottom (the default `scrollDirection`).
- `docs/reference/STARTER.md` is generated (`dart run tool/reference/generate.dart`): the core node types (canvas,
  row, column, flex, stack, box, text, icon, spacer) with their Flutter equivalents, the guide's document, layout,
  decoration, text, responsive design, variables (computed and function variables), checking and pitfalls
  sections, and which reference file covers everything else. Guide parts marked `<!-- guide-only -->` stay out of
  it.
- Guide: section 7 (Responsive design) rewritten the web way: intrinsic layout (basis, auto-fit grids, max-width),
  media rules, `${screen}` bindings as the escape hatch, a canvas per breakpoint last; one verified example page
  with its CSS equivalent.
