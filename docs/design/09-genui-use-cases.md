# Inline generative UI: the use cases

What competitors and component libraries show an assistant rendering inside a conversation, collected on
2026-11-13, and the list we test Codelessly against. It is the brief for the generative UI demo page and for the
head-to-head runs.

Sources read: assistant-ui.com/components and /elements; github.com/assistant-ui/tool-ui (archived 2026-09-26;
its docs now redirect to assistant-ui's elements); a2ui.org, its samples and the A2UI 1.0 announcement;
vercel-labs/json-render; docs.copilotkit.ai; the OpenAI Apps SDK examples. Descriptions are paraphrased. Not
read: CopilotKit's generative UI sub-pages, the A2UI partner demo apps, json-render's individual examples.

## 1. Use-case types, by how many sources show them

| # | Type | Shown by |
|---|---|---|
| 1 | A summary or metric card with actions | A2UI, Google's post, json-render, OpenAI |
| 2 | Charts, metrics, a dashboard | A2UI, Alation (via Google), json-render, assistant-ui |
| 3 | Values edited in place before submitting (fields, quantities, caps, toggles) | A2UI, Gemini Notebook, json-render, OpenAI |
| 4 | Confirm or approve before the agent acts | A2UI, Atlassian, CopilotKit, assistant-ui |
| 5 | A picker or choice (options, seat, time slot, refund or replace) | A2UI, Gemini Notebook, json-render, assistant-ui |
| 6 | A multi-step flow or checkout | A2UI, Google's post, OpenAI |
| 7 | A map or spatial view | A2UI (cabin map), OpenAI (pizza map), assistant-ui, json-render (3D) |
| 8 | A widget calling back to the host or agent (tool call, follow-up, state) | OpenAI, Google's post, json-render |
| 9 | A list or carousel to browse | OpenAI, assistant-ui |
| 10 | An itinerary, timeline or checklist | A2UI, Lynx (via Google), assistant-ui |
| 11 | Cards in a chat channel (Slack, Teams) | json-render, CopilotKit |
| 12 | A game | OpenAI (Cards Against AI), json-render |
| 13 | A document, email or video as output, not interactive | json-render |

## 2. Named demos

**A2UI and Google.** Dinner for four (recipe card and delivery slot picker); spending this week against usual
(comparison card and a weekly cap); hosting twelve kids (timeline and checklist); cracked eggs (refund or
replace); flight rebooking (flight card, seat chips, confirm); a cabin seat map in a sandboxed frame; an order
card with Reorder; a Jira follow-up question answered in a card; Alation's metric feed with the SQL behind each
chart; a Kyoto two-day itinerary; Gemini Notebook's options and review cards; the sick-day view across six apps
with nothing sent until confirm; a reservation picker checking availability live; the restaurant finder sample.

**json-render.** A metric dashboard with export and refresh; a country select that loads cities; cards streamed
into Slack, Teams and Discord; documents, email, video timelines, a terminal status card, 3D scenes.

**OpenAI Apps SDK.** Pizza list, carousel, map, shop and checkout; a shopping cart with quantities; a solar
system viewer; a multiplayer card game.

**Tool UI (27 components).** Progress: plan, progress tracker. Input: option list, parameter slider, preferences
panel, question flow. Display: citation, geo map, item carousel, link preview, stats display, terminal, weather
widget. Artifacts: chart, code block, code diff, data table, Instagram post, LinkedIn post, message draft, X
post. Confirmation: approval card, order summary. Media: audio, image, image gallery, video.

## 3. assistant-ui's elements

The page lists 128 entries (its headline says 151). About 48 are widgets rendered inside the conversation:

- **Cards and documents:** artifact card, comparison, link preview, document reference, sources, research
  report, spec sheet, score breakdown, job progress, task card, subagent list, run activity, memory, file,
  image, image gallery, image generation, media player, web preview, computer use, diagram, Mermaid diagram.
- **Data and charts:** chart, data table, heat graph, timeline, flow graph, trace waterfall, tool timeline,
  retrieval chunks, geo map, map.
- **Code and terminal:** code diff, code runner, reviewable diff, file tree, terminal block, web search, tool
  call, tool fallback, tool failure, todo list.
- **Decisions and forms:** approval card, permission grant, recommendation card, elicitation form, question
  flow, option list.

The rest is the chat itself, which a generative UI demo also needs around the widgets: the thread, message
pair, composer (attachments, mentions, slash commands, model picker, dictation), message actions and branches,
reasoning and chain of thought, tool groups, follow-up suggestions, and state indicators (thinking, typing,
loading, error, stopped run, connection, quota, cost and context meters).

## 4. Our test list

Run so far through the streaming path: flights (pick and confirm), weather, sudoku, form builder, basketball
shooting game, kanban, habit tracker, memory game, and two full pages (restaurant menu, pricing).

Add, to cover the types above that we have not tested:

| Type | Brief |
|---|---|
| 2 | A metric dashboard: four stat tiles, a line chart and a bar chart, a date-range toggle, a sortable table |
| 3, 4 | An order summary: line items with editable quantities, a promo field, totals, confirm or cancel |
| 4 | An approval card for a consequential action, with the details spelled out and approve or deny |
| 5 | A question flow: three short questions in sequence with branching, one result |
| 5, 8 | A reservation picker: date, party size, time slots whose availability changes, confirm |
| 6 | A checkout: cart, shipping form with validation, payment summary, confirmation |
| 7 | A place list beside a map with pins that highlight with the selected card |
| 9 | A product carousel with a detail view |
| 10 | A two-day itinerary as an expandable timeline with a checklist |
| 1 | A comparison of two options side by side with a recommendation |
| - | A data table of tool results: sort, filter, paginate, select rows, act on the selection |
| - | A message draft (email) with editable fields and send or discard |
| - | A plan with steps that tick off as a job progresses |
| - | A code diff with keep or discard per hunk |
| - | An image gallery with a lightbox |

Beyond what competitors show, and where the full vocabulary should matter: the games, the form builder, and
anything needing animation, drag and drop or custom drawing.

## 5. The demo page

A page in the spirit of assistant-ui's elements gallery: every use case above as a live tile, each generated by
a model through `ui_apply` and rendered by the SDK as it streams, replayable from its recorded stream, with the
prompt, the model, the time and the token count shown, and the same brief run through A2UI and json-render
beside it where they can express it. Each tile opens to its document, so it can be edited as data.
