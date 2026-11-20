// Keys (docs/design/22-notation-parity.md section 2.1): a key on a node line is
// the document's own name, found by the catalog. The walk below writes every
// field of every node type the catalog declares as `key=value` and checks
// where it lands.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/keys.dart';
import 'package:test/test.dart';

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// The value at a binding-style path (`props.style.height`, `fills[0].color`).
Object? _at(Map<String, Object?> node, String path) {
  Object? at = node;
  for (final s in path.split('.')) {
    final name = RegExp(r'^[^\[]*').stringMatch(s)!;
    if (at is! Map) return null;
    at = at[name];
    for (final m in RegExp(r'\[(\d+)\]').allMatches(s)) {
      if (at is! List) return null;
      final i = int.parse(m[1]!);
      at = i < at.length ? at[i] : null;
    }
  }
  return at;
}

/// The line a document type is written on, by its own name.
String _head(String type) => '${type[0].toUpperCase()}${type.substring(1)}';

/// A value of [t] as the notation writes it, and the JSON it is; null for a
/// type the walk has no sample of.
(String, Object?)? _sample(PropType t, Object? defaultValue) {
  if (t.isVariable) return null;
  switch (t.kind) {
    case PropKind.boolean:
      final v = defaultValue != true;
      return ('$v', v);
    case PropKind.integer:
      final v = (t.min != null && t.min! > 3) ? t.min!.toInt() : (t.max != null && t.max! < 3 ? t.max!.toInt() : 3);
      return ('$v', v);
    case PropKind.number:
      final num v = t.max != null && t.max! <= 1 ? 0.5 : 3;
      return ('$v', v);
    case PropKind.string:
      return ('"walked"', 'walked');
    case PropKind.enumeration:
      final v = t.values.firstWhere((v) => v != '$defaultValue', orElse: () => t.values.first);
      return (v, v);
    case PropKind.value:
      final Object? v = switch (t.name) {
        'Color' => '#FF123457',
        'AxisSize' => 120,
        'EdgeInsets' => 8,
        'BorderRadius' => 4,
        'BoxConstraints' => {'maxWidth': 100},
        'FontWeight' => 600,
        'IconData' => 'star',
        'Offset' => {'x': 1, 'y': 2},
        'Size' => {'width': 10, 'height': 20},
        'Alignment' => 'center',
        'AxisPosition' => 10,
        _ => null,
      };
      if (v == null) return null;
      return (jsonEncode(v), v);
    case PropKind.list:
      return ('[]', const <Object?>[]);
    case PropKind.object:
      // A record of its first field the walk has a sample of.
      for (final f in t.fields) {
        if (f.type.kind == PropKind.object || f.type.kind == PropKind.json) continue;
        final v = _sample(f.type, f.defaultValue);
        if (v != null) return (jsonEncode({f.key: v.$2}), {f.key: v.$2});
      }
      return null;
    case PropKind.json:
      return ('{"walked":1}', {'walked': 1});
  }
}

void main() {
  const catalog = standardCatalog;

  /// [line] expanded (closed vocabulary): its node `n`, with no issue.
  Map<String, Object?> read(String line) {
    final r = parseNotation(line, catalog: catalog);
    expect(r.issues, isEmpty, reason: line);
    return _node(r, 'n');
  }

  /// [key]=[value] on a [head] line: the document has [expected] at [path],
  /// the printer's key for [path] is [key], and the document prints and
  /// reads back the same.
  void word(String head, String key, String value, String path, Object? expected) {
    final n = read('$head#n $key=$value');
    expect(_at(n, path), expected, reason: '$head $key=$value');
    expect(notationKeyPath(key, '${n['type']}', catalog: catalog), path);
    expect(notationKeyFor(path, '${n['type']}', catalog: catalog), key);
    final doc = parseNotation('$head#n $key=$value', catalog: catalog).document;
    final printed = printNotation(doc, catalog: catalog);
    expect(parseNotation(printed, catalog: catalog, options: notationOptionsFor(doc)).document['nodes'], doc['nodes'], reason: printed);
  }

  group('a key is the document\'s own name, found by the catalog (section 2.1)', () {
    test('a layout field: squeezable, x, the bounds of the constraints', () {
      word('Column', 'squeezable', 'false', 'layout.squeezable', false);
      word('Column', 'x', '10', 'layout.x', 10);
      word('Column', 'minWidth', '200', 'layout.constraints.minWidth', 200);
      word('Column', 'maxHeight', '300', 'layout.constraints.maxHeight', 300);
      word('Column', 'columnSpan', '2', 'layout.columnSpan', 2);
      expect(_node(parseNotation('Column#n squeezable=false', catalog: catalog), 'n')['props'], isNot(contains('squeezable')));
    });

    test('a field of the text style where the type shows text; height on a Text is its line height', () {
      word('Text', 'letterSpacing', '0.4', 'props.style.letterSpacing', 0.4);
      word('Text', 'height', '1.2', 'props.style.height', 1.2);
      word('Text', 'fontStyle', 'italic', 'props.style.fontStyle', 'italic');
      // …starting from the style the line's words start from.
      expect(_at(read('Text#n letterSpacing=0.4'), 'props.style.fontSize'), isNotNull);
      word('Input', 'decorationThickness', '2', 'props.style.decorationThickness', 2);
      word('ChoiceChip', 'fontStyle', 'italic', 'props.labelStyle.fontStyle', 'italic');
      // Where there is no text style, height is the layout's.
      word('Column', 'h', '40', 'layout.height', 40);
    });

    test('a decoration field, where the type is decorated', () {
      word('Column', 'shape', 'circle', 'decoration.shape', 'circle');
      word('Column', 'strokeSides', 'bottom', 'decoration.strokeSides', 'bottom');
      word('Column', 'blendMode', 'multiply', 'decoration.blendMode', 'multiply');
      // A text takes the clip keys (its shape among them) but no box paint.
      final r = parseNotation('Text#n strokeSides=bottom', catalog: catalog);
      expect(r.issues.single.message, 'A Text has no "strokeSides": left out.');
    });

    test('a field of the node and a behavior', () {
      word('Column', 'opacity', '0.5', 'opacity', 0.5);
      word('Column', 'focusable', 'true', 'focusable', true);
      word('Column', 'ignorePointer', 'true', 'ignorePointer', true);
      word('Column', 'textDirection', 'rtl', 'textDirection', 'rtl');
      // `node.` where a prop has the name: a chip's own tooltip and the node's.
      word('ActionChip', 'tooltip', '"Own"', 'props.tooltip', 'Own');
      word('ActionChip', 'node.tooltip', '"Node"', 'tooltip', 'Node');
    });

    test('a dotted key is the path from the field; the full path from the node always reads', () {
      word('Column', 'pan.axis', 'horizontal', 'pan.axis', 'horizontal');
      // (A bound of the constraints is a layout field by its own name.)
      word('Column', 'maxWidth', '720', 'layout.constraints.maxWidth', 720);
      expect(_at(read('Column#n constraints.maxWidth=720'), 'layout.constraints.maxWidth'), 720);
      word('Column', 'dropTarget.accepts', '["clips"]', 'dropTarget.accepts', ['clips']);
      word('Column', 'fills[0].color', '"#FF123457"', 'decoration.fills[0].color', '#FF123457');
      expect(_at(read('Text#n style.letterSpacing=0.4'), 'props.style.letterSpacing'), 0.4);
      expect(_at(read('Column#n layout.x=10'), 'layout.x'), 10);
      expect(_at(read('Text#n props.style.height=1.2'), 'props.style.height'), 1.2);
      expect(_at(read('Column#n decoration.shape=circle'), 'decoration.shape'), 'circle');
      expect(_at(read('Column#n layout.x=10'), 'props'), isNot(contains('layout')));
      // An Input's own decoration (its InputDecoration) by its path.
      expect(_at(read('Input#n decoration.counterText="3/10"'), 'props.decoration.counterText'), '3/10');
    });

    test('a JSON value: a list or a map', () {
      word('Column', 'effects', '[{"type":"layerBlur","radius":4}]', 'decoration.effects', [
        {'type': 'layerBlur', 'radius': 4},
      ]);
      word('Column', 'pan', '{"axis":"vertical"}', 'pan', {'axis': 'vertical'});
    });

    test('key={expression} binds whatever path the key is', () {
      for (final (line, path) in [
        ('Column#n x={a*2}', 'layout.x'),
        ('Column#n squeezable={a}', 'layout.squeezable'),
        ('Text#n letterSpacing={a}', 'props.style.letterSpacing'),
        ('Column#n pan.axis={a}', 'pan.axis'),
        ('Column#n minWidth={a}', 'layout.constraints.minWidth'),
        ('Column#n decoration.shape={a}', 'decoration.shape'),
        ('Column#n opacity={a}', 'opacity'),
      ]) {
        final bind = read(line)['bind'] as Map;
        expect(bind.keys, [path], reason: line);
      }
      expect((read('Column#n x={a*2}')['bind'] as Map)['layout.x'], r'${= a*2}');
    });

    test('an enum word is checked against its enum, the nearest said', () {
      final r = parseNotation('Text#n textAlign=centre', catalog: catalog);
      expect(r.issues.single.message, 'A Text\'s textAlign is one of left, right, center, justify, start, end: not "centre" (did you mean textAlign=center?).');
      expect(_node(r, 'n')['props'], isNot(contains('textAlign')));
      final s = parseNotation('Column#n shape=cirlce', catalog: catalog);
      expect(s.issues.single.message, contains('(did you mean shape=circle?)'));
    });

    test('a record given a word is said with its fields', () {
      final r = parseNotation('Column#n pan=horizontal', catalog: catalog);
      expect(r.issues.single.message, startsWith('A Column\'s pan is a Pan: write its fields, pan.enabled=… (enabled, axis,'));
      expect(_node(r, 'n'), isNot(contains('pan')));
    });

    test('a key that is none of these is said with the nearest name, never a silent prop', () {
      for (final (line, message) in [
        ('Column#n rotate=45', 'A Column has no "rotate": left out.'),
        ('Text#n letterSpaceing=0.4', 'A Text has no "letterSpaceing" (did you mean letterSpacing?): left out.'),
        ('Column#n squeezeable=false', 'A Column has no "squeezeable" (did you mean squeezable?): left out.'),
        ('Column#n pan.axs=horizontal', 'A Column has no "pan.axs" (did you mean pan.axis?): left out.'),
        ('Column#n layout.with=10', 'A Column has no "layout.with" (did you mean layout.width?): left out.'),
        ('Text#n gap=4', 'A Text has no "gap": left out.'),
      ]) {
        final r = parseNotation(line, catalog: catalog);
        expect(r.issues.map((i) => i.message), [message], reason: line);
        final n = _node(r, 'n');
        expect(jsonEncode(n), isNot(contains(RegExp(r'rotate|letterSpaceing|squeezeable|axs|"with"|spacing'))), reason: line);
      }
    });

    test('in the open vocabulary an unknown key is recorded, not said', () {
      final r = parseNotation('Column#n rotate=45 pan.axs=horizontal textAlign=centre', catalog: catalog, options: const NotationOptions().open());
      expect(r.issues, isEmpty);
      expect(r.vocabulary.map((u) => '${u.kind} ${u.word}'), containsAll(['parameter rotate', 'parameter pan.axs']));
      expect(jsonEncode(_node(r, 'n')), isNot(contains(RegExp(r'rotate|axs'))));
    });

    test('the notation\'s own words still come first, and a word of several paths is no key of one', () {
      expect(_at(read('Column#n gap=12'), 'props.spacing'), 12);
      expect(_at(read('Column#n pad=16'), 'layout.padding'), 16);
      expect(_at(read('Text#n size=18'), 'props.style.fontSize'), 18);
      expect(notationKeyFor('props.style.fontSize', 'text', catalog: catalog), 'size');
      expect(notationKeyFor('props.spacing', 'column', catalog: catalog), 'gap');
      expect(notationKeyFor('layout.width', 'column', catalog: catalog), 'w');
      expect(notationKeyFor('layout.padding', 'column', catalog: catalog), 'pad');
      expect(notationKeyPath('fill', 'column', catalog: catalog), isNull);
      expect(notationKeyPath('color', 'column', catalog: catalog), isNull);
      expect(notationKeyPath('border', 'column', catalog: catalog), isNull);
    });
  });

  group('the catalog walk: every field of every node type, written key=value, lands at its path', () {
    // Each type on the line that writes it: its own name, else a short name
    // of the notation that is that type (`Select` a dropdown). The canvas is
    // no line of its own.
    final heads = <String, String>{};
    for (final w in catalog.widgets) {
      if (w.type == 'canvas' || w.type[0] == w.type[0].toUpperCase()) continue;
      // (`Image` is a box with an image fill: not a box alone.)
      for (final head in [_head(w.type), for (final e in notationTypes.entries) if (e.value.type == w.type && e.key != 'Image') e.key]) {
        final probe = parseNotation('$head#n', catalog: catalog);
        if (probe.issues.isEmpty && (probe.document['nodes'] as Map?)?['n']?['type'] == w.type) {
          heads[w.type] = head;
          break;
        }
      }
    }

    test('every node type but a few is walked', () {
      final all = catalog.widgets.where((w) => w.type != 'canvas' && w.type[0] != w.type[0].toUpperCase()).map((w) => w.type);
      // A Box is a column, a Grid a column of rows, a Badge a row, an
      // AppBar a column, a Modal the screen's: no line is the type itself.
      // (radialGauge is the node as written since the paint family, 4.6.)
      expect(all.where((t) => !heads.containsKey(t)).toSet(), {'box', 'gridView', 'badge', 'appBar', 'modal'});
    });

    final misses = <String>[];
    var count = 0;
    void check(String type, String path, String key, String value, Object? expected, {bool bound = false}) {
      final line = '${heads[type]}#n $key=$value';
      count++;
      final r = parseNotation(line, catalog: catalog);
      final node = r.issues.isEmpty ? _node(r, 'n') : null;
      final bind = node?['bind'] as Map?;
      final got = node == null ? null : (bound ? (bind == null ? null : bind[path]) : _at(node, path));
      if (r.issues.isNotEmpty || jsonEncode(got) != jsonEncode(expected)) {
        misses.add('$line -> ${r.issues.isEmpty ? '${bound ? 'bind ' : ''}$path is ${jsonEncode(got)}' : r.issues.first.message}');
      }
    }

    void walk(String type, String path, PropDef<Object?> def, {bool nested = true}) {
      final s = _sample(def.type, def.defaultValue);
      if (s != null) {
        final key = notationKeyFor(path, type, catalog: catalog);
        expect(notationKeyPath(key, type, catalog: catalog), path, reason: '$key on $type');
        check(type, path, key, s.$1, s.$2);
        // The full path always reads.
        final full = path.startsWith('props.') || path.startsWith('layout.') || path.startsWith('decoration.') ? path : 'node.$path';
        if (full != key) check(type, path, full, s.$1, s.$2);
        // key={expression} binds the path; a tooltip reads its data itself,
        // so one worked out is the node's own (docs/design/21).
        check(type, path, key, '{walk.value}', r'${walk.value}', bound: path != 'tooltip');
      }
      // An object's own fields, dotted.
      if (nested && def.type.kind == PropKind.object && def.type.name != 'TextStyle') {
        for (final f in def.type.fields) {
          walk(type, '$path.${f.key}', f, nested: false);
        }
      }
    }

    test('every prop, text style field, layout, decoration, node and behavior field', () {
      for (final type in heads.keys) {
        final spec = catalog.widget(type)!;
        for (final p in spec.props) {
          walk(type, 'props.${p.key}', p);
        }
        if (notationTextStyleProp(spec) case final style?) {
          for (final f in style.type.fields) {
            walk(type, 'props.${style.key}.${f.key}', f, nested: false);
          }
        }
        for (final f in LayoutFields.all) {
          walk(type, 'layout.${f.key}', f);
        }
        for (final f in DecorationFields.all) {
          if (spec.decorated || f.key == 'effects') walk(type, 'decoration.${f.key}', f);
        }
        for (final f in [...NodeFields.all, ...BehaviorFields.all]) {
          walk(type, f.key, f);
        }
      }
      expect(count, greaterThan(10000));
      expect(misses, isEmpty, reason: '${misses.length} of $count:\n${misses.take(400).join('\n')}');
    });
  });
}
