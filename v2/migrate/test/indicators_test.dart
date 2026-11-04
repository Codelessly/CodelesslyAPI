import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// Migrates v1 [nodes] placed in a freeform body; returns the v2 nodes.
Map<String, Object?> migrate(Map<String, Map<String, Object?>> nodes, {MigrationReport? report}) {
  final v2 = migrateDocument({
    'rootNode': {'children': ['c']},
    'c': {'id': 'c', 'type': 'canvas', 'name': 'C', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 400],
          'properties': {'bodyId': 'f'}, 'children': ['f']},
    'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 400], 'children': [...nodes.keys]},
    for (final e in nodes.entries)
      e.key: {'id': e.key, 'name': e.key, 'parentID': 'f', 'basicBoxLocal': [0, 0, 100, 50], ...e.value},
  }, report: report);
  return (v2['nodes'] as Map).cast<String, Object?>();
}

Map props(Map<String, Object?> nodes, String id) => ((nodes[id] as Map)['props'] as Map?) ?? const {};
String type(Map<String, Object?> nodes, String id) => (nodes[id] as Map)['type'] as String;

void main() {
  test('loading indicators: material and cupertino', () {
    final report = MigrationReport();
    final nodes = migrate({
      'm': {'type': 'loadingIndicator', 'basicBoxLocal': [0, 0, 16, 16],
            'properties': {'type': 'material', 'color': '#FF15171A', 'strokeWidth': 2.5, 'value': 0.4, 'strokeCap': 'none'}},
      'd': {'type': 'loadingIndicator', 'properties': {'type': 'material', 'color': '#FF15171A'}},
      'k': {'type': 'loadingIndicator', 'basicBoxLocal': [0, 0, 17, 17], 'properties': {'type': 'cupertino', 'color': '#FFA2A8B1', 'radius': 3}},
    }, report: report);
    expect(type(nodes, 'm'), 'circularProgressIndicator');
    expect(props(nodes, 'm'), {
      'color': '#FF15171A', 'backgroundColor': '#00000000', 'strokeWidth': 2.5, 'value': 0.4, 'strokeCap': 'butt',
    });
    // v1's square cap and transparent track, written over Flutter's nulls.
    expect(props(nodes, 'd'), {'color': '#FF15171A', 'backgroundColor': '#00000000', 'strokeCap': 'square'});
    // The stroke's outer half is padding.
    expect(((nodes['m'] as Map)['layout'] as Map)['padding'], 1.25);
    expect(type(nodes, 'k'), 'activityIndicator');
    // SDK 8.x drew it at half the node's width.
    expect(props(nodes, 'k'), {'color': '#FFA2A8B1', 'radius': 8});
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
  });

  test('progress bar', () {
    final report = MigrationReport();
    final nodes = migrate({
      'p': {'type': 'progressBar', 'currentValue': 35,
            'properties': {'maxValue': 50, 'progressColor': '#FF2D6CDF', 'isVertical': true, 'cornerRadius': [6, false, 'circular'],
              'animationDurationInMillis': 700, 'shape': 'arc', 'bands': [{'start': 0, 'end': 0.9, 'color': '#FF2E9E5B'}],
              'needleColor': '#FF15171A'}},
    }, report: report);
    expect(props(nodes, 'p'), {
      'value': 35, 'max': 50, 'color': '#FF2D6CDF', 'direction': 'vertical', 'borderRadius': 6, 'animationDuration': 700,
      'shape': 'arc', 'needleColor': '#FF15171A', 'bands': [{'start': 0, 'end': 0.9, 'color': '#FF2E9E5B'}],
    });
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
  });

  test('gauges: radial and meter', () {
    final report = MigrationReport();
    final nodes = migrate({
      'r': {'type': 'gauge', 'gaugeKind': 'radial', 'value': 72, 'properties': {'labelFontFamily': 'JetBrains Mono', 'segments': 0}},
      'm': {'type': 'gauge', 'gaugeKind': 'meter', 'value': 50, 'limit': 80,
            'properties': {'shape': 'bar', 'segments': 24, 'animationDurationInMillis': 100}},
    }, report: report);
    expect(type(nodes, 'r'), 'radialGauge');
    final r = props(nodes, 'r');
    expect(r['value'], 72);
    expect(r['segments'], 0);
    // v1's default zones are written out: v2 has none by default.
    expect((r['zones'] as List).length, 3);
    expect(type(nodes, 'm'), 'gaugeMeter');
    expect(props(nodes, 'm'), {'value': 50, 'limit': 80, 'shape': 'bar', 'segments': 24, 'animationDuration': 100});
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
  });

  test('charts: series and plot, bar and line', () {
    final report = MigrationReport();
    final nodes = migrate({
      's': {'type': 'chart', 'chartKind': 'series', 'selectedIndex': 2,
            'properties': {'chartType': 'line', 'gridLines': 0, 'referenceLines': [{'value': 5, 'dashed': false}],
              'series': [{'field': 'a', 'kind': 'area', 'color': '#FFFFD400', 'strokeWidth': 2, 'fillOpacity': 0.25, 'dashed': false}]}},
      'd': {'type': 'chart', 'chartKind': 'series', 'properties': {}},
      'p': {'type': 'chart', 'chartKind': 'plot', 'selectedX': 7,
            'properties': {'points': [1, 2], 'xMax': 24, 'labelStyle': {'fontSize': 9}, 'markers': [{'x': 3, 'label': 'Hi'}]}},
      'b': {'type': 'barChart', 'values': [1, null, 3], 'labels': ['a', 'b', 'c'], 'highlight': 1, 'properties': {'max': 480}},
      'l': {'type': 'lineChart', 'properties': {'padLeft': 40, 'smooth': true, 'xField': 't'}},
    }, report: report);
    final s = props(nodes, 's');
    expect(s['chartType'], 'line');
    expect(s['selectedIndex'], 2);
    expect(s['series'], [{'field': 'a', 'kind': 'area', 'color': '#FFFFD400'}]);
    expect(s['referenceLines'], [{'value': 5, 'color': '#99FFFFFF', 'dashed': false}]);
    // v1's sample series and rows are content in v2.
    final d = props(nodes, 'd');
    expect((d['series'] as List).length, 3);
    expect((d['data'] as List).length, 6);
    expect(type(nodes, 'p'), 'plotChart');
    final p = props(nodes, 'p');
    expect(p['selectedX'], 7);
    expect(p['labelStyle'], {'fontSize': 9, 'color': '#89000000', 'fontWeight': 400});
    expect(p['markers'], [{'x': 3, 'label': 'Hi', 'color': '#FF000000'}]);
    expect(props(nodes, 'b'), {'values': [1, null, 3], 'labels': ['a', 'b', 'c'], 'highlight': 1, 'max': 480});
    final l = props(nodes, 'l');
    expect(l['plotPadding'], [40, 30, 14, 30]);
    expect(l['smooth'], true);
    expect(l['xField'], 't');
    expect((l['axisLabelStyle'] as Map)['fontSize'], 11);
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
  });

  test('barcode', () {
    final report = MigrationReport();
    final nodes = migrate({
      'q': {'type': 'barcode', 'data': 'https://codelessly.com', 'properties': {'symbology': 'pdf417', 'drawText': false}},
    }, report: report);
    expect(props(nodes, 'q'), {'data': 'https://codelessly.com', 'symbology': 'pdf417', 'drawText': false});
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
  });
}
