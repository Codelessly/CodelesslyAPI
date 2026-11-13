Every node type, generated from its declaration (`Widgets.all`). For each: what it is (with the Flutter widget it
corresponds to, when its declaration names one), how it takes children, and every prop with its JSON type,
default, allowed values and description. Props go under the node's `"props"` key; a key not listed here is
reported by validation (`unknown_prop`). The types link to {{page:values.md|value types, models and enums}}.

"Reads from each child's layout" lists the placement fields the type reads ({{page:layout.md|layout}}): a child
of a stack is placed by `x` and `y`, a child of a row or column by `flex`, `squeezable` and `align`.
