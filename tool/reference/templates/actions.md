An action is a JSON object `{"type": "<type>", ...fields}`, run in order in a reaction's chain. Text fields are
expressions (`"${count}"`, `"${= a + 1}"`). A field holding nested actions (`then`, `else`, `onSuccess`...) is a
list of actions. A key not listed for the type is dropped by decoding and reported by validation
(`unknown_action_key`).
