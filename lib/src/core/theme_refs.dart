// Names of the project's theme in a document, resolved before it renders:
// a color field may name one of the theme's colors (`"color": "ember"`)
// and a text style may start from one of its text styles (`"style":
// "title"`, `{"from": "title", "fontSize": 40}`), as a Flutter widget reads
// `Theme.of(context).colorScheme` and `.textTheme`.
//
// Resolution walks a node's JSON by its declarations (each field's
// PropType), so every declared Color and TextStyle field is covered: props,
// decoration, behaviors, and the patches of media rules and interaction
// states. The document keeps its names (a decoded color keeps its name,
// `Color.named`; a style its `from`), so resolving it again against a
// changed theme (another mode, a screen size the theme's media rules
// change, an edited style) gives the new values.
import 'behavior_fields.dart';
import 'catalog.dart';
import 'document.dart';
import 'json.dart';
import 'node.dart';
import 'props.dart';
import 'theme.dart';
import 'value_fields.dart';
import 'values/color.dart';
import 'values/text.dart';

/// [style] with each color it names read by [color] (left as written when
/// [color] has none).
TextStyle resolveStyleColors(TextStyle style, Color? Function(String) color) {
  final json = style.toJson();
  final out = ThemeRefs._(color, (_) => null).value(PropTypes.textStyle, json, keepFrom: true);
  return identical(out, json) ? style : TextStyle.fromJson(out);
}

/// Resolves theme names in JSON written for declared types against a
/// [ThemeTokens] (already for the screen's size and mode:
/// [ThemeTokens.atScreen], [ThemeTokens.forBrightness]).
final class ThemeRefs {
  ThemeRefs(ThemeTokens theme) : this._(theme.color, theme.textStyle);
  ThemeRefs._(this._color, this._style);

  final Color? Function(String) _color;
  final TextStyle? Function(String) _style;

  /// [json], a value of [type], with the names it uses resolved; [json]
  /// itself (identical) when it names nothing this theme has.
  Object? value(PropType type, Object? json, {bool keepFrom = true}) {
    if (json == null) return null;
    switch (type.kind) {
      case PropKind.value:
        if (type.name == 'Color' && json is String && Color.isName(json)) {
          return _color(json)?.toJson() ?? json;
        }
        return json;
      case PropKind.list:
        if (json is! List) return json;
        List<Object?>? out;
        for (var i = 0; i < json.length; i++) {
          final v = value(type.item!, json[i]);
          if (!identical(v, json[i])) (out ??= [...json])[i] = v;
        }
        return out ?? json;
      case PropKind.object:
        if (type.name == 'TextStyle') return _textStyle(json, keepFrom);
        if (json is! Map) return json;
        return _fields(type.fields, json.cast<String, Object?>());
      default:
        return json;
    }
  }

  Object? _textStyle(Object? json, bool keepFrom) {
    final Json own;
    if (json is String) {
      own = {'from': json.trim()};
    } else if (json is Map) {
      own = json.cast<String, Object?>();
    } else {
      return json;
    }
    final fields = _fields(TextStyleFields.all, own);
    final from = readString(own['from'])?.trim();
    if (from == null || from.isEmpty) return fields;
    final base = _style(from);
    if (base == null) return fields; // an unknown name stays (validation reports it)
    final merged = base.merge(TextStyle.fromJson(fields)).toJson();
    // The resolved style keeps the name it starts from: a patch naming
    // another style replaces it as a whole (mergeNodePatch).
    if (keepFrom) {
      merged['from'] = from;
    } else {
      merged.remove('from');
    }
    return merged;
  }

  Json _fields(List<PropDef<Object?>> defs, Json m) {
    Json? out;
    for (final d in defs) {
      if (!m.containsKey(d.key)) continue;
      final v = value(d.type, m[d.key]);
      if (!identical(v, m[d.key])) (out ??= {...m})[d.key] = v;
    }
    return out ?? m;
  }

  /// A node's JSON (or a patch of it: a media rule's, an interaction
  /// state's) with the names it uses resolved; [json] itself when it names
  /// nothing. [spec] declares its props; [specOf] gives the declaration of
  /// another node an interaction state patches.
  Json node(Json json, WidgetSpec? spec, {WidgetSpec? Function(String id)? specOf}) {
    Json? out;
    void put(String key, Object? v) {
      if (!identical(v, json[key])) (out ??= {...json})[key] = v;
    }

    final props = readMap(json['props']);
    if (props != null && spec != null) put('props', _fields(spec.props, props));
    final decoration = readMap(json['decoration']);
    if (decoration != null) put('decoration', _fields(DecorationFields.all, decoration));
    for (final d in BehaviorFields.all) {
      if (!json.containsKey(d.key) || d.key == BehaviorFields.states.key) continue;
      put(d.key, value(d.type, json[d.key]));
    }
    // Interaction states: state → {node id → patch of that node}.
    final states = readMap(json[BehaviorFields.states.key]);
    if (states != null) {
      Json? s;
      for (final e in states.entries) {
        final targets = readMap(e.value);
        if (targets == null) continue;
        Json? t;
        for (final p in targets.entries) {
          final patch = readMap(p.value);
          if (patch == null) continue;
          final r = node(patch, specOf?.call(p.key) ?? spec, specOf: specOf);
          if (!identical(r, patch)) (t ??= {...targets})[p.key] = r;
        }
        if (t != null) (s ??= {...states})[e.key] = t;
      }
      if (s != null) put(BehaviorFields.states.key, s);
    }
    final media = readList(json['media']);
    if (media != null) {
      List<Object?>? m;
      for (var i = 0; i < media.length; i++) {
        final rule = readMap(media[i]);
        final patch = readMap(rule?['patch']);
        if (rule == null || patch == null) continue;
        final r = node(patch, spec, specOf: specOf);
        if (!identical(r, patch)) (m ??= [...media])[i] = {...rule, 'patch': r};
      }
      if (m != null) put('media', m);
    }
    return out ?? json;
  }

  /// [doc] with every node that names something of the theme resolved
  /// (the others are the same objects, so a source comparing nodes sees
  /// only those change).
  LayoutDocument document(LayoutDocument doc) {
    final catalog = doc.catalog ?? Catalog.current;
    Map<String, Node>? nodes;
    WidgetSpec? specOf(String id) => doc[id]?.spec;
    for (final e in doc.nodes.entries) {
      final json = e.value.toJson();
      final r = node(json, e.value.spec, specOf: specOf);
      if (identical(r, json)) continue;
      final n = Node.fromJson(r, id: e.key, catalog: catalog);
      if (n != null && n != e.value) (nodes ??= {...doc.nodes})[e.key] = n;
    }
    return nodes == null ? doc : doc.copyWith(nodes: nodes);
  }
}

/// [doc] resolved against [theme] ([ThemeRefs.document]); [doc] itself when
/// it names nothing of it.
LayoutDocument resolveThemeRefs(LayoutDocument doc, ThemeTokens theme) => ThemeRefs(theme).document(doc);
