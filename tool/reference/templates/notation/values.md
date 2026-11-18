# Values

How each value type and enum is written, and the records no other page shows. Open it when you need the form of a
value (a color, an alignment, a size, an edge inset) or the words an enum takes.

## Writing a value

A key's value is written as on any line: a number; a bare word (an enum's value, `true`, `false`, a color
`#AARRGGBB`, a theme name); a quoted string; JSON for a list or a map; `{expression}` for a value that follows the
state. A value type below is written in its JSON form, bare where that is a number or one word.

```notation
Column pad=[16,8,16,8] fill=#FF2563EB radius=8
  Text "x" color=#FFFFFFFF
```

## Other spellings (also read)

This reference writes each thing one way, and that is the way to write it. A model often reaches for another
name; the open vocabulary reads these as the word in the third column (a host that reads with the closed vocabulary
says them instead). They are listed so you know them when you read them, not as forms to write.

{{aliases}}

## Value types

{{valueTypes}}

## Enums

An enum's value is a bare word: `textAlign=center`, `overflow=ellipsis`.

{{enums}}

{{reference}}

{{examples}}
