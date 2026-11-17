# The notation's grammar: an audit, and one rule per role

2026-11-16. The owner's instruction: "We shouldn't have params one using `=` equals symbol and another using
`:` colon. Do a consistency pass and give it the authority to rewrite the grammar for common sense intuitive
language grammar." Later the same day: "We can do breaking change for improvement. No backwards compatibility
needed!"

This note is the audit that pass started from (sections 1 to 4, of the grammar as it was), the grammar the
owner then decided (5), what changed and what was removed (6, 7), and what is still read though not taught (8).
The design of the notation is [13-compact-notation.md](13-compact-notation.md); the note for those with files in
the old grammar is [18-notation-grammar-migration.md](18-notation-grammar-migration.md).

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

A first pass of this audit proposed keeping the colon and marking a binding `bind:name`. The owner then put the
question to two models (26 runs; the material is with the owner) and decided otherwise, in these words: "= is
natural AI grammar", "Use = and bind as you recommend", "Let's use {} instead of the arrow!", "I want no old
legacy compatibility code". What the runs showed: shown no separator at all, 8 of 8 wrote `key=value` for a
property and 8 of 8 `bind=name` for a control's value; all four Sonnet runs wrote events as `onTap` / `onChange` /
`onBlur`, three with a braced body, and none wrote an arrow; given a grammar card, both models followed `=` and
`:` grammars with no separator error. So reliability does not decide it; what is natural and consistent does. The
count in section 2 that favoured the colon and `bind:` came from answers to a prompt that had already shown
`key:value`.

```
Type[.variant][#id] ["text"] [key=value ...]
```

| Role | Rule | Example |
|---|---|---|
| A value of the node | `key=value`, always. A bare word is a flag (`sticky` is `sticky=true`) or a layout word. | `gap=12 w=fill icon="waves" items=["A","B"] hide=phone` |
| A value worked out from the state | The expression in braces, after a key and inside a text. | `enabled={email != ""}` · `"Total: {total}"` |
| A control's value kept in a variable | `bind=name`: a parameter like any other. Both ways for a control; on what only shows a value it follows the variable, or `bind={expression}`. | `Input "Email" bind=email` |
| What a node does | An event parameter with its actions in braces. `onTap` is a tap; `onChange` a control's change; a block's events keep their own names. There is no arrow. | `onTap={sent=true; toast "Sent"}` · `onCta={go signup}` |
| An action | `name=value`, or a verb with its argument: `emit event [value]`, `go page`, `open id`, `close`, `scroll id`, `toast "…"`, `link url`; several separated by `;`. A verb's argument is the word written; one worked out is in braces. | `go pricing` · `go {lower(result)}` |
| A variable | `=` assigns: where it starts (`state`, `project`), and inside an action. The same "is" as a parameter's. | `state qty=1` · `qty=qty+1` |
| Time | `every 1s [when condition] onTick={actions}` on a line of its own. | `every 1s onTick={t=t+1}` |
| A condition | `if expr` on a line of its own, over the lines under it (`else` after it); `visible={expr}` on one line. | `if step>0` |
| A size | `hide=phone`, `show=tablet`: a size word, never a condition. | `Row hide=phone` |
| A loop | `each x in list` on a line of its own. | `each row in rows` |
| A name | `#id` after the type: what `open`, `scroll` and an edit name. `id=name` on a line is an anchor a `scroll` goes to. | `Section#pricing` |
| What the notation has no word for | `{…}` JSON at the end of a line; `node {…}` for a whole node. | `{"props":{"maxLines":2}}` |

Held in the head: **everything after the text is `key=value`; braces hold an expression, or, after an `on…` key,
actions.**

Decided in this pass, for what the owner left open:

- **The event names.** On a plain node: `onTap` (also read: `onPress`, `onPressed`, `onClick`), `onChange`
  (`onChanged`), `onLongPress`, `onDoubleTap`, `onRightClick`, `onSwipeLeft` / `Right` / `Up` / `Down`, `onHover`
  (the cursor entering), `onFocus`, `onBlur`, `onSubmit`, `onDrop`. Any other `on…` on a plain node is an error
  that lists these. On a block, its own events by name, and `onTap` (or a name it does not have) is its first
  event: a page word that is also a block in one design system (`MenuItem`, `Hero`) is then written one way with
  and without that design system.
- **The value an event carries** is `result` (a slider's new value, the link a `SiteNav` reports), as it was.
- **A worked-out argument** of an action is in braces (`go {expr}`); `emit event value` reads its value as before.
- **`visible={expr}`** is the condition on one line; `show=` and `hide=` take sizes only, and say so otherwise.
- **A timer's actions** are `onTick={…}`: an `every` line has an event like any other.
- **A drop** is `drop=group onDrop={…}`.
- **An anchor** is `id=name` (it was `#name` after the line, or `id:name`): a parameter, and what 204
  no-vocabulary answers wrote but for the colon.
- **A bare word after `=` is that word.** `tone=quiet` is the text "quiet". A word that names a declared variable
  (`color=pick`) is said as an error with what to write (`color={pick}`), not guessed either way.

## 6. What changed

| Was (to 32.x) | Is |
|---|---|
| `gap:12 icon:"mail"` | `gap=12 icon="mail"` |
| `=name`, `=expression` | `bind=name`, `bind={expression}` |
| `key:=expression`; an expression bare after a key | `key={expression}` |
| `-> actions` | `onTap={actions}`; `onChange={actions}` on a control; a block's own event |
| `onCta: actions` on a line of its own | `onCta={actions}` on the node's line |
| `swipe:left -> actions` | `onSwipeLeft={actions}` |
| `drop:todo -> actions` | `drop=todo onDrop={actions}` |
| `every 1s -> actions` | `every 1s onTick={actions}` |
| `go expression` | `go {expression}` |
| `show:condition`, `if:condition`, `when:condition` | `visible={condition}` |
| `Heading "Why" #why`, `id:why` | `Heading "Why" id=why` |
| `Text.strong row.name`, `Button open ? "Hide" : "Show"` | `Text.strong "{row.name}"`, `Button "{open ? "Hide" : "Show"}"` |
| `ActionButton "Cancel" quiet` (a block's enumerated value as a word) | `ActionButton "Cancel" tone=quiet` |
| `List =rows` | `each row in rows` |

## 7. A hard break: what the parser no longer has

The parser reads the grammar of section 5 only. Removed, as code and not only from the prompt: the `->` branch
and everything that worked around where it ended (props moved from behind the actions, a `{…}` tail found inside
them, an `every` whose arrow was on the next line); the `=name` binding and the stray `:=`; the colon as a
separator; the readings of an expression with no mark (`key:count > 0`, `key:(a+b)`, a declared variable written
bare, a list holding expressions, an expression where the text goes, a bare path after `Text`); a handler on a
line of its own, in quotes, or running to the end of the line; `tap:` / `press:` / `click:` / `change:` as event
keys; `swipe:` as a key; `if:` / `when:` / `show:` as conditions; `#name` after a line and `id:` rewritten to it;
a block's enumerated value as a bare word and `key=value` read as `key:=value`; `List =rows`; `value` as a second
name for `result`. The lines the code writes itself (the page words, an overlay's frame, a Nav's phone menu, an
App's drawer, the viewer, Dots, a gallery's wiring) are in the new grammar.

An old line gets the ordinary error for what the grammar does not have, with what to write:
`A value is written with =, not a colon: gap=12.`, `There is no arrow. What a node does is an event with its
actions in braces: onTap={count=count+1} (onChange={…} on a control).`, `A value has a key: write bind=name …`,
`A handler is written on the line of its node …`, `A value read from the state is written in braces: color={pick}.`

Since the parser cannot read the old grammar, the converter does not lean on it: CodelesslySDK's
`tool/notation/migrate.dart` (`notation.sh migrate`) carries its own copy of how the old parser split a line, and
is to be deleted once the sites are migrated. Proved by expanding every notation file with the old packages and
its rewritten copy with the new and comparing the documents to the byte (the numbers are in the changelog).

## 8. Read, though not taught

What a model writes unprompted (design 13, section 13) that is no second way to write a parameter, a binding, a
computed value or a handler:

`let` / `derived` / `const` / `var name = …` and a bare `name = value` line for state; `for x in list` and
`each list`; `else` and `else if`; `n += 1`, `n++`, `rows.add(x)` / `.remove(x)`, `if (c) { … }` inside actions; a
field of the repeated element set where it stands (`row.qty = 2`); `$name`; single quotes in an expression;
`"${…}"` in a text; `sticky=true`; `Text.small.muted` (the first variant); a code fence or a sentence around the
answer; a guessed prop in a `{…}` tail read as the key it is; a list left open over several lines; `onPress`,
`onPressed`, `onClick`, `onChanged` for `onTap` and `onChange`; `onTap` on a block for its first event.

Not kept, because each was a second way: an expression with no braces, a variable with no braces, an event's
actions with no braces, a block's value with no key, an anchor with no key.

## 9. What does not work, or wants a model test

- **`enabled=count > 0`** (no braces) is what models wrote most with no rules at all (design 15, 4.13: 13 of 14
  the name bare, 5 an expression bare). It is now an error with the fix in the message, not a reading. Whether
  models keep to braces under this prompt, and how often the error is met, wants measuring.
- **`color=pick`** where `pick` is a variable is an error; where no such variable is declared it is the word
  "pick". A model that forgets to declare state gets the word, silently.
- **A prop a plain node does not have** (`swipe=left` aside, which is said) is still kept silently in `props` and
  found only at validation, as before.
- **`onHover`, `onFocus`, `onBlur`, `onSubmit`** are wired to the engine's `cursorEnter`, `focusGained`,
  `focusLost` and `submitted` triggers and tested as documents; they were not driven in a render.
- **`{…}` after a key is an expression unless it names a key first** (`{"a": 1}` is a map). An expression that
  starts with a quoted text and a colon cannot be written; none is known.
- The prompt's wording of events (`onTap={…}`, `onChange={…}` with `result`) has not been run on a model.
