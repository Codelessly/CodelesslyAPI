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
`cond` holds.

### Trigger fields

Every trigger takes these fields (each one's doc says which triggers read it):

{{triggerFields}}

### Events

{{triggers}}

## Actions

Actions are separated by `;`. A verb says a common action in a word; any action is its type and its fields by
name, each value as on a line (a number, a word, `"text"` in which `{x}` reads a value, `{expression}`, JSON).
A field that holds actions takes them in braces: `confirm "Remove it?" then {close}`, `onError={toast "Failed"}`.
`cond ? a : b` chooses between actions (a branch may be `{a; b}`, or empty).

{{verbs}}

```notation
Column w=40 h=40 onTap={animate node=hero command=forward; scrollTo node=faq alignment=0}
```

### Fields every action takes

{{actionCommonFields}}

Fields that hold actions: {{chainKeys}}.

### Every action

{{actions}}
