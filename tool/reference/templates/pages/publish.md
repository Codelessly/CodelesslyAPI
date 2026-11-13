# Publish, managed components and plugins

## When to use

What happens to documents after they are written: a published app's model (its layouts, components, theme and
identity), page paths and titles, components published by reference, managed component releases and hosted
plugins. Read it when you set a canvas's URL path or title, or ship components others reuse; the documents
themselves do not change.

## Minimal example

A page whose canvas has a URL path and a name (its default title):

{{example:pages/publish}}

## Reference

### The publish model's parts

{{publishClasses}}

{{reference}}

## Patterns

### A page's URL and title

A canvas's `"path"` is its URL (`/pricing`); without one it gets a path from its name. The app identity's title
template (`${page.title} · ${app.name}`) makes each page's title; a page can override its title and description.

### Components by reference

A published site carries its components beside its pages; an app loads the ones a screen calls with the screen,
caches them, and follows a republished one: every instance updates where it is. Nothing to write in the
documents ([published components](@components-published-components)).

## Pitfalls

- The publish model is written by the editor and the publish tools, not by hand in a page document.
- A component's file must be named after its type.

## See also

[Components](@page-components) · [engage](@page-engage) (automations live in the publish model) ·
[data](@page-data) (APIs live in the publish model).
