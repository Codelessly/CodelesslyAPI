# The notation's grammar changed in 33.0.0: what to do with a file written before

For anyone, or any agent, with pages or cards written in the compact notation before 2026-11-16. It can be pasted
into a prompt as it is. The reasons are in [17-notation-grammar-audit.md](17-notation-grammar-audit.md).

**It is a hard break.** The parser reads the new grammar only: an old file does not expand, and each old line
says what to write instead.

## The grammar now

```
Type[.variant][#id] ["text"] [key=value ...]
```

- Everything after the text is `key=value`: `gap=12 icon="mail" w=fill items=["A","B"] hide=phone`. A bare word is
  a flag or a layout word (`grow`, `center`, `sticky`).
- A value worked out from the state is in braces, after a key and inside a text: `enabled={email != ""}`,
  `"Total: {total}"`.
- A control's value in a variable is `bind=name`.
- What a node does is an event with its actions in braces: `onTap={sent=true; toast "Sent"}`, `onChange={…}` on a
  control (`result` is its new value), a block's own events by name (`onCta={go signup}`). There is no arrow.
- `=` assigns a variable in `state name=value`, `project name=value` and inside an action.

## What changed

| Before | Now |
|---|---|
| `Column gap:12 pad:16` | `Column gap=12 pad=16` |
| `Input "Email" hint:"you@example.com" =email` | `Input "Email" hint="you@example.com" bind=email` |
| `Progress =done/total` | `Progress bind={done/total}` |
| `selected:=tab=="orders"`, `enabled:count > 0` | `selected={tab=="orders"}`, `enabled={count > 0}` |
| `Button "Save" -> saved=true; toast "Saved"` | `Button "Save" onTap={saved=true; toast "Saved"}` |
| `Slider =volume -> emit volume result` | `Slider bind=volume onChange={emit volume result}` |
| `SiteNav … -> go replace(lower(result)," ","_")`<br>`  onCta: go signup` | `SiteNav … onNavigate={go {replace(lower(result)," ","_")}} onCta={go signup}` |
| `Row swipe:left -> rows=without(rows,row)` | `Row onSwipeLeft={rows=without(rows,row)}` |
| `Column drop:todo -> done=append(done,result.data)` | `Column drop=todo onDrop={done=append(done,result.data)}` |
| `every 1s when running -> t=t+1` | `every 1s when running onTick={t=t+1}` |
| `-> go lower(result)` | `onTap={go {lower(result)}}` (`go pricing`, `go case-study` are unchanged) |
| `show:menuOpen`, `if:menuOpen` | `visible={menuOpen}` (`show=phone`, `hide=tablet` are sizes) |
| `Heading "Why" #why`, `Section id:why` | `Heading "Why" id=why`, `Section id=why` (or `Section#why`) |
| `Text.strong row.name` | `Text.strong "{row.name}"` |
| `ActionButton "Cancel" quiet` | `ActionButton "Cancel" tone=quiet` |
| `Lightbox#shots photos:=photos =at` | `Lightbox#shots photos={photos} bind=at` |

Unchanged: one node per line and its indentation, `Type.variant#id "text"`, `state` and `project` lines, `if` /
`else` / `each` lines, `"{name}"` in a text, the page words, the overlays written after the page, the `{…}` JSON
tail and `node {…}`, and what an action is (`name=value`, `emit`, `go`, `open`, `close`, `scroll`, `toast`,
`link`).

## The one command

From a CodelesslySDK checkout (with CodelesslyAPI beside it, both at 33.0.0 or later):

```
tool/notation/notation.sh migrate pages/*.txt --design-system design_systems/cards
```

It rewrites each file in place and changes nothing else (indentation, texts, comments). Name the design system
the pages call (the flag may be repeated): a block's event is then written by the block's own name for it
(`onNavigate`, `onPressed`) and a block's enumerated value gets its key; without it an event is `onTap`, which
on a block is its first event. `--check` lists the files it would rewrite; `--stdout` prints one. For notation
inside other files: `--markdown` (fenced blocks and code spans) and `--dart` (string literals).

A file already in the new grammar is left as it is. The tool is a one-off and will be deleted once the sites are
migrated: it carries its own copy of how the old parser split a line, because the parser no longer can.

Then expand as before (`tool/notation/notation.sh expand …`) and compare with what the page expanded to: every
file of the SDK and every page of the twenty sites expands, rewritten, to the document it expanded to before.

## What to look at by hand

- **A page expanded without its design system.** Under `SiteNav`, `Hero` and the like, the old parser attached a
  handler on a line of its own to whatever node was open above it when the block was unknown. It now goes with its
  block.
- **A handler under an `if` or an `each`** (not under a node) stays where it is, and is an error: write it on the
  line of the node it belongs to.
- **A word written bare after a key that the page meant as a variable** but had not declared before that line
  (`selected:tab` above `state tab=…`): the old parser read it as text, and so does the rewrite (`selected=tab`).
- **A list left open over several lines** (`items:=[` and an element a line) becomes one line.
- **An on-demand block** the tool is not told about: a parameter named `change`, `tap`, `press` or `click` whose
  value is not a number is read as the handler it was read as before.
- **The prompt.** A prompt taken before 33.0.0 teaches the old grammar. Take it again
  (`tool/notation/notation.sh prompt …`).
