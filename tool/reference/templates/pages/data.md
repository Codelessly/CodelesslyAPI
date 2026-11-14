# Data: APIs, cloud data, storage and form submission

## When to use

The `data` feature library: calling HTTP APIs, reading and writing the project's cloud documents and files,
storing values on the device, and submitting forms. Not in the agent trust profile at run time (a host enables it).

## Minimal example

A value saved on the device and read back as `${storage.theme}`:

{{example:pages/data}}

## Reference

{{reference}}

## Patterns

### Call an API and show the result

`callApi` names an API of the publish model (`services.apis`: method, URL, headers, body with `${input}`
placeholders) and passes `params`; its result is `${result}` in `onSuccess` (store it with `setVariable`), the
error in `onError`. Show a loading state with a variable set before the call and cleared in both chains.

### Cloud documents

`cloudData` creates, updates, deletes, reads, queries or aggregates documents of a collection (`whereFilters`,
`orderByFilters`, `limit`); its result goes in `resultVariable`. A list bound to a cloud query loads its pages
through the list's `pagination`.

### Storage on the device

`setStorage` writes `${storage.<key>}` (a key may be a path into a stored map or list; `op` as `setVariable`'s:
`set`, `add` appends to a list, `insert` puts at an `index`, `remove` takes a value out). A variable with
`"persist": true` is kept on the device too.

- **Restore on load**: a canvas `load` reaction copies storage into a variable, `{"type": "setVariable",
  "variable": "saved", "value": "${= coalesce(storage.saved, [])}"}`; write it back after each change with
  `{"type": "setStorage", "key": "saved", "valueType": "list", "value": "${saved}"}`.
- **A key per page or item** (a checklist per route): the key is an expression, `"key": "packed.${route.id}"` with
  `"op": "add"`, `"valueType": "list"`, `"value": "${item}"`; read it with `${= coalesce(get(storage.packed,
  route.id), [])}`. A persisted variable is one value for every route.
- The render command keeps storage in memory for one run: steps and `--navigate` see what earlier steps wrote; each
  size and each run starts empty.

A whole site using both: [a complete site](@components-a-complete-multi-page-site).

### Submit a form

`submitForm` validates the answers and stores them (`service: local`), or sends them to a destination the project
declares; `onSuccess` and `onError` run after. See `docs/submit_form.md` in the package.

## Pitfalls

- These actions are not in the agent trust profile: a runtime model may document them but not use them unless the
  host allows the `data` catalog.
- An API's URL and secrets live in the publish model, never in the document.
- `${result}` is the response only inside `onSuccess`.

## See also

[State](@page-state) (where results go) · [forms](@page-forms) (validation before submitting) · [auth](@page-auth)
· [lists](@page-lists) (pagination).
