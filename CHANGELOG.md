## Unreleased

**Breaking changes**

*Removed* (fields the SDK never read: setting them changed nothing at runtime)

- `Trigger.lookaheadMs` (`TriggerFields.lookaheadMs`, the `lookaheadMs` key of a `clock` trigger): no runtime
  read it. JSON that carries the key still decodes; the key is dropped on re-encode.
- `CloudDataAction.deleteSubcollections` (`CloudDataFields.deleteSubcollections`): no runtime read it. JSON that carries the key still decodes; the key is dropped on re-encode, and
  `ActionSpecs.unknownKeys` now reports it.

## 24.0.0

**Breaking changes**

- The built-in Mailchimp service of `SubmitFormAction` is removed: `FormService.mailchimp`, and the
  `apiKey`, `dataCenter`, `listId`, `emailField`, `firstNameField` and `lastNameField` fields (of the
  action and of `SubmitFormFields`). A layout must not carry a provider's API key, and the packages don't call
  third-party services.
- `SubmitFormAction()` and `{"type": "submitForm"}` now default to `FormService.local`.

**New**

- `StyleSheet.naturalLineHeight` (published as `ThemeTokens.naturalLineHeight`): text without a line height
  takes its font's own, as Flutter's does, rather than the SDK's 1.33.
- `RetryFailedAction` (`retryFailed`): in an `actionError` reaction, runs the failed action chain again.
- Paywall test store data: `ProductSlot.test` (`ProductTestData`: `price`, `rawPrice`, `currency`,
  `currencySymbol`, `period` — `week`, `month`, `year` or '' for lifetime —, `trialDays`, `entitlementId` and
  `outcome`, a `TestPurchaseOutcome`: `purchased` (default), `declined` or `cancelled`) and `PaywallConfig.testStore`
  (`"testStore": true` on the published `paywall`). The SDK's test store runs a paywall's whole flow from them on the
  web (preview and demo sites) without a store or a payment; it never grants real entitlements. Both are omitted
  when unset, so existing JSON is unchanged; real stores ignore them.
- Backdrop screens: `CanvasProps.backdrop` (`"props": {"backdrop": true}` on a canvas) marks a screen drawn once
  beneath every screen, outside navigation (a sky that stays still while screens move over it). `PublishModel`
  lists them in `backdropLayoutIds` (omitted when empty); `backdrops` is the published, enabled ones. A canvas both
  `overlay` and `backdrop` is an overlay.
- `LoadCloudDataAction.scope` (`CloudDataScope.screen`, the default, or `app`; `LoadCloudDataFields.scope`):
  `"scope": "app"` asks the runtime to keep one live subscription for the whole app, shared by every screen that
  runs the same load, writing an app variable. Omitted when `screen`, so existing JSON is unchanged; older
  runtimes ignore it and load per screen.
- Dark colors: `NamedColorStyle.dark` (an optional second paint, `"dark": {...}`, omitted when absent) and
  `darkColor`; `ThemeTokens.dark` (the colors that differ in dark mode), `ThemeTokens.colors` and
  `ThemeTokens.textStyles` (every named style by `ThemeTokens.themeKey`), `forBrightness(dark:)` and `hasDark`.
  `StyleSheet.theme` fills them. Old style sheets and themes decode and re-encode unchanged.
- Data rules for server-written data: `DataRule.ownerRead` (each user reads their own documents; only the project's
  editors, the server and the collection's role write) and `DataRule.audience` (a user reads a document whose
  `audience` list names `*`, `signedIn`, `role:{role}` or `user:{uid}`, checked at read time). `DataRules.ownerFields`
  lists the fields an `ownerRead` owner may change (a `read` flag); `DataRules.expiry` names a collection's expiry
  field, past which app users can't read a document. Helpers: `DataRules.audienceOf`, `roleAudience`,
  `userAudience`, `neverExpires`, `expiryFieldFor`, `ownerFieldsFor`; traits `readsAudience`, `writtenByRole`.
  Older JSON decodes and re-encodes unchanged; an older reader drops the new rules (reads them as `app`), and the
  database rules then refuse its reads and writes instead of opening the collection.
- Automations: `Automation` (`AutomationTrigger` `appStart`, `sessionStart`, `resume`, `event`, `interval`,
  `screenShown`; a `when` formula; `maxRuns`, `maxPerSession`, `everyDays`; `delayMs`, `priority`; `actions`),
  `AutomationFields`, and `PublishModel.automations` / `withAutomations` (the model's `automations`, kept in
  `extra`: a model without them encodes as before).
- `EmitEventAction` (`emitEvent`: `event`, `props`): fires an app event on the runtime's event bus.
- `CaptureScreenshotAction` (`captureScreenshot`: `target` `layout` / `node` / `app`, `node`, `pixelRatio`):
  `${result.image}` is a PNG `data:` URL.
- `ModalPresentation.banner`: a modal along the top (or bottom) edge with no barrier. Runtimes that don't know
  it decode it as `dialog`.
- `CallFunctionAction.optional`: a function the app didn't register gives `null` instead of failing the chain.
- `CloudFilesAction.source` and `fileName`: upload a value (a `data:` URL, `{"data", "name"}`, or a list)
  instead of asking the user to pick files.
- `ListViewProps.stickToEnd`: a list that opens at its end, keeps its place when items are put before the ones
  on screen, and follows new items at the end only while scrolled there (a chat, a log).
- `FormService.unsupported`: older JSON with `service: mailchimp`, with no `service` and the removed fields,
  or with an unknown service decodes as this (it never throws). The removed fields are read past and never written
  back out. `SubmitFormFields.service` offers only `local`.

- Live cloud data bindings (all optional keys; older layouts decode and re-encode unchanged):
  - `LoadCloudDataAction.limit` (a number or expression; `0`: all), `aggregate` (`CloudLoadAggregate`: count, sum,
    average) with `aggregateField`, `refreshSeconds`, `reactive`; `kDefaultCloudLoadLimit` (500), the limit a
    runtime applies when neither the action nor its query gives one.
  - `CloudQueryDef.joins`: `CloudJoin {collection, as, id | localField + foreignField, many}`.
  - `ReloadCloudDataAction` (`reloadCloudData { variable }`), with `ReloadCloudDataFields` and its `ActionSpec`.
  - `CloudBatchAction.forEach` (steps per item of a list, one commit) and `kMaxCloudBatchWrites` (500).
  - `Trigger.onceKey` (once per key per app session) and `Trigger.visibleMs` (enterViewport after staying in view).
  - `ListViewProps.pullToRefresh`: pull to refresh without pagination.
  - Their editor fields: `LoadCloudDataFields`, `CloudBatchFields.forEach`, `TriggerFields.visibleMs`/`onceKey`.

**Migration**

- Stored layouts need no change to load. An old newsletter submission no longer sends anything: a runtime fails
  it as `unsupported_service`. To keep collecting sign-ups, use a `callApi` action to your own endpoint, which
  holds the provider's key server-side. See [docs/submit_form.md](docs/submit_form.md).
- Code that read the removed fields or matched `FormService.mailchimp` should drop them, and handle
  `FormService.unsupported` where it switches over `FormService`.

## 23.0.0

**New**

- Models for managed paywall placements, product slots, offers, and purchase outcomes.
- Action and widget data for form submission, conditional reveal, generated files, print, image lifecycle, media playback controls and status, and sound waveforms.
- Model support for charts and gauges, masonry layouts, stroke progress, and symbol fallback.
- Documented video readiness and action error trigger values.

## 22.0.0

**Breaking changes**

- `Behaviours` is now `Behaviors`.
- `BehaviourFields` is now `BehaviorFields`.
- `Node.behaviours` is now `Node.behaviors`, and the `behaviours:` parameter of `Node()` and `Node.copyWith` is now
  `behaviors:`.

The JSON format is unchanged: behaviors are stored flat in the node's JSON under the same keys.

## 21.0.1

- Documentation: a cleaner README.

## 21.0.0

**Breaking changes**

- Requires Dart 3.12 or newer.
- Requires `collection` 1.19.1 or newer and `meta` 1.19.0 or newer. If your app pins older versions of either,
  raise them alongside this package.

**New**

- A guide to the model, with runnable samples in `example/`:
  [docs/guide](https://github.com/Codelessly/CodelesslyAPI/tree/master/docs/guide).

The model classes and the JSON format are unchanged from 20.0.1.

## 20.0.1

**New**

- `StyleSheet` holds a project's named text and color styles (`NamedTextStyle`, `NamedColorStyle`).
  `StyleSheet.theme` reads the `ThemeTokens` from them by name.

## 20.0.0

**Breaking changes**

- A new data model and JSON format (`"schema": 2`). Nodes use Flutter's own parameter names, types and defaults, and
  a layout is a `LayoutDocument`: its canvases and every node in one flat map.
- Decoding is total: `fromJson` never throws, unknown keys and node types round-trip, and a bad value falls back to
  its default. Encoding is sparse: values equal to Flutter's defaults are not written.
