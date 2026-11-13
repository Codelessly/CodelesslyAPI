// The outline: how an agent reads a document before it edits it. One line
// per node, in tree order (docs/design/08-ai-developer-experience.md §3.6),
// a fraction of the document's size; `ui_read` returns whole nodes by id.
import '../document.dart';
import '../json.dart';
import '../node.dart';
import '../catalog.dart';
import 'apply.dart' show pendingIds;
import 'starter.dart' show describeTypes;

/// The outline of [document]: `{"rev": rev, "outline": [[id, type, label,
/// depth, extras?], ...], "pending": [...]}`. The label is the node's name,
/// else the first [labelLength] characters of its text; extras list what
/// is bound (`"bind": ["props.text"]`), its interaction states, its
/// reactions' triggers and its media rules. Nodes under no root follow,
/// at depth -1.
Json outline(LayoutDocument document, {int rev = 0, int labelLength = 40}) {
  final rows = <List<Object?>>[];
  final seen = <String>{};
  void visit(String id, int depth) {
    final n = document[id];
    if (n == null || !seen.add(id)) return;
    rows.add(outlineRow(n, depth, labelLength: labelLength));
    for (final c in n.childIds) {
      visit(c, depth + 1);
    }
  }

  for (final r in document.roots) {
    visit(r, 0);
  }
  for (final id in document.nodes.keys) {
    if (!seen.contains(id) && document.parentOf(id) == null) visit(id, -1);
  }
  final pending = pendingIds(document);
  return {
    'rev': rev,
    'outline': rows,
    if (pending.isNotEmpty) 'pending': [...pending],
  };
}

/// One outline line: id, type, label, depth, and extras when there are any.
List<Object?> outlineRow(Node n, int depth, {int labelLength = 40}) {
  var label = n.name;
  if (label.isEmpty) {
    final text = n.props.toJson(n.spec)['text'];
    if (text is String) label = text.length > labelLength ? '${text.substring(0, labelLength)}…' : text;
  }
  final behaviors = <String, Object?>{};
  n.behaviors.writeTo(behaviors);
  final states = readMap(behaviors['states']);
  final extras = <String, Object?>{
    if (n.bind.isNotEmpty) 'bind': [...n.bind.keys],
    if (states != null && states.isNotEmpty) 'states': [...states.keys],
    if (n.actions.isNotEmpty) 'on': [for (final r in n.actions) r.trigger.type.name],
    if (n.media.isNotEmpty) 'media': n.media.length,
    if (!n.visible) 'hidden': true,
  };
  return [n.id, n.type, label, depth, if (extras.isNotEmpty) extras];
}

/// Answers a `ui_read` tool call ([input]: `{"ids": [...], "outline": true}`):
/// the full nodes asked for (as the document holds them), missing ids,
/// and the outline when asked or when no ids are given.
Json readUi(LayoutDocument document, Object? input, {int rev = 0, Catalog? catalog}) {
  final m = readMap(input) ?? const {};
  final ids = readStrings(m['ids']);
  final types = readStrings(m['types']);
  final wantOutline = readBool(m['outline']) ?? (ids.isEmpty && types.isEmpty);
  final c = catalog ?? document.catalog ?? Catalog.current;
  return {
    'rev': rev,
    if (types.isNotEmpty) 'types': describeTypes(c, types),
    if (ids.isNotEmpty)
      'nodes': {
        for (final id in ids)
          if (document[id] case final Node n) id: n.toJson()..remove('id'),
      },
    if (ids.any((id) => document[id] == null)) 'missing': [for (final id in ids) if (document[id] == null) id],
    if (wantOutline) ...outline(document, rev: rev),
    if (m['variables'] == true || (ids.isEmpty && types.isEmpty)) 'variables': document.extra['variables'] ?? const {},
  };
}
