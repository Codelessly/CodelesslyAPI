# Generic local form submission

`submitForm` validates a form's answers and stores them in the app's own
variables, without any network or provider setup. `service: local` is the
default and the only service:

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
The handler never calls a third-party service, HTTP, auth, purchases or cloud
data. A remote destination is an explicit later action in `onSuccess`, such as
`callApi` to an endpoint the app defines.

## Older newsletter submissions

Versions up to 23.0.0 also had a built-in newsletter service (`service:
mailchimp`, the default then, with `emailField`, `firstNameField`,
`lastNameField`, `apiKey`, `dataCenter` and `listId`). It has been removed:
a published app must not hold a provider's API key, and the packages do not
call third-party services.

Stored JSON with that service, or with no `service` and those fields, or with
a service this version doesn't know, still decodes: as `service: unsupported`,
its provider fields read past and never written back out. At run time it sends
nothing and fails with `{code: unsupported_service}` in `${result}` and
`resultVariable`; `onError` runs if set, otherwise the chain stops and the
failure is reported like any failed action.

To keep collecting sign-ups, replace it with a `callApi` action to your own
endpoint (which holds the provider's key server-side), or with a local
submission whose `onSuccess` calls that endpoint.
