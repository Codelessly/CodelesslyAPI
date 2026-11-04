import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// A page with [nodes] (id → v1 JSON) in a freeform body.
Map<String, Object?> page(Map<String, Map<String, Object?>> nodes) => {
      'rootNode': {'children': ['c']},
      'c': {'id': 'c', 'type': 'canvas', 'name': 'c', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
            'properties': {'bodyId': 'b'}, 'children': ['b']},
      'b': {'id': 'b', 'type': 'frame', 'name': 'b', 'parentID': 'c', 'basicBoxLocal': [0, 0, 400, 300],
            'children': nodes.keys.toList()},
      for (final e in nodes.entries)
        e.key: {'id': e.key, 'name': e.key, 'parentID': 'b', 'basicBoxLocal': [0, 0, 100, 40], ...e.value},
    };

Map<String, Object?> props(Map<String, Object?> v2, String id) =>
    (((v2['nodes'] as Map)[id] as Map)['props'] as Map? ?? const {}).cast<String, Object?>();

void main() {
  test('a text field: its decoration, style and line limits as SDK 8.x passed them', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      't': {
        'type': 'textField',
        'initialText': 'Hi',
        'properties': {
          'maxLines': null,
          'minLines': 2,
          'keyboardType': 'number',
          'showDecimalKey': true,
          'inputStyle': {'fills': [{'id': 'f', 'type': 'solid', 'color': '#222222'}], 'fontSize': 15},
          'decoration': {
            'hintText': 'Search',
            'labelText': '',
            'showCounter': false,
            'filled': true,
            'fillColor': '#FFF0F0F0',
            'prefixIcon': {'icon': {'icon': {'codepoint': 59574, 'name': 'search', 'style': 'filled', 'type': 'MATERIAL_ICON'},
                'size': 20, 'show': true}},
            'enabledBorder': {'borderType': 'underline', 'borderSide': {'color': '#FF888888', 'width': 2}},
          },
        },
      },
    }), report: report);
    final p = props(v2, 't');
    expect(p['initialValue'], 'Hi');
    expect(p['maxLines'], 0);
    expect(p['minLines'], 2);
    expect(p['keyboardType'], 'number');
    expect(p['keyboardDecimal'], true);
    expect((p['style'] as Map)['fontSize'], 15);
    expect((p['style'] as Map)['color'], '#FF222222');
    final d = p['decoration'] as Map;
    expect(d['hintText'], 'Search');
    expect(d.containsKey('labelText'), isFalse);
    expect(d['counterText'], '');
    expect(d['filled'], true);
    expect(d['fillColor'], '#FFF0F0F0');
    expect(d['isDense'], true);
    expect((d['prefixIcon'] as Map)['size'], 20);
    expect(((d['prefixIcon'] as Map)['icon'] as Map)['name'], 'search');
    expect(d['enabledBorder'], {
      'type': 'underline',
      'borderSide': {'color': '#FF888888', 'width': 2},
      'borderRadius': 4,
    });
    // The node's padding is the content padding.
    expect(((v2['nodes'] as Map)['t'] as Map)['layout']['padding'], [12, 16, 12, 16]);
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
    expect(report.unportedTypes, isEmpty);
  });

  test('toggles, slider, dropdown, pickers, segments and signatures', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'cb': {'type': 'checkbox', 'value': true, 'properties': {'compact': true}},
      'sw': {'type': 'switch', 'value': true, 'properties': {'fillTrack': true}},
      'r': {'type': 'radio', 'value': 'a', 'groupValue': 'b', 'properties': {}},
      's': {'type': 'slider', 'value': 30, 'markerValue': 50,
            'properties': {'isDiscrete': true, 'divisions': 4, 'showLabel': true, 'thumbWidth': 28}},
      'd': {'type': 'dropdown', 'value': 'B', 'properties': {'items': ['A', 'B'], 'hint': 'Pick', 'underline': false}},
      'dp': {'type': 'datePicker', 'value': '2024-05-17', 'properties': {}},
      'tp': {'type': 'timePicker', 'value': '09:30', 'properties': {}},
      'dt': {'type': 'dateTimeInput', 'mode': 'time', 'value': '07:45', 'properties': {'label': 'At'}},
      'sb': {'type': 'segmentedButton', 'properties': {'selectedSegments': ['day'], 'borderWidth': 2}},
      'sg': {'type': 'signature', 'signatureKind': 'strokes', 'value': [[[1, 2], [3, 4]]], 'properties': {'error': true}},
      'sn': {'type': 'signature', 'signatureKind': 'normalized', 'strokes': [[[0.1, 0.2]]], 'properties': {}},
    }), report: report);
    expect(props(v2, 'cb'), containsPair('value', true));
    expect(props(v2, 'cb'), containsPair('compact', true));
    expect(props(v2, 'sw'), containsPair('fillTrack', true));
    expect(props(v2, 'r'), allOf(containsPair('value', 'a'), containsPair('groupValue', 'b')));
    final s = props(v2, 's');
    expect(s['value'], 30);
    expect(s['max'], 100);
    expect(s['divisions'], 4);
    expect(s['showValueIndicator'], 'onDrag');
    expect(s['label'], r'${value}');
    expect(s['thumbSize'], [28, 20]);
    expect(s['markerValue'], 50);
    final d = props(v2, 'd');
    expect(d['items'], ['A', 'B']);
    expect(d['value'], 'B');
    expect(d['hint'], 'Pick');
    expect(d['underline'], false);
    expect(props(v2, 'dp'), {'value': '2024-05-17'});
    expect(props(v2, 'tp'), {'value': '09:30'});
    expect(props(v2, 'dt'), {'mode': 'time', 'value': '07:45', 'labelText': 'At'});
    final sb = props(v2, 'sb');
    expect((sb['segments'] as List).length, 3);
    expect(sb['selected'], ['day']);
    expect(sb['side'], {'color': '#FF79747E', 'width': 2});
    expect(props(v2, 'sg'), {
      'value': [
        [
          [1, 2],
          [3, 4],
        ],
      ],
      'error': true,
    });
    final sn = props(v2, 'sn');
    expect(sn['normalized'], true);
    expect(sn['placeholder'], '');
    expect(sn['inkColor'], '#FF000000');
    expect(report.unmapped.keys.where((k) => !k.startsWith('canvas.')), isEmpty);
    expect(report.unportedTypes, isEmpty);
  });
}
