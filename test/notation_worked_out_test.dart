// What is worked out from the state where it was read by nothing, with no
// word said: a state written as a formula read by a function or a drawing,
// a function with no type, a painter's own key, a chart's lists and rows.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {double width = 1280, bool open = false}) {
  final options = NotationOptions(width: width);
  return Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: open ? options.open() : options));
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

Map<String, Object?> _variable(NotationResult r, String name) {
  final found = <Map<String, Object?>>[];
  void walk(Object? v) {
    if (v is Map) {
      if (v['name'] == name && (v.containsKey('formula') || v.containsKey('value'))) found.add(v.cast<String, Object?>());
      v.values.forEach(walk);
    } else if (v is List) {
      v.forEach(walk);
    }
  }

  walk(r.document);
  return found.single;
}

void main() {
  group('a state written as a formula, with no type', () {
    test('is written out in a function and a formula variable that read it, before or after it', () {
      final r = _parse('''
state pick="Any"
state early(r):boolean={r.minutes <= cap}
state limit={pick == "15 min" ? 15 : 100000}
state cap={limit / 1000}
state fits(r):boolean={r.minutes <= limit}
state double:decimal={limit * 2}
state shadow(limit):boolean={limit > 5}
Column
  Text "x"
''');
      expect(_said(r), isEmpty);
      const limit = '(pick == "15 min" ? 15 : 100000)';
      expect(_variable(r, 'fits')['formula'], 'r.minutes <= $limit');
      expect(_variable(r, 'double')['formula'], '$limit * 2');
      // One declared after the function that reads it, through another.
      expect(_variable(r, 'early')['formula'], 'r.minutes <= ($limit / 1000)');
      // A parameter of that name is the function's own.
      expect(_variable(r, 'shadow')['formula'], 'limit > 5');
      expect(jsonEncode(r.document), isNot(contains('"name":"limit"')));
    });

    test('is written out in a drawing\'s text and numbers', () {
      final r = _parse('''
state price=4
state qty=3
state total={price * qty}
Box#b w=200 h=60
  customPaint viewBox=[200,60]
    paragraph "Peak {total}" offset=[{total},8]
''');
      expect(_said(r), isEmpty);
      final op = ((_node(r, 'b')['customPaint'] as Map)['painter'] as List).single as Map;
      expect(op['text'], contains('price * qty'));
      expect(op['text'], isNot(contains(r'${total}')));
      expect((op['offset'] as List).first, contains('price * qty'));
    });
  });

  test('a function with no type is read: its type is what its formula starts as; one with no formula says the line to write', () {
    final r = _parse('state rows:list=[]\nstate fits(c)={c.minutes > 3}\nColumn\n  Text "{count(rows, c => fits(c))}"\n');
    expect(_said(r), isEmpty);
    final fits = (r.document['variables'] as Map).values.expand((l) => l as List).cast<Map>().firstWhere((v) => v['name'] == 'fits');
    expect((fits['type'], fits['formula']), ('boolean', 'c.minutes > 3'));
    expect(fits['parameters'], ['c']);
    final bare = _parse('state fits(c)=c.minutes\nColumn\n  Text "a"\n');
    expect(_said(bare).single, 'A function is a formula in braces: state fits(c)={…}.');
  });

  test('a painter\'s own key that is worked out is said and left out; its ops\' are read', () {
    final r = _parse('''
state levels=[30,60,45]
Box#b w=fill h=64
  customPaint viewBox=[{length(levels) * 10},100]
    repeat count={length(levels)}
      rect rect=[{index * 10},0,6,{levels[index]}] fill=#FF2563EB
''');
    expect(_said(r).single, allOf(contains('A customPaint\'s viewBox is a value, never worked out'), contains('viewBox=[240,160]'), contains('left out')));
    final paint = _node(r, 'b')['customPaint'] as Map;
    expect(paint.containsKey('viewBox'), isFalse);
    expect(((paint['painter'] as List).single as Map)['count'], r'${= length(levels)}');
    // Written as numbers it is kept.
    final ok = _parse('Box#b w=fill h=64\n  customPaint viewBox=[30,100] fit=contain\n    rect rect=[0,0,6,40] fill=#FF2563EB\n');
    expect(_said(ok), isEmpty);
    expect((_node(ok, 'b')['customPaint'] as Map)['viewBox'], [30, 100]);
  });

  group('a chart\'s lists that follow the state', () {
    const state = 'state pts=[{"h":"Mon","t":3,"u":1},{"h":"Tue","t":5,"u":2}]\nstate who="Tee"\n';

    for (final open in [false, true]) {
      test('a LineChart\'s labels, values and series are its rows worked out (${open ? 'open' : 'closed'})', () {
        final r = _parse('''
${state}Column
  LineChart#one labels={map(pts,p=>p.h)} values={map(pts,p=>p.t)}
  LineChart#two labels={map(pts,p=>p.h)} series={[{"name":who,"values":map(pts,p=>p.t)},{"name":"U","values":{map(pts,p=>p.u)},"color":"#FFDC2626"}]}
  LineChart#three labels=["a","b"] series={[{"name":"T","values":map(pts,p=>p.t)}]}
  AreaChart#four values={map(pts,p=>p.t)} labels=["a","b"]
''', open: open);
        expect(_said(r), isEmpty);
        expect(r.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
        for (final id in ['one', 'two', 'three', 'four']) {
          final n = _node(r, id);
          expect(n['type'], 'chart', reason: id);
          final bind = (n['bind'] as Map).cast<String, Object?>();
          expect(bind.keys.where((k) => const {'props.labels', 'props.values', 'props.series'}.contains(k)), isEmpty, reason: id);
          expect(bind['props.data'], startsWith(r'${= map(range(length('), reason: id);
          expect((n['props'] as Map).containsKey('labels'), isFalse, reason: id);
        }
        final two = _node(r, 'two');
        final series = ((two['props'] as Map)['series'] as List).cast<Map>();
        expect(series.map((s) => s['field']), ['s0', 's1']);
        expect(series[1]['name'], 'U');
        expect(series[1]['color'], '#FFDC2626');
        expect((two['bind'] as Map)['props.data'], allOf(contains('"s0": get(map(pts,p=>p.t), i)'), contains('"s1": get(map(pts,p=>p.u), i)'), contains('get(map(pts,p=>p.h), i)')));
        expect(jsonEncode(two['bind']), contains('who'));
        expect((((_node(r, 'four')['props'] as Map)['series'] as List).single as Map)['kind'], 'area');
        expect((_node(r, 'three')['bind'] as Map)['props.data'], contains('["a","b"]'));
      });
    }

    test('a series that is one variable is said: how many lines it has is not known', () {
      final r = _parse('${state}state lines=[]\nColumn\n  LineChart#c labels=["a","b"] series={lines}\n');
      expect(_said(r).single, contains('series={[{"name":"Visits","values":map(rows, r => r.visits)}]}'));
    });

    test('what is said of a list that is no JSON is a line that is read', () {
      // (A list that is no JSON and reads the state is one worked out: read as in braces.)
      final again = _parse('${state}Column\n  LineChart#c labels=["a","b"] series=[{"name":"T","values":{map(pts,p=>p.t)}}]\n');
      expect(_said(again), isEmpty);
      expect(_node(again, 'c')['type'], 'chart');
      expect((_node(again, 'c')['bind'] as Map)['props.data'], contains('"s0": get(map(pts,p=>p.t), i)'));
    });

    test('a Donut\'s values, labels and colors are its rows worked out', () {
      final r = _parse('${state}Column\n  Donut#d values={map(pts,p=>p.t)} labels={map(pts,p=>p.h)}\n  Donut#e values=[2,3] labels={map(pts,p=>p.h)} colors=["#FF111111","#FF222222"]\n', open: true);
      expect(_said(r), isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
      final d = _node(r, 'd'), e = _node(r, 'e');
      expect((d['props'] as Map)['chartType'], 'donut');
      expect((d['bind'] as Map)['props.data'], allOf(contains('"value": get(map(pts,p=>p.t), i)'), contains('"label": text(coalesce(get(map(pts,p=>p.h), i), ""))')));
      // With no colors written its rows have none: each slice takes the
      // theme's next series color where it is drawn.
      expect((d['bind'] as Map)['props.data'], isNot(contains('"color"')));
      expect((e['bind'] as Map)['props.data'], allOf(contains('get([2,3], i)'), contains('coalesce(get(["#FF111111","#FF222222"], i)')));
      // Written out, it is as it was: its rows in the document.
      final plain = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n', width: 390);
      expect(((_node(plain, 'd')['props'] as Map)['data'] as List).length, 2);
      expect(_node(plain, 'd').containsKey('bind'), isFalse);
    });
  });

  group('a chart over data={rows} with xField and yField', () {
    test('a BarChart\'s values and labels are those fields of the rows', () {
      final r = _parse('''
state pts=[{"h":"Mon","t":3},{"h":"Tue","t":5}]
Column
  BarChart#bound data={pts} xField="h" yField="t"
  BarChart#written data=[{"d":"A","n":2},{"d":"B","n":5}] xField="d" yField="n"
''', open: true);
      expect(_said(r), isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
      final bound = _node(r, 'bound'), written = _node(r, 'written');
      expect((bound['bind'] as Map)['props.values'], r'${= map(pts, row => get(row, "t"))}');
      expect((bound['bind'] as Map)['props.labels'], r'${= map(pts, row => text(coalesce(get(row, "h"), "")))}');
      expect((bound['bind'] as Map).containsKey('data'), isFalse);
      expect((written['props'] as Map)['values'], [2, 5]);
      expect((written['props'] as Map)['labels'], ['A', 'B']);
      for (final n in [bound, written]) {
        expect((n['props'] as Map).keys, isNot(anyOf(contains('xField'), contains('yField'), contains('data'))));
      }
    });

    test('an AreaChart keeps its rows and fills under its line', () {
      final r = _parse('state pts=[{"h":"Mon","t":3}]\nColumn\n  AreaChart#a data={pts} xField="h" yField="t"\n  LineChart#l data={pts} xField="h" yField="t"\n');
      expect(_said(r), isEmpty);
      expect(_node(r, 'a')['type'], 'lineChart');
      expect((_node(r, 'a')['props'] as Map)['areaTopColor'], '#332563EB');
      // A line has no fill under it.
      expect((_node(r, 'l')['props'] as Map)['areaTopColor'], '#00000000');
      expect((_node(r, 'a')['bind'] as Map)['props.data'], r'${pts}');
    });
  });
}
