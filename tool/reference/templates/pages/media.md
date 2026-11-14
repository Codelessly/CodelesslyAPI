# Media: video, audio, web views, speech and sound

## When to use

The `media` feature library: video players, embedded videos, an audio player, web views, reading text aloud,
playing sounds, printing, capturing a screenshot, downloading a file and preloading images.

## Minimal example

{{example:pages/media}}

## Reference

{{reference}}

## Patterns

### Control a player from state

Bind `props.playing` and `props.positionSeconds` to variables to play, pause and seek from buttons; the player's
`changed` trigger reports `ready`, `error`, the duration and the position.

### Save a file

`{"type": "downloadFile", "fileName": "trip.txt", "text": "${brief}", "mimeType": "text/plain"}` offers the text as
a file (the browser's download, a save dialog elsewhere); `${result.saved}` says whether it was saved. The keys are
`fileName` and `text` (not `filename`, `content`). The render command saves it under `<out>/downloads/` and lists it.

### Read-along text

`speak` with `readAlong` times the words for a highlight bound to the spoken word.

## Pitfalls

- Not in the agent trust profile at run time.
- The render command does not play media: a video draws its poster or nothing.

## See also

[Interaction](@page-interaction) · [decoration](@decoration-images) (still images are image fills).
