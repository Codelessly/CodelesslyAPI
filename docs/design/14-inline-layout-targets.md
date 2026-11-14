# Inline layout targets: assistant-ui's elements

Owner, 2026-11-14: "get the inline layouts from assistant UI components. assistant-ui.com. That's another good
pass and each of those widgets represents one we should have a target and professional polish quality for."

assistant-ui lists about 128 elements at `https://www.assistant-ui.com/elements` (alphabetical, no categories;
read 2026-11-14). Its Tool UI docs sort them by job: inform, ask for a decision, adjust something reversible,
report work in flight. Leaving out the app shells (thread, composer, sidebar, settings), these are the ones drawn
inside a chat message. Each is a target: a brief, a reference card in the notation and as a document, rendered on
SSUI defaults, and polished until it stands beside theirs (alignment, spacing, color, every state).

Status: the decision group is built as reference cards in the notation on SSUI's looks
(`CodelesslySDK/design_systems/ssui/examples/targets`): approval card, option list, recommendation card,
permission grant, guardrail notice, elicitation form and question flow, each with its states; and six of the data
and comparison group: data table (sortable), comparison, spec sheet, score breakdown, cost meter, timeline; and six
of plans and progress: agent plan, todo list, task card, tool call, tool failure, job progress.
Nineteen of about 90. They were compared by eye with the descriptions, not side by side with assistant-ui's
renders. Writing the data group found four things the notation did not read, now fixed in it: a border or a text
color that follows data (`border:=`, `color:=`), an icon chosen by an expression, an expression written in a
line's `{…}` tail (read as a binding), and copies across a row that `grow` (an equal column each). Seven overlap the 17 card briefs already recorded (approval, question flow, data table,
comparison, code diff, image gallery, plan).

## The targets

| Group | Elements |
|---|---|
| Approval and decision | Approval card, Option list, Recommendation card, Elicitation form, Question flow, Permission grant, Guardrail notice |
| Data and comparison | Data table, Comparison, Spec sheet, Score breakdown, Chart, Number ticker, Cost meter, Context display, Heat graph, Activity graph, Timeline, Trace waterfall, Flow graph, Math |
| Links, sources, citations | Link preview, Inline citation, Sources, Document reference, Retrieval chunks, Web search, Confidence, Research report, Geo map, Map |
| Code and terminal | Terminal block, Code runner, Code diff, Reviewable diff, Syntax highlighter, Mermaid diagram, Diagram, File tree |
| Media | Image gallery, Image, Image generation, Media player, File, Web preview, Computer use |
| Plans, tasks, progress | Agent plan, Todo list, Task card, Subagent list, Job progress, Run activity, Tool call, Tool failure, Tool group, Tool fallback, Tool timeline, Handoff, Agent card, Agent status, Thinking indicator, Schedule, Stopped run, Error state, Quota banner, Connection state, Background runs |
| Other message parts | Artifact card, Markdown text, Streaming text, Reasoning, Memory, Speaker identity, Follow-up suggestions, Message actions, Read aloud, Feedback dialog, Quote, Prompt library, Orb, Voice conversation |

Each has a page at `/elements/<name-in-kebab-case>`.

## What the three read in detail are made of

- **Approval card.** A header (icon tile, title, subtitle), an optional description, an optional monospace
  command panel, optional label and value rows, and a footer that is either the request's buttons ("Allow once",
  "Always allow", "Deny") or a status receipt. States: request, running, done, denied. A destructive variant
  changes the icon tile and the primary action's tone.
- **Option list.** One row per option (a button; a checkbox when several may be chosen), a count and a confirm
  button for several, and a receipt of the chosen rows once answered. States: open, pending, receipt.
- **Data table.** Sortable column headers (ascending, descending, unsorted), rows, and in a narrow container a
  card per row with the primary column as its title. Cell kinds: text, number, currency, percent, delta, date,
  boolean, link, badge, list of chips.

Their rule worth keeping: a surface that was decided leaves a receipt; a reversible control (sort, filter) does
not.

## Order of work

1. The decision group (seven), since approval and question flow already exist as briefs: write each with its
   states (request, running, receipt) and compare side by side with theirs.
2. Data and comparison, which exercises the table, charts and number formats.
3. Plans and progress, which exercises streaming updates to one card.
4. The rest by how often a chat product needs them: sources and link preview, terminal and diff, media.

What each needs from the vocabulary is noted as it is built; a gap is fixed in the catalog or the design system,
not worked around in the card.
