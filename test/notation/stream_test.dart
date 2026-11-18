// The notation as it arrives (design 13, principle 5): NotationStream reads
// every line parseNotation reads, and the operations it gives build the same
// document at the end of the stream. Fed line by line: the printed corpus
// (tool/reference/examples, as printNotation writes it) and a sample of each
// form of the document family's, the paint and the media words.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

/// The document [text] builds fed to a NotationStream one line at a time,
/// and the one parseNotation gives, both through the document model.
({String streamed, String whole, List<String> errors}) _both(String text, NotationOptions options) {
  final stream = Catalog.run(standardCatalog, () => NotationStream(catalog: standardCatalog, options: options));
  var doc = LayoutDocument(catalog: standardCatalog);
  final errors = <String>[];
  void apply(List<Json> ops) {
    if (ops.isEmpty) return;
    final a = applyOps(doc, {'ops': ops}, catalog: standardCatalog);
    errors.addAll(a.errors.map((e) => '$e'));
    doc = a.document;
  }

  for (final line in const LineSplitter().convert(text)) {
    apply(Catalog.run(standardCatalog, () => stream.add('$line\n')));
  }
  apply(Catalog.run(standardCatalog, stream.close));
  final whole = Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: options)).document;
  // What no operation carries (the document's id, schema, a component's
  // declaration and previews) is the stream's result.
  final built = {
    ...doc.toJson(),
    for (final e in stream.result!.document.entries)
      if (!const {'nodes', 'roots', 'variables'}.contains(e.key)) e.key: e.value,
  };
  return (
    streamed: jsonEncode(_sorted(LayoutDocument.fromJson(built, catalog: standardCatalog).toJson())),
    whole: jsonEncode(_sorted(LayoutDocument.fromJson(whole, catalog: standardCatalog).toJson())),
    errors: errors,
  );
}

const _samples = <String>[
  // The document line, typed state, the canvas line with what the screen does.
  'document id="checkout" schema=2 scope=page_variables\nstate count:decimal=2\nstate note:text\ncanvas "Trip" path="/trip" h=844 onLoad={count=3}\nColumn\n  Text "{count}"\nevery 1s onTick={count=count+1}',
  // A component's head and its tree.
  'component StatusPill "A short status."\n  param label="Active" required doc="What it says."\n  param tone:neutral|success|danger="neutral"\n  param count:{"kind":"number","flutter":"int"}=0\n  event onChanged:String\n  slot trailing\n  preview "Default" 120x28 label="Active"\nRow#pill gap=4\n  Text#pillLabel "Active"',
  // A tail merged again over what later lines add; a tail that takes away what the words made.
  'Column\n  Row#r {"props":{"crossAxisAlignment":"end"}}\n    Text "a" grow\n  Badge#b "x" {"children":null}',
  // Slots of a plain node.
  'Column\n  ListTile#t\n    slot title\n      Text "Hello"\n    slot trailing\n      Icon "chevron_right"',
  // A list of its own line over data; an each with stagger.
  'state rows=[{"n":"a"},{"n":"b"}]\nColumn\n  ListView#l h=300\n    each r in rows\n      Row#t gap=4\n        Text "{r.n}"\n  each r in rows stagger=80\n    Text "{r.n}"',
  // Record lines: custom paint and an animation.
  'Column\n  box#n w=40 h=40\n    customPaint viewBox=[40,40]\n      circle c=[20,20] radius=10 fill=#FF000000\n    animation#a duration=300\n      track path=opacity from=0 to=1\n  Text "after"',
  // Media words.
  'Column#root\n  Flex#a gap=24 max899.direction=vertical phone.pad=12\n  Row#b hidden minDesktop.visible=true',
  // Other canvases.
  'Column\n  Text "home"\nCanvas#about "About" path="about"\n  Column\n    Text "about"',
];

void main() {
  group('a stream gives the document parseNotation gives', () {
    for (final (i, text) in _samples.indexed) {
      test('sample ${i + 1}: ${text.split('\n').first}', () {
        final r = _both(text, const NotationOptions());
        expect(r.errors, isEmpty, reason: text);
        expect(r.streamed, r.whole, reason: text);
      });
    }

    test('every document of tool/reference/examples, printed', () {
      final files = Directory('tool/reference/examples').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      var read = 0;
      final wrong = <String>[];
      for (final f in files) {
        final json = jsonDecode(f.readAsStringSync());
        if (json is! Map<String, Object?> || json['nodes'] is! Map || json['roots'] is! List) continue;
        // A page calling its site's components needs their catalog.
        if ((json['nodes'] as Map).values.any((n) => n is Map && standardCatalog.widget('${n['type']}') == null)) continue;
        final text = Catalog.run(standardCatalog, () => printNotation(json, catalog: standardCatalog));
        final r = _both(text, notationOptionsFor(json));
        read++;
        if (r.errors.isNotEmpty || r.streamed != r.whole) wrong.add('${f.path}: ${r.errors.take(2).join('; ')}');
      }
      expect(read, greaterThan(20));
      expect(wrong, isEmpty);
    });
  });
}
