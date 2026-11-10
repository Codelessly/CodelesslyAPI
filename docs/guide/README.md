# codelessly_api guide

For `codelessly_api` 20.x (the code in [`v2/`](../../v2)). The samples here run as
[`v2/example/example.dart`](../../v2/example/example.dart) and
[`v2/example/guide.dart`](../../v2/example/guide.dart) (`dart run --enable-asserts example/guide.dart`).

`codelessly_api` is the data model of Codelessly: what the Editor saves, what a publish contains and what the SDK
renders. It is pure Dart. To show layouts in a Flutter app you want the
[SDK guide](https://github.com/Codelessly/CodelesslySDK/tree/master/docs/guide) instead; read this one to
understand, build, check or transform layouts as data.

| # | Chapter | |
|---|---|---|
| 1 | [The data model](01-data-model.md) | Node, layout, decoration, props, document |
| 2 | [Widgets and `WidgetSpec`](02-widgets-and-widgetspec.md) | The widget declarations, prop types, introspection |
| 3 | [The JSON format](03-json-format.md) | Schema version, total decoding, sparse encoding, the publish format |
| 4 | [Building and checking a layout in code](04-building-layouts-in-code.md) | Typed construction, editing, validation, a bundle for the SDK |
| 5 | [Logic](05-logic.md) | Variables, conditions, bindings, reactions and actions, scripts |
| 6 | [The migrate package](06-migrate-package.md) | Converting v1 (10.x) documents to v2 |

For contributors, [`v2/DESIGN.md`](../../v2/DESIGN.md) is the full design of the format, and
[`docs/STANDARDS.md`](../STANDARDS.md) the coding standards.

Package names: on pub.dev the package is `codelessly_api`. In this repository the 20.x sources are in `v2/` under
the name `codelessly_api_v2` (renamed at publish), so code in the repository imports
`package:codelessly_api_v2/codelessly_api.dart`. The repository root holds 10.x, which is legacy.
