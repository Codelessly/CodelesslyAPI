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

Every colour there may be a theme colour's name; every text style may name a theme style. An outlined field needs
`"contentPadding": [14, 16, 14, 16]` in its decoration to keep its text off the border.

### A text field bound to a variable (two-way)

Bind its `props.initialValue` to the variable: `"bind": {"props.initialValue": "${query}"}`. Typing sets the
variable (its `changed` reaction also runs), and setting the variable elsewhere (a clear button, a stepper,
`--set`) changes the text, keeping the caret, as a `TextEditingController` held in state. The other inputs show
their bound value prop (`"bind": {"props.value": "${agree}"}` for a checkbox, switch, slider or dropdown,
`props.selected` for a segmented button, `props.groupValue` for radios) and report a change through `changed`:
store `${result}` in the same variable and the control follows it.

### Validation and an error state

Keep the values in variables, set a `tried` flag on submit, and show errors from computed variables: bind
`props.decoration.errorText` (the field turns to its `errorBorder` and shows the text) or a separate text's
`visible`. An empty `errorText` shows no error. The `validator` prop is declared but not applied by the SDK; `inputFormatter` applies only
`{"type": "regex", "pattern": ..., "allow": true}`.

```json
"variables": {"page_variables": [
  {"name": "seats", "type": "text", "value": "10"},
  {"name": "seatsError", "type": "text", "formula": "seats == '' || number(seats) < 1 ? 'Enter at least 1 seat.' : ''"}
]}
```

```json
"seatsField": {"type": "textField", "layout": {"width": 160, "height": 72},
  "bind": {"props.initialValue": "${seats}", "props.decoration.errorText": "${seatsError}"},
  "props": {"keyboardType": "number", "decoration": {"labelText": "Seats",
    "border": {"type": "outline", "borderRadius": 8}, "errorBorder": {"type": "outline", "borderRadius": 8, "borderSide": {"color": "#FFDC2626"}}}}}
```

Give a field that may show an error a hug height (`{"hug": 56}`): it grows by the error line, and the form with it;
a fixed height keeps the field that tall. A form submitted to a service: `submitForm` ([data](@page-data)).

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

Buttons (`filledButton`, `elevatedButton`, `outlinedButton`, `textButton`, `iconButton`) take `label` and `style`.
Their label text is 12 px unless `style.textStyle.fontSize` says otherwise. Give buttons a fixed or fill width. For
full control of a button's look (two lines, an icon after the label), use a `row` with a decoration, padding, text
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
- A hugging button is only as wide as its label, without padding.
- An input does nothing with its value until a `changed` reaction stores it, or its value prop is bound.
- `${result}` in a `changed` chain is the new value until an action that gives a value replaces it; `setVariable`
  does not.
- Every action key is written flat in the action; a misspelled one is dropped (`unknown_action_key`).
- The `validator` prop is not applied: validate with variables.
- An outlined border without `contentPadding` puts the text on the border.

## See also

[State](@page-state) (variables, computed variables) · [reactions](@interaction-reactions) · [lists](@page-lists)
(an editable list) · [data](@page-data) (`submitForm`, storage).
