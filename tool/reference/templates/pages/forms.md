# Buttons, forms and inputs

## When to use

Buttons, text fields, checkboxes, switches, radios, sliders, dropdowns, segmented buttons, date and time pickers,
chips and signatures: every control's props, **how to style each one (in one place, below)**, two-way binding to a
variable, validation and error states, focus and the keyboard.

## Minimal example

An email field stored in a variable on every change, an error shown after a failed send, and a thank-you after a
good one:

{{example:form}}

## Reference

Every control's props, then the models that style them ([InputDecoration](@type-InputDecoration),
[InputBorder](@type-InputBorder), [ButtonStyle](@type-ButtonStyle)...), then the input triggers.

{{reference}}

## Patterns

### Styling the controls, in one place

| Control | Its look | Where |
|---|---|---|
| `textField` | label, hint, helper and error texts and their styles; border (`"border": {"type": "outline", "borderSide": {"color": ..., "width": 1}, "borderRadius": 8}`), `enabledBorder`, `focusedBorder`, `errorBorder`, `focusedErrorBorder`; `fillColor` + `filled`; `contentPadding`; `prefixIcon` / `suffixIcon`, `prefixText` / `suffixText` | `props.decoration` ([InputDecoration](@type-InputDecoration), [InputBorder](@type-InputBorder), [InputIcon](@type-InputIcon)) |
| `textField` | the typed text's style (`style`), alignment, the caret (`cursorColor`, `showCursor`), the focus ring (`focusRingColor`, `focusRingWidth`) | `props` ([textField](@node-textField)) |
| buttons | `backgroundColor`, `foregroundColor`, `textStyle` (the label's size and weight), `shape` (`{"type": "roundedRectangle", "borderRadius": 10}`), `side` (border), `padding`, `elevation` | `props.style` ([ButtonStyle](@type-ButtonStyle)) |
| `checkbox` | `activeColor`, `checkColor`, `fillColor`, `side` / `activeSide` (the box's border), `borderRadius`, `compact` | `props` ([checkbox](@node-checkbox)) |
| `switch` | `activeTrackColor`, `inactiveTrackColor`, `activeThumbColor`, `inactiveThumbColor`, `fillTrack`, `thumbInset`, `trackOutlineWidth`, `trackRadius` | `props` ([switch](@node-switch)) |
| `radio`, `slider`, `dropdown`, `segmentedButton` | their colours, track and thumb shapes | `props` ([radio](@node-radio), [slider](@node-slider), [dropdown](@node-dropdown), [segmentedButton](@node-segmentedButton)) |
| a labelled row | a `row` holding the control (with `"ignorePointer": true` and its value bound) and a text, with the row's `click` reaction | [a labelled checkbox](@forms-a-labelled-checkbox-or-switch) |

Every colour there may be a theme colour's name; every text style may name a theme style. An outlined or filled
field that sets no `contentPadding` (nor a `layout.padding`) takes Flutter's default, 12 px at the sides, which
keeps its text and label off the border; set `contentPadding` for another.

### A text field bound to a variable (two-way)

Bind its `props.initialValue` to the variable: `"bind": {"props.initialValue": "${query}"}`. Typing sets the
variable (its `changed` reaction also runs), and setting the variable elsewhere (a clear button, a stepper,
`--set`) changes the text, keeping the caret, as a `TextEditingController` held in state. The other inputs show
their bound value prop (`"bind": {"props.value": "${agree}"}` for a checkbox, switch, slider or dropdown,
`props.selected` for a segmented button, `props.groupValue` for radios) and report a change through `changed`:
store `${result}` in the same variable and the control follows it.

### Validation and an error state

As Flutter's `TextFormField` and `Form`:

- A field's `validator` is Flutter's `validator: (value) => ...`: an expression that reads the typed text as
  `value` and gives the error to show under the field, or `''` when it is valid:
  `"validator": "${= trim(value) == '' ? 'Enter your name.' : ''}"` (in `props`, not `bind`: it runs on the text
  each time the field checks itself).
- `autovalidateMode` says when a field checks itself (Flutter's `AutovalidateMode`): `disabled` (default: only
  when its form is validated), `onUnfocus` (when the focus leaves it: validate on blur), `onUserInteraction` (as
  it is typed in, once it has been), `onUserInteractionIfError` (as it is typed in, while it shows an error: the
  error clears as soon as it is fixed), `always`. An error stays until the field checks itself again.
- A node with `"form": {"autovalidateMode": ...}` is Flutter's `Form` around the fields inside it: the mode applies
  to all of them, and its nodes read `${form.valid}` (every field passes now) and `${form.errors}` (the errors the
  fields show, top to bottom: `{field, label, message}`) for a summary.
- `{"type": "validate", "node": "<form>"}` is `FormState.validate()`: every field of the form shows its error,
  the first invalid one takes the focus, and `${result}` is whether all are valid, for an `if` that submits.

An error can also come from anywhere else: bind `props.decoration.errorText` (an empty text shows none); the
validator's error, when it shows one, wins. Give a field that may show an error a hug height (`{"hug": 56}`): it
grows by the error line, and the form with it; a fixed height keeps the field that tall. `inputFormatter` applies
only `{"type": "regex", "pattern": ..., "allow": true}`. A form submitted to a service: `submitForm`
([data](@page-data)).

A contact form validated on blur and on send, with a summary of the errors above it, a radio group and a thank-you
that replaces the form:

{{example:form_validated}}

### A radio group

Flutter's `RadioGroup`: give the node around the radios `"radioGroup": {"groupValue": ...}`, bind its
`radioGroup.groupValue` to the variable that keeps the choice, and store `${result}` in its `changed` reaction. Each
`radio` inside sets only its `value`: it is on when that is the group's value, and choosing it runs the group's
`changed` (and its own). See `budget` in the form above.

### A stepper around a field

Two icon buttons that `setVariable` with `"op": "add"` / `"subtract"` on a number, and a field bound two-way to the
same variable. Keep the last valid value in a second variable when the typed text may be invalid.

### A clear button in the field

Its `decoration.suffixIcon` with a tap reaction (`actions` is a list of reactions, as a node's), shown only while
there is text by binding the icon:

```json
"search": {"type": "textField", "layout": {"width": {"fill": 280}, "height": 44},
  "bind": {"props.initialValue": "${query}", "props.decoration.suffixIcon.icon": "${= query == '' ? '' : 'close'}"},
  "props": {"decoration": {"hintText": "Search dishes", "prefixIcon": {"icon": "search", "size": 18}, "suffixIcon": {"icon": "close", "size": 18,
    "actions": [{"trigger": {"type": "click"}, "actions": [{"type": "setVariable", "variable": "query", "value": ""}]}]}}}}
```

### A labelled checkbox or switch

The whole row toggles: the control ignores the pointer and shows the variable; the row's reaction toggles it. A tap
on a control inside a tappable row otherwise runs the control's own reaction only (the innermost wins).

```json
"agreeRow": {"type": "row", "children": ["agreeBox", "agreeText"], "props": {"spacing": 8},
  "layout": {"width": {"hug": 240}, "height": 40},
  "actions": [{"trigger": {"type": "click"}, "actions": [{"type": "setVariable", "variable": "agree", "op": "toggle"}]}]},
"agreeBox": {"type": "checkbox", "ignorePointer": true, "layout": {"width": 24, "height": 24}, "bind": {"props.value": "${agree}"}},
"agreeText": {"type": "text", "props": {"text": "I agree", "style": {"fontSize": 15, "color": "#FF111827"}},
  "layout": {"width": {"hug": 60}, "height": {"hug": 20}}}
```

### Buttons

Buttons (`filledButton`, `elevatedButton`, `outlinedButton`, `textButton`, `iconButton`) take `label`, `icon` and
`style`. With no layout they hug: 28 high, padded, the label 12 px unless `style.textStyle.fontSize` says otherwise.
`"loading": true` (bound to a variable an action sets while it runs) shows a spinner in place of the icon and ignores
taps. For full control of a button's look (two lines, an icon after the label), use a `row` with a decoration, padding, text
children, a `click` reaction and [hover and pressed states](@interaction-hover-press-and-other-states).

### Add and remove items (a list editor)

Add: `setVariable` on the list with `"op": "add"` (appends; a list value appends each item) and
`"value": "${= object('name', draft, 'done', false)}"`, then clear the draft; guard it with the action's `when` (or
an `if`) on the draft not being empty. Remove: in the item template, `"op": "removeAt"` with `"index": "${index}"`.
Change one item: `"op": "update"` with `index`, or a formula (`${= updateWhere(habits, 'id', item.id, h => set(h,
'done', !h.done))}`). Give items an id (`newId('habit')`) when they can be reordered or removed.

### Focus and the keyboard

`focus` moves the focus to a field (or away), `editText` changes its text or selection. `submitted` fires on the
keyboard's done key; `textInputAction` picks the key. A canvas's `keyDown` reaction (`{"trigger": {"type":
"keyDown", "key": "ArrowRight"}, ...}`) runs while no text field has the focus: arrow keys between tabs, Escape to
close. The render command types with `--type <id>=<text>` (it replaces the text) and presses keys with `--key`
(after `--unfocus`).

## Pitfalls

- A button's text is `label`, not `text`; its colours are in `style`, not `decoration`.
- An input does nothing with its value until a `changed` reaction stores it, or its value prop is bound.
- `${result}` in a `changed` chain is the new value until an action that gives a value replaces it; `setVariable`
  does not.
- Every action key is written flat in the action; a misspelled one is dropped (`unknown_action_key`).
- A `validator` reads the field's text as `value`, not the variable the field is bound to; it goes in `props`, not
  `bind`.
- With `autovalidateMode` `disabled` (the default) a validator shows nothing until its form is validated: give the
  form, or the field, a mode, or run `validate` on send.

## See also

[State](@page-state) (variables, computed variables) · [reactions](@interaction-reactions) · [lists](@page-lists)
(an editable list) · [data](@page-data) (`submitForm`, storage).
