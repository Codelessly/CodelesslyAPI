# Screens, navigation, modals and toasts

## When to use

Several screens and moving between them, a page's URL path, passing values to a screen, dialogs, bottom sheets
and popovers, confirmations and toasts, app bars, navigation bars, tabs and disclosure (accordions).

## Minimal example

Two screens: a list that opens a detail screen with a parameter, a modal, and a toast:

{{example:navigation}}

## Reference

{{reference}}

## Patterns

### Screens

Each canvas in `roots` is a screen, unless canvases are grouped: canvases with the same `props.screen` are one
screen, one canvas per breakpoint ([a canvas per breakpoint](@layout-a-canvas-per-breakpoint)). A canvas is the
`Scaffold` of its screen: put the page content in its `body` slot, usually a column filling it. Its
`decoration.fills` is the page background; its `layout` is its design size (on a device the canvas takes the
screen's size).

A site's pages may be separate documents (one file per page, checked and rendered together); `navigate` then names a
canvas id of another document. Give a canvas a `"path"` (`"pricing"`, a top-level key of the canvas node, not a
prop) for its URL; without one it gets a path from its name. The first screen of the first document is the entry
screen.

### Going to a screen and back

`{"type": "navigate", "to": "<canvas id>"}` pushes the screen; `"mode": "pop"` goes back; `"replace"` and `"reset"`
replace the history. For a screen with a canvas per breakpoint, name any of them. `"params": {"id": "${item.id}"}`
passes values the destination reads as `${route.id}`. `transition` picks the animation (`fade`, `slideUp`...).

### Modals and toasts

`{"type": "openModal", "to": "<canvas id>"}` shows another canvas over the screen, at its design size
(`presentation`: `dialog`, `bottomSheet`, `fullScreen`, a popover anchored to a node...). Inside it,
`{"type": "closeModal"}` closes it, and its value becomes the opener's `${result}`. The modal canvas is a root like
any screen; give it the size of the dialog. `{"type": "showToast", "message": "Saved", "style": "success"}` shows a
short message; `confirm` asks yes or no and runs `actions` or `cancelActions`.

### A mobile menu (drawer)

A menu button that toggles a `menuOpen` variable, and the menu a node bound `"visible": "${menuOpen}"`. As an
overlay over the page: the canvas body is a `stack` filling it, the page's scrolling column first and the menu
panel last (fill width, placed at `"y": 64`), hidden unless open; or open it as a modal (`"presentation":
"fullScreen"` or a sheet). A link in the menu closes it (`setVariable menuOpen false`) and navigates. The render
command captures the open state with `--tap menuButton`; an overlay sized to the window is drawn in the first
window of a `--full-page` capture.

### Tabs and an accordion (FAQ)

Tabs from a variable: a row of tab labels whose `selected` binds to `${= tab == 'lunch'}` with a click that sets
`tab`, and the panels bound `visible` on `tab` (the `tabs` and `tabBar` node types do the same with Material's
look). An FAQ where several items may be open: a list variable of open indices; an item's click sets
`${= contains(open, index) ? without(open, index) : append(open, index)}`, its answer is visible while
`${= contains(open, index)}`, and its icon turns (`motion.rotate`) with a transition.

### App bars and navigation bars

A canvas's `appBar` slot spans the top at its own height and `bottomNavigationBar` the bottom; the body sits
between, and `floatingActionButton` sits 16 px from the right above the bottom bar. `navigationBar` and
`bottomNavigationBar` take destinations (icon, label) and report the chosen index through `changed`.

## Pitfalls

- `to` names a canvas id; a screen that is not a root cannot be shown.
- A modal shows its canvas at its design size: give the modal canvas the dialog's size, not the screen's.
- `${route.<param>}` exists only on the screen navigated to with `params`.
- A canvas's `path` is a top-level key of the canvas node, not a prop.
- Menus hidden behind `hovered` never open on touch screens.

## See also

[State](@page-state) (variables kept across screens: `page_variables`) · [interaction](@page-interaction) (keys,
hover) · [responsive layout](@page-layout) (a canvas per breakpoint) · [animation](@page-animation) (route
transitions).
