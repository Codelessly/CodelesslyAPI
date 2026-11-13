A reaction (`"actions": [{"trigger": {...}, "actions": [...]}]` on a node) starts on its trigger. In the chain,
`${result}` first holds the trigger's event (where a click landed, an input's new value). Screen triggers (`load`,
`valueChanged`, `timer`, `keyDown`...) are set on the canvas.
