// Whether a binding path (a key of `Node.bind`) names a bindable field of a
// node, walked over the declarations: the node's own fields, LayoutFields,
// DecorationFields (paints and effects selected by index, id or `*`), the
// type's props and the behaviors' models.
import '../core/behavior_fields.dart';
import '../core/bindings.dart';
import '../core/migrate/legacy_paths.dart';
import '../core/props.dart';
import '../core/value_fields.dart';
import 'diagnostic.dart';

/// Why [path] isn't a bindable path of a node of [spec] (null: it is),
/// with the nearest valid key at the step that failed.
({String message, String? suggestion, bool reserved})? bindPathProblem(String path, WidgetSpec? spec, String type) {
  // An older schema's path (one set from outside the document is not
  // migrated): what to write.
  if (schema2PathHint(path) case final String hint) {
    return (message: '"$path" is a schema-2 path, which schema 4 does not read: write $hint.', suggestion: null, reserved: false);
  }
  if (schema3PathHint(path) case final String hint) {
    return (message: '"$path" is a schema-3 path, which schema 4 does not read: write $hint.', suggestion: null, reserved: false);
  }
  final keys = BindPaths.parse(path);
  if (keys.isEmpty) return (message: '"$path" is not a binding path.', suggestion: null, reserved: false);
  final head = keys.first;
  final rest = keys.sublist(1);
  const top = ['visible', 'opacity', 'selected', 'disabled', 'data', 'layout', 'decoration', 'props'];
  if (head is! String) return (message: '"$path" must start with a name.', suggestion: null, reserved: false);
  switch (head) {
    case 'visible' || 'opacity' || 'selected' || 'disabled':
      return rest.isEmpty ? null : (message: '"$head" takes no sub-path.', suggestion: head, reserved: false);
    case 'data':
      final repeats = const {'listView', 'gridView', 'pageView', 'tableView'}.contains(type);
      if (!repeats) {
        return (
          message: '"data" is read by a listView, gridView, pageView or tableView (the items it repeats its first child for); a $type does not read it.',
          suggestion: null,
          reserved: false,
        );
      }
      return null;
    case 'semantics' || 'enabled':
      return (message: '"$path" is reserved: kept, but not applied yet.', suggestion: null, reserved: true);
    case 'layout':
      if (rest.isEmpty) return (message: 'Bind a layout field ("layout.width"), not the whole layout.', suggestion: 'layout.width', reserved: false);
      final fields = [...LayoutFields.all.map((f) => f.key), 'widthFactor', 'heightFactor'];
      final f = rest.first;
      if (f is! String || !fields.contains(f)) {
        return (message: 'layout has no "$f". Bindable: ${fields.join(', ')}.', suggestion: f is String ? _near(f, fields, 'layout.') : null, reserved: false);
      }
      if (rest.length > 1) {
        final def = LayoutFields.all.where((d) => d.key == f).firstOrNull;
        if (def == null || def.type.kind != PropKind.object) {
          return (message: 'layout.$f is set as a whole: bind "layout.$f" to the full value.', suggestion: 'layout.$f', reserved: false);
        }
      }
      return null;
    case 'decoration':
      if (rest.isEmpty) return (message: 'Bind a decoration field ("decoration.fills[0]"), not the whole decoration.', suggestion: null, reserved: false);
      final f = rest.first;
      final def = f is String ? DecorationFields.all.where((d) => d.key == f).firstOrNull : null;
      if (def == null) {
        final keys = DecorationFields.all.map((d) => d.key);
        return (message: 'decoration has no "$f". Fields: ${keys.join(', ')}.', suggestion: f is String ? _near(f, keys, 'decoration.') : null, reserved: false);
      }
      return _walk(def.type, rest.sublist(1), 'decoration.$f', idSelectable: true);
    case 'props':
      if (rest.isEmpty) return (message: 'Bind a prop ("props.text"), not all props.', suggestion: null, reserved: false);
      final p = rest.first;
      if (spec == null) return null; // unknown type: reported elsewhere
      final def = p is String ? spec.prop(p) : null;
      if (def == null) {
        final keys = spec.props.map((d) => d.key);
        return (
          message: 'A $type has no prop "$p". Its props: ${keys.isEmpty ? '(none)' : keys.join(', ')}.',
          suggestion: p is String ? _near(p, keys, 'props.') : null,
          reserved: false,
        );
      }
      return _walk(def.type, rest.sublist(1), 'props.$p');
  }
  final behavior = BehaviorFields.all.where((d) => d.key == head).firstOrNull;
  if (behavior != null) return _walk(behavior.type, rest, head, lenient: true);
  final all = [...top, ...BehaviorFields.all.map((d) => d.key)];
  return (message: '"$head" is not bindable. Paths start with: ${all.join(', ')}.', suggestion: _nearPlain(head, all), reserved: false);
}

/// Walks [keys] into a value of [type]: object fields by key, list items by
/// `[i]` or `*` (or an item id where [idSelectable]), free-form JSON
/// anywhere.
({String message, String? suggestion, bool reserved})? _walk(PropType type, List<Object> keys, String at,
    {bool idSelectable = false, bool lenient = false}) {
  var t = type;
  var where = at;
  for (var i = 0; i < keys.length; i++) {
    final k = keys[i];
    switch (t.kind) {
      case PropKind.json:
        return null;
      case PropKind.list:
        if (k is int || k == everyItem || (idSelectable && k is String)) {
          t = t.item!;
          where = '$where${k is int ? '[$k]' : '.$k'}';
          continue;
        }
        return (message: '$where is a list: select an item with [index] or *.', suggestion: null, reserved: false);
      case PropKind.object:
        final fields = t.fields;
        final f = k is String ? fields.where((d) => d.key == k).firstOrNull : null;
        if (f == null) {
          final keys = fields.map((d) => d.key);
          return (message: '$where (${t.name}) has no "$k". Fields: ${keys.join(', ')}.', suggestion: k is String ? _near(k, keys, '$where.') : null, reserved: false);
        }
        t = f.type;
        where = '$where.$k';
      case PropKind.value:
        // offset.dx / offset.dy of a shadow are bindable.
        if (t.name == 'Offset' && (k == 'dx' || k == 'dy') && i == keys.length - 1) return null;
        if (lenient) return null;
        return (message: '$where is a ${t.name}: bind it whole.', suggestion: where, reserved: false);
      default:
        return (message: '$where is a ${t.typeName}: it has no "$k".', suggestion: where, reserved: false);
    }
  }
  return null;
}

String? _near(String word, Iterable<String> keys, String prefix) => nearest(word, keys)?.let((k) => '$prefix$k');
String? _nearPlain(String word, Iterable<String> keys) => nearest(word, keys);

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// The widget types whose `data` binding is the list they repeat for.
const repeatingTypes = {'listView', 'gridView', 'pageView', 'tableView'};
