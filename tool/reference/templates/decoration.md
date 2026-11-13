A node's `"decoration"` object: what its box paints. Types without a box decoration (see
{{page:nodes.md|node types}}) keep only blur effects. Fills paint bottom to top, then the node's content, then
`foregroundFills`, then strokes.
