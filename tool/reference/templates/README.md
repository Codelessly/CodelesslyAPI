# docs/reference

The API reference for authors who write Codelessly documents directly, people and AI agents alike. It is
generated: do not edit these files.

**One base, plus links.** `STARTER.md` is the base: everything most screens need, written to be read in full and
given up front. Each feature area has a page of its own, and every page has the same sections: *When to use*,
*Minimal example*, *Reference* (generated tables), *Patterns*, *Pitfalls*, *See also*. `index.md` maps needs ("a
capped-width band", "style a text field's border") and every declared name (an A–Z) to the section that answers.

The same base and pages serve a model at run time: `RUNTIME_STARTER.md` is the base's runtime form (the system
prompt `runtimeStarter()` builds; it differs from `STARTER.md` only by its envelope: the op rules and two op
examples instead of the render command and site files), and the `ui_docs` tool answers with these pages' sections
(`docsTopic`). A link `forms.md#forms-validation` in the files is `ui_docs "forms-validation"` at run time.

{{fileTable}}

The old per-kind pages (`nodes.md`, `behaviors.md`, `triggers.md`, `actions.md`, `bindings.md`, `formulas.md`,
`variables-conditions-scripts.md`) are stubs that say where each item went, so old links keep working. Old guide
links (`index.md#guide-...`) land on a table in `index.md` that says where each section went.

## How it is generated

`dart run tool/reference/generate.dart` (from the package root; `--check` exits 1 when a file is stale) reads:

- the declarations (`WidgetSpec`s, `PropDef`s, action and trigger specs, enums, doc comments), walked into
  `catalog.json` (`tool/reference/src/catalog.dart`);
- which page documents what: `tool/reference/src/areas.dart` (every node type, behavior, trigger, action, model,
  enum, value type and formula function is on exactly one page; the generator fails otherwise);
- the prose: `tool/reference/templates` (`base.md`, `index.md`, `pages/<page>.md`, this file);
- the examples: `tool/reference/examples` (every one is validated by `test/reference_test.dart`).

It also writes `lib/src/core/edit/guide_topics.g.dart`, the base's segments and the pages' sections the package
serves at run time. `test/reference_test.dart` fails when anything here is stale, a link or anchor does not
resolve, an item is on no page or two, a page lacks one of the six sections, or an example does not validate.

## Adding a page

1. Add a `PageDef` to `featurePages` in `tool/reference/src/areas.dart` and move the items it documents to it.
2. Write `tool/reference/templates/pages/<id>.md` with the six `##` sections in order; put `\{{reference}}` under
   *Reference* and a small, complete example under *Minimal example* (`\{{example:<file>}}`, the JSON in
   `tool/reference/examples`; `\{{example-as-written:<file>}}` keeps the file's own one-node-per-line layout, for an
   example a ui_docs section must hold in 4,200 characters). Link to any section of any page with `[text](@anchor)`.
3. Add the needs it answers to the task table in `templates/index.md`, then regenerate.
