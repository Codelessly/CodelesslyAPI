# 11. Edit operations and streaming

A layout is a flat, id-addressed document, so changing it is a small set of checked operations on ids. The same six
ops build a UI (a model's first answer), edit it (every answer after), and stream: a model's `ui_apply` tool call
arrives as text deltas, and each op applies the moment it is complete. All of it is in the core library
(`package:codelessly_api/core.dart`); the strict per-op check is in `package:codelessly_api/validate.dart`. The
reference has the op table, the codes and the tool schemas: [§20 of the guide](../reference/index.md#guide-edit).

| Here | Flutter / the web |
|---|---|
| `set` with `parent` | inserting a widget into a parent's `children` |
| `patch` (RFC 7396 merge patch on one node) | changing a widget's constructor arguments |
| `move`, `remove` | reordering, removing children |
| `vars` | `setState` on the screen's fields |
| `roots` | the app's routes |

## Applying ops

```dart
import 'package:codelessly_api/core.dart';
import 'package:codelessly_api/validate.dart' show strictEditCheck;

var doc = LayoutDocument(catalog: Catalog.core);
final result = applyOps(doc, {
  'ops': [
    {'op': 'roots', 'roots': ['home']},
    {'op': 'set', 'id': 'home', 'node': {'type': 'canvas', 'slots': {'body': 'page'}, 'layout': {'width': 390, 'height': 844}}},
    {'op': 'set', 'id': 'page', 'node': {'type': 'column', 'children': ['title'], 'layout': {'width': {'fill': 390}, 'height': {'fill': 844}}}},
    {'op': 'set', 'id': 'title', 'node': {'type': 'text', 'layout': {'width': {'hug': 80}, 'height': {'hug': 24}},
        'props': {'text': 'Hello', 'style': {'fontSize': 20, 'color': '#FF111827'}}}},
  ],
}, catalog: Catalog.core, check: strictEditCheck(), profile: TrustProfile.agent);

result.applied;        // [0, 1, 2, 3]: indices of the ops that applied
result.diagnostics;    // per op: code, path, message, expected, suggestion
result.toModelJson();  // the tool result a model reads
result.inverse;        // applied with atomic: true, they undo the batch
doc = result.document; // a new document; nodes that did not change are the same objects
```

`applyOps` takes a list of `EditOp`s (`SetOp`, `PatchOp`, `MoveOp`, `RemoveOp`, `VarsOp`, `RootsOp`) or the tool
input JSON (`decodeOps`: lenient, so `"op": "delete"`, a remove with `id`, a set whose node carries its id all
read; what cannot be read is a diagnostic with the op's index). Each op is applied and checked on its own:

* **structure**: one parent per node, no cycle, no canvas as a child, a parent that takes children there, no
  node left without a parent by a `set` that replaces its parent;
* **the trust profile** ([`TrustProfile`](#the-trust-profile));
* **its nodes**, by an `EditCheck`: `catalogCheck` (the default, core only: types, keys and values against the
  catalog's declarations) or `strictEditCheck()` (the strict validator of chapter 4, run on the nodes the op touched,
  their parents and children, the rest of the document as stubs: a few nodes per op, not the page).

An op with an error changes nothing; the rest apply, or with `atomic: true` none does. Warnings are reported and
the op applies.

## Revisions and undo

`EditResult.rev` counts the batches that changed the document; `revisions` keeps, per node and field, the
revision and author of its last change. A batch with `baseRev` (the revision its author read) is checked against
it: a patch of a field another author changed since, or a set of a node they changed, is `stale_rev` with the
current value in `expected`; patches of different fields of the same node merge. `inverseOps(before, after)`
gives the ops that turn any later document back into an earlier one, which is how a session undoes a whole
streamed answer as one step.

## Streaming

```dart
final decoder = OpStreamDecoder();
await for (final delta in toolInputDeltas) {        // input_json_delta text, cut anywhere
  for (final s in decoder.add(delta)) {             // each op as soon as its closing brace arrives
    final r = applyOps(doc, [s.op], catalog: Catalog.core, incomplete: true);
    doc = r.document;
  }
}
final end = decoder.close();                        // baseRev, atomic, a truncated tail
final missing = endOfStream(doc);                   // dangling_child for ids that never came
```

The decoder's guarantees, tested on a 196-node page with forty random chunkings: the ops yielded depend only on the
text, not on where it was cut; each op is yielded exactly when its text is complete; inside a `set` with a `nodes`
map each node is yielded as its own brace closes (so one large op still paints progressively) and not again at
the end; a stream cut mid-op keeps every complete op and reports the op that was arriving (`truncated_op`);
an op that is not JSON, or not an op, is reported with its index and the stream goes on.

While a document streams in it is incomplete by nature. With `incomplete: true` a child listed before its node
arrives is pending (`EditResult.pending`), and a reference to a node, screen or variable that has not arrived yet
is a warning, not an error; `endOfStream` (and `validateEdited` for the whole document) report what never came.

`opsFromDocument(document)` writes a document as the ops that build it top-down, the order a model is asked to
stream in: roots, each canvas and its state variables, then each section complete before the next, a large data
variable just before the first node that reads it. `toolInputText(ops)` is those ops as the tool input text.

## What a model reads, and the tools

`outline(document)` is one row per node (`[id, type, label, depth, extras]`), a seventh of the document's bytes on
the m05 pages; `readUi(document, input)` answers `ui_read`. `uiTools(catalog)` gives the two tools, `ui_apply`
and `ui_read`, with input schemas generated from the op declarations (`EditOp.specs`) and the catalog's node types,
so the schema a model is given and what `decodeOps` accepts cannot drift apart.

## The trust profile

```dart
final profile = TrustProfile.agent.copyWith(linkHosts: {'example.com'});
final slice = profile.restrict(standardCatalog); // the catalog the model is described and checked with
```

`TrustProfile.agent` allows the core's node types and local actions (no scripts, links, host functions or
feature types; navigation only to the document's own canvases; size limits). A violation is
`capability_not_allowed` or `limit_exceeded` with the op and the path. `TrustProfile.none` allows everything.

The SDK's `UiSession` and `CodelesslyView` are this chapter over a live render tree: see the SDK guide.
