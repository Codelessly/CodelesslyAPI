import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

Object? encodeDecode(Object? json) => jsonDecode(jsonEncode(json));

final DateTime _time = DateTime.utc(2026, 1, 1);

Expression _expression() => Expression(
  operator: ConditionOperation.equalsTo,
  leftPart: VariablePart(valueString: r'${a}'),
  rightPart: RawValuePart('1'),
);

/// Models with fields whose defaults are left out of `toJson`, keyed like
/// test/fixtures/omitted_defaults_5_3_0.json, which holds the JSON
/// codelessly_api 5.3.0 wrote for them (with the default keys present).
Map<String, Object Function()> omittedDefaultModels() => {
  'ConditionalAction': () => ConditionalAction(expression: _expression()),
  'ConditionalActionNested': () => ConditionalAction(
    expression: _expression(),
    actions: [ForEachAction(items: r'${list}')],
    elseActions: [CallFunctionAction(name: 'f')],
  ),
  'ForEachAction': () => ForEachAction(items: r'${list}'),
  'CloudFilesAction': () => CloudFilesAction(access: CloudFileAccess.public),
  'ApiCallAction': () => ApiCallAction(apiId: 'api'),
  'CallFunctionAction': () => CallFunctionAction(name: 'f'),
  'VariableData': () => VariableData(id: 'v', name: 'count', value: '1'),
  'ElseCondition': () => ElseCondition(id: 'e', lastUpdated: _time),
  'ConditionGroup': () => ConditionGroup(
    id: 'g',
    lastUpdated: _time,
    ifCondition: Condition(
      id: 'c',
      mode: ConditionMode.ifMode,
      expression: _expression(),
      actions: [],
      lastUpdated: _time,
    ),
  ),
  'VarianceNode': () => VarianceNode(
    id: 'var',
    name: 'Variance',
    basicBoxLocal: NodeBox(0, 0, 10, 10),
    variants: [Variant(id: 'v1', name: 'A', children: [])],
    currentVariantId: 'v1',
  ),
  'FrameWithReactions': () => FrameNode(
    id: 'f',
    name: 'F',
    basicBoxLocal: NodeBox(0, 0, 10, 10),
    children: [],
    reactions: [
      Reaction(
        id: 'r1',
        name: 'tap',
        trigger: TriggerModel(type: TriggerType.click),
        action: ConditionalAction(
          expression: _expression(),
          actions: [
            CloudFilesAction(access: CloudFileAccess.public),
            ApiCallAction(apiId: 'a'),
          ],
        ),
      ),
    ],
  ),
};

Object parseModel(String name, Map json) => switch (name) {
  'VariableData' => VariableData.fromJson(Map<String, dynamic>.from(json)),
  'ElseCondition' ||
  'ConditionGroup' => BaseCondition.fromJson(Map<String, dynamic>.from(json)),
  'VarianceNode' || 'FrameWithReactions' => NodeJsonConverter().fromJson(json)!,
  _ => ActionModel.fromJson(json),
};

Map<String, dynamic> _node(
  String type, [
  Map<String, dynamic> extra = const {},
]) => {
  'id': type,
  'name': type,
  'type': type,
  'basicBoxLocal': [0, 0, 100, 40],
  ...extra,
};

const _collection = {
  'children': ['a'],
  'isScrollable': true,
  'allowedTypes': <String>[],
  'deniedTypes': <String>[],
  'useFlutterListView': false,
};

/// One or more nodes of every registered node type.
List<BaseNode> sampleNodes() {
  final box = NodeBox(0, 0, 120, 48);
  PaintModel solid(String id, ColorRGB color) =>
      PaintModel.solid(id: id, color: color);
  return [
    ColumnNode(
      id: 'column',
      name: 'Column',
      basicBoxLocal: box,
      children: ['a', 'b'],
    ),
    RowNode(
      id: 'row',
      name: 'Row',
      basicBoxLocal: box,
      children: ['a'],
      mainAxisAlignment: MainAxisAlignmentC.spaceBetween,
      horizontalFit: SizeFit.expanded,
      verticalFit: SizeFit.shrinkWrap,
      padding: const EdgeInsetsModel.all(8),
    ),
    RowNode(
      id: 'wrapRow',
      name: 'Wrap Row',
      basicBoxLocal: box,
      children: ['a', 'b'],
      mainAxisAlignment: MainAxisAlignmentC.start,
      verticalFit: SizeFit.shrinkWrap,
      wrap: true,
      spacing: 8,
      runSpacing: 6,
    ),
    FrameNode(
      id: 'frame',
      name: 'Frame',
      basicBoxLocal: box,
      children: ['a'],
      fills: [solid('fill', ColorRGB.white)],
      cornerRadius: const CornerRadius.all(RadiusModel.circular(8)),
    ),
    omittedDefaultModels()['FrameWithReactions']!() as BaseNode,
    TextNode(
      id: 'text',
      name: 'Text',
      basicBoxLocal: NodeBox(0, 0, 80, 20),
      characters: 'Hello world',
      textMixedProps: [
        StartEndProp(
          start: 0,
          end: 11,
          fills: [solid('textFill', ColorRGB.black)],
          fontSize: 14,
        ),
      ],
    ),
    RectangleNode(
      id: 'rectangle',
      name: 'Rectangle',
      basicBoxLocal: box,
      fills: [solid('rectFill', ColorRGB.black)],
    ),
    SpacerNode(id: 'spacer', name: 'Spacer', basicBoxLocal: box),
    TextFieldNode(
      id: 'textField',
      name: 'Text Field',
      basicBoxLocal: box,
      properties: TextFieldProperties(),
    ),
    TextFieldNode(
      id: 'textFieldHints',
      name: 'Text Field',
      basicBoxLocal: box,
      properties: TextFieldProperties(
        autofillHints: {TextInputAutofillHints.email},
      ),
    ),
    omittedDefaultModels()['VarianceNode']!() as BaseNode,
    BadgeNode.empty(),
    ElevatedButtonNode.empty(),
    CheckboxNode.empty(),
    SignatureNode.empty(),
    SignatureNormalizedNode.empty(),
    ChipNode.empty(),
    DividerNode.empty(),
    EmbeddedVideoNode.empty(),
    ExpansionTileNode.empty(),
    FloatingActionButtonNode.empty(),
    IconNode.empty(),
    ListTileNode.empty(),
    ProgressBarNode.empty(),
    LineChartNode.empty(),
    GaugeMeterNode.empty(),
    BarChartNode.empty(),
    ChartNode.empty(),
    PlotChartNode.empty(),
    RadioNode.empty(),
    SegmentedButtonNode.empty(),
    SliderNode.empty(),
    SignatureNode.empty(),
    SwitchNode.empty(),
    for (final json in [
      _node('root', {'children': <String>[]}),
      _node('canvas', {
        'properties': {'bodyId': 'body'},
        'children': ['body'],
      }),
      _node('appBar', {
        'properties': {
          'title': 'Title',
          'backgroundColor': '#FFFFFF',
          'leading': {'id': 'lead', 'type': 'icon', 'icon': {}},
        },
      }),
      _node('navigationBar', {
        'properties': {'styleDefinition': 'material_3', 'items': []},
      }),
      _node('loadingIndicator', {
        'properties': {'type': 'material', 'color': '#000000'},
      }),
      _node('webView', {
        'properties': {
          'webviewType': 'webpage',
          'pageSourceType': 'url',
          'input': 'https://example.com',
        },
      }),
      for (final properties in [
        {
          'webviewType': 'googleMaps',
          'mapMode': 'places',
          'query': 'Coffee',
          'url': 'https://maps.example.com',
        },
        {
          'webviewType': 'twitter',
          'embedType': 'tweet',
          'tweetURL': 'https://x.com/a/status/1',
          'mediaAutoPlaybackPolicy': 'requireUserActionForAllMedia',
        },
      ])
        {
          ..._node('webView', {'properties': properties}),
          'id': 'webView ${properties['webviewType']}',
        },
      _node('dropdown', {
        'properties': {'items': []},
      }),
      _node('listView', {'properties': {}, ..._collection}),
      _node('gridView', {
        'properties': {
          'gridDelegate': {'type': 'fixedCrossAxisCount', 'crossAxisCount': 2},
        },
        ..._collection,
      }),
      _node('pageView', {'properties': {}, ..._collection}),
      _node('tabBar', {
        'properties': {},
        'scrollDirection': 'horizontal',
        'reverse': false,
        'primary': true,
        'keyboardDismissBehavior': 'manual',
        'isScrollable': false,
        'physics': 'platformDependent',
        'useFlutterListView': false,
        'shouldAlwaysScroll': true,
      }),
      _node('singlePlaceholder', {
        'allowedTypes': [],
        'deniedTypes': [],
        'children': [],
      }),
      _node('autoPlaceholder', {'rowColumnType': 'row'}),
      _node('freeformPlaceholder'),
      _node('placeholder'),
      _node('accordion', {'rowColumnType': 'column', 'properties': {}}),
      _node('external', {'properties': {}}),
      _node('gauge', {
        'gaugeKind': 'radial',
        'value': 72.6,
        'properties': {
          'segments': 0,
          'target': 90,
          'labels': [0, 100],
          'labelFontFamily': 'JetBrains Mono',
          'zones': [
            {'from': 0, 'to': 50, 'color': '#FF4A3D'},
            {'from': 50, 'to': 100, 'color': '#2FD17A'},
          ],
        },
      }),
      _node('chart', {
        'chartKind': 'series',
        'selectedIndex': 2,
        'properties': {
          'chartType': 'line',
          'xSlots': 8,
          'nowValue': 342,
          'series': [
            {
              'field': 'actual',
              'kind': 'area',
              'fillTo': 'plan',
              'endDot': true,
            },
            {'field': 'plan', 'kind': 'line', 'dashed': true},
          ],
          'referenceLines': [
            {'value': 85, 'color': '#2FD17A'},
          ],
          'sampleData': [
            {'label': '14', 'actual': 0, 'plan': 0},
            {'label': '15', 'actual': 700, 'plan': 800},
          ],
        },
      }),
    ])
      NodeJsonConverter().fromJson(json)!,
  ];
}

/// Node types declared in lib/src/api/nodes, as node_registry_test finds
/// them.
Set<String> declaredNodeTypes() {
  const propertyTypes = {'material', 'cupertino'};
  final pattern = RegExp(r"^  final String type = '(\w+)';", multiLine: true);
  return {
    for (final file in Directory('lib/src/api/nodes').listSync())
      if (file is File && !file.path.endsWith('.g.dart'))
        for (final match in pattern.allMatches(file.readAsStringSync()))
          match.group(1)!,
  }.difference(propertyTypes);
}

void main() {
  group('every node type round-trips', () {
    final nodes = sampleNodes();

    test('samples cover every node type', () {
      expect(
        declaredNodeTypes().difference({for (final n in nodes) n.type}),
        isEmpty,
      );
    });

    for (final node in nodes) {
      test('${node.type} "${node.id}"', () {
        final json = encodeDecode(node.toJson()) as Map;
        final back = NodeJsonConverter().fromJson(json)!;
        expect(back.runtimeType, node.runtimeType);
        expect(back, node);
        final expected = encodeDecode(json) as Map;
        // As in node_json_golden_test: a non-tristate checkbox reads null as
        // false.
        if (expected['type'] == 'checkbox' && expected['value'] == null) {
          expected['value'] = false;
        }
        // Master retains legacy-required list/grid/page keys on serialization.
        // They may be absent in older input JSON, but their defaults must be
        // restored without changing any keys supplied by that input.
        final roundTrip = encodeDecode(back.toJson()) as Map;
        if (const {'listView', 'gridView', 'pageView'}.contains(node.type)) {
          for (final key in ['deniedTypes', 'useFlutterListView']) {
            if (!expected.containsKey(key) && roundTrip.containsKey(key)) {
              roundTrip.remove(key);
            }
          }
        }
        expect(roundTrip, expected);
      });
    }
  });

  group('omitted defaults', () {
    final legacy = jsonDecode(
      File('test/fixtures/omitted_defaults_5_3_0.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    for (final MapEntry(key: name, value: build)
        in omittedDefaultModels().entries) {
      test('$name round-trips without its default keys', () {
        final model = build();
        final json = encodeDecode((model as dynamic).toJson()) as Map;
        final back = parseModel(name, json);
        expect(back, model);
        expect(encodeDecode((back as dynamic).toJson()), json);
        // Strictly smaller than what 5.3.0 wrote.
        expect(
          jsonEncode(json).length,
          lessThan(jsonEncode(legacy[name]).length),
        );
      });

      test('$name reads JSON written by 5.3.0', () {
        final model = build();
        final old = parseModel(name, legacy[name] as Map);
        expect(old, model);
        expect(
          encodeDecode((old as dynamic).toJson()),
          encodeDecode((model as dynamic).toJson()),
        );
      });
    }

    test('a pulse round-trips and is left out when unset', () {
      final RectangleNode rect = RectangleNode.fromJson({
        'id': 'r',
        'name': 'Skeleton',
        'type': 'rectangle',
        'basicBoxLocal': [0, 0, 100, 12],
        'pulse': {'durationMillis': 600},
      });
      expect(rect.pulse, const PulseModel(durationMillis: 600));
      expect(rect.pulse!.minOpacity, 0.45);
      expect(rect.toJson()['pulse'], {
        'pulseKind': 'relative',
        'durationMillis': 600,
      });
      expect(
        RectangleNode.fromJson(rect.toJson()).pulse,
        const PulseModel(durationMillis: 600),
      );
      rect.pulse = null;
      expect(rect.toJson(), isNot(contains('pulse')));
    });

    test('a spacer reads JSON that leaves out its defaults', () {
      final SpacerNode spacer = SpacerNode.fromJson({
        'id': 's',
        'name': 'Spacer',
        'type': 'spacer',
        'basicBoxLocal': [0, 0, 1, 1],
        'flex': 2,
      });
      expect(spacer.positioningMode, PositioningMode.align);
      expect(spacer.aspectRatioLock, isFalse);
      expect(spacer.reactions, isEmpty);
      // Master deliberately writes this key for SDKs <= 6.0.0.
      expect(spacer.toJson()['positioningMode'], 'align');
    });

    test('empty action lists, maps and sets are left out', () {
      expect(
        ConditionalAction(expression: _expression()).toJson().keys,
        isNot(anyOf(contains('actions'), contains('elseActions'))),
      );
      expect(ForEachAction().toJson(), isNot(contains('actions')));
      expect(CloudFilesAction().toJson(), isNot(contains('actions')));
      expect(ApiCallAction().toJson(), isNot(contains('parameters')));
      expect(CallFunctionAction(name: 'f').toJson(), isNot(contains('params')));
      expect(
        VariableData(id: 'v', name: 'n').toJson(),
        isNot(contains('extra')),
      );
      expect(
        ElseCondition(id: 'e', lastUpdated: _time).toJson(),
        isNot(contains('actions')),
      );
      expect(TextFieldProperties().toJson(), isNot(contains('autofillHints')));
    });

    test('squeezable is written only when set', () {
      TextNode node() => TextNode(
        id: 't',
        name: 'T',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
        characters: 'a',
        horizontalFit: SizeFit.shrinkWrap,
      );
      expect(node().toJson(), isNot(contains('squeezable')));
      final json = encodeDecode((node()..squeezable = true).toJson()) as Map;
      expect(json['squeezable'], true);
      expect(TextNode.fromJson(json).squeezable, isTrue);
      expect(TextNode.fromJson(node().toJson()).squeezable, isFalse);
    });

    test('non-default values are still written', () {
      expect(
        ConditionalAction(
          expression: _expression(),
          elseActions: [CloudFilesAction()],
        ).toJson(),
        contains('elseActions'),
      );
      expect(ApiCallAction(parameters: {'a': 'b'}).toJson()['parameters'], {
        'a': 'b',
      });
      expect(
        CallFunctionAction(name: 'f', params: {'x': 1}).toJson()['params'],
        {'x': 1},
      );
      expect(
        VariableData(id: 'v', name: 'n', extra: {'k': true}).toJson()['extra'],
        {'k': true},
      );
      expect(
        TextFieldProperties(autofillHints: {TextInputAutofillHints.email})
            .toJson()['autofillHints'],
        ['email'],
      );
    });
  });

  group('JSON from build scripts', () {
    test('a spacer needs no positioning, aspect lock or reactions', () {
      final node =
          NodeJsonConverter().fromJson({
                'type': 'spacer',
                'id': 'sp',
                'name': 'sp',
                'flex': 1,
                'basicBoxLocal': [0, 0, 10, 10],
                'horizontalFit': 'expanded',
                'verticalFit': 'expanded',
              })!
              as SpacerNode;
      expect(node.positioningMode, PositioningMode.align);
      expect(node.aspectRatioLock, isFalse);
      expect(node.reactions, isEmpty);
      // Older readers require these keys, so they are still written.
      expect(
        node.toJson(),
        allOf(
          containsPair('positioningMode', 'align'),
          containsPair('aspectRatioLock', false),
          containsPair('reactions', isEmpty),
        ),
      );
    });

    test('a grid needs no useFlutterListView or isScrollable', () {
      final node =
          NodeJsonConverter().fromJson({
                'type': 'gridView',
                'id': 'grid',
                'name': 'grid',
                'basicBoxLocal': [0, 0, 300, 300],
                'allowedTypes': [],
                'deniedTypes': ['gridView'],
                'children': ['item'],
                'properties': {
                  'gridDelegate': {
                    'type': 'fixedCrossAxisCount',
                    'crossAxisCount': 2,
                    'shrinkWrapRows': true,
                  },
                },
              })!
              as GridViewNode;
      expect(node.useFlutterListView, isFalse);
      expect(node.isScrollable, isTrue);
      expect(node.properties.gridDelegate.shrinkWrapRows, isTrue);
      final json = encodeDecode(node.toJson()) as Map;
      expect(json, containsPair('useFlutterListView', false));
      expect(json, containsPair('isScrollable', true));
      expect(
        (json['properties'] as Map)['gridDelegate'],
        containsPair('shrinkWrapRows', true),
      );
      expect(NodeJsonConverter().fromJson(json), node);
    });

    test('rows sized to their content leave the item main axis free', () {
      final grid = GridViewNode(
        id: 'grid',
        name: 'grid',
        basicBoxLocal: NodeBox(0, 0, 316, 300),
        children: ['item'],
        properties: GridViewProperties(
          gridDelegate: FixedCrossAxisCountGridDelegateProperties(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisExtent: 130,
            shrinkWrapRows: true,
          ),
        ),
      );
      final constraints = grid.relegatedConstraintsToChildren(grid)!;
      expect(constraints.minWidth, 150);
      expect(constraints.maxWidth, 150);
      expect(constraints.minHeight, isNull);
      expect(constraints.maxHeight, isNull);
    });
  });
}
