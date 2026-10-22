import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

VarianceNode statusStates({bool skeleton = false}) => VarianceNode(
  id: 'states',
  name: 'Tasks states',
  basicBoxLocal: NodeBox(0, 0, 390, 600),
  variants: [
    Variant(id: 'default', name: 'Loaded', children: ['list']),
    Variant(
      id: kQueryStatusLoading,
      name: 'Loading',
      children: skeleton ? [] : ['spinner'],
      skeleton: skeleton,
    ),
    Variant(id: kQueryStatusEmpty, name: 'Empty', children: ['nothing']),
    Variant(id: kQueryStatusError, name: 'Error', children: ['oops']),
  ],
);

void main() {
  test('a variance with a status variant shows a list status', () {
    expect(statusStates().isQueryStatus, isTrue);
    expect(
      VarianceNode(
        id: 'v',
        name: 'v',
        basicBoxLocal: NodeBox(0, 0, 1, 1),
        variants: [Variant(id: 'default', name: 'Default', children: [])],
      ).isQueryStatus,
      isFalse,
    );
  });

  test('a skeleton variant shows the default children', () {
    final VarianceNode node = statusStates(skeleton: true)
      ..currentVariantId = kQueryStatusLoading;
    expect(node.currentVariant.sharesDefaultChildren, isTrue);
    expect(node.children, ['list']);
    expect(node.unloadedVariantsChildren, ['nothing', 'oops']);
  });

  test('skeleton and paging round-trip and are omitted by default', () {
    final VarianceNode node = statusStates(skeleton: true);
    final Map decoded = jsonDecode(jsonEncode(node.toJson())) as Map;
    final VarianceNode back = VarianceNode.fromJson(decoded);
    expect(back.variants[1].skeleton, isTrue);
    expect(back.variants[2].toJson().containsKey('skeleton'), isFalse);

    final ListViewNode list = ListViewNode(
      id: 'list',
      name: 'List',
      basicBoxLocal: NodeBox(0, 0, 390, 600),
      properties: ListViewProperties(),
      children: ['item'],
    );
    expect(list.toJson().containsKey('paging'), isFalse);
    list.paging = QueryPaging.button;
    final ListViewNode listBack = ListViewNode.fromJson(
      jsonDecode(jsonEncode(list.toJson())) as Map,
    );
    expect(listBack.paging, QueryPaging.button);
  });
}
