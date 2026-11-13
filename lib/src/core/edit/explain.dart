// Diagnostics a model can act on without reading the reference: the codes
// live generations actually hit, rewritten with the fix spelled out as JSON
// (a size written as a layout key, children on a type that takes none, a
// prop a type does not have). Applied to every diagnostic an op's check
// reports ([applyOps]); the code, path and severity are kept.
import '../catalog.dart';
import '../json.dart';
import '../props.dart' show ChildModel;
import 'diagnostics.dart';

/// The node types of [catalog] that take a `children` list, most used
/// first.
List<String> containerTypes(Catalog catalog) {
  const first = ['column', 'row', 'stack', 'wrap', 'listView', 'gridView'];
  final all = [for (final w in catalog.widgets) if (w.children == ChildModel.list) w.type];
  return [for (final t in first) if (all.contains(t)) t, for (final t in all) if (!first.contains(t)) t];
}

/// [d] with a message that says how to fix it, when its code is one models
/// hit; [node] is the node's JSON as the op wrote it.
EditDiagnostic explainDiagnostic(EditDiagnostic d, {required Catalog catalog, Json? node}) {
  String? message;
  String? suggestion = d.suggestion;
  List<String>? expected = d.expected;
  final last = d.path.split('/').last;
  final type = readString(node?['type']);
  switch (d.code) {
    case 'unknown_layout_key' when const {'hug', 'fill', 'flexible', 'fixed', 'auto', 'wrap', 'expand', 'expanded'}.contains(last):
      final layout = readMap(node?['layout']) ?? const {};
      final both = layout.containsKey('height') && layout.containsKey('width');
      final axis = layout.containsKey('height') && !layout.containsKey('width') ? 'width' : 'height';
      final v = layout[last];
      final mode = last == 'fixed' ? null : (const {'fill', 'expand', 'expanded'}.contains(last) ? 'fill' : (last == 'flexible' ? 'flexible' : 'hug'));
      final existing = readMap(layout[axis])?.values.whereType<num>().firstOrNull;
      final n = v is num && v > 0 ? v : (existing ?? 24);
      message = 'layout has no "$last": sizes go under width/height: "$axis": ${mode == null ? '$n' : '{"$mode": $n}'} '
          '(a number is a fixed size; {"hug": n} fits the content, {"fill": n} takes the free space; n is the size you expect).'
          '${both ? ' This node has both already: remove "$last".' : ''}';
      suggestion = axis;
      expected = const ['width', 'height'];
    case 'unknown_layout_key' when const {'gap', 'spacing', 'mainAxisAlignment', 'crossAxisAlignment'}.contains(last):
      message = 'layout has no "$last": it is a prop of a row or column: "props": {"${last == 'gap' ? 'spacing' : last}": ...}.';
      suggestion = 'props.${last == 'gap' ? 'spacing' : last}';
    case 'unknown_decoration_key' when const {'color', 'background', 'backgroundColor', 'fill'}.contains(last):
      message = 'decoration has no "$last": a fill is a list of paints: "decoration": {"fills": [{"color": "#FF2563EB"}]}.';
      suggestion = 'fills';
    case 'unknown_decoration_key' when const {'border', 'borderColor', 'stroke'}.contains(last):
      message = 'decoration has no "$last": a border is "strokes": [{"color": "#FFE5E7EB"}] with "strokeWidth": 1.';
      suggestion = 'strokes';
    case 'unknown_decoration_key' when const {'borderRadius', 'cornerRadius', 'radii'}.contains(last):
      message = 'decoration has no "$last": corners are "radius": 12.';
      suggestion = 'radius';
    case 'children_not_allowed' || 'invalid_parent' when !(d.message.contains('slot')):
      final containers = containerTypes(catalog);
      final what = type ?? _typeIn(d.message);
      message = '${what == null ? 'This node type' : 'A $what'} takes no children. Types that take children: '
          '${containers.take(6).join(', ')}. For a filled or bordered box with content (a button, a tag, a chip), use a row '
          '(or column, or stack) with the decoration and padding: {"type": "row", "layout": {"padding": [12, 6, 12, 6]}, '
          '"decoration": {"fills": [{"color": "#FFDCFCE7"}], "radius": 12}, "children": ["tagText"]}.';
      expected = containers.take(6).toList();
      suggestion = 'row';
    case 'unknown_prop' when type != null && catalog.widget(type) != null:
      expected = expected ?? [for (final p in catalog.widget(type)!.props) p.key];
      message = 'A $type has no prop "$last". Its props: ${expected.join(', ')}.'
          '${last == 'text' && expected.contains('label') ? ' A button\'s text is "label".' : ''}';
      if (last == 'text' && expected.contains('label')) suggestion = 'label';
    default:
      return d;
  }
  return EditDiagnostic(
      op: d.op, code: d.code, error: d.error, path: d.path, message: message, nodeId: d.nodeId, expected: expected, suggestion: suggestion);
}

String? _typeIn(String message) => RegExp(r'A (\w+) takes no').firstMatch(message)?[1];
