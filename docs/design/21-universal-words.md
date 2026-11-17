# 21. Universal words: one table, one implementation

2026-11-17. Decided in the vocabulary loop's second review (SDK `tool/vocabulary/JOURNAL.md`, Review 2, D6 and D7;
D8 and D9 are built with them and are in sections 7 and 8). Built in `lib/src/core/notation/universal.dart` (the
table) and `notation.dart` (where a line is read); tests in `test/notation_universal_test.dart`; the SDK's
`tool/notation/vocabulary_words.dart` counts them. Notes 19 (the open vocabulary) and 20 (defined words) are what
this extends.

## 1. Why

Vocabulary has two axes. Types are the nouns, and since note 20 a missing noun is a few lines of data. Parameters,
flags and events are adjectives and verbs, and models apply the same ones to *any* noun: in the first forty answers
`color` is written on 12 types, `size` on 10, `icon` on 6, `onReorder` and `onSelect` on 6 each, and `selected`,
`disabled`, `readonly`, `tooltip`, `required`, `removable`, `selectable`, `sortable`, `autofocus` on several. A model
does not think "a Chip has no color"; it thinks every thing has a colour, a size, an icon and a selected state, and
every list can be reordered and chosen from. Fixing each (type, word) pair on its own is the mistake of building each
tail type in Dart, one axis over.

A **universal word** is a parameter, flag or event that means the same on every line. It is written once in a table,
implemented once where a line is read, and every line has it: core types, a design system's components (where the
component has no parameter of that name) and defined words (without the definition naming it).

## 2. The table

`notationUniversal` (`universal.dart`) lists every word every line understands, each with its kind and meaning, in
two groups:

- **The grammar's own** (they predate this note): the layout and look words (`w`, `h`, `grow`, `pad`, `gap`, `fill`,
  `radius`, `border` and its sides, `maxw`, `scroll`, `clip`, `sticky`, `animate` with `duration`, `delay`,
  `stagger`), place and alignment (`center`, `middle`, `start`, `end`, `between`, `around`, `evenly`, `top`,
  `bottom`, `left`, `right`, `stretch`), `visible`, `hidden`, `hide`, `show`, `id`, `drag`, `drop`, `menu`,
  `preview`, `tooltip`, `selected`, and the pointer events (`onTap`, `onLongPress`, `onDoubleTap`, `onRightClick`,
  `onHover`, `onDrop`, the four swipes).
- **The universal words** (this note): `color`, `size`, `icon`, `disabled`/`enabled`, `readonly`, `required`,
  `autofocus`; on a list, `reorder` (also `sortable`, `reorderable`) with `onReorder` and `handle`, `selectable`
  with `onSelect`, and `removable` with `onRemove` (also `onDelete`).

The table is the one list: the parser asks it what a word is, a definition passes a use's universal words to its
root by it (it replaces note 20's `definedPassThrough`), and the SDK's counting tool resolves by it.

## 3. What wins

1. **A type's own word of that name.** `Avatar size=large` on a design system whose Avatar takes `size` is that
   component's; `Rating readOnly`; a Chip of Cards with `icon`; a Select's `icon` (its arrow). A definition that names
   the word in its signature has it as its own: Cards' `Timeline#events` names `selected` (the index of the entry
   lit, as writers wrote it, `current=` aliased to it), so on a Timeline `selected` is that index, not the root's
   selected state; a Banner's `icon` (since D30) is its glyph.
2. **An alias** that reads it as one of the type's own (`disabled` is `enabled={!…}` on a type with `enabled`;
   `readonly` is `readOnly` on a text field and a slider).
3. **The universal meaning**, below.
4. Where a universal word has no honest meaning on a kind of line (a `size` on a Column), it is what it was: left out
   and recorded unknown with the open vocabulary, an issue without it. The table says, per word, the kinds of line it
   is universal on.

## 4. Each word

The kinds of line: a **container** (Column, Row, Stack, Box, Card, Grid, a stand-in, a definition's root column), a
**text** (Text, Heading, Link), an **icon** (Icon, IconButton), a **control** (Button, Input, Select, Toggle,
Checkbox, Radio, Slider, a chip, Progress, Ring, Avatar), a **component** of the design system.

| word | container | text | icon | control | component |
|---|---|---|---|---|---|
| `color` | the ink of the texts and icons written under it that set none (inherited while the lines are read: nearer wins) | its ink | its ink | its accent: a toggle's track, a checkbox's or radio's fill, a slider's track and thumb, a bar's or ring's fill, a choice or filter chip's selected tint; its ink where it carries text (a plain chip's label and icon, an input's typed text, a ghost or outline button's label); a filled button's fill, or its label when the line also writes `fill=` | its own `color`, else not universal |
| `size` | not universal | `small`, `medium`, `large` (also `xs`, `xl`) are the theme's text sizes (caption, small, body, title, the title's 1.5); a number is the font size, as before | 16, 20, 28 (14, 36): the icon button's scale | a step of the control scale (`xs` 24, `compact` 28, `small` 32, `medium` 36, `large` 44) as a button's height; a field's (an Input's, a Select's) height the same way; an Avatar 24/32/40/56/72; a Ring 32/48/64/96/128 across (a number is its width); a bar's thickness 3/4/8/12/16; a slider's track (2/2/4/6/8) and thumb (5/6/8/10/12); a chip's height 20/24/28/32/36; a number on an input is its text's size. Not universal on a toggle, a checkbox or a radio | its own `size`, else not universal |
| `icon` | not universal | not universal | it is its icon | a leading icon: a button's (its own), an input's (inside the field, before the text), a chip's (its avatar), a list tile's (its leading slot) | its own `icon`, else not universal |
| `selected` | the node's selected state: the theme's selected fill, announced selected | the selected state | the selected state | a chip is a choice chip and this is its value; a checkbox's or toggle's value; elsewhere the selected state | its own, else not universal |
| `disabled` (`enabled={!…}`) | it and everything in it take no pointer and no focus, its clicks do not run, and it is drawn at half strength (`states.disabled` over the `disabled` binding) | the same | the same | its own `enabled`; a control without one is put in its disabled state (the renderer's look for it) | its own `enabled`, else not universal |
| `readonly` | not universal | not universal | not universal | an input's and a slider's `readOnly`; another control shows its value and takes no input (`ignorePointer`: no pointer, no focus) | its own `readOnly`, else not universal |
| `tooltip` | the node's tooltip (also one that reads data: `tooltip="{n} left"`) | the same | the same | the same | the same |
| `required` | not universal | not universal | not universal | its label is marked (` *`); an input also checks it (its `validator`: empty is "Required"), with the rest of the form | its own, else not universal |
| `autofocus` | not universal | not universal | an icon button's | its own (`autofocus`) | its own |
| `hidden` | hidden (`hidden={cond}` hides while it holds) | the same | the same | the same | the same |

A definition's root is a line like any other: `StickyNote color=#FFB91C1C` with no `color` in its signature puts
`color=` on the body's root, which, a column, inks what is written in it.

### 4.1 On a list: reorder, select, remove

These go on the line whose lines come from an `each` (a Column, a Card, a Section, a Grid, a stand-in), or, for
`removable`, on any line.

- **`reorder`** (`sortable`, `reorderable`): the `each` directly under it is `each … reorder` (note 19's list
  reorder): rows are dragged into a new place and moved by Alt and the arrow keys, and the new order is written to
  the list's variable. `handle` (a flag, or `handle=icon`) drags them by their Handle line; without it, by a long
  press anywhere on a row. `onReorder={…}` runs after a move with `result` the list in its new order, and
  `result.from`, `result.to`, `result.item` as the list gives them. An `each` over a formula is reordered when the
  line has `onReorder`: the list is not written, and `result` is the formula's list moved (`move(list, result.from,
  result.to)`; the answer stores it). Under a Grid or across a Row nothing is reordered (the renderer reorders a list
  down a column only): the word is left out and recorded unknown, and the list is kept.
- **`selectable`** with `selected=@list` (the rows chosen, by their keys; else the line's own `<id>Selected`) and
  `onSelect={…}`: a tap on a row selects
  it alone, Ctrl or ⌘ adds or removes it, Shift takes the range from the last row chosen; Space and Enter on a
  focused row do the same with the same keys held, and the arrow keys move between rows (one Tab stop). Ctrl or ⌘ A
  selects every row while the page is not being typed in. The range runs from the last row tapped, also when that tap
  took it out with Ctrl (as a file list does). A row is in its selected state while its key (its `id`,
  else the element itself) is in the list, so it takes the theme's selected fill and is announced selected; each
  change is announced ("3 selected"). `onSelect` runs after each change with `result` the selection. It is compiled
  to the reactions the document already has (a click's `result.meta` and `result.shift`, the `selected` binding, a
  focus group, a key reaction on the list), so it works the same in every renderer of the document. A row that
  takes the tap itself (its own `onTap`; a design system's row that fires an event when tapped, a TableRow's or a
  ListRow's `onPressed`) never lets it through to the copy around it, so its own tap reaction chooses it first and
  then does what it does (a block's event carries no Ctrl or Shift: a tap there selects the row alone).
- **`removable`** with `onRemove={…}` (`onDelete`; either event alone implies it): a chip becomes an input chip whose
  × (or Delete, Backspace) fires it; on a box (a Row, a Column, a Card, a stand-in, a defined word's root) a small ×
  button, named "Remove", is added at its end, and on a ListTile in its trailing place when that is free; a design
  system's block that has a slot and no × of its own (a ListRow's trailing, a SectionHeader's actions) takes it at
  the end of its slot. On anything else (a TabBar's tabs are one list of labels) it is not universal.

A list word on a line with no `each` directly under it is left out and recorded unknown; the variable its
`selected=@name` names is still declared, so what reads it validates. `selectable` there is also said, with where it goes (a
`Card selectable` under the `each`, a `Row selectable` of fixed lines: it chooses among an `each`'s copies only).

Beside these, on a design system's block that does not have the word itself:

- `action="View all"` with `onAction={…}` on a block with a slot (a SectionHeader's actions) is a quiet button at
  the end of the slot (`action={…}` alone: a button labelled More that does that).
- `clearable` on a block with a clear of its own (a SearchBar's ×, its `onClear`) is what it does already.
- `disabled={cond}` (or a bare `disabled`) on a block whose own `disabled` is the list of its options that are off
  (ChoiceChips) is the whole block off, as `enabled={!cond}` is on a control: the node's disabled state. A list
  (`disabled=["18:30"]`) is still its own parameter.
- `live` is a Text's (and a block's that takes it: Cards' Banner reads its title and message out); on another line
  it is said, with the Text to put it on, or `announce` for the action that changes it.
- `size={…}` on an Input is its text's size, as a number is.

## 5. Recorded

A universal word applied where the type has no word of that name is recorded with the open vocabulary as a use of
kind `universal` (`of` the kind of word as written, `on` the type) and counted by the SDK's tool as `resolved:
universal`. A word reached through an alias counts as the alias (`readonly` is read as `readOnly`). On a defined
word, a use's universal word the signature does not name is recorded by the use when it goes on the root (the root's
kind of line takes it; a list's words only when the use says `reorder` or `selectable`); one the root cannot take is a
word the definition does not have, as before. The grammar's own words on a core type stay `core`.

On a type we do not have (a stand-in, D6) the parser records as universal each word of the line it applied, checked
against what it did rather than listed: a word of the table, or a property of the column the stand-in is, that it did
not leave out (no issue at its column, not one of the words it drops). What a stand-in does not honour stays unknown:
`@name` (the page's variable, declared like any a line binds, so that what reads it validates, but nothing keeps a
value in it), `size`,
`items`, `x` and `y`, its own events (`onChange`, `onSeek`), `duration` without `animate`, a list word with no `each`
under it, and every other word. Its strings are still counted as texts of a word we do not have.

With the vocabulary closed nothing is recorded, and every document is the same open or closed.

## 6. How a design system styles the states

Nothing is added to a design system. `selected` and `disabled` are states the document model already has: a node in
them takes its `states.selected` / `states.disabled` patch, the controls draw their own selected and disabled looks
from the theme's control tokens, and a box written `selected` takes the theme's `selectedFill` (as a NavItem does).
`color`, `size` and `icon` resolve to the theme's names and scales (a colour name of the palette stays a name with
`--named`; the sizes are the theme's text styles and control heights).

## 7. Input (D8)

Every unknown word of `Input` the text field can express is now read, by the alias table where the field already
has the word under another name and in the parser otherwise:

| written | read as |
|---|---|
| `clearable` | a × inside the field, after the text (its suffix icon), that clears it as typing would (`editText clear`: the variable it is bound to follows) |
| `maxlength=`, `maxLength=` (`maxChars`) | `maxLength`, with the field's character counter (the field 18 taller for it) |
| `readonly` | `readOnly` |
| `autofocus`, `required` | section 4 |
| `caps` (`uppercase`, `allcaps`), `caps=words` (`sentences`, `characters`, `none`) | `textCapitalization` |
| `multiline`, `autogrow`, `lines=`, `rows=` | `multiline` 3 to 6 lines, `autogrow` from one line to 6 (or to `lines=`); `rows=` is `lines=` |
| `center` (`right`) | the typed text's alignment |
| `onEnter` | `onSubmit` (the field submitted from the keyboard) |
| `onKeyDown` | a key pressed while the field has the focus (`result.key`; a bare `key` in its actions is read as `result.key`) |
| `onSaved` | `onBlur` (it lost focus after editing) |
| `value="…"` or `value={…}` beside `@name` | the text it starts with: a fixed text over the variable's, `value={…}` bound; the variable is still the one a change writes |
| `prefix=`, `suffix=` | the texts before and after the typed text, always shown (`kg`, `$`) |
| `error=`, `helper=` | as before (they were read already) |
| `fuzzy` | a recorded no-op with an issue: fuzzy matching belongs to the list that is filtered (`filter(items, x => fuzzy(x.name, q))`), not to the field |

## 8. A bare number where the text goes (D9)

`Footnote 1`, `CountUp 39`, `Badge 3`, `Text 2026`: a bare number in the text position is the text, on a core type, a
component (its first text parameter) and a stand-in; where a type's main thing is a value (`Progress 0.6`, `Slider
40`, `Ring 0.8`) it is the value, as before. On a defined word it fills the next string of the signature, or a
parameter named `value` when the strings are given; where the body reads it in an expression it is the number
(`{value*2}`), in a text its digits. So a signature names its positional value by its first string or by `value`:
note 20's grammar gap is closed with no new syntax. A bare *word* in the text position is still an issue when it
names a variable (`Text plan.name` says to write `"{plan.name}"`).

## 9. What the renderer needed

The universal words compile to what the document already has, with two general fixes in the SDK's renderer:

- A box whose bound interaction states change (`selected` or `disabled` from its binding) is re-applied even when its
  node is otherwise the same. Before, a list's row (the root of its item) that became selected kept its old press
  target: it was not announced selected, and its state style did not show until something else re-applied it.
- A node in its `disabled` state runs no pointer actions (`WidgetState.disabled` said so; before, a press target was
  only taken out of the focus order).

## 10. Not done

- `color`, `size` and `icon` on a component that has no parameter of that name: a component's look is its own
  document, and a call cannot reach into it. Left out, recorded unknown.
- `icon` on a text, a tab of a TabBar, a banner, a tree row: a text has no leading place, and the others are
  components or lists of labels.
- `size` on a toggle, a checkbox or a radio (the renderer draws them at one size); `readonly={…}` worked out on a
  control without a read-only of its own; `required` on a Select.
- Reordering a grid or a row (section 4.1).
- A selected row's fill is the theme's `selectedFill` across the whole row of the list, with no radius of its own.
- `removable` on a tab of a TabBar (its tabs are one list of labels) and on a design system's component with no
  slot.
- `live` on a line that is not a Text: the document has no live region but a text's (a block takes it only as its
  own parameter, as Cards' Banner does).
- Selecting by dragging a rectangle (a marquee), and Shift with the arrow keys extending the selection: the arrow
  keys move the focus; Shift with Space takes the range.
- Ctrl or ⌘ A selects the rows of every selectable list of the page at once (the key reaction cannot tell which
  list the focus is in).
