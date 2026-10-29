import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> listWire({bool conflict = false}) => {
  'type': 'listView',
  'id': 'list',
  'name': 'List',
  'basicBoxLocal': [0, 0, 200, 100],
  'children': <String>[],
  'properties': <String, dynamic>{
    'stacked': true,
    if (conflict) 'layout': 'stack',
    'customNested': <String, dynamic>{
      'values': [1, 2, 3],
    },
  },
};

void main() {
  test('plain list omits both stack modes', () {
    final props = ListViewProperties.fromJson({});
    expect(props.layout, ListLayout.list);
    expect(props.stacked, isFalse);
    expect(props.toJson().containsKey('layout'), isFalse);
    expect(props.toJson().containsKey('stacked'), isFalse);
  });

  test('old centered deck stack does not become positional x/y stack', () {
    final props = ListViewProperties.fromJson({'stacked': true});
    expect(props.stacked, isTrue);
    expect(props.layout, ListLayout.list);
    expect(props.toJson()['stacked'], isTrue);
    expect(props.toJson().containsKey('layout'), isFalse);
    final copied = props.copyWith(wrap: true);
    expect(copied.stacked, isTrue);
    expect(copied.isWrapping, isFalse);
  });

  test('new positional stack does not become centered deck stack', () {
    final props = ListViewProperties.fromJson({'layout': 'stack'});
    expect(props.stacked, isFalse);
    expect(props.layout, ListLayout.stack);
    expect(props.toJson()['layout'], 'stack');
    expect(props.toJson().containsKey('stacked'), isFalse);
    expect(
      ListViewProperties.fromJson(props.toJson()).layout,
      ListLayout.stack,
    );
  });

  test('two explicit stack modes reject, never coerce one into the other', () {
    expect(
      () => ListViewProperties.fromJson({'stacked': true, 'layout': 'stack'}),
      throwsFormatException,
    );
    expect(
      () => ListViewProperties(stacked: true, layout: ListLayout.stack),
      throwsArgumentError,
    );
    final props = ListViewProperties(stacked: true)..layout = ListLayout.stack;
    expect(() => props.toJson(), throwsStateError);
  });

  test('node converter rejects conflicting list layouts with original raw', () {
    final input = listWire(conflict: true);
    try {
      NodeJsonConverter().fromJson(input);
      fail('must not guess the meaning of two stack modes');
    } on UnresolvedNodeSchema catch (error) {
      expect(error.reason, 'conflicting-list-layout-schema');
      expect(error.raw, input);
      ((input['properties'] as Map)['customNested'] as Map)['values'] = [9];
      expect(
        ((error.raw['properties'] as Map)['customNested'] as Map)['values'],
        [1, 2, 3],
      );
    }
  });

  test('nodes map retains every sibling and full raw list on conflict', () {
    final input = <String, dynamic>{
      'first': listWire(),
      'conflict': listWire(conflict: true),
      'last': listWire(),
    };
    try {
      NodesMapConverter.deserialize(input);
      fail('must not return a partial parsed nodes map');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'conflicting-list-layout-schema');
      expect(error.nodeKey, 'conflict');
      expect(error.raw, input);
      expect(error.raw.keys, ['first', 'conflict', 'last']);
      (((input['conflict'] as Map)['properties'] as Map)['customNested']
          as Map)['values'] = [
        9,
      ];
      expect(
        ((((error.raw['conflict'] as Map)['properties'] as Map)['customNested']
            as Map)['values']),
        [1, 2, 3],
      );
    }
  });

  test('canvases map retains every canvas and sibling on list conflict', () {
    final input = <String, dynamic>{
      'before': <String, dynamic>{'safe': listWire()},
      'affected': <String, dynamic>{
        'first': listWire(),
        'conflict': listWire(conflict: true),
        'last': listWire(),
      },
      'after': <String, dynamic>{'safe': listWire()},
    };
    try {
      CanvasesMapConverter.deserialize(input);
      fail('must not return a partial parsed canvases map');
    } on UnresolvedDocumentSchema catch (error) {
      expect(error.reason, 'conflicting-list-layout-schema');
      expect(error.nodeKey, 'conflict');
      expect(error.raw, input);
      expect(error.raw.keys, ['before', 'affected', 'after']);
      expect((error.raw['affected'] as Map).keys, [
        'first',
        'conflict',
        'last',
      ]);
      (((((input['affected'] as Map)['conflict'] as Map)['properties']
                      as Map)['customNested']
                  as Map)['values']
              as List)
          .add(9);
      expect(
        (((((error.raw['affected'] as Map)['conflict'] as Map)['properties']
                as Map)['customNested']
            as Map)['values']),
        [1, 2, 3],
      );
    }
  });

  test('node wire retains independent layout and wrap settings', () {
    final node = ListViewNode(
      id: 'list',
      name: 'List',
      basicBoxLocal: NodeBox(0, 0, 200, 100),
      properties: ListViewProperties(
        layout: ListLayout.stack,
        wrap: true,
        wrapSpacing: 5,
        runSpacing: 7,
      ),
      children: const [],
    );
    final json = jsonDecode(jsonEncode(node.toJson())) as Map;
    final decoded = ListViewNode.fromJson(json);
    expect(decoded.properties.layout, ListLayout.stack);
    expect(decoded.properties.stacked, isFalse);
    expect(decoded.properties.wrap, isTrue);
    expect(decoded.properties.runSpacing, 7);
  });
}
