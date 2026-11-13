`"bind"` on a node maps a **binding path** (a path into the node's JSON) to an expression; the field at the path
takes the expression's value. Paths: `visible`, `opacity`, `layout.<field>`, `decoration.<field>` (with
`[index]`, a paint's `id` or `*` into lists), `props.<prop>` and deeper fields of model props, `data`, `selected`,
`disabled`, and the behavior keys. Values are read loosely: `"12"` is a number, `1` and `"true"` are true,
`"#FF0000"` is a color; a value that cannot be read leaves the field as it was.

Expressions: `${path}` reads a value (`user.name`, `items[0].price`, `pal[item.kind]`), `${= formula}` computes
one ({{page:formulas.md|formula functions}}). A binding that is exactly one expression keeps the value's type.
