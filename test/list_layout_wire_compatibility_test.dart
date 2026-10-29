import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

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
