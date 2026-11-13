# codelessly_api guide

For `codelessly_api` 22.x. The samples here run as
[`example/example.dart`](../../example/example.dart) and
[`example/guide.dart`](../../example/guide.dart) (`dart run --enable-asserts example/guide.dart`).

`codelessly_api` is the data model of Codelessly: what the Editor saves, what a publish contains and what the SDK
renders. It is pure Dart. To show layouts in a Flutter app you want the
[SDK guide](https://github.com/Codelessly/CodelesslySDK/tree/master/docs/guide) instead; read this one to
understand, build, check or transform layouts as data.

![codelessly_api between the Editor, which saves layouts, and the SDK, which renders them; your tools read, build, check and transform layouts](images/index/hero.png)

*The model, between the Editor and the SDK.*

| # | Chapter | |
|---|---|---|
| 1 | [The data model](01-data-model.md) | Node, layout, decoration, props, document |
| 2 | [Widgets and `WidgetSpec`](02-widgets-and-widgetspec.md) | The widget declarations, prop types, introspection |
| 3 | [The JSON format](03-json-format.md) | Schema version, total decoding, sparse encoding, the publish format |
| 4 | [Building and checking a layout in code](04-building-layouts-in-code.md) | Typed construction, editing, validation, a bundle for the SDK |
| 5 | [Logic](05-logic.md) | Variables, conditions, bindings, reactions and actions, scripts |
| 6 | [Chart data transitions](06-chart-data-transitions.md) | Data matching, animation controls, interrupted updates and gaps |
| 7 | [Drawing with `customPaint`](07-custom-paint.md) | Flutter's `CustomPaint` and `Canvas` calls as data: ops, paints, expressions, hit regions |
| 8 | [Animation](08-animation.md) | `AnimationController` and `Tween` as data: `animations`, tracks, presets, `animate`, `frame`, `Spring`, the schema-2 keys |
| 9 | [Catalogs, libraries and plugins](09-catalogs-and-plugins.md) | `Catalog`, the core and feature libraries, native plugins, catalog JSON, hosted plugins as data |
| 10 | [Gestures](10-gestures.md) | `track` (Flutter's `Slider` on any path), `dismissible`, `pan`, `draggable`/`dropTarget`, the control actions, the schema-2 `drag` |
| 11 | [Edit operations and streaming](11-edit-ops-and-streaming.md) | Six id-addressed ops, per-op validation, revisions and undo, streaming tool input, the outline, the two LLM tools, the trust profile |
| 12 | [Migrating to schema 3](12-migrating-to-schema-3.md) | Schema 2 documents load, migrated in memory; `migrate2to3`, the report, `tool/migrate.dart`, what was rewritten and what was dropped |
| 13 | [Migrating to schema 4](13-migrating-to-schema-4.md) | One Transform and one Hero: the node's `scale` and `layout.rotation` are its `motion`, `flightKey` and `flight` its `hero`; `migrate3to4`, what was rewritten and what is reported |

For authors who write documents directly (people and AI agents), the generated reference is
[`docs/reference`](../reference/README.md): one base to read first ([`STARTER.md`](../reference/STARTER.md)), a page
per feature area with the same sections (When to use, Minimal example, Reference, Patterns, Pitfalls, See also), and
an [index](../reference/index.md) from needs and names to sections. At run time the same base and pages are a
model's system prompt (`runtimeStarter()`) and its `ui_docs` tool (`docsTopic`).

For contributors, [`DESIGN.md`](../../DESIGN.md) is the full design of the format.
