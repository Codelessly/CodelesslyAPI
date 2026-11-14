# The render command: checking your work

## When to use

Checking a document or a site before trusting it: strict validation, screenshots at each size, the states after
taps, typing and scrolling, and a diagnostic for every problem with a code, a JSON pointer and what to do. The
command lives in the SDK repository (`tool/render/render.sh`; its README has every option).

## Minimal example

The smallest document, and the command that checks it at three sizes:

{{example:minimal}}

```sh
tool/render/render.sh home.json --out shots/ --sizes 390x844,834x1112,1440x900 --full-page
```

## Reference

### What it does

Decoding is lenient: a misspelled key, a value of the wrong shape or an unknown enum value is silently ignored or
replaced by its default. Never trust a document that has not been checked. The command validates every document
strictly, renders each screen with the SDK at each size, writes `shots/<screen>@<w>x<h>.png` and
`shots/diagnostics.json`, and prints one line per problem with a code, the JSON pointer of the value
(`/nodes/hero-title/props/style/fontSize`) or the node, and what to do. It exits 1 when there are errors.

### Steps before the capture

In order: `--tap <id>` (`<id>#<n>` for the n-th copy of a list item; a node out of view or under an overlay is
scrolled to the middle first, and a tap that would land on another node is reported, not made), `--hover <id>`,
`--focus <id>`, `--unfocus`, `--type <id>=<text>`, `--key <key>`, `--set <variable>=<json>`, `--scroll <id or
screen>=<px>`, `--drag <id>=<dx>,<dy>` (or `=<other id>`: onto a node), `--navigate <screen>`, `--wait <ms>`. A step
may name a node by its `name` too. In a site, steps name nodes inside components by path (`--tap plans/card1/cta`)
and a node in a list's copy as `<template>#<n>/<node>` (`evCard#0/evReserve`, the same as `evReserve#0`). Ids are
per document, so a page, a component and an open modal may share one: a step naming an id two shown nodes have is
an error listing how to name each (`page/saved`, the page's own under its canvas id; `footer/saved`, the
component's). A step on a node hidden at one size (a media rule, another breakpoint's canvas) is skipped there with
a note; the others run. `--navigate` takes a canvas id, a screen name or a URL path, with a query string for the
params the screen reads as `${route.<name>}` (`--navigate speaker?id=ada`, `--navigate /project?id=7`); later steps
act on the screen navigated to. A `--set` holds: a timer or `load` reaction that writes the variable afterwards does
not change the capture (`set_overwritten` says it happened); `--now <ISO time>` pins `now()`. A tap, a drag or a
navigation first unfocuses a focused text field elsewhere, as a click outside it does. `--label <name>` keeps the screenshots and
`diagnostics-<name>.json` of each state apart. After each step the page settles before the next one and the capture
(about a second): an animation shorter than that is over when the screenshot is taken; to see one mid-flight,
lengthen its duration in a copy. `--key` presses a key for the screen's `keyDown` reactions; it does not submit a
focused text field (test `submitted` chains through a button). In nested lists `#n` counts the copies across the
whole repeat, outer item by outer item, from 0: with a 7-day grid per habit, `day#9` is the second habit's third
day. `--full-page` captures the whole page from its top, its own scroll
height, as a reader sees it: content fixed to the window and an open modal (with its dimmed backdrop) in the first
window, a sticky node once in its place, and after a navigation the page navigated to at its own height; without it
the capture is the window where the steps left the page. `--fonts <dir>` adds font files; `--component <Type>` and `--components-all` render
components alone.

### Validation codes

From `package:codelessly_api/validate.dart`:

{{diagnosticCodes}}

### Render codes

The render step adds what only rendering shows: `render_exception` (naming the node), `action_error`,
`interaction_failed`, `tap_no_reaction`, `layout_overflow`, `offscreen`, `text_clipped`, `text_truncated`,
`text_no_color`, `missing_glyph`, `icon_not_drawn`, `expression_not_evaluated`, `path_overflow`, `font_fallback`,
`fill_fallback`, `image_failed`, `image_network`, `empty_screen`, `invalid_json`, `component_missing`,
`set_overwritten`. Links to a screen that is missing are one `unknown_screen` per screen, with how many links name it. Formulas are
parsed by the SDK's own parser there, so formula syntax errors and unknown names in formulas are reported only by
the render command.

{{reference}}

## Patterns

### A loop that converges

Validate and render after each section, read the diagnostics, then look at the PNGs next to the target: validation
cannot tell you that a page is ugly. Fix by the JSON pointer each line gives. Capture each state with its own
`--label` so the files do not overwrite each other.

### Capturing states

The annual price: `--tap billingSwitch --label annual`. An open menu at phone width: `--sizes 390x844 --tap
menuButton --label menu`. An error state: `--type seats=0 --unfocus --label error`. A value set directly:
`--set annual=true`. A detail page with its parameter: `--navigate speaker?id=ada --full-page`. A reordered list or
a slider: `--drag handle#0=0,120`, `--drag volume=80,0`. A countdown before the event: `--now
2026-11-13T09:00:00Z`.

### What a run keeps

Storage, variables and the clipboard live in memory for one run: steps and `--navigate` see what earlier steps
wrote, and each size starts afresh, as does each run (nothing persists between runs, so a "restored on reload"
state is captured by writing it first: `--tap save --navigate home`). `downloadFile` saves its file under
`<out>/downloads/<capture>/` and `copyToClipboard` copies in memory; both are listed in the output and in the
diagnostics file (`downloads`, `clipboard`). `openLink` opens nothing.

### Comparing with a reference

`--compare <dir>` picks, for each capture, the PNG of the same size whose name is the screen and the state exactly
(`section--saved--390x844.png` for `--label saved`, never `section--saved-empty`); with no `--label`, `default` or
no state. When the reference names a page otherwise, map it: `--compare-map home=index`.

## Pitfalls

- Every diagnostic is about the page as it renders at that size: its media rules applied, what scrolls there, what
  an ancestor clips away.
- The command does not fetch network images or fonts: pass local files.
- A `--tap` scrolls the target into view; a `--full-page` capture still starts at the top.
- Runs on one SDK checkout take turns (each waits for the one before): start several, and they finish one after
  another.

## See also

[The base](STARTER.md) · [responsive layout](@page-layout) · [components](@components-rendering-one-part).
