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
parentheses, `=` and the actions: `on load={…}` when the screen opens, `on backPressed={…}` for the system's back.

```notation
state step=0
state saved=[]
Text "Step {step}"
every 1s onTick={step=step+1}
key mod+k onPress={step=0}
on load={saved=coalesce(storage.saved, [])}
on backPressed(when={step > 0})={step=step-1}
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
`cond ? a : b` chooses between actions (a branch may be `{a; b}`, or empty). `close` closes the overlay the action
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
speed). A text field's change is the text itself (`result`, not `result.text`).

{{verbs}}

```notation
Column w=40 h=40 onTap={animate node=hero command=forward; scrollTo node=faq alignment=0}
```

### Fields every action takes

{{actionCommonFields}}

Fields that hold actions: {{chainKeys}}.

### Every action

{{actions}}
