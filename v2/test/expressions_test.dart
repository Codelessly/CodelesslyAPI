import 'package:codelessly_api_v2/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('variables', () {
    test('decode totally and encode sparsely', () {
      final v = Variable.fromJson({'id': 'v', 'name': 'count', 'type': 'integer', 'value': '3', 'x': 1})!;
      expect(v.value, 3);
      expect(v.extra, {'x': 1});
      expect(v.toJson(), {'id': 'v', 'name': 'count', 'type': 'integer', 'value': 3, 'x': 1});
      expect(Variable.fromJson(v.toJson()), v);
      expect(const Variable(name: 'n').toJson(), {'name': 'n'});
      expect(Variable.fromJson({'type': 'integer'}), isNull);
      expect(Variable.fromJson({'name': 'bad', 'type': 'nope', 'value': 5})!.type, VariableType.text);
    });

    test('values are read as their type', () {
      expect(VariableType.decimal.coerce('4.5'), 4.5);
      expect(VariableType.integer.coerce(2.9), 2);
      expect(VariableType.boolean.coerce('TRUE'), true);
      expect(VariableType.boolean.coerce('maybe'), isNull);
      expect(VariableType.color.coerce('#f00f00'), '#FFF00F00');
      expect(VariableType.list.coerce('[1, 2]'), [1, 2]);
      expect(VariableType.map.coerce('{"a": 1}'), {'a': 1});
      expect(VariableType.text.coerce(3.0), '3');
    });

    test('computed variables and functions', () {
      const total = Variable(name: 'total', formula: 'price * qty');
      const f = Variable(name: 'twice', formula: 'x * 2', parameters: ['x']);
      expect(total.isComputed, isTrue);
      expect(total.isFunction, isFalse);
      expect(f.isFunction, isTrue);
      expect(Variable.fromJson(f.toJson()), f);
    });

    test('choice options', () {
      final v = Variable.fromJson({
        'name': 'tab',
        'type': 'choice',
        'value': 'b',
        'options': ['a', {'value': 'b', 'label': 'Bee'}],
      })!;
      expect(v.options, const [VariableOption('a'), VariableOption('b', 'Bee')]);
      expect(v.toJson()['options'], ['a', {'value': 'b', 'label': 'Bee'}]);
    });
  });

  group('conditions', () {
    final json = <String, Object?>{
      'id': 'c1',
      'name': 'Low stock',
      'branches': [
        {
          'when': {
            'and': [
              {'left': r'${stock}', 'op': 'lessThan', 'right': '5'},
              {'left': r'${on}', 'op': 'isTrue'},
            ],
          },
          'set': [
            {'node': 'badge', 'path': 'visible', 'value': true},
          ],
        },
        {
          'when': {'left': r'${tag}', 'op': 'contains', 'right': {'raw': r'${x}'}},
          'set': [
            {'node': 'badge', 'path': 'opacity', 'value': 0.5},
          ],
        },
        {
          'set': [
            {'node': 'badge', 'path': 'visible', 'value': false},
          ],
        },
      ],
    };

    test('round-trip', () {
      final c = Condition.fromJson(json)!;
      expect(c.branches, hasLength(3));
      expect(c.branches.last.isElse, isTrue);
      final first = c.branches.first.when! as Junction;
      expect(first.join, Join.and);
      expect((first.parts[1] as Comparison).op, ConditionOp.isTrue);
      expect((c.branches[1].when! as Comparison).right, const ConditionOperand(r'${x}', raw: true));
      expect(c.toJson(), json);
      expect(Condition.fromJson(c.toJson()), c);
    });

    test('what a condition sets and reads', () {
      final c = Condition.fromJson(json)!;
      expect(c.targets.toList(), [('badge', 'visible'), ('badge', 'opacity')]);
      expect(c.branches.first.when!.operands.map((o) => o.text), [r'${stock}', '5', r'${on}']);
    });

    test('bad entries are dropped, not thrown', () {
      final c = Condition.fromJson({
        'branches': [
          5,
          {'when': 'nope', 'set': [{'node': 'n'}, 'x']},
        ],
      })!;
      expect(c.branches.single.when, isNull);
      expect(c.branches.single.sets, isEmpty);
    });
  });

  test('a layout document holds its variables and conditions', () {
    final doc = LayoutDocument.fromJson({
      'schema': 2,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas'},
      },
      'variables': {
        'c': [
          {'name': 'count', 'type': 'integer', 'value': 0},
        ],
      },
      'conditions': {
        'c': [
          {
            'id': 'k',
            'branches': [
              {'set': [{'node': 'c', 'path': 'opacity', 'value': 1}]},
            ],
          },
        ],
      },
    });
    final logic = doc.logic;
    expect(logic.variablesOf('c').single.name, 'count');
    expect(logic.conditionsOf('c').single.id, 'k');
    final next = doc.withLogic(const LayoutLogic(variables: {'c': [Variable(name: 'x')]}));
    expect(next.toJson()['variables'], {
      'c': [
        {'name': 'x'},
      ],
    });
    expect(next.toJson().containsKey('conditions'), isFalse);
    expect(LayoutLogic.fromJson(doc.toJson()), logic);
  });

  group('binding paths', () {
    final box = Node.fromJson({
      'type': 'box',
      'layout': {'width': {'fill': 100}, 'height': 40},
      'decoration': {
        'fills': [
          {'id': 'p1', 'color': '#FF000000', 'opacity': 0.5},
          {'type': 'linear', 'id': 'g', 'stops': [{'position': 0, 'color': '#80FF0000'}, {'position': 1, 'color': '#FF0000FF'}]},
        ],
        'strokes': [{'id': 's1', 'color': '#FF000000'}],
        'effects': [
          {'type': 'dropShadow', 'id': 'e1', 'blurRadius': 4},
          {'type': 'dropShadow', 'id': 'e2', 'blurRadius': 2},
        ],
      },
    }, id: 'b')!;

    test('parse', () {
      expect(BindPaths.parse('decoration.fills[0].stops[2].color'), ['decoration', 'fills', 0, 'stops', 2, 'color']);
      expect(BindPaths.parse('decoration.effects.*.visible'), ['decoration', 'effects', '*', 'visible']);
      expect(BindPaths.parse('a..b'), isEmpty);
    });

    test('node-level and layout', () {
      expect(BindPaths.apply(box, 'visible', 'false').visible, isFalse);
      expect(BindPaths.apply(box, 'visible', 0).visible, isFalse);
      expect(BindPaths.apply(box, 'opacity', 3).opacity, 1);
      final sized = BindPaths.apply(box, 'layout.width', '240');
      expect(sized.layout.width, const AxisSize.fill(240));
      expect(BindPaths.apply(box, 'layout.width', {'hug': 50}).layout.width, const AxisSize.hug(50));
      expect(BindPaths.apply(box, 'layout.flex', 0.2).layout.flex, 1);
      expect(BindPaths.apply(box, 'layout.flex', 3).layout.flex, 3);
      expect(BindPaths.apply(box, 'layout.padding', [8, 4]).layout.padding, const EdgeInsets.fromLTRB(8, 4, 8, 4));
      expect(BindPaths.apply(box, 'layout.margin', {'top': 44}).layout.margin, const EdgeInsets.fromLTRB(0, 44, 0, 0));
      expect(BindPaths.apply(box, 'layout.x', 12).layout.x, const AxisPosition.start(12));
      expect(BindPaths.apply(box, 'layout.constraints.maxWidth', 300).layout.constraints.maxWidth, 300);
      // Values that can't be read leave the node as it was.
      expect(BindPaths.apply(box, 'layout.width', 'wide'), same(box));
      expect(BindPaths.apply(box, 'visible', null), same(box));
      expect(BindPaths.apply(box, 'nope.at.all', 1), same(box));
    });

    test('paints by index or id; a color replaces the paint', () {
      final first = BindPaths.apply(box, 'decoration.fills[0]', '#2FD17A').decoration.fills.first;
      expect(first.color, const Color(0xFF2FD17A));
      expect(first.opacity, 1);
      expect(first.id, 'p1');
      final byId = BindPaths.apply(box, 'decoration.fills.p1.color', '#FF00FF00').decoration.fills.first;
      expect(byId.color, const Color(0xFF00FF00));
      expect(byId.opacity, 0.5, reason: '.color keeps the paint opacity');
      final stop = BindPaths.apply(box, 'decoration.fills[1].stops[0].color', '#00FF00').decoration.fills[1].stops[0];
      expect(stop.color, const Color(0x8000FF00), reason: '#RRGGBB keeps the stop alpha');
      final image = BindPaths.apply(box, 'decoration.fills.p1', 'https://x/y.png').decoration.fills.first;
      expect(image.type, PaintType.image);
      expect(image.image!.url, 'https://x/y.png');
      final url = BindPaths.apply(
        Node.fromJson({
          'type': 'box',
          'decoration': {'fills': [{'type': 'image', 'id': 'i', 'image': {'url': 'a.png'}}]},
        })!,
        'decoration.fills.i.image.url',
        'b.png',
      );
      expect(url.decoration.fills.single.image!.url, 'b.png');
      expect(BindPaths.apply(box, 'decoration.strokes.s1', '#FFFF0000').decoration.strokes.single.color, const Color(0xFFFF0000));
      // The first fill of a node without fills is added.
      const bare = Node(id: 'n', type: 'box');
      expect(BindPaths.apply(bare, 'decoration.fills[0]', '#FF112233').decoration.fills.single.color, const Color(0xFF112233));
    });

    test('effects, radius, stroke width', () {
      final hidden = BindPaths.apply(box, 'decoration.effects.*.visible', false).decoration.effects;
      expect(hidden.every((e) => !e.visible), isTrue);
      final one = BindPaths.apply(box, 'decoration.effects.e2.color', '#FF00FF00').decoration.effects;
      expect(one[1].color, const Color(0xFF00FF00));
      expect(one[0].color, box.decoration.effects[0].color);
      expect(BindPaths.apply(box, 'decoration.effects.*.offset.dy', 6).decoration.effects.first.offset.dy, 6);
      expect(BindPaths.apply(box, 'decoration.radius', [6, 6, 0, 0]).decoration.radius,
          const BorderRadius.only(topLeft: 6, topRight: 6));
      expect(BindPaths.apply(box, 'decoration.strokeWidth', '2').decoration.strokeWidth, 2);
    });

    test('props, and a text style for every run', () {
      final text = Node.fromJson({
        'type': 'text',
        'props': {
          'text': 'Hello world',
          'style': {'fontSize': 14, 'color': '#FF000000'},
          'runs': [
            {'start': 0, 'end': 5, 'style': {'color': '#FF0000FF'}},
          ],
        },
      }, id: 't')!;
      expect(BindPaths.apply(text, 'props.text', 42).prop(TextProps.text), '42');
      expect(BindPaths.apply(text, 'props.maxLines', '2').prop(TextProps.maxLines), 2);
      expect(BindPaths.apply(text, 'props.textAlign', 'center').prop(TextProps.textAlign), TextAlign.center);
      final red = BindPaths.apply(text, 'props.style.color', '#FFFF0000');
      expect(red.prop(TextProps.style).color, const Color(0xFFFF0000));
      expect(red.prop(TextProps.runs).single.style.color, const Color(0xFFFF0000));
      expect(BindPaths.apply(text, 'props.style.fontWeight', 'bold').prop(TextProps.style).fontWeight, 700);
      expect(BindPaths.apply(text, 'props.style.decoration', true).prop(TextProps.style).decoration, TextDecoration.lineThrough);
      final row = Node.fromJson({'type': 'row'}, id: 'r')!;
      expect(BindPaths.apply(row, 'props.spacing', '12').prop(FlexProps.spacing), 12);
      expect(BindPaths.apply(row, 'props.mainAxisAlignment', 'center').prop(FlexProps.mainAxisAlignment), MainAxisAlignment.center);
    });

    test('behaviours through their JSON', () {
      expect(BindPaths.apply(box, 'scale', '1.5').behaviours.scale, 1.5);
      final moved = BindPaths.apply(box, 'motion.translateY', 2);
      expect(moved.behaviours.motion!.translateY, 2);
    });
  });
}
