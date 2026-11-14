# Design systems

## When to use

Giving every screen one look that is not the renderer's default and not the host app's: a set of components (buttons,
fields, selects, cards, dialogs...) drawn from core nodes, the tokens they are styled with, and the two documents an
author reads first, the principles and the patterns. Use one for a site (`site.json` names it) or for a generated UI
(the app gives it to the session); write one when several projects should share a look.

## Minimal example

A design system is a folder with a manifest, `design_system.json`:

```json
{"id": "acme", "name": "Acme", "version": "1.0.0", "description": "Flat, hairline-bordered, dense.",
 "design": "DESIGN.md", "patterns": "PATTERNS.md",
 "theme": {"primary": "#FF2563EB", "onPrimary": "#FFFFFFFF", "surface": "#FFFFFFFF", "onSurface": "#FF111827",
   "colors": {"border": "#FFE5E7EB"}, "dark": {"surface": "#FF141414", "onSurface": "#FFFFFFFF", "colors": {"border": "#FF383838"}},
   "textStyles": {"body": {"fontSize": 13, "height": 1.5, "color": "onSurface"}},
   "spacing": {"2": 8, "3": 12, "4": 16}, "radii": {"control": 7, "panel": 8}, "sizes": {"compact": 28}},
 "components": ["components/Button.json", "components/Card.json"],
 "replaces": ["filledButton", "outlinedButton", "textButton"]}
```

A site made with it names the folder; its pages call the components by type:

```json
{"schema": 3, "pages": ["home.json"], "designSystem": "../design_systems/acme",
 "theme": {"primary": "#FF7C3AED"}}
```

## Reference

### The manifest

| Key | Meaning |
|---|---|
| `id` | Its id: what a site names when it is published, the prefix of its components' publish paths. |
| `name`, `version`, `description` | Shown to authors; the description is the prompt's first line about it. |
| `design` | DESIGN.md: the principles (look, roles of the tokens, do and don't). Its `## In brief` section is what a prompt quotes. |
| `patterns` | PATTERNS.md: forms, lists, cards, empty, loading and error states, density. Its `## In brief` is quoted too. |
| `theme` | The tokens: a theme as `site.json` takes one, with its named scales (`spacing`, `radii`, `sizes`, `shadows`, `durations`, `curves`) and `dark`. |
| `components` | Its component definitions, in the order its list shows them ([components](@page-components)). |
| `fonts` | The families it ships, files relative to the manifest (a pubspec's `fonts:`). |
| `replaces` | The base node types its components stand in for: a prompt lists the components instead. They stay valid. |
| `examples` | Example documents: a gallery of every component, sample screens. |

A published design system is one bundle, `{"manifest": {...}, "design": "...", "patterns": "...", "components":
{"Button": {...}}}`, read with `DesignSystem.fromJson`; a folder is read with `DesignSystem.load`.

{{reference}}

## Patterns

### What a site gets from it

- **Theme.** The tokens are the site's base theme; the site's `theme` is merged over them key by key (a color, a
  style, a scale step). Named colors and text styles, light and dark, work as in [the theme](@page-theme).
- **Scales.** `${theme.spacing.3}`, `${theme.radii.panel}`, `${theme.sizes.compact}`, `${theme.shadows.level3}` and
  `${theme.durations.fast}` are read in bindings: `"bind": {"layout.padding": "${theme.spacing.3}",
  "decoration.radius": "${theme.radii.panel}"}`. Validation reports a name the theme does not have
  (`unknown_theme_name`).
- **Components.** Called by type as the site's own (`{"type": "Button", "props": {"label": "Save"}}`); a site
  component of the same type wins. Calls are checked against their declarations (`missing_prop`, `unknown_event`).
- **Nothing from the app.** The app the site runs in lends no color, font or shape; without a design system the
  controls are neutral (ink on paper, small radii).

### Writing one

1. Write the tokens first: roles (`primary`, `surface`, `onSurface`, `error`...), named colors with their `dark`
   values, text styles that name colors, and the scales.
2. Draw each component from core nodes (`row`, `column`, `box`, `text`, `icon`): fills, strokes and radii by
   token name, hover and press as interaction `states`, sizes and variants as parameters bound with formulas.
   Wrap a core control only for what only it does (text editing, a native menu), and style every part of it.
3. Give every component a one-sentence `doc` (its purpose) and a first preview (its minimal call).
4. Render a gallery of every component, light and dark: `--components-all --theme dark`.

### In a generated UI

The app gives the session the design system: its catalog then has the components, and the prompt is generated from
it (`runtimeStarter(designSystem: ds)`): the principles in brief, the tokens by name, each component with its
parameters and a call, the patterns in brief, and no rows for the base controls it replaces. `ui_docs "design"`,
`"patterns"` and a component's name give the rest.

## Pitfalls

- A call has no `decoration`: style the definition, or add a parameter (`variant`, `size`).
- A color written in full (`"#FF2563EB"`) does not follow dark mode: name it.
- A scale step is read through a binding, not written where a number goes (`"padding": "md"` is not a number).
- `replaces` hides base controls from the prompt only; documents that use them still validate and render.

## See also

[Components](@page-components) · [theme](@page-theme) (named colors, styles, dark mode) · [forms](@page-forms) ·
[render](@page-render) (`--components-all`, `--theme`).
