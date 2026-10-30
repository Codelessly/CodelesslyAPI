import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('NotchModel', () {
    test('reads hand-written JSON with defaults', () {
      final NotchModel notch = NotchModel.fromJson({'offset': 146, 'relative': false});
      expect(notch.edge, NotchEdge.leftRight);
      expect(notch.radius, 10);
      expect(notch.fromEnd, isFalse);
      expect(notch.positionOn(214), 146);
    });

    test('positions relative and from-the-end offsets', () {
      expect(const NotchModel(offset: 0.25).positionOn(200), 50);
      expect(const NotchModel(offset: 40, relative: false, fromEnd: true).positionOn(300), 260);
      expect(const NotchModel(offset: 0.1, fromEnd: true).positionOn(100), closeTo(90, 1e-9));
    });

    test('vertical edges measure from the top', () {
      expect(NotchEdge.leftRight.isVertical, isTrue);
      expect(NotchEdge.left.isVertical, isTrue);
      expect(NotchEdge.topBottom.isVertical, isFalse);
    });
  });

  group('notches on nodes', () {
    final Map<String, dynamic> frameJson = {
      'type': 'frame',
      'id': 'ticket',
      'name': 'Ticket',
      'children': <String>[],
      'basicBoxLocal': {'x': 0, 'y': 0, 'width': 340, 'height': 420},
      'notches': [
        {'offset': 146, 'relative': false, 'radius': 11},
        {'offset': 120, 'relative': false, 'fromEnd': true, 'radius': 12},
      ],
    };

    test('a frame keeps its notches through JSON', () {
      final FrameNode frame = FrameNode.fromJson(frameJson);
      expect(frame.notches, hasLength(2));
      expect(frame.notches.last.fromEnd, isTrue);
      final FrameNode again = FrameNode.fromJson(frame.toJson());
      expect(again.notches, frame.notches);
    });

    test('nodes without notches leave them out of their JSON', () {
      final FrameNode frame = FrameNode.fromJson({...frameJson}..remove('notches'));
      expect(frame.notches, isEmpty);
      expect(frame.toJson().containsKey('notches'), isFalse);
    });

    test('rectangles and rows keep notches too', () {
      final RectangleNode rect = RectangleNode.fromJson({
        'type': 'rectangle',
        'id': 'r',
        'name': 'R',
        'basicBoxLocal': {'x': 0, 'y': 0, 'width': 100, 'height': 60},
        'notches': [
          {'edge': 'top', 'offset': 0.5, 'radius': 6},
        ],
      });
      expect(rect.notches.single.edge, NotchEdge.top);
      expect(RectangleNode.fromJson(rect.toJson()).notches, rect.notches);
    });
  });
}
