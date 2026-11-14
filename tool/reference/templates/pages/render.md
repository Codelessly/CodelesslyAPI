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
screen>=<px>`, `--navigate <canvas id>`, `--wait <ms>`. A step may name a node by its `name` too. In a site, steps
name nodes inside components by path (`--tap plans/card1/cta`). `--label <name>` keeps the screenshots and
`diagnostics-<name>.json` of each state apart. After each step the page settles before the next one and the capture
(about a second): an animation shorter than that is over when the screenshot is taken; to see one mid-flight,
lengthen its duration in a copy. `--key` presses a key for the screen's `keyDown` reactions; it does not submit a
focused text field (test `submitted` chains through a button). In nested lists `#n` counts the copies across the
whole repeat, outer item by outer item, from 0: with a 7-day grid per habit, `day#9` is the second habit's third
day. `--full-page` captures the whole page from its top, its own scroll
height, with content fixed to the window drawn in the first window; without it the capture is the window where the
steps left the page. `--theme light|dark` starts the site in that theme mode (PNG names end `-light`, `-dark`; a
`--tap` on a `setThemeMode` switch then changes it). A site's declared fonts (`site.json`'s `fonts`) and images
named by a path relative to the site are read from its folder with no flag; `--fonts <dir>` adds other font files
(`--fonts system`: the system's). `--component <Type>` and `--components-all` render components alone.

### Validation codes

From `package:codelessly_api/validate.dart`:

{{diagnosticCodes}}

### Render codes

The render step adds what only rendering shows: `render_exception` (naming the node), `action_error`,
`interaction_failed`, `tap_no_reaction`, `layout_overflow`, `offscreen`, `text_clipped`, `text_truncated`,
`text_no_color`, `missing_glyph`, `icon_not_drawn`, `expression_not_evaluated`, `path_overflow`, `font_fallback`,
`font_missing`, `fill_fallback`, `image_failed`, `image_network`, `empty_screen`, `invalid_json`, `component_missing`. Formulas are
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
`--set annual=true`.

## Pitfalls

- Every diagnostic is about the page as it renders at that size: its media rules applied, what scrolls there, what
  an ancestor clips away.
- The command does not fetch network images or fonts: put the files beside `site.json` and name them by their
  relative path.
- A `--tap` scrolls the target into view; a `--full-page` capture still starts at the top.

## See also

[The base](STARTER.md) · [responsive layout](@page-layout) · [components](@components-rendering-one-part).
