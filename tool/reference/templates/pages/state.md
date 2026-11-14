# State and logic

## When to use

Variables and where they live, computed and function variables, expressions and every binding path with the value
it expects, conditions, the formula functions (grouped: text, numbers, money, lists, objects, dates, colours), the
actions that change state, and sandboxed scripts.

## Minimal example

A counter: a variable, two buttons that change it, and a text and a colour bound to it.

{{example:counter}}

## Reference

### Variables

Declare them in the document's `variables`, under a canvas id (that canvas only) or under `"page_variables"` (every
canvas of the document, kept while the user moves between them). A site's `site.json` adds project variables, read
by bare name in every page and component. A variable's keys:

{{variableFields}}

Types:

{{variableTypes}}

### Expressions

`${name}` or `${path}` reads a value: `${count}`, `${user.name}`, `${items[0].price}`, `${pal[item.kind]}`.
`${= formula}` computes one: arithmetic (`+ - * / %`), comparisons (`== != < <= > >=`), `&&`, `||`, `!`,
`cond ? a : b`, literals (`'text'`, `3.5`, `true`, `null`, lists `[1, 2]`), and lambdas for list functions
(`x => x.price`). A text that is exactly one expression gives its value with its type; inside other text a number is
printed without trailing zeros. Names an expression may start with, besides the variables: {{scopes}}.

### Binding paths

What each path of `bind` expects. A formula gives the value as the field is written in JSON: a number, `true` /
`false`, a name for an enum, a list or an object for the fields written that way. A value of another shape is not
read and the field keeps its value. Values are read loosely: `"12"` is a number, `1` and `"true"` are true.

{{bindingPaths}}

`props.<prop>` takes what the prop's type is written as: `"${= open ? 'vertical' : 'horizontal'}"` for
`props.direction`, a TextStyle object or a theme style's name for `props.style`. Every bindable field:

{{bindableFields}}

Named paths:

{{namedPaths}}

### Conditions

{{conditionParts}}

{{conditionOps}}

### Scripts

A document's sandboxed JavaScript (`scripts`), run by `runScript` or called from a formula (`script.name(...)`).

{{scriptFields}}

### Formula functions

The functions a formula (`${= ...}`) can call, from the SDK's formula engine, grouped.

{{formulaFunctions}}

{{reference}}

## Patterns

### Computed and function variables

A variable with a `formula` (what goes in `${= ...}`) is read-only and follows what it reads; with `parameters` it
is a function any formula calls by name. Declare them in `page_variables` to share them with every canvas of the
document:

```json
"variables": {"page_variables": [
  {"name": "query", "type": "text", "value": ""},
  {"name": "dishes", "type": "list", "value": [{"name": "Lamb", "vegan": false}, {"name": "Squash", "vegan": true}]},
  {"name": "shown", "type": "list", "formula": "filter(dishes, d => contains(lower(d.name), lower(query)))"},
  {"name": "shownCount", "type": "integer", "formula": "length(shown)"},
  {"name": "usd", "type": "text", "parameters": ["n"], "formula": "'$' + round(n)"}
]}
```

`${shown}` feeds a list, `${shownCount}` a label, `${= usd(price * 12)}` any text: write a filter or a rule once,
not in every binding. A function variable's name must not be a formula function's (the built-in one wins).

### A streak and other counts from data

Derive, do not store: a computed variable over the records. Habits done today: `count(habits, h => h.done)`.
Totals: `sum(map(cart, i => i.price * i.qty))`. Dates: `formatDate(today(), 'EEE d')`, `addDays(today(), -i)`,
`weekday(date)` (Monday is 1). Function variables may call each other. A streak (checked days in a row ending at
day `end` of a list of booleans): the days up to `end`, reversed, and the index of the first unchecked one.

```json
"variables": {"page_variables": [
  {"name": "todayIdx", "type": "integer", "formula": "weekday(today()) - 1"},
  {"name": "gapAt", "type": "integer", "parameters": ["days", "end"], "formula": "findIndex(reverse(take(days, end + 1)), d => !d)"},
  {"name": "streak", "type": "integer", "parameters": ["days", "end"], "formula": "gapAt(days, end) < 0 ? end + 1 : gapAt(days, end)"}
]}
```

`${= streak(item.days, todayIdx)}` in a habit's row; `${= streak(item.days, todayIdx - 1)}` when today is not
checked yet. For anything with a real loop, a script.

### Changing state from a reaction

`setVariable` with `op`: `set` (default), `toggle`, `add` (a number adds; a list appends; a map merges),
`subtract`, `insert` / `removeAt` / `update` at `index`, `remove`. `value` is an expression. A chain that branches:
`if` with a `condition` (a predicate: `{"left": "${count}", "op": "greaterThan", "right": "5"}`, `{"left":
"${name}", "op": "isEmpty"}`; every op is in [Conditions](@state-conditions)) and `then` / `else` chains. Every
action also takes `when`, the same kind of predicate object (run only while it holds); a trigger's `when` is a
formula string instead (`"when": "!item.future"`). `forEach` runs a chain per item; `delay` waits.

```json
{"type": "if", "condition": {"left": "${= contains(saved, trip.id)}", "op": "isTrue"},
 "then": [{"type": "setVariable", "variable": "saved", "op": "remove", "value": "${trip.id}"}],
 "else": [{"type": "setVariable", "variable": "saved", "op": "add", "value": "${trip.id}"}]}
```

The condition is an object, never a formula string: a formula goes in `left` with `"op": "isTrue"`.

### Setting several nodes with a condition

A condition sets node fields while a test holds: an ordered list of branches (if, else if, ..., else) under a canvas
id in the document's `conditions`. For one field the first branch that holds and sets it wins; a condition wins
over the node's binding. A binding with a formula is often simpler; conditions suit setting several nodes at once.

{{example:conditions}}

### When to use a script

For multi-step state changes (a puzzle's checks, a game step, a streak over dates), a script reads and sets
variables with `vars.get(name)` and `vars.set(name, value)` (capabilities `variables.read`, `variables.write`);
the UI updates through what binds to them. A script cannot draw or touch nodes. A reaction runs it (`{"type":
"runScript", "script": "place", "arguments": {"cell": "${index}"}}`); a formula calls a pure one
(`${= script.isSolved(board)}`).

## Pitfalls

- `${false}` reads a variable called `false`: a literal is `${= false}`.
- Values in `props`, `layout` and `decoration` are literal: `"opacity": "${x}"` is an error; bind it.
- A backslash in a formula is written twice in JSON: `"${= matches(code, '^\\d{4}$')}"`.
- A component never reads its caller's variables: pass them as parameters.
- Per-breakpoint canvases have separate variables: shared state lives in `page_variables`.
- A function variable named like a formula function is never called (the built-in wins).
- Formula syntax errors and unknown names in formulas are reported by the render command (the SDK parses them).
- A misspelled binding path is `unknown_bind_path`; a name nothing declares is `unknown_name`.

## See also

[Forms](@page-forms) (inputs that set variables) · [lists](@page-lists) (data for templates) ·
[interaction](@interaction-reactions) (reactions and triggers) · [data](@page-data) (APIs, storage, cloud data).
