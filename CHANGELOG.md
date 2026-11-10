## 21.0.1

- Documentation: a cleaner README.

## 21.0.0

**Breaking changes**

- Requires Dart 3.12 or newer.
- Requires `collection` 1.19.1 or newer and `meta` 1.19.0 or newer. If your app pins older versions of either,
  raise them alongside this package.

**New**

- A guide to the model, with runnable samples in `example/`:
  [docs/guide](https://github.com/Codelessly/CodelesslyAPI/tree/master/docs/guide).

The model classes and the JSON format are unchanged from 20.0.1.

## 20.0.1

**New**

- `StyleSheet` holds a project's named text and color styles (`NamedTextStyle`, `NamedColorStyle`).
  `StyleSheet.theme` reads the `ThemeTokens` from them by name.

## 20.0.0

**Breaking changes**

- A new data model and JSON format (`"schema": 2`). Nodes use Flutter's own parameter names, types and defaults, and
  a layout is a `LayoutDocument`: its canvases and every node in one flat map.
- Decoding is total: `fromJson` never throws, unknown keys and node types round-trip, and a bad value falls back to
  its default. Encoding is sparse: values equal to Flutter's defaults are not written.
