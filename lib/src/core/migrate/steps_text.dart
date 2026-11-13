// Steps for text: what a schema-2 text did with its fields, written out so
// the schema-3 reading (Flutter's) gives the same text.
import '../behavior_fields.dart';
import '../catalog.dart';
import '../json.dart';
import '../props.dart';
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

/// Schema 2's base line height: what a text style with no `height` (and no
/// `naturalHeight`) was drawn at.
const double schema2LineHeight = 1.33;

/// Calls [visit] with every TextStyle value in [json], a value of [type]
/// (a map, or a theme style's name as a string), and its JSON pointer.
void _eachTextStyle(PropType type, Object? json, String at, void Function(Object style, String at, void Function(Object) replace) visit,
    void Function(Object) replace) {
  if (json == null) return;
  switch (type.kind) {
    case PropKind.object when type.name == 'TextStyle':
      if (json is Map || json is String) visit(json, at, replace);
    case PropKind.object:
      final m = readMap(json);
      if (m == null) return;
      for (final d in type.fields) {
        if (!m.containsKey(d.key)) continue;
        _eachTextStyle(d.type, m[d.key], '$at/${d.key}', visit, (v) => m[d.key] = v);
      }
    case PropKind.list:
      if (json is! List) return;
      for (var i = 0; i < json.length; i++) {
        _eachTextStyle(type.item!, json[i], '$at/$i', visit, (v) => json[i] = v);
      }
    default:
  }
}

/// Every TextStyle value of node (or patch) JSON [n] of [nodeType], by its
/// declarations: its props, and its behaviors (a typewriter's caret style,
/// a painter's text).
void eachTextStyleOf(Json n, String? nodeType, void Function(Object style, String at, void Function(Object) replace) visit,
    {String at = ''}) {
  final props = readMap(n['props']);
  final spec = nodeType == null ? null : Catalog.current.widget(nodeType);
  if (props != null && spec != null) {
    for (final d in spec.props) {
      if (props.containsKey(d.key)) _eachTextStyle(d.type, props[d.key], '$at/props/${d.key}', visit, (v) => props[d.key] = v);
    }
  }
  for (final d in BehaviorFields.all) {
    if (d.key == BehaviorFields.states.key || d.key == BehaviorFields.defaultTextStyle.key || !n.containsKey(d.key)) continue;
    _eachTextStyle(d.type, n[d.key], '$at/${d.key}', visit, (v) => n[d.key] = v);
  }
}

/// The ids of [nodes] no other node holds as a child or in a slot: where a
/// tree starts (a canvas, a dialog, a component's root, a drag feedback).
Set<String> topLevelIds(Json nodes) {
  final held = <String>{};
  for (final v in nodes.values) {
    final n = readMap(v);
    if (n == null) continue;
    held.addAll(readStrings(n['children']));
    for (final s in (readMap(n['slots']) ?? const <String, Object?>{}).values) {
      if (s is String) held.add(s);
      if (s is List) held.addAll(s.whereType<String>());
    }
  }
  return {for (final k in nodes.keys) if (!held.contains(k)) k};
}

/// Schema 3 draws a text style with no `height` at the font's own line
/// height (Flutter's `height: null`); schema 2 drew it at 1.33 unless the
/// style said `naturalHeight` (or the project's theme `naturalLineHeight`).
/// The migration keeps schema 2's line height with one
/// `"defaultTextStyle": {"height": 1.33}` (Flutter's `DefaultTextStyle`) on
/// each top-level node of the document: every text style below inherits
/// it, the ones that state a height keep theirs, and a theme style's own
/// height still wins (it merges over the default). `naturalHeight` is
/// removed: a node with a style that asked for it gets
/// `"defaultTextStyle": {}` (the font's own height for that node), and its
/// other styles without a height get 1.33 written out. What can't be kept
/// exactly (a natural run beside 1.33 runs, a theme style named by a
/// natural node, a state or media patch switching it) is reported.
final textLineHeightStep = MigrationStep(
  id: 'text.lineHeight',
  description: 'schema 2\'s base line height (1.33) kept as the top-level nodes\' defaultTextStyle; naturalHeight removed',
  document: (doc, s) {
    final nodes = readMap(doc['nodes']);
    if (nodes == null) return;
    const instead = 'Remove the node\'s defaultTextStyle (or set "height" on the style) to choose.';
    bool natural(Object? style) => style is Map && style['naturalHeight'] == true && readDouble(style['height']) == null;

    for (final e in nodes.entries) {
      final node = readMap(e.value);
      if (node == null) continue;
      final at = '/nodes/${e.key}';
      final type = readString(node['type']);
      // Its styles: which asked for the font's own height.
      final styles = <(Object, String, void Function(Object))>[];
      eachTextStyleOf(node, type, (style, p, replace) => styles.add((style, p, replace)));
      final naturals = styles.where((x) => natural(x.$1)).toList();
      if (naturals.isNotEmpty) {
        node['defaultTextStyle'] = <String, Object?>{};
        s.rewrite('$at/defaultTextStyle', null, const <String, Object?>{},
            'A style with naturalHeight: the node takes the font\'s own line height (defaultTextStyle: {}).');
        final base = type == 'text' ? (readMap(node['props'])?['style']) : null;
        for (final (style, p, replace) in styles) {
          if (natural(style)) continue;
          final m = readMap(style);
          if (m != null && readDouble(m['height']) != null) continue;
          if (m != null && m['from'] == null && m['naturalHeight'] == null) {
            // A run of a natural text with no height merged over its base.
            if (type == 'text' && p.contains('/runs/') && natural(base)) continue;
            if (type == 'text' && p.contains('/runs/') && m.isEmpty) continue;
            m['height'] = schema2LineHeight;
            replace(m);
            s.rewrite('$p/height', null, schema2LineHeight, 'Schema 2\'s line height written out beside a natural style.');
          } else if (m == null || m['naturalHeight'] != false) {
            s.behaviourChange('A style beside a naturalHeight style takes its theme style\'s line height, or the font\'s own (was 1.33).',
                path: p, old: style, instead: instead);
          }
        }
        if (type == 'text' && !natural(base) && naturals.any((x) => x.$2.contains('/runs/'))) {
          s.behaviourChange('A run with naturalHeight in a text whose style has none is drawn at its text\'s line height (1.33).',
              path: '$at/props/runs', instead: 'Give the text one line height for all its runs.');
        }
        // A widget's text styles it does not set (drawn from the base
        // style) take the font's own height under the node's {} too.
        final props = readMap(node['props']) ?? const <String, Object?>{};
        final unset = [
          for (final d in type == null || type == 'text' ? const <PropDef<Object?>>[] : Catalog.current.widget(type)?.props ?? const [])
            if (d.type.name == 'TextStyle' && !props.containsKey(d.key)) d.key,
        ];
        if (unset.isNotEmpty) {
          s.behaviourChange('The text styles this node leaves unset (${unset.join(', ')}) take the font\'s own line height beside its naturalHeight style (was 1.33).',
              path: '$at/defaultTextStyle', instead: 'Set "height": 1.33 on those styles.');
        }
      }
      // naturalHeight is gone from every style.
      for (final (style, p, replace) in styles) {
        if (style is! Map || !style.containsKey('naturalHeight')) continue;
        final m = readMap(style)!;
        s.rewrite('$p/naturalHeight', m.remove('naturalHeight'), null);
        replace(m);
      }
      // Patches and bindings that set it: no schema-3 form.
      for (final st in (readMap(node['states']) ?? const <String, Object?>{}).entries) {
        for (final p in (readMap(st.value) ?? const <String, Object?>{}).entries) {
          final patch = readMap(p.value);
          if (patch != null) _stripPatch(patch, readString(readMap(nodes[p.key])?['type']), '$at/states/${st.key}/${p.key}', s);
        }
      }
      final media = readList(node['media']);
      for (var i = 0; i < (media?.length ?? 0); i++) {
        final patch = readMap(readMap(media![i])?['patch']);
        if (patch != null) _stripPatch(patch, type, '$at/media/$i/patch', s);
      }
      final bind = bindOf(node);
      final dropped = [for (final k in bind.keys) if (k.endsWith('.naturalHeight')) k];
      if (dropped.isNotEmpty) {
        for (final k in dropped) {
          s.behaviourChange('A binding of naturalHeight no longer acts (naturalHeight is gone).', path: '$at/bind/$k', old: bind[k], instead: instead);
        }
        putBind(node, {...bind}..removeWhere((k, _) => dropped.contains(k)), MigrationScope.silent(s.step));
      }
    }
    // Schema 2's base line height for everything below the top-level nodes.
    for (final id in topLevelIds(nodes)) {
      final node = readMap(nodes[id]);
      if (node == null || node.containsKey('defaultTextStyle')) continue;
      node['defaultTextStyle'] = <String, Object?>{'height': schema2LineHeight};
      s.rewrite('/nodes/$id/defaultTextStyle', null, node['defaultTextStyle'],
          'Schema 2\'s base line height (1.33) for the text below; schema 3\'s is the font\'s own.');
    }
  },
);

void _stripPatch(Json patch, String? type, String at, MigrationScope s) {
  eachTextStyleOf(patch, type, (style, p, replace) {
    if (style is! Map || !style.containsKey('naturalHeight')) return;
    final m = readMap(style)!;
    final v = m.remove('naturalHeight');
    replace(m);
    if (v == true && readDouble(m['height']) == null) {
      s.behaviourChange('A patch that asked for the font\'s own line height (naturalHeight) no longer does.',
          path: '$p/naturalHeight', old: v, instead: 'Patch "defaultTextStyle": {} on the node instead.');
    } else {
      s.rewrite('$p/naturalHeight', v, null);
    }
  }, at: at);
}
