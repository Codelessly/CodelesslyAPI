# 08 · The API for AI: how agents, apps and platforms use Codelessly

Status: proposal. Builds on doc 05 (catalog, strict validation), doc 06
(sections and components by reference) and the landscape in doc 07. Paths
are to this worktree unless they start with `CodelesslySDK/`,
`CodelesslyEditor/` or `experiments/` (= `/home/user/experiments/`).

The owner's question: "What does the API for AI to use CodelesslySDK look
like? ... For us, we just want to be able to have UI, apps, and features
directly editable as data. Natural language app description to data and
then editing apps as data."

The answer in one paragraph: **the API is a small set of edit operations
over the flat, id-addressed document, validated per operation against a
catalog, with the same operations exposed as files and CLI for agents at
design time, as a Dart `UiSession` plus two LLM tools at runtime, and as
the editor's own transactions.** Generation is just the first batch of
operations. Everything else in this document is that idea made concrete.

## 1. Positioning

**Codelessly is the app as an editable document.** A natural-language
description becomes a complete app (screens, layout, styling, state,
actions) as one validated data document, and from then on AI agents,
people in the visual editor and code all change it with the same small,
checked operations, and the SDK renders it natively with node-level
updates. It is for teams who ship and keep changing real apps, not for
chat answers.

What we should **not** try to be:

* **A chat-card protocol.** A2UI 1.0, json-render, ChatKit and CopilotKit
  own disposable cards over fixed catalogs, with renderers on every
  platform and Google's and Vercel's distribution (doc 07 §2–3, §6). Our
  answers there would be bigger (15–22k tokens for a page against A2UI's
  ≈800-token median answer) and Flutter-only. We interoperate with them;
  we do not compete on their benchmark.
* **A code generator.** Models write HTML 5–10x faster per page than our
  data today (doc 07 §9). If the output is meant to be code, v0 and its
  peers win. Our output is meant to be edited.
* **A cross-framework renderer zoo.** One native renderer (Flutter, with
  its web build) is enough while the document is the product.

## 2. The three users

### 2a. An AI agent authoring and editing an app at design time

**Today.** Agents write files using the reference
(`docs/reference/index.md`) or the 6.4k-word starter
(`experiments/m05/STARTER.md`), then run the render command
(`CodelesslySDK/tool/render/README.md`: strict validation, screenshots at
390×844, 834×1112 and 1440×900, `--tap`, `--set`, `--dump-layout`). That
loop produced close matches of two reference pages at three sizes in
21–27 min (`experiments/m05/c1/*/RESULTS.md`). The editor's MCP
(`CodelesslyEditor/docs/MCP_COMMANDS.md`, ≈220 commands; `nodes.patch`,
`nodes.insertTree`...) needs a live editor: "Commands fail with
`no_v2_page` when no page is open in the editor".

**Proposed.** One headless tool, `codelessly`, shipped with the SDK
(it needs Flutter for rendering, as the render command does), that works
on a site directory (doc 06 §8.1: `site.json`, `pages/`, `components/`)
with no editor running:

| Command | Does |
|---|---|
| `codelessly init <dir> [--features commerce,auth]` | Writes `site.json`, an empty page, and `AGENTS.md`: the starter generated from the catalog slice, plus links into the reference |
| `codelessly check <dir>` | Strict validation of every file (`validateProject`), JSON output with codes and pointers |
| `codelessly render <dir> --out out [steps]` | Today's render command, unchanged |
| `codelessly apply <file> ops.json` | Applies edit operations (§3) to a file; prints the result (applied, rejected with diagnostics, inverse) |
| `codelessly outline <file>` | The compact view (§3.6) for an agent to read instead of the whole file |
| `codelessly describe <type>` | One node or action type's declaration from the catalog |
| `codelessly mcp <dir>` | The same commands as an MCP server over stdio: `ui_outline`, `ui_get`, `ui_apply`, `ui_check`, `ui_render`, `ui_describe` |
| `codelessly push <dir>` | Publishes to the project (what the editor's save does) |

The editor's MCP stays for driving the visual editor (selection, canvas
drops); its document commands become thin wrappers over the same
operations (§3.5).

**Quickstart** (works once built):

```sh
codelessly init site --features commerce          # site.json, pages/home.json, AGENTS.md
# Tell the agent: "Read site/AGENTS.md. Build a pricing page for <brief>
#   in site/pages/pricing.json. Run `codelessly render site --out out`
#   after each section and fix every error it reports."
codelessly render site --out out --sizes 390x844,1440x900
codelessly outline site/pages/pricing.json         # what the agent reads on a follow-up
echo '{"ops":[{"op":"patch","id":"hdrTalkText","patch":{"props":{"text":"Book a demo"}}}]}' \
  | codelessly apply site/pages/pricing.json -
codelessly render site --out out --screen pricing --hover hdrTalk --label hover
codelessly push site
```

Or, for an MCP client: `claude mcp add codelessly -- codelessly mcp ./site`.

Writing whole files remains the generation path at design time. The
experiments show agents are good at it (190–466 nodes, 67–183 KB, zero
errors at the end). Operations are for every change after that.

### 2b. An app developer who wants AI-generated or AI-edited UI at runtime

**Today** there is no path: the A2UI bridge was deleted
(`CodelesslyEditor/docs/genui_a2ui.md`), and the only way to change a
shown document is to replace it, after which `DocumentSource` notifies
the nodes that differ (`CodelesslySDK/lib/src/render/source.dart`).

**Proposed** — a `UiSession` in the SDK: a document plus a catalog plus a
trust profile, which implements `NodeSource` so the render tree's per-node
watching does the incremental work it already does for the editor.

```dart
// codelessly_api (pure Dart): the operations and their application.
sealed class EditOp {
  factory EditOp.fromJson(Json json);       // {"op": "set" | "patch" | "move" | "remove" | "vars" | "roots", ...}
  Json toJson();
}

final class EditResult {
  final LayoutDocument document;            // after the ops that applied
  final List<EditOp> applied;
  final List<EditOp> inverse;               // applying these undoes `applied`
  final List<OpDiagnostic> diagnostics;     // per op: index, code, path, message, expected, suggestion
  final Set<String> pending;                // ids referenced but not yet defined (streaming)
  final int rev;
}

EditResult applyOps(LayoutDocument doc, List<EditOp> ops,
    {required Catalog catalog, TrustProfile profile = TrustProfile.none, bool atomic = false});

// codelessly_sdk: the session the UI renders from.
final class UiSession implements NodeSource {
  UiSession({LayoutDocument? document, required Catalog catalog, TrustProfile profile = TrustProfile.agent});

  EditResult apply(Object? opsJson, {String author = 'agent', int? baseRev});
  Future<EditResult> applyStream(Stream<String> toolInputDeltas, {String author = 'agent'});
  Json outline();                            // §3.6
  Json describeForModel();                   // starter + catalog slice, §4
  Stream<UiEvent> get events;                // emitEvent actions, submitted forms
  bool undo({String? author});
  bool redo({String? author});
  LayoutDocument get document;
  int get rev;
}

// A widget over a session, like CodelesslyWidget over a published layout.
CodelesslyView(session: session, canvas: 'home');
```

The tools the model calls. Two are enough; the schema is generated from
the catalog slice, so `node` validates against the allowed types:

```json
[
  {"name": "ui_apply",
   "description": "Change the UI. Ops apply in order. Ids are the addresses: a node's id is its key in `nodes`. Return value lists rejected ops with codes; fix and resend only those.",
   "input_schema": {"type": "object", "required": ["ops"], "properties": {
     "baseRev": {"type": "integer"},
     "ops": {"type": "array", "items": {"oneOf": [
       {"type": "object", "required": ["op", "id", "node"], "properties": {"op": {"const": "set"}, "id": {"type": "string"}, "node": {"$ref": "#/$defs/Node"}, "parent": {"type": "string"}, "index": {"type": "integer"}, "slot": {"type": "string"}}},
       {"type": "object", "required": ["op", "id", "patch"], "properties": {"op": {"const": "patch"}, "id": {"type": "string"}, "patch": {"type": "object", "description": "RFC 7396 merge patch on the node; null deletes a key"}}},
       {"type": "object", "required": ["op", "id", "parent"], "properties": {"op": {"const": "move"}, "id": {"type": "string"}, "parent": {"type": "string"}, "index": {"type": "integer"}, "slot": {"type": "string"}}},
       {"type": "object", "required": ["op", "ids"], "properties": {"op": {"const": "remove"}, "ids": {"type": "array", "items": {"type": "string"}}}},
       {"type": "object", "required": ["op", "scope", "set"], "properties": {"op": {"const": "vars"}, "scope": {"type": "string"}, "set": {"type": "object", "description": "variable name -> value, or -> full variable object to declare"}, "remove": {"type": "array", "items": {"type": "string"}}}},
       {"type": "object", "required": ["op", "roots"], "properties": {"op": {"const": "roots"}, "roots": {"type": "array", "items": {"type": "string"}}}}
     ]}}}}},
  {"name": "ui_read",
   "description": "Read the current UI: the outline (id, type, name, text, children) or full nodes by id.",
   "input_schema": {"type": "object", "properties": {"ids": {"type": "array", "items": {"type": "string"}}, "outline": {"type": "boolean"}}}}
]
```

This replaces the four names floated in the brief (`set_nodes`,
`patch_node`, `remove_nodes`, `set_variables`) with one tool carrying a
batch: one tool call per turn, one validation pass, one result, and
streamed rendering inside the call. Separate tools would cost a round
trip each and could not be applied atomically.

**Quickstart** (an app that lets a model build and then change a screen):

```dart
final session = UiSession(catalog: standardCatalog, profile: TrustProfile.agent(
    actions: {'setVariable', 'navigate', 'showToast', 'emitEvent'}, linkHosts: {'example.com'}));
final llm = MyModelClient(system: session.describeForModel(), tools: UiSession.tools);
session.events.listen((e) => llm.send(e.toModelMessage()));       // a tap the agent asked to hear
llm.onToolInputDelta('ui_apply', (chunks) async {
  final r = await session.applyStream(chunks);                    // renders as each op arrives
  llm.toolResult(r.toModelJson());                                // rejected ops with codes
});
runApp(MaterialApp(home: Scaffold(body: CodelesslyView(session: session))));
llm.send('A booking screen for a 6-table restaurant, 7–10pm slots.');
```

The provider adapter (`MyModelClient`) is the app's; the SDK ships one
reference adapter for one provider's streaming tool input and documents
the three hooks it needs (system text, tool schema, streamed tool input).

**Events back to the agent.** The model wires interactions as ordinary
reactions with the existing `emitEvent` action, which already reaches the
host on `codelessly.events`:

```json
{"trigger": {"type": "click"},
 "actions": [{"type": "emitEvent", "event": "choosePlan", "props": {"plan": "${item.id}"}}]}
```

`UiSession.events` delivers `{"event": "choosePlan", "props": {"plan":
"team"}, "source": "planCta#1", "rev": 42}`; the app decides which events
go to the model. Everything else (toggles, filters, form validation, tab
switching) runs locally on variables and formulas at zero model tokens,
as in the m05 pages, where tabs, filters and search were all variables.

### 2c. A platform or agent builder who wants interop

**A2UI.** Being an A2UI *renderer* again is not worth it as a product: we
built one on v0.9.1 and deleted it, Google ships `a2ui_flutter` 0.3.0
(doc 07 §2), and rendering A2UI's 18 unstyled components with our engine
adds nothing a customer can see. Two cheap pieces are worth it:

1. **A2UI → Codelessly import** (`a2ui.toDocument(messages)`): an A2UI
   surface becomes a starting document the user can then edit as data.
   Mapping, from the deleted bridge's table (`genui_a2ui.md` §1), updated
   to v1.0:

| A2UI 1.0 | Codelessly | Lossy? |
|---|---|---|
| `Column`/`Row` (`justify`, `align`, `weight`) | `column`/`row` (`mainAxisAlignment`, `crossAxisAlignment`, `layout.flex`) | No |
| `Text` (`variant` caption/body, `weight`) | `text` with theme text style | Gains styling; markdown in `text` is not parsed |
| `Button` (`variant` default/primary/borderless, `action.event`) | `outlinedButton`/`filledButton`/`textButton` + `click` → `emitEvent` | No |
| `TextField`, `CheckBox`, `Slider`, `ChoicePicker`, `DateTimeInput` | `textField`, `checkbox`, `slider`, `chip`s or `segmentedButton`, a date input | DateTimeInput: check node coverage |
| `Card`, `Divider`, `List` (template) | box with decoration, `divider`, `listView` bound to a list variable | No |
| `Tabs`, `Modal` | tabs node; `openModal` action + modal canvas | Structure changes |
| `Image`, `Icon`, `Video`, `AudioPlayer` | box image fill, `icon`, media plugin nodes | Media needs the media library |
| Data model + `{"@path"}` | variables + `${path}` | No |
| `formatString`, `formatCurrency`... | formula functions | Check each |
| `callAgentFunction` | `emitEvent` + session event | Synchronous return is lost |

2. **Codelessly as an A2UI custom component**: a one-component custom
   catalog, `CodelesslyDocument {documentId | inline document}`, so an A2UI
   agent (Gemini Enterprise, CopilotKit) can place a full Codelessly
   section inside its surface. Export the other way (Codelessly → A2UI) is
   not worth building: layout, decoration, states and motion have no A2UI
   spelling since v1.0 removed theme.

**MCP Apps.** Yes, a Codelessly document can be an MCP App's UI: the HTML
resource (`text/html;profile=mcp-app`) is the SDK's web build hosting a
`UiSession`; the tool result's `structuredContent` carries the document or
ops; `ui/notifications/tool-input-partial` feeds `applyStream`;
`emitEvent` becomes `tools/call` (to app-visible tools) or `ui/message`.
**Risk, unmeasured:** a Flutter web build is several MB and has a cold
start; the CSP must allow its script/font hosts through `resourceDomains`.
Prototype and measure time-to-first-frame in Claude and ChatGPT before
promising it.

```json
{"name": "show_booking", "_meta": {"ui": {"resourceUri": "ui://codelessly/session"}},
 "inputSchema": {"type": "object", "properties": {"ops": {"type": "array"}}}}
```

**AG-UI.** Nothing to design: `ui_apply` is a normal tool, so its
arguments stream as `ToolCallArgs` events into `applyStream`, and session
events go back as tool results or user messages. Where a framework
prefers shared state, the document is a state key and our ops convert to
`StateDelta` RFC 6902 patches (`/nodes/<id>/...`).

## 3. The edit model

### 3.1 The operations

Six operations, all addressed by node id. Paths inside a node are not
part of the address: the patch body is shaped like the node.

| Op | Means | Example |
|---|---|---|
| `set` | Create or replace node `id`; optionally place it under `parent` at `index` (or in `slot`) | `{"op":"set","id":"faqTitle","parent":"faqSec","index":0,"node":{"type":"text","props":{"text":"Questions"}}}` |
| `patch` | RFC 7396 merge patch on node `id`: objects merge, arrays and scalars replace, `null` deletes | `{"op":"patch","id":"heroH1","patch":{"props":{"style":{"fontSize":72}},"bind":{"props.style.fontSize":null}}}` |
| `move` | Move node `id` to `parent` at `index` (reorder = move within the same parent) | `{"op":"move","id":"faqSec","parent":"page","index":2}` |
| `remove` | Remove nodes and their subtrees; detach from parents | `{"op":"remove","ids":["promoBanner"]}` |
| `vars` | Set variable values, declare or remove variables in a scope | `{"op":"vars","scope":"pricing","set":{"annual":true}}` |
| `roots` | Set the document's canvases | `{"op":"roots","roots":["home","pricing"]}` |

Decisions in that table:

* **Merge patch per node, not RFC 6902 paths.** A model writes
  `{"props":{"text":"Book a demo"}}` as naturally as it writes the node;
  6902 needs `/nodes/hdrTalkText/props/text` and array indices, which are
  where models make mistakes. json-render offers both (doc 07 §3.1); we
  pick one.
* **Child lists are changed by `set`/`move`/`remove`, never by patching
  `children`.** Merge patch replaces arrays, so patching `children` to
  insert one id would need the whole list and races with other editors.
  `patch` rejects `children` and `slots` with `structural_key_in_patch`.
* **Ids are minted by the author.** The model chooses readable ids
  (`hero-title`), as the reference already asks (`index.md` §2). A `set`
  on an existing id is a replace; the result says which happened.
* **Components and sections** (doc 06) are addressed by path
  (`plans/card1/cta`) when an op targets a node inside a component
  instance from the page; by plain id inside the component's own file.

### 3.2 A follow-up instruction becomes a small patch

The user says: "Make the header button say 'Book a demo' and turn it lime
on hover." The agent reads the outline (§3.6), finds `hdrTalk` (a row)
and `hdrTalkText` (its label) in the saas-landing-A page
(`experiments/m05/c1/saas-landing-A/site/pricing.json`), and sends:

```json
{"ops": [
  {"op": "patch", "id": "hdrTalkText", "patch": {"props": {"text": "Book a demo"}}},
  {"op": "patch", "id": "hdrTalk", "patch": {"layout": {"width": {"hug": 140}},
    "states": {"hovered": {"hdrTalk": {"decoration": {"fills": [{"color": "#FFB9F34C"}]}}}}}}
]}
```

**Cost estimate.** How it was estimated: minified bytes of the measured
documents ÷ 3.5 bytes per token (the ratio doc 06 §9.4 uses; no
tokenizer was run).

| | Bytes | ≈ tokens |
|---|---|---|
| Regenerate the page (output) | 51–76 KB minified for the five single-page documents (measured) | 15,000–22,000 |
| This patch (output; measured, minified) | 237 | ≈ 68 |
| A typical one-node edit: median node 205–235 bytes (measured), a patch is a fraction of it | 60–240 | 20–70 |
| Adding a 10-node section (median node size × 10) | ≈ 2,200 | ≈ 630 |
| Outline to locate targets (input; the §3.6 outline measured on saas-landing-A: 15.2 KB for 253 nodes, 60 bytes per node; 190–290 nodes) | 11–18 KB | 3,300–5,000 |
| Whole document in context instead of the outline (input; cacheable) | 51–76 KB | 15,000–22,000 |

So a follow-up edit costs **two to three orders of magnitude fewer output
tokens** than regeneration (≈68 vs ≈15–22k), and output tokens are what
make a turn slow. Regeneration also re-rolls every other node: collateral
change is the real cost, and the evaluation measures it (§6.2). Doc 06's
component split lowers the input side further: editing the plan card
means reading 9.4 KB (≈2.7k tokens) instead of 73.8 KB (doc 06 §8.5).

### 3.3 Streaming

Generation streams the same operations.

* **Order.** Root first, then breadth-first: canvas, page column, section
  roots, then each section's contents. The starter tells the model this
  order; nothing breaks if it is not followed.
* **Placeholders.** A child id listed in a node's `children` before its
  `set` arrives is `pending`: the render tree lays it out as a zero-size
  box (a skeleton when `UiSession.placeholder` is set). This is A2UI's rule
  (doc 07 §2) and what the render tree already does for a missing node.
* **When to apply.** Each op is parsed out of the streamed tool input when
  its closing brace arrives (the deleted bridge's `A2uiJsonStreamParser`
  did exactly this), validated, applied, and the session notifies the
  touched nodes; frames coalesce, so 300 ops in 20 s are 300 small updates,
  not 300 rebuilds of the page.
* **Partial text.** `props.text` inside an incomplete op is not shown (A2UI
  Express heals partial strings; we can add that later for long copy).
* **End of stream.** `pending` ids that never arrived become
  `dangling_child` errors in the tool result, so the model can send them.

### 3.4 Validation per op, with errors the model can act on

Each op is checked by the existing strict validator restricted to what the
op touched: the node's own fields (`unknown_prop`, `wrong_type`,
`invalid_enum`, `out_of_range`, `unknown_bind_path`, `expression_syntax`,
`unknown_name`, `unknown_action_type`...), the references it creates or
breaks (`dangling_child` once not pending, `multiple_parents`, `cycle`,
`unknown_target_node`, `unknown_variable`), and the trust profile
(`capability_not_allowed`, §5). New codes for the edit layer:
`unknown_id` (patch/move/remove of nothing), `structural_key_in_patch`,
`stale_rev` (§3.5), `would_orphan`. All 50 existing codes stay
(`lib/src/validate/diagnostic.dart`).

A rejected op is not applied; the others are, unless the call says
`"atomic": true`. The result, which is the tool result:

```json
{"rev": 43, "applied": [0], "rejected": [
  {"op": 1, "code": "unknown_field", "path": "/nodes/hdrTalk/states/hovered/hdrTalk/decoration/fill",
   "message": "decoration has no key \"fill\"", "expected": ["fills", "strokes", "radius", "shadows", "blurs", "clip"],
   "suggestion": "fills"}],
 "warnings": []}
```

Layout-time problems the validator cannot see (`layout_overflow`,
`text_clipped`, `offscreen` from the render command) are reported at
design time by `ui_render`; at runtime the session reports
`render_exception` and overflow on the next frame as a follow-up message
only if the app opts in.

### 3.5 Two editors at once, and undo

* **Revisions.** The document has a `rev`; every node has the `rev` of its
  last change. An op batch may carry `baseRev` (the rev the author read).
* **Merging.** On apply, for each `patch` the session compares the
  *fields* it touches with fields changed on that node since `baseRev`.
  Disjoint fields merge (agent changes text while a person changes the
  fill: both stay). The same field changed by someone else since
  `baseRev` is rejected with `stale_rev`, carrying the current value; the
  author re-reads and decides. `set` (whole node) is rejected if the node
  changed at all since `baseRev`. `move`/`remove` on a node another author
  removed: `unknown_id`.
* **Why not a CRDT.** Edits are coarse (a node, a field), authors are few
  (an agent and a person, or two agents on different section files, doc
  06 §8.1), and rejection with the current value is something a model
  handles well. Revisit if real-time multi-person editing is required.
* **The editor joins the same log.** The editor's `DocStore` transactions
  (`CodelesslyEditor/docs/MCP_COMMANDS.md`: "Every node edit is one
  `store.edit(...)` transaction: one undo step") become op batches with
  `author: "person"`, so an agent working through `codelessly mcp` on the
  saved files and a person in the editor see each other's changes as ops.
* **Undo.** Every applied batch stores its `inverse` ops; `undo(author:)`
  applies the inverse of that author's last batch, checked like any other
  batch (it fails with `stale_rev` if someone has since changed the same
  fields). One batch is one undo step, as one `store.edit` is today.

### 3.6 The outline: how an agent reads before it edits

An agent should not re-read 70 KB to change a label. The outline is one
line per node, in tree order:

```json
{"rev": 42, "outline": [
  ["pricing", "canvas", "Pricing", 0],
  ["root", "column", "", 1],
  ["header", "row", "", 2],
  ["hdrTalk", "row", "", 3, {"bind": ["visible"], "states": ["hovered"]}],
  ["hdrTalkText", "text", "Talk to sales", 4],
  ["heroH1", "text", "Prepared for\nevery scale.", 3, {"bind": ["props.style.fontSize", "props.style.letterSpacing", "layout.margin"]}]
]}
```

(id, type, name or first 40 characters of text, depth, and what is bound
or stateful.) `ui_read {"ids": [...]}` returns full nodes. This is the
same move as UI SDK's `agent.snapshot()` (doc 07 §3: −83% text read).

## 4. Prompt and context packaging

What the model is given, by surface:

| Item | Design time (files/MCP) | Runtime (`describeForModel`) |
|---|---|---|
| Starter: document, eight core types, layout, text, one example | `AGENTS.md`, generated; 6.4k words today (`experiments/m05/STARTER.md`) | A runtime starter: ≈2.5k words, one example screen |
| Catalog slice | `codelessly describe <type>`; feature sections appended by `--features` | `catalog.select(...)` per app, compact JSON, only allowed types |
| Reference | By link: files in the package (`docs/reference/*.md`); agents read 15–25k of 66.7k words | Not given; `ui_describe` tool if the app enables it |
| Examples | Two worked pages, linked | One screen in the starter |
| Current UI | Files; outline | Outline in each turn; full nodes on request |
| Operations and errors | In the starter, one page | In the tool description |

**Size budget.** Design time: starter ≤ 8k words, always loaded; the rest
by link. The m05 evidence is that the starter plus reference by link
matched reading the reference (same quality), so loading more is waste.
Runtime: system context ≤ 6k tokens (starter + slice + tool schema; A2UI's
median input is 10,980 tokens for Direct JSON and 6,000 for Express, doc
07 §2, so 6k is the competitive number), plus the outline.

**A compact inference format: not now.** The arguments:

* **Design time does not need one.** Agents wrote 51–117 KB (minified)
  documents successfully by writing files; the time went into layout and
  checking (22–49 render runs), not typing. A DSL would cost the property
  that the file the agent writes is the document the editor opens.
* **Edits do not need one.** A patch is 20–240 tokens (§3.2).
* **Runtime generation of a whole screen might.** At an assumed 60–120
  output tokens/s (provider-dependent; not measured here), a 15–22k-token
  page takes 2–6 minutes; a 30–60-node screen (≈2–4k tokens at our median
  node size) takes 15–60 s. Streaming shows the first section within
  seconds either way, but the total matters.
* **Most of our verbosity is fixable inside JSON.** In the measured pages,
  much of each text node is an inline style repeated on every text
  (`heroEyebrow`: 207 bytes minified, of which 82 are `style`, measured)
  and sizes the model computed
  (`{"hug": 148}`). Theme text styles by name, flexbox layout without
  precomputed sizes (the planned replacement for formula layout) and
  components by reference (doc 06) attack exactly this.

**Recommendation with numbers.** Build the three verbosity fixes first,
then measure median output tokens per runtime screen on the evaluation's
chat-sized briefs (§6.3). Build a compact form (a line-per-op JSONL with
positional fields, compiled to ops) only if, after those fixes, the median
runtime screen still exceeds **2,000 output tokens** or time to a complete
screen exceeds **20 s** on the reference model. A2UI's own number says
what to expect from it: −63% generated tokens on small cards (807 → 297).

## 5. Trust: a restricted catalog is the capability boundary

An agent-authored document is untrusted input. The profile is a catalog
slice plus limits, checked by validation on every op (doc 05 §5.4 already
gives hosted plugins `requires`):

```dart
final profile = TrustProfile.agent(
  catalog: standardCatalog.select(
    widgets: TrustProfile.safeWidgets,                     // layout, text, inputs, lists, charts; no webView, no htmlEmbed
    actions: {'setVariable', 'navigate', 'openModal', 'closeModal', 'showToast', 'emitEvent', 'scrollTo', 'animate', 'openLink'}),
  scripts: false,                                          // `scripts` key and `runScript` rejected
  linkHosts: {'example.com'},                              // openLink: these hosts; https only; user tap required
  imageHosts: {'images.example.com', 'cdn.codelessly.com'},
  navigation: NavigationLimit.withinDocument,              // navigate only to this document's canvases
  dataScopes: {'user.firstName', 'cart'},                  // names bindings may read; values are never sent to the model
  maxNodes: 600, maxDepth: 40, maxTextLength: 4000, maxOpsPerCall: 400,
);
```

Off by default for agents: `runScript`, `callApi`, `setStorage`, all
`cloud*` actions, `auth`, `paywall`, `submitForm`, `downloadFile`,
`captureScreenshot`, `copyToClipboard` (each can be enabled by the app).
A violation is `capability_not_allowed` with the op and path. Bindings
read only `dataScopes`, and `describeForModel` lists their names and types,
never their values: A2UI's "sensitive values never reach the model"
(doc 07 §2), which our bindings already make natural. A document promoted
from an agent session to a published app is re-validated against the
project's own (wider) profile.

## 6. Plan and evaluation

### 6.1 Build order

| Phase | Build | Why first | Measure |
|---|---|---|---|
| 1 | `EditOp`, `applyOps`, inverse, per-op validation, `outline` in `codelessly_api` (pure Dart, with tests) | Every surface uses it; no Flutter needed | Op round-trip tests; validation coverage per code |
| 2 | `codelessly` CLI and `codelessly mcp` (files, no editor) wrapping phase 1 and the render command; generated `AGENTS.md` | The design-time agent is the user we have evidence for | Edit-task suite (§6.2): tokens, time, collateral change |
| 3 | Verbosity fixes already planned: flexbox layout, theme text styles by name, components by reference (doc 06) | Largest friction and largest byte cost | Bytes/node, render runs, time per page on the paired corpus |
| 4 | `UiSession` (NodeSource over ops), streaming parser, placeholders, `TrustProfile`, events, one reference model adapter | Runtime generation | Time to first section, time to complete, rejected ops per screen |
| 5 | Editor `DocStore` transactions as op batches; `baseRev` merging | Agent and person on one document | Conflicts per session, lost edits (target 0) |
| 6 | Interop: MCP App host page on the web build; A2UI import; `CodelesslyDocument` A2UI component | Distribution | Time to first frame in Claude/ChatGPT; A2UI corpus import pass rate |

### 6.2 Evaluation: the paired corpus

The ten reference sites already exist in HTML/CSS/JS with specs,
screenshots and build times (`CodelesslyEditor/experiments/reference/*`:
conference, docs-site, magazine, nonprofit, property-listings,
restaurant, saas-landing, storefront, studio-portfolio, travel-guide).

* **Build tasks.** For each site, one page from the brief as data and the
  same page in HTML, same model, same harness, same time limit.
* **Edit tasks.** Ten follow-up instructions per site, written before any
  run: retitle, restyle a component, add a section, remove one, reorder,
  change a responsive rule, add a state (filter, tab), change copy
  throughout, add a form field with validation, swap the palette. Run as
  ops on data and as code edits on the HTML.
* **Metrics.** Wall-clock time; input and output tokens (from the
  harness, not estimates); render/check runs; final validation errors;
  fidelity at 390/834/1440 (the 1–5 ratings used in m05 plus a pixel
  difference against the reference screenshots); scripted state checks
  from each `SPEC.md`; for edit tasks, **collateral change** (nodes or
  screenshot regions changed outside the instruction's target) and
  whether a person can then edit the result in the visual editor (data:
  yes by construction; HTML: no).

### 6.3 Comparing with A2UI and json-render fairly

They target cards, not pages, so compare on their ground and ours
separately.

* **Their ground: 20 chat-sized briefs** (a booking form, a flight card, a
  metric dashboard, a settings panel...), including A2UI's own published
  samples where available. A2UI 1.0 via `a2ui_agent` with Express (its
  default) and the basic catalog; json-render with its shadcn catalog and
  `catalog.prompt()`; Codelessly via `UiSession` with the agent profile.
  Same model, temperature 0, three runs each. Metrics: output tokens, time
  to first render and to complete, pass rate (renders, no errors),
  judged quality, and **three follow-up edits each** (tokens, collateral
  change).
* **Our ground: the paired pages.** Run json-render on the same page
  briefs (it can express a page with its component set); report fidelity
  honestly, noting that A2UI 1.0 cannot carry styling and is not expected
  to match.
* Report each system's own numbers alongside ours (A2UI: −63% tokens on
  54 samples) and say where our setup differs from theirs.

### 6.4 Results that would change the plan

| If the ten-site results show... | Then |
|---|---|
| Data pages still take more than 3x the HTML time at equal fidelity after phase 3 | Build a translator from a Flutter widget subset to nodes (§7, decision 5); the model writes what it knows, the document stays data |
| Edit tasks on data are not cheaper in tokens or lower in collateral change than HTML edits | The edit-model differentiator fails; stop phase 4 and rethink positioning |
| Median runtime screen above 2,000 output tokens after phase 3 | Build the compact op format (§4) |
| Agents rarely need more than the starter | Shrink the starter further and drop reference links from the runtime prompt |
| Layout friction stays dominant after flexbox | Layout vocabulary, not the API, is the problem; fix it before phase 4 |

## 7. Open decisions for the owner, ranked

1. **Positioning: "the app as an editable document", not a chat-card
   protocol and not a code generator.** Everything else follows from it.
   *Recommended: yes.*
2. **The edit operations as a public, versioned contract in
   `codelessly_api`**: six ops, merge patch per node, structural changes
   only by `set`/`move`/`remove`, ids as addresses, per-op validation.
   *Recommended: yes, as phase 1.*
3. **A headless CLI and MCP server that needs no editor.** *Recommended:
   yes, phase 2; the editor's MCP keeps its canvas-driving commands.*
4. **Runtime generation in the SDK (`UiSession`, two tools,
   `TrustProfile`)**, marked experimental. *Recommended: yes, after the
   layout fixes (phase 4), so runtime output benefits from them.*
5. **A Flutter-subset-to-data translator as the hedge** for "AI is good
   at Flutter but worse at our API". *Recommended: not now; decide on the
   §6.4 result. The data is already one mechanical step from Flutter
   (docs/design/README.md), so the translator is feasible if needed.*
6. **No compact inference format until the numbers say so** (thresholds in
   §4). *Recommended: agree to the thresholds.*
7. **A2UI: import plus a Codelessly custom component, no runtime A2UI
   renderer.** *Recommended: yes; revisit if a customer needs Gemini or
   CopilotKit surfaces rendered by us.*
8. **MCP Apps through the web build.** *Recommended: prototype and measure
   cold start before committing.*
9. **Concurrency by revision-checked ops, not a CRDT.** *Recommended:
   yes, until real-time multi-person editing is a requirement.*
10. **Agent trust defaults** (scripts, API calls, cloud, auth off; links
    and images by allow-list). *Recommended: yes, as listed in §5.*

## Not verified

* No part of this proposal was built or prototyped. Token figures are
  byte counts ÷ 3.5, not tokenizer counts; the outline size (60 bytes per
  node) was measured on one page with a throwaway script, not the proposed
  implementation; output speeds of 60–120 tokens/s are an assumption.
* The m05 build times (21–27 and 16–18 min) are from the experiment
  brief; the RESULTS.md files record runs, nodes and sizes but not times.
* The HTML build times are the RESULTS.md self-reports; the harness may
  differ from the m05 runs, and those builds had no pixel target.
* Flutter web bundle size and cold start inside MCP Apps hosts were not
  measured.
* `catalog.select` and `TrustProfile` do not exist yet (doc 05 §7 proposes
  `select`); action names in §5 are from `docs/reference/catalog.json`.

## Deviations from the proposal

Implemented 2026-11-13 (codelessly_api `lib/src/core/edit`, `lib/src/validate/edit_check.dart`; the SDK's
`lib/src/session`, `tool/stream`, `examples/stream_chat`).

* **`applyOps` takes the check as a parameter.** The strict validator imports every feature library (it decodes
  with `standardCatalog`), so the core cannot call it. `applyOps(..., check:)` defaults to `catalogCheck` (the core:
  types, keys and values against the catalog's declarations); `strictEditCheck()` in `validate.dart` runs the
  validator on what the op touched: the nodes it created or changed, their parents and children in full, the rest of
  the document as type-only stubs, codes the edit layer reports itself filtered out. `UiSession` defaults to the
  core check, so agent UI stays core-only; an app passes `strictEditCheck()` (the replay command does).
* **`incomplete: true` instead of a session-only rule.** Forward references are a flag of `applyOps`: a pending child
  is never an error, and while it is set, references to nodes, screens and variables that have not arrived
  (`unknown_target_node`, `unknown_screen`, `unknown_variable`, `unknown_name`) are warnings. `endOfStream` turns
  what is still dangling into `dangling_child`.
* **Events through `componentEvent`, not `emitEvent`.** `emitEvent` is the engage library's, so the core-only agent
  profile cannot allow it. A `componentEvent` outside any component (an agent's document is not one) goes to the
  document's host: `CodelesslyView` delivers it to `UiSession.events` (`event`, evaluated `value`, `source` node id,
  `rev`); `strictEditCheck` accepts it in a document without `widget`. `emitEvent` is handled the same way when the
  catalog has it.
* **Pending children render as hidden boxes, and empty containers wait.** Not a zero-size box: a box hidden as a
  binding hides it takes no room and no spacing, so the layout is the same as without the child, and its arrival
  re-applies only its own box. A container none of whose children shows yet is held back
  (`UiSession.holdEmptyContainers`, on) so no empty bordered shells flash. The canvas waits for content too.
* **A `set` may carry `nodes` (several nodes) and `placeholders`** (a pending child id → the layout to reserve). The
  streaming decoder yields each node of a `nodes` map as its own brace closes.
* **`set` that drops children is `would_orphan`**, not a silent orphaning; `remove` of an id already gone is a
  warning. Undo is `inverseOps` applied atomically (structure checked at the end), one step per batch or stream.
* **`TrustProfile.agent` allows every core node type**, not a hand-picked `safeWidgets` list (the core has no
  web view or embed: those are feature types), and no links by default (`linkHosts: {}`), images from any https
  host (`imageHosts: null`); `dataScopes` and `NavigationLimit` beyond `withinDocument` are not implemented.
* **`opsFromDocument`** declares a large data variable just before the first node that reads it (state variables
  with their canvas): declared up front, the restaurant page's 8 KB menu data held its header back 11 s at 150 tok/s.
* **The live adapter** is the example's (`examples/stream_chat/lib/src/llm.dart`, `anthropic_sdk_dart`), not the
  SDK's: the SDK takes no LLM dependency. It asks for eager tool input streaming, so `input_json_delta` events arrive
  as the input is generated.

* **Real streams are not valid JSON** (recorded 2026-11-13, three live generations). With eager tool input
  streaming the API does not validate the input, and `flights@claude-haiku-5-5` closed one brace too many three
  times (after writing `bind` beside `node`): the first decoder took the `ops` array as closed after 6 of 24 ops.
  The decoder now works around op boundaries (a repaired copy of the text, op objects at any depth outside an op,
  re-synchronisation when an op begins inside an unclosed one), reports each repair as `malformed_input` with its
  offset, and moves node fields written beside `node` into it (`misplaced_field`); all 24 ops apply.
* **The retry protocol is part of the edit layer**, not the host's prose: `toModelJson()` carries what the document
  holds and `next` (fix by patching, same ids, never start over); `protectRoots` answers a rebuild with
  `start_over` (the live haiku retry re-created the card under a new root); the diagnostics models hit carry the fix
  as JSON (`explainDiagnostic`). Lints of a finished UI (`empty_button`, `low_contrast`, `missing_glyph`, `no_size`)
  go back through the same channel: the weather card's empty yellow button was a model mistake (a `box` with a
  click reaction and no label: a box takes no children) that nothing reported; now `empty_button` does.
* **Runtime context: a base set plus a link to the full reference.** §4's ≈2.5k-word starter became
  `runtimeStarter` (generated from the declarations for the profile's types: rules, ops, layout and decoration
  essentials, one table of the base node types including the button family and the inputs, two verified examples)
  and the `ui_docs` tool (`docsTopic`: any node type, action type, trigger, behavior or guide area, generated from
  the same declarations and templates as docs/reference). 15,125 characters with 2,126 of compact tools against
  72,898 + 8,369 (full STARTER and full schemas). Not counted with a tokenizer here: ≈ 4,900 tokens at 3.5
  characters per token, ≈ 7,300 at the 2.37 the API measured for the full prompt (28,768 tokens): within §4's 6k
  budget only at the first estimate; the interactive components' tables were kept over the budget, as the owner
  asked.
* **Apps may run scripts** (`TrustProfile.agentApps`): the `scripts` op writes the document's sandboxed scripts,
  capabilities limited to variables and the clock; `agent` (chat cards) stays script-free.
* **Forced tool use only where the model takes it.** Haiku 5.5 with thinking off gets `tool_choice: any`; Sonnet
  5.5, Opus 5.5 and Fable 5.2 reject a forced choice (400), so they get `auto` and one nudge when a turn ends with
  text only.

## Measured

On the replay's virtual clock (synthetic streams, 4 characters per token; `CodelesslySDK/tool/stream/out/summary.md`):

| UI | Output tokens | First paint at 60 / 150 / 400 tok/s | Complete at 60 / 150 / 400 tok/s |
|---|---|---|---|
| Flight card (43 nodes) | ≈2,825 | 5.8 / 2.7 / 1.3 s | 47.6 / 19.3 / 7.6 s |
| Weather card (54 nodes) | ≈2,692 | 5.7 / 2.6 / 1.3 s | 45.4 / 18.4 / 7.2 s |
| Restaurant menu page (147 nodes) | ≈12,840 | 11.1 / 4.7 / 2.1 s | 214.5 / 86.1 / 32.6 s |
| SaaS pricing page (196 nodes) | ≈15,154 | 12.1 / 5.1 / 2.2 s | 253.1 / 101.5 / 38.4 s |

Median boxes re-applied per op: 0 to 2 (p90 6 to 15); the largest single op re-applies a list's 113 item boxes when
its data arrives. Follow-up edits: "sort by price" 17 tokens (one `move`), "make it dark" 156 tokens (five
`patch`es), against 2,825 and 2,692 to regenerate. The two cards are above the 2,000-token threshold of §4 for a
runtime screen; the system prompt the live example sends (rules, node and action types, the STARTER) is about 15k
tokens, above §4's 6k budget (it is cached).

## Not done

* **The hardened path is verified on three recorded streams only.** The compact prompt, `ui_docs`, the retry
  protocol, forced tool use and the app briefs were built and checked offline (the request JSON, recorded streams,
  hand-written fixtures for "works when used"); their effect on live validity, size and time is what
  `examples/stream_chat/tool/record_all.sh` measures.
* Formulas that call a session's scripts (`script.name(...)` in a binding) are validated and allowed by
  `agentApps`, but `CodelesslyView` wires only `runScript` reactions to the script runner; formula calls are not
  evaluated in a session view yet.
* `missing_glyph` needs the host to say which characters its fonts draw (`UiSession.glyphCoverage`); the replay
  and the record command use Roboto's cmap, an app passes nothing by default.
* The `codelessly` CLI and MCP server (phase 2), the editor's `DocStore` as op batches (phase 5), interop (phase 6).
* Components by path in ops (`plans/card1/cta`): ops address the session's own document only.
* `TrustProfile.dataScopes`, image host allow-lists by default, `maxDepth` measured through slots of instances.
* The compact op format of §4: not built; the recorded cards (3,170 to 4,886 output tokens) are above its
  2,000-token threshold.
* Partial text inside an incomplete op (A2UI Express's healing): an op applies only whole.
* Render-time feedback to the model (`render_exception`, overflow) after the first frame.
