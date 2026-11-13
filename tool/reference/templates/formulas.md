The functions a formula (`${= ...}`) can call, extracted from the SDK's formula engine
(`FormulaEvaluator.functionDocs`). Formulas also have arithmetic (`+ - * / %`), comparisons (`== != < <= > >=`),
`&&`, `||`, `!`, `cond ? a : b`, string and number literals (`'text'`, `"text"`, `3.5`), lists (`[1, 2]`), paths
(`user.name`, `items[0]`), and lambdas for list functions (`x => x.price`).

Formulas are written inside JSON strings, so a backslash in a formula (a regular expression's `\d`) is written
twice in the JSON: `"${= matches(code, '^\\d{4}$')}"`. A text that is exactly one formula keeps the value's type;
inside other text a number is printed without trailing zeros (`${= 2.50}` prints `2.5`).
