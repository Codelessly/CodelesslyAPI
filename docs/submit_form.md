# Generic local form submission

The existing `submitForm` default remains `service: mailchimp`; legacy email,
name and provider fields retain their meanings and JSON shape.

`service: local` submits arbitrary JSON without any network or provider setup:

```json
{
  "type": "submitForm",
  "service": "local",
  "payload": "${answers}",
  "validationScript": "prepareSubmission",
  "validationArguments": {"schema": "${schema}", "answers": "${answers}"},
  "responseVariable": "responses",
  "prepend": true,
  "resultVariable": "submission",
  "onSuccess": [{"type": "setVariable", "variable": "done", "value": "true"}],
  "onError": [{"type": "setVariable", "variable": "errors", "value": "${result.errors}"}]
}
```

- `payload` is an expression yielding a JSON object. It may be omitted if a
  validator supplies the payload.
- `validationScript` is optional. Its named `validationArguments` are evaluated
  like `runScript` arguments. The sandbox run is awaited before storing anything.
  It must return `{valid: boolean, errors?: object, payload?: object}`. A valid
  result's `payload` replaces the input, enabling hidden-answer removal,
  normalization, metadata and versioned schemas in tested scripts.
- A failed validator, malformed validation result or invalid payload stores
  nothing. Validators should be pure except for `clock` when timestamps are
  needed. Their own granted host capabilities are unchanged.
- `responseVariable`, when set, must name a mutable list variable. A deep JSON
  snapshot is appended, or prepended when `prepend` is true. Mark the variable
  `persist: true` to retain submissions through the normal SDK storage service.
- `resultVariable` receives `{ok, value, error, errors}` before callbacks. On
  success `value` is the submitted snapshot, `error` is null and `errors` is
  empty. On failure `value` is null, `error` is `{code, message}` and `errors`
  holds field errors. `${result}` exposes the same canonical fields.
- `onSuccess` runs only after storage. `onError` handles rejection/failure. A
  failure with no error callback stops the chain. Callback failures do not
  retry or duplicate an already stored submission.

Stable failure codes: `validation_failed`, `validation_script_failed`,
`invalid_validation_result`, `invalid_response_variable`, `invalid_payload`.
The local handler never calls Mailchimp, HTTP, auth, purchases or cloud data.
A remote destination can remain an explicit subsequent action in `onSuccess`.
