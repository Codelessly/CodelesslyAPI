## Unreleased

**`Motion` is a transform; its timing, entrance, loop, spin and shimmer are animations and transitions**
(docs/design/03-motion.md; the rest of docs/design/02-animation.md's presets; guide chapter 8)

- `Motion` has 14 fields (was 50): `translateX/Y`, `shiftX/Y`, `scale`, `scaleX/Y`, `rotate`, `rotateX/Y`,
  `perspective`, `alignment`, `backfaceHidden`, `path`. `PathFollow` (`path`, `viewBox`, `progress`, `orient`;
  deprecated `pacing`, `focus`), `PathOrient` (`none`, `tangent`, `upright`, `uprightFlip`), `PathPacing`
  (deprecated). `Motion.properties`, `valueOf`, `withValue`, `restOf`, `lerp`, `hasPath`, `hasTransform`.
- `Pose` (a `Motion` with `opacity`, `blur`; flat JSON): `TransitionSide.motion`, `PageViewProps.pageMotion`,
  `pageMotionBefore`.
- `Transition` (`property`, `duration`, `delay`, `curve`, `spring`, `keyframes`, `interpolation`, deprecated
  `arc`; `matches`, `of`, `keyframesOf`, `listFromJson`); `Behaviors.transitions` is a `List<Transition>`.
- `PathFollow` is the one shared with `track.path` (it gained `uprightFlip`, deprecated `pacing`/`focus`; its
  `viewBox` is a list, empty for none).
- `Shimmer` (`color`, `strength`, `width`, `angle`, `position`), behavior key `shimmer`.
- `NodeAnimation.ramp`, `visibleFraction`; `AnimationTrack.interpolation` (`KeyframeInterpolation`
  `linear`/`monotoneCubic`, `monotoneAt`, `monotoneCubic`); a wave on a replacing track is a share of
  `to − from` (a swing); track numbers carry on past their ends on an overshooting curve.
- Presets `loop` (`from`, `frames`, `mode: swing`, `curve`, `rotateCurve`, `fadeShare`), `shimmer`; `enter` takes
  `frames`, `curve`, `rotateCurve`, `fadeShare`; `spin` takes `perSecond` (a turn a run, its duration
  `1000 / |perSecond|`). `AnimationPreset.durationOf`. `AnimationPresets.fromMotion`, `legacyLoopMode`,
  `legacyMotionPath`, `legacyMotionProperties`, `legacyKeyframeProperties`, `motionBlurId`, `legacyMotionSpring`.
- `setVariable` with `animateMs` (set/add/subtract of a variable) decodes as `AnimateAction` (`animateTo`).
- `Behaviors.formulaOf`. `FlipCard.durationOf` takes a `Transition?`.

**JSON compatibility.** `"schema": 2` stays. Every legacy motion key reads (test/motion_migration_test.dart):
the pose's (`originX/Y` → `alignment`, the flat `path*` keys → `path`), `opacity` → the node's opacity
(multiplied), `blur` → a `layerBlur` effect `motionBlur`, `duration`/`delay`/`curve`/`spring*` → a `motion`
transition (plus `opacity`/blur ones, `rotateCurve` → `motion.rotate`), `enter`/`enterFrom`/`replayKey`/
`enterHeld`/`revealOnScroll`/`revealFraction` → animation `enter`, `loop`/`repeat`/`phase`/`paused` → animation
`loop`, `spin`/`spinRamp` → animation `spin`, `shimmer` → `shimmer` + animation `shimmer`, `keyframes` → their
`frames`; bound keys are rewritten. A state style's `motion.opacity` is its `opacity`. `transitions` also reads
the legacy `{style, opacity, size}` object and a property map. Encoders write only the new shape: a document with
legacy motion keys encodes differently (four SDK fixtures; their corpus digests changed). Not read any more:
`pathWrap` on an open path (a closed path wraps), bound `rotateCurve`/`fadeShare`/`arc`/`spring*`/
`revealOnScroll`/`revealFraction`.

**Breaking changes for Dart callers**

- Removed from `Motion`: `opacity`, `blur`, `originX`, `originY`, `duration`, `delay`, `curve`, `rotateCurve`,
  `fadeShare`, `spring`, `defaultSpring`, `spin`, `spinRamp`, `loop`, `repeat`, `enter`, `enterFrom`,
  `replayKey`, `pathProgress`, `orientToPath`, `keyframes`, `revealOnScroll`, `enterHeld`, `revealFraction`,
  `orientUpright`, `uprightMirror`, `arc`, `paused`, `phase`, `pathPacing`, `pathFocusX/Y`, `pathWrap`,
  `pathViewBox`, `shimmer`, `named`, `atRest`, `entranceStart`, `loopStart`, `hasEntrance`, `keyframed`,
  `wrapProgress` (→ `PathFollow.wrap`), `headsLeft` (→ `PathFollow.headsLeft`); `Motion.path` is a `PathFollow?`.
- Removed: `MotionLoop`, `MotionPathPacing` (→ `PathPacing`), `MotionShimmer` (→ `Shimmer`), `MotionKeyframe`,
  `Transitions` (→ `List<Transition>`), `TransitionsFields`, `MotionShimmerFields`, `MotionKeyframeFields`,
  `motionKeyframeType`, `motionShimmerType`, `transitionsType`. `MotionFields` keeps only the pose.
- `TransitionSide.motion`, `PageViewProps.pageMotion`/`pageMotionBefore` are `Pose`s (`.motion.rotateY`).
- `Transition` gained `property` (first, default '') and the timing fields; `duration` is optional.
- `AnimationTrack.lerpValue` extrapolates numbers outside 0–1.

**New: drag and track** (docs/design/04-drag-and-track.md; guide chapter 10)

- The `drag` key splits into four behaviors: `track` (`Track`, Flutter's `Slider` along a line, arc or path),
  `dismissible` (`DismissibleBehavior`, Flutter's `Dismissible`), `pan` (`Pan`, pointer follow with spring
  back or stay) and `reorderHandle` (a bool, `ReorderableDragStartListener`). `BehaviorFields.track`,
  `.dismissible`, `.pan`, `.reorderHandle`; `TrackFields`, `DismissibleFields`, `PanFields`,
  `PathFollowFields`; `trackType`, `dismissibleType`, `panType`, `pathFollowType`.
- `PathFollow` and `PathOrient` (`lib/src/core/path_follow.dart`, doc 03's shared shape): `Track.path`.
- `Track`: `enabled`, `clamp`, `sweepAngle`, `allowedInteraction` (`TrackInteraction`), `physics` (a
  `GesturePhysics` coast), `path: PathFollow?`; getters `endAngle`, `jumpOnTap`, `momentum`, `wheel`,
  `frictionRate`; `Track.readsOnly`, `Track.fromLegacyDrag`.
- `DismissibleBehavior.defaultThreshold`, `thresholdFor`, `effectiveReturnDuration`/`Curve`, `fromLegacyDrag`;
  `PanRelease`; `Pan.hasBounds`, `fromLegacyDrag`.
- `DragSource`: `childWhenDragging`, `feedback`, `dragAnchor` (`DragAnchor { child, center }`),
  `returnSpring: Spring?` (`false` in JSON: none).
- Actions `controlTrack` (`ControlTrackAction`, `TrackCommand { step, animateTo }`), `controlDismissible`
  (`ControlDismissibleAction`, `DismissCommand { dismiss, returnFrom, reset, shake }`), `controlTransform`
  (`ControlTransformAction`, `TransformCommand { reset, scaleBy, animateTo }`), with `ControlTrackFields`,
  `ControlDismissibleFields`, `ControlTransformFields`.
- Expression scopes `dismiss` and `pan` (`runtimeScopes`).

**JSON compatibility.** Every existing document reads and behaves as before: `drag` reads as `track`
(`drag.track`, switched by `drag.enabled`), `reorderHandle` (`reorder: true`), `dismissible` (`release:
dismiss`, with its old defaults — 0.35 thresholds, 800 px/s, a 320 ms easeIn fly-off, a 450 ms spring-curve
return — written out) or `pan`; `zoomable: true` as `transformGesture: {target: content, pan: whenZoomed}`;
`controlDrag` as the typed action its command names; a track's `endless`, `endAngle`, `jumpOnTap`, `wheel`,
`keyboard`, `momentum`/`friction`, `gain`, `write: false`, its path string, `viewBoxWidth`/`Height`,
`orientToPath`/`orientUpright`; a draggable's `whileDragging`, `feedbackNodeId`, `feedbackAnchor`, `spring`,
`springStiffness`/`Damping`, `physics`. Legacy binding paths (`drag.track.*`, `drag.enabled`, `drag.restX`...)
are rewritten when a node decodes. Only the new shape is written, so a document re-saved changes its JSON (not
its behaviour); the catalog corpus digests of documents with a legacy `drag` change accordingly.

**Breaking changes for Dart callers**

- Removed: `DragMotion`, `DragMotionFields`, `dragMotionFields`, `dragMotionType`, `Behaviors.drag`,
  `Behaviors.zoomable` (and their `copyWith` parameters), `BehaviorFields.drag`, `BehaviorFields.zoomable`,
  `ControlDragAction`, `ControlDragFields`, `DragCommand`, `FeedbackAnchor`, `DragSource.whileDragging`,
  `.feedbackNodeId`, `.feedbackAnchor`, `.spring`, `.physics` (and the `bool returnSpring`).
- Renamed: `DragTrack` → `Track`, `DragTrackFields` → `TrackFields`, `dragTrackFields` → `trackFields`,
  `dragTrackType` → `trackType`, `DragTrackShape`/`Input`/`HitArea`/`Units` → `TrackShape`/`TrackInput`/
  `TrackHitArea`/`TrackUnits`.
- `Track` lost `endless` (`clamp`), `endAngle` (now a getter over `sweepAngle`), `jumpOnTap`, `wheel`,
  `keyboard`, `momentum`, `friction` (getters or `physics`), `write`, `viewBoxWidth`, `viewBoxHeight`,
  `orientToPath`, `orientUpright` (`path`); `path` is a `PathFollow?`, not a `String?`.
- `Behaviors.effectiveTransformGesture` is `transformGesture`.

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
