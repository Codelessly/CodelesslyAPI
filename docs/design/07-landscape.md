# 07 · The generative-UI landscape, 13 November 2026

Status: research. Every product fact below carries the URL it was read
from on 2026-11-13. A sentence marked **Inference** is our reading, not a
published fact. Package versions and dates were read from the registries
(npm, pub.dev) where a URL is given as `registry.npmjs.org/...` or
`pub.dev/api/packages/...`.

The owner's question: "We still don't have the full A2UI and Vercel/UI
competitive landscape." This document is that landscape. Document 08 is
the developer-experience proposal built on it.

## 1. The short version

There are four camps, and they solve different problems.

1. **Chat-surface protocols** (A2UI, json-render, ChatKit widgets,
   CopilotKit's generative UI). A model emits a small declarative tree
   over a **fixed, developer-registered catalog**, the host renders it
   with its own components, and the UI is usually disposable: a card in a
   conversation. Styling is mostly not on the wire. All of them have
   converged on the same shape: a **flat list or map of components
   addressed by id, children by id, data in a separate JSON model bound
   by JSON Pointer**, streamed in order.
2. **Embedded app UIs in a chat host** (MCP Apps, which ChatGPT's Apps
   SDK implements). An HTML app in a sandboxed iframe, written by a
   developer ahead of time, fed tool inputs and results. The model chooses
   *when* to show it, not what it looks like.
3. **Agent-operable UI** (Vercel's UI SDK, released 2026-11-12; WebMCP).
   The interface is code written by a coding agent from a behavior
   library, and a running agent reads and drives it through a small
   snapshot/act API. This is what the owner called "Vercel's new /UI
   library".
4. **Generate code** (v0, Lovable, Bolt, Replit, Claude and ChatGPT
   canvases, Claude's inline visuals, FlutterFlow's Dreamflow). The model
   writes HTML/React/Flutter it already knows. Output quality is high and
   fast; the output is code, not editable data.

Nobody in the four camps offers what Codelessly is built for: a whole app
(screens, layout, styling, state, actions) as **one declared, validated,
id-addressed document** that a model generates and then edits in small
operations, that a person edits in a visual editor, and that renders
natively. That is the opening, and it is also the risk: it means
competing with camp 4 on generation quality while not being able to lean
on what models already know.

## 2. Google A2UI

**What it is.** An open protocol in which an agent describes UI as JSON
messages and the client renders them with its own registered components.
Verified: "A2UI 1.0: Build delightful, fast, reliable, agentic
experiences", Google Developers Blog, 2026-11-11
(https://developers.googleblog.com/a2ui-10-build-delightful-fast-reliable-agentic-experiences/).

**Latest release.** Verified:

| Artifact | Version | Date | Source |
|---|---|---|---|
| Spec | v1.0, status `current`; v0.9.1 `previous`; v0.8 `deprecated` | announced 2026-11-11 | https://a2ui.org/specification/versions.json |
| `a2ui_flutter` | 0.3.0 ("supports protocol v1.0 and v0.9", replaces `genui`) | 2026-11-11 | https://pub.dev/api/packages/a2ui_flutter |
| `a2ui_core` (Dart) | 0.7.0 | 2026-11-11 | https://pub.dev/api/packages/a2ui_core |
| `a2ui_agent` (Dart) | 0.3.0 | 2026-11-11 | https://pub.dev/api/packages/a2ui_agent |
| `genui` (Dart, superseded) | 0.10.4 | 2026-09-29 | https://pub.dev/api/packages/genui |
| A2UI CLI | v0.3.0 | 2026-11-11 | https://github.com/a2ui-project/a2ui/releases |
| Python `a2ui-agent-sdk` | 0.11.0 | 2026-11-10 | same |
| `@a2ui/react`, `@a2ui/web_core` | 0.15.0 | 2026-11-02 | https://registry.npmjs.org/@a2ui/react |
| `@a2ui/agent` (TS) | 0.1.0 | 2026-11-02 | https://registry.npmjs.org/@a2ui/agent |

Nothing newer than 2026-11-11 was found on the releases page, pub.dev or
npm. The repository has no tag named for spec 1.0.

**Wire format.** Verified, from the `a2ui_flutter` 0.3.0 README
(https://pub.dev/packages/a2ui_flutter):

```json
[
  {"version": "1.0", "createSurface": {"surfaceId": "hello", "catalogId": "https://a2ui.org/specification/v1_0/catalogs/basic/catalog.json"}},
  {"version": "1.0", "updateComponents": {"surfaceId": "hello", "components": [
    {"id": "root", "component": "Column", "children": ["greeting", "button"]},
    {"id": "greeting", "component": "Text", "text": "Hello, A2UI!"},
    {"id": "button", "component": "Button", "child": "label", "action": {"event": {"name": "greet"}}},
    {"id": "label", "component": "Text", "text": "Say hi"}
  ]}}
]
```

Messages from agent to renderer are `createSurface`, `updateComponents`,
`updateDataModel`, `deleteSurface`, `callRendererFunction`,
`agentFunctionResponse`; from renderer to agent `action`,
`callAgentFunction`, `rendererFunctionResponse`, `error`. Components are a
flat list with ids; parent-child links are ids; the component with id
`root` mounts the surface (https://a2ui.org/specification/v1.0-a2ui/).

**Component model.** A catalog, identified by a `catalogId`, declares the
components as JSON Schema. The v1.0 basic catalog has 18 components (Text,
Image, Icon, Video, AudioPlayer, Row, Column, List, Card, Tabs, Modal,
Divider, Button, TextField, CheckBox, ChoicePicker, Slider, DateTimeInput)
and 14 functions (`required`, `regex`, `length`, `numeric`, `email`,
`formatString`, `formatNumber`, `formatCurrency`, `formatDate`,
`pluralize`, `openUrl`, `and`, `or`, `not`); the file is 42 KB (verified by
download: https://a2ui.org/specification/v1_0/catalogs/basic/catalog.json).
Custom catalogs have the same structure. **Styling is not on the wire**:
Text has only `variant` (`caption`, `body`) and `weight`; v1.0 removed
`theme` from `createSurface` ("a `createSurface` that includes `theme` is
invalid"); look is the renderer's native theme (spec, same URL).

**Data binding.** A separate JSON data model per surface; bindings are
JSON Pointers, `{"@path": "/flight/number"}`; relative paths inside list
templates; functions as `{"@call": "...", "args": {...}}` (spec). The 1.0
blog adds "secure data binding": "A2UI reliably binds to your data and
child components on the server, so sensitive values never reach the
model" (blog, above).

**Actions and the round trip.** A component's action sends an `action`
message (`name`, `surfaceId`, `sourceComponentId`, `context`) to the agent,
which answers in its next turn. New in 1.0: bidirectional function calls
(`callAgentFunction` / `callRendererFunction`, with `allowedCallers` and
`requiresUserActivation`), so a picker can ask the agent for availability
without a full turn (spec; blog).

**Streaming.** Messages apply in arrival order; rendering may begin once
`root` exists; missing child references render as placeholders; data
paths may be undefined until their `updateDataModel` arrives (spec).

**Editing model.** `updateComponents` "adds or updates" components by id;
`updateDataModel` upserts the value at a path (`null` removes). The spec
does not define field-level merge for a re-sent component, so a change to
one property means re-sending the whole component (spec). **Inference:**
editing is component-granular replace, which is fine for cards of 5–30
components and is the same unit our nodes have.

**Inference formats and Express.** Since 1.0 the agent SDKs let the model
write a compact format that a compiler turns into wire JSON. "A2UI Express"
is "a compact positional DSL with nested component calls and `$/path` data
assignments, compiled to flat wire JSON", wrapped in `<a2ui>` tags, and is
the default format in the Python, TypeScript and Dart agent SDKs
(https://a2ui.org/concepts/inference-formats/). The opening of the
published example (https://developers.googleblog.com/fast-reliable-a2ui/,
2026-10-27):

```
surface("gallery-notification-permission")
$/description="Get alerts for order status changes"
$/icon="check"
root=Card(main_column)
```

Token claims, and how they were measured (inference-formats page): the
54-sample `core_v1_0` eval suite, `gemini-3.8-flash`, temperature 0,
thinking off or unbounded. Median input tokens 10,980 → 6,000 (−45.4%);
median generated UI ("code") tokens 807 → 297 (−63.2%) with thinking off
and 794 → 260 (−67.3%) with it on; Pass@1 98.1% for both formats; judge
quality equal. The October blog claims "up to 3x" lower latency and "up to
3x fewer tokens", and up to 80x with a "System One" decision model that
picks components instead of writing text. **Note the scale**: the median
A2UI answer is about 800 tokens of JSON. Our experiment pages are 15–22k
(§12).

**Renderers.** React, Angular, Lit; Flutter (mobile, web, desktop);
SwiftUI; Jetpack Compose (at 0.9.1, 1.0 "coming soon"); the web and
Flutter renderers "also run inside MCP Apps"; ByteDance's Lynx supports
0.9 (blog).

**Trust.** The agent can only place components the developer registered;
the app draws them; data bound server-side never reaches the model; the
blog's example sends nothing until the user confirms (blog). Functions
have `allowedCallers` and `requiresUserActivation` (spec).

**Validation and error feedback.** A standard error payload with `code`
(`VALIDATION_FAILED`, `UNALLOWED_PARENT`, `UNALLOWED_CHILD`), `surfaceId`,
a JSON Pointer `path` and a message, "intended to be fed back to the LLM
for correction" (spec). The agent SDKs "help ... correct errors" (blog).

**Adoption.** Named in the 1.0 blog: Atlassian (Jira), Alation, ByteDance
(Lynx renderer), Bloomberg (no detail), Gemini Notebook, Gemini (renders
registered agents' A2UI at 0.9.1), Gemini Enterprise (moving to 1.0).
CopilotKit ships an A2UI catalog of 70 components (18 basic + 52 its own)
(https://www.copilotkit.ai/blog/open-intelligent-ui-with-a2ui, 2026-11-12).

**Our history with it.** We built a Codelessly A2UI renderer and catalog
on v0.9.1 (`CodelesslyEditor/docs/genui_a2ui.md`: `codelessly_genui`,
streaming through `A2uiJsonStreamParser`, a placeholder for each failing
component and the error returned in the `tool_result`, at most two
automatic repair turns). It was deleted in a cleanup. Its mapping table
(Text→`text`, Button→`filledButton`/`outlinedButton`/`textButton`,
ChoicePicker→`chip`s, Card→frame, and "Image, Icon, Tabs, Modal,
DateTimeInput: no Codelessly node yet") is the starting point for any
A2UI interop in doc 08.

## 3. Vercel: the "/UI" release is the UI SDK (2026-11-12)

**Finding it.** Checked: vercel.com/blog (newest posts 2026-11-02 to
2026-11-09, none about UI), vercel.com/changelog (entries 9–12 Nov, all AI
Gateway and platform; none about UI), the AI SDK (`ai` 7.0.171, published
2026-11-12T20:22Z, a patch release:
https://registry.npmjs.org/ai), json-render (latest 0.22.0, 2026-11-04),
and npm. The release is **UI SDK**:

* `@ui-sdk/react` 0.1.0-beta.1, published **2026-11-12T17:09Z**, created
  the same minute; maintainer `shadcn`; repository
  `github.com/vercel-labs/ui`; Apache-2.0; homepage https://ui-sdk.dev;
  "A library of behaviors to build your components";
  `npm install @ui-sdk/react @ui-sdk/core`; "The docs also ship in this
  package as Markdown, starting at `docs/llms.txt`, for your editor and
  your agent" (https://registry.npmjs.org/@ui-sdk/react).
* Vercel's post on X, "Introducing the UI SDK"
  (https://x.com/vercel/status/2120950020249895314), and Chris Tate's:
  "UI SDK: a library of behaviors for agents to build the next generation
  of UIs → 50+ behaviors: popups, selection, typeahead, focus → Components
  for React, Vue, Svelte, Solid, Web Components → Easy for agents to build
  with, and for any agent to use"
  (https://x.com/ctatedev/status/2120966861252960508). Both were seen as
  search results; X pages were not fetched.

On 2026-11-13 in the owner's time zone it was the previous evening's
release; nothing Vercel released on the 13th was found.

**What it is.** Verified (https://ui-sdk.dev, https://ui-sdk.dev/llms.txt):
a framework-free TypeScript core of interface behaviors (focus,
selection, dragging, lists, trees, transitions, popups, canvases) with
renderers for React, Vue, Svelte, Solid and Web Components, plus a starter
component set. "The agent picks the behaviors it needs and puts them
together in your framework." It is **not runtime generative UI**: there is
no wire format, and the site does not mention generative UI, json-render
or MCP. A coding agent writes the components at development time, guided
by a skill (`npx skills add vercel-labs/ui --skill ui-sdk`, per secondary
coverage; not verified on the site).

**The agent bridge.** Verified (https://ui-sdk.dev/docs/agents): at
runtime, `createAgent` from `@ui-sdk/react/agent` gives an agent two calls.
`agent.snapshot()` returns each component with a `ref`, its `component`
type, `label`, current `value` and available `actions` (the docs' example:
an input `c1`, "Project name", value "Apollo", actions `setValue` and
`clear`). `agent.act()` runs steps:

```js
await agent.act({
  steps: [{ ref: "Project name", action: "setValue", args: ["Atlas"] }],
})
```

Changes go through the component's own API; change callbacks get
`source: "agent"` and can cancel; the app approves or refuses through an
`allow` callback. The same tools can be registered with the browser via
WebMCP. Their benchmark (a project-settings task, Sonnet through Claude
Code, medians of three runs): browser tools on another component library
vs the bridge — tool calls 16 → 5, characters read 39.8k → 6.8k, time
41 s → 16 s, cost $0.073 → $0.032.

**Inference.** Two lessons for us. (1) Vercel's bet for *building* UI is
"agents write code from good primitives", the camp-4 answer, not a JSON
DSL. (2) Its bet for *operating* UI is a compact, id/label-addressed
snapshot plus typed actions, the same shape as our flat document plus
`--tap`/`--set` steps.

### 3.1 json-render (Vercel Labs), the Vercel generative-UI framework

Verified (https://github.com/vercel-labs/json-render,
https://json-render.dev/docs/streaming, https://json-render.dev/docs/changelog):

* **Release.** `@json-render/core` and `/react` 0.22.0, 2026-11-04 (a Chat
  SDK renderer for Slack/Teams cards); 0.21.0 2026-09-18 (TanStack Start
  renderer, experimental "Jev composition APIs"); edit modes 0.14.0
  (2026-03-13); MCP Apps 0.12.0 (2026-03-06). Repository: 19.6k stars,
  Apache-2.0. Vercel changelog 2026-11-06: "Chat SDK agents can now stream
  generative UI with json-render"
  (https://vercel.com/changelog/json-render-and-chat-sdk-agents).
* **Wire format.** Flat: a `root` key and an `elements` map by id; each
  element has `type`, `props`, `children` (ids):

```json
{"root": "card-1", "elements": {
  "card-1": {"type": "Card", "props": {"title": "Hello"}, "children": ["button-1"]},
  "button-1": {"type": "Button", "props": {"label": "Click me"}, "children": []}}}
```

* **Component model.** `defineCatalog(schema, {components, actions})` with a
  zod `props` schema and a description per component; `catalog.prompt()`
  generates the system prompt; `defineRegistry` maps to implementations. A
  shadcn/ui set of 36 components ships. Styling is whatever the props
  declare.
* **Binding.** `$state`, `$cond/$then/$else`, `$template`, `$computed`,
  `$bindState` (two-way), `visible` conditions, `watch`.
* **Actions.** Components `emit` named actions; built-in `setState`;
  declared catalog actions go to the app.
* **Streaming.** "SpecStream": JSONL, each line an RFC 6902 JSON Patch op:

```json
{"op":"add","path":"/root","value":"root"}
{"op":"add","path":"/elements/root","value":{"type":"Card","props":{"title":"Dashboard"},"children":["metric-1","metric-2"]}}
{"op":"add","path":"/elements/metric-1","value":{"type":"Metric","props":{"label":"Revenue"}}}
```

* **Editing.** Three edit modes for multi-turn refinement: RFC 6902 patch,
  RFC 7396 merge patch, unified diff, chosen with `editModes` on the
  prompt builder; YAML wire variants (`yaml-edit`, `yaml-patch`).
* **Renderers.** React, Vue, Svelte, Solid, React Native, Remotion, React
  PDF, React Email, Slack/Teams/Discord cards, Satori images, React Three
  Fiber, Ink, Next.js/TanStack apps. No Flutter.
* **Validation.** Against the zod schemas; "can only use components in your
  catalog". The error-feedback mechanism is not documented on the pages
  read.

**Inference.** json-render is the closest thing in the market to our wire
shape (flat map by id, patches over it, edit modes), but over a
developer-written component set without layout or styling vocabulary. It
is the system to beat on "edit as data" for small surfaces.

### 3.2 AI SDK and AI Elements

`ai` 7.0.171 and `@ai-sdk/react` 4.0.175 were published 2026-11-12
(registry). AI SDK 7 was announced 2026-06-25 (vercel.com/blog listing).
**Inference** (not re-read for this document): generative UI in the AI
SDK is typed tool-call parts rendered by the app's own components; AI
Elements is a chat component kit. Neither is a UI-as-data format.

## 4. MCP Apps (and MCP-UI, and OpenAI's Apps SDK)

**What it is.** The official MCP extension for interactive UI returned by
an MCP server. It "builds on proven work from MCP-UI and OpenAI Apps SDK";
the proposal (SEP-1865) was written by MCP maintainers at OpenAI and
Anthropic with the MCP-UI creators
(https://blog.modelcontextprotocol.io/posts/2025-11-21-mcp-apps/). Stable
spec revision 2026-01-26
(https://github.com/modelcontextprotocol/ext-apps/blob/main/specification/2026-01-26/apps.mdx).

**Latest release.** `@modelcontextprotocol/ext-apps` v2.1.0 on GitHub,
10 Nov (WebMCP interoperability: tools registered with `App.registerTool()`
are mirrored into `document.modelContext`; the draft spec no longer
requires double sandboxed iframes); npm's `latest` tag read 2.0.4
(2026-10-27) at the time of checking
(https://github.com/modelcontextprotocol/ext-apps/releases,
https://registry.npmjs.org/@modelcontextprotocol/ext-apps). v2.0.0: "The
MCP Apps wire protocol is unchanged". MCP-UI's own packages
(`@mcp-ui/client` 7.1.1, 2026-05-09) are now mostly superseded.

**Wire format.** A tool points at a UI resource:

```json
{"name": "get_forecast", "inputSchema": {"type": "object"},
 "_meta": {"ui": {"resourceUri": "ui://weather-server/dashboard-template", "visibility": ["model", "app"]}}}
```

The resource must be `ui://...` with MIME type `text/html;profile=mcp-app`;
"the initial specification supports only HTML". The View and host talk
JSON-RPC over postMessage: `ui/initialize`, `ui/notifications/tool-input`
(and `-partial` for streamed arguments), `ui/notifications/tool-result`,
`ui/message`, `ui/update-model-context`, `ui/open-link`, and standard
`tools/call` and `resources/read` (spec).

**Component model, binding, styling.** None: it is an arbitrary web app.
The developer writes it; the model only supplies tool arguments.
**Actions.** The View may call server tools (`tools/call`; tools with
`visibility: ["app"]` are hidden from the model), post a message into the
conversation, or update the model's context.
**Trust.** Sandboxed iframe, a sandbox proxy on another origin for web
hosts, CSP from the resource's `ui.csp` (`connectDomains`,
`resourceDomains`); default blocks external connections; hosts must not
allow undeclared domains (spec).
**Editing / validation / tokens.** Not applicable; the UI is not generated.
**Adoption.** ChatGPT "implements the open MCP Apps standard"; OpenAI's
reference says to use the standard's `ui/*` bridge by default and treat
`window.openai` as optional ChatGPT-only extensions
(https://developers.openai.com/apps-sdk/mcp-apps-in-chatgpt). Claude,
VS Code, Cursor are named as hosts by json-render's MCP package
(changelog above). A2UI's web and Flutter renderers run inside MCP Apps
(A2UI blog).

**Inference.** MCP Apps is the distribution channel, not a competitor: it
is how an A2UI surface, a json-render spec, or a Codelessly document gets
into Claude or ChatGPT. The constraint is "HTML only", so our route in is
the Flutter web build as the HTML resource.

## 5. OpenAI

* **Apps SDK**: MCP Apps plus `window.openai` extensions (above).
* **ChatKit**: an embeddable chat UI; widgets are the rendering layer for
  structured blocks; new apps should use "your own ChatKit server";
  `@openai/chatkit-react` 1.6.1 (2026-07-31, registry); the hosted Agent
  Builder shuts down 2026-11-30
  (https://developers.openai.com/api/docs/guides/chatkit). The widget
  format itself was not on the page read; not verified here.
* **Intelligent UI in ChatGPT**, launched with GPT-6 on 2026-10-07:
  interactive charts, editable graphs, calculators, buttons inline in
  answers (https://techcrunch.com/2026/10/07/chatgpt-is-getting-a-lot-more-visual-with-the-launch-of-a-new-interface/).
  The technical description ("native, streamable components with a
  compiler") comes from secondary coverage; OpenAI's own post was not
  read. CopilotKit (a competitor, 2026-11-12) states it is closed, OpenAI
  models only, with no API. **Not verified** from an OpenAI source.

**Inference.** OpenAI made generative UI the default answer for a very
large audience, but as a first-party, closed feature. For developers it
offers MCP Apps (hand-written HTML) and ChatKit widgets (a fixed widget
vocabulary).

## 6. AG-UI and CopilotKit

**AG-UI** is an event protocol between an agent backend and a frontend:
lifecycle, text message, tool call (`ToolCallStart/Args/End/Result`),
state (`StateSnapshot`, `StateDelta` as RFC 6902 JSON Patch,
`MessagesSnapshot`), activity, reasoning, subagent, `Raw` and `Custom`
events (https://docs.ag-ui.com/concepts/events). AG-UI 1.0 (2026-09-30): a
JSON Schema for every event, SDKs generated from it, subagents,
human-in-the-loop interrupts, token usage on finish, backwards compatible
(https://www.copilotkit.ai/blog/ag-ui-1.0). `@ag-ui/core` 1.0.4,
2026-11-05 (registry). Claimed adopters: Google, Microsoft, Amazon,
Oracle; frameworks LangChain, Mastra, Google ADK, OpenAI Agents SDK,
Strands, Microsoft Agent Framework, Pydantic AI, Anthropic's Claude
Managed Agents (vendor claims, same post).

**CopilotKit** renders A2UI 1.0 carried over AG-UI; 70-component catalog;
`createGenerativeUI` for custom components, `GenerativeUISurface`;
components that fail the catalog are returned to the agent to correct;
"interactions run in the browser at zero extra tokens" (2026-11-12 post,
above). `@copilotkit/react-core` 1.87.1, 2026-11-12; 2.0.0-rc.45 on
`next` (registry). The post labels the generative-UI features
experimental.

**Inference.** AG-UI is a transport we can ride without designing
anything: our edit operations travel as tool-call arguments (streamed by
`ToolCallArgs`) or as `StateDelta` patches on a `ui` key.

## 7. Anthropic: generate code into a sandbox

* **Artifacts** (2024 onward): the model writes HTML/React/SVG/Markdown
  into a sandboxed, persistent, shareable page. Regeneration or targeted
  text edits of the source; no declared vocabulary.
* **Interactive visuals in chat** ("Custom Visuals in Chat"), reported
  launched for all plans on 2026-03-12: inline, ephemeral HTML/SVG charts
  and diagrams, an expansion of the "Imagine with Claude" research preview
  (https://thenewstack.io/anthropics-claude-interactive-visualizations/;
  secondary sources; Anthropic's own announcement was not found).
* **Claude Design**, an Anthropic Labs research preview, reported
  2026-04-17 (secondary source only, not verified).

**Inference.** Anthropic's chat UI bets on code generation into a
sandbox; its protocol bet is MCP Apps. Neither gives a developer an
editable UI document.

## 8. Flutter-specific

| Product | Latest (verified) | What it is | AI story |
|---|---|---|---|
| `a2ui_flutter` + `a2ui_core` + `a2ui_agent` | 0.3.0 / 0.7.0 / 0.3.0, 2026-11-11 (pub.dev) | Official A2UI renderer, protocol core and Dart agent helper. `a2ui_agent`: "negotiates catalogs with the renderer, teaches the model the catalog, and parses its reply into A2UI messages" | The successor to `genui` (0.10.4, 2026-09-29), which its README says these replace |
| `rfw` (Remote Flutter Widgets) | 2.0.0, 2026-10-21 (pub.dev); "migrates the package to material_ui", Flutter 3.44 / Dart 3.12 (https://pub.dev/packages/rfw/changelog) | A text/binary widget-library format interpreted at runtime | None published. Not a model target |
| Stac | 1.6.0, 2026-09-13 (pub.dev) | Server-driven UI: JSON → widgets (`Stac.fromJson`), Dart DSL compiled to JSON, Stac Cloud (https://docs.stac.dev/why_stac) | No AI generation feature found |
| FlutterFlow / Dreamflow | not verified | Visual builder; Dreamflow is the team's prompt-to-app builder emitting Flutter code (secondary sources only) | Generates code, not a documented data format |

Server-driven UI vendors (DivKit, Judo and similar) were searched for an
AI story; none was found worth listing. Not verified further.

**Inference.** In Flutter, Google's own path is now A2UI (small catalog,
chat surfaces). Nobody offers whole apps as data with an AI authoring
path, and nobody renders through render objects rather than widgets.

## 9. "Just generate code"

v0 (Vercel), Lovable, Bolt, Replit Agent, Claude artifacts, ChatGPT
canvas, Dreamflow. Their current versions were not re-verified for this
document (third-party pricing pages only, e.g. v0's free tier limits as
of 2026-11-07 per taskade.com; not primary). What matters is the
paradigm and our own numbers for it.

**Our evidence** (`CodelesslyEditor/experiments/reference/*/RESULTS.md`):
the ten reference sites were built in HTML/CSS/JS by an agent from a
`SPEC.md`. Recorded initial-build times: storefront ≈12 min (133,433
tokens), restaurant ≈13 min (127,859 tokens), saas-landing ≈16 min
(≈158,000 tokens), studio-portfolio 16 min 23 s (135,569 tokens),
travel-guide ≈20 min (≈177,000 tokens); with a polish pass included:
magazine 24 min, property-listings 28 min, conference ≈30 min (review
pass only), docs-site ≈33 min, nonprofit 55 min. Each is a **whole site of
5–12 pages**. The same restaurant and SaaS briefs, one page each, built
directly as Codelessly JSON took 21–27 min (§12). Caveats: the HTML runs
had no pixel target to match; one file names a "Codex goal runtime", so
the harness is not certainly the one used for m05; token counts include
tool traffic.

**Inference.** Per page, writing code was roughly 5–10x faster than
writing our data, before any of the planned layout changes. That is the
owner's "AI is good at writing existing code" in numbers. The price of
code is that the result is not editable data: no visual editor, no
validated patch, no per-node update, no catalog boundary, and every
follow-up edit is a code edit with whole-file risk.

## 10. Comparison

"Fixed" = the model can only use what a developer registered.

| | A2UI 1.0 | json-render 0.22 | UI SDK beta | MCP Apps | ChatKit / Intelligent UI | AG-UI | Code generators | **Codelessly today** |
|---|---|---|---|---|---|---|---|---|
| Unit | Surface (card, form) | Spec (card to page) | Component code | Tool's HTML app | Widget / answer | Event stream | Repo / file | **Whole app: screens, pages, components** |
| Wire | Flat component list, ids; data model | Flat `elements` map, ids | None (code) | HTML resource + JSON-RPC | Widget JSON (not verified) | JSON events | Source code | **Flat `nodes` map by id** (`docs/reference/index.md` §1) |
| Catalog | Fixed; 18 basic; custom catalogs | Fixed; zod per component | 50+ behaviors | n/a | Fixed | n/a | Open (any code) | **66 node types, 43 action types**, declared `Catalog`, `catalog.json` 736 KB |
| Styling on wire | No (removed in 1.0) | Only via declared props | In code | In code | Little | n/a | Full | **Full: layout, decoration, text styles, states, motion** |
| Data binding | JSON Pointer `@path`, functions | `$state`, `$cond`, `$computed` | App code | App code | n/a | State + JSON Patch | Code | **Typed variables, `${...}` and `${= formula}` bindings, conditions** |
| Interactivity | `action` → next turn; function calls | `emit` → app; `setState` | Components; agent `act` | Tool calls, `ui/message` | Actions → server | Tool calls | Code | **Triggers + 43 actions run locally; no agent round trip yet** |
| Streaming | Yes, in order, root first, placeholders | JSONL RFC 6902 | n/a | Partial tool input | Yes (claimed) | Yes | Token stream | **No public API.** `DocumentSource` re-notifies changed nodes on replace (`CodelesslySDK/lib/src/render/source.dart`) |
| Edit model | Re-send component by id | Patch / merge patch / diff | Edit code | Edit code | Regenerate | State deltas | Edit files | **Design time only: editor MCP `nodes.patch` etc. (needs live editor); file edits** |
| Renderers | Web ×3, Flutter, SwiftUI, Compose, Lynx | Many web/RN/PDF/email | Web ×5 | Any HTML host | OpenAI only | n/a | Their stack | **Flutter only** (mobile, desktop, web build) |
| Trust | Registered components; server-side binding | Catalog | App's `allow` | iframe + CSP | Vendor | n/a | Sandbox | **Catalog + strict validation; hosted-plugin `requires` (doc 05 §5.4); no agent profile yet** |
| Validation feedback | Typed error, JSON Pointer | zod (format not documented) | Types | n/a | n/a | JSON Schema | Compiler/tests | **50 typed diagnostic codes, JSON Pointer, suggestions** (`lib/src/validate/diagnostic.dart`); render command adds layout checks |
| Token efficiency | Express −63% generated tokens (54-sample eval) | Not published | Bridge −83% read (3 runs) | n/a | n/a | n/a | Not published | **Pages 51–76 KB minified ≈ 15–22k tokens; no compact form** |
| Interop | Is the standard | MCP Apps, chat cards | WebMCP | Is the standard | MCP Apps | Carries A2UI | n/a | **None** (A2UI bridge deleted) |
| Human visual editor | No | Playground | No | No | No | No | Some (v0, Lovable) | **Yes: the Codelessly editor on the same data** |

Where Codelessly is behind, plainly: no runtime generation path; no
streaming or patch API; the editor's MCP needs a running editor; Flutter
is the only renderer; the vocabulary is large (catalog 736 KB vs A2UI's 42
KB basic catalog), so a model needs a 6.4k-word starter just to begin; no
interop with A2UI, MCP Apps or AG-UI; and authoring is 5–10x slower per
page than writing code.

Where it is ahead: it is the only entry whose wire carries a complete app
with styling and logic **and** a visual editor **and** strict typed
validation **and** a native renderer with node-level updates.

## 11. What each camp has figured out that we should adopt

1. **A2UI: root first, placeholders, render early.** Any order of arrival
   is legal; missing children render as placeholders; nothing waits for
   the whole answer. Our streaming API should copy these rules exactly.
2. **A2UI: typed errors are part of the protocol**, sent back to the
   model. We have better errors (50 codes vs 3); they need to be in the
   tool result of every edit, not only in a CLI.
3. **A2UI: keep secrets out of the model.** Server-side binding means the
   model writes `${user.balance}`, never the balance. Our bindings already
   work this way; the runtime API must not serialize data scopes into the
   prompt by default.
4. **A2UI Express: measure inference formats against wire JSON** with a
   fixed eval, and separate "what the model writes" from "what is
   stored". Adopt the method; decide the format from our numbers (doc 08
   §4).
5. **json-render: edit modes.** Patch, merge patch and diff as explicit
   modes for a follow-up turn, chosen per task. We should ship merge patch
   per node plus structural ops (doc 08 §3).
6. **json-render / A2UI: the catalog generates the prompt.**
   `catalog.prompt()`; our equivalent is a starter generated from a catalog
   slice.
7. **UI SDK: a compact, addressable snapshot and typed actions** beat
   screenshots and DOM for an agent operating a UI (−83% text read). Our
   outline view and `--tap/--set` steps are the same idea; expose them as
   tools.
8. **UI SDK: docs inside the package, `llms.txt`, an agent skill.** Ship
   the starter and reference inside `codelessly_api`, with a skill file.
9. **MCP Apps: be a guest in every chat host** through one HTML resource,
   rather than build host integrations one by one.
10. **AG-UI: don't invent a transport.** Edits ride tool-call arguments.
11. **Code generators: models are fluent in widget code.** Keep the data
    one mechanical translation from Flutter (docs/design/README.md "AI
    authoring"), and consider a Flutter-subset-to-data translator if the
    evaluation says authoring speed is the bottleneck (doc 08 §7).

## 12. Our own numbers, for reference

From `/home/user/experiments/m05/c1/*/RESULTS.md` and `c1p/*/RESULTS.md`
(times from the experiment brief; RESULTS.md files do not record them;
the `runs.log` of saas-landing-B spans 02:56:55–03:09:55 of render runs):

| Run | Task | Time | Render runs | Nodes | Size (as written) | Minified (measured) |
|---|---|---|---|---|---|---|
| restaurant-A | rebuild menu page | 21–27 min (range for the four) | 31 | 202 | 67.2 KB | 57.4 KB |
| restaurant-B | rebuild menu page | | ≈49 | 254 | 75.1 KB | 67.6 KB |
| saas-landing-A | rebuild pricing page | | 22 | 253 | 112.6 KB | 73.8 KB |
| saas-landing-B | rebuild pricing page | | 35 | 189 | 80 KB | 51.3 KB |
| c1p restaurant-B | design from brief, 3 canvases | 16–18 min (range for the two) | 28 | 466 | 183 KB | 117 KB |
| c1p saas-landing-B | design from brief | | 19–28 | 293 | 117 KB | 76.1 KB |

Median node size, minified: 205–235 bytes (measured over the five
single-file documents). Agents read ≈15–25k words of the 66.7k-word
reference (`docs/reference/API_REFERENCE.md`); the 6.4k-word starter plus
reference by link gave the same quality. Responsive layout through formula
strings (`"props.style.fontSize": "${= rv(88, 50, 52)}"`, saas-landing-A
`heroH1`) was the largest friction.

## 13. What could not be verified

* The UI SDK X posts were seen only as search results; the vercel-labs/ui
  repository and its releases page were not opened (GitHub API access was
  not available in this session); the skill install command is from
  secondary coverage.
* A2UI's Dart agent SDK name in the 1.0 blog links to the PyPI page; the
  Dart package `a2ui_agent` 0.3.0 is verified on pub.dev.
* The full A2UI v1.0 spec page was read to about 100k of 116k characters;
  the renderer-to-agent `error` message details beyond the payload fields
  were in the unread part.
* OpenAI Intelligent UI's technical design and ChatKit's widget format;
  Anthropic's interactive-visuals announcement (secondary sources only);
  Claude Design; Dreamflow; current versions of v0, Lovable, Bolt, Replit.
* ext-apps v2.1.0's npm tag (GitHub shows it as latest; npm `latest` read
  2.0.4).
* Adoption lists are vendors' own claims.
