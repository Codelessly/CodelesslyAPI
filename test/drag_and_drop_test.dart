import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('draggable and dropTarget round-trip and are omitted by default', () {
    final FrameNode node = FrameNode(
      id: 'card',
      name: 'Card',
      basicBoxLocal: NodeBox(0, 0, 260, 90),
      children: [],
    );
    expect(node.toJson().containsKey('draggable'), isFalse);
    expect(node.toJson().containsKey('dropTarget'), isFalse);

    node
      ..draggable = const DraggableModel(
        group: 'card',
        data: r'${item.id}',
        whileDragging: DragSourceStyle.hidden,
      )
      ..dropTarget = const DropTargetModel(
        accepts: ['card'],
        key: r'${item.id}',
        acceptIf: r'${= drag.count <= 2}',
        listNodeId: 'cards',
      );
    final Map json = node.toJson();
    // Defaults stay out of the JSON.
    expect(json['draggable'], {'group': 'card', 'data': r'${item.id}', 'whileDragging': 'hidden'});
    expect((json['dropTarget'] as Map).containsKey('slot'), isFalse);

    final BaseNode back = NodeJsonConverter().fromJson(json)!;
    expect(back.draggable, node.draggable);
    expect(back.dropTarget, node.dropTarget);
    expect(back.dropTarget!.acceptsGroup('card'), isTrue);
    expect(back.dropTarget!.acceptsGroup('column'), isFalse);
  });

  test('hand-written drag JSON may leave everything out', () {
    final BaseNode node = NodeJsonConverter().fromJson({
      'type': 'frame',
      'id': 'lane',
      'name': 'Lane',
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 10, 'height': 10},
      'draggable': {},
      'dropTarget': {'accepts': ['card']},
    })!;
    expect(node.draggable, const DraggableModel());
    expect(node.draggable!.start, DragStart.auto);
    expect(node.dropTarget!.slot, DropSlot.gap);
  });

  test('feedbackAnchor round-trips, defaults to grab and reads unknown names as grab', () {
    expect(const DraggableModel().feedbackAnchor, FeedbackAnchor.grab);
    expect(const DraggableModel().toJson().containsKey('feedbackAnchor'), isFalse);
    const DraggableModel centred = DraggableModel(group: 'hive', feedbackAnchor: FeedbackAnchor.center);
    expect(centred.toJson(), {'group': 'hive', 'feedbackAnchor': 'center'});
    expect(DraggableModel.fromJson(centred.toJson()), centred);
    expect(DraggableModel.fromJson({'feedbackAnchor': 'nowhere'}).feedbackAnchor, FeedbackAnchor.grab);
    expect(centred.copyWith(feedbackAnchor: FeedbackAnchor.grab), const DraggableModel(group: 'hive'));
    for (final anchor in FeedbackAnchor.values) {
      expect(anchor.prettify, isNotEmpty);
    }
  });

  test('drag triggers have names', () {
    for (final t in [...TriggerType.dragSource, ...TriggerType.dropTarget, TriggerType.secondaryClick]) {
      expect(t.prettify, isNotEmpty);
      expect(TriggerModel.fromJson(TriggerModel(type: t).toJson()).type, t);
    }
  });
}
