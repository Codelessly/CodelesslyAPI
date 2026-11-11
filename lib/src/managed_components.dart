// Linked, Codelessly-managed components (DESIGN.md §4.3): components that
// Codelessly publishes as immutable, versioned masters and that projects
// reference instead of copying.
//
// * A master (`managed_components/{id}`, [ManagedComponentMaster]) lists its
//   versions, its channel pointers (`stable`, `beta`) per major, staged
//   rollouts and blocked (rolled back) versions.
// * A version (`managed_components/{id}/versions/{n}`,
//   [ManagedComponentVersion]) is immutable: the component's nodes
//   ([ComponentDefinition]) and its contract ([ManagedComponentContract]:
//   settings by stable key, slots, events, theme tokens, variables).
// * An instance in a page is the top node of a copy of a version's nodes,
//   linked with a [ComponentLink] whose [ComponentLink.managed] is a
//   [ManagedComponentRef]: the channel it follows (or a pinned version), its
//   setting values by key, its slots' contents, its event action chains and
//   theme token overrides. Its nodes are the snapshot: what the editor
//   shows, what a publish carries and what an app falls back to.
// * [buildManagedInstance] makes an instance's nodes from any version and
//   the instance's ref, so the editor (insert, update, settings) and the SDK
//   (a newer version at run time) build the same tree.
// * Versioning: a version has a semver. Same-major versions apply on their
//   own (the SDK swaps them in at run time); a new major never does: the
//   editor offers it as an update ([ManagedComponentMaster.newerMajor]).
import 'dart:convert';

import 'package:meta/meta.dart';

import 'actions.dart';
import 'bindings.dart';
import 'components.dart';
import 'document.dart';
import 'json.dart';
import 'layout.dart';
import 'node.dart';
import 'publish/publish_layout.dart';
import 'publish/theme.dart';
import 'variables.dart';

/// The collection of managed component masters; versions are its
/// `versions` subcollection.
const String kManagedComponentsCollection = 'managed_components';

/// The action type a master's chains name an event by: `{"type":
/// "componentEvent", "event": "onSuccess"}`. Building an instance splices
/// the instance's chain for that event in its place; an unbuilt one is an
/// unknown action, which runtimes skip.
const String kComponentEventAction = 'componentEvent';

/// The placeholder action for event [key] (see [kComponentEventAction]).
ActionDef componentEventAction(String key) => UnknownAction(kComponentEventAction, {'event': key});

/// The event [action] is the placeholder of, or null.
String? componentEventOf(ActionDef action) =>
    action is UnknownAction && action.unknownType == kComponentEventAction ? readString(action.json['event']) : null;

/// A release channel of managed components.
enum ManagedChannel {
  /// What every project gets.
  stable,

  /// Ahead of stable: Codelessly's own and opted-in projects. A beta
  /// instance also takes stable releases newer than beta's.
  beta,
}

/// A semantic version, `major.minor.patch` (missing parts are 0; anything
/// after a `-` or `+` is ignored).
@immutable
final class Semver implements Comparable<Semver> {
  const Semver(this.major, [this.minor = 0, this.patch = 0]);

  final int major, minor, patch;

  /// Null when [text] doesn't start with a number.
  static Semver? tryParse(String? text) {
    if (text == null) return null;
    final core = text.trim().split(RegExp(r'[-+]')).first;
    final parts = core.split('.');
    final nums = [for (final p in parts) int.tryParse(p)];
    if (nums.isEmpty || nums.first == null || nums.length > 3 || nums.any((n) => n == null || n < 0)) return null;
    return Semver(nums[0]!, nums.length > 1 ? nums[1]! : 0, nums.length > 2 ? nums[2]! : 0);
  }

  @override
  int compareTo(Semver other) => major != other.major
      ? major.compareTo(other.major)
      : minor != other.minor
      ? minor.compareTo(other.minor)
      : patch.compareTo(other.patch);

  bool operator <(Semver other) => compareTo(other) < 0;
  bool operator >=(Semver other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) => other is Semver && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// Whether an SDK at [sdkVersion] can run a version needing [minSdk]
/// (either empty or unreadable: yes).
bool sdkSatisfies(String? sdkVersion, String? minSdk) {
  final need = Semver.tryParse(minSdk), have = Semver.tryParse(sdkVersion);
  return need == null || have == null || have >= need;
}

/// A project's rollout bucket for managed component [componentId], 0..99:
/// FNV-1a (32 bit) of `"projectId/componentId"`'s UTF-8 bytes, mod 100.
/// Per project, so every user of one app sees the same version.
int managedRolloutBucket(String projectId, String componentId) {
  var h = 0x811c9dc5;
  for (final b in utf8.encode('$projectId/$componentId')) {
    h ^= b;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h % 100;
}

// --- the instance's side --------------------------------------------------------------

/// A managed instance's reference ([ComponentLink.managed]): what it follows
/// and how it customizes the component without forking it.
///
/// JSON (sparse): `{"channel": "beta", "pin": 4, "semver": "1.2.0",
/// "digest": "…", "values": {"title": "Welcome"}, "slots": {"header":
/// ["n7"]}, "events": {"onSuccess": [{"type": "navigate", …}]},
/// "tokens": {"primary": "#FF6200EE"}}`. `channel` defaults to `stable`.
@immutable
final class ManagedComponentRef {
  const ManagedComponentRef({
    this.channel = ManagedChannel.stable,
    this.pin,
    this.semver = '',
    this.digest = '',
    this.values = const {},
    this.slots = const {},
    this.events = const {},
    this.tokens = const {},
    this.extra = const {},
  });

  /// The channel whose same-major releases the instance takes.
  final ManagedChannel channel;

  /// A version number the instance stays on: no update applies on its own.
  final int? pin;

  /// The semver of the version its nodes were built from (the snapshot):
  /// its major is the one updates stay within.
  final String semver;

  /// The snapshot version's digest, when known.
  final String digest;

  /// Setting values the instance set, by setting key
  /// ([ComponentSetting.effectiveKey]); a setting not here has the
  /// version's value.
  final Json values;

  /// The instance's own nodes in each slot, by slot key: ids of top nodes
  /// kept in the page under the slot's node.
  final Map<String, List<String>> slots;

  /// The action chain run on each event, by event key.
  final Map<String, List<ActionDef>> events;

  /// Theme token overrides ([ThemeTokens] JSON keys → values).
  final Json tokens;
  final Json extra;

  /// The snapshot's major (0 when its semver is unreadable).
  int get major => Semver.tryParse(semver)?.major ?? 0;

  ManagedComponentRef copyWith({
    ManagedChannel? channel,
    int? Function()? pin,
    String? semver,
    String? digest,
    Json? values,
    Map<String, List<String>>? slots,
    Map<String, List<ActionDef>>? events,
    Json? tokens,
  }) => ManagedComponentRef(
    channel: channel ?? this.channel,
    pin: pin != null ? pin() : this.pin,
    semver: semver ?? this.semver,
    digest: digest ?? this.digest,
    values: values ?? this.values,
    slots: slots ?? this.slots,
    events: events ?? this.events,
    tokens: tokens ?? this.tokens,
    extra: extra,
  );

  /// With setting [key] set to [value] (null: back to the version's).
  ManagedComponentRef withValue(String key, Object? value) =>
      copyWith(values: {...values, key: value}..removeWhere((k, v) => k == key && v == null));

  /// With event [key]'s chain set to [actions] (empty: removed).
  ManagedComponentRef withEvent(String key, List<ActionDef> actions) =>
      copyWith(events: {...events, key: actions}..removeWhere((k, v) => k == key && v.isEmpty));

  /// With slot [key]'s nodes set to [nodeIds] (empty: the version's default
  /// content).
  ManagedComponentRef withSlot(String key, List<String> nodeIds) =>
      copyWith(slots: {...slots, key: nodeIds}..removeWhere((k, v) => k == key && v.isEmpty));

  /// Slot node ids mapped by [ids] (a copy of the tree with new ids).
  ManagedComponentRef remapped(Map<String, String> ids) => copyWith(
    slots: {
      for (final e in slots.entries) e.key: [for (final id in e.value) ids[id] ?? id],
    },
  );

  /// Every slot node id.
  Iterable<String> get slotNodeIds => slots.values.expand((l) => l);

  static const _keys = {'channel', 'pin', 'semver', 'digest', 'values', 'slots', 'events', 'tokens'};

  /// Null unless [json] is an object.
  static ManagedComponentRef? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ManagedComponentRef(
      channel: readEnum(ManagedChannel.values, m['channel'], ManagedChannel.stable),
      pin: readInt(m['pin']),
      semver: readString(m['semver']) ?? '',
      digest: readString(m['digest']) ?? '',
      values: {...?readMap(m['values'])},
      slots: {
        for (final e in (readMap(m['slots']) ?? const {}).entries)
          if (readStrings(e.value) case final ids when ids.isNotEmpty) e.key: ids,
      },
      events: {
        for (final e in (readMap(m['events']) ?? const {}).entries)
          if (ActionDef.listFromJson(e.value) case final chain when chain.isNotEmpty) e.key: chain,
      },
      tokens: {...?readMap(m['tokens'])},
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    if (channel != ManagedChannel.stable) 'channel': channel.name,
    'pin': ?pin,
    if (semver.isNotEmpty) 'semver': semver,
    if (digest.isNotEmpty) 'digest': digest,
    if (values.isNotEmpty) 'values': values,
    if (slots.isNotEmpty) 'slots': slots,
    if (events.isNotEmpty)
      'events': {
        for (final e in events.entries) e.key: [for (final a in e.value) a.toJson()],
      },
    if (tokens.isNotEmpty) 'tokens': tokens,
    ...extra,
  };

  @override
  bool operator ==(Object other) => other is ManagedComponentRef && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'ManagedComponentRef(${toJson()})';
}

// --- the master's contract -------------------------------------------------------------

/// A place in a managed component that holds the instance's own nodes.
///
/// JSON: `{"key": "header", "label": "Header", "node": "hdr", "accepts":
/// "any"}`: [node] is the version's node (an id in its definition) whose
/// children the slot's content replaces.
@immutable
final class ManagedSlot {
  const ManagedSlot({required this.key, this.label = '', required this.node, this.accepts = 'any'});

  final String key, label, node;

  /// `any`, `image` or `text`: what the editor offers to put in it.
  final String accepts;

  static ManagedSlot? fromJson(Object? json) {
    final m = readMap(json);
    final key = readString(m?['key']), node = readString(m?['node']);
    if (m == null || key == null || key.isEmpty || node == null || node.isEmpty) return null;
    return ManagedSlot(
      key: key,
      label: readString(m['label']) ?? '',
      node: node,
      accepts: readString(m['accepts']) ?? 'any',
    );
  }

  Json toJson() => {
    'key': key,
    if (label.isNotEmpty) 'label': label,
    'node': node,
    if (accepts != 'any') 'accepts': accepts,
  };
}

/// Something a managed component reports, which an instance can run its
/// own action chain after.
///
/// JSON: `{"key": "onSuccess", "label": "On success", "description": "…",
/// "payload": {"uid": "string"}}` (`${result}` while the chain runs).
@immutable
final class ManagedEvent {
  const ManagedEvent({required this.key, this.label = '', this.description = '', this.payload = const {}});

  final String key, label, description;
  final Json payload;

  static ManagedEvent? fromJson(Object? json) {
    final m = readMap(json);
    final key = readString(m?['key']);
    if (m == null || key == null || key.isEmpty) return null;
    return ManagedEvent(
      key: key,
      label: readString(m['label']) ?? '',
      description: readString(m['description']) ?? '',
      payload: readMap(m['payload']) ?? const {},
    );
  }

  Json toJson() => {
    'key': key,
    if (label.isNotEmpty) 'label': label,
    if (description.isNotEmpty) 'description': description,
    if (payload.isNotEmpty) 'payload': payload,
  };
}

/// What a managed component lets an instance customize, and what it needs:
/// the schema the editor's instance panel is generated from.
///
/// JSON: `{"settings": [ComponentSetting…], "slots": [ManagedSlot…],
/// "events": [ManagedEvent…], "tokens": ["primary", …], "variables":
/// [Variable…], "requires": {"auth": ["password"]}}`. Setting targets and
/// slot nodes name the version's node ids.
@immutable
final class ManagedComponentContract {
  const ManagedComponentContract({
    this.settings = const [],
    this.slots = const [],
    this.events = const [],
    this.tokens = const [],
    this.variables = const [],
    this.requires = const {},
    this.extra = const {},
  });

  final List<ComponentSetting> settings;
  final List<ManagedSlot> slots;
  final List<ManagedEvent> events;

  /// The theme tokens ([ThemeTokens] JSON keys) its nodes bind
  /// (`${theme.primary}`).
  final List<String> tokens;

  /// The variables its nodes and actions use, declared on the canvas it is
  /// placed on.
  final List<Variable> variables;

  /// What it needs of the project (`{"auth": ["password"]}`).
  final Json requires;
  final Json extra;

  /// Every setting, groups flattened.
  Iterable<ComponentSetting> get flatSettings sync* {
    Iterable<ComponentSetting> walk(List<ComponentSetting> list) sync* {
      for (final s in list) {
        if (s.isGroup) {
          yield* walk(s.settings);
        } else {
          yield s;
        }
      }
    }

    yield* walk(settings);
  }

  /// The setting with key [key].
  ComponentSetting? setting(String key) => flatSettings.where((s) => s.effectiveKey == key).firstOrNull;

  static const _keys = {'settings', 'slots', 'events', 'tokens', 'variables', 'requires'};

  static ManagedComponentContract fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return ManagedComponentContract(
      settings: ComponentSetting.listFromJson(m['settings']),
      slots: [...?readList(m['slots'])?.map(ManagedSlot.fromJson).nonNulls],
      events: [...?readList(m['events'])?.map(ManagedEvent.fromJson).nonNulls],
      tokens: readStrings(m['tokens']),
      variables: [...?readList(m['variables'])?.map(Variable.fromJson).nonNulls],
      requires: readMap(m['requires']) ?? const {},
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    if (settings.isNotEmpty) 'settings': [for (final s in settings) s.toJson()],
    if (slots.isNotEmpty) 'slots': [for (final s in slots) s.toJson()],
    if (events.isNotEmpty) 'events': [for (final e in events) e.toJson()],
    if (tokens.isNotEmpty) 'tokens': tokens,
    if (variables.isNotEmpty) 'variables': [for (final v in variables) v.toJson()],
    if (requires.isNotEmpty) 'requires': requires,
    ...extra,
  };

  @override
  bool operator ==(Object other) => other is ManagedComponentContract && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

// --- versions and the master -----------------------------------------------------------

/// One immutable release of a managed component
/// (`managed_components/{id}/versions/{n}`).
///
/// JSON as stored: `{"schema": 2, "id": "sign_in", "version": 3, "semver":
/// "1.1.0", "minSdk": "22.0.0", "payload": "{\"definition\": …, \"contract\":
/// …}", "digest": "9f2c…", "changelog": "…", "createdAt": ms, "createdBy":
/// uid}`: `payload` is the JSON text of the definition and contract and
/// `digest` the sha256 hex of its UTF-8 bytes. The payload is kept as text so
/// a reader can check the digest over exactly the stored bytes. Decoding
/// also takes `definition` and `contract` inline (tests, bundles).
@immutable
final class ManagedComponentVersion {
  const ManagedComponentVersion({
    required this.id,
    required this.version,
    required this.semver,
    required this.definition,
    this.contract = const ManagedComponentContract(),
    this.minSdk = '',
    this.changelog = '',
    this.digest = '',
    this.payload,
    this.createdAt,
    this.extra = const {},
  });

  /// The managed component's id.
  final String id;

  /// The version number (the document id): 1, 2, 3… in release order.
  final int version;
  final String semver;
  final ComponentDefinition definition;
  final ManagedComponentContract contract;

  /// The oldest SDK that can render it; empty for any.
  final String minSdk;
  final String changelog;

  /// The sha256 hex digest of [payload]'s UTF-8 bytes.
  final String digest;

  /// The stored payload text, when it was read from one.
  final String? payload;
  final int? createdAt;
  final Json extra;

  int get major => Semver.tryParse(semver)?.major ?? 0;

  /// The payload text for [definition] and [contract]: what a release
  /// stores and digests.
  static String encodePayload(ComponentDefinition definition, ManagedComponentContract contract) =>
      jsonEncode({'definition': definition.toJson(), 'contract': contract.toJson()});

  static const _keys = {
    'schema', 'id', 'version', 'semver', 'minSdk', 'payload', 'definition', 'contract', 'digest', 'changelog', //
    'createdAt',
  };

  /// Null without an id, a version number, or a definition with a root.
  static ManagedComponentVersion? fromJson(Object? json, {String? id, int? version}) {
    final m = readMap(json);
    if (m == null) return null;
    final cid = id ?? readString(m['id']);
    final n = version ?? readInt(m['version']);
    if (cid == null || cid.isEmpty || n == null) return null;
    final payload = readString(m['payload']);
    Json body = m;
    if (payload != null) {
      try {
        body = readMap(jsonDecode(payload)) ?? const {};
      } catch (_) {
        return null;
      }
    }
    final definition = ComponentDefinition.fromJson({...?readMap(body['definition']), 'id': cid});
    if (definition == null || definition.rootId == null) return null;
    return ManagedComponentVersion(
      id: cid,
      version: n,
      semver: readString(m['semver']) ?? '',
      definition: definition,
      contract: ManagedComponentContract.fromJson(body['contract']),
      minSdk: readString(m['minSdk']) ?? '',
      changelog: readString(m['changelog']) ?? '',
      digest: readString(m['digest']) ?? '',
      payload: payload,
      createdAt: readInt(m['createdAt']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  /// As stored, with [payload] (or one encoded now) as the body.
  Json toJson() => {
    'schema': kSchemaVersion,
    'id': id,
    'version': version,
    'semver': semver,
    if (minSdk.isNotEmpty) 'minSdk': minSdk,
    'payload': payload ?? encodePayload(definition, contract),
    if (digest.isNotEmpty) 'digest': digest,
    if (changelog.isNotEmpty) 'changelog': changelog,
    'createdAt': ?createdAt,
    ...extra,
  };
}

/// What a master knows of one of its versions, without its nodes.
@immutable
final class ManagedVersionInfo {
  const ManagedVersionInfo({required this.semver, this.minSdk = '', this.createdAt});

  final String semver, minSdk;
  final int? createdAt;

  int get major => Semver.tryParse(semver)?.major ?? 0;

  static ManagedVersionInfo? fromJson(Object? json) {
    final m = readMap(json);
    final semver = readString(m?['semver']);
    if (m == null || semver == null) return null;
    return ManagedVersionInfo(
      semver: semver,
      minSdk: readString(m['minSdk']) ?? '',
      createdAt: readInt(m['createdAt']),
    );
  }

  Json toJson() => {'semver': semver, if (minSdk.isNotEmpty) 'minSdk': minSdk, 'createdAt': ?createdAt};
}

/// A staged release: [version] goes to the projects of [channel] whose
/// rollout bucket ([managedRolloutBucket]) is below [percent].
@immutable
final class ManagedRollout {
  const ManagedRollout({this.channel = ManagedChannel.stable, required this.version, required this.percent});

  final ManagedChannel channel;
  final int version;

  /// 0..100.
  final int percent;

  static ManagedRollout? fromJson(Object? json) {
    final m = readMap(json);
    final v = readInt(m?['version']);
    if (m == null || v == null) return null;
    return ManagedRollout(
      channel: readEnum(ManagedChannel.values, m['channel'], ManagedChannel.stable),
      version: v,
      percent: (readInt(m['percent']) ?? 0).clamp(0, 100),
    );
  }

  Json toJson() => {'channel': channel.name, 'version': version, 'percent': percent};
}

/// A managed component (`managed_components/{id}`): its versions, what each
/// channel offers per major, staged rollouts and blocked versions.
///
/// JSON: `{"name": "Sign in", "description": "…", "category": "Accounts",
/// "feature": "auth.signIn", "versions": {"1": {"semver": "1.0.0",
/// "minSdk": "22.0.0", "createdAt": ms}}, "channels": {"stable": {"1": 1},
/// "beta": {"1": 2}}, "rollouts": [{"channel": "stable", "version": 2,
/// "percent": 10}], "blocked": [3], "latest": 3, "updatedAt": ms}`; a
/// channel maps each major (as text) to a version number.
@immutable
final class ManagedComponentMaster {
  const ManagedComponentMaster({
    required this.id,
    this.name = '',
    this.description = '',
    this.category = '',
    this.feature = '',
    this.versions = const {},
    this.channels = const {},
    this.rollouts = const [],
    this.blocked = const {},
    this.previewUrl,
    this.extra = const {},
  });

  final String id, name, description, category, feature;

  /// Every version, by number.
  final Map<int, ManagedVersionInfo> versions;

  /// Channel → major → version number.
  final Map<ManagedChannel, Map<int, int>> channels;
  final List<ManagedRollout> rollouts;

  /// Versions no app may show (rolled back): skipped by resolution, and an
  /// instance whose snapshot is blocked moves to the channel's version.
  final Set<int> blocked;
  final String? previewUrl;
  final Json extra;

  /// The newest version number, or 0.
  int get latest => versions.keys.fold(0, (a, b) => a > b ? a : b);

  /// The version channel [channel] offers for [major] to project
  /// [projectId] on an SDK at [sdkVersion]: its pointer, raised by
  /// rollouts the project's bucket is in, then the newest version at or
  /// below that of the same major that isn't blocked and the SDK can run.
  /// A beta channel takes stable's too. Null when there is none.
  int? resolve({
    required int major,
    ManagedChannel channel = ManagedChannel.stable,
    String projectId = '',
    String? sdkVersion,
  }) {
    final names = channel == ManagedChannel.beta ? const [ManagedChannel.stable, ManagedChannel.beta] : [channel];
    int? top;
    for (final c in names) {
      final p = channels[c]?[major];
      if (p != null && (top == null || p > top)) top = p;
    }
    final bucket = managedRolloutBucket(projectId, id);
    for (final r in rollouts) {
      if (!names.contains(r.channel) || versions[r.version]?.major != major) continue;
      if (bucket < r.percent && (top == null || r.version > top)) top = r.version;
    }
    if (top == null) return null;
    int? best;
    for (final e in versions.entries) {
      final n = e.key;
      if (n > top || e.value.major != major || blocked.contains(n)) continue;
      if (!sdkSatisfies(sdkVersion, e.value.minSdk)) continue;
      if (best == null || n > best) best = n;
    }
    return best;
  }

  /// The version of the newest major above [major] that [channel] offers
  /// (for "Update available"); null when there's none.
  int? newerMajor(
    int major, {
    ManagedChannel channel = ManagedChannel.stable,
    String projectId = '',
    String? sdkVersion,
  }) {
    final majors = {for (final c in channels.values) ...c.keys}.where((m) => m > major).toList()..sort();
    for (final m in majors.reversed) {
      final n = resolve(major: m, channel: channel, projectId: projectId, sdkVersion: sdkVersion);
      if (n != null) return n;
    }
    return null;
  }

  static const _keys = {
    'id', 'name', 'description', 'category', 'feature', 'versions', 'channels', 'rollouts', 'blocked', 'preview', //
  };

  /// Null without an id.
  static ManagedComponentMaster? fromJson(Object? json, {String? id}) {
    final m = readMap(json);
    final cid = id ?? readString(m?['id']);
    if (m == null || cid == null || cid.isEmpty) return null;
    return ManagedComponentMaster(
      id: cid,
      name: readString(m['name']) ?? '',
      description: readString(m['description']) ?? '',
      category: readString(m['category']) ?? '',
      feature: readString(m['feature']) ?? '',
      versions: {
        for (final e in (readMap(m['versions']) ?? const {}).entries)
          if ((int.tryParse(e.key), ManagedVersionInfo.fromJson(e.value)) case (
            final int n,
            final ManagedVersionInfo i,
          ))
            n: i,
      },
      channels: {
        for (final e in (readMap(m['channels']) ?? const {}).entries)
          if (ManagedChannel.values.where((c) => c.name == e.key).firstOrNull case final ManagedChannel c)
            c: {
              for (final p in (readMap(e.value) ?? const {}).entries)
                if ((int.tryParse(p.key), readInt(p.value)) case (final int major, final int n)) major: n,
            },
      },
      rollouts: [...?readList(m['rollouts'])?.map(ManagedRollout.fromJson).nonNulls],
      blocked: {...?readList(m['blocked'])?.map(readInt).nonNulls},
      previewUrl: readString(readMap(m['preview'])?['url']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    'id': id,
    if (name.isNotEmpty) 'name': name,
    if (description.isNotEmpty) 'description': description,
    if (category.isNotEmpty) 'category': category,
    if (feature.isNotEmpty) 'feature': feature,
    'versions': {for (final e in versions.entries) '${e.key}': e.value.toJson()},
    'channels': {
      for (final e in channels.entries) e.key.name: {for (final p in e.value.entries) '${p.key}': p.value},
    },
    if (rollouts.isNotEmpty) 'rollouts': [for (final r in rollouts) r.toJson()],
    if (blocked.isNotEmpty) 'blocked': [...blocked]..sort(),
    if (previewUrl != null) 'preview': {'url': previewUrl},
    ...extra,
  };
}

/// The version instance [link] should show now instead of its snapshot
/// (version [ComponentLink.version]), by [master]; null to keep the
/// snapshot.
///
/// * A pinned instance keeps its snapshot.
/// * Only the snapshot's major is considered: a new major never applies.
/// * A newer version the channel offers ([ManagedComponentMaster.resolve])
///   applies; an older one only when the snapshot is blocked (rollback).
int? managedUpdateTarget(
  ComponentLink link,
  ManagedComponentMaster master, {
  String projectId = '',
  String? sdkVersion,
}) {
  final ref = link.managed;
  if (ref == null || ref.pin != null) return null;
  final snapshot = link.version;
  final semver = ref.semver.isNotEmpty ? ref.semver : master.versions[snapshot]?.semver;
  final major = Semver.tryParse(semver)?.major;
  if (major == null) return null;
  final target = master.resolve(major: major, channel: ref.channel, projectId: projectId, sdkVersion: sdkVersion);
  if (target == null || target == snapshot) return null;
  if (target > snapshot || master.blocked.contains(snapshot)) return target;
  return null;
}

// --- building an instance --------------------------------------------------------------

/// The id an instance with top node [topId] gives the version's node
/// [nodeId]: stable across versions while the master keeps its node ids.
String managedNodeId(String topId, String nodeId) => '${topId}__$nodeId';

/// An instance's nodes built from a version, and the variables they need.
@immutable
final class ManagedBuild {
  const ManagedBuild({required this.nodes, this.variables = const []});

  /// The top node first (its id the instance's), then the rest.
  final List<Node> nodes;

  /// The contract's variables, to declare on the canvas.
  final List<Variable> variables;
}

final RegExp _themeBind = RegExp(r'^\$\{\s*theme\.([A-Za-z0-9_]+)\s*\}$');

/// Instance [topId]'s nodes built from [version] with [ref] applied:
///
/// * node ids derived from [topId] ([managedNodeId]; the top keeps
///   [topId]), every reference to them renamed;
/// * the setting values in [ComponentLink.managed] written to their targets
///   by key;
/// * theme bindings (`${theme.primary}`) replaced by the instance's token,
///   else [theme]'s, else the version's own value;
/// * each slot node's children replaced by the instance's slot content
///   (those nodes are the page's, not built here);
/// * each event placeholder ([kComponentEventAction]) replaced by the
///   instance's chain for it (or removed);
/// * the top node linked to the version with [ref], placed with [layout]
///   (the instance's own place and size) when given.
ManagedBuild buildManagedInstance({
  required ManagedComponentVersion version,
  required String topId,
  ManagedComponentRef ref = const ManagedComponentRef(),
  Layout? layout,
  ThemeTokens? theme,
}) {
  final def = version.definition;
  final root = def.rootId!;
  final source = def.document.toJson();
  final raw = readMap(source['nodes']) ?? const {};
  final ids = {for (final id in raw.keys) id: id == root ? topId : managedNodeId(topId, id)};
  Object? rename(Object? v) => switch (v) {
    final String s when ids.containsKey(s) => ids[s],
    final List<Object?> l => [for (final x in l) rename(x)],
    final Map<Object?, Object?> m => {for (final e in m.entries) (ids[e.key] ?? e.key): rename(e.value)},
    _ => v,
  };
  final eventJson = {
    for (final e in ref.events.entries) e.key: [for (final a in e.value) a.toJson()],
  };
  Object? splice(Object? v) {
    if (v is List) {
      return [
        for (final x in v)
          if (readMap(x) case final Json m when m['type'] == kComponentEventAction)
            ...?eventJson[readString(m['event'])]
          else
            splice(x),
      ];
    }
    if (v is Map) return {for (final e in v.entries) '${e.key}': splice(e.value)};
    return v;
  }

  final nodes = <String, Node>{};
  for (final id in [root, ...raw.keys.where((k) => k != root)]) {
    final json = readMap(rename(raw[id]));
    if (json == null) continue;
    if (json['actions'] != null) json['actions'] = splice(json['actions']);
    final n = Node.fromJson(json, id: ids[id]);
    if (n != null) nodes[n.id] = n;
  }

  // Settings, by key.
  for (final s in version.contract.flatSettings) {
    final key = s.effectiveKey;
    if (!ref.values.containsKey(key)) continue;
    final value = ref.values[key];
    for (final t in s.targets) {
      final id = ids[t.node] ?? t.node, path = t.path;
      final n = nodes[id];
      if (n == null || path == null) continue;
      nodes[id] = BindPaths.apply(n, path, value);
    }
  }

  // Theme tokens.
  final projectTokens = theme?.toJson() ?? const {};
  for (final id in [...nodes.keys]) {
    final n = nodes[id]!;
    if (n.bind.isEmpty) continue;
    var out = n;
    final bind = {...n.bind};
    for (final e in n.bind.entries) {
      final token = _themeBind.firstMatch(e.value)?[1];
      if (token == null) continue;
      bind.remove(e.key);
      final value = ref.tokens[token] ?? projectTokens[token];
      if (value != null) out = BindPaths.apply(out, e.key, value);
    }
    if (bind.length != n.bind.length) nodes[id] = out.copyWith(bind: bind);
  }

  // Slots.
  for (final slot in version.contract.slots) {
    final content = ref.slots[slot.key];
    final id = ids[slot.node];
    final n = id == null ? null : nodes[id];
    if (content == null || content.isEmpty || n == null) continue;
    // The version's default content of the slot goes.
    final drop = <String>{};
    void collect(String c) {
      if (!drop.add(c)) return;
      for (final cc in nodes[c]?.childIds ?? const <String>[]) {
        collect(cc);
      }
    }

    for (final c in n.children) {
      collect(c);
    }
    nodes.removeWhere((k, _) => drop.contains(k));
    nodes[n.id] = n.copyWith(children: content);
  }

  final top = nodes[topId]!;
  nodes[topId] = Node.fromJson({...top.toJson(), if (layout != null) 'layout': layout.toJson()}, id: topId)!
      .withComponent(
        ComponentLink(
          id: version.id,
          version: version.version,
          managed: ref.copyWith(semver: version.semver, digest: version.digest),
        ),
      );
  return ManagedBuild(
    nodes: [nodes[topId]!, ...nodes.values.where((n) => n.id != topId)],
    variables: version.contract.variables,
  );
}

/// [document] with managed instance [topId] replaced by [build]: the
/// instance's old nodes go, except its slots' content (the page's own
/// nodes), and [build]'s come in. The top node keeps its id and its place.
LayoutDocument replaceManagedInstance(LayoutDocument document, String topId, ManagedBuild build) {
  final old = document[topId];
  if (old == null) return document;
  final keep = <String>{};
  void collect(String id) {
    if (!keep.add(id)) return;
    for (final c in document[id]?.childIds ?? const <String>[]) {
      collect(c);
    }
  }

  for (final id in old.component?.managed?.slotNodeIds ?? const <String>[]) {
    collect(id);
  }
  final drop = {...document.subtree(topId).map((n) => n.id)}..removeAll(keep);
  return document.copyWith(
    nodes: {
      for (final e in document.nodes.entries)
        if (!drop.contains(e.key)) e.key: e.value,
      for (final n in build.nodes) n.id: n,
    },
  );
}

/// The managed instances of [document]: their top nodes.
Iterable<Node> managedInstancesOf(LayoutDocument document) =>
    document.nodes.values.where((n) => n.component?.isManaged ?? false);

// --- the publish snapshot ------------------------------------------------------------

/// What a publish recorded of one managed instance in a layout
/// (`PublishLayout.extra.managed`, by the instance's top node id): the
/// version its nodes (the snapshot) were built from.
///
/// JSON: `{"id": "sign_in", "version": 3, "semver": "1.1.0", "channel":
/// "stable", "pin": 3, "digest": "…"}`.
@immutable
final class ManagedSnapshot {
  const ManagedSnapshot({
    required this.id,
    required this.version,
    this.semver = '',
    this.channel = ManagedChannel.stable,
    this.pin,
    this.digest = '',
  });

  /// [top]'s snapshot, or null when it isn't a managed instance.
  static ManagedSnapshot? of(Node top) {
    final link = top.component;
    final ref = link?.managed;
    if (link == null || ref == null || !link.isInstance) return null;
    return ManagedSnapshot(
      id: link.id,
      version: link.version,
      semver: ref.semver,
      channel: ref.channel,
      pin: ref.pin,
      digest: ref.digest,
    );
  }

  final String id;
  final int version;
  final String semver;
  final ManagedChannel channel;
  final int? pin;
  final String digest;

  static ManagedSnapshot? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']), version = readInt(m?['version']);
    if (m == null || id == null || version == null) return null;
    return ManagedSnapshot(
      id: id,
      version: version,
      semver: readString(m['semver']) ?? '',
      channel: readEnum(ManagedChannel.values, m['channel'], ManagedChannel.stable),
      pin: readInt(m['pin']),
      digest: readString(m['digest']) ?? '',
    );
  }

  Json toJson() => {
    'id': id,
    'version': version,
    if (semver.isNotEmpty) 'semver': semver,
    'channel': channel.name,
    'pin': ?pin,
    if (digest.isNotEmpty) 'digest': digest,
  };

  @override
  bool operator ==(Object other) => other is ManagedSnapshot && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}

/// A layout's managed instances as published ([PublishLayout.extra]'s
/// `managed`).
extension PublishLayoutManaged on PublishLayout {
  /// The key in [PublishLayout.extra].
  static const String key = 'managed';

  /// Instance top node id → its snapshot.
  Map<String, ManagedSnapshot> get managedSnapshots => {
    for (final e in (readMap(extra[key]) ?? const {}).entries)
      if (ManagedSnapshot.fromJson(e.value) case final ManagedSnapshot s) e.key: s,
  };

  /// This layout with its `managed` index rebuilt from its nodes (what the
  /// editor's publish writes); without one when it has no managed instance.
  PublishLayout withManagedSnapshots() {
    final index = {
      for (final n in managedInstancesOf(document))
        if (ManagedSnapshot.of(n) case final ManagedSnapshot s) n.id: s.toJson(),
    };
    return copyWith(
      extra: {
        for (final e in extra.entries)
          if (e.key != key) e.key: e.value,
        if (index.isNotEmpty) key: index,
      },
    );
  }
}
