// What the chart words write when a line gives only its data. A chart node
// that leaves a key out draws as its type always has; the look of the
// notation's words (LineChart, AreaChart, BarChart, Donut, Pie, Sparkline)
// is the keys they write on the node, each one the line's own to say
// otherwise. And the colors a theme's accent gives.
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

    test('one series is drawn as several are: round lines the chart chooses, each with its figure', () {
      final r = _parse('state v=[3,5,4]\nColumn\n  BarChart#b values={v}\n  BarChart#w values=[3,5,4] labels=["a","b","c"]\n  BarChart#own values={v} max=10\n  BarChart#said values=[3,5] gridLabels=["0","5"] labelFontSize=9 labelFontFamily="Inter"\n  barChart#raw values=[3,5]\n');
      expect(_said(r), isEmpty);
      expect(_node(r, 'b')['type'], 'barChart');
      expect((_node(r, 'b')['bind'] as Map)['props.values'], r'${v}');
      for (final id in ['b', 'w']) {
        final p = _props(r, id);
        // The scale and its figures are the chart's to choose, as the values come.
        expect([p['gridValues'], p['gridLabelsLeft'], p['gridLines'], p['gridLabelWidth']], [true, true, 4, 44], reason: id);
        expect(p.keys, isNot(anyOf(contains('max'), contains('gridLabels'))), reason: id);
        // Labels as a series chart's: 11 px, in no family of the chart's own, in a band 22 high.
        expect([p['labelFontSize'], p['labelFontFamily'], p['labelAreaHeight']], [11, '', 22], reason: id);
      }
      // A top or labels of its own are the chart's, and so is what the line says of its labels.
      expect(_props(r, 'own').containsKey('gridValues'), isFalse);
      expect(_props(r, 'said').containsKey('gridValues'), isFalse);
      expect([_props(r, 'said')['labelFontSize'], _props(r, 'said')['labelFontFamily']], [9, 'Inter']);
      // The node as its type spells it is as written.
      expect(_props(r, 'raw').keys, ['values']);
    });

    test('bars of several series are as wide at the most as one series\' are', () {
      final r = _parse('Column\n  BarChart#g labels=["Q1"] series=[{"name":"A","values":[3]},{"name":"B","values":[4]}]\n  BarChart#one values=[3]\n');
      expect(_props(r, 'g')['maxBarWidth'], 40);
      expect(_props(r, 'one')['maxBarWidth'], 40);
    });
  });

  group('a donut', () {
    test('its slices are left to the theme: no color is written unless the line writes colors', () {
      final r = _parse('Column\n  Donut#d values=[4,3,2] labels=["a","b","c"]\n  Donut#c values=[4,3] labels=["e","f"] colors=["#FF111111","#FF222222"]\n');
      expect((_props(r, 'd')['data'] as List).cast<Map>().every((row) => !row.containsKey('color')), isTrue);
      expect([for (final row in (_props(r, 'c')['data'] as List).cast<Map>()) row['color']], ['#FF111111', '#FF222222']);
    });

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

    test('one legend, the chart\'s own: wherever it is written, with room beside the ring', () {
      Map<String, Object?> layout(NotationResult r, String id) => (_node(r, id)['layout'] as Map).cast<String, Object?>();
      // On a page, on a narrow canvas, with lists written out or following
      // the state: the same node, told to draw its legend, as wide as what
      // it is in.
      final page = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n');
      final narrow = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n', width: 390);
      final bound = _parse('state v=[60,40]\nstate l=["Rent","Food"]\nColumn\n  Donut#d values={v} labels={l} h=200\n');
      for (final r in [page, narrow, bound]) {
        expect(_said(r), isEmpty);
        expect(_node(r, 'd')['type'], 'chart');
        expect(_props(r, 'd')['legend'], isTrue);
        expect(layout(r, 'd')['width'], {'fill': 0});
        expect((r.document['nodes'] as Map).keys.where((k) => '$k'.startsWith('d')), ['d']);
      }
      // No labels: nothing to list, the square it was. legend=false: none.
      // In a Row: the square, its legend under the ring. In a Stack: the
      // page's own things are over it, and it keeps its box.
      final other = _parse('Column\n  Donut#a values=[60,40]\n  Donut#b values=[60,40] labels=["Rent","Food"] legend=false\n  Row\n    Donut#c values=[60,40] labels=["x","y"]\n  Stack\n    Donut#s values=[60,40] labels=["p","q"]\n  Donut#w values=[60,40] labels=["m","n"] w=300\n', width: 390);
      for (final id in ['a', 'b', 's']) {
        expect(layout(other, id)['width'], 160, reason: id);
      }
      // With a legend it is 200 high (and, in a Row, wide) with no size written.
      expect((layout(other, 'c')['width'], layout(other, 'c')['height']), (200, 200));
      expect(layout(narrow, 'd')['height'], 200);
      expect(layout(bound, 'd')['height'], 200);
      expect(layout(other, 'w')['width'], 300);
      expect(_props(other, 'a').containsKey('legend'), isFalse);
      expect(_props(other, 'b')['legend'], isFalse);
      expect(_props(other, 'c')['legend'], isTrue);
      expect(_props(other, 's').containsKey('legend'), isFalse);
      expect(_props(other, 'w')['legend'], isTrue);
    });
  });

  group('the words write their look on the node', () {
    Map<String, Object?> only(Map<String, Object?> props, List<String> keys) => {for (final k in keys) k: props[k]};
    const look = ['selectOnHover', 'tooltip', 'legend', 'roundScale', 'plotInset', 'axisFontSize'];

    test('a LineChart or an AreaChart of series', () {
      final r = _parse('''
Column
  LineChart#l labels=["W1","W2"] series=[{"name":"A","values":[1,2]},{"name":"B","values":[3,4]}]
  AreaChart#a labels=["W1","W2"] values=[1,2]
  LineChart#own labels=["W1","W2"] series=[{"name":"A","values":[1,2]}] legend=false tooltip=false dots=0 roundScale=false plotInset=0 axisFontSize=9 cursorLine=false selectOnHover=false
''');
      expect(_said(r), isEmpty);
      for (final id in ['l', 'a']) {
        expect(_node(r, id)['type'], 'chart');
        expect(only(_props(r, id), [...look, 'dots', 'cursorLine']), {
          'selectOnHover': true,
          'tooltip': true,
          'legend': true,
          'roundScale': true,
          'plotInset': 6,
          'axisFontSize': 11,
          'dots': 12,
          'cursorLine': true,
        }, reason: id);
        expect(_props(r, id).keys, isNot(anyOf(contains('barRadius'), contains('maxBarWidth'))), reason: id);
      }
      expect([for (final s in (_props(r, 'l')['series'] as List).cast<Map>()) (s['kind'], s['curved'], s['fade'])],
          [('line', true, null), ('line', true, null)]);
      // An area fades under its line.
      expect([for (final s in (_props(r, 'a')['series'] as List).cast<Map>()) (s['kind'], s['curved'], s['fade'])], [('area', true, true)]);
      // What the line says is the chart's.
      expect(only(_props(r, 'own'), [...look, 'dots', 'cursorLine']), {
        'selectOnHover': false,
        'tooltip': false,
        'legend': false,
        'roundScale': false,
        'plotInset': 0,
        'axisFontSize': 9,
        'dots': 0,
        'cursorLine': false,
      });
    });

    test('a BarChart of series', () {
      final r = _parse('Column\n  BarChart#b labels=["Q1"] series=[{"name":"A","values":[3]},{"name":"B","values":[4]}]\n  BarChart#own labels=["Q1"] series=[{"name":"A","values":[3]}] barRadius=0 maxBarWidth=12\n');
      expect(only(_props(r, 'b'), [...look, 'barRadius', 'maxBarWidth']), {
        'selectOnHover': true,
        'tooltip': true,
        'legend': true,
        'roundScale': true,
        'plotInset': 6,
        'axisFontSize': 11,
        'barRadius': 4,
        'maxBarWidth': 40,
      });
      expect(_props(r, 'b').keys, isNot(anyOf(contains('dots'), contains('cursorLine'))));
      expect(only(_props(r, 'own'), ['barRadius', 'maxBarWidth']), {'barRadius': 0, 'maxBarWidth': 12});
    });

    test('a LineChart or an AreaChart of one line of values or of rows, and a Sparkline', () {
      final r = _parse('''
state rows=[{"d":"Mon","n":3}]
Column
  LineChart#v values=[3,5,4]
  LineChart#d data={rows} xField="d" yField="n"
  AreaChart#a data={rows} xField="d" yField="n"
  LineChart#own values=[3,5,4] scrubEnabled=false gridValues=false cursorLine=false
  Sparkline#s values=[3,5,4]
''');
      expect(_said(r), isEmpty);
      for (final id in ['v', 'd', 'a']) {
        expect(_node(r, id)['type'], 'lineChart');
        expect(only(_props(r, id), ['smooth', 'scrubEnabled', 'cursorLine', 'gridValues']),
            {'smooth': true, 'scrubEnabled': true, 'cursorLine': true, 'gridValues': true}, reason: id);
      }
      expect(only(_props(r, 'own'), ['scrubEnabled', 'cursorLine', 'gridValues']), {'scrubEnabled': false, 'cursorLine': false, 'gridValues': false});
      // A small trend to look at: nothing under the pointer, no figures.
      expect(_props(r, 's').keys, isNot(anyOf(contains('scrubEnabled'), contains('cursorLine'), contains('gridValues'))));
    });

    test('a BarChart of one series', () {
      final r = _parse('Column\n  BarChart#b values=[3,5,4]\n  BarChart#own values=[3,5,4] tooltip=false barRadius=0\n');
      expect(only(_props(r, 'b'), ['tooltip', 'gridValues', 'barRadius', 'maxBarWidth', 'labelFontSize']),
          {'tooltip': true, 'gridValues': true, 'barRadius': 4, 'maxBarWidth': 40, 'labelFontSize': 11});
      expect(only(_props(r, 'own'), ['tooltip', 'barRadius']), {'tooltip': false, 'barRadius': 0});
    });

    test('a Donut and a Pie', () {
      final r = _parse('Column\n  Donut#d values=[60,40] labels=["Rent","Food"]\n  Pie#p values=[60,40] labels=["a","b"]\n  Donut#own values=[60,40] labels=["c","e"] tooltip=false selectOnHover=false legend=false total=false\n');
      expect(only(_props(r, 'd'), ['selectOnHover', 'tooltip', 'legend', 'centerLabel']),
          {'selectOnHover': true, 'tooltip': true, 'legend': true, 'centerLabel': 'Total'});
      expect(only(_props(r, 'p'), ['selectOnHover', 'tooltip', 'legend', 'centerLabel']),
          {'selectOnHover': true, 'tooltip': true, 'legend': true, 'centerLabel': null});
      expect(only(_props(r, 'own'), ['selectOnHover', 'tooltip', 'legend', 'centerLabel']),
          {'selectOnHover': false, 'tooltip': false, 'legend': false, 'centerLabel': null});
    });

    test('a node written by its type is as written: the words\' look is not the node\'s', () {
      final r = _parse('''
Column
  chart#c chartType=line series=[{"field":"a","name":"A"}] data=[{"label":"x","a":1}]
  barChart#b values=[3,5]
  lineChart#l data=[{"x":1,"y":2}]
''');
      expect(_props(r, 'c').keys, unorderedEquals(['chartType', 'series', 'data']));
      expect(_props(r, 'b').keys, ['values']);
      expect(_props(r, 'l').keys, ['data']);
    });
  });

  group('the nodes\' own defaults are as they were, and their new keys are off', () {
    test('chart, lineChart, barChart', () {
      expect(ChartProps.selectOnHover.defaultValue, isFalse);
      expect(ChartProps.tooltip.defaultValue, isFalse);
      expect(ChartProps.barRadius.defaultValue, 0);
      expect(ChartProps.axisFontSize.defaultValue, 10);
      expect(ChartProps.maxBarWidth.defaultValue, isNull);
      expect(ChartProps.legend.defaultValue, isFalse);
      expect(ChartProps.roundScale.defaultValue, isFalse);
      expect(ChartProps.dots.defaultValue, 0);
      expect(ChartProps.cursorLine.defaultValue, isFalse);
      expect(ChartProps.plotInset.defaultValue, isNull);
      expect(ChartProps.centerLabel.defaultValue, isNull);
      expect(ChartSeries.fadeDef.defaultValue, isFalse);
      expect(LineChartProps.scrubEnabled.defaultValue, isFalse);
      expect(LineChartProps.cursorLine.defaultValue, isFalse);
      expect(LineChartProps.gridValues.defaultValue, isFalse);
      expect(BarChartProps.gridValues.defaultValue, isFalse);
      expect(BarChartProps.tooltip.defaultValue, isFalse);
    });

    test('a graph\'s legend, palette, inset and rounded scale are keys of its records, off unless set', () {
      final g = Node.fromJson({
        'type': 'graph',
        'props': {
          'legend': {'show': 'always', 'position': 'right'},
          'style': {'palette': ['#FF111111', '#FF222222'], 'ink': '#FF000000', 'tooltip': '#FFFFFFFF'},
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
      expect(GraphLegend.showDef.defaultValue, 'none');
      expect(GraphYAxis.niceDef.defaultValue, isFalse);
      expect(GraphXAxis.insetDef.defaultValue, 0);
      expect(GraphMark.dotsDef.defaultValue, 0);
      expect(GraphMark.centerDef.defaultValue, '');
      expect(GraphStyle.paletteDef.defaultValue, isEmpty);
    });
  });
}
