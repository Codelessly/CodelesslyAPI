// The core's check of the nodes an op touched, against a catalog's
// declarations alone: node types, node keys, props (keys and values),
// layout and decoration keys, children and slots, action types. It needs no
// feature library and no validator, so a core-only build (a renderer with
// the core catalog) can check agent ops. `strictEditCheck`
// (package:codelessly_api/validate.dart) runs the full strict validator
// instead.
import '../behaviors.dart';
import '../catalog.dart';
import '../json.dart';
import '../props.dart' show ChildModel;
import '../value_fields.dart';
import '../widgets/canvas.dart';
import 'apply.dart';
import 'diagnostics.dart';

/// The keys a node reads (beyond the behaviors).
const Set<String> editNodeKeys = {
  'type', 'name', 'key', 'children', 'slots', 'visible', 'opacity', 'layout', 'decoration', 'props', 'bind', //
  'actions', 'component', 'media',
};

/// An [EditCheck] over [EditCheckInput.catalog]'s declarations: unknown
/// node types, node keys, props, layout and decoration keys and action
/// types; prop values a declaration cannot read; children or slots a type
/// does not take. Codes as strict validation's.
List<EditDiagnostic> catalogCheck(EditCheckInput input) {
  final out = <EditDiagnostic>[];
  final catalog = input.catalog;
  final types = [for (final w in catalog.widgets) w.type];
  void add(String code, String path, String message, {String? nodeId, List<String>? expected, String? suggestion, bool error = true}) =>
      out.add(EditDiagnostic(
          op: input.op, code: code, error: error, path: path, message: message, nodeId: nodeId, expected: expected, suggestion: suggestion));

  for (final e in input.nodes.entries) {
    final id = e.key, json = e.value;
    final at = editPointer('/nodes', id);
    final type = readString(json['type']) ?? '';
    final spec = catalog.widget(type);
    if (spec == null) {
      add('unknown_node_type', editPointer(at, 'type'), '"$type" is not a node type here.',
          nodeId: id, expected: types, suggestion: nearestName(type, types));
    }
    for (final k in json.keys) {
      if (editNodeKeys.contains(k) || Behaviors.keys.contains(k)) continue;
      if (type == CanvasProps.spec.type && const {'path', 'under', 'translucent'}.contains(k)) continue;
      final where = spec?.prop(k) != null
          ? 'props.$k'
          : LayoutFields.all.any((f) => f.key == k)
              ? 'layout.$k'
              : DecorationFields.all.any((f) => f.key == k)
                  ? 'decoration.$k'
                  : null;
      add('unknown_node_key', editPointer(at, k), where == null ? 'A node has no "$k".' : 'A node has no "$k"; it belongs in "$where".',
          nodeId: id, suggestion: where ?? nearestName(k, [...editNodeKeys, ...Behaviors.keys]));
    }
    if (spec != null) {
      final props = readMap(json['props']) ?? const {};
      final keys = [for (final p in spec.props) p.key];
      for (final p in props.entries) {
        final def = spec.prop(p.key);
        final pp = editPointer(editPointer(at, 'props'), p.key);
        if (def == null) {
          add('unknown_prop', pp, 'A ${spec.type} has no prop "${p.key}".', nodeId: id, expected: keys, suggestion: nearestName(p.key, keys));
        } else if (p.value != null && def.decode(p.value) == null) {
          add('wrong_type', pp, 'A ${spec.type}\'s "${p.key}" is ${def.type.name}; this value cannot be read as one.',
              nodeId: id, expected: [def.type.name]);
        }
      }
      final children = readList(json['children']);
      if (children != null && children.isNotEmpty && spec.children != ChildModel.list) {
        add('children_not_allowed', editPointer(at, 'children'),
            spec.slots.isNotEmpty ? 'A $type takes slots (${spec.slots.join(', ')}), not "children".' : 'A $type takes no children.',
            nodeId: id, expected: spec.slots.isEmpty ? null : spec.slots);
      }
      final slots = readMap(json['slots']);
      for (final s in (slots ?? const {}).keys) {
        if (!spec.slots.contains(s)) {
          add('unknown_slot', editPointer(editPointer(at, 'slots'), s), 'A $type has no slot "$s".',
              nodeId: id, expected: spec.slots, suggestion: nearestName(s, spec.slots));
        }
      }
    }
    final layout = readMap(json['layout']);
    if (layout != null) {
      final keys = [for (final f in LayoutFields.all) f.key, 'widthFactor', 'heightFactor'];
      for (final k in layout.keys) {
        if (!keys.contains(k)) {
          add('unknown_layout_key', editPointer(editPointer(at, 'layout'), k), 'layout has no "$k".',
              nodeId: id, expected: keys, suggestion: nearestName(k, keys));
        }
      }
    }
    final decoration = readMap(json['decoration']);
    if (decoration != null) {
      final keys = [for (final f in DecorationFields.all) f.key];
      for (final k in decoration.keys) {
        if (!keys.contains(k)) {
          add('unknown_decoration_key', editPointer(editPointer(at, 'decoration'), k), 'decoration has no "$k".',
              nodeId: id, expected: keys, suggestion: nearestName(k, keys));
        }
      }
    }
    _actions(json['actions'], editPointer(at, 'actions'), id, catalog, add);
  }
  return out;
}

void _actions(Object? reactions, String at, String id, Catalog catalog,
    void Function(String code, String path, String message, {String? nodeId, List<String>? expected, String? suggestion, bool error}) add) {
  final list = readList(reactions);
  if (list == null) return;
  final types = [for (final a in catalog.actions) a.type];
  void chain(Object? actions, String p) {
    final l = readList(actions);
    if (l == null) return;
    for (var i = 0; i < l.length; i++) {
      final a = readMap(l[i]);
      if (a == null) continue;
      final type = readString(a['type']) ?? '';
      final spec = catalog.action(type);
      final ap = editPointer(p, i);
      if (spec == null) {
        add('unknown_action_type', editPointer(ap, 'type'), '"$type" is not an action type here.',
            nodeId: id, expected: types, suggestion: nearestName(type, types));
        continue;
      }
      for (final k in spec.nested) {
        chain(a[k], editPointer(ap, k));
      }
    }
  }

  for (var i = 0; i < list.length; i++) {
    chain(readMap(list[i])?['actions'], editPointer(editPointer(at, i), 'actions'));
  }
}
