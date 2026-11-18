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
`keys_test.dart` checks it, and that the line written with it expands to the value at P, for 63 of the 69
core types (five have no line that is the type alone: `box`, `gridView`, `badge`, `appBar`, `modal`;
`radialGauge` has been the node as written since 4.6). A value still goes through the notation's reading of it (`_value`: a quoted string, a number,
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
  `tooltip`, `sticky`, `readOnly`, `drag`, `drop`), bindings, the line's marks (`@name`, design 13 section 3.1);
  then events, media, paint. A key is written once on a line (design 13 section 3: a key written twice is an issue,
  since 34.0.0).
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
  own name, as its JSON: `style={…}` on a button, `fills=[…]`, `strokes=[…]`, `effects=[…]`; where its parts
  have keys they are written by them instead (4.7: `minHeight=40 maxWidth=720`, `hint=Search
  decoration.isDense=true` on an Input). `gradient=` is a linear fill with even stops. (A text has no fill: it is
  not decorated, 4.1 Keys.)
- **A binding** is `key={expression}` (`{name}` reads `${name}`, `{formula}` reads `${= formula}`; `selected=`
  always reads a formula), and a prop bound to a text with values in it is `key="…{x}…"`. A value and a binding of
  the same field are both written, the binding by the key and the value by another key that means the field: its
  path (`decoration.radius=8 radius={…}`, `layout.height=24 h={…}`, `props.crossAxisCount=3 cols={…}`), or the
  field's whole value (`fills=[{"color":"#FFE5E7EB"}] fill={…}`); a field with no second key keeps its value in
  the tail. (Before 34.0.0 both were written under one key, `radius=8 radius={…}`; a key written twice is now an
  issue.) A size is 0 under a binding unless a number is written beside it (`layout.height=24` counts, 4.7). A
  control's value kept in a declared variable, with the `changed` reaction that stores it first, is `@name`, the
  events' word since the second wave (4.1, 4.7); `printedBindReaction` tells the events' words which reaction that
  is.
- **By name (on since the Keys family landed: 4.7).** A field of a text's style by its name (`letterSpacing=0.4`,
  `from=eyebrow`); a layout field (`squeezable=true`, `columnSpan=2`, `minHeight=40`); a decoration field
  (`strokeSides=topBottom`, `dashPattern=[6,4]`, `strokeAlign=outside`, `blendMode=multiply`,
  `foregroundFills=[…]`); a node field or behavior, a record as its JSON (`inkWell={…}`, `states={…}`,
  `ignorePointer=true`); a field inside a prop by its path from the props (`decoration.isDense=true` on an
  Input); a prop whose name is a word of the notation by its full path (`props.animate=true`); a binding with no
  key by the field's name (`columnSpan={…}`) or its path (`motion.scale={…}`, `effects[0].color={…}`).

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
  has: `enabled`, `nonBlocking`, `when` (JSON). A formula that is only a name (`${= ready}`) is written as it is
  held, in quotes (`when="${= ready}"`, second pass below): `{ready}` is `${ready}`.
- **A verb that is also an action type** (`focus`, `announce`, `confirm`) is the action type when a field of it
  follows (`focus node=email selectAll=true`), else the verb (`focus email`).
- **The printer** tries, for each action, the verbs, the choice (for an `if` whose condition is `isTrue` of a
  formula), the type and its fields, then JSON, and writes the first that parses back to the same action; a
  node's events are written all or none. The canvas's timers and shortcuts are its `every` and `key` lines
  (`printCanvasEvents`); its other triggers are `on` lines (second pass below).

### 4.1 Events and actions, second pass: the forms settled

Settled 2026-11-17 (tests: `test/notation/events_test.dart`, group "the second pass").

- **The screen's other reactions** are lines of their own, as `every` and `key` are: `on`, the trigger's catalog
  name, its fields in parentheses as after an event, `=` and its actions in braces: `on load={saved=coalesce(storage.saved,
  [])}`, `on backPressed(when={step > 0})={step=step-1}`, `on keyDown(key=Escape, repeat=true)={close}`. (A bare
  `onLoad={…}` line stays what it was, a handler written off its node's line, said.) The printer writes `every`
  and `key` where they say the reaction, else `on`; an unknown trigger is said with the nearest
  (`The screen has no trigger "lod". Did you mean "load"?`).
- **A formula that is only a name** in a trigger's or an action's field: a quoted string keeps a `${…}` written
  in it as written, as a paint op's value does (4.6): `onScroll(when="${= ready}")={…}`, `setVariable variable=x
  value="${= ready}" op=toggle`. A string with no `${` reads its `{name}` as before.
- **One spelling of what the API reads in two.** The notation states meaning; where the document API reads two
  spellings as one thing, the print is right when the document read back is the document in the parser's
  spelling. `printNormalized` (print_events.dart) gives that form and `printNotation` reads the document in it
  before it prints, compares and works out a tail: a reaction's trigger written as its type alone (`"trigger":
  "click"`, `Trigger.fromJson`) is `{"type": "click"}`; an operand of a condition written as a number or a boolean
  (`"left": 3`, `ConditionOperand.fromJson`) is its text, in an action's `when`, an `if`'s `condition` and the
  actions nested in them. Nothing else in a reaction is read two ways: its `actions` are a list only
  (`readList`), an action's type and fields one key each.
- **`@name`** (design 13 section 3.1, since 34.0.0; before, `bind=name`) is printed for every two-way binding
  the parser writes: the binding of the control's value and the `changed` reaction that stores it first among
  its reactions, found by reading the mark on the line where the node is (under its `each`), so for every control
  type: a variable (`Slider @vol`), a field of a record variable (`Input @draft.title`), a field of the repeated
  element (`Checkbox @item.done` under an `each`), and a control with two ends, one change storing both (`Slider
  @lo @hi`, `Calendar @from @to`). A design system control's variable parameter holding a variable's name or a
  field's path is a mark too, with no reaction: its value bare (`ToggleRow @public`, `ToggleRow @item.on` under an
  each), each further variable parameter by name (`SortMenu @col direction=@dir`). The mark is printed only
  where the variable is declared (by the print's `state` lines, a loop): reading it adds no variable. The node's
  other reactions are its events. What only shows a value (`Progress`) keeps `value={…}` (the fields' binding).
  Not printed yet: `selected=@picked` on a `selectable` list (the list words are not printed: the list stays its
  reactions and bindings).
- **A design system block's events** are written by their own names (`SessionRow onPressed={emit open_session
  {item.date}}`), checked on the block called alone, which may already say it lacks a parameter; `onTap` on a
  block reads as its first event and prints as that event's name. In a component's own tree, `emit name [value]`
  raises one (`Row onTap={emit onPressed}`).

Not said yet: an event of a design system component whose name is also a word of the notation (`Button`,
`IconButton`, `Card`, `Chip`, `TopBar`): the line reads as the notation's type, on which `onPressed` is a tap,
so its reactions stay in the tail with its `type` until a line can name such a component (the fields' and the
parser's head, not an event's word). A nested `each` (a list in a list's element) prints `@name` only for a
variable or a record's field; a field of the outer element keeps `value={…} onChange={…}`.

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
  Any other id is written when it is one word of letters, digits and `_` (`#m_logo`; an id from data,
  `#row-{row.id}`, is still its fixed part). Since 34.0.0 a hyphen in an id is an issue, read as `_` (design 13
  section 3): a document whose node or canvas ids have one (`m-logo`) cannot name them in a line, and prints
  whole on the `document {…}` line, which the stream sends as its nodes, their places, its roots and its
  variables.
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

### 4.7 Fields, second pass: every field by its key

Settled 2026-11-17 (tests: `test/notation/fields_p2_test.dart`, `fields_test.dart`).

- **The rule.** After a line's own words (4.1), every field the line still gives other than the node has it is
  written by the key `notationKeyFor` gives its path (2.5): props, layout, decoration, the node's own fields and
  behaviors, bindings. A record or a list whose parts differ is written part by part by their paths
  (`style.letterSpacing=0.4`, `fills[1].visible={…}`), else whole as its JSON; a key the line reads as a word of
  its own falls back to the full path (`props.size=48`). The words are checked by reading the line under its
  parent's line, all at once and then a field at a time, for a few rounds, and kept where the line is closer to the
  node. `printNotation` then asks the fields once more where the print puts each line (under an `each`, in a grid,
  in a page: `printFieldsRefine`, one call in the walk), against what the line reads as there. The fields of the
  other families are left to them (`actions`, `media`, `states`, `animations`, `transitions`, `customPaint`, and
  what `printPaintSays` names).
- **`key=null`: a field the node has not.** The line gives it (a row's `crossAxisAlignment`, a slot's size, a
  text style's `fontSize` from its variant), the node has none: `Row crossAxisAlignment=null`, `Slot w=null
  h=null`, `Text "x" size=null from=caption`. The field is taken out once the line is read, whatever the line would
  give it, and a section (`props`, `layout`, `decoration`) it leaves empty with it: a row with no props at all is
  `Row crossAxisAlignment=null`.
- **An expression is kept as written, its quotes too.** `key={…}` for a key that is no event, an `if` line's
  condition and an `each` line's list are read as written: `visible={tone == 'quiet'}` is
  `${= tone == 'quiet'}`, as a design system writes it. Single quotes are still read as double in actions (after
  `on…=`) and in a value that is no expression (`text='Hi'`, `items=['a','b']`). A `\n` written in an expression
  is read as written.
- **`data={list}`**: what a list shows, bound by the binding's own path where the type has no prop `data`; a
  list the walk does not make an `each` of is written so.
- **`enabled={x}`** on what has no enabled of its own is its disabled state `${= !x}` for a name or a path,
  `${= !(x)}` for more: so a document's `!props.enabled` is written `enabled={props.enabled}`.
- **`type=Name`: a design system's component a word of the notation shadows.** `Button "Save" type=Button
  variant=ghost` is the component `Button`, not the notation's button; `TopBar "…" type=TopBar` is no page word.
  The key is the node's own `type` (2.1), written only with the name the line starts with, and only where the
  line without it reads as another type; `node.type=Name` reads too. `Button` alone stays the notation's (design
  13, section 12).
- **What a word adds yields to what the line gives.** A box's theme look for `selected=` and `enabled=` is added
  only where the line gives no `selected` (`disabled`) state of its own; a number written beside a bound size is
  the size it starts at (`layout.height=24 h={size}`, where a bound size alone is 0); a fill with its design size
  (`w={"fill":140}`) stays in a grid's cell, where any other width is the cell's.
- **`@name` is the events' word** (4.1 Events). A control's value kept in a variable, with the `changed`
  reaction that stores it, is left by the fields to `print_events.dart`: the bound path is not written here, and
  `printedBindReaction` names the reaction.
- **The types a capital would make another word**: `box` (`Box` is a column), `gridView` (`GridView`, `Grid` the
  grid of an `each`), `badge` (`Badge` a tinted pill row) are written by their catalog names, lowercase, and read
  as exactly that type (`box w=40 h=40`, `gridView cols=3`, `badge`).

Still without a word, and why: a column of a fixed height with a text in it (the parser makes it at least that
high, `height: {hug: h}` and a `minHeight`, after the column's line is read: a column exactly that high needs a
decision on that rule); a binding that is a formula of a bare name (`${= theme.colors.ink}`; `{name}` is
`${name}`), `selected` bound to `${name}` (`selected=` always reads a formula), and `${a[0].b}` (braces read it
as a formula); the disabled state of a control that has an `isEnabled` (`enabled=` is that prop); a binding the
parser adds that the node has not (a page's `index == n` under `Pages`); an empty `props: {}`; a text's
`decoration` (a text is not decorated, 4.1 Keys); and props or layout fields the catalog does not declare (a
box's `path`, `layout.rotation`, a component parameter its declaration lacks).

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
record whole as its JSON only where no word of each field reads back (else the fields that have words, the rest
in the tail). A drag source whose `data` is worked out is
`drag=card(item.id)` with its other fields after it (`draggable.start=auto`): a key's value with `{…}` in it binds
the field. `print_states.dart` writes these (`printStatesKeys`); the fields' own loop leaves them to it.

Not said yet: a value inside a record that is an expression to work out later (`dropTarget.key: "${item.name}"`):
a key's value with `{…}` binds the field (`bind.dropTarget.key`), which is another document (the Keys family's
reading of values). A state patch of a node that does not exist (`states.hovered.self`) and a node key the catalog
does not have (`margin` beside `layout`) have no line to be written on or no key to be written with.

### 4.7 The document family, second pass: the forms settled

Settled 2026-11-17 (tests: `test/notation/document_p2_test.dart`, `test/notation/stream_test.dart`).

- **The document line.** `document id="checkout" schema=2 scope=page_variables` at the top: the document's own `id`
  (where the parser gives another: a page has none, a component's is its name) and `schema` (a schema-2 file), and
  `scope`, the scope the `state` lines are kept in (the edit operations' name for it: a canvas id, or
  `page_variables` for every canvas), written where the parser would keep them elsewhere (it keeps them on the
  page's canvas, or in `page_variables` once the page has other canvases or overlays). Another key on it is said.
  `document {…}` at the end stays what it was, the document's merge patch.
- **State said one by one.** A component call's optional variable parameter that its line's tail gives (a value, a
  binding) declares no `<id>_<param>` variable: the document's variables are the state lines, so a list of
  variables is never replaced whole on the document line.
- **What the screen does.** A canvas reaction that is neither a timer nor a shortcut is a word of its `canvas`
  line, by its event's name (2.2): `canvas onLoad={go home}`, `onBackPressed={…}`, before its `every` and `key`
  lines.
- **Slots.** `slot name` under a node, the node in that slot indented under it, as a component's head names its
  slots with `slot name`: `ListTile` / `  slot title` / `    Text "Hello"`. It reads for any node whose catalog
  type has that slot (a ListTile's title, a badge's child, a table's cell, a component's actions); a slot the type
  does not have, and a second line under one slot, are said. The printer writes slot lines only for a node whose
  slots do not read back from the lines under it (a ListTile's icon still goes to its leading by itself).
- **A list of its own line.** A `ListView` or `GridView` line with an `each` as the only line under it repeats over
  that data, the line under the `each` its template (its one child), as a page view's page is under `Pages`:
  `ListView#rail h=300 scrollDirection=horizontal` / `  each item in products` / `    Column#card …`. What `each`
  makes under any other line is unchanged (a list and its item column, `<id>Item`). What differed before was
  exactly that: the parser's list is `listViewN` with its own props and the column `<id>Item` around the lines; a
  list written by hand has its own id and fields and its template as its child. The list's own line carries its
  id and fields, so no flag on the `each` is needed.
- **`stagger=`** is printed on the `each` line, for a first line under it whose `animations[0].delay` is bound to
  `index*<n>` (plus the line's own `delay=`).
- **A parameter's type** no Flutter name says (`int` held as a number, a `dynamic` item, a record's fields) is its
  JSON after the colon: `param count:{"kind":"number","flutter":"int"}=0`.
- **The catalog's type name is the node as written.** A line written with the type as the catalog spells it gets
  none of the defaults the notation's capitalised word adds: `barChart` and `lineChart` no height of 140 and no
  accent color (and `barChart` none of the design system's bar options), `barcode` no size of its own, as
  `radialGauge` (4.6) no composed gauge. `BarChart`, `LineChart`, `Barcode`, `Gauge`, `Dial` add them. The other
  types whose capitalised word reads as something else (`box`/`Box`, `gridView`/`GridView`, `badge`/`Badge`,
  `appBar`/`AppBar`) were already the node as written. A `lineChart`'s `values=[…]` is still its points: that is
  the word's meaning, not a default.
- **Reading back.** A record block (`customPaint`, `animation`, `transition`) under a node replaces what the line's
  tail gave for that field, also when the tails are merged again. A tail that gives a node another `type` gives
  that type's props; a `null` in a tail takes away what the words gave; a node the words made under a line (a
  Badge's text) that the line's tail takes out of `children` or `slots` is not in the document.
- **As it arrives.** `NotationStream` reads every line `parseNotation` reads. What the end of the text does (the
  tails merged again, the nodes a tail took away, the canvas lines' words, the `document {…}` line's nodes) is
  sent as patches and removals by `close()`; a tree with no canvas (a component's, `canvas none`) is sent with its
  root as the document's root. What no operation carries (the document's `id` and `schema`, a component's
  declaration and previews) is `NotationStream.result` after `close()`. `stream_test.dart` streams every printed
  document of `tool/reference/examples` and a sample of each form line by line and compares with `parseNotation`.
- **The measure** (`tool/notation_coverage.dart`) reads each document with its own design system's declaration of
  a component two design systems declare differently (the nearest on disk), does not count record lines as node
  lines, and counts how each field of a node line is said: a word of the notation, the field's own name, a dotted
  path, JSON as a value, an event, a media rule.

Not said yet, and why:

- **A design system's component whose name the notation reads as its own word** (`Button`, `IconButton`, `Badge`,
  `TopBar`, `Card`, `Chip`, `Select`, `Checkbox`, `Radio`, `Switch`, `Slider`, `ProgressBar`, `Sidebar`, `Header`,
  `Footer`: 235 node lines carry `"type"` in their tail, and their 64 `"children": null`). The owner decided that
  such a name stays the notation's (prompt.dart: "A name the notation already reads as a core type … stays
  that"), and the grammar has no other spelling for a component: the catalog spells it with the capital the
  notation takes. A form needs a decision: a component-first rule like `_softNames` (a writer's `Button` in such a
  design system would then be its Button), or a new head (`node {…}` is the one there is).
- **A component's empty parameter list** (`"widget": {"props": []}`, 3 documents): the parser gives a component no
  `props` when it has no `param` line.
- **A document's `conditions`** (1 document) and a missing `schema` (1).
- **Values the catalog does not have** (a box's `path`, a filled button's `size`, a literal `${…}` in a prop that
  is not a text): the parser says them (2.1) and the document line keeps them.

### 4.8 The reference family: what the reference exposed

Settled 2026-11-17 (tests: `test/notation/reference_p3_test.dart`; the reference: `tool/reference/src/notation_reference.dart`,
`docs/reference/notation/`, whose `_tails.md` is the work list).

- **A line's quoted strings.** A line has one main string (design 13, section 3). A second has a place only where
  the word gives it one: an `Input`'s second string is its hint, a `ListTile`'s its subtitle, and a container's
  strings (`Column`, `Row`, `Stack`, `Accordion`, `ExpansionTile`) are each a text in it, as many as written. Any
  other further string is said and left out, the first kept: `Text "a" "b"` → `A Text takes one quoted string: this
  one is left out.` (before, the second replaced the first without a word).
- **A box has no text.** `box "x"` is said (`A box has no text of its own…`); `Image "url"` (a box with that
  picture) is the one word whose string a box takes. The printer no longer writes a box's `props.text` as its string:
  it is a value the catalog does not have, kept as JSON (4.7).
- **One order for a line's words.** The printer writes a line in the order of 4.1 Fields, and within a text's or an
  Input's style its words in one order whatever the JSON's key order: `size weight color fontFamily lineHeight
  letterSpacing`, then the flags (`italic`, `underline`/`strike`), then any other style field by name, A to Z
  (`Text.title "x" weight=700 color=#FFFFFFFF lineHeight=1.3`). A `{…}` tail and the `document {…}` line write
  their JSON with keys A to Z at every depth. So a print printed again is the same text (the reference checks every
  example: `_tails.md`, "Prints that print again differently").
- **The grid of an `each`.** `Grid cols=3` with an `each` under it (a column around a gridView over the data, its
  item `<id>Item`) prints as that `Grid` line, `cols=` and `gap=` (when not 8) with the column's own words, the
  `each` under it: not as `Column#grid1` and `gridView … {"bind":{"data":…}}`. Where the grid does not read back
  from it, both print as nodes, as an each does.
- **A variable's type.** A declared type that is none of `VariableType`'s (`"number"`) is an `invalid_variable`
  error of the `vars` op, with the type meant as its suggestion (`number` → `decimal`, `string` → `text`); before,
  `Variable.fromJson` read it as text and the print's `state price:number` was refused. The JSON reference's
  STARTER example says `decimal`.
- **The verbs.** `notationVerbs` (notation.dart) is the parser's verbs and `notationVerbAliases` their other
  spellings (`unfocus` → `blur`); the reference generator stops when a verb has no documented sample or an action
  type of the catalog no section. The reference documents each canonical spelling; the open vocabulary's other
  spellings (`NotationVocabulary.core`, the verb aliases) are a generated table on `values.md`, marked "also read".

Checked and already as written (no change): `project cart=[]` on a page read alone is the same document as
`state cart=[]`, and prints so; `form=true`, `pan.axis=…`, `motion.scale=…`, `reorderHandle=true`, `letterSpacing=…`
on a Text print as written, and `style.letterSpacing=…` prints as its shorter word. A chart writes each key once
(`BarChart values=[…] labels=[…]`, `LineChart values=[…]`, `Donut values=[…]`, `Gauge value=…`), since 34.0.0's
key-once rule. `draggable=true` is no form: a drag source is `drag=…` or its fields (`draggable.group=…`).

### 4.8 Values: the forms settled

Settled 2026-11-17 by the values family (tests: `test/notation/values_p3_test.dart`).

- **A quoted string with the document's formula in it is kept as written, on every key.** Where a quoted string
  has `${=` in it, nothing in it is read: it is the text the document holds (`color="${= theme.colors.ink}"`,
  `validator="${= trim(value) == '' ? 'Enter your name.' : ''}"`, `Text "${= join(…)}"`, in a verb's string too).
  Without `${=`, `{x}` in a quoted string reads a value as before, and a `$` before a read is a dollar, as models
  write a price (`"Total ${qty*12}"` is `Total $${= qty*12}`, design 13's "read, not taught"). A trigger's or an
  action's field and a paint op's value keep any `${…}` as written (4.1 second pass, 4.6); a node's line keeps
  only the formula's, so that the price stays a price. The printer writes a string as written only where braces
  cannot say it (`${= name}`, which `{name}` reads as `${name}`).
- **Where the string goes is the field's.** On a node's line a string that reads data is bound (the field's
  binding), unless the field works its expression out itself, as the renderer does: a text's own text, an Input's
  `validator` (it runs on the text typed, `value`), a drop target's `key` and `acceptIf` (worked out for each
  drop), an image paint's URL (filled in from the scope). Those hold it: `validator="${= …}"` is
  `props.validator`, `dropTarget.key="{item.name}"` is `dropTarget.key: "${item.name}"`. A quoted string in braces
  always binds: `text={"${= ok ? 'Saved' : 'Not saved'}"}` on a Text is `bind.props.text`. From the corpus
  (CodelesslySDK `design_systems/cards/components/TableRow.json`; `tool/reference/examples/form_validated.json`;
  `examples/showcase/desktop/native/app_board.json`):

  ```
  Text#c0 "{length(props.cells) > 0 ? at(props.cells, 0) : ""}" … color="${= theme.colors.ink}"
  Input#name "Name" … validator="${= trim(value) == '' ? 'Enter your name.' : ''}"
  Column#lane … dropTarget.key="{item.name}"
  ```

- **A path with an element by its index reads as a path**: `{kpis[0].value}` is `${kpis[0].value}`, as `{name}` is
  `${name}` (before, a formula `${= kpis[0].value}`, which is now written `"${= kpis[0].value}"`).
- **`selected="…"`** is the binding as a quoted string reads (`selected="{props.selected}"` is
  `${props.selected}`); `selected={…}` still always reads a formula.
- **`node.disabled={…}`** is the node's disabled state as bound and nothing more, where `enabled=` is the type's own
  prop (an Input's `enabled`, a block's `disabled` options): `Input#field … enabled={props.enabled}
  node.disabled={!props.enabled}` (CodelesslySDK `design_systems/cards/components/TextInput.json`).
- **A field the line also binds** is written by its full path from the node, a key once a line:
  `radioGroup.groupValue={budget} node.radioGroup.groupValue=small`.
- **`props={}`, `props=null`** (and `layout`, `decoration`): the node's section is an empty record, or the node has
  none, whatever the line's words gave. Written where `key=null` cannot say it: a design system's call with no
  parameters given (`AuthPromptBanner#AuthPromptBanner0 w=340 h={"hug":92} props={}`, CodelesslySDK
  `design_systems/ssui/examples/catalog.json`), a section whose fields have no key.
- **A size written by its full path is that size exactly**: no rule of the line or of a line under it changes it.
  `Column layout.height=108` with a text under it is 108 high (`h=108` stays the least height, `{"hug": 108}` and a
  `minHeight`, design 13); `Spacer grow layout.height=hug` in a column hugs; `w={…} layout.width=fill` keeps the fit
  under the binding, as a number beside it does. From CodelesslySDK `design_systems/cards/components/BoardColumn.json`:
  `Column#empty gap=6 middle center pad=[12,12,12,12] layout.height=108 fill=card …`.
- **In a media rule, a word written by its full path patches that path only**: what reading it adds elsewhere on
  the line is not the rule's (`maxMobile.props.scrollable=true` without a scrolling row's edge fade,
  `min700.tablet.layout.width=fill` without a text's `squeezable`), CodelesslySDK
  `test/tool/fixtures/truth/scroll_by_media.json`.
- **The catalog declares `layout.widthFactor` and `layout.heightFactor`** (Flutter's `FractionallySizedBox`, which the
  document reads and CodelesslySDK renders): `box h=8 fill=accent widthFactor={item.pct / 100}`.

Not said, and why (dead data in fixtures: no renderer reads it, so the catalog does not declare it and the parser
says it, 2.1):

- a box's `props.path` (a box has no props; 12 nodes: CodelesslySDK `examples/relay-pricing/components/*.json`,
  `design_systems/ssui/examples/gallery.json`), `layout.rotation` (read only by the schema-2 migration), a node's
  top-level `margin` (the renderer reads `layout.margin`: `examples/showcase/desktop/native-cards/site_product/round1/doc.json`),
  an empty prop name `props.""` (`examples/showcase/design-pass-runs/inline-cards/approval/before.json`,
  `examples/showcase/style-pass/approval/before.json`);
- a decoration on a type that is not `decorated` (4.1 Keys), which its renderer does not draw: a Text's
  `decoration.fills` (14, `examples/showcase/design-pass-runs/inline-cards*/code_diff*/before.json`), a button's
  `bind.decoration.radius` (4, `examples/showcase/desktop/reference/site_*.json`), a page view's and a `Media` call's
  `decoration.radius` (5);
- a prop the type does not have: a button's `props.size` (6, `examples/showcase/desktop/tier1/*.doc.json`: a
  button sizes by its height), a Text's `props.decoration` beside its style's (1); an enum value the type does not
  have: an Input's `keyboardType: "email"` (2, `examples/showcase/desktop/{baseline,tier1}/site_blog.doc.json`;
  Flutter's is `emailAddress`, which `type=email` writes);
- a value beside a binding of the same text (`props.icon: "${item.icon}"` and `bind.props.icon` alike): the value
  is a read the field does not work out, which a line binds.

## 5. What does not change

The prompt teaches the grammar and the core (design 19). Parity is what the parser reads and the printer
writes; it is not a longer prompt. A key the catalog has is read whether or not the prompt names it, and the
reference page of its type is where a writer finds it.
