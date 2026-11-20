# 26. Text runs and links

2026-11-20. Built: a run's `link` takes a tap (the text's `onLinkTap`, else the link opens), the formula
`regexMatches(text, pattern)`, the operator `a ?? b`, and a count in braces (`\d{3}`) kept in a formula's text.
From the NOCD rebuild's friction register, "The base lacks it": automatically linked URLs, emails and phone numbers
(parts 06, 11, 12, 13, 15), tappable styled inline runs (part 24), and a null fallback (part 18); and from the chat
pilot, search matches marked in a text, which writers did not find.

## 1. Decomposed

A text is its characters and a list of runs; a run is a range (`start`, `end`) with a style. What the writers asked
for is three things on top of that:

1. **A run may mean something when tapped.** `TextRun.link` was declared ("a URL the run opens when tapped") and
   printed in the reference, but the renderer built plain spans: nothing took the tap. The tap went to the text's
   own `onTap`, so part 24 wrote the whole status line as tappable.
2. **Runs are worked out from the text by a rule.** A search mark already was (`matchRanges`, `matchRuns`, and
   `map(matchRanges(t, q), r => {start: r[0], end: r[1], style: {...}})` composes any look). Links found in a
   message need every match of a pattern **with where it is**; the formulas had `matches` (true or false) and
   `regexReplace` (new text) but nothing that gives positions.
3. **What a link opens is a function of what was found**: `https://` for a bare `www.`, `mailto:` for an address,
   `tel:` plus the digits for a number. The formulas say that already (`matches`, `contains`, `regexReplace`).

Tried before building (`before.txt` in the session's scratch): styled runs, `matchRuns` and a composed highlight
render; a run with `link` draws but a tap on it runs the node's `onTap`; Markdown underlines a bare domain (and
the domain half of an email) but opens nothing. So 1 and the positions of 2 were missing; everything else composes.

## 2. What is added

| Addition | Where | Why this form |
|---|---|---|
| A run with a `link` takes its own tap | SDK `node_tree.dart` (a `TapGestureRecognizer` per link run on its spans, only where the app runs) | The run already said it; the renderer owns the spans, so the tap is where the characters are, with the platform's link cursor and semantics. The text's other characters keep the text's `onTap`. |
| Trigger `linkTap`, written `onLinkTap`, `result` = `{link, text, start, end}` | API `TriggerType`; SDK `TreeReactions.fire` | One event for every link of a text, as `onRowTap` is for every row of a table: the run names what it is (`link="restart"`, `link="mailto:…"`), the reaction decides. Without a reaction the link opens (`openLink`), so a found URL needs no reaction at all. |
| `regexMatches(text, pattern)` → `[{start, end, text, groups}]` | SDK formula engine | The one missing primitive: every match and where it is, in the offsets a run takes. With `map` it makes runs of any kind (links, hashtags, mentions, marks, a phrase in bold); it is the sibling of `matches` and `regexReplace` and reads the same patterns and inline flags. |
| `a ?? b` | SDK formula parser | `coalesce` existed; writers from Dart and JavaScript write `??` and the expander refused it ("Unexpected ?"). Dart's meaning (`b` only when `a` is null; `coalesce` also skips empty text), between `||` and `? :` as in both languages. |
| A count in braces in a formula's text stays text | API notation `_spans` | `"\d{3}"` was read as a value in braces, `"\d" + (3)`, and the pattern lost its count. A brace holding only a count (`{3}`, `{5,}`, `{2,4}`) reads nothing (no one writes `{3}` to show 3). |
| Markdown links open | SDK `markdown.dart` | Markdown's link runs now carry their address (a bare domain gets `https://`), so they take the tap like any link; the domain half of an email is no longer drawn as a link. |
| `--tap <text>@link:<label or n>` | SDK render tool | To drive a link in a render: by its characters, a part of them, or its number; `--dump-layout` lists a text's links as its `parts`. |

Nothing named is added: no `autoLink`, no `linkify`, no link colour key. "Find URLs, emails and phones" is a pattern
and a mapping, so it is a word of the project's dictionary (`AutoLinkText`, `PhraseLinks` in
`vocabulary/words/`), written in these base words, and a writer can change any part of it on a page.

## 3. What a writer writes

```notation
state body="Write care@nocd.com or call +1 555 010 2233 for help."
state q="help"
Text "{body}" runs={concat(map(regexMatches(body, "[\w.+-]+@[\w-]+(\.[\w-]+)+|\+?\d[\d ]{6,}\d"), m => {start: m.start, end: m.end, link: contains(m.text, "@") ? "mailto:" + m.text : "tel:" + replace(m.text, " ", ""), style: {color: "#FF2563EB", decoration: "underline"}}), map(matchRanges(body, q), r => {start: r[0], end: r[1], style: {backgroundColor: "#FFFDE68A"}}))}
Text "{status}" runs={map(regexMatches(status, "Restart therapy"), m => {start: m.start, end: m.end, link: "restart", style: {fontWeight: 700}})} onLinkTap={open restartSheet}
Text "{(route.entry ?? entry) == 'subtype' ? 'Pick one' : ''}"
```

With the dictionary: `AutoLinkText "{message.text}" query={q} linkColor=#FFFFFFFF size=16`,
`PhraseLinks "{legal}" phrases="Terms|Privacy Policy" onLinkTap={go {result.link}}`.

## 4. What composes with it

- Any run source: `matchRuns`, `matchRanges`, `regexMatches`, a list written out, Markdown's runs (a text's
  `markdown` still replaces its written runs, as before). `concat` puts them together; where two runs style the
  same characters the later one's keys win, and of the runs over a character the last one with a `link` is the one
  tapped.
- The link is a value, so it can be bound (`link: "/post/" + m.groups[0]`), and `onLinkTap` can do anything an event
  does: `go`, `open`, `copy "{result.link}"`, `link {result.link}` after a confirm.
- The renderer's own text features keep working over it: `maxLines`, `selectable`, a typewriter (its plain text),
  `defaultTextStyle`, right-to-left text.

## 5. Not done, open

- Text fields: runs in an editable field (`TextFieldProps.runs`, Markdown preview) do not take taps; an editor's
  caret wins there.
- A long press on a link (copy the address, as iOS does) is not a separate event; `onLongPress` is the text's.
- A formula's text with a value read *and* a backslash (`"\d" + {n}` written `"\d{n}"` with `n` a value) is joined
  with JSON's escapes, which the formula engine does not undo: the pattern gets `\\d`. Written as two strings
  (`"\d{" + n + "}"`), it is right. Unchanged here.
- The JSON reference (`docs/reference/*.md`, `catalog.json`) was not regenerated in this checkout: its generator
  fails on the checkout's CRLF files (the known `reference_test` failure). The notation reference was.
