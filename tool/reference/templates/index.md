# Index

The reference is one base plus one page per feature area. Read [the base](STARTER.md) first, in full. Then use
this page to find the one section you need: the task table below says where each need is answered, the A–Z lists
every node type, behavior, trigger, action, formula function, model, enum and value type with the page that
documents it, and the page list says what each page covers. Every page has the same sections: When to use,
Minimal example, Reference, Patterns, Pitfalls, See also. At run time the same map is the `ui_docs` tool: a
section's anchor is its topic.

## You need X: open Y

| You need | Open |
|---|---|
| A row that becomes a column at a width; another order or hidden at a width | @@layout-a-row-that-becomes-a-column |
| Content capped at a width and centered inside a full-width band (CSS max-width + margin auto) | @@layout-a-capped-band |
| A page at phone, tablet and desktop: one column, a split with a sticky rail, columns with a spanning lead | @@layout-an-editorial-page-at-three-sizes |
| A grid item spanning two columns or rows; items placed at a row and column (a timetable that is a list on phones) | @@layout-grid-spans-a-timetable |
| Cards three across that wrap to two, then one, with no breakpoint | @@layout-cards-that-wrap |
| Equal-height cards in a grid; a banner above one card; a button pinned to a card's bottom | @@lists-equal-height-cards |
| Overlap the section above (a negative margin); bleed past the page gutter | @@layout-overlap-and-bleed |
| A sticky or fixed header; a table's sticky first column | @@layout-a-sticky-header-or-column |
| Make the page scroll; scroll sideways; scroll to a node | @@layout-scrolling |
| A media rule and a binding on the same field (phones only, and only while closed) | @@layout-a-media-rule-and-a-binding-on-one-field |
| Responsive design step by step; values computed from the screen width | @@layout-responsive-design |
| The breakpoints and their widths | @@layout-breakpoints |
| Why a fill took its design size (`fill_fallback`); which sizes a parent allows | @@layout-which-sizing-modes-each-parent-allows |
| Every layout field (constraints, aspectRatio, widthFactor, order, basis...) | @@layout-layout-fields |
| A screen designed separately per breakpoint | @@layout-a-canvas-per-breakpoint |
| Name the palette and the type scale once (the theme) | @@theme-named-colors-and-styles |
| A type size that grows at tablet and desktop, written once | @@theme-a-type-scale-that-changes-with-the-screen-size |
| Dark mode | @@theme-dark-mode |
| Part of a text in another style, a link in text; text defaults | @@theme-text |
| A raised currency sign or a superscript | @@theme-superscripts-and-a-raised-currency-sign |
| Fonts, and characters the font cannot draw | @@theme-fonts |
| Every theme key | @@theme-theme-keys |
| Linear and radial gradients, a soft glow | @@decoration-gradients |
| Background grid lines, a repeating pattern in pixels, grain | @@decoration-a-pattern-in-pixels-a-background-grid-grain |
| A border on one side, a rule under a text, dashed borders, shadows, frosted glass | @@decoration-borders-rules-and-shadows |
| A dark gradient over a photo with a caption | @@decoration-a-scrim-over-a-photo |
| A border hidden by a child's fill (paint order) | @@decoration-borders-rules-and-shadows |
| Images (local files, cover, aspect ratio) | @@decoration-images |
| Icons, their size and style | @@decoration-icons |
| A star, sparkle or other mark the font does not have; a custom shape | @@decoration-small-marks-and-shapes |
| Style a text field (border, focus ring, fill, label, icons), a checkbox, a switch or a button, in one place | @@forms-styling-the-controls-in-one-place |
| A text field that shows a variable and writes it back (two-way) | @@forms-a-text-field-bound-to-a-variable-two-way |
| Validate a form: per-field errors on blur or on send, the first error focused, a summary, a success state | @@forms-validation-and-an-error-state |
| A radio group (one choice of several) | @@forms-a-radio-group |
| A − / + stepper around a number field | @@forms-a-stepper-around-a-field |
| A search icon or a clear (×) button inside a text field | @@forms-a-clear-button-in-the-field |
| A checkbox or switch with a label, toggled from the whole row | @@forms-a-labeled-checkbox-or-switch |
| Add and remove items of a list (a list editor) | @@forms-add-and-remove-items-a-list-editor |
| Focus a field; keyboard keys; arrow keys between tabs | @@forms-focus-and-the-keyboard |
| A button's label, colors, corners and label size | @@forms-buttons |
| Every prop of a text field | @@node-textField |
| Repeat one template per item of a list | @@lists-one-template-from-data |
| A grid of cards from data, as many columns as fit; gaps between wrapped items | @@lists-a-grid-of-cards |
| Nested lists; the outer item inside the inner list (`parent`) | @@lists-nested-lists |
| A comparison table from one row and one cell template | @@lists-a-table-from-one-template |
| Filter, sort, page a list | @@lists-filter-sort-and-page-a-list |
| A weekly grid (days × habits) | @@lists-a-weekly-grid |
| A carousel with arrows, dots and progress; snapping to cards; scroll to an item; long lists loaded in pages | @@lists-a-carousel-pages-and-pagination |
| Several screens; a page's URL path | @@navigation-screens |
| Go to a screen with parameters, and back | @@navigation-going-to-a-screen-and-back |
| A dialog, a bottom sheet, a popover, a toast, a confirmation | @@navigation-modals-and-toasts |
| A mobile menu (drawer) that opens over the page | @@navigation-a-mobile-menu-drawer |
| Tabs; an FAQ accordion where several items may be open | @@navigation-tabs-and-an-accordion-faq |
| An app bar, a bottom navigation bar, a floating button | @@navigation-app-bars-and-navigation-bars |
| Declare variables; screen, page and project scope | @@state-variables |
| A value derived once from others (computed variables), a reusable formula (function variables) | @@state-computed-and-function-variables |
| The value each binding path expects (lists for padding, names for enums) | @@state-binding-paths |
| Every formula function: text, numbers, money, lists, objects, dates, colors | @@state-formula-functions |
| A count, a total, a streak from data; dates | @@state-a-streak-and-other-counts-from-data |
| Toggle, add, append, remove at an index (setVariable ops); if / else in a chain | @@state-changing-state-from-a-reaction |
| Set several nodes while a test holds (conditions) | @@state-conditions |
| Logic with loops or several steps (scripts) | @@state-when-to-use-a-script |
| A literal `$` before a value; `${false}`; what an expression may read | @@state-expressions |
| Hover and pressed styles; a selected style | @@interaction-hover-press-and-other-states |
| A monthly / annual toggle | @@interaction-a-segmented-toggle-monthly-annual |
| Every trigger, and what `${result}` holds in a chain | @@interaction-reactions |
| Drag and drop; reorder a list | @@interaction-drag-and-drop |
| A custom slider, swipe to dismiss, pinch and rotate | @@interaction-values-set-by-dragging-swiping-pinching |
| Animate a change (a check-off, a selected card, an opening panel) | @@animation-animate-a-change-transitions |
| Move, scale or rotate a node without changing layout | @@animation-move-scale-or-turn-without-changing-layout-motion |
| A keyframe animation or a preset that plays on its own | @@animation-play-an-animation-animations-and-presets |
| Reveal on scroll | @@animation-reveal-on-scroll-view-progress-sticky-effects |
| A timer, a clock, a game loop | @@animation-clocks-and-game-loops |
| Split a page into components and sections; when to use which | @@components-when-to-make-what |
| Every component parameter kind (number, list, object, json, variable...) | @@components-parameter-kinds |
| State shared between a page and a component | @@components-shared-state-variable-parameters |
| Pass children into a component (slots); events out of it | @@components-slots |
| The site manifest (`site.json`) | @@components-the-site-manifest |
| Render one component alone | @@components-rendering-one-part |
| A whole multi-page site: manifest first, shared header and footer, route parameters, storage, a modal | @@components-a-complete-multi-page-site |
| A list kept per page or per item (a key built from `${route.id}`) | @@data-storage-on-the-device |
| A reading-progress bar driven by the page's scroll | @@layout-scroll-progress |
| A progress bar or ring bound to a value | @@charts-progress-from-state |
| Bar, line and series charts | @@charts-charts-from-data |
| Call an HTTP API and show the result | @@data-call-an-api-and-show-the-result |
| Keep a value on the device | @@data-storage-on-the-device |
| Show the signed-in user | @@auth-show-the-signed-in-user |
| Capture the states (after a tap, typing, an open menu) with the render command | @@render-capturing-states |
| Every validation and render code | @@render-validation-codes |
| Build and edit with ops; streaming; the retry protocol | @@edit-ops-the-ops |
| How one value type is written (color, alignment, insets) | @@values-colors-and-alignments |

## The pages

{{pageTable}}

## A–Z

Every declared name and the page that documents it.

{{az}}

## Old links

The guide that was `index.md` was split into the base and the pages. Its sections went here:

{{movedGuide}}
