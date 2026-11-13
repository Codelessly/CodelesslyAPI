// A patch of a node's JSON (a media rule's, an interaction state's) merged
// as CSS applies a declaration: a JSON merge patch (RFC 7386: objects merge,
// `null` removes a key, anything else replaces), except that a value with
// several forms is replaced as a whole when the patch writes another form.
//
// A size is one of `{"fixed"|"fill"|"flexible"|"hug": n}`: merging
// `{"hug": 200}` into `{"fill": 292}` gave `{"fill": 292, "hug": 200}`,
// which is no size at all. The forms are read from the declarations (the
// field's PropType), so every union-typed field is covered: sizes
// (`layout.width`/`height`), positions (`layout.x`/`y`: an edges form
// `{"start", "end"}`, `{"align"}`, `{"relative"}`), icons (a name or a typed
// object), and the models a `type` discriminates (paints, effects, shape
// and input borders).
import 'json.dart';
import 'props.dart';
import 'value_fields.dart';

/// The form a union-typed value [v] of [type] is written in (what decides
/// whether a patch merges into it or replaces it), or null when [type] has
/// one form only, or [v] names none.
String? unionForm(PropType type, Object? v) {
  if (v == null) return null;
  switch (type.kind) {
    case PropKind.value:
      switch (type.name) {
        case 'AxisSize':
          if (v is num) return 'fixed';
          if (v is Map) {
            // A size object has one key: its mode (nulls are removals).
            final keys = [for (final e in v.entries) if (e.value != null) '${e.key}'];
            return keys.length == 1 ? keys.first : (keys.isEmpty ? null : keys.join('+'));
          }
          return null;
        case 'AxisPosition':
          if (v is num) return 'number';
          if (v is Map) {
            final keys = {for (final e in v.entries) if (e.value != null) '${e.key}'};
            if (keys.contains('align')) return 'align';
            if (keys.contains('relative')) return 'relative';
            return keys.isEmpty ? null : 'edges';
          }
          return null;
        case 'IconData':
          if (v is String) return 'name';
          if (v is Map) return v['type'] is String ? 'type:${v['type']}' : null;
          return null;
      }
      return null;
    case PropKind.object:
      if (v is Map && type.fields.any((f) => f.key == 'type')) {
        final t = v['type'];
        return t is String ? 'type:$t' : null;
      }
      return null;
    default:
      return null;
  }
}

/// Whether [type] is a union: a value written in one of several forms.
bool isUnionType(PropType type) =>
    (type.kind == PropKind.value && const {'AxisSize', 'AxisPosition', 'IconData'}.contains(type.name)) ||
    (type.kind == PropKind.object && type.fields.any((f) => f.key == 'type'));

/// [base] (a node's JSON, or a patch of it) with [patch] merged in, as the
/// node's declarations read them: as [mergePatch]'s JSON merge patch, except
/// that where [patch] writes a union-typed field ([isUnionType]) in another
/// form than [base] has, the patch's value replaces [base]'s (its `null`
/// keys left out), as CSS replaces a declaration. A size object always
/// replaces (it has one key). [props] are the node type's prop
/// declarations (null: its props merge as plain JSON). With [keepNulls], a
/// `null` is kept (two patches merged into one).
Json mergeNodePatch(Json base, Json patch, {List<PropDef<Object?>>? props, bool keepNulls = false}) {
  final out = <String, Object?>{...base};
  for (final e in patch.entries) {
    final fields = switch (e.key) {
      'layout' => LayoutFields.all,
      'decoration' => DecorationFields.all,
      'props' => props,
      _ => null,
    };
    out[e.key] = fields == null
        ? _plain(out[e.key], e.value, keepNulls, out.containsKey(e.key))
        : _typed(out[e.key], e.value, {for (final f in fields) f.key: f.type}, keepNulls);
    if (e.value == null && !keepNulls) out.remove(e.key);
  }
  return out;
}

Object? _plain(Object? cur, Object? v, bool keepNulls, bool had) {
  if (v is Map && cur is Map) return _mergeMaps(readMap(cur)!, readMap(v)!, null, keepNulls);
  return v is Map && !keepNulls ? _withoutNulls(v) : v;
}

Object? _typed(Object? cur, Object? v, Map<String, PropType> fields, bool keepNulls) {
  if (v is! Map) return v;
  if (cur is! Map) return keepNulls ? v : _withoutNulls(v);
  return _mergeMaps(readMap(cur)!, readMap(v)!, fields, keepNulls);
}

Json _mergeMaps(Json base, Json patch, Map<String, PropType>? fields, bool keepNulls) {
  final out = <String, Object?>{...base};
  for (final e in patch.entries) {
    final v = e.value, cur = out[e.key];
    final type = fields?[e.key];
    if (v == null) {
      if (keepNulls) {
        out[e.key] = null;
      } else {
        out.remove(e.key);
      }
      continue;
    }
    if (v is Map && type != null && isUnionType(type) && _replaces(type, cur, v)) {
      out[e.key] = keepNulls ? v : _withoutNulls(v);
      continue;
    }
    if (v is Map && cur is Map) {
      final sub = type != null && type.kind == PropKind.object ? {for (final f in type.fields) f.key: f.type} : null;
      out[e.key] = _mergeMaps(readMap(cur)!, readMap(v)!, sub, keepNulls);
    } else {
      out[e.key] = v is Map && !keepNulls ? _withoutNulls(v) : v;
    }
  }
  return out;
}

/// Whether patch value [v] replaces [cur] (of union [type]) instead of
/// merging into it.
bool _replaces(PropType type, Object? cur, Map v) {
  if (type.kind == PropKind.value && type.name == 'AxisSize') return true;
  if (cur is! Map) return true;
  final a = unionForm(type, cur), b = unionForm(type, v);
  return b != null && a != b;
}

Object? _withoutNulls(Object? v) {
  if (v is! Map) return v;
  return {
    for (final e in v.entries)
      if (e.value != null) '${e.key}': _withoutNulls(e.value),
  };
}
