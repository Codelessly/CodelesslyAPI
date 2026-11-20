# The notation

The compact notation writes a Codelessly document one node per line. It says everything the JSON document says,
in fewer words, and expands to that same document. Read this page in full; it ends with the list of the other
pages, which you open when a UI needs what they hold.

## A line

```
Type[.variant][#id] ["text"] [key=value ...] [on<Event>={actions} ...]
```

- **Indentation** (two spaces) puts a line under another: its child.
- **`Type`** is a word ([Words](#notation-words)); `.variant` picks a look (`Text.title`, `Button.outline`).
- **`#id`** names the node, only where something else names it (an action, an overlay, a scroll target). An id the
  parser would give the line anyway is not written.
- **`"text"`** is the node's main string: a Text's text, a Button's label, an Input's label, an Icon's name, an
  Image's URL. A line takes one; a second is an Input's hint or a ListTile's subtitle, and on a Column or Row each
  string is a text in it. `{name}` inside a string shows a value: `"Total: {total}"`.
- **`key=value`** sets a field. The key is a short word (`gap`, `pad`, `w`, `h`, `fill`, `radius`) or the field's own
  name in the API (`letterSpacing`, `squeezable`, `crossAxisCount`). A field inside a record is a dotted key
  (`pan.axis=horizontal`, `fills[0].color=#FF2563EB`); the full path from the node always reads too (`layout.x=10`,
  `props.style.height=1.2`). Each word page gives every key of its words.
- **Values**: a number (`12`, `0.5`), a bare word (an enum's value `center`, a color `#FF2563EB`, `true`), a quoted
  string (`"Two words"`), JSON for a list or a map (`items=["S","M","L"]`), or `{expression}` for a value that
  follows the state (`visible={count > 0}`). Colors are `#AARRGGBB`. The docs of the keys quote the JSON's
  expressions: `${name}` there is `{name}` here, and `${= formula}` is `{formula}`.
- **`on<Event>={actions}`** runs actions on an event, `;` between them.
- **A bare word** after the text is a flag: `grow`, `hidden`, `scroll`, `center`. An icon's name is a word too:
  `Icon download`, and `icon=download` on a Button, Chip or IconButton, whatever a variable is called; an icon
  chosen by data is braced (`Icon {glyph}`, `icon={done ? "check" : "add"}`).
- **Your key wins over a word's own**: `Sidebar w=240 h=fill` and `Table … radius=0 border=rule` keep what you
  wrote over what the word would give; a key written twice on one line is still said.

```notation
state count=0
Column gap=12 pad=16
  Text.title "Counter"
  Text "Clicked {count} times"
  Row gap=8
    Button.outline "-" onTap={count=max(0,count-1)}
    Button "+" onTap={count=count+1}
```

What no word says yet can be written as JSON: a `{…}` at the end of a line is merged into that node
(`Text "x" {"props":{"maxLines":2}}`), and `node {"type":"…", …}` is a whole node. You should rarely need either:
every field of the API has a key.

## Words

A line's word is its node type. These are the words, by [level](levels.md); each links to its keys.

{{typeWords}}

Words that stand for a type with more set:

```notation expands
Column gap=8
  Card gap=8
    Text.strong "A card: a padded, bordered column"
  Box pad=12 fill=#FFF3F4F6 radius=8
    Text "A box: a column you style"
  Input "Email" "you@example.com"
```

- Text looks: {{textVariants}}
- Button looks: {{buttonVariants}}. Plain `Button` is primary.
- Badge looks: {{badgeVariants}}.
- `Table r in rows columns=["Name","Email"]` is a finished table of records (a bordered frame, a header that sorts
  with `sort=@key`, a checkbox column with `select=@chosen`): write it for any rows of records, never a Column of
  Rows ([lists.md](lists.md#lists-a-table-of-records)). `NumberInput @qty min=1` is a number between a minus and a plus
  button in one border ([forms.md](forms.md#forms-a-number-with-its-buttons)).
- `Grid cols=3 gap=8` lays the lines under it in columns; `List` is a column of rows; `Image "url"` a picture;
  `Avatar "Maya Reyes"` a round mark with initials; `Pages` a swiped row of pages.
- `Calendar @day marks=["2026-03-04"]` is a month on the page with a dot under each day listed (records
  `{date, label}`: a short text under it); `Barcode "text" symbology=qrCode` draws a QR code of the text
  (`code128`, `ean13`: bars).
- An app window is `App` with a `Sidebar` (the rail), a `Main` (the content) and any `Pane` (an inspector). In
  the sidebar write a row per item (`selected={…}` with a `selected.fill=` for the chosen one) and a `Footer`
  (pinned at its end) ([navigation.md](navigation.md#navigation-a-sidebar)). A
  website is a `Page` of `Nav`, `Section` and `Footer` bands. Over the page: `Dialog#id`, `Sheet#id`, `Drawer#id`,
  `Menu#id`, written after the page at the margin with their lines under them; `open id` shows one, `close` closes
  it:

```notation width=1280 expands
state tab="home"
state name=""
App
  Sidebar w=72
    IconButton "home" selected={tab == "home"} onTap={tab="home"}
  Main
    Button "New" onTap={open create}
  Pane w=280 hide=tablet
    Text.heading "Details"
Dialog#create "New project"
  Input "Name" @name
```

- Page frames and overlays ({{pageWords}}) are on [navigation.md](navigation.md).

## Words every line takes

{{universal}}

## Sizes and alignment

A size is worked out: in a Column a child is as wide as the column and as tall as its content; in a Row a child is as
big as its content. Write a size only where the design needs one.

- `w`, `h`: a number (fixed), `fill` (the room the parent gives), `hug` (the content's size). `grow` on a child of a
  Row or Column takes the room left (shared by every child with `grow`).
- `pad`: one number, or `[left,top,right,bottom]`. `gap`: the room between children. `margin` as `pad`.
- `maxWidth=720` (also `minWidth`, `minHeight`, `maxHeight`) bounds a size.
- On a Row, Column or Stack: `center` is across the page and `middle` down it. Along a Row or Column: `start`,
  `end`, `between`, `around`, `evenly`. Across it: `top`, `bottom`, `left`, `right`, `stretch`.
- `scroll` makes a Column scroll (a Row: sideways).
- Controls in a Row share a height: leave `h` off them all (an Input, a Select, a Button, an IconButton hug to one
  step), or give each the same `h`. A height on one alone makes the row uneven, and the render says so.

```notation
Row gap=8
  Input hint=Message grow
  IconButton "send"
```

```notation
Row gap=8
  Column w=120 h=40 fill=#FFE5E7EB
  Column h=40 grow fill=#FFDBEAFE
```

```notation
Row gap=8 between
  Text.strong "Total"
  Text "$24"
```

Every layout key is on [layout.md](layout.md).

## State

`state name=value` at the margin, before the tree, declares a variable; its type is its value's. A type the value
does not say is written after a colon: `state price:decimal=0`. A value worked out from others is a formula
variable, kept up to date: `state total:decimal={price * qty}`. `saved` keeps a value on the device across reloads.
Types: {{variableTypes}} (`boolean`, not `bool`; a component's `param` is typed in Flutter's names).

- `{name}` in a string, and `key={expression}` on any key, follow the state.
- `@name` keeps a control's value in a variable, both ways: `Slider @volume`, `Input "Email" @email`; any other
  property it binds is named (`selected=@picked`), and a control with two ends takes two (`Slider @low @high`). A
  bound variable is declared by a `state` line.
- An action sets a variable: `onTap={count=count+1}`.

```notation
state price=2.5
state qty:decimal=1
state total:decimal={price * qty}
Column gap=8
  Text "Total: {total}"
  Slider @qty
```

## Formulas

Inside `{…}`: `+ - * / %`, `== != < <= > >=`, `&& || !`, `cond ? a : b`; text in `"double"` or `'single'`
quotes; lists `[1,2]`, fields `a.b`, items `list[0]`; a function of one argument `x => x.price`. Lists never change
in place: set the variable to a new list (`cart=append(cart,item)`). The functions, by group (each with its
signature on [state.md](state.md#state-functions)):

{{functionNames}}

## Events and actions

`on<Event>={actions}` on any line. Inside the braces, `result` is what the event carries (a control's new value,
where a tap landed). The events of the core and the controls:

{{coreEvents}}

Every other trigger is `on` and its name with a capital (`onDragEnd`, `onScroll`, `onEnterViewport`); a trigger's
fields go in parentheses before the `=`: `onKeyDown(key=Enter)={…}`. All are on [events.md](events.md).

Actions, `;` between them. The verbs:

{{verbs}}

Any other action is its type and its fields by name: `animate node=hero command=forward`,
`scrollTo node=faq alignment=0`. Every action type and its fields are on [events.md](events.md).

```notation
Column w=40 h=40 onKeyDown(key=Enter)={emit go} onLongPress={toast "Held"}
```

A screen's timers, shortcuts and other reactions are lines of their own, after the tree (`mod` is Ctrl, or ⌘ on a
Mac); `on load={…}` runs when the screen opens:

```notation
state count=0
Text "{count}"
every 1s onTick={count=count+1}
key mod+k onPress={count=0}
on load={count=1}
```

## Lists and conditions

`each item in list` repeats the lines under it once per element; inside, `{item.name}` reads the element and
`index` its place. `if expression` shows the lines under it while it holds; `else` after it, the others.

```notation
state rows=[{"name":"Ada","done":false},{"name":"Lin","done":true}]
state tab="all"
Column gap=8
  each item in rows
    Text "{item.name}"
  if tab == "all"
    Text "Everything"
  else
    Text "Some"
```

A control bound to a field of the element changes that element: `Checkbox @row.done` under `each row in
rows`. Under a `ListView` or `GridView` line of its own, an `each` repeats inside that list, whose keys (height,
direction) are on its line. A table of records is a `Table`; tables, grids, paging and reordering are on
[lists.md](lists.md).

## Pages at other widths

Write the page once, for its width. A key with a condition before it holds only at that size:
`phone.pad=16`, `tablet.gap=8`, `max899.hidden`. `hide=phone` leaves a node out on a phone; `show=phone` shows it
only there.

{{mediaSizes}}

```notation
Column pad=48 phone.pad=16
  Text "Wide" phone.size=14 hide=tablet
```

A part whose lines differ at a width writes them in a block under it, after its own lines: `at phone`, the lines
under it the part's children there, `...#links` one of its own lines placed again (a design at a width, on
[responsive.md](responsive.md)).

A page expanded at a desktop's width gets rules for a tablet and a phone of its own (reflow: bands wrap, an app's
window drops its side panes); a line with its own rules, a Row of a list or of a toolbar, and a line written `keep`
are left as written. A component's own rules (its root's `tablet.w=64`) hold where it is called, unless the call
writes its width. Bounds in pixels (`min700`, `max899`), breakpoints (`minTablet`), orientation (`portrait`),
combined conditions and what reflow does are on [responsive.md](responsive.md).

## Hover, press, focus

A state's name before a key holds while the line is in that state: `hovered.fill=#FFE5E7EB`, `pressed.opacity=0.8`,
`focused.border=#FF2563EB`, `selected.fill=…` (with `selected={…}`), `disabled.opacity=0.4` (with `enabled={…}`). A
line inside follows its state by its id: `card.hovered.color=…`.

```notation
Column#card pad=12 fill=#FFFFFFFF radius=8 hovered.fill=#FFF3F4F6 pressed.opacity=0.8 onTap={emit open}
  Text "Open" card.hovered.color=#FF2563EB
```

More on [responsive.md](responsive.md#responsive-states); focus and the keyboard on [interaction.md](interaction.md).

## Records under a line

What is an ordered list in the document is lines under the node, one record a line, in the grammar of a line: a
`customPaint` line and its draw ops ([paint.md](paint.md)), `animation#id` lines with their `track` lines, and
`transition` lines ([animation.md](animation.md)). `animate=fadeIn` says a common entrance in a word.

```notation
box w=40 h=40
  customPaint viewBox=[40,40]
    circle c=[20,20] radius=16 fill=#FF2563EB
  transition property=opacity duration=200 curve=easeOut
```

A print uses three more forms a writer rarely needs: `key=null` (no such field, though the line would give one),
`slot name` (a line under it fills that slot) and `type=Name` (a design system's component a notation word shadows):
[document.md](document.md).

## The references

Open a page when the UI needs what it holds. Every name, A to Z, is in [index.md](index.md). A site's
`site.json` (its pages, shared variables, theme) is on [site.md](site.md).

{{references}}
