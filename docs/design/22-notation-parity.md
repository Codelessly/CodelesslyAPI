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

## 5. What does not change

The prompt teaches the grammar and the core (design 19). Parity is what the parser reads and the printer
writes; it is not a longer prompt. A key the catalog has is read whether or not the prompt names it, and the
reference page of its type is where a writer finds it.
