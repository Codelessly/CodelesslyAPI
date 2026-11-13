// A hint for authors (an AI agent above all): a document that writes the same
// subtree several times over, node for node, is a component (or a list
// template) waiting to be made (docs/design/06 §8.4). Reported as an INFO, and
// only for exact repeats: the subtrees are equal in everything but their
// nodes' ids and editor names, so the hint is never wrong about what repeats.
import '../core/json.dart';
import '../core/sections.dart' show canonicalJson;
import 'diagnostic.dart';

/// The smallest subtree worth a hint, in nodes.
const int kRepeatedSubtreeMinNodes = 3;

/// One INFO per group of exactly repeated subtrees in [nodes] (a document's
/// `nodes` JSON) of at least [kRepeatedSubtreeMinNodes] nodes, the largest
/// first: a group inside a repeat already reported is not reported again.
List<Diagnostic> repeatedSubtrees(Json nodes) {
  final shapes = <String, String>{};
  final sizes = <String, int>{};
  final visiting = <String>{};

  // A node's shape: its JSON without id and name, its children and slots by
  // their own shapes. Null inside a cycle or for a missing node (no hint).
  String? shapeOf(String id) {
    final done = shapes[id];
    if (done != null) return done;
    final n = readMap(nodes[id]);
    if (n == null || !visiting.add(id)) return null;
    try {
      var size = 1;
      final children = <String>[];
      for (final c in readList(n['children']) ?? const []) {
        final s = c is String ? shapeOf(c) : null;
        if (s == null) return null;
        children.add(s);
        size += sizes[c]!;
      }
      final slots = <String, String>{};
      for (final e in (readMap(n['slots']) ?? const {}).entries) {
        final s = e.value is String ? shapeOf(e.value as String) : null;
        if (s == null) return null;
        slots[e.key] = s;
        size += sizes[e.value as String]!;
      }
      final own = {
        for (final e in n.entries)
          if (!const {'id', 'name', 'children', 'slots'}.contains(e.key)) e.key: e.value,
      };
      sizes[id] = size;
      return shapes[id] = canonicalJson({'node': own, 'children': children, 'slots': slots});
    } finally {
      visiting.remove(id);
    }
  }

  final groups = <String, List<String>>{};
  for (final id in nodes.keys) {
    final s = shapeOf(id);
    if (s == null || sizes[id]! < kRepeatedSubtreeMinNodes) continue;
    (groups[s] ??= []).add(id);
  }
  final repeats = [
    for (final g in groups.values)
      if (g.length > 1) g,
  ]..sort((a, b) => sizes[b.first]!.compareTo(sizes[a.first]!));
  if (repeats.isEmpty) return const [];

  // Every node inside a reported repeat.
  final covered = <String>{};
  void cover(String id) {
    if (!covered.add(id)) return;
    final n = readMap(nodes[id]);
    for (final c in readList(n?['children']) ?? const []) {
      if (c is String) cover(c);
    }
    for (final c in (readMap(n?['slots']) ?? const {}).values) {
      if (c is String) cover(c);
    }
  }

  final out = <Diagnostic>[];
  for (final g in repeats) {
    if (g.every(covered.contains)) continue;
    final shown = g.length > 5 ? [...g.take(5), '...'] : g;
    out.add(Diagnostic(
      Codes.repeatedSubtree,
      pointer('/nodes', g.first),
      'The subtree at "${g.first}" (${sizes[g.first]} nodes) is written ${g.length} times, node for node '
      '(${shown.join(', ')}): consider a component (one definition, one call per use) or, for repeats of one '
      'shape from data, a list template.',
      nodeId: g.first,
    ));
    for (final id in g) {
      cover(id);
    }
  }
  return out;
}
