import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  RectangleNode card() => RectangleNode(
    id: 'card',
    name: 'Card',
    basicBoxLocal: NodeBox(0, 0, 340, 214),
  );

  group('DragModel', () {
    test(
      'the follow, fly-out and variable settings are left out by default',
      () {
        expect(const DragModel().toJson(), isEmpty);
        final DragModel read = DragModel.fromJson(const {});
        expect(read, const DragModel());
        expect(read.follow, isTrue);
        expect(read.flyOutDistance, isNull);
        expect(read.flyOutCurve, MotionCurve.easeIn);
        expect(read.xVariable, isEmpty);
      },
    );

    test('a card drag survives a node round trip', () {
      const DragModel drag = DragModel(
        axis: DragAxis.horizontal,
        release: DragRelease.dismiss,
        rotateFactor: 9,
        originY: -1,
        distanceThreshold: 0.28,
        velocityThreshold: 700,
        flyOutDistance: 1.25,
        follow: false,
        xVariable: 'deckDrag',
      );
      final RectangleNode node = card()..drag = drag;
      final Map json = node.toJson();
      expect(json['drag'], {
        'axis': 'horizontal',
        'release': 'dismiss',
        'distanceThreshold': 0.28,
        'velocityThreshold': 700.0,
        'rotateFactor': 9.0,
        'originY': -1.0,
        'follow': false,
        'flyOutDistance': 1.25,
        'xVariable': 'deckDrag',
      });
      expect(RectangleNode.fromJson(json).drag, drag);
    });

    test('the first drag format reads into the current one', () {
      final BaseNode? node = NodeJsonConverter().fromJson({
        'id': 'f',
        'type': 'frame',
        'name': 'Card',
        'basicBoxLocal': [0, 0, 100, 60],
        'drag': {
          'axis': 'horizontal',
          'rotate': 9,
          'dismissDistance': 0.28,
          'dismissVelocity': 700,
          'dismissMs': 200,
          'xVariable': 'deckDrag',
        },
      });
      final DragModel drag = node!.drag!;
      expect(drag.axis, DragAxis.horizontal);
      expect(drag.rotateFactor, 9);
      expect(drag.release, DragRelease.dismiss);
      expect(drag.distanceThreshold, 0.28);
      expect(drag.velocityThreshold, 700);
      expect(drag.flyOutMs, 200);
      // Defaults of the first format, which its JSON left out.
      expect(drag.snapBackMs, 260);
      expect(drag.snapCurve, MotionCurve.easeOutBack);
      expect(drag.flyOutDistance, 1.25);
      expect(drag.xVariable, 'deckDrag');
      // Written back in the current format.
      expect(
        drag.toJson().keys.toSet().intersection(DragModel.legacyKeys),
        isEmpty,
      );
    });

    test('a first-format drag without dismiss settings springs back', () {
      final DragModel drag = DragModel.fromJson(const {
        'axis': 'vertical',
        'returnMs': 0,
        'yVariable': 'pull',
      });
      expect(drag.release, DragRelease.snapBack);
      expect(drag.snapBackMs, 0);
      expect(drag.yVariable, 'pull');
    });

    test(
      'a first-format drag with only a velocity never dismisses by distance',
      () {
        final DragModel drag = DragModel.fromJson(const {
          'dismissVelocity': 900,
        });
        expect(drag.release, DragRelease.dismiss);
        expect(drag.velocityThreshold, 900);
        expect(drag.distanceThreshold, double.maxFinite);
      },
    );

    test('a node without drag leaves it out of JSON', () {
      expect(card().toJson().containsKey('drag'), isFalse);
      expect(RectangleNode.fromJson(card().toJson()).drag, isNull);
    });

    test('copyWith clears and keeps values', () {
      const DragModel drag = DragModel(flyOutDistance: 1.5, xVariable: 'x');
      expect(drag.copyWith(clearFlyOutDistance: true).flyOutDistance, isNull);
      expect(drag.copyWith(rotateFactor: 4).xVariable, 'x');
      expect(drag.copyWith(xVariable: '').xVariable, isEmpty);
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
        ListViewProperties(stacked: true)
            .toJson()
            .containsKey('reversePaintOrder'),
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
