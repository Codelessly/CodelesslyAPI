import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Nodes whose JSON is pinned by the fixtures in test/fixtures.
///
/// node_json_golden.json was produced by codelessly_api 4.4.0, which used the
/// forked json_serializable with `serialize_default_values: false`.
List<BaseNode> goldenNodes() {
  final nodes = <BaseNode>[
    ElevatedButtonNode.empty(),
    CheckboxNode.empty(),
    DividerNode.empty(),
    EmbeddedVideoNode.empty(),
    FloatingActionButtonNode.empty(),
    IconNode.empty(),
    ListTileNode.empty(),
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
      padding: const EdgeInsetsModel.all(4),
      alignment: AlignmentModel.center,
      properties: SwitchProperties(
        activeTrackColor: ColorRGBA.white,
        splashRadius: 12,
        autofocus: true,
        useMaterial3: true,
      ),
    ),
    RowNode(
      id: 'row',
      name: 'Row',
      basicBoxLocal: NodeBox(0, 0, 100, 40),
      children: ['a', 'b'],
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
  Map<String, dynamic> fixture(String name) =>
      jsonDecode(File('test/fixtures/$name').readAsStringSync())
          as Map<String, dynamic>;

  // JSON written by codelessly_api 4.4.0.
  final legacy = fixture('node_json_golden.json');
  // JSON written for freshly created nodes by this version, which uses
  // Material 3 defaults where 4.4.0 used Material 2 ones.
  final current = fixture('node_json_current.json');

  for (final node in goldenNodes()) {
    test('${node.type} "${node.id}" serializes as pinned', () {
      expect(
        withoutPaintIds(encodeDecode(node.toJson())),
        withoutPaintIds(
          node is ButtonNode
              ? {
                  ...?current[node.id],
                  'type': 'elevatedButton',
                  'properties': {
                    ...?current[node.id]?['properties'],
                    'buttonType': 'elevated',
                  },
                }
              : current[node.id],
        ),
      );
    });

    if (node is ButtonNode || node is RowColumnNode)
      continue; // Retired combined node types have no decoder.
    test('${node.type} "${node.id}" keeps its 4.4.0 JSON', () {
      // Designs saved by 4.4.0 must not change when read and saved again,
      // even where a default changed since.
      final reserialized = encodeDecode(
        NodeJsonConverter.instance.fromJson(legacy[node.id])!.toJson(),
      );
      final expected = encodeDecode(legacy[node.id]) as Map;
      // The one normalization: a non-tristate checkbox reads null as false.
      if (expected['type'] == 'checkbox' && expected['value'] == null) {
        expected['value'] = false;
      }
      expect(reserialized, expected);
    });
  }
}
