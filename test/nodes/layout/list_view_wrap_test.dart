import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Map _roundTrip(Map json) => jsonDecode(jsonEncode(json)) as Map;

ListViewNode _list(ListViewProperties properties) => ListViewNode(
  id: 'list',
  name: 'Tides',
  basicBoxLocal: NodeBox(0, 0, 300, 100),
  children: ['chip'],
  properties: properties,
);

void main() {
  group('ListViewProperties wrap', () {
    test('defaults are off and left out of the JSON', () {
      final ListViewProperties properties = ListViewProperties();
      expect(properties.wrap, isFalse);
      expect(properties.runSpacing, 0);
      final Map json = properties.toJson();
      expect(json.containsKey('wrap'), isFalse);
      expect(json.containsKey('runSpacing'), isFalse);
      expect(_list(properties).toJson()['properties'], isNot(contains('wrap')));
    });

    test('non-default values round-trip through the node', () {
      final Map json = _roundTrip(
        _list(
          ListViewProperties(
            itemCount: 4,
            hasSeparator: true,
            separatorSpacing: 8,
            wrap: true,
            runSpacing: 6,
          ),
        ).toJson(),
      );
      expect(json['properties']['wrap'], true);
      expect(json['properties']['runSpacing'], 6);
      final ListViewNode node = ListViewNode.fromJson(json);
      expect(node.properties.wrap, isTrue);
      expect(node.properties.runSpacing, 6);
      expect(node.properties.separatorSpacing, 8);
    });

    test('missing keys decode to defaults; copyWith and equality see them', () {
      final ListViewProperties properties = ListViewProperties.fromJson({});
      expect(properties.wrap, isFalse);
      expect(properties.runSpacing, 0);
      final ListViewProperties wrapped = properties.copyWith(
        wrap: true,
        runSpacing: 4,
      );
      expect(wrapped.wrap, isTrue);
      expect(wrapped.runSpacing, 4);
      expect(wrapped, isNot(properties));
    });

    test('field access edits them', () {
      final ListViewProperties properties = ListViewProperties();
      final fields = properties.generateFields();
      fields['wrap']!.setValue(true);
      fields['runSpacing']!.setValue(8.0);
      expect(properties.wrap, isTrue);
      expect(properties.runSpacing, 8);
    });
  });
}
