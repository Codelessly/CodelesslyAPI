A node's `"layout"` object: its size, spacing, and placement in its parent. See the guide's
{{link:index.md#guide-layout|Layout}} section for how the modes behave, with examples.

`width` and `height` are an {{link:values.md#type-AxisSize|AxisSize}}: a number (fixed) or `{"fill" | "hug" |
"flexible" | "fixed": number}`. `x` and `y` are an {{link:values.md#type-AxisPosition|AxisPosition}}. The default
size is fixed 0: a node without a width and a height draws nothing.
