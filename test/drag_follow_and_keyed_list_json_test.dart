import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  RectangleNode card() => RectangleNode(
    id: 'card',
    name: 'Card',
    basicBoxLocal: NodeBox(0, 0, 340, 214),
  );

  group('DragModel', () {
    test('defaults are left out of JSON', () {
      expect(const DragModel().toJson(), isEmpty);
      final DragModel read = DragModel.fromJson(const {});
      expect(read, const DragModel());
      expect(read.axis, DragAxis.free);
      expect(read.follow, isTrue);
      expect(read.returnMs, 260);
      expect(read.returnCurve, MotionCurve.easeOutBack);
      expect(read.dismissDistance, isNull);
      expect(read.dismissVelocity, isNull);
    });

    test('a card drag survives a node round trip', () {
      const DragModel drag = DragModel(
        axis: DragAxis.horizontal,
        rotate: 9,
        originY: -1,
        dismissDistance: 0.28,
        dismissVelocity: 700,
        xVariable: 'deckDrag',
      );
      final RectangleNode node = card()..drag = drag;
      final Map json = node.toJson();
      expect(json['drag'], {
        'axis': 'horizontal',
        'rotate': 9.0,
        'originY': -1.0,
        'dismissDistance': 0.28,
        'dismissVelocity': 700.0,
        'xVariable': 'deckDrag',
      });
      final RectangleNode read = RectangleNode.fromJson(json);
      expect(read.drag, drag);
    });

    test('hand-written JSON reads into every node type with drag', () {
      final BaseNode? node = NodeJsonConverter().fromJson({
        'id': 'f',
        'type': 'frame',
        'name': 'Card',
        'basicBoxLocal': [0, 0, 100, 60],
        'drag': {'axis': 'vertical', 'returnMs': 0, 'yVariable': 'pull'},
      });
      expect(node!.drag!.axis, DragAxis.vertical);
      expect(node.drag!.returnMs, 0);
      expect(node.drag!.yVariable, 'pull');
    });

    test('a node without drag leaves it out of JSON', () {
      expect(card().toJson().containsKey('drag'), isFalse);
      expect(RectangleNode.fromJson(card().toJson()).drag, isNull);
    });

    test('dismisses past the distance or the velocity', () {
      const DragModel drag = DragModel(
        dismissDistance: 0.28,
        dismissVelocity: 700,
      );
      expect(drag.dismisses(distance: -0.3, velocity: 0), isTrue);
      expect(drag.dismisses(distance: 0.1, velocity: -800), isTrue);
      expect(drag.dismisses(distance: 0.2, velocity: 300), isFalse);
      expect(
        const DragModel().dismisses(distance: 5, velocity: 9000),
        isFalse,
      );
    });

    test('copyWith clears and keeps values', () {
      const DragModel drag = DragModel(dismissDistance: 0.3, xVariable: 'x');
      expect(drag.copyWith(clearDismissDistance: true).dismissDistance, isNull);
      expect(drag.copyWith(rotate: 4).xVariable, 'x');
      expect(drag.copyWith(clearXVariable: true).xVariable, isNull);
    });
  });

  group('keyed, z-ordered stacked list', () {
    test('reversePaintOrder survives JSON and is left out when false', () {
      final ListViewProperties props = ListViewProperties(
        stacked: true,
        reversePaintOrder: true,
      );
      final Map json = props.toJson();
      expect(json['reversePaintOrder'], isTrue);
      expect(ListViewProperties.fromJson(json).reversePaintOrder, isTrue);
      expect(
        ListViewProperties(stacked: true).toJson().containsKey(
          'reversePaintOrder',
        ),
        isFalse,
      );
      expect(ListViewProperties.fromJson(const {}).reversePaintOrder, isFalse);
      expect(props.copyWith().reversePaintOrder, isTrue);
      expect(props, isNot(ListViewProperties(stacked: true)));
    });

    test('item key and z index bindings are list variables', () {
      expect(ListViewNode.itemKeyVariable, 'itemKey');
      expect(ListViewNode.itemZIndexVariable, 'itemZIndex');
      final BaseNode? list = NodeJsonConverter().fromJson({
        'id': 'deck',
        'type': 'listView',
        'name': 'Deck',
        'basicBoxLocal': [0, 0, 340, 260],
        'properties': {'stacked': true, 'reversePaintOrder': true},
        'variables': {
          'data': r'${passes}',
          'itemKey': r'${item.id}',
          'itemZIndex': r'${= -((index - front + 9) % 9)}',
        },
        'children': <String>[],
      });
      final ListViewNode node = list! as ListViewNode;
      expect(node.properties.reversePaintOrder, isTrue);
      expect(node.variables['itemKey'], r'${item.id}');
      final ListViewNode read = ListViewNode.fromJson(node.toJson());
      expect(read.variables['itemZIndex'], node.variables['itemZIndex']);
    });
  });

  test('a fractional width survives JSON', () {
    final RectangleNode node = card()..widthFactor = 0.42;
    final Map json = node.toJson();
    expect(json['widthFactor'], 0.42);
    expect(RectangleNode.fromJson(json).widthFactor, 0.42);
    expect(RectangleNode.fromJson(json).heightFactor, isNull);
  });
}
