# Value types, models and enums

## When to use

Looking up how one value is written: a value type (a colour, an alignment, insets), a model no feature page shows
(its fields) or an enum (its names). Link to one with `values.md#type-<Name>` or `values.md#enum-<Name>`. Models
that belong to a feature are on that feature's page (TextStyle on the theme page, InputDecoration on the forms
page...); the [A–Z](index.md#index-a-z) finds any of them.

## Minimal example

Value types are written in a compact form of their own; models are objects; enums are names:

```json
{"color": "#FF2563EB", "padding": [16, 8, 16, 8], "alignment": [0, -1], "fit": "cover"}
```

## Reference

Decoding is lenient and never fails: a value it cannot read becomes the field's default, which is why validation
reports it.

### Value types

{{valueTypes}}

### Models

Objects with declared fields. Keys not listed are reported by validation (`unknown_field`).

{{models}}

### Enums

Written as the value's name, a JSON string (`"center"`).

{{enums}}

## Patterns

### Colours and alignments

A colour is `"#AARRGGBB"`, `"#RRGGBB"` or a theme colour's name. An alignment is `[x, y]` from -1 to 1 or a name
(`"topCenter"`, `"centerRight"`).

## Pitfalls

- Padding and margin are a number or four numbers; a list of two is not read.
- An enum value is case sensitive.

## See also

[The index](index.md) (every name, A–Z).
