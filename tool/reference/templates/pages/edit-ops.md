# Edit ops and streaming

## When to use

Building and changing a document with edit operations: what a model sends in a `ui_apply` tool call, what an app's
`UiSession` applies while the model streams, the retry protocol for rejected ops, the tools' schemas and the trust
profiles that limit what a model may use.

## Minimal example

The ops that build the base's smallest document, top-down, as a model streams them:

{{editBuild}}

## Reference

### The ops

A document is built and changed with six **edit operations**, each addressed by node id: what an agent sends in a
`ui_apply` tool call, what `codelessly apply` takes, and what an app's `UiSession` applies while a model streams
(`applyOps`, `decodeOps`, `OpStreamDecoder` in `package:codelessly_api/core.dart`). Generation is just the first
batch of ops; every change after it is a few more.

{{editOps}}

### Codes of the edit layer

{{editCodes}}

### The tools

`outline(document)` is one row per node, `[id, type, label, depth, {what is bound, states, triggers}]`, a sixth to
a seventh of the document's size (the two m05 pages: 6.7 KB for 147 nodes against 47.6 KB, 8.3 KB for 196 nodes
against 55.4 KB). `readUi` answers the `ui_read` tool: the outline, or whole nodes by id.

The two tools (`uiTools(catalog)`), their input schemas generated from the op declarations and the catalog's
node types (the agent profile over the core: [ui_tools.json](ui_tools.json)):

{{uiTools}}

A schema that enumerates every node type and key is the wrong shape for a runtime tool: it costs tokens on every
call and still cannot say what a prop holds. `uiTools(catalog, compact: true)` gives the op envelope strictly (op
names, field names and kinds from the declarations; [ui_tools.compact.json](ui_tools.compact.json)) and leaves the
node's contents to the system prompt: the **base** in its runtime form, `runtimeStarter(catalog:, profile:, kind:)`
([RUNTIME_STARTER.md](RUNTIME_STARTER.md)). It is the same document as [STARTER.md](STARTER.md), assembled by
`baseDocument` from the same generated segments, with the runtime envelope (answering rules, the ops, two examples
that apply cleanly) in place of the file envelope (the render command, sites as files), and its tables restricted
to what the trust profile allows. `ui_read {"types": [...]}` describes any other allowed type on demand
(`describeTypes`), and validation does the rest.

The base ends with the index of the third tool, `ui_docs {"topic": ...}` (`uiTools(catalog, compact: true, docs:
true)`). `docsTopic` answers with these pages: a page's *When to use*, minimal example and pitfalls, and the list of
its sections; any section by its anchor (`ui_docs "forms-validation-and-an-error-state"`); any node type, action
type, trigger or behavior by name, generated from the declarations. A link `forms.md#x` in the files is
`ui_docs "x"` in the runtime form: the same map (`toRuntimeLinks`). The trust profile decides what may be *used*: a
topic outside it says it is not available here.

`TrustProfile.agentApps` is `agent` plus the document's own sandboxed scripts, for apps and games an agent builds:
the `scripts` op (name → `{"source", "params", "capabilities", "timeoutMs"}`, validated by `ScriptDef.validate()`,
`invalid_script`), `runScript` and `script.name(...)` in formulas, with capabilities limited to `variables.read`,
`variables.write` and `clock`. Everything else stays as `agent`'s.

### The trust profile

`TrustProfile` is what an edited document may use: node types and action types (a restricted catalog,
`profile.restrict(catalog)`), scripts, link and image hosts, navigation, and limits (nodes, depth, text length, ops
per call). `TrustProfile.agent`, the default for agent-written UI, allows the core's node types and its local
actions (variables, values, in-document navigation, modals, toasts, scrolling, animation, `componentEvent`): no
scripts, no links, no host functions, no feature library's types. A violation is `capability_not_allowed` or
`limit_exceeded`, with the op and the path.

`componentEvent` in a document that is not a component (an agent's UI) is the event to the document's host: the
session delivers it to the app, which sends it to the model.

{{reference}}

## Patterns

### A follow-up edit

Then a follow-up instruction ("add a button under the title, drop the body text, make the title say Welcome") is
a few ops, not a new document:

```json
{"ops": [
  {"op": "set", "id": "cta", "parent": "page", "index": 1,
   "node": {"type": "row", "children": ["ctaText"], "layout": {"width": {"hug": 140}, "height": 44, "padding": [16, 0, 16, 0]},
            "decoration": {"fills": [{"color": "#FF2563EB"}], "radius": 10}}},
  {"op": "set", "id": "ctaText", "node": {"type": "text", "layout": {"width": {"hug": 100}, "height": {"hug": 20}},
            "props": {"text": "Get started", "style": {"fontSize": 15, "fontWeight": 600, "color": "#FFFFFFFF"}}}},
  {"op": "remove", "ids": ["body"]},
  {"op": "patch", "id": "title", "patch": {"props": {"text": "Welcome"}}},
  {"op": "vars", "scope": "home", "set": {"taps": {"type": "integer", "value": 0}}},
  {"op": "patch", "id": "cta", "patch": {"actions": [{"trigger": {"type": "click"},
            "actions": [{"type": "setVariable", "variable": "taps", "op": "add", "value": 1}]}]}},
  {"op": "move", "id": "cta", "parent": "page", "index": 0}
]}
```

A batch with a mistake: the second op misspells `fills`. It is rejected with a code, the path and a suggestion; the
first applies:

{{editRejected}}

### Streaming

LLM APIs deliver a tool call's input as text deltas cut anywhere. `OpStreamDecoder` yields each op the moment its
closing brace arrives (inside a `set` with `nodes`, each node as its own brace closes), whatever the cuts; a stream
cut mid-op keeps every complete op and reports the tail (`truncated_op`).

**Malformed input.** With eager (fine-grained) tool input streaming a provider does not promise valid JSON, and
models do not always write it: a recorded live generation closed one brace too many three times in 24 ops. The
decoder works around op boundaries, not the enclosing JSON: it keeps a repaired copy of the text (a closer that
closes nothing is dropped, a missing one is inferred, trailing commas are removed, missing commas inserted), reads an
op object (`{"op": ...}`) at any depth outside another op (after an `ops` array closed early, in a wrapper of
another name, after text), and when an op begins before the previous one closed, closes that one where the next
began and reads what it can of it. Each repair is one `malformed_input` warning with the character offset; the ops
around it apply. A node field written beside `"node"` (what an early closing brace produces) is moved into the node
(`misplaced_field`). A single stray or missing brace, bracket or comma loses at most the op it is in
(`test/edit_stream_recovery_test.dart` checks this property on 2,000 random edits, and that every chunking yields the
same ops). `OpStreamEnd.repairs` and `.recovered` count the repairs and the ops read after the first one.

While a document streams in, it is incomplete by nature:

* **Order.** Root first, then top-down: the `roots` op, the canvas, its container, then each section complete before
  the next. Nothing breaks if a model does otherwise.
* **Forward references.** A child id listed before its node arrives is **pending**, not an error; a reference to a
  node, screen or variable that has not arrived yet (a state that patches it, a navigation to it) is a warning while
  the stream runs (`applyOps(..., incomplete: true)`). When the stream ends, `endOfStream` reports every id still
  dangling (`dangling_child`), so the model can send it.
* **Rendering** (the SDK's `UiSession`): nothing paints until a root canvas has content; a pending child takes no
  room (or the size a `set`'s `placeholders` gave it); a container none of whose children has arrived waits for
  its first, so no empty shells flash; text and values are never shown half-written (an op applies only whole).

### The retry protocol

After a stream, the tool result (`EditResult.toModelJson()`) says exactly what the document holds and what to do:
`rev`, the ops that applied (by index, and the ids they set, patched, moved and removed), every rejected op with its
code, path, what was expected and a suggestion, warnings (at most 20), the pending ids, the document's roots and node
count, and, when anything was rejected or is pending, `next`: fix it by patching the document as it is (same ids),
never start over. A host sends it back and lets the model answer with one more `ui_apply`, a capped number of
times (the chat example: 2), stopping when nothing is rejected or pending. `applyOps(..., protectRoots: true)`
answers a batch that would replace the existing roots or create a new canvas with `start_over` (a live retry did
exactly that instead of fixing three ops). The diagnostics models hit carry the fix as JSON (`explainDiagnostic`): a
size written as a layout key (`"height": {"hug": 46}`), children on a type that takes none (the types that do, and a
row with a fill for a tag or button), a button's `text` (its `label`). `uiLints(document)` adds what no declaration
catches: `empty_button` (a tappable box that shows nothing) and `low_contrast` (text in its background's color); a
renderer adds `missing_glyph` and `no_size` (the SDK's `UiSession.renderDiagnostics`).

## Pitfalls

* A `patch` is an RFC 7396 merge patch on one node, shaped like the node: objects merge, lists and values replace,
  `null` deletes a key. It never changes `children`, `slots` or `type` (`structural_key_in_patch`): child lists
  change only through `set` (with `parent`), `move` and `remove`.
* A `set` of an id that exists replaces the node (the result says which ids it created). Replacing a node that had
  children it no longer lists is `would_orphan`: keep them, move or remove them first, or patch instead.
* Each op is checked on its own, against what it touched: its structure (one parent, no cycle, no canvas as a child,
  a parent that takes children there), the trust profile, and the nodes' fields (the strict validator of
  [render](@page-render) on the nodes the op created or changed, their parents and children). A rejected op changes nothing; the others
  apply (with `"atomic": true`, all or none).
* A batch may carry `"baseRev"`, the revision the author read: a patch of a field, or a set of a node, that another
  author changed since is `stale_rev`, with the current value. Every applied batch has inverse ops: applied
  atomically, they restore the document (undo).

## See also

[The base](STARTER.md) (its runtime form, `RUNTIME_STARTER.md`) · [components](@page-components) · [the render
command](@page-render).
