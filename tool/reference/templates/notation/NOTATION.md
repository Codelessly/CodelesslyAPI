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
  Image's URL. A second string is the Input's hint. `{name}` inside a string shows a value: `"Total: {total}"`.
- **`key=value`** sets a field. The key is a short word (`gap`, `pad`, `w`, `h`, `fill`, `radius`) or the field's own
  name in the API (`letterSpacing`, `squeezable`, `crossAxisCount`). A field inside a record is a dotted key
  (`pan.axis=horizontal`, `fills[0].color=#FF2563EB`); the full path from the node always reads too (`layout.x=10`,
  `props.style.height=1.2`). Each word page gives every key of its words.
- **Values**: a number (`12`, `0.5`), a bare word (an enum's value `center`, a color `#FF2563EB`, `true`), a quoted
  string (`"Two words"`), JSON for a list or a map (`items=["S","M","L"]`), or `{expression}` for a value that
  follows the state (`visible={count > 0}`). Colors are `#AARRGGBB`. The docs of the keys quote the JSON's
  expressions: `${name}` there is `{name}` here, and `${= formula}` is `{formula}`.
- **`on<Event>={actions}`** runs actions on an event, `;` between them.
- **A bare word** after the text is a flag: `grow`, `hidden`, `scroll`, `center`.

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
- `Grid cols=3 gap=8` lays the lines under it in columns; `List` is a column of rows; `Image "url"` a picture;
  `Avatar "Maya Reyes"` a round mark with initials; `Pages` a swiped row of pages.
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
Types: {{variableTypes}}.

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

A screen's timers and shortcuts are lines of their own, after the tree:

```notation
state count=0
Text "{count}"
every 1s onTick={count=count+1}
key mod+k onPress={count=0}
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
rows`. Tables, grids, paging and reordering are on [lists.md](lists.md).

## Pages at other widths

Write the page once, for its width. A key with a condition before it holds only at that size:
`phone.pad=16`, `tablet.gap=8`, `max899.hidden`. `hide=phone` leaves a node out on a phone; `show=phone` shows it
only there.

{{mediaSizes}}

```notation
Column pad=48 phone.pad=16
  Text "Wide" phone.size=14 hide=tablet
```

Bounds in pixels (`min700`, `max899`), breakpoints (`minTablet`), orientation (`portrait`) and combined conditions
are on [responsive.md](responsive.md).

## The references

Open a page when the UI needs what it holds. Every name, A to Z, is in [index.md](index.md).

{{references}}
