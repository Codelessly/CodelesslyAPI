import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Nodes whose toJson output is pinned by test/fixtures/node_json_golden.json.
///
/// The fixture was produced by codelessly_api 4.4.0, which used the forked
/// json_serializable with `serialize_default_values: false`. These tests keep
/// the stored JSON format identical after moving to json_serializable plus
/// tool/json_defaults_builder.
List<BaseNode> goldenNodes() {
  final nodes = <BaseNode>[
    ButtonNode.empty(),
    CheckboxNode.empty(),
    DividerNode.empty(),
    EmbeddedVideoNode.empty(),
    FloatingActionButtonNode.empty(),
    IconNode.empty(),
    ListTileNode.empty()..setChildrenMixin(children: []),
    ProgressBarNode.empty(),
    RadioNode.empty(),
    SliderNode.empty(),
    SwitchNode.empty(),
    SwitchNode(
      id: 'switch_custom',
      name: 'Custom switch',
      basicBoxLocal: NodeBox(10, 20, 80, 40),
      value: true,
      visible: false,
      padding: EdgeInsetsModel.all(4),
      alignment: AlignmentModel.center,
      properties: SwitchProperties(
        activeTrackColor: ColorRGBA.white,
        splashRadius: 12,
        autofocus: true,
        useMaterial3: true,
      ),
    ),
    RowColumnNode(
      id: 'row',
      name: 'Row',
      basicBoxLocal: NodeBox(0, 0, 100, 40),
      children: ['a', 'b'],
      rowColumnType: RowColumnType.row,
      mainAxisAlignment: MainAxisAlignmentC.spaceBetween,
    ),
    TextNode(
      id: 'text',
      name: 'Text',
      basicBoxLocal: NodeBox(0, 0, 100, 20),
      characters: 'Hello',
      textMixedProps: [],
    ),
  ];
  return nodes;
}

/// Paint ids come from generateId() on every construction, so they cannot be
/// pinned; everything else is compared exactly.
Object? withoutPaintIds(Object? json, {bool topLevel = true}) => switch (json) {
  Map() => {
    for (final MapEntry(:key, :value) in json.entries)
      if (topLevel || key != 'id' || !json.containsKey('type'))
        key: withoutPaintIds(value, topLevel: false),
  },
  List() => [for (final e in json) withoutPaintIds(e, topLevel: false)],
  _ => json,
};

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

void main() {
  final golden = jsonDecode(
    File('test/fixtures/node_json_golden.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  for (final node in goldenNodes()) {
    test('${node.type} "${node.id}" serializes like 4.4.0', () {
      expect(
        withoutPaintIds(encodeDecode(node.toJson())),
        withoutPaintIds(golden[node.id]),
      );
    });

    test('${node.type} "${node.id}" reads its 4.4.0 JSON back stably', () {
      // fromJson may normalize once (e.g. a non-tristate checkbox's null
      // value becomes false); after that, toJson/fromJson must be stable.
      final once = encodeDecode(
        NodeJsonConverter.instance.fromJson(golden[node.id])!.toJson(),
      );
      final twice = encodeDecode(
        NodeJsonConverter.instance.fromJson(once as Map)!.toJson(),
      );
      expect(twice, once);
    });
  }
}
