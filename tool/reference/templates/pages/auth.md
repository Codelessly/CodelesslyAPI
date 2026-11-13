# Auth: signing users in

## When to use

The `auth` feature library: signing app users in, up and out, and managing their account, with `${auth}` to show
who is signed in.

## Minimal example

A sign-in form whose error appears in a text:

{{example:pages/auth}}

## Reference

{{reference}}

## Patterns

### Show the signed-in user

`${auth.isSignedIn}`, `${auth.email}`, `${auth.displayName}`, `${auth.initial}`, `${auth.role}` bind like any value: a header shows "Sign in" or
the user's name by `visible` bindings on `${auth.isSignedIn}`.

### Errors

A failure's message goes in `errorVariable` and stops the chain: actions after `auth` run only on success.

## Pitfalls

- Not in the agent trust profile at run time.
- Keep the password in a variable only as long as the form needs it.

## See also

[Forms](@page-forms) · [data](@page-data) · [navigation](@page-navigation).
