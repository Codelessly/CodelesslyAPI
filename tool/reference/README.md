# tool/reference

`generate.dart` writes the package's reference from its declarations: the JSON reference (`docs/reference`, see
`templates/README.md`, which becomes `docs/reference/README.md`) and the notation reference
(`docs/reference/notation`). Run it from the package root.

```
dart run tool/reference/generate.dart              # both references
dart run tool/reference/generate.dart --check      # exit 1 if a file of either is stale
dart run tool/reference/generate.dart --notation   # the notation reference only (--check too)
```

## The notation reference

`docs/reference/notation` is the reference of the compact notation, the same document written one node per line:
what a build agent is given in place of the JSON reference. `NOTATION.md` is the core, read in full; it ends with
the list of the other pages. Each page mirrors the JSON reference's page of the same name (`layout.md`,
`forms.md`…); `events.md`, `paint.md`, `responsive.md`, `document.md` and `levels.md` are the notation's own.
`index.md` and `index.json` index it; `_tails.md` lists what the notation still prints as JSON.

Nothing in it is typed by hand but the prose (`src/notation_reference.dart`):

- each word's section comes from the catalog: the word the printer writes for the type, what its quoted strings set
  (a parse of `Word "…"`), and a table of its props with the shortest key `keys.dart` gives each, its type,
  default, doc and level (`lib/src/core/levels.dart`);
- events from the trigger types (`notationEventName`), actions from the action specs, each verb from a parse of its
  sample (`notationVerbSamples`); formulas, media conditions, `animate=` words, looks and universal words from their
  tables in the package; draw ops from `DrawOpSpecs`;
- every example of the JSON reference (`examples/` and the ```json blocks of `templates/`) printed with
  `printNotation`; a fragment is made a document first (a node map under a canvas, keys on a node, an action on a
  button). A print is shown as printed again until it is a fixed point.

The prose is `templates/notation/<page>.md`: `{{fill}}`s for the generated parts (`{{reference}}`, `{{examples}}`,
…), `[text](@anchor)` links. Every ```notation block in a template is parsed (closed vocabulary, no reflow) and
printed back; the generator stops with the file and line of one that does not read back as written. Mark a block
`expands` when it uses words the printer writes otherwise (`Card`, `Page`, `define`): it is checked to read with no
issue, and its print follows it on the page. `width=1280` gives its canvas width.

`_tails.md` is the parity work list: every example line that keeps a `{…}` tail, a `node {…}` or `document {…}`
line, with the paths it holds; prints the parser says something about (their blocks are marked `unchecked`); and
prints that print again differently. The reference is complete when it lists nothing.

`test/notation_reference_test.dart` checks the folder is up to date, every block parses with no issue and prints
back, and every link resolves. The generator and the test read files with `\r\n` as `\n`, so they run on a Windows
checkout; `--notation` writes each file in the line endings it already has.
