// Steps for text: what a schema-2 text did with its fields, written out so
// the schema-3 reading (Flutter's) gives the same text.
import '../json.dart';
import 'legacy_read.dart';
import 'migrate.dart';

bool _isText(Object? node) => readMap(node)?['type'] == 'text';

/// Whether a `bind` key addresses a layout's padding.
bool _isPaddingPath(String k) => k == 'layout.padding' || k.startsWith('layout.padding.') || k.startsWith('layout.padding[');

/// A text's `layout.padding` dropped: schema 2 did not apply it (the
/// editor's text has no box of its own, so the SDK drew the lines at the
/// node's edge and a hugging text did not grow by it); schema 3 applies it
/// as Flutter's `Padding(child: Text)`. Dropped from the text's own layout,
/// its `layout.padding` bindings, the interaction-state patches that target
/// it (from any node) and its media patches. Each is a rewrite: it did
/// nothing before, and dropped it does nothing now.
final textPaddingStep = MigrationStep(
  id: 'text.padding',
  description: 'a text\'s layout.padding dropped (schema 2 did not apply it; schema 3 does, as Padding(child: Text))',
  document: (doc, s) {
    final nodes = readMap(doc['nodes']);
    if (nodes == null) return;
    const message = 'A text\'s layout.padding had no effect in schema 2 (schema 3 applies it): dropped.';

    /// Drops `layout.padding` from [patch] (a node or a patch of one) at
    /// [at]; true when it held one.
    bool strip(Json patch, String at) {
      final layout = readMap(patch['layout']);
      if (layout == null || !layout.containsKey('padding')) return false;
      s.rewrite('$at/layout/padding', layout.remove('padding'), null, message);
      // A patch left with nothing to change in the layout drops it.
      if (layout.isEmpty && (at.contains('/states/') || at.contains('/media/'))) {
        patch.remove('layout');
      } else {
        patch['layout'] = layout;
      }
      return true;
    }

    for (final e in nodes.entries) {
      final node = readMap(e.value);
      if (node == null) continue;
      final text = _isText(node);
      final at = '/nodes/${e.key}';
      if (text) {
        strip(node, at);
        final bind = bindOf(node);
        final kept = {...bind}..removeWhere((k, _) => _isPaddingPath(k));
        if (kept.length != bind.length) {
          for (final k in bind.keys.where(_isPaddingPath)) {
            s.rewrite('$at/bind/$k', bind[k], null, message);
          }
          putBind(node, kept, MigrationScope.silent(s.step));
        }
        final media = readList(node['media']);
        for (var i = 0; i < (media?.length ?? 0); i++) {
          final rule = readMap(media![i]);
          final patch = readMap(rule?['patch']);
          if (rule == null || patch == null) continue;
          if (strip(patch, '$at/media/$i/patch')) {
            rule['patch'] = patch;
            media[i] = rule;
          }
          final pb = readMap(patch['bind']);
          if (pb != null && pb.keys.any(_isPaddingPath)) {
            for (final k in pb.keys.where(_isPaddingPath).toList()) {
              s.rewrite('$at/media/$i/patch/bind/$k', pb.remove(k), null, message);
            }
            if (pb.isEmpty) {
              patch.remove('bind');
            } else {
              patch['bind'] = pb;
            }
          }
        }
        if (media != null) node['media'] = media;
      }
      // Interaction states: state → {target id → patch of that node}.
      final states = readMap(node['states']);
      if (states == null) continue;
      var changed = false;
      for (final st in states.entries) {
        final per = readMap(st.value);
        if (per == null) continue;
        for (final p in per.entries) {
          final patch = readMap(p.value);
          if (patch == null || !_isText(nodes[p.key])) continue;
          if (strip(patch, '$at/states/${st.key}/${p.key}')) {
            per[p.key] = patch;
            states[st.key] = per;
            changed = true;
          }
        }
      }
      if (changed) node['states'] = states;
    }
  },
);
