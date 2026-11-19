# Media: video, audio, web views, speech and sound

## When to use

The `media` feature library: video players, embedded videos, an audio player, web views, reading text aloud,
playing sounds, printing, capturing a screenshot, downloading a file, picking a file, sharing and preloading images.

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

### Pick a file without uploading it

`{"type": "pickFile", "accept": "image/*,.pdf"}` opens the device's file chooser; `${result}` is the picked file's
record, `{"name", "size", "type", "data"}` (`data` a `data:` URL: an image's `url`, or a `cloudFiles` action's
`source` when it is uploaded after all). `"multiple": true` gives a list of records; `"content": "text"` gives
`text` in place of `data`, `"none"` neither. Picking nothing stops the chain. The render command picks the files its
`--pick-file <path>` names.

### Share

`{"type": "share", "title": "${story.title}", "url": "${screen.url}"}` opens the device's share panel;
`${result.shared}` says whether it took it. Where there is no share panel the URL (or, without one, the text) is
copied to the clipboard and `${result.copied}` is true: show a toast then.

### Read-along text

`speak` with `readAlong` times the words for a highlight bound to the spoken word.

## Pitfalls

- Not in the agent trust profile at run time.
- The render command does not play media: a video draws its poster or nothing.

## See also

[Interaction](@page-interaction) · [decoration](@decoration-images) (still images are image fills).
