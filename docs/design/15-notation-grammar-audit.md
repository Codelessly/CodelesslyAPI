# The notation's grammar: an audit, and one rule per role

2026-11-16. The owner's instruction: "We shouldn't have params one using `=` equals symbol and another using
`:` colon. Do a consistency pass and give it the authority to rewrite the grammar for common sense intuitive
language grammar." Later the same day: "We can do breaking change for improvement. No backwards compatibility
needed!"

This note is the audit that pass started from (sections 1 to 4), the grammar it arrived at (5), and what was
changed, kept and left alone (6 to 8). The design of the notation is [13-compact-notation.md](13-compact-notation.md);
the note for those with files in the old grammar is [16-notation-grammar-migration.md](16-notation-grammar-migration.md).
(Two other notes in this folder carry the numbers 15 and 16; these two are told apart by their names.)

## 1. What was counted

File and line references are to `lib/src/core/notation/` at master `9baab672`, before the change.

| Corpus | Files | Lines | What it is |
|---|---|---|---|
| Showcase | 298 | 19,527 | Recorded model answers under the notation prompt (CodelesslySDK `examples/showcase/**`, less the next row) |
| Sites | 217 | 11,817 | The pages of the twenty sites agents wrote (`experiments/dsl-5/<site>/pages/*.txt` on 26 branches, one copy of each page) |
| No vocabulary | 84 | 4,290 | Answers written with no prompt at all (`examples/showcase/natural-words/**/natural/`): what a model reaches for by itself |

Counted with regular expressions over each line (strings set aside), so each figure is
within a few of the truth, not exact.

## 2. Every form the parser read, by role

| Role | Form | Example | Read at | Taught | Showcase | Sites | No vocabulary |
|---|---|---|---|---|---|---|---|
| **A prop** | `key:value` | `gap:12 w:fill icon:"waves"` | key loop, `notation.dart:2126` | yes | 11,476 | 6,794 | 9,482 |
| | `key=value` on a component | `qty=count` | `_componentWord`, `:3624` | no | not counted | | |
| **A flag** | a bare word | `grow sticky center hidden` | `:2127`-`:2206` | yes | 3,932 | 1,332 | 13 |
| | `key:true` | `sticky:true` | `page_words.dart:633` | no | | | |
| **A computed value** | `key:=expr` (no spaces) | `selected:=tab=="a"` | `:2248` | yes | 1,128 | 206 | **0** |
| | `key:{expr}` | `visible:{count > 0}` | `:2263`, `_bracedExpression` `:3861` | only with `natural: true` | 0 | 0 | **29** |
| | `key:={expr}` | `enabled:={!running}` | `:2262` | no | | | |
| | `key:expr` written bare | `enabled:count > 0`, `price:x.price` | `:2255`, `:2265`, `:2285` | no | | | |
| | the same after the actions | `-> size="7" selected:=size=="7"` | `:1594`, `:1744` | no | 94 | 1 | 0 |
| **A two-way binding** | `=name` | `Input "Email" =email` | `:2037` | yes | 1,265 | 468 | **0** |
| | `=expr` on what shows a value | `Progress =done/total` | `:2058` | yes | (in the row above) | | |
| | `:=expr` with a stray colon | `Progress :=done/5` | `:1949` | no | | | |
| | `bind:name` (not read: it became a prop named `bind`) | `Text "0/500" bind:comment-length` | | no | 0 | 0 | **15** |
| **State** | `state name=value` | `state qty=1` | `_state`, `:3588` | yes | 914 | 614 | 0 |
| | `state name=formula` (a worked-out value) | `state total=sum(cart,x=>x.price)` | `:3598` | yes | | | |
| | `let` / `derived` / `const` / `var name = …` | `let total = a + b` | `:1551` | with `natural: true` | 0 | 2 | 0 |
| | `name = value` on a line of its own | `count = 0` | `:1546` | no | 0 | 0 | 0 |
| | `project name=value` | `project cart=[]` | `:1558` | yes (pages) | 0 | 85 | 0 |
| **An action** | `-> name=value` | `-> qty=qty+1` | `_actions`, `:3720` | yes | 1,494 | 531 | 0 |
| | `+=`, `++`, `.add(x)`, `if (c) {…}` | `-> n += 1` | `_inPlace` `:3690`, `_guarded` `:3671` | with `natural: true` | 0 | 0 | 0 |
| | `emit name [value]` | `-> emit pick item.id` | `:3749` | yes | 582 | 0 | 0 |
| | `go page` | `-> go pricing` | `:3782` | yes (pages) | 0 | 2,127 | 0 |
| | `go expression` | `-> go replace(lower(result)," ","_")` | `:3787` | yes (pages) | 0 | 145 | 0 |
| | `open id`, `close` | `-> open signup` | `:3762`, `:3780` | yes | 25 | 85 | 0 |
| | `scroll id` | `-> scroll pricing` | `:3768` | yes (pages) | 0 | 23 | 0 |
| | `toast "…"`, `link url` | `-> toast "Saved"` | `:3789`, `:3791` | yes | 193 | 20 | 0 |
| | an action as JSON | `-> {"type":"setVariable",…}` | `:3715` | yes | 0 | 0 | 0 |
| **A handler** | `-> actions` (the node's own event) | `Button "Save" -> emit save` | `:1972` | yes | 2,957 | 2,696 | 15 |
| | `onEvent:{actions}` on the line | `onLongPress:{n=0}` | `:2217`, `_handlerTrigger` `:3649` | no | 2 | 9 | **30** |
| | `onEvent: actions` on a line of its own | `  onCta: go signup` | `:1623` | yes (pages) | 0 | 65 | 15 |
| | `tap:"…"`, `onX: bare to the end` | `tap:"n = n + 1"` | `:2224`, `:2227` | no | | | |
| | `swipe:left -> actions` | `Row swipe:left -> …` | `:2442` | yes | 13 | 0 | 5 |
| | `menu:id` (a right click or long press opens it) | `Row menu:rowMenu` | `:2240` | yes (pages) | 1 | 5 | 1 |
| | `every 1s [when c] -> actions` | `every 1s -> t=t+1` | `:1569` | yes | 22 | 7 | 0 |
| | `drag:group(value)`, `drop:group -> …` | `Card drag:todo(card.id)` | `:2449`, `:2458` | yes | 64 | 0 | 2 |
| **A condition** | `if expr` line (and `else`) | `if step>0` | `:1654`, `:1639` | yes | 434 | 404 | 1 |
| | `visible:` on a line | `visible:=count>0` | `pathOf`, `:1927` | yes | 75 | 8 | 31 |
| | `if:` / `when:` as a key | `when:{forward}` | `:2213` | no | 0 | 0 | 23 |
| | `show:condition` | `show:menuOpen` | `:2213` | no | 0 | 0 | 13 |
| | `hidden` | `Text "x" hidden` | `:2192` | yes | 28 | 0 | 1 |
| **A size** | `hide:phone`, `show:tablet` | `Row hide:phone` | `:2408` | yes (pages) | 0 | 20 | 0 |
| **A loop** | `each x in list` | `each row in rows` | `:1678` | yes | 225 | 32 | 0 |
| | `each list`, `List =rows`, `for x in list` | `for t in tasks` | `:1669`, `:1553` | no | 0 | 0 | 0 |
| **An id** | `Type#id` | `Section#pricing` | head, `:1791` | yes | 96 | 172 | 0 |
| | `#name` after the line (an anchor) | `Heading "Why" #why` | `:2188` | yes (pages) | 11 | 2 | 41 |
| | `id:name` (rewritten to an anchor) | `Section id:pricing` | `page_words.dart:646` | yes (pages) | 3 | 0 | **204** |
| | `href:"#name"` on a Link | `Link "Pricing" href:"#pricing"` | `page_words.dart:559` | yes (pages) | | | |
| **Text that reads a value** | `"{expr}"` | `"Total: {total}"` | `_interpolate`, `:3973` | yes | 1,293 | 445 | 45 |
| | `"${expr}"` (the document's own) | `"${fixed(n, 2)}"` | the same | no | 34 | 59 | 2 |
| | a bare path where the text goes | `Text.strong row.name` | `page_words.dart:634` | no | | | |
| | an expression where the text goes | `Button open ? "Hide" : "Show"` | `:2106` | no | | | |
| **Lists** | `items:[…]` (Select, SegmentedButton) | `items:["S","M"]` | `:2509` | yes | 146 | 55 | 2 |
| | `options:[…]` (a component's own parameter, also read on a Select) | `TabToggle options:[…]` | the component's spec | in the component's line | 48 | 71 | 3 |
| **Overlays** | `Dialog#id "Title"` at the margin (Sheet, Drawer, Menu, Popover, Lightbox) | `Menu#more end` | `page_words.dart:138` | yes (pages) | 9 | 27 | 0 |
| **Escapes to JSON** | `{…}` at the end of a line | `Text "x" {"props":{"maxLines":2}}` | `:1987`, `_tail` `:4058` | yes | 28 | 57 | 0 |
| | `node {…}` | `node {"type":"customPaint",…}` | `:1754` | yes | 35 | 1 | 0 |
| | `document {…}` (the printer's last line) | | `:1587` | no | | | |

The printer (`print.dart`) writes `state name=value`, the type, `#id`, the main string, `gap:`, `pad:`, `fill:`,
`border:`, `radius:`, `w:`, `h:` and three alignment words; everything else goes in the `{…}` tail. It printed no
binding, no computed value and no handler, so no form above is its to choose.

## 3. What authors got wrong

From the twenty sites' `friction.md` (20 sites, 31 distinct files) and the 32 issue lines recorded under
`examples/showcase/**/issues.txt`. Grammar only; layout and missing parts are left out.

| Stumble | Sites | What was written |
|---|---|---|
| `go` with a destination worked out was taken as a page's name, or the other way round | 11 | `-> go result`; `go lower(result)`; `go result=="Home"?"home":"pricing"` "expanded to that exact string"; four spellings tried (`go ${=lower(result)}`, `go "{lower(result)}"`, `go =expression`, bare); `go case-study` read as a subtraction |
| A variable of the site declared again by the page that set it | 15 | `-> favourites=append(…)` beside site.json; `shared state x=…`, `project x`, `-> project.x=…` tried |
| `->` wires one event; a block's other events had no words | 6 | `Hero … -> go episode` left `secondary` unwired; 14 JSON tails on one site; `hover:"preview=festival"` (actions inside a text) |
| `if` with `show:phone` under it; `show:phone` read as a variable named `phone` | 10 | `if menuOpen` over `Section show:tablet` |
| A JSON tail for what has a word | 11 | `{"props":{"sticky":true,"top":24}}` (16 of the 32 recorded issues are of this kind or a bare word) |
| A state line holding an expression | 3 | `state price=variant=="Oat"?48:…` |
| A hyphen in `#id` | 2 | `Segments#billing-toggle` |
| An overlay written under an `if` | 4 | `if selected!=""` over a `Dialog` |
| A loop name that is also a key | 1 | `each h in homes` … `h:120` |

Not reported by anyone as a stumble: `:=` against `:` against `=name`. Authors were taught three marks and used
them correctly. The cost of the three marks is paid by the reader, and by a model that was not taught them: in 84
answers written with no vocabulary, `:=` and `=name` appear **0** times, `key:{…}` 29 times and `bind:name` 15.

## 4. The inconsistencies, ranked

By how much each would mislead someone reading a file for the first time, or a model writing one.

1. **Three marks for "this node's key has this value".** `gap:12`, `selected:=tab=="a"`, `=email`. A reader cannot
   tell from the role which mark a thing takes; `:=` exists nowhere else a model has seen with this meaning (it is
   assignment in Pascal and Go), and it needs a second rule ("no spaces") to say where it ends. `=email` is a
   parameter with no name.
2. **`=` in two jobs.** After `->` and in `state` it assigns a variable (`qty=qty+1`). On a node's line it bound a
   control (`=email`) or, after a colon, marked a formula. The first is what `=` means in every language a model
   knows; the other two are not.
3. **Braces already meant "worked out from the state", but only inside a text.** `"Total: {total}"` and
   `visible:=total>0` say the same thing two ways. `key:{…}` was read, and taught under a flag, and was the only
   form models wrote unprompted.
4. **A handler in four places.** `-> …` on the line; `onCta: …` on a line of its own under the node (which reads as
   a child); `onLongPress:{…}` as a key; `swipe:left -> …`, a key that changes what the arrow on the same line
   means.
5. **`go` read its argument two ways** by its shape: a word is a page, anything else a formula. The most reported
   stumble of the twenty sites.
6. **`show:` meant two things**: a size (`show:phone`) and a condition (`show:menuOpen`), told apart by the value,
   so a page with a variable named `phone` needed a special case (`notation.dart:2212`).
7. **A name for a line in three places**: `Type#id`, `#name` after the line, `id:name`. Only the first names the
   node; the other two name an anchor only `scroll` reads.
8. **`items:` on a Select, `options:` on a design system's TabToggle.** Each is the parameter's own name, and
   `options:` is read on a Select too. Under-explained, not inconsistent.

## 5. The grammar

Four marks, each with one job, and nothing on a node's line that is not one of them.

```
Type[.variant][#id] ["text"] [key:value ...] [-> action; action] [onEvent:{action; action} ...]
```

| Role | Rule | Example |
|---|---|---|
| A value of the node | `key:value`, always a colon. A bare word is a flag (`sticky` is `sticky:true`) or a layout word. | `gap:12 w:fill icon:"waves" grow` |
| A value worked out from the state | The expression in braces, wherever a value goes: after a key, and inside a text. | `visible:{count > 0}` · `"Total: {total}"` |
| A control's value kept in a variable | `bind:name`: a key like any other, whose value is the variable. Both ways for a control; for what only shows a value (Progress, Gauge) it follows the variable, or `bind:{expression}`. | `Input "Email" bind:email` |
| A variable | `=` assigns, as in code, and appears nowhere else: where it starts (`state`, `project`), and what an action makes it. | `state qty=1` · `-> qty=qty+1` |
| What a node does | `-> actions` is its own event (a tap; a change, for a control; a component's first event). Any other event is `onEvent:{actions}`, a key whose value is code in braces, before or after the arrow. Actions are separated by `;`. | `-> go home onCta:{go signup}` |
| An action | `name=value`, or a verb with its argument: `emit event [value]`, `go page`, `open id`, `close`, `scroll id`, `toast "…"`, `link url`. A verb's argument is the word written; one that is worked out is in braces. | `go pricing` · `go {lower(result)}` |
| A condition | `if expr` on a line of its own, over the lines under it (`else` after it); `visible:{expr}` on one line. | `if step>0` |
| A size | `hide:phone`, `show:tablet`: a size word, never a condition. | `Row hide:phone` |
| A loop | `each x in list` on a line of its own. | `each row in rows` |
| A name | `#id` after the type. Everything that refers to a line uses it: `open`, `scroll`, `href:"#id"`, an edit. | `Section#pricing` |
| What the notation has no word for | `{…}` JSON at the end of a line; `node {…}` for a whole node. | `{"props":{"maxLines":2}}` |

Held in the head: **a colon gives the node a value; braces mean "worked out"; `=` sets a variable; `->` and
`onEvent:{…}` are what happens.**

This is the question [15-the-middle-and-generated-apps.md](15-the-middle-and-generated-apps.md) left open in its
section 4.10 ("the same idea is written five ways depending on where it stands … not decided") and measured in
4.13 and 4.15: of fourteen answers written by the small model with the rules about state taken out, one used
`=name` and none `:=`; thirteen wrote the name bare after the key, four in braces; and the prompt variant that
taught braces (`notationPrompt(natural: true)`) scored 11 and 10 of 25 on the values check against 8 for the
prompt that taught `:=`. Braces are the one of the model's own forms that says where the expression ends and is
never mistaken for a word; the bare forms are still read (section 8).

Why these, and not others:

- **The colon for every parameter** is what is already written 18,000 times against 1,300, what YAML, CSS and JSON
  do, and what every no-vocabulary answer does.
- **Braces for an expression** are JSX's (`selected={tab == "a"}`), a template string's, and the notation's own
  inside a text; they are what models wrote unprompted (29 to 0), they end where they close, so an expression may
  have spaces, and they are one rule where there were two.
- **`bind:` for a binding** is Svelte's word and what 15 no-vocabulary answers wrote. It costs about one token
  more than `=email` per control. `value:{email}` was considered and rejected: it reads as one-way (and is), and a
  control's value prop has a different name on each control.
- **`=` kept for state and actions**, not changed to a colon: `state qty=1` and `-> qty=qty+1` are statements, a
  different thing from a parameter, and the form makes that visible. Inside an action the right side is already
  code, so it takes no braces.
- **`onEvent:{…}` for the other events** is `key:value` with code as the value, as in JSX; `->` stays as the short
  form for the one event nearly every line has (5,650 uses).

## 6. What changed

| Was | Is | Why it is worth it |
|---|---|---|
| `=name`, `=expression` | `bind:name`, `bind:{expression}` | The owner's example: no parameter is marked with `=`. Every word after the type is now a text, a flag, `key:value` or a handler. |
| `key:=expression` | `key:{expression}` | One mark for "worked out", the same as in a text; no "no spaces" rule; what models write unprompted. |
| `onCta: actions` on a line of its own | `onCta:{actions}` on the node's line (after the arrow's actions, or before the arrow) | A handler is not a child. One place for what a node does. |
| `swipe:left -> actions` | `onSwipeLeft:{actions}` | `->` means one thing on every line. |
| `go expression` | `go {expression}` | The most reported stumble: a bare word is always a page, braces are always worked out. |
| `show:condition` | `visible:{condition}` | `show:` has one meaning, a size. |
| `List =rows` | `each row in rows` | It was `=` again. |

Each old spelling is still read, so the card or page is drawn, and the parser says once per text what to write
instead (`A binding is written bind:name, not =name: …`): an author or a model is told and fixes it, and
`tool/notation/notation.sh expand` exits 1 until then. `formatNotation` (`notation.sh format <file>`) rewrites a
file and changes nothing else.

One reading had to be chosen. `bind:` was until now an unknown prop on a core type (kept as `props.bind`, which
nothing drew) and a rejected word on a component; it is now the binding. The eight no-vocabulary answers that wrote
`bind:rating-label` and the like expand differently, and for the better.

## 7. What stays, and why

- **`state name=value`, `project name=value`, `-> name=value`.** Assignment, consistently.
- **`->`.** The notation's most used mark after the colon.
- **The flag and alignment words.** `grow`, `sticky`, `center`: a bare word is a yes.
- **`if` lines beside `visible:`.** Two jobs: a block of lines, and one line.
- **`hide:phone` / `show:phone`.** A size is not a condition, and the form now says so: their values are size
  words only.
- **`items:` and `options:`.** A key is the parameter's own name; a Select reads both.
- **`menu:id`.** A parameter (which menu a right click opens), not a handler.
- **`emit event value`.** The value after the event is read as a value or an expression as before. Putting it in
  braces was considered; nobody stumbled on it, and it is 582 lines.
- **Strings in order** for a component's text parameters.

## 8. Tolerance kept

The notation reads what a model writes unprompted (design 13, section 13). That stays wherever it is a near miss
and not a second taught way. Read with nothing said, and not taught:

`if:` / `when:` as keys (23 no-vocabulary uses); a bare expression after a key (`enabled:count > 0`); a
declared variable written bare (`choice:pick`); `key:={…}`; `id:name` and `#name` after a line as anchors (245
no-vocabulary uses; making them the node's id would rename nodes in existing documents); `tap:"…"` and a handler's
body written to the end of the line; `let`, `for x in`, `else`, `+=` and `.add()`; `"${…}"` in a text; a bare path
where a text goes; a prop written after the actions, when it is in braces. `formatNotation` rewrites `if:` and
`when:` to `visible:{…}` and leaves the rest as written.
