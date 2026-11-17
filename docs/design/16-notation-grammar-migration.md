# The notation's grammar changed on 2026-11-16: what to do with a file written before

For anyone, or any agent, with pages or cards written in the compact notation before this date. It can be pasted
into a prompt as it is. The reasons are in [15-notation-grammar-audit.md](15-notation-grammar-audit.md).

## The grammar now

One rule per role:

- `key:value` gives a node a value. The colon is the only separator on a node's line.
- `{…}` is a value worked out from the state, wherever a value goes: `visible:{count > 0}`, `"Total: {total}"`.
- `=` only sets a variable: `state qty=1`, `-> qty=qty+1`.
- `->` is what a node does when it is used; any other event is `onEvent:{actions}` on the same line.

## What changed

| Before | Now |
|---|---|
| `Input "Email" =email` | `Input "Email" bind:email` |
| `Progress =done/total` | `Progress bind:{done/total}` |
| `selected:=tab=="orders"` | `selected:{tab=="orders"}` (spaces are fine now: `selected:{tab == "orders"}`) |
| `-> size="7" selected:=size=="7"` (a prop after the actions) | `selected:{size=="7"} -> size="7"` |
| A handler on a line of its own under its node:<br>`SiteNav … -> go home`<br>`  onCta: go signup` | On the node's line, in braces, after its actions:<br>`SiteNav … -> go home onCta:{go signup}` |
| `Row swipe:left -> rows=without(rows,row)` | `Row onSwipeLeft:{rows=without(rows,row)}` |
| `-> go replace(lower(result)," ","_")` | `-> go {replace(lower(result)," ","_")}` (`go pricing`, `go case-study` and `go "{name}"` are unchanged) |
| `show:menuOpen` | `visible:{menuOpen}` (`show:phone`, `hide:tablet` are unchanged: they are sizes) |
| `List =rows` | `each row in rows` |

Nothing else changed: `state name=value`, `project name=value`, `-> name=value`, `if` and `each` lines,
`Type#id`, `"{name}"` in a text, the `{…}` JSON tail, `node {…}`, the page words and the overlays are as they
were, and every file expands to the same document once rewritten.

## The one command

From a CodelesslySDK checkout (with CodelesslyAPI beside it, both at this change or later):

```
tool/notation/notation.sh format pages/*.txt
```

It rewrites each file in place to the grammar above and changes nothing else (indentation, texts, comments).
Before it writes a file it expands the text as written and as rewritten and compares the two documents; a file
whose document would change is left alone and named. Pass `--design-system <folder>` when the pages call a design
system's blocks, `--check` to list the files it would rewrite without touching them, `--stdout` to print one
file. For notation inside other files: `dart run tool/format_notation_in_markdown.dart <file.md>` and
`dart run tool/format_notation_in_dart.dart <file.dart>` in CodelesslyAPI (fenced blocks and code spans; string
literals), each listing what it changed.

Then expand as before (`tool/notation/notation.sh expand …`). A file still holding an old spelling expands, so
the page is drawn as it was, but the expander names each old spelling once (`A binding is written bind:name, not
=name: …`) and exits 1 until none is left.

## What the formatter cannot do for you

- A handler on a line of its own under an `if` or an `each` (not under a node) stays where it is: write it on the
  line of the node it belongs to.
- A list left open over several lines (`items:=[` and an element a line) becomes one line when something in it is
  rewritten.
- `bind:` is now the binding. If a line used `bind:` for something else (a prop of that name on a plain type), it
  reads differently: rename it.
- The prompt a model was given before teaches the old spellings. Take the prompt again
  (`tool/notation/notation.sh prompt …`): an answer written from an old prompt is read, and each old spelling in
  it is named once in the issues.
