# 22. Parity: every document is the notation

2026-11-17. The owner's goal: full Codelessly API parity in the notation. Anything a schema-3 document can hold
is written in the notation's words and prints back in them. The `{…}` tail and the `node {…}` line stay as
the escape hatch they were designed as, and the measure of parity is that nothing needs them.

## 1. Where it stands (measured)

`tool/notation_coverage.dart` prints every document of a corpus with `printNotation` and counts what falls
into a `{…}` tail. Over 1,287 documents (the reference's examples, CodelesslySDK's design systems, examples and
test fixtures), at `4b395b93`:

| | |
|---|---|
| Documents printed whole as data (`document {…}`, no tree in words) | 1,087 (84%) |
| Node lines with a `{…}` tail | 90.4% |
| Characters in tails | 92.5% |
| Distinct tail paths | 649 |

Two different gaps make that number:

- **The printer writes 13 words.** The parser reads hundreds. `Text "x" size=18 color=#FF111111` parses, and
  prints back as `Text "x" {"props":{"style":{…}}}`. Most of the 90% is this.
- **The parser has no word** for some of the API: any trigger but eleven, any action but twelve, media rules
  beyond `hide=`/`show=`, behaviors (`pan`, `draggable`'s options, `dropTarget`'s), custom paint, animations,
  typed variables, a component's declaration.

And one defect found while measuring: **a key the parser does not know is put in `props` without a word**
(`squeezable=false` lands in `props.squeezable`, where nothing reads it; `letterSpacing=0.4` on a Text lands in
`props.letterSpacing`, not in its style). With the strict validator gone, nothing says so.

## 2. The rules (the grammar does not change)

The grammar of design 13 section 3 stands: `Type[.variant][#id] ["text"] [key=value ...]`, `key={expression}`,
`on…={actions}`. Parity is reached inside it. Nothing here adds a second way to write what already has one.

### 2.1 A key is the document's own name, found by the catalog

`key=value` on a line of type T means, in this order, the first that has that name:

1. a word of the notation (`gap`, `pad`, `fill`, `w`, `h`, `border`, `radius`, `size`, `weight`, `color`,
   `grow`, the alignment words, a universal word of design 21, a design system component's parameter);
2. a prop of T in the catalog;
3. a field of T's text style, where T shows text (`letterSpacing`, `fontFamily`, `height` on a Text is its line
   height: the catalog's prop wins over a layout field of the same name);
4. a layout field (`x`, `y`, `squeezable`, `flex`, `margin`, `minWidth`, `maxWidth`, `minHeight`, `maxHeight`,
   every other the catalog's layout declares);
5. a decoration field (`shape`, `strokeWidth`, `strokeSides`, `clip`, `effects`, `fills`, `strokes`, …);
6. a field of the node itself (`tooltip`, `opacity`, `visible`, `semantics`, …) and a behavior
   (`draggable`, `dropTarget`, `pan`, `dismissible`, …).

A nested field is the path from there, dotted: `pan.axis=horizontal`, `style.letterSpacing=0.4`,
`constraints.maxWidth=720`, `dropTarget.accepts=["clips"]`. The full path from the node always reads
(`layout.x=10`, `props.style.height=1.2`, `decoration.shape=circle`), and is what the printer writes when a
shorter name would be read as something else.

A value is a number, a bare word (an enum's name, `true`, `false`), a quoted string, or JSON for a list or a
map (`effects=[{"type":"dropShadow","blurRadius":8}]`). `key={expression}` binds that path
(`x={clip.start*px}` is `bind: {"layout.x": "${= clip.start*px}"}`); it already does for the keys the parser
knows, and now does for every key.

**A key that is none of these is said**, on its line, with the nearest name (`suggest.dart`): in the closed
vocabulary an issue, in the open one a recorded word (design 19), never a silent prop.

### 2.2 An event is the trigger's own name

`on<Trigger>={actions}` for every trigger type of the catalog, in the catalog's name with a capital
(`onDragEnd`, `onPanUpdate`, `onScroll`, `onEnterViewport`, `onLongPress`): the eleven the parser has keep their
names (`onTap` is `click`). A trigger's own fields are written in parentheses before the `=`, by name:
`onKey(key=enter, shift=true)={…}`, `onScroll(threshold=120)={…}`. `result` is the trigger's payload, as now.

### 2.3 An action is the action's own name

The verbs the notation has stay (`name=value`, `emit`, `toast`, `open`, `close`, `go`, `scroll`, `link`,
`announce`, `confirm`, `focus`, `copy`, `cond ? a : b`). Every other action type of the catalog is its type
name and its fields by name: `animate node=hero preset=fadeIn durationMs=300`, `setFocus node=email`. A field's
value follows 2.1 (a bare word, a number, a quoted string, braces for an expression, JSON for a list or map).
An action written as JSON still reads; the printer never writes one where this form says it.

### 2.4 What is not a node

- **Variables.** `state name=value` with the type read from the value, as now; a type the value does not say
  is `state name:type=value` … to be settled by the document family (section 4) from what the corpus holds.
- **Media rules.** A line's value at another width, in the notation's words, not a patch in JSON. The media
  family settles the form from the 41 paths the corpus uses (`hide=`/`show=` stay as they are).
- **A list, a condition.** `each x in list` and `if`/`else` already parse; the printer writes them from
  `bind.data` and from `visible` bindings shared by siblings.
- **A component.** A design system's component document (`widget`, `previews`) prints as a `define` (design
  20) where a definition can say it, and otherwise as a `component Name(params)` head with its tree under it.
- **Overlays and more canvases.** `Dialog#id`, `Sheet#id`, `Menu#id` blocks, and one block per canvas.

### 2.5 The printer

`printNotation` stays exact by construction: it writes words, parses them back, and whatever differs goes in
the tail. So a printer word can never corrupt a document; a wrong word only fails to shrink the tail. The
printer writes, for each field of a node that differs from what the parser would give that line with nothing
written: the notation's short word when there is one, else the field's own name (2.1), else its full path. It
writes nothing for a value the parser already gives.

The printer is split by family so the work does not collide:

| File | Holds |
|---|---|
| `print.dart` | The walk: state lines, `each`/`if`/`else`, overlays, canvases, components, ids. |
| `print_fields.dart` | A node's line: type, text, props, style, layout, decoration, node fields, bindings. |
| `print_events.dart` | Events and actions. |
| `print_media.dart` | Media rules. |
| `print_paint.dart` | Custom paint, animations, charts. |

## 3. Done

For the corpus of section 1 and for a generated document that sets every catalog field once:

- no document prints whole as data;
- no node line has a tail, and there is no `document {…}` line, other than for a field the catalog marks as
  opaque data (a script's source, an embedded document);
- every catalog node type, prop, layout field, decoration field, behavior, trigger and action has a test that
  writes it in the notation, expands it, prints it and gets the same line back;
- an unknown key or action is said, in both vocabularies.

## 4. Families

Each family owns its part of the parser and its printer file, measures itself with
`tool/notation_coverage.dart` before and after, and adds its tests to a file of its own under `test/notation/`.

| Family | Parser | Printer |
|---|---|---|
| Keys | 2.1: catalog resolution, dotted paths, binding any key, the unknown-key issue | none |
| Fields | none (reports what the parser cannot read back) | `print_fields.dart` |
| Events and actions | 2.2, 2.3 | `print_events.dart` |
| Media | 2.4 media rules | `print_media.dart` |
| Document | typed variables, component heads, canvases | `print.dart` |
| Paint, motion, charts | words for custom paint ops, animations, chart options | `print_paint.dart` |

### 4.5 The document family: the forms settled

What is not a node's own line (`print.dart`, read back by the parser). Each form is a line of the grammar of
design 13 section 3; none is a second way to write what had one.

- **Variables.** `state name=value` as before. A type the value does not say is written after a colon, in the
  variable's own type names: `state count:decimal=2`, `state accent:color="#FF2563EB"`; with no value,
  `state note:text`. A typed value in braces is a formula variable of the document (`Variable.formula`):
  `state total:decimal={price*qty}`; with parameters, a function: `state clamp(v):decimal={min(1, max(0, v))}`.
  (Without a type, `state x={…}` stays a formula written out where it is read.) `saved` is `persist`. A typed
  formula is kept as written, single quotes too.
- **The screen's canvas.** `canvas "Trip" path="/trip" h=844 fill=paper` above the tree: its name in quotes,
  `w`, `h`, `fill` (a plain fill), any other field by its path from the canvas (`props.blockBack=true`,
  `layout.height.hug=600`; `null` removes). `canvas none`: the document has no canvas, its root is the first line.
- **Other canvases.** `Canvas#about "About" path="about"` at the margin after the page, its tree indented under
  it: an overlay block with no frame of its own, the head taking the canvas line's words. One block per canvas.
- **Lists and conditions.** A list over data the parser makes from `each` (a `listView` whose one child is the
  column `<id>Item`) is printed `each item in list` (with `reorder`, `follow h=…`); an each with an each in it
  names its element with a word its lines do not use, so their `parent.item` stays as written. Sibling lines
  whose bound `visible` is the same `${= expr}` (two or more, or one followed by its negation) are under
  `if expr`, the negation under `else`. A list written by hand (its item not the parser's column) stays a node
  line.
- **Ids.** An id the parser would give the line (`text3`: its type and the count so far) is not written,
  unless the line reads as something else without it (`Sidebar`, a page word, for a component of that name).
  Any other id is written; an id's parts may be joined by `-` (`#m-logo`), which the parser now reads (an id
  from data, `#row-{row.id}`, is still its fixed part).
- **A component.** A design system's component document is its head, then its tree (no canvas; its variables
  are its root's):

  ```
  component StatusPill "A short status, colored by its tone."
    param label="Active" required doc="What it says."
    param tone:neutral|success|danger="neutral"
    param value:ValueNotifier<bool>=false
    event onChanged:String doc="The new label."
    slot trailing
    preview "Default" 120x28 label="Active" tone="success"
  Row#pill gap=4
    Text#pillLabel "Active"
  ```

  A parameter is declared as a variable is (`name[:Type]=default`), its type in Flutter's names (`String`,
  `bool`, `double`, `int`, `List<…>`, `ValueNotifier<…>` for a variable parameter, an enum's values joined by
  `|`), written only where the default does not say it; `required` and `doc="…"` after it. An event's payload is
  its type after a colon. A preview is its name, its size (`340x66`) and the call's values. A `define` (design
  20) is a macro written out where it is used, not a component of the document, so it cannot say one.
- **Reading back.** A line's `{…}` tail is merged again once the text is read (less the values it binds), so
  what later lines add does not undo it, and the printer reads its print back until tails and canvas lines say
  everything. A print is parsed with `notationOptionsFor(document)`, which turns the reflow off: a printed
  document's media rules are its own.
- **The screen's events** (`every`, `key`) are the events family's: the walk calls `printCanvasEvents`.

Not said yet: a node in a slot of a node that is no component (a `listTile`'s title: the parser puts the lines
under a node in its children); a component call whose type the catalog does not have (the parser reads no such
line, and a `node {…}` line refuses an unknown type); the document's own `id` and `schema` where they are not
the parser's.

## 5. What does not change

The prompt teaches the grammar and the core (design 19). Parity is what the parser reads and the printer
writes; it is not a longer prompt. A key the catalog has is read whether or not the prompt names it, and the
reference page of its type is where a writer finds it.
