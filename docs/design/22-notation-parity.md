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

#### Media rules: the form (media family)

A rule is the line's own keys at a width: `condition.key=value`, on the line, one word per field. The key after
the dot is any key the line reads, with its value as the line writes it (`pad`, `gap`, `w`, `h`, `size`,
`hidden`, `visible`, `direction`, a prop's name, a bare alignment word, `key={expression}` for a binding), so a rule
reads "at this width, these keys have these values". The condition is one or more dotted segments:

| Segment | Condition |
|---|---|
| `phone`, `tablet` | `maxWidth` 699, 1023: the named sizes `hide=phone`, `hide=tablet` hide at |
| `desktop` | `minWidth` 1024 (`hide=desktop`) |
| `max899`, `min1100` | `maxWidth`, `minWidth` in px |
| `minTablet`, `maxMobile` | `minWidth`, `maxWidth` naming a breakpoint (`"tablet"`), its id with a capital |
| `portrait`, `landscape` | `orientation` |

Segments combine (`min700.tablet.hidden`: 700 to 1023). The words after one another with the same condition are
one rule; rules are in the order written, `hide=`/`show=` each one of its own in its place. A rule's patch is
what its words change on the line: the line (its words, without its rules and its `{…}` tail) is read alone under
its parent's kind with and without them and the difference kept (a size or a position in another form is written
whole, as a media patch replaces it; a field the words give the value the line already has is kept too, read on
the type alone), so a rule knows every key the line knows, and an unknown key in a rule is said as it is on a
line. The printer chooses a rule's words the same way, the shortest that give exactly its patch. A fixed value for a field the line binds
drops that binding where the rule holds (`"bind": {"layout.width": null}`), as `hide=` does for `visible`.
`hide=`/`show=` stay what they are and are printed for exactly their rule; `min<px>`/`max<px>` are printed only
where a bound is no named size. A rule can hold props, layout, decoration, visible, opacity, motion and
bindings (`MediaRule.patchKeys`); another key in one is said.

From the corpus (CodelesslySDK `examples/showcase/desktop/native`):

```
Flex#grpProfile … tablet.direction=vertical tablet.gap=16 tablet.crossAxisAlignment=stretch
    {"maxWidth":1023,"patch":{"props":{"direction":"vertical","spacing":16,"crossAxisAlignment":"stretch"}}}
Text#title "…" … max900.size=40 max900.letterSpacing=-0.8          (site_blog)
    {"maxWidth":900,"patch":{"props":{"style":{"fontSize":40,"letterSpacing":-0.8}}}}
Column#sidebar … max899.visible={menuOpen}                          (site_docs)
    {"maxWidth":899,"patch":{"bind":{"visible":"${menuOpen}"}}}
```

and from the reference's `responsive_web.json`: `Row#nav … hidden minDesktop.visible=true`.

`printNotation` parses its print with reflow off (`notationOptionsFor`): the print says every rule the document
has, the reflow's included, and the round trip does not depend on what the reflow would add to lines printed as
plain types (a `Section` prints as a `Column`). Read with reflow on, a rule the reflow makes that the line already
says is not added twice.

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
| `print_states.dart` | States, a node's name, its behaviors (4.7). |

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
| States | state words, `name=`, behaviors by name (4.7) | `print_states.dart` |

### 4.1 Keys (settled 2026-11-17)

What 2.1 left to this family, as the parser now reads it (`lib/src/core/notation/keys.dart`,
`test/notation/keys_test.dart`):

- **Where a type shows text** is the catalog's: its prop `style` when that is a `TextStyle`, else its one
  `TextStyle` prop (a chip's `labelStyle`, a badge's `textStyle`); a type with several (a tab bar, a chart) has
  none. A field of it set on a line starts from the style the line's words start from (a Text's body style, an
  Input's own), as `size=` does. So `height=1.2` on a Text or an Input is its line height; `h=` is its height.
- **Decoration fields are a key only where the catalog says the type is `decorated`**; elsewhere only `effects`
  (the blurs an undecorated node keeps). `Text radius=4` is said, not dropped at decode.
- **The bounds of the constraints** (`minWidth`, `maxWidth`, `minHeight`, `maxHeight`) are layout fields by their
  own names: `maxWidth=720` is `layout.constraints.maxWidth`. `constraints.maxWidth=720` reads too.
- **A field of the node itself** has no section in the document, so its full path is `node.` before it: where a
  prop of the type has the same name (a chip's own `tooltip`), `node.tooltip="…"` is the node's. Elsewhere the
  bare name is the shortest key.
- **An element of a list** is `[n]` in a key, as in a binding path: `fills[0].color="#FF2563EB"`,
  `effects[0].blurRadius=8`.
- **A full path that names a section the type has a prop of** (`decoration.counterText` on an Input) reads as the
  section first and the prop second: `decoration.` on an Input is its `InputDecoration`.
- **`key={expression}` binds the path** the key resolved to, for every key. The one exception is a tooltip,
  which reads its data itself (design 21): `tooltip={…}` and `node.tooltip={…}` are the node's own tooltip.
- **Values.** A word for an enum field that is none of its values is said with the nearest (`A Text's textAlign
  is one of left, right, center, justify, start, end: not "centre" (did you mean textAlign=center?)`). A field
  that is a record (a `Pan`, a `DropTarget`) given a word it cannot read as one is said with its fields
  (`pan=horizontal` → `write its fields, pan.enabled=… (enabled, axis, …), or pan={"enabled": …}`). In the
  open vocabulary both are recorded words instead, as a wrong kind of value was.
- **The unknown key** is said where it was written: `A Column has no "rotate": left out.`, with `(did you mean
  squeezable?)` when `suggest.dart` finds one among the names the type has (its props, its text style's
  fields, the layout, decoration, node and behavior fields, the short words that mean something on it); a
  dotted one at the segment that is wrong (`pan.axs` → `pan.axis`). A design system's component keeps its
  message (`A StatusPill has no "status". It takes: label, tone.`). A key the notation's own words read later
  (a Donut's `values`, a chart's `series`) is not said.

**For the printer.** `keys.dart` exports, all pure, `catalog` defaulting to `Catalog.current` and `type` the
document's node type (`text`, `textField`, a component's name):

```dart
/// The path key K sets on a node of type T (`props.style.height`, `layout.constraints.maxWidth`, `pan.axis`,
/// `decoration.fills[0].color`, `tooltip`), or null: no name of T, or a word of the notation that sets
/// no one path (`fill`, `border`, `animate`, `color` on a box, `gap` on a Grid).
String? notationKeyPath(String key, String type, {Catalog? catalog});

/// The same, with what the catalog declares there (`type`, `def`).
NotationKey? notationKey(String key, String type, {Catalog? catalog});

/// The shortest key that means path P on T: the notation's short word, else the field's own name, else the
/// path from its field up, else the full path (`node.` before a node field).
String notationKeyFor(String path, String type, {Catalog? catalog});

/// The nearest name to an unknown key on T, as the issue says it; and every name a key may start with on T.
String? notationKeyNearest(String key, String type, {Catalog? catalog});
List<String> notationKeyNames(String type, {Catalog? catalog});

/// The prop of a type that is the style of the text it shows, or null.
PropDef<Object?>? notationTextStyleProp(WidgetSpec spec);
```

`notationKeyPath(notationKeyFor(P, T), T) == P` for every field of every node type: the walk in
`keys_test.dart` checks it, and that the line written with it expands to the value at P, for 62 of the 69
core types (six have no line that is the type alone: `box`, `gridView`, `badge`, `appBar`, `modal`,
`radialGauge`). A value still goes through the notation's reading of it (`_value`: a quoted string, a number,
a bare word, JSON), so the printer writes a string quoted and a list or map as JSON.

### 4.1 Fields: the forms of a node's line

What 2.1 and 2.5 leave to this family, settled (tests: `test/notation/fields_test.dart`):

- **The parser is the table.** The printer asks the parser, by reading short lines once per catalog, which word a
  type takes, what a line gives with nothing written, and whether `key=value` reads back as that prop; it keeps
  no second table of either.
- **Order.** `Type[.variant]#id "main"`, the type's own words (`gap`, the alignment words, `scroll`, `clip`, a
  text's or a field's style words, an Input's `hint=` `helper=` `error=` `icon=` `prefix=` `password`), then
  layout (`pad`, `w`, `h`, `grow`, `margin`, `x`, `y`, `align`, `order`, `basis`, `aspectRatio`, `maxWidth` or
  `constraints`), decoration (`fill`/`gradient`/`fills`, `border`/`border-<side>`/`strokes`, `strokeWidth`,
  `radius`, `effects`, `clip`, `shape`), the other props by name, the node's own fields (`hidden`, `opacity`,
  `tooltip`, `sticky`, `readOnly`, `drag`, `drop`), bindings, `bind=name`; then events, media, paint.
- **A type's word.** Its one short name that says no more than the type's own word, with every prop and a line
  under it and with the line's own words (`Input`, `Toggle`, `Select`, `Button`, `Progress`; not `AreaChart`,
  which fills under a line chart's series); else a button's look that says no more (`Button.outline`,
  `Button.ghost`, `Button.elevated`); else the type capitalised (`ListView`); else the type as the catalog spells
  it, where the capital is another word (`box`, `gridView`, `badge`, `barcode`). A look with props of its own is
  written where the node has them (`Button.secondary`, `Button.destructive`). A text is the named style it is
  the fewest words away from (`Text.title color=…`), the later name of two of one style (`title`, not
  `pageTitle`).
- **A size** is written where it is not what the parent gives (design 13, section 3): `fill` and `hug` for a fit,
  the number for a fixed size, and the size's own JSON for a fit that keeps a design size (`w={"fill":390}`, 2.1's
  JSON for a map). A text in a row that may not shrink writes its width (`w=hug`): written without one, it is
  squeezable.
- **A field whose value is a record or a list** with no word for each of its parts is written whole under its
  own name, as its JSON: `style={…}` on a button, `decoration={…}` on an Input, `constraints={…}`, `fills=[…]`,
  `strokes=[…]`, `effects=[…]`. `maxWidth=` alone is the constraints' word; `gradient=` a linear fill with even
  stops. A text's fill is `fills=[…]`: `fill=` on a text makes a tag around it.
- **A binding** is `key={expression}` (`{name}` reads `${name}`, `{formula}` reads `${= formula}`; `selected=`
  always reads a formula), and a prop bound to a text with values in it is `key="…{x}…"`. A value and a binding of
  the same field are both written, the value first (`fill=#FFE5E7EB fill={…}`, `radius=8 radius={…}`), except a
  size, which a binding makes 0. A control's value kept in a declared variable, with the `changed` reaction that
  stores it first, is `bind=name`; `printedBindReaction` tells the events' words which reaction that is.
- **By name, once the parser reads every field (Keys).** Behind `notationFieldNames` (off until then; its tests
  are skipped with "needs the Keys family"): a field of a text's style by its name (`letterSpacing=0.4`,
  `from=eyebrow`); a layout field (`squeezable=true`, `columnSpan=2`, `minHeight=40`); a decoration field
  (`strokeSides=topBottom`, `dashPattern=[6,4]`, `strokeAlign=outside`, `blendMode=multiply`,
  `foregroundFills=[…]`); a node field or behavior, a record as its JSON (`inkWell={…}`, `states={…}`,
  `ignorePointer=true`); a field inside a prop by its path from the props (`decoration.isDense=true` on an
  Input); a prop whose name is a word of the notation by its full path (`props.animate=true`); a binding with no
  key by the field's name (`columnSpan={…}`) or its full path (`motion.scale={…}`,
  `decoration.effects[0].color={…}`).

### 4.1 Events and actions: the forms settled

- **An event's name.** The notation's own names stay: `onTap` (`click`), `onChange` (`changed`), `onRightClick`
  (`secondaryClick`), `onHover` (`cursorEnter`), `onFocus`, `onBlur`, `onSubmit`. Every other trigger is `on` and
  its catalog name with a capital (`onLongPress`, `onDrop`, `onDragEnd`, `onEnterViewport`, `onKeyDown`, `onTimer`,
  `onLoad`, `onRowTap`), read from `TriggerType` at run time. `hover` (the pointer moving over the node) is
  `onHoverMove`, since `onHover` was taken. The catalog's own name where the notation has another (`onClick`,
  `onChanged`, `onCursorEnter`, `onFocusGained`) still reads, and is never printed. One table holds the names
  (`notationEventNames`, `notation_events.dart`); the parser and the printer both read it.
- **Which node takes which trigger.** The catalog says no more than that a trigger is a node's: every trigger
  reads on every line. `onEvent` is no event: a block's events are written by their own names, as before; on a
  block, a trigger name the notation did not have before section 2.2 is that trigger, and the names it had are
  the block's first event when it has none of that name.
- **A trigger's fields** are written in parentheses by name, separated by commas: `onKeyDown(key=Shift+Enter,
  repeat=true)={…}`, `onEnterViewport(visibleFraction=0.5, onceKey={item.id})={…}`. The fields are the
  catalog's (`TriggerFields`), shared by every trigger. (There is no `onKey` and no `shift` field: the example in
  2.2 is `onKeyDown(key=Shift+Enter)`.)
- **A field's value**, of a trigger or an action: a number, `true`, `false`, `null`; a bare word (that text); a
  quoted string, whose `{name}` reads a value as a verb's string does; `{expression}`, as after a key (a name is
  `${name}`, anything else `${= …}`); `{"key": …}` and `[…]`, JSON. A field that holds actions (the catalog's
  nested chains: `then`, `else`, `actions`, `onSuccess`, `onError`, `cancelActions`) takes them in braces:
  `runScript script=check onError={toast "Failed"; ok=false}`. Every action type also takes the fields every action
  has: `enabled`, `nonBlocking`, `when` (JSON). A formula that is only a name (`${= ready}`) has no word of its own
  (`{ready}` is `${ready}`): an action holding one prints in another form, or as JSON.
- **A verb that is also an action type** (`focus`, `announce`, `confirm`) is the action type when a field of it
  follows (`focus node=email selectAll=true`), else the verb (`focus email`).
- **The printer** tries, for each action, the verbs, the choice (for an `if` whose condition is `isTrue` of a
  formula), the type and its fields, then JSON, and writes the first that parses back to the same action; a
  node's events are written all or none. The canvas's timers and shortcuts are its `every` and `key` lines
  (`printCanvasEvents`); a canvas's other triggers (`load`, `backPressed`) have no line yet (the Document family's
  canvases).

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

### 4.6 Paint, motion and charts: the forms

Settled 2026-11-17 by that family. Custom paint and animations are ordered lists of records, so they are lines:
each record one line, in the grammar's own shape (`word[#id] ["text"] key=value … [{…}]`), indented under the
line that holds it. The parser reads these lines before any other reading of a line (an alias, a defined word,
a node type), so an op named `text`, `path` or `image` is never a node.

**Custom paint.** A `customPaint` line indented under the node that paints carries the behavior's own fields
(`viewBox`, `fit`, `isComplex`, `willChange`; a true boolean is its bare word). The lines under it are the
`painter`'s ops, in order, one op a line; a `foregroundPainter` line under it holds the ops drawn over the
content, under it again. An op line is:

- the op's API name (`path`, `line`, `rect`, `rrect`, `circle`, `oval`, `arc`, `points`, `paragraph`, `image`,
  `group`, `repeat`: `DrawOpSpecs`), `#id` for its `id`;
- a quoted string first: a `paragraph`'s `text`, an `image`'s `url`;
- its fields by their own names (`DrawOpSpecs`' fields and `id`, `when`, `paint`, `hit`): `c=[12,12]`,
  `radius=4`, `d="M0 0 L10 10"`, `when={item != 0}`;
- its paint in two words: `fill=<color>` paints the shape, `stroke=<color>` strokes it, with the stroke's own
  fields beside it by Flutter's names (`strokeWidth`, `strokeCap`, `strokeJoin`, `strokeMiterLimit`,
  `dashPattern`, `scaleStroke`). `fill` alone is the paint as written (`fill=#FF22C55E` is `"paint": "#FF22C55E"`,
  as the API writes a paint that is a color; `fill={pal[item]}` a paint worked out), `stroke` alone a stroking
  paint, both the two paints in that order. `paint=` (the field's own name) is what they cannot say: a paint
  object with a shader or a blend mode, paints in another order;
- a `group`'s and a `repeat`'s `ops` are the lines under it;
- a `{…}` tail at its end, merged into the op, as on a node's line.

A value is written as on a node's line (2.1): a number, a bare word (an enum's name, a color, a theme color's
name), a quoted string (`{name}` in it reads the state; `${…}` written in it stays as written), `{expression}`
(`${name}` for a name, `${= …}` otherwise), JSON for a map, and a list as JSON or with expressions among its
numbers (`c=[{60 + index * 34},48]`). An op the API does not have, a key its op does not take and a line under an
op that takes none are said (a closed vocabulary): the op is kept as written.

From the corpus (tool/reference/examples/paint_illustration.json; CodelesslySDK examples/prompt_app/polish/bar/
home.json, `top_mark`; examples/showcase/desktop/native/site_landing.json, `hero_figure_hero_adult`):

```
box#scene w=fill h=212
  customPaint viewBox=[320,200] fit=cover
    rect rect=[0,0,320,200] fill=#FFE8F1F8
    circle c=[236,62] radius=28 fill=#FFF4B740
    repeat count=3
      circle c=[{60 + index * 34},{48 + index * 6}] radius=3 fill=#FF5D6D7E
    path d="M0 150 C60 100 120 110 170 140 C220 170 270 120 320 130 L320 200 L0 200 Z" fill=#FF7FB685
    line p1=[40,196] p2=[280,196] stroke=#33FFFFFF strokeWidth=2

box#top_mark w=30 h=30
  customPaint viewBox=[28,28]
    rrect rect=[0,0,28,28] radius=9 fill={{'shader': {'type': 'linear', 'begin': 'topLeft', 'end': 'bottomRight', 'stops': [{'position': 0, 'color': theme.colors.brandBright}, {'position': 1, 'color': theme.colors.brand}]}}}
    path d="M7 17 C 7 5, 21 5, 21 17" stroke={theme.colors.accent} strokeWidth=2.6 strokeCap=round strokeJoin=round
    circle c=[14,18.5] radius=2.6 fill={theme.colors.onBrand}

box#hero_figure_hero_adult
  customPaint viewBox=[240,240] fit=contain
    group opacity=0.55
      path d="M48 122 C 18 176, 66 232, 120 232 C 174 232, 222 176, 192 122" stroke={theme.colors.artRope} strokeWidth=3 strokeCap=round strokeJoin=round dashPattern=[1,9]
    oval rect=[80,220,80,10] fill={theme.colors.artShadow}
```

And the guide's dial (docs/guide/07-custom-paint.md), with a foreground painter:

```
box w=200 h=200
  customPaint viewBox=[200,200]
    circle c=[100,100] radius=96 fill=#FF1C2833 stroke=#FF5D6D7E strokeWidth=3
    repeat count={ticks}
      group translate=[100,100] rotate={radians(index * 360 / count)}
        line p1=[0,-90] p2=[0,{index % 5 == 0 ? -76 : -84}] stroke=#FFE8ECEE strokeWidth={index % 5 == 0 ? 3 : 1.5} strokeCap=round
    foregroundPainter
      group#needle translate=[100,100] rotate={radians(value * 6)}
        line p1=[0,14] p2=[0,-80] stroke=#FFE74C3C strokeWidth=3 strokeCap=round
```

**Animations.** `animate=<word> duration=… delay=…` stays the way to write an animation one of its words
stands for, and the printer writes it for a node whose `animations` are exactly that (`id` `a`). Every other
animation is an `animation#<id>` line indented under its node, with `NodeAnimation`'s fields by their own names
(`duration`, `delay`, `curve`, `repeat`, `autoplay`, `preset`, `params`, `spring`, `progress`, …), and its
tracks the `track[#id]` lines under it with `AnimationTrack`'s fields by theirs (`path`, `node`, `variable`,
`from`, `to`, `keyframes`, `wave`, `interval`, `curve`, `blend`, `interpolation`). Values as above
(`repeat={"reverse": true}`, `from={start}`). The animations are in the order their lines are written, after
the one `animate=` gives. From CodelesslySDK examples/prompt_app/polish/bar/home.json:

```
Column#top gap=16
  animation#enter duration=520 delay=0 curve=easeOutCubic
    track path=opacity from=0 to=1
    track path=motion.translateY from=14 to=0
```

A node's `transitions` (how a change of a property animates) are `transition` lines under it in the same way,
one a line, with `Transition`'s fields by their own names: `transition property=opacity duration=200
curve=easeOut`. (`motion` is one record, not a list: its fields are dotted paths, 2.1.)

**Charts.** A chart's fields are props, read and written by their own names (2.1). Its lists are JSON: the
records (`series`, `referenceLines`, `xLabels`, `zones`, `markers`, `ranges`, `yLines`, a line chart's bands and
ticks) and the values (`values`, `labels`, `colors`, `gridLabels`, `points`, `data`); the printer writes them, by
those names, on the line of a `chart`, `barChart`, `lineChart`, `plotChart`, `radialGauge` or `gaugeMeter`.
What the notation says shorter is printed so: a `lineChart` whose `data` are the points that `values=[…]` gives
(`{"x": i, "y": v}` under `xField` `x` and `yField` `y`) prints as `values=[…]`, and as `values={list}` when
they follow the state. `radialGauge`, the document's own type, is the node as written; `Gauge` and `Dial` are
the notation's gauge (a stack of the arc and the figure inside it, a clean arc unless more is written).

A record block is the node's field whole: a `customPaint` line sets the node's `customPaint` to what its block
says; `animation` lines add to the node's `animations` after the one `animate=` gives, `transition` lines to
its `transitions`.
`printPaintSays` (print_paint.dart) names the fields these words say, for the line's other words to leave out.

### 4.7 States and behaviors: the forms

Settled 2026-11-17 by the states family (`state_words.dart`, `print_states.dart`; tests:
`test/notation/states_test.dart`).

**The shape.** A node's `states` (`StateStyles`) maps a state, one of `WidgetState`'s names (`hovered`, `focused`,
`pressed`, `selected`, `disabled`, `dragged`, read at run time), to node ids, each to a patch of that node's JSON
(a merge patch). The ids are the node itself or nodes inside it: a state of a row restyles the row and the label
in it. They are ids, not the node's `name` (a node's `name` is its name in the editor, nothing reads it here).
`selected` and `disabled` follow the node's bindings (`bind.selected`, `bind.disabled`); the others the pointer
and the focus. Where states overlap, the later in `WidgetState`'s order wins. While a state holds, its patch
shows over the node's bindings of the fields it sets (the renderer drops them, as a media rule's
`"bind": {…: null}` does), and a patch may hold bindings of its own (`"bind": {…}`, merged into the node's).

**The form.** A state is a media rule with the state's name as the condition (2.4): `state.key=value`, one word
per field, the key any key the line reads, with its value as the line writes it.

- On a node's own line, the words are its own state: `hovered.fill=accentDeep pressed.opacity=0.82
  focused.strokes=[{"color":"focusBorder"}] disabled.opacity=0.4`. A flag reads as on a line (`hovered.hidden`), a
  binding as `key={expression}` (`hovered.color={dark ? "white" : "ink"}`: the patch's `bind`).
- On the line of a node inside it, a state of the line around it is written after that line's id:
  `btn.selected.color=primaryText`. The word goes on the line of the node it restyles, so each line stays one
  node; the id names whose state it follows, and must be the id of a line around it (else it is said). An id
  the parser gave (`row3`) is written as it is given.
- The words of one state of one node on a line are one patch, wherever they are on the line. Its patch is what
  the words change on the line: the line read alone with and without them (`MediaLineReader`, the media rules'
  reader, given the keys a state's patch may hold: any field of the node, not `type`, `children`, `slots`,
  `actions`, `media`, `states`, `name`, `key`, `component`). Unlike a media rule's, it drops no binding (the
  renderer does).
- **A state written replaces the look the parser gives.** `selected={…}` on a box draws it in the theme's
  selected fill and `enabled={…}` on a box draws it at half strength: a `selected.…` or `disabled.…` word for that
  node, on its line or under it, is its look instead (`Row#btn selected={on}` with `btn.selected.color=…` on
  a line under it has no selected fill).
- **Not confusable with a media rule.** The state names are none of a media condition's segments (`phone`,
  `mobile`, `tablet`, `desktop`, `portrait`, `landscape`, `min…`, `max…`). A key the line's type reads as a
  path wins over a state word (`states.hovered.btn.opacity`, the full path, still reads), and a media condition
  wins over an id: a node with the id `phone` or `max900` has no state words under it (its states print in the
  tail). A media rule holds no state and a state no media rule: `phone.hovered.fill=…` and
  `hovered.phone.pad=…` are said.
- **The printer** writes, for each node whose states it can say, every patch with the words a media rule's are
  chosen with (`printPatchWords`), the shortest that give exactly that patch: on the node's line for its own,
  on the target's line after the owner's id for a node inside it. A state the line's words give already
  (`selected={…}` on a box with exactly the theme's selected fill) is not written. A node's states are written
  all or none: one patch with no words (a target that is no node inside it, an empty patch) leaves them all to
  its `{…}` tail. `print_fields.dart` writes `selected={…}` on a box whose selected state the words say.

From the corpus (CodelesslySDK `design_systems/cards/components/ActionButton.json`, `Chip.json`;
`examples/showcase/desktop/native/app_board/round2/doc.json`):

```
Row#btn gap=8 center pad=[16,0,16,0] h=46 fill=accent radius=14 … pressed.opacity=0.82 onTap={…}

Row#chip gap=0 pad=[8,0,8,0] … fill=subtleFill radius=9 selected.fill=activeTint
    selected.strokes=[{"color":"primaryTintBorder"}] hovered.foregroundFills=[{"color":"hoverOverlay"}] …
  Row#chipContent gap=4
    Icon#icon "sell" color=secondaryText size=12 chip.selected.color=primary
    Text#label "{props.label}" … chip.selected.color=primary

Column#card gap=8 pad=12 … selected={selectedId == item.id} drag=card(item.id) draggable.start=auto
    draggable.childWhenDragging=ghost hovered.strokes=[{"color":"#FFCBD5E1"}] selected.strokes=[{"color":"#FF2563EB"}] …
```

**A node's name and its behaviors.** `name=Board` (a quoted text where it is not a word) is the node's `name`;
on a type with a prop `name` (a component's parameter), `node.name=`. Every behavior no other word says
(`inkWell`, `focusable`, `motion`, `focusGroup`, `form`, `radioGroup`, `reorderHandle`, `floating`, a drag
source's or a drop target's other fields) is written by the keys' names (2.1, `keys.dart`): one word per field
(`inkWell.hoverColor=hoverOverlay`, `motion.rotate=90`, `focusable=false`, `form.autovalidateMode=onUnfocus`), a
record whole as its JSON only where no word of each field reads back. A drag source whose `data` is worked out is
`drag=card(item.id)` with its other fields after it (`draggable.start=auto`): a key's value with `{…}` in it binds
the field. `print_states.dart` writes these (`printStatesKeys`); the fields' own loop leaves them to it.

Not said yet: a value inside a record that is an expression to work out later (`dropTarget.key: "${item.name}"`):
a key's value with `{…}` binds the field (`bind.dropTarget.key`), which is another document (the Keys family's
reading of values). A state patch of a node that does not exist (`states.hovered.self`) and a node key the catalog
does not have (`margin` beside `layout`) have no line to be written on or no key to be written with.

## 5. What does not change

The prompt teaches the grammar and the core (design 19). Parity is what the parser reads and the printer
writes; it is not a longer prompt. A key the catalog has is read whether or not the prompt names it, and the
reference page of its type is where a writer finds it.
