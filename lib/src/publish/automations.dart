// Automations: what a published project does on its own at app-level
// moments (the app starts, a session starts, the app resumes, the app or a
// layout fires an event, an interval passes, a screen shows), with no node
// and no visible screen of its own. Each is a trigger, a condition, how
// often it may run, and the chain of actions it runs (open a layout as a
// modal or banner, set a variable, call a function...). Pure data; the SDK
// runs them (its `Codelessly.automations`).
//
// JSON, in the publish model under `automations` (a list; a model without it
// has none, and a runtime that doesn't know it keeps it in `extra`):
//
// ```json
// {"id": "rate-us", "trigger": "event", "event": "order_completed",
//  "when": "usage.events.order_completed.count >= 3",
//  "maxRuns": 1, "delayMs": 1500,
//  "actions": [{"type": "openModal", "to": "rate-us", "presentation": "dialog"}]}
// ```
import 'package:meta/meta.dart';

import '../actions.dart';
import '../json.dart';
import '../props.dart';
import 'publish_model.dart';

/// The publish model's key holding its automations.
const String kAutomationsKey = 'automations';

/// What starts an [Automation].
enum AutomationTrigger {
  /// The app started: once per run, when the runtime has loaded the
  /// project.
  appStart,

  /// A session started: at app start, and when the app comes back after
  /// [Automation.sessionTimeoutMs] in the background.
  sessionStart,

  /// The app came back to the foreground.
  resume,

  /// App event [Automation.event] was fired: by the host
  /// (`codelessly.emit`) or a layout (an `emitEvent` action). `${event}`
  /// holds its `name` and `props`; `${result}` its props.
  event,

  /// Every [Automation.intervalMs] while the app is in the foreground.
  interval,

  /// A screen of the project showed ([Automation.screen]: a layout, canvas
  /// or custom id; empty: any). `${event.props}` holds `layoutId`,
  /// `canvasId` and `params`.
  screenShown,
}

/// One automation of a project. Its [when] and its actions read the app's
/// values (variables, `auth`, `storage`, `data`), `${event}` (`name`,
/// `props`) and `${usage}`, the per-user counters the runtime keeps on the
/// device:
///
/// - `usage.launches`, `usage.sessions`, `usage.firstSeen`, `usage.lastSeen`
///   (ms since epoch), `usage.isFirstLaunch`, `usage.isFirstSession`;
/// - `usage.events.<name>.count` and `.last`: every app event fired;
/// - `usage.automations.<id>.count`, `.last` and `.session` (runs this
///   session).
///
/// [maxRuns], [maxPerSession] and [everyDays] limit how often it runs
/// ("once", "once per session", "at most every 7 days").
@immutable
final class Automation {
  const Automation({
    required this.id,
    this.name = '',
    this.enabled = true,
    this.trigger = AutomationTrigger.event,
    this.event = '',
    this.screen = '',
    this.intervalMs = 60000,
    this.sessionTimeoutMs = 30 * 60 * 1000,
    this.when = '',
    this.maxRuns = 0,
    this.maxPerSession = 0,
    this.everyDays = 0,
    this.delayMs = 0,
    this.priority = 0,
    this.actions = const [],
    this.extra = const {},
  });

  /// Unique in the project; its counters (`usage.automations.<id>`) are
  /// kept by it.
  final String id;
  final String name;

  /// False: it never runs.
  final bool enabled;
  final AutomationTrigger trigger;

  /// [AutomationTrigger.event]: the event's name.
  final String event;

  /// [AutomationTrigger.screenShown]: the screen (layout, canvas or custom
  /// id); empty: any.
  final String screen;

  /// [AutomationTrigger.interval]: how often, in ms (at least 1000).
  final int intervalMs;

  /// [AutomationTrigger.sessionStart]: how long the app must have been in
  /// the background for its return to start a new session.
  final int sessionTimeoutMs;

  /// A formula that must hold for it to run (`usage.sessions >= 3 &&
  /// !auth.isAnonymous`), or a `${...}` expression; empty: always.
  final String when;

  /// The most times it runs for a user; 0: no limit (1: once).
  final int maxRuns;

  /// The most times it runs in one session; 0: no limit.
  final int maxPerSession;

  /// The fewest days between two runs; 0: no wait.
  final double everyDays;

  /// Waits this long after the trigger before checking [when] again and
  /// running (a popup a moment after a screen shows).
  final int delayMs;

  /// Which presentation shows first when several wait (higher first).
  final int priority;

  /// What it does, in order, as one chain.
  final List<ActionDef> actions;

  /// Keys this version doesn't model, kept.
  final Json extra;

  static const Set<String> _keys = {
    'id', 'name', 'enabled', 'trigger', 'event', 'screen', 'intervalMs', 'sessionTimeoutMs', 'when', 'maxRuns', //
    'maxPerSession', 'everyDays', 'delayMs', 'priority', 'actions',
  };

  /// Decodes an automation; null for anything without an id. Never throws.
  static Automation? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    return Automation(
      id: id,
      name: readString(m['name']) ?? '',
      enabled: readBool(m['enabled']) ?? true,
      trigger: readEnum(AutomationTrigger.values, m['trigger'], AutomationTrigger.event),
      event: readString(m['event']) ?? '',
      screen: readString(m['screen']) ?? '',
      intervalMs: (readInt(m['intervalMs']) ?? 60000).clamp(1000, 1 << 31),
      sessionTimeoutMs: (readInt(m['sessionTimeoutMs']) ?? 30 * 60 * 1000).clamp(0, 1 << 31),
      when: readString(m['when']) ?? '',
      maxRuns: (readInt(m['maxRuns']) ?? 0).clamp(0, 1 << 31),
      maxPerSession: (readInt(m['maxPerSession']) ?? 0).clamp(0, 1 << 31),
      everyDays: (readDouble(m['everyDays']) ?? 0).clamp(0, double.infinity).toDouble(),
      delayMs: (readInt(m['delayMs']) ?? 0).clamp(0, 1 << 31),
      priority: readInt(m['priority']) ?? 0,
      actions: ActionDef.listFromJson(m['actions']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  /// The automations in [json] (a list); entries without an id are left out.
  static List<Automation> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() => {
    'id': id,
    if (name.isNotEmpty) 'name': name,
    if (!enabled) 'enabled': false,
    'trigger': trigger.name,
    if (event.isNotEmpty) 'event': event,
    if (screen.isNotEmpty) 'screen': screen,
    if (intervalMs != 60000) 'intervalMs': intervalMs,
    if (sessionTimeoutMs != 30 * 60 * 1000) 'sessionTimeoutMs': sessionTimeoutMs,
    if (when.isNotEmpty) 'when': when,
    if (maxRuns != 0) 'maxRuns': maxRuns,
    if (maxPerSession != 0) 'maxPerSession': maxPerSession,
    if (everyDays != 0) 'everyDays': writeDouble(everyDays),
    if (delayMs != 0) 'delayMs': delayMs,
    if (priority != 0) 'priority': priority,
    if (actions.isNotEmpty) 'actions': [for (final a in actions) a.toJson()],
    ...extra,
  };

  Automation copyWith({
    String? id,
    String? name,
    bool? enabled,
    AutomationTrigger? trigger,
    String? event,
    String? screen,
    int? intervalMs,
    int? sessionTimeoutMs,
    String? when,
    int? maxRuns,
    int? maxPerSession,
    double? everyDays,
    int? delayMs,
    int? priority,
    List<ActionDef>? actions,
  }) => Automation(
    id: id ?? this.id,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    trigger: trigger ?? this.trigger,
    event: event ?? this.event,
    screen: screen ?? this.screen,
    intervalMs: intervalMs ?? this.intervalMs,
    sessionTimeoutMs: sessionTimeoutMs ?? this.sessionTimeoutMs,
    when: when ?? this.when,
    maxRuns: maxRuns ?? this.maxRuns,
    maxPerSession: maxPerSession ?? this.maxPerSession,
    everyDays: everyDays ?? this.everyDays,
    delayMs: delayMs ?? this.delayMs,
    priority: priority ?? this.priority,
    actions: actions ?? this.actions,
    extra: extra,
  );

  @override
  bool operator ==(Object other) => other is Automation && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'Automation(${toJson()})';
}

/// An [Automation]'s fields, for generated editors (its JSON keys and
/// defaults).
abstract final class AutomationFields {
  static const id = PropDef<String>('id', Codecs.string, '', doc: 'Unique in the project; keys its counters.');
  static const name = PropDef<String>('name', Codecs.string, '');
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true);
  static const trigger = PropDef<AutomationTrigger>(
      'trigger', EnumCodec(AutomationTrigger.values), AutomationTrigger.event,
      doc: 'App start, session start, resume, an app event, an interval, or a screen shown.');
  static const event = PropDef<String>('event', Codecs.string, '', doc: 'Trigger event: the event\'s name.');
  static const screen = PropDef<String>('screen', Codecs.string, '', doc: 'Trigger screenShown: the screen; empty: any.');
  static const intervalMs = PropDef<int>('intervalMs', IntCodec(min: 1000), 60000, doc: 'Trigger interval: every (ms).');
  static const sessionTimeoutMs = PropDef<int>('sessionTimeoutMs', IntCodec(min: 0), 30 * 60 * 1000,
      doc: 'Time in the background after which a return starts a new session (ms).');
  static const when = PropDef<String>('when', Codecs.string, '',
      doc: 'A formula over event, usage, variables, auth and storage; empty: always.');
  static const maxRuns = PropDef<int>('maxRuns', IntCodec(min: 0), 0, doc: 'Runs per user; 0: no limit, 1: once.');
  static const maxPerSession = PropDef<int>('maxPerSession', IntCodec(min: 0), 0, doc: 'Runs per session; 0: no limit.');
  static const everyDays = PropDef<double>('everyDays', Codecs.positive, 0, doc: 'Fewest days between runs; 0: no wait.');
  static const delayMs = PropDef<int>('delayMs', IntCodec(min: 0), 0, doc: 'Wait after the trigger (ms).');
  static const priority = PropDef<int>('priority', Codecs.int, 0, doc: 'Higher shows first when presentations wait.');
  static const actions = PropDef<Object?>('actions', Codecs.any, null, doc: 'The chain it runs.');
  static const List<PropDef<Object?>> all = [
    id, name, enabled, trigger, event, screen, intervalMs, sessionTimeoutMs, when, maxRuns, maxPerSession, //
    everyDays, delayMs, priority, actions,
  ];
}

/// A publish model's automations (its `automations`, kept in
/// [PublishModel.extra] so that a model without them is unchanged).
extension PublishModelAutomations on PublishModel {
  /// The project's automations, in order.
  List<Automation> get automations => Automation.listFromJson(extra[kAutomationsKey]);

  /// This model with [automations] (none: the key is removed).
  PublishModel withAutomations(List<Automation> automations) => copyWith(extra: {
    for (final e in extra.entries)
      if (e.key != kAutomationsKey) e.key: e.value,
    if (automations.isNotEmpty) kAutomationsKey: [for (final a in automations) a.toJson()],
  });
}
