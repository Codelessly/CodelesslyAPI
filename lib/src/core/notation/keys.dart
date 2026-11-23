// What a key on a node line means: the path in the node it is found at, by
// the catalog (docs/design/22-notation-parity.md section 2.1). Pure: the
// parser reads a key with it, and the printer asks it for the shortest key
// that means a path.
import '../behavior_fields.dart' show BehaviorFields;
import '../catalog.dart';
import '../props.dart';
import '../suggest.dart' show didYouMean;
import '../value_fields.dart' show DecorationFields, LayoutFields, NodeFields;

/// The short keys the notation has for a field, on every type.
const notationShortKeys = {'gap': 'props.spacing', 'pad': 'layout.padding', 'w': 'layout.width', 'h': 'layout.height', 'grow': 'layout.flex'};

/// The fields of a node's motion (what is drawn moved, scaled or turned,
/// with nothing laid out again) by the names read for them on a line whose
/// type has no key of that name.
const notationMotionKeys = {
  'scale': 'motion.scale',
  'rotate': 'motion.rotate',
  'translateX': 'motion.translateX',
  'translateY': 'motion.translateY',
};

/// Words that name one value of a choice (a tone, a size, a keyboard): a
/// parameter that takes one of them is said with it where another of its
/// set is written (`tone="error"` where the choice is `danger`).
const List<Set<String>> notationSameValues = [
  {'danger', 'error', 'destructive', 'critical', 'bad'},
  {'warning', 'warn', 'caution'},
  {'success', 'ok', 'positive', 'good'},
  {'info', 'information', 'note'},
  {'neutral', 'default', 'muted'},
  {'sm', 'small'},
  {'md', 'medium'},
  {'lg', 'large'},
  {'email', 'emailAddress'},
];

/// The shadows `shadow=` names by size, each the effects it is written out
/// as (`effects=[…]`).
const Map<String, List<Map<String, Object?>>> notationShadows = {
  'none': [],
  'small': _shadowSmall,
  'medium': _shadowMedium,
  'large': _shadowLarge,
};
const _shadowSmall = [
  {'type': 'dropShadow', 'color': '#14000000', 'offset': [0, 2], 'blurRadius': 8},
];
const _shadowMedium = [
  {'type': 'dropShadow', 'color': '#1F000000', 'offset': [0, 6], 'blurRadius': 18},
];
const _shadowLarge = [
  {'type': 'dropShadow', 'color': '#29000000', 'offset': [0, 14], 'blurRadius': 36},
];

/// Keys a model reaches for that a type spells otherwise.
const Map<String, Map<String, List<String>>> notationTypeKeys = {
  'textField': {
    'hint': ['props.decoration.hintText'],
    'label': ['props.decoration.labelText'],
    'helper': ['props.decoration.helperText'],
    'error': ['props.decoration.errorText'],
  },
  'gridView': {
    'cols': ['props.crossAxisCount'],
    'gap': ['props.mainAxisSpacing', 'props.crossAxisSpacing'],
  },
  'pageView': {
    // The share of the width one page takes: under 1, the next page shows at the edge.
    'peek': ['props.viewportFraction'],
  },
};

/// Keys written on a Text that belong to its style.
const notationTextStyleKeys = {
  'color': 'color', 'size': 'fontSize', 'weight': 'fontWeight',
  'bold': 'fontWeight', 'fontFamily': 'fontFamily', 'lineHeight': 'height',
  'fontFamilyFallback': 'fontFamilyFallback',
};

/// Keys written on an Input that belong to the style of its typed text.
const notationFieldStyleKeys = {
  'fontFamily': 'fontFamily', //
  'weight': 'fontWeight', 'letterSpacing': 'letterSpacing', 'lineHeight': 'height',
  'fontFamilyFallback': 'fontFamilyFallback',
};

/// The bounds of a node's `constraints` (Flutter's `BoxConstraints`), each a
/// layout field by its own name.
const notationConstraintKeys = {'minWidth', 'maxWidth', 'minHeight', 'maxHeight'};

/// Keys the parser reads as words of its own, on any type, that set more (or
/// other) than one path: `fill`, `border`, `animate`, `drag`, `sticky=0`…
/// A key of the type's own props of the same name is the prop where the
/// parser says so ([_ownFirst]).
const _words = {
  'bind', 'id', 'menu', 'preview', 'fill', 'gradient', 'animate', 'animation', 'enter', 'duration', 'delay', 'stagger', 'after', //
  'drag', 'drop', 'border', 'strokeWidth',
  'selected', 'hidden', 'show', 'hide', 'swipe', 'maxw',
  'border-bottom', 'border-top', 'border-left', 'border-right',
};

/// Of [_words], those that are the type's prop when it has one.
const _ownFirst = {
  'menu', 'preview', 'swipe', 'show', 'hide', 'selected', 'strokeWidth', 'bind', 'id',
};

/// Keys the parser reads as words of its own on one type.
const Map<String, Set<String>> _typeWords = {
  'text': {'mark', 'decoration', 'strike', 'underline', 'bold'},
  'textField': {'type', 'value', 'prefix', 'suffix', 'caps', 'icon', 'color', 'size', 'password'},
  'dropdown': {'color', 'size'},
  'iconButton': {'color', 'size'},
  'radialGauge': {'limit', 'unit', 'label'},
  'lineChart': {'color'},
  'slider': {'step', 'color', 'size', 'bindEnd'},
  'calendar': {'bindEnd'},
  'datePicker': {'min', 'max'},
  'switch': {'color'},
  'radio': {'color'},
  'listTile': {'icon'},
  'segmentedButton': {'items'},
  'column': {'color'},
  'row': {'color'},
  'stack': {'color'},
  'filledButton': {'color'},
  'elevatedButton': {'color'},
  'outlinedButton': {'color'},
  'textButton': {'color'},
};

/// A key resolved: the [path] in the node it is found at (`props.style.height`,
/// `layout.constraints.maxWidth`, `pan.axis`, `decoration.fills[0].color`, as a
/// binding names it) and what the catalog declares there ([type]; null under
/// a value the catalog does not break into fields, such as a constraint's
/// bound). [def] is the field's declaration when the path ends at one.
final class NotationKey {
  const NotationKey(this.path, this.type, this.def);
  final String path;
  final PropType? type;
  final PropDef<Object?>? def;

  @override
  String toString() => 'NotationKey($path)';
}

/// What the key [key] written `key=value` on a node line of the document type
/// [type] (`text`, `column`, a design system's `StatusPill`) means: the path
/// it sets, or null when the parser reads it as a word of its own that sets
/// no one path (`fill`, `border`, `animate`, `color` on a box) or when it is
/// no name of that type at all.
///
/// In the order of design 22 section 2.1: a word of the notation (`gap`,
/// `pad`, `w`, `h`, `grow`, `size` on a Text…); a prop of [type]; a field of
/// its text style, where it shows text; a layout field (`minWidth` and the
/// other bounds are `layout.constraints`'); a decoration field; a field of the
/// node (`visible`, `opacity`) or a behavior (`pan`, `draggable`). A dotted
/// key is the path from there (`pan.axis`, `style.letterSpacing`); the full
/// path from the node (`layout.x`, `props.style.height`, `decoration.shape`)
/// always reads, and `node.` before a field of the node itself or a behavior
/// (`node.tooltip` on a chip, whose own prop is `tooltip`). `[n]` takes an
/// element of a list (`fills[0].color`). Decoration fields are a key only
/// where the catalog says the type is decorated (elsewhere its `effects`).
String? notationKeyPath(String key, String type, {Catalog? catalog}) => notationKey(key, type, catalog: catalog)?.path;

/// [notationKeyPath] with what the catalog declares at the path.
NotationKey? notationKey(String key, String type, {Catalog? catalog}) {
  final c = catalog ?? Catalog.current;
  final spec = c.widget(type);
  final own = spec?.prop(key) != null;
  if (_words.contains(key) && !(own && _ownFirst.contains(key))) return null;
  final component = _isComponent(type);
  if (!component && (_typeWords[type]?.contains(key) ?? false) && !own) return null;
  if (!component && (type == 'chip' || type.endsWith('Chip')) && const {'color', 'size', 'icon'}.contains(key) && !own) return null;
  // The words that set one path.
  if (notationTypeKeys[type]?[key] case final List<String> paths) return paths.length == 1 ? _at(paths.single, type, c) : null;
  if (notationShortKeys[key] case final String path) return _at(path, type, c);
  final textWord = type == 'text' ? notationTextStyleKeys[key] : type == 'textField' && !own ? notationFieldStyleKeys[key] : null;
  if (textWord != null) return _at('props.style.$textWord', type, c);
  if (type == 'textField' && !own && (key == 'lines' || key == 'rows')) return _at('props.maxLines', type, c);
  if ((key == 'selected' || key == 'checked') && (type == 'checkbox' || type == 'switch')) return _at('props.value', type, c);
  if (key == 'enabled' && !own && spec?.prop('isEnabled') != null) return _at('props.isEnabled', type, c);
  if (key == 'enabled' && !own && !component) return null;
  if (key == 'tooltip' && !own) return _at('tooltip', type, c);
  return resolveNotationField(key, type, catalog: c)?.key;
}

/// A key resolved by the catalog alone (ranks 2 to 6 of section 2.1, dotted
/// and full paths), with no word of the notation: the key, or why not (the
/// prefix that resolved and the names the next segment could have been).
({NotationKey? key, String at, List<String> names})? resolveNotationField(String key, String type, {Catalog? catalog}) {
  final c = catalog ?? Catalog.current;
  final segments = _segments(key);
  if (segments == null) return null;
  final first = segments.first;
  final rest = segments.sublist(1);
  // The full path from the node.
  if (rest.isNotEmpty && first.indices.isEmpty && _sections.contains(first.name)) {
    final fields = _sectionFields(first.name, type, c);
    final head = rest.first;
    final def = fields.where((f) => f.key == head.name).firstOrNull;
    if (def != null) {
      final r = _walk('${first.name}.', def, rest);
      if (r.key != null) return r;
      // `decoration.hintText` on an Input: its own decoration prop.
      final other = _first(first, rest, type, c);
      if (other?.key != null) return other;
      return r;
    }
    final other = _first(first, rest, type, c);
    if (other != null) return other;
    return (key: null, at: first.name, names: [for (final f in fields) f.key]);
  }
  // `node.tooltip`: a field of the node itself where a prop of the type has
  // its name (a chip's own tooltip).
  if (rest.isNotEmpty && first.indices.isEmpty && first.name == 'node') {
    final def = _nodeFields.where((f) => f.key == rest.first.name).firstOrNull;
    if (def != null) return _walk('', def, rest);
    final other = _first(first, rest, type, c);
    return other ?? (key: null, at: 'node', names: [for (final f in _nodeFields) f.key]);
  }
  return _first(first, rest, type, c);
}

final _nodeFields = [...NodeFields.all, ...BehaviorFields.all];

/// The shortest key that means [path] on [type]: the notation's short word
/// when there is one, else the field's own name, else the path from its
/// field up, else the full path (which always reads).
String notationKeyFor(String path, String type, {Catalog? catalog}) {
  final c = catalog ?? Catalog.current;
  bool means(String k) => notationKeyPath(k, type, catalog: c) == path;
  String? best;
  void consider(String k) {
    // (An Input's text size is size=, a number, as a Text's is: the field's
    // own name alone is not read there.)
    if (type == 'textField' && k == 'fontSize') return;
    if ((best == null || k.length < best!.length) && means(k)) best = k;
  }

  for (final w in [...?notationTypeKeys[type]?.keys, ...notationShortKeys.keys, if (type == 'text') ...notationTextStyleKeys.keys, if (type == 'textField') ...notationFieldStyleKeys.keys]) {
    consider(w);
  }
  final parts = path.split('.');
  for (var i = parts.length - 1; i >= 0; i--) {
    consider(parts.sublist(i).join('.'));
  }
  if (best == null && !_sections.contains(parts.first)) consider('node.$path');
  return best ?? path;
}

/// The path [path] (a full path from the node) as [notationKey] gives it on
/// [type], or null when the catalog has no such field there.
NotationKey? _at(String path, String type, Catalog c) => resolveNotationField(path, type, catalog: c)?.key;

/// Every name a key may start with on [type] (its props, its text style's
/// fields, the layout, decoration, node and behavior fields, the notation's
/// short words): what the nearest name of an unknown key is chosen from.
List<String> notationKeyNames(String type, {Catalog? catalog}) {
  final c = catalog ?? Catalog.current;
  final spec = c.widget(type);
  final style = spec == null ? null : notationTextStyleProp(spec);
  return {
    ...?spec?.props.map((p) => p.key),
    ...?style?.type.fields.map((f) => f.key),
    ...LayoutFields.all.map((f) => f.key),
    ...notationConstraintKeys,
    ..._decoration(spec).map((f) => f.key),
    ...NodeFields.all.map((f) => f.key),
    ...BehaviorFields.all.map((f) => f.key),
    for (final k in notationShortKeys.keys)
      if (notationKeyPath(k, type, catalog: c) != null) k,
  }.toList();
}

/// The name an author most likely meant by [key] on [type] (at the segment
/// that did not resolve, for a dotted key), or null. It is a key [type]
/// takes: a near name whose path does not resolve (`Button
/// labelStyle.fontWeight` → `label.fontWeight`, then refused) is not said;
/// the key's last names under one or two of the type's names are tried
/// instead (`style.textStyle.fontWeight`).
String? notationKeyNearest(String key, String type, {Catalog? catalog}) {
  final c = catalog ?? Catalog.current;
  final raw = key.split('.');
  if (_segments(key) == null) return null;
  bool takes(String k) => resolveNotationField(k, type, catalog: c)?.key != null;
  String name(String s) => s.replaceAll(RegExp(r'\[\d+\]'), '');
  for (var i = 1; i <= raw.length; i++) {
    if (i == 1 && raw.length > 1 && (_sections.contains(raw.first) || raw.first == 'node')) continue;
    final r = resolveNotationField(raw.take(i).join('.'), type, catalog: c);
    if (r?.key != null) continue;
    final near = i == 1 ? didYouMean(name(raw.first), notationKeyNames(type, catalog: c)) : didYouMean(name(raw[i - 1]), r?.names ?? const []);
    final guess = near == null ? null : [...raw.take(i - 1), near, ...raw.skip(i)].join('.');
    if (guess != null && takes(guess)) return guess;
    // The rest of the key after the name that did not resolve, under
    // another name of the type.
    final rest = raw.skip(i).join('.');
    if (i != 1 || rest.isEmpty) return null;
    final found = <String>[];
    for (final n in notationKeyNames(type, catalog: c)) {
      if (takes('$n.$rest')) found.add('$n.$rest');
      // (The names under one: what a name that is none of them is offered.)
      if (resolveNotationField(n, type, catalog: c)?.key == null) continue;
      for (final m in resolveNotationField('$n.noSuchName', type, catalog: c)?.names ?? const <String>[]) {
        if (takes('$n.$m.$rest')) found.add('$n.$m.$rest');
      }
    }
    if (found.isEmpty) return null;
    // The one whose names share the longest run of letters with the name
    // written (`labelStyle` → `style.textStyle`, not `icon`).
    int shared(String a, String b) {
      a = a.toLowerCase();
      b = b.toLowerCase();
      var best = 0;
      for (var x = 0; x < a.length; x++) {
        for (var y = 0; y < b.length; y++) {
          var n = 0;
          while (x + n < a.length && y + n < b.length && a[x + n] == b[y + n]) {
            n++;
          }
          if (n > best) best = n;
        }
      }
      return best;
    }

    final head = name(raw.first);
    int score(String f) => shared(head, f.substring(0, f.length - rest.length));
    found.sort((a, b) => score(b) != score(a) ? score(b) - score(a) : a.length - b.length);
    return score(found.first) >= 3 ? found.first : null;
  }
  return null;
}

/// The prop of [spec] that is the style of the text it shows: its `style`
/// when that is a TextStyle, else its one TextStyle prop (a chip's
/// `labelStyle`, a badge's `textStyle`); null when it shows none or several.
PropDef<Object?>? notationTextStyleProp(WidgetSpec spec) {
  final style = spec.prop('style');
  if (style != null && style.type.name == 'TextStyle') return style;
  final all = spec.props.where((p) => p.type.kind == PropKind.object && p.type.name == 'TextStyle').toList();
  return all.length == 1 ? all.single : null;
}

// --- How a key is walked -------------------------------------------------------

const _sections = {'props', 'layout', 'decoration'};

bool _isComponent(String type) => type.isNotEmpty && type[0] == type[0].toUpperCase() && type[0] != type[0].toLowerCase();

typedef _Segment = ({String name, List<int> indices});

/// `fills[0].color` as its segments; null when it is not a key's shape.
List<_Segment>? _segments(String key) {
  if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*(\[\d+\])*(\.[A-Za-z_][A-Za-z0-9_]*(\[\d+\])*)*$').hasMatch(key)) return null;
  return [
    for (final s in key.split('.'))
      (
        name: RegExp(r'^[A-Za-z_][A-Za-z0-9_]*').stringMatch(s)!,
        indices: [for (final m in RegExp(r'\[(\d+)\]').allMatches(s)) int.parse(m[1]!)],
      ),
  ];
}

List<PropDef<Object?>> _sectionFields(String section, String type, Catalog c) => switch (section) {
  'props' => c.widget(type)?.props ?? const [],
  'layout' => LayoutFields.all,
  _ => _decoration(c.widget(type)),
};

/// The decoration fields a node of [spec] keeps: all of them where the
/// catalog says it is decorated, else its effects (the blurs it keeps).
List<PropDef<Object?>> _decoration(WidgetSpec? spec) =>
    spec == null || spec.decorated ? DecorationFields.all : DecorationFields.undecorated;

final _constraints = LayoutFields.all.firstWhere((f) => f.key == 'constraints');

/// The first segment by the ranks of section 2.1 (2 to 6), then the rest.
({NotationKey? key, String at, List<String> names})? _first(_Segment first, List<_Segment> rest, String type, Catalog c) {
  final spec = c.widget(type);
  final name = first.name;
  if (spec?.prop(name) case final def?) return _walk('props.', def, [first, ...rest]);
  final style = spec == null ? null : notationTextStyleProp(spec);
  if (style != null) {
    final f = style.type.fields.where((f) => f.key == name).firstOrNull;
    if (f != null) return _walk('props.${style.key}.', f, [first, ...rest]);
  }
  for (final f in LayoutFields.all) {
    if (f.key == name) return _walk('layout.', f, [first, ...rest]);
  }
  if (notationConstraintKeys.contains(name) && first.indices.isEmpty && rest.isEmpty) {
    return (key: NotationKey('layout.constraints.$name', const PropType.number(min: 0), null), at: '', names: const []);
  }
  for (final f in _decoration(spec)) {
    if (f.key == name) return _walk('decoration.', f, [first, ...rest]);
  }
  for (final f in _nodeFields) {
    if (f.key == name) return _walk('', f, [first, ...rest]);
  }
  return null;
}

/// From [def] (the field [segments] starts at, under [prefix]) down the rest
/// of the segments, by the declared fields of each object.
({NotationKey? key, String at, List<String> names}) _walk(String prefix, PropDef<Object?> def, List<_Segment> segments) {
  var path = prefix + segments.first.name;
  PropType? type = def.type;
  PropDef<Object?>? at = def;
  // Into a list's elements.
  ({NotationKey? key, String at, List<String> names})? index(List<int> indices) {
    for (final i in indices) {
      if (type == null) {
        path += '[$i]';
        continue;
      }
      if (type!.kind == PropKind.json) {
        type = null;
        at = null;
        path += '[$i]';
        continue;
      }
      if (type!.kind != PropKind.list) return (key: null, at: path, names: const []);
      type = type!.item;
      at = null;
      path += '[$i]';
    }
    return null;
  }

  if (index(segments.first.indices) case final failed?) return failed;
  for (final s in segments.skip(1)) {
    final t = type;
    if (t != null && t.kind == PropKind.object && t.fields.isNotEmpty) {
      final f = t.fields.where((f) => f.key == s.name).firstOrNull;
      if (f == null) return (key: null, at: path, names: [for (final f in t.fields) f.key]);
      type = f.type;
      at = f;
    } else if (t == null || t.kind == PropKind.json || t.kind == PropKind.value || t.kind == PropKind.object) {
      // A value the catalog does not break into fields (a constraint's
      // bound, a map of data): the path as written.
      type = identical(at, _constraints) ? const PropType.number(min: 0) : null;
      at = null;
    } else {
      return (key: null, at: path, names: const []);
    }
    path += '.${s.name}';
    if (index(s.indices) case final failed?) return failed;
  }
  return (key: NotationKey(path, type, at), at: path, names: const []);
}
