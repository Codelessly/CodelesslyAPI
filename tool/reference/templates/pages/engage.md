# Engage: app events and automations

## When to use

The `engage` feature library: firing app events that the project's automations listen for (a popup after a
lesson, a review prompt after the third order), and the `${usage}` counters they read.

## Minimal example

{{example:pages/engage}}

## Reference

{{reference}}

## Patterns

### Fire an event

`{"type": "emitEvent", "event": "lessonFinished", "props": {"lesson": "intro"}}`: every automation of the project
listening for `lessonFinished` runs, reading `${event.props.lesson}` and `${usage.events.lessonFinished.count}`.
Automations live in the publish model, not in the document.

## Pitfalls

- Not in the agent trust profile at run time.
- An event no automation listens for does nothing.

## See also

[Publish](@page-publish) (the publish model) · [state](@page-state).
