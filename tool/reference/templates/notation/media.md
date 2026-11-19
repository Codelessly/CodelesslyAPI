# Media (feature layer)

The media layer: video, embedded video, audio, web views, reading text aloud, sounds, printing, screenshots, downloads, picking a file, sharing and preloading images. Open it when a UI plays or embeds media. Its words and actions are allowed only where the host enables the layer (see [levels.md](levels.md)).

## A file picked, and sharing

`pickFile` opens the device's file chooser and gives what was picked as `result`, uploading nothing: a record with
the file's `name`, `size` (bytes), `type` and `data` (the file as a `data:` URL, which an `Image` shows and a
`cloudFiles source=` uploads later). `accept=` names the kinds offered, `multiple=true` gives a list of records,
`content=text` gives the file's `text` in place of `data` and `content=none` neither. When nothing is picked the
actions after it do not run. `share` opens the device's share panel with a `text`, a `url` and a `title`; where
there is none it copies the URL (or the text) and `result.copied` is true. `screen.url` is the page's own address.

```notation expands
state files=[]
Column gap=12
  Button "Attach" icon="attach_file" onTap={pickFile accept="image/*,.pdf"; files=append(files, result)}
  each f in files
    Text "{f.name} ({f.size} bytes)"
  Button.ghost "Share" icon="share" onTap={share title="Trip notes" url={screen.url}; result.copied ? toast "Link copied"}
```

{{reference}}

{{examples}}
