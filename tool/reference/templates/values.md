How values are written in JSON. **Value types** are written in a compact form of their own (a color as
`"#AARRGGBB"`). **Models** are JSON objects with the fields listed. **Enums** are written as the value's name.
Decoding is lenient and never fails: a value it cannot read becomes the field's default, which is why
validation reports it.
