A node's `"decoration"` object: what its box paints. Types without a box decoration (see
{{page:nodes.md|node types}}) keep only blur effects. Fills paint bottom to top under the node's content;
`foregroundFills` paint over it, **children included** (Flutter's `foregroundDecoration`): a scrim in a photo's
`foregroundFills` darkens a caption inside the photo node too; put the caption after a gradient box instead.
Every color may be a theme color's name (`"ember"`).
