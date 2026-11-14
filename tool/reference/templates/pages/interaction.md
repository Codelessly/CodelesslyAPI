# Interaction: reactions, states and gestures

## When to use

What a node does when it is tapped, hovered, pressed, dragged or swiped: reactions and every trigger, hover and
pressed styles (`states`), ink ripples, tooltips, letting taps through, drag and drop, values set by dragging
(`track`), swipe to dismiss, pan, pinch and rotate, keys, the clipboard and haptics.

## Minimal example

A button-like row that changes colour while hovered and pressed, and while selected:

{{example:states}}

## Reference

### Trigger fields

A trigger is `{"type": "<type>", ...these}`, or just the type as a string (`"click"`).

{{triggerFields}}

### Fields every action has

{{actionCommonFields}}

{{reference}}

## Patterns

### Reactions

A node's `actions` is a list of **reactions**: a trigger and the chain of actions it runs, in order.

- In a chain `${result}` starts as the trigger's event (where a click landed; a text field's text; a checkbox's
  value) and is replaced only by an action that gives a value (`callApi`, `openModal`'s closing value, `runScript`,
  `callFunction`, a cloud read); `setVariable`, `navigate`, `showToast`, `scrollTo` leave it as it was.
- A tap on a control (a checkbox, a switch, a button, a text field) inside a node with a `click` reaction runs the
  control's reaction only, as Flutter's gesture arena gives the tap to the innermost recognizer. To toggle from the
  whole row with one handler, give the control `"ignorePointer": true` and bind its value.
- Screen triggers (`load`, `valueChanged`, `timer`, `frame`, `keyDown`) go on the canvas.
- Every action also takes `enabled`, `nonBlocking` and `when` (run only while a predicate holds:
  `{"left": "${count}", "op": "greaterThan", "right": "5"}`; the ops are in [Conditions](@state-conditions)). A
  trigger's own `when` is a formula string.
- Write each action's fields flat in the action object; a misspelled key is dropped by the runtime and reported by
  validation (`unknown_action_key`).

### Hover, press and other states

`states` on a node changes it and its descendants while it is `hovered`, `pressed`, `focused`, `selected`,
`disabled` or `dragged`. Each state maps node ids (the node itself or nodes inside it) to a **patch**: partial node
JSON merged over that node (objects merge, other values replace, `null` removes). `selected` and `disabled` follow
bindings: `"bind": {"selected": "${= tab == 'pricing'}"}` puts the node in its `selected` state. `hovered` needs a
mouse: on touch screens it never happens, so do not hide anything behind it. Animate the change with
`transitions` ([animation](@page-animation)).

### A segmented toggle (monthly / annual)

Two labels in a row with a fill; each label's `selected` binds to the variable (`${= annual}` and
`${= !annual}`), its `states.selected` patches its fill and text colour, and its click sets the variable. A
`switch` bound two-way to the same variable works as well.

### Drag and drop

`draggable` (`{"group": "card", "data": "${item.id}"}`) lets the node be picked up; a `dropTarget` that `accepts`
the group takes it, and its `drop` reaction reads the data as `${result}`. Reordering a list: the list's `reorder`
settings with a `reorderHandle` in the item, and the `reorder` trigger.

### Values set by dragging, swiping, pinching

`track` sets a variable as the pointer moves along a line, arc or path (a custom slider, a dial). `dismissible`
swipes a node away (a list item; the `swipeAction` trigger). `pan` makes a node follow the pointer;
`transformGesture` pinches, pans and rotates with fling physics. The `drag` trigger reports `${result.dx}`,
`${result.dy}` per move and `dragEnd` the velocity, for game controls.

### Copy to the clipboard

`{"type": "copyToClipboard", "text": "${address}"}` (the key is `text`), then the chain goes on: a toast or a
"Copied" state after it. The render command copies in memory and lists what was copied in its report.

### Keys

A canvas's `keyDown` reaction (`{"trigger": {"type": "keyDown", "key": "ArrowRight"}, ...}`) runs while no text
field has the focus: arrow keys between tabs are two reactions that set the tab variable
(`${= (tabIndex + 1) % 4}`), Escape closing a menu is one.

## Pitfalls

- `hovered` never happens on touch screens.
- The innermost tappable node takes the tap; `ignorePointer` lets it through.
- A state patch names node ids inside the node; patching a node outside it does nothing.
- An interaction state's patch loses to a binding of the same field (bindings come after states).
- A misspelled trigger is `unknown_trigger`; a key it does not take is `unknown_trigger_key`.
- `tap_no_reaction` (render command): a `--tap` step hit a node with no reaction.

## See also

[Forms](@page-forms) (inputs and their triggers) · [animation](@page-animation) (transitions on state changes) ·
[navigation](@page-navigation) · [state](@page-state) (what reactions change).
