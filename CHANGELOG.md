## Unreleased

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

- Media and state patches merge by the declarations: a union-typed value written in another form replaces the old
  one (`mergeNodePatch`, `unionForm`, `isUnionType`; `Node.patched`, `mediaPatchAt(props:)`,
  `StateStyles.patchFor(props:)`), so `{"width": {"hug": 200}}` over `{"fill": 292}` is a hug size, not an object
  with two modes; sizes, positions (edges / align / relative), icons and the models a `type` discriminates (paints,
  effects, shape and input borders). Validation accepts `null` in a patch (it removes the key) as documented.
  **Behaviour change (bug fix):** a patch that wrote another form of such a value produced an invalid value before.
- `fit_not_allowed` (and `layout.basis` ignored) are judged at each range of screen widths the node's and its
  parent's media rules cut (`mediaWidthRanges`, `mediaRuleSetting`), with the rules that hold there, at the value in
  effect; a finding names the widths it holds at. No more warnings for a child patch checked against the parent's
  unpatched props.
- Grid cells: in a `gridView` with `shrinkWrapRows` a hugging or filling item is honoured along the rows (the
  renderer stretches it to the row); a masonry grid's fill is reported. New warning `prop_ignored`:
  `mainAxisExtent` under `shrinkWrapRows` (which wins, as documented).
- `Paint.length` (a gradient's length in pixels: CSS `repeating-linear-gradient(..., 80px)`), `PaintType.noise`
  with `NoisePaint` / `NoiseType` (SVG `feTurbulence` as a paint), `StrokeSides.none`.
- An input icon's `actions` validate as a list of reactions (both forms tried were rejected as "got an object").
- Docs: `scrollTo.node` takes an expression; `IconProps.icon` documents the name form; the guide's sections
  3, 4, 7, 10, 12, 13, 14, 16 and 17 (see the guide commit).

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
