# Events and actions

Every event (trigger) a line can react to, with its fields, and every action, with its fields and its verb. Open
it when a UI reacts to more than a tap and a change, or an action needs a field the verbs do not say.

## An event

`on<Event>={actions}` on any line. The event is the trigger's name with `on` and a capital (`onLongPress`,
`onDragEnd`), except the notation's own names: `onTap` (click), `onChange` (changed), `onRightClick`, `onHover`
(cursorEnter), `onHoverMove` (hover), `onFocus`, `onBlur`, `onSubmit`. A trigger's fields go in parentheses,
by name, `,` between them. `result` in the actions is what the event carries (its doc says what).

```notation
Column w=40 h=40 onKeyDown(key=Enter)={emit go} onEnterViewport(visibleFraction=0.5)={emit seen}
```

The screen's timers and keys are lines of their own after the tree: `every 1s onTick={…}` (a `timer`),
`key mod+k onPress={…}` (a `keyDown` of the screen); `when cond` after the interval or key runs it only while
`cond` holds. Any other reaction of the screen is an `on` line: `on`, the trigger's name, its fields in
parentheses, `=` and the actions: `on load={…}` when the screen opens, `on backPressed={…}` for the system's back,
`on valueChanged(variable=draft)={…}` when a variable changes.

```notation
state step=0
state saved=[]
Text "Step {step}"
every 1s onTick={step=step+1}
key mod+k onPress={step=0}
on load={saved=coalesce(storage.saved, [])}
on backPressed(when={step > 0})={step=step-1}
on valueChanged(variable=step)={saved=append(saved,step)}
```

### Trigger fields

Every trigger takes these fields (each one's doc says which triggers read it):

{{triggerFields}}

### Events

{{triggers}}

## Actions

Actions are separated by `;`. A verb says a common action in a word; any action is its type and its fields by
name, each value as on a line (a number, a word, `"text"` in which `{x}` reads a value, `{expression}`, JSON).
A field that holds actions takes them in braces: `confirm "Remove it?" then {close}`, `onError={toast "Failed"}`.
`cond ? a : b` chooses between actions (a branch may be `{a; b}`, or empty; `cond ? a` alone does nothing when it
does not hold). `if` is a line of the tree, not a verb: `onTap={missing ? {open naming} : {open account}}`, not
`onTap={if missing {…} else {…}}` (the action by its type is `if condition={missing} then={…} else={…}`). A verb
says only the fields its row shows; any other is the action by its type: `showToast message="Saved" style=success`
(`toast "Saved" style=success` is said with that line). A number of an action is a number: `delay ms={…}` is the
delay's `duration={…}`, and a value worked out given to another number field is said. `close` closes the overlay the action
runs in; a second `close` in the same chain closes the one under it (`close; close` from a dialog over a dialog
closes both).

An expression is written the same everywhere: braces around it are the expression's (`when {length(sel) > 0}` is
`when length(sel) > 0`, `n={n + 1}` in an action is `n=n + 1`), and a map is a literal with keys (`m={a: 1}`, `{}`).
Inside a JSON value (`params={"id":"${msg.id}"}`) a value is written `${…}`: the `{x}` of a text does not reach
into JSON.

`confirm` takes the question, then a detail line, the buttons' words and `danger` before `then`: `confirm "Delete
it?" "It cannot be restored." ok="Delete" cancel="Keep" danger then {…} else {…}`; the action's own field names
read there too (`title="…"`, `message="…"`, `confirmLabel="…"`, `cancelLabel="…"`, `destructive=true`).

A click's `result` holds `x`, `y`, `globalX`, `globalY` and the keys held: `shift`, `alt`, `meta` (Control or
Command, the platform's "add to" key), `ctrl` (Control). A drag's (every move) holds `dx`, `dy` (the move since the
last event), `x`, `y`, `globalX`, `globalY`, `startX`, `startY`, `pointerCount`; a drag's end holds `vx`, `vy` (the
speed). `x`, `y`, `startX` and `startY` are in the node where it is now, `globalX` and `globalY` on the screen: a
node that moves with the pointer (a drawer pulled open) keeps `x` near `startX`, and how far it has been dragged is
each move's `dx` added up (`onDrag={pull=pull + result.dx}`). A text field's change is the text itself (`result`, not `result.text`). A press that reads the keys held
(a list whose rows are chosen this way needs none of it: `selectable`,
[lists.md](lists.md#lists-a-list-chosen-from-and-swiped)):

```notation
state rows=[{"id":"a","name":"Ada"},{"id":"b","name":"Lin"}]
state chosen=[]
Column gap=8
  each item in rows
    Text "{item.name}" onTap={result.meta ? chosen=append(chosen,item.id) : chosen=[item.id]}
    Text "Open" onTap={result.shift ? emit openBeside : emit open}
```

{{verbs}}

```notation
Column w=40 h=40 onTap={animate node=hero command=forward; scrollTo node=faq alignment=0}
```

### Fields every action takes

{{actionCommonFields}}

Fields that hold actions: {{chainKeys}}.

### Every action

{{actions}}
