// Narrow layout rules for page notation. The source page stays at its
// authoring width; the renderer applies these media patches only below it.
import '../json.dart';

void reflowPage(
  Map<String, Json> nodes, {
  required Set<String> gridRows,
  required bool app,
}) {
  void rule(Json node, int maxWidth, Json patch) {
    final media =
        (node['media'] as List<Object?>?) ?? (node['media'] = <Object?>[]);
    media.add({'maxWidth': maxWidth, 'patch': patch});
  }

  for (final entry in nodes.entries) {
    final node = entry.value;
    final type = node['type'];
    if (type == 'gridView') {
      final count = (node['props'] as Map?)?['crossAxisCount'];
      if (count is num && count > 2)
        rule(node, 1023, {
          'props': {'crossAxisCount': 2},
        });
      if (count is num && count > 1)
        rule(node, 599, {
          'props': {'crossAxisCount': 1},
        });
      continue;
    }
    if (type != 'row') continue;
    final children =
        (node['children'] as List?)?.whereType<String>().toList() ??
        const <String>[];
    if (children.length < 2) continue;
    final isGrid = gridRows.contains(entry.key);
    final flexible = children
        .where((id) => (nodes[id]?['layout'] as Map?)?['flex'] != null)
        .toList();
    if (isGrid) {
      rule(node, 1023, {
        'props': {'wrap': true},
      });
      for (final id in flexible) {
        rule(nodes[id]!, 1023, {
          'layout': {'basis': 300},
        });
      }
    } else if (flexible.length >= 2) {
      rule(node, 1023, {
        'props': {'wrap': true},
      });
      for (final id in flexible) {
        rule(nodes[id]!, 1023, {
          'layout': {'basis': 500, 'flex': null},
        });
        rule(nodes[id]!, 599, {
          'layout': {'basis': 240},
        });
      }
    } else {
      rule(node, 1023, {
        'props': {'wrap': true},
      });
      if (!app && flexible.length == 1) {
        rule(nodes[flexible.single]!, 1023, {
          'layout': {'basis': 240},
        });
      }
    }
  }
}
