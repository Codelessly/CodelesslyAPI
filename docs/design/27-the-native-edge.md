# 27 · The native edge: what a page described as data asks of the app that hosts it

A page written in the notation is drawn by the SDK's own render objects. Everything else an app does stays
Flutter's: the platform, its permissions and lifecycle, and the package ecosystem (PubNub, Firebase, AppsFlyer,
`record`, `google_sign_in`, `permission_handler`, `webview_flutter`). The owner's words: "The platform and
ecosystem is exactly what we use Flutter for, we're not replacing that part!" What is not yet proven is the seam
between the two. This note designs that seam. It also records the first slice of it, which is built: the device's
edges (safe area, keyboard, text scale) readable in formulas and simulated by the render tool.

## 1. What the NOCD rebuild could not reach

The 30-part recreation of NOCD in the notation stood in for every native service with variables. Its register
(`nocd/REGISTER.md`, "The base lacks it") has these entries on the native side:

| Register entry | What the page needed | Kind (§2) |
|---|---|---|
| Provide native insets and text scaling (5 parts) | Status bar and home-indicator insets, keyboard height, text scale | value |
| Independent alert guards and system insets | A sheet's bottom padding from the keyboard and safe area | value |
| Native permissions and biometrics | Ask for the microphone or notifications; run Face ID for the passcode | request |
| Native microphone capture and recording formats | Permission, then start and stop a take, with a level meter and a file | request + stream |
| Native gallery, hosted privacy content and crop output | Pick an image, crop it to a circle, get the bytes | request |
| Native auth and host adapters | Google and Apple sign-in with cancel and failure outcomes | request |
| Handoff and external picker boundary | Share an image with a caption through the system sheet | request |
| Mock request action cannot prove native URL, share or network | Per-call outcomes a test can choose | request (mock) |
| Native update gate and system services | The store's update check, then a gate that blocks Back | value + request |
| Mockable calendar and feature flags | Add to calendar; a release flag picks the booking path | request + value |
| Time zones and injectable clock | Slot labels in an IANA zone; a fixed clock for tests | value |
| Missing raw SSE frame handling | Robin's answer arriving in pieces, with tool and error stages | stream |
| Native services and system lifecycle | Background and foreground, notification ownership, resume | value + stream |
| Native Back and exit | The system Back, predictive Back, exit | stream |
| Replay host return events | A deep link from an email returning to the app | stream |
| Native media and web lifecycles | A video player and a web view the host draws | region |

The repair ledgers mark 99 requirements "out of reach of headless render". Of the 71 whose reason the ledgers spell
out, about 16 are insets, keyboard or text scale; 11 are chat-thread lines that name lifecycle, deep links,
keyboard, notification permission and text scale together; about 16 are host handoffs (OAuth, calendar, permission
dialogs, web views, release flags); 9 are lifecycle, resume and Back; 5 are native keyboard configuration and
autofill (the keyboard's own UI, which no harness draws); 5 are haptics, screen readers and platform physics; 3 are
analytics; 7 are not native at all. Every row in the first four groups is a value, a request or a stream that a
test cannot drive today.

## 2. The model

Four kinds of thing cross the boundary. Each kind gets one generic form in the notation and one registration in
Dart. Grammar is never per capability: a capability is a **named contract** (its values, requests, events and
states), implemented by an **adapter** the host registers.

| Kind | Direction | Examples | The writer writes | The host writes |
|---|---|---|---|---|
| Value | host → page, changes | insets, keyboard, text scale, brightness, locale, lifecycle, connectivity, a permission's state, the signed-in user, feature flags, the clock and zone | a formula: `{host.microphone.permission}`, `{screen.keyboard}` | a `ValueListenable` on its adapter |
| Request | page → host → page, later | ask a permission, pick or capture media, record, sign in, share, a native picker, a purchase, a biometric check | an action with a result and an error branch: `callFunction name=microphone.start … onError={…}` | `request(name, args)` returning a future |
| Stream | host → page, pushed | a channel's messages, a push, a level meter, an SSE answer in pieces, a deep link, Back | an event on the page, `on host(event=chat.signal)={…}`, or a value that grows (`host.robin.answer`) | `listen(event, params)` returning a stream |
| Region | host draws inside the page | a camera preview, a map, a web view, a video | `External builderId=camera.preview params={…}` | a widget builder on its adapter |

### 2.1 Values

What a writer writes is a formula. Two roots hold them:

- `screen`, for what every device has and every page may read: size, breakpoint, orientation, brightness, and now
  `screen.insets.{top,right,bottom,left}`, `screen.keyboard` and `screen.textScale` (§9). It needs no
  declaration, and an agent can always rely on it.
- `host.<capability>.<value>`, for what a host offers: `host.microphone.permission`, `host.app.lifecycle`,
  `host.net.online`, `host.flags.newBooking`, `host.clock.zone`, `host.chat.connection`. One root name, any
  capability under it. The page reads only what a declaration lists.

```notation
Text "Turn on the microphone in Settings" visible={host.microphone.permission == 'permanentlyDenied'}
Button "Book" onTap={host.flags.newBooking ? navigate to=bookingV2 : navigate to=booking}
Text "{formatDate(slot.start, 'h:mm a', host.clock.zone)}"
on valueChanged(variable=host.app.lifecycle)={if host.app.lifecycle == 'resumed' then reload}
```

**Exists today.** `screen` (size, breakpoint, orientation, brightness, modal, sheet, url, backdrop), `theme`,
`storage`, `route`, `data` (anything the host puts there with `codelessly.setData`, which is how the guide tells
an app to mirror the signed-in user), `auth`, `device.hover`. The clock is injectable: `FormulaClock`, with the
render tool's `--now` and `--clock`. **Missing.** The `host` root and its declarations. Lifecycle, connectivity,
locale, zone and permission states have no standard names. `data.*` is untyped, so nothing checks a page's reads
against what the host provides.

### 2.2 Requests

What a writer writes is an action whose `${result}` is typed by the declaration, with an `onError` branch. The
action is the existing `callFunction`, whose name is `<capability>.<request>`:

```notation
Button "Record" onTap={callFunction name=microphone.requestPermission;
  if result.status == 'granted' then callFunction name=microphone.start params={"format": "aac"} onError={toast "{result.error.message}"}
  else open micSettingsSheet}
```

**Exists today.** `callFunction` with params evaluated, an awaited result, `optional`, and the chain stopping when
the function throws. `onActionError` on the canvas catches a failed chain. `callApi` and `runScript` already take
their own `onError`. The built-in requests (`pickFile`, `share`, `auth`, `paywall`, `openLink`, `haptic`) are each
a separate action type over a `Services` interface. **Missing.** An `onError` field on `callFunction`, so a denied
or cancelled request is a branch and not an error. Typed results and errors (a declaration says what
`result.status` can be). A timeout. A way for a test to choose the outcome.

### 2.3 Streams

What a writer writes is an event on the page: one trigger type, `host`, whose `event` field names
`<capability>.<event>`, as `componentEvent` names a component's event today. Its `params` say what to listen to. The
SDK subscribes when the screen shows and cancels when the screen leaves, so a page never opens or closes a
subscription by hand:

```notation
on host(event=chat.signal, params={"channel": route.channelId})={callFunction name=chat.fetchNewer params={"after": last(messages).id}}
on host(event=links.opened)={navigate to={result.path}}
```

When what the page wants is the latest value rather than each message (a level meter, an answer arriving in
pieces), the stream is a value instead, and the adapter keeps it up to date: `host.microphone.level` (0 to 1, about
20 times a second) and `host.robin.answer` (`{text, stage, tools, error}`, its `text` growing). A list that grows
is a value too. The SDK's lists already key and animate inserts.

**Exists today.** `backPressed` with `blockBack` (the system Back). `screen.url` and the navigation handler (deep
links at launch). Cloud data subscriptions (live lists through `Services.cloud`). `componentEvent` and `onEvent`,
the pattern this copies. **Missing.** The `host` trigger, its subscription lifetime, and a replay step that emits an
event.

### 2.4 Regions

What a writer writes is `External`, the node that reserves a box for an app-built widget:

```notation
External#preview builderId=camera.preview w=fill h=480 params={"lens": lens}
```

**Exists today.** `External` with `builderId`, and `ExternalComponents` in the app mapping ids to builders. The
built-in `Video`, `WebView`, `AudioPlayer` and `EmbeddedVideo` are native regions with their own words.
**Missing.** `params`: the builder gets a `BuildContext` only, and the guide says "The node's props are not passed to
the builder". A capability that supplies a region should declare it, so that the builder id is checked and a mock
draws a labelled placeholder of the region's size in a render.

## 3. Capabilities as contracts

A capability declaration is data: JSON shipped with its adapter and exported to the agent with the notation
reference. It names the capability and lists its values (each typed, with a default), its requests (typed
arguments, a result, the errors it can give), its events (a payload), its regions, and its **states**. A state is a
value that tells the page whether the capability can be used at all, with fixed words: `unavailable` (no hardware,
or not on this platform), `unknown` (not asked yet), `denied` (refused, can be asked again), `permanentlyDenied`
(only Settings changes it), `restricted` (parental or MDM), `granted`, `limited` (some photos only).

```json
{
  "capability": "microphone",
  "version": "1.0.0",
  "platforms": ["ios", "android", "web"],
  "sensitive": true,
  "state": "permission",
  "values": {
    "permission": {"type": "choice", "of": ["unavailable", "unknown", "denied", "permanentlyDenied", "restricted", "granted"], "default": "unknown"},
    "recording": {"type": "boolean", "default": false},
    "level": {"type": "decimal", "min": 0, "max": 1, "default": 0, "updates": "stream"},
    "elapsedMs": {"type": "integer", "default": 0, "updates": "stream"}
  },
  "requests": {
    "requestPermission": {"result": {"status": "permission"}, "userGesture": true},
    "start": {
      "args": {"format": {"type": "choice", "of": ["aac", "wav", "amrWb", "opus"], "default": "aac"}, "sampleRate": {"type": "integer", "default": 44100}},
      "result": {},
      "errors": ["denied", "busy", "unavailable"],
      "needs": {"permission": "granted"}
    },
    "stop": {"result": {"file": "file", "durationMs": "integer"}, "errors": ["notRecording"]},
    "cancel": {"result": {}}
  },
  "events": {"interrupted": {"payload": {"reason": {"type": "choice", "of": ["call", "otherApp", "background"]}}}},
  "outlives": "screen"
}
```

`file` is a typed value the SDK already knows from `pickFile` (`{name, size, type, path or data}`). `needs` says
which state a request requires. `userGesture` says it must run from a tap, never from `load`. `outlives` says
whether the adapter keeps running when the screen that started it leaves (§5).

The declaration makes three things possible, none of which exists today:

1. **Discovery.** The host's declarations are listed in what the agent is given: one line per value, request and
   event, with its result. An agent writing a page knows that `microphone.stop` returns a file and a duration, and
   that `permission` can be `permanentlyDenied`. Nothing else in its prompt changes.
2. **Checking.** The expander checks a page against the host's declarations, as it checks words against the
   catalog. These are issues: a `callFunction name=x.y` or `host(event=x.y)` that no declaration offers; a read of
   `host.x.v` that is not declared; a comparison with a choice that is not one of its words
   (`permission == 'blocked'`); an argument of the wrong type. These are warnings: a request that declares
   `errors` with no `onError`; a request whose `needs` is not checked before it, or whose denied state the page
   never shows (no formula reads the state); a `userGesture` request in `load`.
3. **Mocking.** Any declaration can be served by a generic mock. The mock holds the declared defaults and answers
   each request with its declared result shape, or with an outcome a test names. The render tool sets its values
   and emits its events (§6), so the states the rebuild faked with page variables become states of the host.

### 3.1 The four cases in full

**LoopTape: microphone permission, a recording with a level meter, a file.** The declaration is the one above.
NOCD today: `Permission.microphone.request()`, then `AudioRecorder().start(RecordConfig(encoder:, sampleRate:,
numChannels: 1), path:)` into the temp directory, then `stop()`. A failure shows a dialog about another app using
the microphone. `PasscodeManager.disableOnce()` keeps the passcode lock from firing when the system prompt returns
the app to the foreground.

The page:

```notation
state take:map=null
Column gap=16 pad=24
  Text.title "LoopTape"
  Column visible={host.microphone.permission == 'permanentlyDenied'} gap=8
    Text "Microphone access is off. Turn it on in Settings to record."
    Button.outline "Open Settings" onTap={callFunction name=app.openSettings}
  Progress value={host.microphone.level} visible={host.microphone.recording}
  Text "{formatDuration(host.microphone.elapsedMs)}" visible={host.microphone.recording}
  Button "{host.microphone.recording ? 'Stop' : 'Record'}" disabled={host.microphone.permission == 'unavailable'}
    onTap={host.microphone.recording
      ? callFunction name=microphone.stop onError={toast "The recording could not be saved."}; take=result
      : callFunction name=microphone.requestPermission;
        if result.status == 'granted' then callFunction name=microphone.start params={"format": "aac"} onError={toast "Unable to record audio. Another app may be using the microphone."}}
  AudioPlayer src={take.file.path} visible={take != null}
on host(event=microphone.interrupted)={toast "Recording stopped: {result.reason}"}
```

The Dart adapter, written once against the `record` and `permission_handler` packages:

```dart
class MicrophoneCapability extends HostCapability {
  MicrophoneCapability({this.onSystemPrompt}) : super(CapabilityDeclaration.asset('microphone.json'));

  /// NOCD: PasscodeManager.instance.disableOnce, so the prompt's return doesn't lock the app.
  final VoidCallback? onSystemPrompt;
  final _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _meter;
  Timer? _clock;

  @override
  Future<void> start() async => set('permission', _state(await Permission.microphone.status));

  // Called by the SDK when the app resumes: Settings may have changed it.
  @override
  Future<void> resumed() => start();

  @override
  Future<Object?> request(String name, Map<String, Object?> args, CapabilityCall call) async {
    switch (name) {
      case 'requestPermission':
        onSystemPrompt?.call();
        final status = _state(await Permission.microphone.request());
        set('permission', status);
        return {'status': status};
      case 'start':
        if (values['permission'] != 'granted') throw CapabilityError('denied');
        final dir = await getTemporaryDirectory();
        try {
          await _recorder.start(
            RecordConfig(encoder: _encoder(args['format']), sampleRate: args['sampleRate'] as int, numChannels: 1),
            path: '${dir.path}/looptape_${const Uuid().v4()}.m4a',
          );
        } on Exception catch (e) {
          throw CapabilityError('busy', '$e');
        }
        set('recording', true);
        final started = DateTime.now();
        _meter = _recorder.onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen((a) => set('level', ((a.current + 60) / 60).clamp(0.0, 1.0)));
        _clock = Timer.periodic(const Duration(milliseconds: 100),
            (_) => set('elapsedMs', DateTime.now().difference(started).inMilliseconds));
        return const {};
      case 'stop':
        final path = await _recorder.stop();
        await _meter?.cancel();
        _clock?.cancel();
        final ms = values['elapsedMs'];
        setAll({'recording': false, 'level': 0.0, 'elapsedMs': 0});
        if (path == null) throw CapabilityError('notRecording');
        return {'file': await CapabilityFile.fromPath(path), 'durationMs': ms};
      case 'cancel':
        await _recorder.cancel();
        setAll({'recording': false, 'level': 0.0, 'elapsedMs': 0});
        return const {};
    }
    throw CapabilityError.unknownRequest(name);
  }

  static String _state(PermissionStatus s) => switch (s) {
        PermissionStatus.granted => 'granted',
        PermissionStatus.limited => 'granted',
        PermissionStatus.permanentlyDenied => 'permanentlyDenied',
        PermissionStatus.restricted => 'restricted',
        PermissionStatus.denied => 'denied',
        _ => 'unknown',
      };
}

final codelessly = Codelessly(config: CodelesslyConfig(
  capabilities: [MicrophoneCapability(onSystemPrompt: PasscodeManager.instance.disableOnce), AppCapability()],
));
```

`HostCapability` is the SDK's base class. Its `values` is the capability's `ValueListenable` map, exposed as
`host.<name>`. `set` and `setAll` change it and are checked against the declaration in debug builds. `request`
answers a `callFunction`. `listen` answers a `host` event (the default emits whatever `emit(event, payload)`
sends). `CapabilityError(code, message)` becomes `${result.error}` in `onError`. `CapabilityCall` carries
`cancelled` (a future that completes when the chain is abandoned) and the calling screen's id.

**The chat channel: a signal means "fetch newer".** NOCD subscribes with
`pubNub.subscribe(channels: {channelId})`. On any message it calls `chatLoad(kGreaterThan)`, fetching messages newer
than the last over REST. It does not read the payload.

```json
{
  "capability": "chat",
  "version": "1.0.0",
  "values": {"connection": {"type": "choice", "of": ["offline", "connecting", "online"], "default": "offline"}},
  "events": {
    "signal": {"params": {"channel": "text"}, "payload": {"channel": "text", "at": "integer"}},
    "presence": {"params": {"channel": "text"}, "payload": {"uuid": "text", "action": {"type": "choice", "of": ["join", "leave", "timeout"]}}}
  },
  "requests": {"fetch": {"args": {"channel": "text", "after": "integer", "before": "integer", "limit": "integer"}, "result": {"messages": "list"}, "errors": ["offline", "server"]}}
}
```

```notation
state messages=[]
ListView m in messages reverse keyedBy=id
  ChatBubble message={m}
on load={callFunction name=chat.fetch params={"channel": route.channelId, "limit": 30}; messages=result.messages}
on host(event=chat.signal, params={"channel": route.channelId})={callFunction name=chat.fetch params={"channel": route.channelId, "after": last(messages).id} onError={}; messages=append(messages, result.messages)}
Text.caption "Reconnecting…" visible={host.chat.connection == 'connecting'}
```

```dart
class PubNubChat extends HostCapability {
  PubNubChat(this.pubnub, this.api) : super(CapabilityDeclaration.asset('chat.json'));
  final PubNub pubnub;
  final ChatRepository api;

  @override
  Stream<Map<String, Object?>> listen(String event, Map<String, Object?> params) {
    final channel = params['channel'] as String;
    final sub = pubnub.subscribe(channels: {channel});
    set('connection', 'online');
    final source = event == 'signal'
        ? sub.messages.map((e) => {'channel': channel, 'at': e.publishedAt.value})
        : sub.presence.map((p) => {'uuid': p.uuid?.value, 'action': p.action.name});
    // Cancelled by the SDK when the screen leaves: unsubscribe.
    return source.doOnCancel(sub.cancel);
  }

  @override
  Future<Object?> request(String name, Map<String, Object?> args, CapabilityCall call) async {
    if (name != 'fetch') throw CapabilityError.unknownRequest(name);
    try {
      final page = await api.messages(args['channel'] as String, after: args['after'] as int?, limit: args['limit'] as int? ?? 30);
      return {'messages': [for (final m in page) m.toJson()]};
    } on SocketException {
      throw CapabilityError('offline');
    }
  }
}
```

The page never sees PubNub. Another app's chat adapter (Stream, Firebase) implements the same declaration, and
the page is unchanged.

**Google sign-in.** NOCD calls `GoogleSignIn.instance.authenticate()`, then exchanges the token with Firebase
Auth, then its own backend. `GoogleSignInExceptionCode.canceled` is a quiet return; other failures show a dialog.

```json
{
  "capability": "googleSignIn",
  "version": "1.0.0",
  "platforms": ["ios", "android", "web"],
  "state": "availability",
  "values": {"availability": {"type": "choice", "of": ["unavailable", "granted"], "default": "granted"}},
  "requests": {"signIn": {"result": {"user": {"uid": "text", "email": "text", "displayName": "text", "isNew": "boolean"}}, "errors": ["canceled", "network", "accountDisabled", "failed"], "userGesture": true}}
}
```

```notation
Button.outline "Continue with Google" icon=google visible={host.googleSignIn.availability == 'granted'}
  onTap={callFunction name=googleSignIn.signIn
    onError={if result.error.code != 'canceled' then toast "Sign-in failed. Please try again."};
    navigate to={result.user.isNew ? 'onboarding' : 'home'} mode=reset}
```

```dart
class GoogleSignInCapability extends HostCapability {
  GoogleSignInCapability(this.backend) : super(CapabilityDeclaration.asset('google_sign_in.json'));
  final NocdAuthBackend backend;

  @override
  Future<Object?> request(String name, Map<String, Object?> args, CapabilityCall call) async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final cred = GoogleAuthProvider.credential(idToken: account.authentication.idToken);
      final user = await FirebaseAuth.instance.signInWithCredential(cred);
      final session = await backend.exchange(await user.user!.getIdToken());
      return {'user': {'uid': user.user!.uid, 'email': user.user!.email, 'displayName': user.user!.displayName, 'isNew': session.isNew}};
    } on GoogleSignInException catch (e) {
      throw CapabilityError(e.code == GoogleSignInExceptionCode.canceled ? 'canceled' : 'failed', e.description);
    } on SocketException {
      throw CapabilityError('network');
    }
  }
}
```

The signed-in user afterwards is a value. The SDK's `auth` layer (`Services.auth`, read as `auth.*`) is the
built-in form of this. An app that keeps its own session sets it through an `auth` adapter (§4), not through
`codelessly.setData('auth', …)`.

**System insets, keyboard and text scale.** These need no adapter and no declaration: Flutter already gives every
app its `MediaQuery`, and they are read under `screen`. This is stage one, built (§9):

```notation
Column w=fill h=fill
  Box w=fill h={screen.insets.top}
  Column#thread scroll w=fill grow
    …
  Row#composerBar w=fill gap=8 middle pad=[12,8,12,8] border-top=#FFE5E7EB
    Input#composer "" "Message Robin" @draft grow
    IconButton#send "send" onTap={…}
  Box w=fill h={screen.keyboard + screen.insets.bottom}
```

```dart
// Nothing to register: the platform's view metrics arrive through MediaQuery.
// A host that wants the layout to follow the text size setting raises the limit:
Codelessly(config: CodelesslyConfig(maxTextScaleFactor: 1.3));
// A host that consumes the safe area itself wraps the layout; the layout then reads 0.
SafeArea(child: CodelesslyWidget(codelessly: codelessly));
```

As a declaration, for discovery and mocks, it is the built-in `screen` contract: values only, always present.

## 4. Packages and adapters

**An adapter is a `HostCapability` subclass plus its declaration JSON.** It turns one package's API into one
contract. Three sources, from most to least common at first:

1. **The app developer**, in the app. NOCD's adapters would wrap the services it already has (`looptape_manager`,
   the PubNub code in `generic_chat_state`, `auth_components`, `remote_config_service`, `in_app_review_manager`).
   Most of the code is moved, not written.
2. **An agent given the package's API.** The work is mechanical: a declaration from the package's public
   surface, then a request switch over its calls and its exceptions mapped to declared error codes. An agent with
   the package's dartdoc and a declaration template writes it. The mock comes free from the declaration, so the agent
   can test the page before the adapter runs on a device.
3. **Published adapter packages**, one per package: `codelessly_capability_record`,
   `codelessly_capability_pubnub`, `codelessly_capability_google_sign_in`, each depending on the SDK's small
   capability library and on its package. They do not live in the SDK core. The core holds the base class, the
   declaration model, the `host` root, the `host` trigger, the mock and the checks, and no package dependency.

Two contracts with the same name cannot both be registered. Two adapters can implement the same contract (chat
over PubNub or over Stream), and the page cannot tell which.

**Versions.** A declaration has a semver `version`. A page records the contract versions it was checked against
in the publish (`requires: {"microphone": "^1.0.0"}`). At start, the SDK compares that with the registered
adapters and reports a page whose contract is missing or older than it needs. The page still shows; the request
fails into `onError` with `unavailable`. Adding a value, request, error or choice word is a minor version. Removing
or retyping one is major.

**Platforms.** A declaration lists `platforms`. An adapter on an unsupported platform reports its state as
`unavailable`, so a page that reads the state hides the control. The checks warn when a page uses a capability
whose declaration omits a platform the project targets, unless the page reads its state.

**The built-in layers are capabilities.** The SDK's feature layers are the same thing with different names:

| Layer | Today | As a capability |
|---|---|---|
| auth | `auth` action, `Services.auth`, `auth.*` value | `auth`: values `user`, `state`; requests `signIn`, `signUp`, `signOut`, `resetPassword` |
| data | `callApi`, cloud data actions, `Services.api`, `Services.cloud` | stays as it is: its actions are a document language over a backend, not a device capability |
| media | `pickFile`, `share`, `downloadFile`, `playSound`, `speak`, `captureScreenshot`; `Services.filePicker`, `sharer` | `files.pick`, `share.sheet`, `sound.play`, `speech.speak`, each with a declaration and a mock |
| commerce | `paywall`, `Services.purchases` | `purchases`: values `entitlements`; requests `buy`, `restore` |
| engage | `emitEvent`, `Services.analytics` | `analytics.track`: a request with no result that never fails a chain |

The existing action words stay: they are words in the base vocabulary, and `share` reads better than
`callFunction name=share.sheet`. What changes is underneath. Each built-in action is a declared request of a
built-in capability, so it gets the same typed result, `onError`, mock and render options as an app's own. The
`Services` interfaces become the built-in adapters' extension points, as they are today.

**Trust.** `TrustProfile` (`lib/src/core/edit/trust.dart`) says which words an agent-written page may use. It
gains a list of allowed capabilities and, for each, the requests allowed. An agent's page may read any declared
value of an allowed capability. It may make a request only if the profile allows that request, and a `sensitive`
capability (microphone, camera, location, contacts, purchases) only where the host turns it on for that page. A
request marked `userGesture` runs only from a pointer or key event: an agent's `load` cannot open a permission
prompt or a purchase sheet. The checks are made at expand time (an issue) and again at run time (the request fails
with `notAllowed`). This replaces "level 5, feature layers" with something finer: a level says which words, the
profile says which capabilities.

## 5. Lifecycle and correctness

- **A request outstanding when the page is left.** A chain already stops when its node leaves the screen. The
  SDK completes the call's `cancelled` future, and the adapter may stop work (a picker it can dismiss) or let it
  finish. A result that arrives after the screen has gone is dropped: no formula sees it and no `onError` runs. The
  declaration's `outlives` decides what happens to work that has started. A recording (`outlives: screen`) is
  cancelled with its screen, and the adapter's `cancel` runs. An upload (`outlives: app`) continues, and its outcome
  is a value (`host.uploads.pending`) any later screen can read.
- **A stream when the app is backgrounded.** `host.app.lifecycle` (`resumed`, `inactive`, `paused`, `hidden`,
  `detached`, from `AppLifecycleListener`) is a built-in value. The SDK tells adapters through `paused()` and
  `resumed()`. An adapter whose stream can miss messages while paused emits a `caughtUp` event on resume, or the
  page re-fetches on `valueChanged(variable=host.app.lifecycle)`. The chat example above needs nothing: its next
  signal fetches everything after the last message. Subscriptions stay open across a pause unless the adapter
  closes them. They close only when their screen leaves.
- **A permission changed in Settings while the app is away.** Each permission-backed adapter reads the state again
  in `resumed()` and `set`s it. Formulas follow and `valueChanged` reactions run. A page never caches a permission
  in its own variable. The checks warn when a page copies `host.*` into a `state`.
- **Errors.** Every failure reaches the page as `${result.error}` = `{code, message, capability, request}`. `code`
  is one of the declaration's `errors`, or one of the SDK's own: `unavailable`, `notAllowed`, `timeout`,
  `cancelled`, `unknownRequest`. An undeclared exception from an adapter becomes `failed`, is reported to
  `Services.analytics`, and is printed in debug builds. Without `onError`, the chain stops and `onActionError` runs,
  as today.
- **Timeouts.** A request declares `timeoutMs`, and `callFunction timeoutMs=…` overrides it for one call. A user
  prompt (permission, sign-in, picker) declares none, because a person may take as long as they like.
- **What is persisted.** Nothing of a capability's, by default. Values are the adapter's to restore (it reads the
  platform again at start). A value the declaration marks `persist` (the last fetched feature flags, so the first
  frame does not flicker) is kept in `Services.storage` under the capability's name. Outstanding requests and
  stream subscriptions are never persisted. A `--reload` in the render tool starts them fresh, as an app restart
  does.
- **Back.** It stays the screen's `backPressed` with `blockBack`, which exists. Predictive Back is a platform
  animation the SDK's route already drives.
- **The clock.** `now()` reads `FormulaClock`, which a host can replace and the render tool pins (`--now`) or
  starts (`--clock`). The zone is the missing half: `host.clock.zone` (IANA, from `flutter_timezone`), and
  `formatDate(t, pattern, zone)` taking it.

## 6. What the test and render tools need

Everything below follows from the declaration. A test names an outcome, and the generic mock produces it.

| Need | Option or step | Today |
|---|---|---|
| The device's safe area | `--insets 47,34` (or four sides) | **built (stage one)** |
| The text size setting | `--text-scale 1.3` | **built (stage one)** |
| The keyboard opening and closing | step `--keyboard 336`, `--keyboard 0` | **built (stage one)** |
| A fixed or moving clock | `--now`, `--clock` | exists |
| A zone | `--zone America/Chicago` | missing |
| Which capabilities the host offers | `--capabilities <folder of declarations>`; a site's `site.json` lists its own | missing |
| A capability's value | `--capability microphone.permission=denied` (a run option, or a step, which changes it while the page shows) | missing |
| A request's outcome | `--answer googleSignIn.signIn=error:canceled`, `--answer microphone.stop='{"file":"fixtures/take.m4a","durationMs":12000}'`, `--answer files.pick=fixtures/a.png` (as `--pick-file` does) | `--pick-file` only |
| A pushed event | step `--emit chat.signal='{"channel":"t1"}'` | missing |
| A value that streams | steps of `--capability microphone.level=0.6` with `--frames` | missing |
| Lifecycle | step `--lifecycle paused`, `--lifecycle resumed` (adapters' `paused` and `resumed` run, `host.app.lifecycle` changes) | missing |
| Back | step `--key Escape` reaches `backPressed`; a `--back` step that sends the system's | partly |
| What the page asked of the host | the diagnostics list each request, with its arguments, and each subscription, as the analytics recorder lists events today | missing |

In `states.json`, each step is a key, as now: `{"capability": "microphone.permission=denied"}`,
`{"emit": "chat.signal={\"channel\":\"t1\"}"}`, `{"keyboard": 336}`. A request with no `--answer` gets the
declaration's default result. A required request with no answer and no declared default fails the run with a
message naming the option that would answer it, so a missing answer is never a silent pass.

With these, the rebuild's "out of reach" rows become states. The recorder becomes four of them: denied, recording
at a level, stopped with a file, interrupted. The chat becomes a signal arriving while scrolled up. The update gate
becomes `--capability store.update=required`. Robin becomes `--capability robin.answer='{"stage":"tool",…}'`
steps, and the deep link becomes `--emit links.opened`. Only the keyboard's own UI, autofill, haptics you can feel
and screen-reader speech still need a device.

## 7. A staged plan

Each stage is useful by itself.

**Stage one: the device's edges** (built, §9). `screen.insets`, `screen.keyboard` and `screen.textScale` come from
the platform or the host's `MediaQuery`. The render tool's `--insets`, `--text-scale` and `--keyboard` simulate
them. It unlocks the register's most-cited native entry, "Provide native insets and text scaling" (parts 01, 03,
07, 19, 28), and "Independent alert guards and system insets" (02). Of the "out of reach" rows, it reaches the 16
insets, keyboard and text-scale rows and the keyboard parts of the 11 chat-thread rows: wrappers that pad for a
status bar (03, 05, 12, 17), composers and sheets that ride the keyboard (07, 12, 23, 24, 26, 27), and Robin's draft.

**Stage two: values and requests, declared and mocked.** This adds the declaration model (API), `HostCapability`,
the `host` root, `callFunction onError` and `timeoutMs`, the expander checks, the generic mock, and the render
options `--capabilities`, `--capability` and `--answer`. `app` is a built-in capability (lifecycle as a value,
`openSettings`, `version`), and so is `clock.zone`. The built-in `pickFile` and `share` move onto it. It unlocks
permissions and biometrics (30), LoopTape's permission and start and stop with a file (28; the level meter needs
streamed values, which ride on `set`), Google and Apple sign-in outcomes (07, 10), gallery pick and crop (16), the
share handoff (15), the calendar handoff and notification permission (19, 30), the update gate (03), the booking
release flag and zones (21, 22), and the remote-request outcomes (01). It is the largest stage and the one that
proves the model. Build LoopTape first, end to end on a device with `record`, then Google sign-in.

**Stage three: streams and lifecycle.** This adds the `host` trigger with screen-scoped subscriptions, the
`paused` and `resumed` hooks, and the render steps `--emit` and `--lifecycle`. It unlocks the PubNub signal and
presence (11, 12, 13), Robin's SSE answer as a streamed value (12), push notifications and deep-link returns (08,
11), homework's background, foreground and catch-up (23), and settings refreshing on resume (30).

**Stage four: regions and adapter packages.** This adds `External params`, regions in declarations with mock
placeholders, and the first published adapter packages (`record`, `pubnub`, `google_sign_in`). It also exports
declarations into the agent's reference and adds capabilities to `TrustProfile`. It unlocks the video and web view
lifecycles (04, 19, 23) and a camera preview. It also lets an agent build a page for a host it has never seen, from
the host's declarations alone.

## 8. Open questions for the owner

1. **One root or several.** This note puts device facts under `screen` (no declaration) and everything else under
   `host.<capability>`. The alternative is a root per capability (`microphone.permission`), which reads better but
   makes every capability name a reserved word of the formula language.
2. **The request form.** Is it `callFunction name=microphone.start`, reusing a word, or a new generic action, say
   `ask microphone.start format=aac`, a verb whose fields are the declaration's arguments? The second reads better
   and checks better. It is one new word, not one per capability.
3. **Built-in actions.** Should `pickFile`, `share` and `auth` stay words over built-in capabilities (proposed), or
   become plain `callFunction`s of them, which shrinks the vocabulary but loses the natural word?
4. **Text scale.** `CodelesslyConfig.maxTextScaleFactor` defaults to 1. The prototype found that even when raised,
   the nodes' text is drawn at its written size: `screen.textScale` reads 1.3, but the picture is the same as at 1.
   Should the SDK's text follow it (and then which nodes: body text yes, a fixed-height tab label no), or should
   layouts only read it and choose?
5. **The keyboard and the other agent's fix.** Another checkout is making the SDK keep a focused field visible
   when the keyboard opens. If that moves or shrinks the page by itself, `screen.keyboard` must then mean "the part
   of this page the keyboard still covers", which is 0 once the SDK has made room, as `MediaQuery.removeViewInsets`
   does inside a sheet today. Otherwise a page that pads by it lifts the composer twice. That contract needs settling
   between the two.
6. **Who publishes adapters.** Should Codelessly publish first-party adapter packages for the common packages
   (permission_handler, record, image_picker, google_sign_in, share_plus, pubnub, firebase_messaging,
   remote_config), or leave adapters to apps and agents, with only the declaration format and the mock shipped?
7. **Sensitive capabilities in agent pages.** Should an agent-written page ever be allowed a sensitive request
   (microphone, purchases) without a human approving that page, or should the trust profile require approval per
   page, per capability?

## 9. Stage one, as built

What a page reads (`CodelesslySDK/lib/src/runtime/expressions/scopes.dart`, `deviceEdgeValues`; from Flutter in
`lib/src/app/viewport.dart`, `deviceEdgesOf`):

| Value | From | Meaning |
|---|---|---|
| `screen.insets.top`, `.right`, `.bottom`, `.left` | `MediaQuery.padding` | The safe area. A side the keyboard covers has none, so `screen.keyboard + screen.insets.bottom` is the one gap a bottom bar needs. A `SafeArea` the host puts around the layout consumes them |
| `screen.keyboard` | `MediaQuery.viewInsets.bottom` | How much of the screen's bottom the soft keyboard covers; 0 while closed |
| `screen.textScale` | `MediaQuery.textScaler`, clamped to `CodelesslyConfig.maxTextScaleFactor` | The device's text size setting as far as the host lets layouts follow it (1 by default) |

They are part of the `screen` value on `CodelesslyWidget` (`_updateScreen`) and on the session view
(`lib/src/session/view.dart`), and they change as the `MediaQuery` changes. The host supplies them as any Flutter
app has them: the platform's view metrics, or a `MediaQuery` of its own above the layout.

The render tool (`CodelesslySDK/tool/render`) gains `--insets <top>,<bottom>` (or four sides) and
`--text-scale <f>` as run options, and `--keyboard <px>` as a step. `--keyboard` sets the view's bottom inset, takes
the home indicator's inset under it, and draws a plain grey block where a keyboard would be. `tool/codelessly
states` takes them as `{"keyboard": 336}` steps and `"args": ["--insets", "47,34"]`. The guide
(`docs/guide/08-conditions-and-breakpoints.md`) and the notation reference (`responsive.md`) say how to read them.

The example is [`the-native-edge/composer.txt`](the-native-edge/composer.txt), a chat thread whose composer bar
sits on a box `h={screen.keyboard + screen.insets.bottom}` tall, with the values printed in its header. Its
[`states.json`](the-native-edge/states.json) renders five states at 390×844. In "desktop window" there are no
insets. In "phone" (`--insets 47,34`) the header clears the status bar and the bar clears the home indicator. In
"keyboard open" (`--focus composer --keyboard 336 --type …`) the bar sits on the keyboard; the header reads
`keyboard 336 · insets 47/0`. In "closed again" (send, unfocus, `--keyboard 0`) it is back above the home
indicator, with the sent message in the thread. In "large text" (`--text-scale 1.3`) the header reads 1.3, but the
text is unchanged (question 4). The pictures are in `the-native-edge/out/<state>/` and on one sheet,
`the-native-edge/out/sheet.png`.

Tests: `CodelesslySDK/test/app/device_edges_test.dart` (the values in formulas, from the platform, from a host
`MediaQuery`, the text scale clamped by the config, a `SafeArea` consuming them) and
`CodelesslySDK/test/tool/render_device_edges_test.dart` (the options parse; the composer's bar ends at 844 − 34
with the keyboard closed, at 844 − 336 with it open, and returns when it closes).
