# State and formulas

Variables, formula variables and functions, bindings, and every formula function. Open it when a value must be
worked out, kept, or shared, or you need a function's signature.

## Variables

`state name=value` declares a variable of the screen, its type from its value; `state name:type=value` names the
type (`state price:decimal=0`; with no value, `state note:text`). Types: {{variableTypes}}. `saved` after the
value keeps it on the device: `state tab="inbox" saved` (not `state tab saved="inbox"`). A variable every page shares
is the site's, declared in `site.json` (`"favourites": {"value": [], "persist": true}`): [site.md](site.md). A
variable is not named after what the runtime gives every formula: `data`, `route`, `storage`, `screen`, `theme`,
`auth`, `drag`, `perf`, `script`, `speech` (`state perfText=…`, not `state perf=…`), nor after a state a line's
looks are written under (`hovered`, `focused`, `pressed`, `selected`, `disabled`, `dragged`): on a line `pressed.fill=…`
is always the node's pressed look, never the variable (`state heldItem=…`, not `state pressed=…`).

`state x=0` is a whole number, and a fraction set into it is rounded: one that holds a fraction says so
(`state read:decimal=0`). `state x=null` is text: a variable that starts empty and later holds a record or a list
says so (`state replyTo:map=null`); `replyTo=null` empties it again (`replyTo != null` is then false).

```notation
state read:decimal=0
Column gap=8
  Column scroll h=200 onScroll={read=result.fraction}
    Text "A long text"
  Text "{round(read * 100)}% read"
```

A formula variable is worked out and kept up to date: `state total:decimal={price * qty}`. With parameters it is a
function the formulas call: `state usd(n):text={'$' + round(n)}`.

```notation
state price=2.5
state qty=2
state total:decimal={price * qty}
state usd(n):text={'$' + round(n)}
Text "{usd(total)}"
```

## Bindings

`key={expression}` binds any key: `visible={count > 0}`, `fill={done ? '#FF16A34A' : '#FFE5E7EB'}`,
`w={progress * 200}`. `{name}` reads a value as it is; anything else is a formula. A string with values in it is
`"… {x} …"`.

```notation
state count=0
Column gap=8
  Text "Clicked {count} times"
  Text "Twice: {count * 2}"
  Button "Reset" visible={count > 0} onTap={count=0}
```

## Changing state

`name=value` in an event sets a variable (the value a formula). Lists change by setting a new list:

```notation
state cart=[]
Button "Add" onTap={cart=append(cart,"Tea")}
```

`setVariable` and `setValue` with their fields say the rest (an `op` such as `add`, `toggle`, `remove`; an index):
[events.md](events.md#action-setVariable).

## Functions

{{functions}}

{{reference}}

{{examples}}
