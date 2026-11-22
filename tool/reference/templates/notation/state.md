# State and formulas

Variables, formula variables and functions, bindings, and every formula function. Open it when a value must be
worked out, kept, or shared, or you need a function's signature.

## Variables

`state name=value` declares a variable of the screen, its type from its value; `state name:type=value` names the
type (`state price:decimal=0`; with no value, `state note:text`). Types: {{variableTypes}}. `saved` after the
value keeps it on the device: `state tab="inbox" saved` (not `state tab saved="inbox"`). A variable every page shares
is the app's, declared in the site's `app.txt` with the same line (`state favourites=[] saved`): [site.md](site.md). A
variable is not named after what the runtime gives every formula: `data`, `route`, `storage`, `screen`, `theme`,
`auth`, `drag`, `perf`, `script`, `speech` (`state perfText=…`, not `state perf=…`), nor after a state a line's
looks are written under (`hovered`, `focused`, `pressed`, `selected`, `disabled`, `dragged`): on a line `pressed.fill=…`
is always the node's pressed look, never the variable (`state heldItem=…`, not `state pressed=…`).

The type words are these and no others: `boolean` (not `bool`), `integer` or `decimal` (not `int`, `number`,
`double`), `text` (not `String` or `string`), `list`, `map`. A component's `param` is typed in Flutter's names
instead (`param open:bool=false`, [components.md](components.md#components-writing-one)). There is no `formula`
line: a value worked out is a `state` whose value is braced (`state valid:boolean={matches(url, '^https?://')}`).

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

Whatever is written in braces after `state name=` is a formula, with or without a type: `state m={cur % 12}`,
`state late={due < today()}`, `state b={a}` (b follows a); a value in braces stays a value (`state rec={"n": 1}`,
`state n={3}`). Inside a formula, braces group as parentheses do, so a value written `{id}` where `id` would do is
read (`filter(rows, x => x.id == {id})`); a record (`{"id": x.id}`) stays a record. A function's own parameter is
the function's, whatever else has its name: in `map(xs, top => top.a)` beside `state top={n * 2}`, `top` is the item.
A name that is called is the formulas' own function, never a state of that name: beside `state count={sum(cart, l =>
l.qty)}`, `count(rows, r => r.done)` still counts.

A formula variable is its formula wherever it is read, so it cannot be set: `day=addDays(day, 1)` beside `state
day={today()}` is said, with what to write. A value that starts worked out and then changes is a plain variable set
when the screen opens ([events.md](events.md)):

```notation
state day=""
Column gap=8
  Text "{formatDate(day, 'EEE d MMM')}"
  Button "Next day" onTap={day=addDays(day, 1)}
on load={day=today()}
```

## Values in a text

A text reads a value in braces: `Text "{count} of {total}"`, `Text "Hello {user.name}"`, a formula
(`"{length(items)} items"`). A number alone in braces among the words is that number (`"Count {0}"` shows
`Count 0`). `\{` and `\}` are the braces themselves, read as no value: `Text "Write \{name\} where the name
goes"` shows `Write {name} where the name goes`.

A state is not named `data`, `route`, `storage`, `screen`, `theme`, `auth`, `drag`, `perf`, `script`, `speech` or
`device`: the runtime gives every formula those names. A state may have the name of a word of a line (`top`, `end`,
`center`): the word keeps its meaning where a word goes (`Row end`, `border-top=`), and the state is read where a
value is (`{end}`, `w={top}`).

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

A formula is not JavaScript. Logic is `!x`, `a && b`, `a || b` (not `not`, `and`, `or`); a list is the first
argument of a function, not a method (`any(facts, f => f.done)`, not `facts.some(…)`); a record changes by
`set(p, 'following', !p.following)`, with no `{...p}`. A field of a record that is null is null, not an error:
`coalesce(selected.iso, "")` is `""` while nothing is selected.

```notation
state people=[{"id":"a","following":false}]
state selected={}
Column gap=8
  Text "Following someone" visible={any(people, p => p.following)}
  Button "Follow" onTap={people=map(people, p => p.id == "a" ? set(p, "following", !p.following) : p)}
  Button "Book" enabled={coalesce(selected.iso, "") != ""}
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
