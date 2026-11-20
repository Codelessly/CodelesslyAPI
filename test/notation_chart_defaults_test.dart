// What the chart words supply when a line gives only its data: series
// colors left to the theme, a smooth line with no fill, a donut's total and
// where its legend is drawn, bars of several series, and the colors a
// theme's accent gives.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

NotationResult _parse(String text, {double width = 1280, bool open = false}) {
  final options = NotationOptions(width: width);
  return Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog, options: open ? options.open() : options));
}

Map<String, Object?> _node(NotationResult r, String id) => ((r.document['nodes'] as Map)[id] as Map).cast<String, Object?>();
Map<String, Object?> _props(NotationResult r, String id) => (_node(r, id)['props'] as Map).cast<String, Object?>();
List<String> _said(NotationResult r) => [for (final i in r.issues) i.message];

void main() {
  group('the colors of an accent', () {
    test('the accent, then seven colors that are not shades of it', () {
      final palette = chartPalette('#FF2563EB')!;
      expect(palette, hasLength(8));
      expect(palette.first, '#FF2563EB');
      expect(palette.toSet(), hasLength(8));
      int channel(String c, int at) => int.parse(c.substring(at, at + 2), radix: 16);
      // Each differs from every other by more than a tint or a shade does
      // in at least the balance of its channels: no two are one hue.
      for (var i = 0; i < palette.length; i++) {
        for (var j = i + 1; j < palette.length; j++) {
          final d = [for (final at in [3, 5, 7]) (channel(palette[i], at) - channel(palette[j], at)).abs()];
          expect(d.reduce((a, b) => a + b), greaterThan(40), reason: '${palette[i]} and ${palette[j]}');
        }
      }
    });

    test('follows the accent: another accent, other colors; a gray accent is followed by colors', () {
      expect(chartPalette('#FF16A34A')!.first, '#FF16A34A');
      expect(chartPalette('#FF16A34A')![1], isNot(chartPalette('#FF2563EB')![1]));
      final gray = chartPaletteOf(0xFF111827);
      expect(gray.first, 0xFF111827);
      for (final c in gray.skip(1)) {
        final r = c >> 16 & 0xFF, g = c >> 8 & 0xFF, b = c & 0xFF;
        expect([r, g, b].reduce((a, b) => a > b ? a : b) - [r, g, b].reduce((a, b) => a < b ? a : b), greaterThan(30));
      }
      expect(chartPalette('primary'), isNull);
      expect(chartPalette('#2563EB')!.first, '#FF2563EB');
    });
  });

  group('a line chart', () {
    test('several series leave their colors to the theme; a written color is the series\'s', () {
      final r = _parse(
          'Column\n  LineChart#c labels=["W1","W2"] series=[{"name":"A","values":[1,2]},{"name":"B","values":[3,4],"color":"#FFDC2626"}]\n');
      expect(_said(r), isEmpty);
      final series = (_props(r, 'c')['series'] as List).cast<Map>();
      expect(series[0].containsKey('color'), isFalse);
      expect(series[1]['color'], '#FFDC2626');
    });

    test('one line of values is smooth, with no fill under it; an AreaChart has its fill', () {
      final r = _parse('Column\n  LineChart#l values=[3,5,4]\n  AreaChart#a data=[{"x":1,"y":2},{"x":2,"y":3}] xField="x" yField="y"\n  lineChart#raw data=[{"x":1,"y":2}]\n');
      expect(_props(r, 'l')['smooth'], isTrue);
      expect(_props(r, 'l')['areaTopColor'], '#00000000');
      expect(_props(r, 'a')['areaTopColor'], '#332563EB');
      // The node as its type spells it is as written.
      expect(_props(r, 'raw').keys, isNot(anyOf(contains('smooth'), contains('areaTopColor'))));
      // What the line says wins.
      final own = _parse('Column\n  LineChart#l values=[3,5,4] smooth=false areaTopColor=#22FF0000\n');
      expect(_props(own, 'l')['smooth'], isFalse);
      expect(_props(own, 'l')['areaTopColor'], '#22FF0000');
    });
  });

  group('a bar chart', () {
    test('with series is the series chart: bars side by side, or stacked one on another', () {
      final r = _parse('''
state rows=[{"q":"Q1","a":3,"b":4}]
Column
  BarChart#g labels=["Q1","Q2"] series=[{"name":"2024","values":[30,42]},{"name":"2025","values":[36,45]}]
  BarChart#s stacked labels=["Q1","Q2"] series=[{"name":"Direct","values":[30,42]},{"name":"Organic","values":[16,15]}]
  BarChart#b labels={map(rows,r=>r.q)} series={[{"name":"A","values":map(rows,r=>r.a)},{"name":"B","values":map(rows,r=>r.b)}]}
''', open: true);
      expect(_said(r), isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'parameter' || u.kind == 'flag'), isEmpty);
      for (final id in ['g', 's', 'b']) {
        expect(_node(r, id)['type'], 'chart');
        expect(_props(r, id)['chartType'], 'bar');
        expect(_props(r, id).containsKey('fitMinY'), isFalse);
      }
      final side = (_props(r, 'g')['series'] as List).cast<Map>(), stacked = (_props(r, 's')['series'] as List).cast<Map>();
      expect([for (final s in side) (s['name'], s['kind'], s['stack'])], [('2024', 'bar', null), ('2025', 'bar', null)]);
      expect([for (final s in stacked) (s['kind'], s['stack'])], [('bar', 's'), ('bar', 's')]);
      expect(_props(r, 'g')['data'], [
        {'label': 'Q1', 's0': 30, 's1': 36},
        {'label': 'Q2', 's0': 42, 's1': 45},
      ]);
      expect((_node(r, 'b')['bind'] as Map)['props.data'], contains('"s1": get(map(rows,r=>r.b), i)'));
    });

    test('values that follow the state: the chart chooses its lines and their figures', () {
      final r = _parse('state v=[3,5,4]\nColumn\n  BarChart#b values={v}\n  BarChart#w values=[3,5,4]\n  BarChart#own values={v} max=10\n');
      expect(_said(r), isEmpty);
      expect(_node(r, 'b')['type'], 'barChart');
      expect((_node(r, 'b')['bind'] as Map)['props.values'], r'${v}');
      expect(_props(r, 'b')['gridValues'], isTrue);
      expect(_props(r, 'b')['gridLabelsLeft'], isTrue);
      // Written out, its figures are in the document; a top of its own is the chart's.
      expect(_props(r, 'w').containsKey('gridValues'), isFalse);
      expect(_props(r, 'w')['gridLabels'], ['0', '2', '4', '']);
      expect(_props(r, 'own').containsKey('gridValues'), isFalse);
    });

    test('ten thousand and more is written in thousands on its axis', () {
      final r = _parse('Column\n  BarChart#b values=[12400,27300]\n  BarChart#m values=[1200000,2900000]\n');
      expect(_props(r, 'b')['gridLabels'], ['0', '10K', '20K', '']);
      expect(_props(r, 'm')['gridLabels'], ['0', '1M', '2M', '']);
    });
  });

  group('a donut', () {
    test('has its total in its hole; total= names it or leaves it out, and a Pie has no hole', () {
      final r = _parse('''
Column
  Donut#d values=[60,40] labels=["Rent","Food"]
  Donut#v values=[60,40] labels=["a","b"] total="Visitors"
  Donut#n values=[60,40] labels=["c","e"] total=false
  Pie#p values=[60,40] labels=["f","g"]
  Stack
    Donut#s values=[60,40]
    Text "72%"
''', width: 390, open: true);
      expect(_said(r), isEmpty);
      expect(r.vocabulary.where((u) => u.kind == 'parameter'), isEmpty);
      expect(_props(r, 'd')['centerLabel'], 'Total');
      expect(_props(r, 'v')['centerLabel'], 'Visitors');
      expect(_props(r, 'n').containsKey('centerLabel'), isFalse);
      expect(_props(r, 'p').containsKey('centerLabel'), isFalse);
      // The page's own text is over a donut in a Stack.
      expect(_props(r, 's').containsKey('centerLabel'), isFalse);
      for (final id in ['d', 'v', 'n', 'p', 's']) {
        expect(_props(r, id).containsKey('total'), isFalse);
      }
    });

    test('the legend written out on a page is the only one; elsewhere the chart draws its own, with room beside it', () {
      // On a page: the row of the chart and its legend, the chart told to draw none.
      final page = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n');
      expect(_node(page, 'd')['type'], 'row');
      expect(_props(page, 'dChart')['legend'], isFalse);
      expect((_node(page, 'dChart')['layout'] as Map)['width'], 160);
      // Lists that follow the state, or a narrow canvas: the chart's own
      // legend, the chart as wide as what it is in.
      final bound = _parse('state v=[60,40]\nstate l=["Rent","Food"]\nColumn\n  Donut#d values={v} labels={l} h=200\n');
      expect(_node(bound, 'd')['type'], 'chart');
      expect(_props(bound, 'd').containsKey('legend'), isFalse);
      expect((_node(bound, 'd')['layout'] as Map)['width'], {'fill': 0});
      final narrow = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n', width: 390);
      expect(_node(narrow, 'd')['type'], 'chart');
      expect((_node(narrow, 'd')['layout'] as Map)['width'], {'fill': 0});
      // No labels, legend=false, or in a Row: the square it was.
      final square = _parse('Column\n  Donut#a values=[60,40]\n  Donut#b values=[60,40] labels=["Rent","Food"] legend=false\n  Row\n    Donut#c values=[60,40] labels=["x","y"]\n', width: 390);
      for (final id in ['a', 'b', 'c']) {
        expect((_node(square, id)['layout'] as Map)['width'], 160, reason: id);
      }
      expect(_props(square, 'b')['legend'], isFalse);
      expect(_props(square, 'a').containsKey('legend'), isFalse);
    });
  });

  group('the chart and the graph say their defaults', () {
    test('a chart selects under the pointer with a tooltip, and rounds its bars', () {
      expect(ChartProps.selectOnHover.defaultValue, isTrue);
      expect(ChartProps.tooltip.defaultValue, isTrue);
      expect(ChartProps.barRadius.defaultValue, 4);
      expect(ChartProps.legend.defaultValue, isNull);
      expect(ChartProps.centerLabel.defaultValue, isNull);
      expect(LineChartProps.scrubEnabled.defaultValue, isTrue);
      expect(BarChartProps.gridValues.defaultValue, isFalse);
    });

    test('a graph\'s legend, palette, inset and rounded scale are keys of its records', () {
      final g = Node.fromJson({
        'type': 'graph',
        'props': {
          'legend': {'show': 'always', 'position': 'right'},
          'style': {'palette': ['#FF111111', '#FF222222'], 'ink': '#FF000000'},
          'xAxis': {'inset': 6, 'maxBarWidth': 24},
          'yAxis': {'nice': true},
          'marks': [
            {'type': 'arc', 'y': 'v', 'center': 'total', 'centerLabel': 'Total'},
            {'type': 'line', 'y': 'v', 'dots': 3},
          ],
        },
      }, id: 'g')!;
      final legend = g.prop(GraphProps.legend);
      expect((legend.get(GraphLegend.showDef), legend.get(GraphLegend.positionDef), legend.get(GraphLegend.valuesDef)), ('always', 'right', true));
      expect(g.prop(GraphProps.style).get(GraphStyle.paletteDef), ['#FF111111', '#FF222222']);
      expect(g.prop(GraphProps.xAxis).get(GraphXAxis.insetDef), 6);
      expect(g.prop(GraphProps.xAxis).get(GraphXAxis.maxBarWidthDef), 24);
      expect(g.prop(GraphProps.yAxis).get(GraphYAxis.niceDef), isTrue);
      final marks = g.prop(GraphProps.marks);
      expect((marks[0].get(GraphMark.centerDef), marks[0].get(GraphMark.centerLabelDef)), ('total', 'Total'));
      expect(marks[1].get(GraphMark.dotsDef), 3);
      // With nothing said: a legend when there is something to tell apart.
      expect(GraphLegend.showDef.defaultValue, 'auto');
    });
  });
}
