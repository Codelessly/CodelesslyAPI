# Interaction: reactions, states and gestures

## When to use

What a node does when it is tapped, hovered, pressed, dragged or swiped: reactions and every trigger, hover and
pressed styles (`states`), ink ripples, tooltips, letting taps through, drag and drop, values set by dragging
(`track`), swipe to dismiss, pan, pinch and rotate, keys, the clipboard and haptics.

## Minimal example

A button-like row that changes color while hovered and pressed, and while selected:

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
bindings: `"bind": {"selected": "${= tab == 'pricing'}"}` puts the node in its `selected` state, as Flutter's
`statesController` puts a button in `WidgetState.selected`. Buttons draw it themselves (a tinted fill, the primary
color as ink: tabs and toggles made of buttons need nothing more); on other nodes only a `states.selected` patch
shows it, so a bound `selected` with none changes nothing (`state_no_effect`). A chip's own selection is its prop,
`props.selected`. A selected outlined button in a look of its own (a filter or a delivery option):

```json
"bind": {"selected": "${= category == 'linen'}"},
"states": {"selected": {"linen": {"props": {"style": {"backgroundColor": "ink", "foregroundColor": "paper"}}}}}
```

`hovered` needs a
mouse: on touch screens it never happens, so do not hide anything behind it. Animate the change with
`transitions` ([animation](@page-animation)).

### A segmented toggle (monthly / annual)

Two labels in a row with a fill; each label's `selected` binds to the variable (`${= annual}` and
`${= !annual}`), its `states.selected` patches its fill and text color, and its click sets the variable. A
`switch` bound two-way to the same variable works as well.

### Drag and drop

`draggable` (`{"group": "card", "data": "${item.id}"}`) lets the node be picked up; a `dropTarget` that `accepts`
the group takes it, and its `drop` reaction reads the data as `${result.data}` (`${result}` is the whole drag: `data`,
`group`, `source`, `over`, `count`): `{"type": "setVariable", "variable": "cards", "value": "${= map(cards, c => c.id == result.data ? {id: c.id, title: c.title, col: 'done'} : c)}"}`. Reordering a list: the list's `reorder`
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
(`${= (tabIndex + 1) % 4}`), Escape closing a menu is one. A combination with Ctrl/Cmd or Alt (`"key": "Mod+K"`)
also runs while a field has the focus; a plain letter stays with the field. In the notation it is a line of its
own, `key mod+k onPress={open search}`, and `Text "Search" shortcut="mod+k"` shows the combination as the
platform writes it (Ctrl K, ⌘K).

### The keyboard: Tab, Enter, Space and the focus ring

Nothing to write: a node with a `click` reaction is a **Tab stop**, like the controls. Tab and Shift+Tab move the
focus through the page in reading order (rows from the top, left to right in a row; a node around other stops comes
before them), Enter and Space run the focused node's click, and the node shows the theme's focus ring (the
`focusBorder` color, just outside its box, with its corner radius) while the focus is on it **from the keyboard**:
a pointer or a touch never shows the ring. While it shows, the node is in its `focused` state, so a
`states.focused` patch styles it further (a menu row's fill). A screen reader gets one focusable button named by the
node's text, or by its `tooltip` when it has none (an icon).

What is **not** a stop:

- a node with no `click` reaction: `hover`, `longPress`, drags and the other triggers alone do not make one;
- `"focusable": false` on the node: the document's opt-out, for a row whose only action a button inside it repeats;
- a node that is `disabled` (a bound `disabled`), has `ignorePointer`, or sits inside a node that has: the labeled
  checkbox row (`ignorePointer` on the checkbox) is one stop, the row;
- a node that is not shown (`visible: false`, opacity 0), or whose every click reaction has a `when` that does not
  hold now (it joins the order when one does);
- a node that is itself a control: a text field or a button with a click reaction is one stop, the control.

A node with a click **around** other stops (a card with a button in it) stays a stop: its own action must stay
reachable. If that doubles what the button does, give the card `"focusable": false`.

### One Tab stop for a group: `focusGroup`

A menu, a tab list, a toolbar or a list of options is one stop, and the arrow keys move inside it. Put
`focusGroup` on the node around the items:

```json
"menu": {"type": "column", "focusGroup": {"typeAhead": true}, "children": ["open", "rename", "delete"]}
```

Tab enters the group at the item focused last (else the one whose `selected` is bound true, else the first) and
leaves to the next stop outside it. The arrows of `axis` (`vertical`: Up and Down; `horizontal`: Left and Right,
swapped under `textDirection: rtl`; `both`) move through the items that can take the focus, in reading order;
`wrap` (default true) goes from the last to the first; Home and End jump to the ends; with `typeAhead` a typed
letter jumps to the next item whose text starts with it (the same letter again goes on to the next). Enter and
Space press the focused item as anywhere. The items are whatever takes the focus inside: nodes with a click
reaction and controls; a control's own keys come first (a slider in a toolbar keeps its arrows).

## Pitfalls

- `hovered` never happens on touch screens.
- The innermost tappable node takes the tap; `ignorePointer` lets it through.
- A state patch names node ids inside the node; patching a node outside it does nothing.
- An interaction state's patch loses to a binding of the same field (bindings come after states).
- A misspelled trigger is `unknown_trigger`; a key it does not take is `unknown_trigger_key`.
- `tap_no_reaction` (render command): a `--tap` step hit a node with no reaction.
- Only a `click` reaction makes a node reachable by keyboard: an action that exists only on `hover`,
  `longPress` or `doubleTap` has no key.
- A focus ring that looks cut off: the node sits flush in a parent that clips. Give the parent padding (the ring
  is 1.5 px outside the node), or style `states.focused` instead.

## See also

[Forms](@page-forms) (inputs and their triggers) · [animation](@page-animation) (transitions on state changes) ·
[navigation](@page-navigation) · [state](@page-state) (what reactions change).
