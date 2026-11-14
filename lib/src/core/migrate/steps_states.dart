// The targets of a node's interaction-state patches. A state patch names the
// node it patches by id (`states.hovered.<node id>`), as every schema has.
// Generators of the reference apps wrote two other spellings that no schema
// ever read: `self` (the node the states are on) and `@<key>` (a node's
// `key`, the handle an inserted tree names its nodes by before they have
// ids). The insert resolved `@key` where it was a value (an action's node)
// but not where it was a map key, so those patches matched no node and never
// ran. In the corpus every one of them names the node the states are on.
import '../behaviors.dart' show mergePatch;
import '../json.dart';
import 'migrate.dart';

/// The node id a state target [target] written on node [ownId] (key
/// [ownKey]) means, or null when it is an id already or names nothing:
/// `self` is the node itself; `@k` is the node whose `key` is `k` (the node
/// itself first, else the one node of [nodes] with that key).
String? stateTargetId(String target, {required String ownId, required String ownKey, Map<String, Object?>? nodes}) {
  if (nodes != null && nodes.containsKey(target)) return null;
  if (target == 'self') return ownId;
  if (!target.startsWith('@') || target.length < 2) return null;
  final key = target.substring(1);
  if (key == ownKey) return ownId;
  if (nodes == null) return null;
  final ids = [
    for (final e in nodes.entries)
      if (readMap(e.value)?['key'] == key) e.key,
  ];
  return ids.length == 1 ? ids.single : null;
}

/// `states.<state>.self` and `states.<state>.@<key>` → the node's id: the
/// patch runs (it never did; reported as a behaviour change). A target
/// that names no node by any spelling is left for validation to report.
final stateTargetsStep = MigrationStep(
  id: 'states.target',
  description: 'a state patch targeting `self` or `@<key>` → the node id it means',
  node: (n, s) {
    final states = readMap(n['states']);
    if (states == null) return;
    final nodes = readMap(s.document?['nodes']);
    final ownKey = readString(n['key']) ?? '';
    var changed = false;
    final rewritten = <String>[];
    final out = <String, Object?>{};
    for (final st in states.entries) {
      final per = readMap(st.value);
      if (per == null) {
        out[st.key] = st.value;
        continue;
      }
      final next = <String, Object?>{};
      // Patches by id first: a resolved spelling merges over them.
      final resolved = <String, Object?>{};
      for (final t in per.entries) {
        final id = stateTargetId(t.key, ownId: s.nodeId, ownKey: ownKey, nodes: nodes);
        if (id == null) {
          next[t.key] = t.value;
        } else {
          resolved[t.key] = id;
        }
      }
      for (final e in resolved.entries) {
        final id = e.value as String;
        final patch = per[e.key];
        final existing = readMap(next[id]);
        final p = readMap(patch);
        next[id] = existing != null && p != null ? mergePatch(existing, p, keepNulls: true) : patch;
        s.rewrite('/states/${st.key}/${e.key}', e.key, id, 'State target "${e.key}" → "$id" (targets are node ids).');
        rewritten.add('${st.key}.${e.key}');
        changed = true;
      }
      out[st.key] = next;
    }
    if (!changed) return;
    n['states'] = out;
    s.behaviourChange(
        'The ${rewritten.join(', ')} patch${rewritten.length == 1 ? '' : 'es'} now appl${rewritten.length == 1 ? 'ies' : 'y'}: '
        'its target matched no node, so it never ran.',
        path: '/states',
        instead: 'Remove the patch if the node should not change in that state.');
  },
);
