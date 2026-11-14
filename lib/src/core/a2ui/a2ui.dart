// A2UI in front of the notation (docs/design/13-compact-notation.md §7).
//
// A2UI v1.0's agent-to-renderer messages (createSurface, updateComponents,
// updateDataModel, deleteSurface) with its basic catalog are read into the
// compact notation, which expands to an ordinary document: a second parser,
// not a second renderer. An A2UI-tuned model then draws with this renderer
// and the design system's defaults, and what it wrote can go on being
// edited as a document.
//
// What maps: Text, Image, Icon, Row, Column, List (static or over data),
// Card, Divider, Button (its action is told to the host with its context),
// TextField, CheckBox, Slider, ChoicePicker (one choice), DateTimeInput, and
// the data model (a bound path is a variable; a list a template repeats is
// a list variable). What does not yet: Tabs and Modal are laid out in place
// (each tab's title above its content; a modal's trigger only), Video and
// AudioPlayer are placeholders, a ChoicePicker with several choices is not
// bound, and of the functions only formatString's text is kept. Each is
// reported in [A2uiResult.notes].
import 'dart:convert';

import '../catalog.dart';
import '../json.dart';
import '../notation/notation.dart';

/// What [parseA2ui] gives: the document, the notation it was read through,
/// and what was approximated.
final class A2uiResult {
  const A2uiResult(this.document, this.notation, this.issues, this.notes);

  /// A schema-3 layout document.
  final Json document;

  /// The same UI in the compact notation.
  final String notation;

  /// What the notation could not read (a bug in the mapping when not empty).
  final List<NotationIssue> issues;

  /// A2UI features laid out approximately or left out.
  final List<String> notes;
}

/// The surface A2UI's JSONL [text] describes (the last one created, or
/// [surfaceId]), as a document.
A2uiResult parseA2ui(String text, {required Catalog catalog, String? surfaceId, NotationOptions options = const NotationOptions()}) {
  final messages = <Json>[];
  for (final line in const LineSplitter().convert(text)) {
    final t = line.trim();
    if (!t.startsWith('{')) continue;
    try {
      final j = jsonDecode(t);
      if (j is Map) messages.add(j.cast<String, Object?>());
    } catch (_) {
      // A line still arriving: read when it is whole.
    }
  }
  return a2uiToDocument(messages, catalog: catalog, surfaceId: surfaceId, options: options);
}

/// [messages] (decoded agent-to-renderer envelopes) as a document.
A2uiResult a2uiToDocument(List<Json> messages, {required Catalog catalog, String? surfaceId, NotationOptions options = const NotationOptions()}) {
  final surface = _Surface();
  for (final m in messages) {
    final created = readMap(m['createSurface']);
    if (created != null) {
      final id = readString(created['surfaceId']);
      if (surfaceId == null || id == surfaceId) {
        surface
          ..id = id
          ..components.clear()
          ..data.clear();
        for (final c in readList(created['components']) ?? const []) {
          surface.add(c);
        }
        final model = readMap(created['dataModel']);
        if (model != null) surface.data.addAll(model);
      }
    }
    final update = readMap(m['updateComponents']);
    if (update != null && surface.owns(update['surfaceId'], surfaceId)) {
      for (final c in readList(update['components']) ?? const []) {
        surface.add(c);
      }
    }
    final data = readMap(m['updateDataModel']);
    if (data != null && surface.owns(data['surfaceId'], surfaceId)) surface.write(readString(data['path']) ?? '/', data['value']);
    final deleted = readMap(m['deleteSurface']);
    if (deleted != null && surface.owns(deleted['surfaceId'], surfaceId)) {
      surface
        ..components.clear()
        ..data.clear();
    }
  }
  final notation = surface.notation();
  final r = parseNotation(notation, catalog: catalog, options: options);
  return A2uiResult(r.document, notation, r.issues, surface.notes);
}

class _Surface {
  String? id;
  final components = <String, Json>{};
  final Json data = {};
  final notes = <String>[];
  final _bound = <String>{};

  bool owns(Object? surface, String? wanted) => id == null || surface == null || surface == (wanted ?? id);

  void add(Object? component) {
    final c = readMap(component);
    final cid = c == null ? null : readString(c['id']);
    if (cid != null) components[cid] = c!;
  }

  /// Upserts [value] at JSON Pointer [path] (null removes).
  void write(String path, Object? value) {
    final parts = _pointer(path);
    if (parts.isEmpty) {
      data.clear();
      if (value is Map) data.addAll(value.cast<String, Object?>());
      return;
    }
    Json at = data;
    for (final p in parts.take(parts.length - 1)) {
      final next = at[p];
      at = next is Map ? (at[p] = next.cast<String, Object?>()) : (at[p] = <String, Object?>{});
    }
    value == null ? at.remove(parts.last) : at[parts.last] = value;
  }

  static List<String> _pointer(String path) =>
      [for (final p in path.split('/')) if (p.isNotEmpty) p.replaceAll('~1', '/').replaceAll('~0', '~')];

  /// The variable a model path is: its segments joined (`/user/name` is
  /// `user_name`); inside a template, a relative path reads the item.
  String _name(String path, {bool item = false}) {
    if (!path.startsWith('/') && item) return 'item.${_pointer(path).join('.')}';
    final parts = _pointer(path);
    final name = parts.map((p) => p.replaceAll(RegExp('[^A-Za-z0-9_]'), '_')).join('_');
    final safe = RegExp('^[A-Za-z_]').hasMatch(name) ? name : 'v_$name';
    _bound.add(parts.join('/'));
    return safe;
  }

  String notation() {
    notes.clear();
    _bound.clear();
    final body = <String>[];
    final root = components['root'] ?? (components.isEmpty ? null : components.values.first);
    if (root != null) _write(root, 0, body, {}, item: false);
    // State: every scalar or list of the model, under the name its path
    // gives; a binding to a path with no value yet declares itself.
    final state = <String>[];
    void walk(Object? value, List<String> path) {
      if (value is Map && path.length < 6) {
        for (final e in value.entries) {
          walk(e.value, [...path, '${e.key}']);
        }
        return;
      }
      if (path.isEmpty) return;
      state.add('state ${_name('/${path.join('/')}')}=${jsonEncode(value)}');
    }

    walk(data, const []);
    return [...state, ...body].join('\n');
  }

  /// A dynamic value as notation text inside a string: a literal as it is,
  /// a binding as `{name}`.
  String _text(Object? v, {required bool item}) {
    if (v == null) return '';
    if (v is Map) {
      final path = readString(v['@path']) ?? readString(v['path']);
      if (path != null) return '{${_name(path, item: item)}}';
      final args = readMap(v['args']);
      if (v['@call'] == 'formatString' && args != null) {
        // "${/path}" inside the format reads the model.
        return '${args['value'] ?? ''}'.replaceAllMapped(RegExp(r'\$\{([^}]+)\}'), (m) => '{${_name(m[1]!.trim(), item: item)}}');
      }
      notes.add('The function ${v['@call']} is not evaluated.');
      return '';
    }
    return '$v'.replaceAll('{', '(').replaceAll('}', ')');
  }

  String _quoted(Object? v, {required bool item}) => jsonEncode(_text(v, item: item)).replaceAll(r'\\', r'\');

  /// The variable a dynamic value is bound to (null: a literal).
  String? _bindingOf(Object? v, {required bool item}) {
    if (v is! Map) return null;
    final path = readString(v['@path']) ?? readString(v['path']);
    return path == null ? null : _name(path, item: item);
  }

  void _write(Json c, int depth, List<String> out, Set<String> seen, {required bool item}) {
    final cid = readString(c['id']) ?? '';
    if (!seen.add(cid)) return;
    final pad = '  ' * depth;
    final grow = c['weight'] is num ? ' grow' : '';
    void line(String s) => out.add('$pad$s$grow');
    void child(Object? id, int d, {bool? inItem}) {
      final next = id is String ? components[id] : null;
      if (next != null) _write(next, d, out, {...seen}, item: inItem ?? item);
    }

    void children(Object? list, int d) {
      if (list is List) {
        for (final id in list) {
          child(id, d);
        }
      } else if (list is Map) {
        // A template repeated over a list of the model.
        final path = readString(list['path']) ?? '/';
        out.add('${'  ' * d}each item in ${_name(path, item: item)}');
        child(list['componentId'], d + 1, inItem: true);
      }
    }

    String flex(Json c, {required bool row}) {
      const main = {'start': 'start', 'center': 'center', 'end': 'end', 'spaceBetween': 'spaceBetween', 'spaceAround': 'spaceAround', 'spaceEvenly': 'spaceEvenly', 'stretch': 'start'};
      const cross = {'start': 'start', 'center': 'center', 'end': 'end', 'stretch': 'stretch'};
      final props = {
        'mainAxisAlignment': main[c['justify']] ?? 'start',
        // A2UI stretches by default; a row's children are centred on its
        // line here, as the notation's are.
        'crossAxisAlignment': cross[c['align']] ?? (row ? 'center' : 'stretch'),
      };
      return ' {"props": ${jsonEncode(props)}}';
    }

    switch (readString(c['component'])) {
      case 'Text':
        final variant = c['variant'] == 'caption' ? '.caption' : '';
        line('Text$variant ${_quoted(c['text'], item: item)}');
      case 'Image':
        final h = switch (c['variant']) { 'icon' => 24, 'avatar' => 40, 'smallFeature' => 80, 'largeFeature' => 220, 'header' => 180, _ => 140 };
        final small = c['variant'] == 'icon' || c['variant'] == 'avatar';
        line('Image ${_quoted(c['url'], item: item)} h:$h${small ? ' w:$h radius:${h ~/ 2}' : ' radius:8'}');
      case 'Icon':
        final name = c['name'];
        final snake = name is String ? name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}') : 'circle';
        line('Icon "$snake"');
      case 'Row':
        out.add('${pad}Row gap:8$grow${flex(c, row: true)}');
        children(c['children'], depth + 1);
      case 'Column':
        out.add('${pad}Column gap:8$grow${flex(c, row: false)}');
        children(c['children'], depth + 1);
      case 'List':
        final across = c['direction'] == 'horizontal';
        out.add('$pad${across ? 'Row' : 'Column'} gap:8$grow');
        children(c['children'], depth + 1);
      case 'Card':
        out.add('${pad}Card gap:8$grow');
        child(c['child'], depth + 1);
      case 'Divider':
        line('Divider');
      case 'Button':
        final label = components[c['child']];
        final text = label == null ? 'Button' : _text(label['text'], item: item);
        final variant = switch (c['variant']) { 'primary' => '', 'borderless' => '.ghost', _ => '.outline' };
        final event = readMap(readMap(c['action'])?['event']);
        final context = readMap(event?['context']) ?? const {};
        final value = {
          for (final e in context.entries)
            e.key: _bindingOf(e.value, item: item) == null ? e.value : '\${${_bindingOf(e.value, item: item)}}',
        };
        final tail = event == null
            ? ''
            : ' ${jsonEncode({
                'actions': [
                  {
                    'trigger': {'type': 'click'},
                    'actions': [
                      {'type': 'componentEvent', 'event': '${event['name']}', if (value.isNotEmpty) 'value': value},
                    ],
                  },
                ],
              })}';
        if (readMap(c['action'])?['functionCall'] != null) notes.add('Button "$cid": a function call action is not run.');
        out.add('${pad}Button$variant ${jsonEncode(text)}$grow$tail');
      case 'TextField':
        final bound = _bindingOf(c['value'], item: item);
        final extra = switch (c['variant']) { 'longText' => ' lines:4', 'obscured' => ' obscureText:true', 'number' => ' keyboardType:number', _ => '' };
        final hint = c['placeholder'] == null ? '' : ' hint:${_quoted(c['placeholder'], item: item)}';
        line('Input ${_quoted(c['label'], item: item)}$hint$extra${bound == null ? '' : ' =$bound'}');
      case 'CheckBox':
        final bound = _bindingOf(c['value'], item: item);
        line('Checkbox ${_quoted(c['label'], item: item)}${bound == null ? '' : ' =$bound'}');
      case 'Slider':
        if (c['label'] != null) out.add('${pad}Text.small ${_quoted(c['label'], item: item)}');
        final bound = _bindingOf(c['value'], item: item);
        line('Slider min:${c['min'] ?? 0} max:${c['max'] ?? 100}${bound == null ? (c['value'] is num ? ' ${c['value']}' : '') : ' =$bound'}');
      case 'ChoicePicker':
        final options = [for (final o in readList(c['options']) ?? const []) if (o is Map) o];
        final labels = [for (final o in options) _text(o['label'], item: item)];
        if (c['label'] != null) out.add('${pad}Text.small ${_quoted(c['label'], item: item)}');
        final bound = _bindingOf(c['value'], item: item);
        if (c['variant'] == 'multipleSelection') {
          notes.add('ChoicePicker "$cid": several choices are drawn as checkboxes and not bound.');
          for (final l in labels) {
            out.add('${pad}Checkbox ${jsonEncode(l)}');
          }
        } else if (labels.length <= 4) {
          line('SegmentedButton items:${jsonEncode(labels)}${bound == null ? '' : ' =$bound'}');
        } else {
          line('Select items:${jsonEncode(labels)}${bound == null ? '' : ' =$bound'}');
        }
      case 'DateTimeInput':
        if (c['label'] != null) out.add('${pad}Text.small ${_quoted(c['label'], item: item)}');
        final bound = _bindingOf(c['value'], item: item);
        final time = c['enableTime'] == true && c['enableDate'] != true;
        line('${time ? 'TimePicker' : 'DatePicker'}${bound == null ? '' : ' =$bound'}');
      case 'Tabs':
        notes.add('Tabs "$cid": each tab is laid out in place, its title above its content.');
        out.add('${pad}Column gap:12$grow');
        for (final t in readList(c['tabs']) ?? const []) {
          if (t is! Map) continue;
          out.add('$pad  Text.strong ${_quoted(t['title'], item: item)}');
          child(t['child'], depth + 1);
        }
      case 'Modal':
        notes.add('Modal "$cid": only its trigger is drawn.');
        child(c['trigger'], depth);
      case 'Video' || 'AudioPlayer':
        notes.add('${c['component']} "$cid" is drawn as a placeholder.');
        line('Box h:${c['component'] == 'Video' ? 160 : 44} fill:#FFE5E7EB radius:8');
      case final other:
        notes.add('No component "$other" ("$cid"): left out.');
    }
  }
}
