# The audit's verdict

Written 2026-11-13, at the end of the audit that began with one question: after the features that made a
graphing calculator, a drag-and-drop kanban board, a piano keyboard, animation paths and games possible, do the
API and the SDK still follow their path, **Flutter SDK API → data model → SDK that renders it → feature layers
on top**, or had they become a pile of workarounds?

## 1. What the audit found

- **The data model had drifted from Flutter's names.** About a third of prop names matched Flutter's. The rest
  were renamed, merged or invented.
- **The SDK was not a mirror of Flutter's widgets and never needed to be.** It lays out and paints nodes with its
  own render objects on Flutter's rendering pipeline; real Flutter widgets appear only as islands for Material
  controls. That is a sound design, and it is why flat, editable data works.
- **44% of the fields added to unblock a reference app were special cases for that one app.**
- **Three general primitives were missing**, and their absence is what produced the special cases: custom
  painting, a frame clock with animation, and an extension point for what the catalog lacks.
- **Feature layers were tangled into the renderer.** Auth, data, commerce, media and messaging code could not be
  separated from drawing.

## 2. What was changed

| Area | Before | After |
|---|---|---|
| Painting | one-off props (`strokePath`, a box's `path`, per-subpath colours, a dial, a plot's extras) | `customPaint`: draw ops that mirror Flutter's `Canvas`, `Path` and `Paint`; a `path` node |
| Animation | per-feature timers and tweens | `animations` with one `Spring`, an `animate` action, a `frame` trigger |
| Motion | 50 fields, plus a separate node `scale` and `layout.rotation` | `motion` with 14 fields (Flutter's `Transform`), a `PathFollow`; scale and rotation folded in |
| Dragging | one `drag` with modes | `track`, `dismissible`, `pan`, `reorderHandle` |
| Shared elements | `hero` and a separate `flightKey` | one `hero` under Flutter's name, with `flies` and `flight` for what Flutter lacks |
| Responsive layout | fixed canvases per breakpoint | the web's model: `flex`, `media` rules, `order`, `basis` |
| Reuse | none | components by reference with props, slots and events |
| Text | padding ignored; an opt-in flag for natural line height | padding applies; the font's own line height; `defaultTextStyle` as in Flutter |
| Extension | unknown types failed | a `Catalog` of widget and action specs; app-registered recipes and action handlers |
| Layers | one library | `core` plus `data`, `auth`, `commerce`, `media`, `engage`, `publish`, `managed`; an architecture test keeps the render layer free of them, and a core-only build proves it |
| One-app fields | 171 | 135 after the first pass, then the paint and transform folds (declared fields 2,122 → 2,099) |
| Stored format | schema 2 with legacy readers | schema 3; schema 2 migrates in memory through named steps; no legacy readers |

## 3. What deliberately has no Flutter counterpart, and why it stays

Charts and gauges, formulas and bindings, variables and conditions, actions and triggers, `media` rules,
components, edit operations for streaming, and `hero`'s in-place flight. Each is general (not tied to one app),
and each is what makes an app expressible as data rather than as code. The owner's rule was that such additions
are fine; special cases are not.

The plot chart keeps its 23 Cartesian props. They are the general parts of a line chart, and the chart computes
extents and ticks from data while it paints, so moving them to a draw list would move the special case into
every document.

## 4. Verdict

The path holds. After the cleanup, a feature is either Flutter's concept under Flutter's name, a general
primitive with a stated reason for existing, or a feature layer that the renderer does not know about. The
"hacks" were symptoms of three missing primitives, and with those in place the special cases could be expressed
generally or removed.

Evidence that it works as an API for building, not only on paper: independent agents given only the reference
built nine multi-page sites that validate clean and render at three sizes in 28 to 42 minutes each, and six of
the nine reported nothing the API could not express.

## 5. What is not finished

- **Material defaults.** Unstyled controls still take Material's look. This is the largest remaining deviation
  from "the document decides how it looks" and is the first item of iteration 2.
- **Gaps the nine builds named:** a theme mode, grid item span, scroll control, pointer position on hover, a clip
  mask, focus management, URL state. Each needs a design pass against Flutter's API.
- **Name conformance was not re-measured** after the cleanup; the one-third figure is from the start of the audit.
- **Inert state targets.** 330 state patches in the corpus target `self` or `@name`, which match no node; their
  press and hover scales never ran.
- **A stroke's draw-on animation** (`drawMs`) has no exact general form and is no longer drawn. Nothing in the
  corpus uses it.
- **The editor** still writes schema 2 and reads fields that have moved; its port follows the milestones.
- **Fidelity to the web builds** is roughly 30 to 45 percent by reviewers' eyes. The causes found are defaults,
  imagery, fonts, layout guidance and tooling rather than the model, but that claim is only tested by the next
  round.
