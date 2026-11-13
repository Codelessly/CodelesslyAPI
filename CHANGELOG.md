## Unreleased

**Authoring fixes from the first direct-authoring experiment (cycle 1)**

- New node type `flex` (Flutter `Flex`, the widget `Row` and `Column` extend): the row/column props plus
  `direction` (`horizontal` | `vertical`, Flutter `Axis`, default `horizontal`). Bindable and patchable per
  breakpoint, so a row becomes a column without copying its children. `FlexProps.flex`, `FlexProps.direction`,
  `FlexProps.types`, `flexAxisOf(node)`. `row` and `column` are unchanged.
- New node key `media`: the node's own fields by screen size, as CSS media queries:
  `[{"maxWidth": 599, "patch": {"props": {"direction": "vertical"}}}]`. A rule's conditions are `minWidth` /
  `maxWidth` (px, inclusive, or a breakpoint name: from its min width / up to the next breakpoint) and
  `orientation`; all must hold. The patch is a JSON merge patch over the node (`props`, `layout`, `decoration`,
  `visible`, `opacity`); rules apply in order, the later winning (the CSS cascade). `MediaRule`,
  `MediaOrientation`, `Node.media`, `Node.atScreen`, `mediaPatchAt`. Validation type-checks every patched value as
  the node's own (`invalid_enum`, `unknown_prop`... with paths into the patch) and adds `invalid_media` (shape, no
  condition, bad width, min above max, a key that cannot vary) and `media_overridden` (a patched field the node
  also binds); `unknown_breakpoint` also covers a rule's breakpoint name.
- New layout fields from the CSS flex-item model, read by a row, column or flex: `order` (CSS `order`: layout and
  paint order, ascending, equal orders as listed) and `basis` (CSS `flex-basis`, in a wrapping row/column/flex:
  the size a child counts when lines are broken; a child that fills the main axis then grows by its `flex` share
  of its line). A filling child with a `basis` in a wrapping flex no longer gets `fit_not_allowed`; `basis` under
  a flex that does not wrap is reported as `layout_field_ignored`.
- `gridView.minCrossAxisExtent`: CSS grid `repeat(auto-fit, minmax(<min>, 1fr))`, as many equal columns as fit at
  least that wide, never more than there are items.
- An icon is written the same way everywhere: `InputIcon.icon` (a text field's `prefixIcon`, `suffixIcon`, `icon`)
  reads a Material icon name string as the `icon` node's `props.icon` does (before, the string was a `wrong_type`
  error), and an untyped `{"name": "search"}` decodes as that Material icon (before, it decoded to a glyph nothing
  can draw: a bug fix).
- Validation: `${false}`, `${12}`, `${'a'}` (a literal where `${...}` reads a name) is reported as `unknown_name`
  with the suggestion `${= false}`; a `spacer` with no main-axis size in a row/column is `zero_size` with how to
  write Flutter's `Spacer()` (`{"fill": 0}`); a wrapping `listView` no longer gets `fit_not_allowed` for its items'
  own sizes (it lays them out at their own sizes); new warning `vertical_wrap` for a wrapping list whose runs go top
  to bottom (the default `scrollDirection`).
- Guide: section 7 (Responsive design) rewritten the web way: intrinsic layout (basis, auto-fit grids, max-width),
  media rules, `${screen}` bindings as the escape hatch, a canvas per breakpoint last; one verified example page
  with its CSS equivalent.

**New: catalogs, feature libraries and plugins** (docs/design/05-plugins-and-layers.md; guide chapter 9)

- `Catalog` (`id`, `widgets`, `actions`, `dataSources`, `formulas`, `instructions`, `parts`; `+`, `widget`,
  `action`, `dataSource`, `formula`, `includes`, `upgrade`, `decodeAction`, `toJson({compact})`, `fromJson`,
  `Catalog.core`, `Catalog.current`, `Catalog.run`). `standardCatalog`, `coreCatalog`, `dataCatalog`,
  `authCatalog`, `commerceCatalog`, `mediaCatalog`, `engageCatalog`. `DataSourceSpec` (`listDataSource`,
  `cloudDataSource`, `apiDataSource`), `FormulaSpec`, `ActionCommon`, `ActionDecoder`, `DeclaredAction`,
  `JsonPropCodec`, `propTypeToJson`/`propTypeFromJson` and the other `*ToJson`/`*FromJson` declaration helpers.
- `ActionSpec` gains `decode`, `result`, `nested`, `requires`, `field`, `fieldSpec`.
- Decoders take `catalog:`: `LayoutDocument.fromJson`, `Node.fromJson`, `Reaction.fromJson`/`listFromJson`,
  `ActionDef.fromJson`/`listFromJson`, `ComponentDefinition.fromJson`, `PublishLayout.fromJson`,
  `PublishBundle.fromJson`, `buildManagedInstance`. `Node.catalog` and `LayoutDocument.catalog` (outside equality).
- Libraries: `package:codelessly_api/core.dart`, `data.dart`, `auth.dart`, `commerce.dart`, `media.dart`,
  `engage.dart`, `publish.dart`, `managed.dart`; `codelessly_api.dart` exports them all.
- Hosted plugins (`managed.dart`): `PluginPackage` (`problems`), `PluginWidget`, `PluginAction`, `PluginAsset`,
  `PluginVersion`, `PluginRef`, `pluginUpdateTarget`, `kPluginsCollection`, `PublishModel.plugins` /
  `withPlugins` (`PublishModelPlugins`).
- `Props`: a prop held raw (its spec unknown to the decoding catalog) decodes when read through its `PropDef`;
  props keep each value's `PropDef` so they encode without the spec.
- `tool/corpus_roundtrip.dart`: digests of every document's encoding, to compare before and after a change.

**JSON compatibility.** None changes: every document decodes and encodes byte for byte as before (with
`standardCatalog`), checked on 65 documents, 47,555 nodes and 20,573 reactions and actions of the reference apps
and the SDK's fixtures. A type a catalog doesn't declare round-trips unchanged. The list `source` object of the
proposal (§6.3) is not written: lists keep `query`, `pagination.source`, `apiId`.

**Breaking changes for Dart callers**

- **Decoding defaults to `Catalog.core`.** The core library cannot name the feature libraries, so a decoder
  given no catalog reads feature types (callApi, cloud*, auth, paywall, speak, playSound, preloadImages,
  captureScreenshot, print, downloadFile, submitForm, emitEvent; video, embeddedVideo, audioPlayer, webView) as
  `UnknownAction`s and raw props. Pass `catalog: standardCatalog` (or wrap a block in
  `Catalog.run(standardCatalog, ...)`). `ActionDef.types` lists `Catalog.current`'s types.
- `ActionDef` is an `abstract base class`, not sealed: a `switch` over it needs a default, or switches over a
  family (`CoreAction`, `DataAction`, `MediaAction`, `EngageAction`; `AuthAction`, `PaywallAction`). An action
  class outside the core overrides `fieldsJson`.
- `ComponentLink.managed` (field and constructor/`copyWith` parameter) is `managedJson` (raw JSON) in the core;
  `ComponentLink.managed` and `withManaged` are an extension in `managed.dart` (exported by the umbrella).
- `mediaSpecs` holds only `video`, `embeddedVideo`, `audioPlayer`, `webView`; `path`, `external`,
  `placeholder`, `singlePlaceholder` are `pathAndSlotSpecs` (in `coreWidgetSpecs`). `Widgets.all` is a getter
  (not `const`). `ActionSpecs.all` lists the core's types first, then each library's.
- `submitForm` is in the data library, `downloadFile` in media (not engage, data).
- Files moved: `lib/src/*` into `lib/src/core` and `lib/src/features/<x>`; deep `src/` imports change.

### Animation

**New: animation as data** (docs/design/02-animation.md; guide chapter 8)

- `animations` (`Behaviors.animations`, `NodeAnimation`): Flutter's `AnimationController` as data, with
  `AnimationTrack`s (`Tween`/`TweenSequence` via `Keyframe`/`Interval`/`CurveTween` on any binding `path`, of the
  node or another `node`, or on a `variable`; `TrackBlend` `replace`/`add`/`multiply`; `Wave`s), `AnimationRepeat`,
  `playKey`, `paused`, `phase`, `spring`, `progress`, `alignment`, `previewAt`, and `preset` + `params` short forms
  (`AnimationPresets`: `pulse`, `fade`, `scale`, `spin`, `bob`, `sway`, `flicker`, `shake`, `bounce`, `pop`,
  `wiggle`, `jelly`, `flash`, `keyframes`, `enter`; `NodeAnimation.expanded`). Declared as
  `BehaviorFields.animations`, `NodeAnimationFields`, `AnimationTrackFields`, `KeyframeFields`, `WaveFields`,
  `AnimationRepeatFields`.
- `AnimateAction` (`animate`, `AnimateCommand`, `AnimateFields`): `forward`, `reverse`, `toggle`, `repeat`,
  `stop`, `reset`, `animateTo`, `animateBack`, `set` on a node's animation or a number variable.
- `TriggerType.frame`: a `Ticker` (`${result.dt}`, `${result.elapsed}`, `${result.frame}`) guarded by `when`.
- `Spring` (`SpringFields`): Flutter's `SpringDescription`, physical or `withDurationAndBounce`; `toJsonOver`
  writes it sparse over an owner's default. `Trigger.intervalMsOf`.

**JSON compatibility.** `"schema": 2` is unchanged and every document written before loads and plays the same.
The decoders read the legacy keys and return the new model; the encoders write only the new shape:
`loops` and `effectAnimations` become `animations` (presets of their type; ids `loop<i>` and the effect's name),
their bindings (`loops[i].*`, `effectAnimations[i].*`) are rewritten to `animations.<id>.*`, `motion.pulseKey`
becomes the animation `pulse`; `playAnimation` and `animateVariable` read as `animate`; the `clock` trigger reads
as `timer` (`every` → `intervalMs`, `runWhen` → `when`); `FlipSpring`/`TransitionSpring` JSON, `motion`'s
`springStiffness`/`springDamping`, `draggable`'s `springStiffness`/`springDamping`, `drag.track`'s
`settleStiffness`/`settleDamping` and `GesturePhysics`' flat `stiffness`/`damping`/`mass`/`bounce`/`duration`
read as a `spring` (`settleSpring`) with their old defaults.

**Breaking changes for Dart callers**

- Removed: `LoopAnimation`, `LoopAnimationType`, `LoopPose`, `LoopAnimationFields`, `loopAnimationType`,
  `Behaviors.loops` (use `Behaviors.animations`); `EffectAnimation`, `EffectAnimationType`,
  `EffectAnimationFields`, `effectAnimationType`, `Behaviors.effectAnimations`, `BehaviorFields.loops`,
  `BehaviorFields.effectAnimations`; `PlayAnimationAction`, `PlayAnimationFields`, `AnimateVariableAction`,
  `AnimateVariableMode`, `AnimateVariableFields` (use `AnimateAction`; `ActionDef.types` lists `animate` and no
  longer the two legacy types, which still decode); `TriggerType.clock`, `Trigger.every`, `Trigger.runWhen`,
  `TriggerFields.every`, `TriggerFields.runWhen`; `FlipSpring`, `FlipSpringFields`, `flipSpringType`,
  `TransitionSpring`, `TransitionSpringFields`, `transitionSpringType` (use `Spring`, `springType`);
  `Motion.pulseKey`, `MotionFields.pulseKey`.
- Changed: `Trigger.intervalMs` is an `Expr<int>` (`TriggerFields.intervalMs` an `ExprCodec`), and
  `effectiveIntervalMs` is null for an expression; `GesturePhysics` takes `spring` (a `Spring`) instead of
  `stiffness`, `damping`, `mass`, `bounce`, `duration` and loses `usesBounce`; `Motion.springStiffness`/
  `springDamping` → `Motion.spring`; `DragSource.springStiffness`/`springDamping` → `DragSource.spring`;
  `DragTrack.settleStiffness`/`settleDamping` → `DragTrack.settleSpring`; `FlipCard.spring` and
  `RouteDismiss.spring` are `Spring`s; the matching `*Fields` entries follow (`GesturePhysicsFields.spring`,
  `MotionFields.spring`, `DragSourceFields.spring`, `DragTrackFields.settleSpring`).
- `Behaviors.legacyKeys` (`loops`, `effectAnimations`) and `Behaviors.migrateBind` are new; `Node.fromJson` keeps
  the legacy keys out of `extra`.

**New**

- `customPaint`, a behavior on any node (`Behaviors.customPaint`, `CustomPaint`): Flutter's `CustomPaint` as
  data. `painter` and `foregroundPainter` are lists of `DrawOp`s named as the `Canvas` calls they are
  (`PathOp`, `LineOp`, `RectOp`, `RRectOp`, `CircleOp`, `OvalOp`, `ArcOp`, `PointsOp`, `ParagraphOp`,
  `ImageOp`) with Flutter's parameter names and a `DrawPaint` (Flutter's `Paint`), plus `GroupOp` (save,
  transforms, clips, a layer, restore) and `RepeatOp` (`item`, `index`, `count`); `viewBox`, `fit`,
  `isComplex`, `willChange`. Values may be literals or inline expressions (`Expr`). Ops with `hit` are hit
  regions. Total decoding (unknown ops and keys round-trip), sparse encoding, binding paths by op id. Declared
  as `BehaviorFields.customPaint`, `CustomPaintFields`, `DrawPaintFields` and `DrawOpSpecs`; `ExprCodec` marks a
  field that takes an expression. New enums `PaintingStyle`, `PathFillType`, `PointMode`. Guide chapter 7.
  Nothing existing changes: `strokePath`, `box.path`, `subpathColors`, `gradientPerSubpath` and `plotChart` are
  as they were.

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
