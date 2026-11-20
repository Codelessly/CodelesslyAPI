// A graph in the notation: its parts are records, so their fields are dotted
// keys on the node's line, checked against the declarations, and printed
// back the same way.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

NotationResult _parse(String text) => Catalog.run(standardCatalog, () => parseNotation(text, catalog: standardCatalog));

Json _props(NotationResult r, String id) =>
    ((((r.document['nodes'] as Map)[id] as Map)['props']) as Map).cast<String, Object?>();

void main() {
  test('a graph\'s parts are written as dotted keys, and its marks by their place', () {
    final r = _parse('Column\n'
        '  graph#g h=240 rowKey=month xAxis.label=month xAxis.fit=bars yAxis.side=left yAxis.width=40 yAxis.prefix="\$" '
        'selection.on=both selection.total=true marks[0].type=bar marks[0].y=web marks[0].stack=r '
        'marks[1].type=bar marks[1].y=store marks[1].stack=r marks[1].color=#FF60A5FA');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final p = _props(r, 'g');
    expect(p['rowKey'], 'month');
    expect(p['xAxis'], {'label': 'month', 'fit': 'bars'});
    expect(p['yAxis'], {'side': 'left', 'width': 40, 'prefix': r'$'});
    expect(p['selection'], {'on': 'both', 'total': true});
    expect(p['marks'], [
      {'type': 'bar', 'y': 'web', 'stack': 'r'},
      {'type': 'bar', 'y': 'store', 'stack': 'r', 'color': '#FF60A5FA'},
    ]);
  });

  test('it reads as its declaration: a typed node with its records', () {
    final r = _parse('Column\n  graph#g coord=polar marks=[{"type":"arc","y":"share","inner":0.6}] selection.by=mark');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final node = LayoutDocument.fromJson(r.document).nodes['g']!;
    expect(node.prop(GraphProps.coord), 'polar');
    final mark = node.prop(GraphProps.marks).single;
    expect(mark.get(GraphMark.typeDef), 'arc');
    expect(mark.get(GraphMark.innerDef), 0.6);
    expect(mark.get(GraphMark.gapDef), 0);
    expect(node.prop(GraphProps.selection).get(GraphSelection.byDef), 'mark');
    expect(node.prop(GraphProps.selection).get(GraphSelection.onDef), 'none');
    expect(node.prop(GraphProps.crosshair).get(GraphCrosshair.enabledDef), isFalse);
  });

  test('a field a part does not have is said, with the ones it has', () {
    final r = _parse('Column\n  graph#g xAxis.lable=month');
    expect(r.issues, isNotEmpty);
    expect('${r.issues}', contains('label'));
  });

  test('it prints, and the print reads as the same document', () {
    final r = _parse('Column\n'
        '  graph#g h=240 rowKey=month xAxis.label=month xAxis.fit=bars selection.on=hover '
        'marks[0].type=bar marks[0].y=web');
    expect(r.issues, isEmpty, reason: '${r.issues}');
    final printed = Catalog.run(standardCatalog, () => printNotation(r.document, catalog: standardCatalog));
    // The printer writes a part whole where that is shorter.
    expect(printed, contains('Graph#g'));
    expect(printed, contains('rowKey=month'));
    final back = _parse(printed);
    expect(back.issues, isEmpty, reason: '${back.issues}\n$printed');
    expect(jsonEquality.equals(back.document, r.document), isTrue, reason: printed);
  });
}
