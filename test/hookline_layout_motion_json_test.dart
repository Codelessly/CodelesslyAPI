import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('MotionCurve', () {
    test('reads and writes easeInOutCubic and step', () {
      for (final MotionCurve curve in [
        MotionCurve.easeInOutCubic,
        MotionCurve.step,
      ]) {
        final MotionModel motion = MotionModel.fromJson({
          'durationMs': 500,
          'curve': curve.name,
          'loop': 'reverse',
          'opacity': 0,
        });
        expect(motion.curve, curve);
        expect(MotionModel.fromJson(motion.toJson()), motion);
      }
    });

    test('scrollTo accepts the new curves', () {
      final action = ScrollToAction.fromJson({
        'type': 'scrollTo',
        'nodeId': 'n',
        'curve': 'easeInOutCubic',
      });
      expect(action.curve, MotionCurve.easeInOutCubic);
      expect(
        (ScrollToAction.fromJson({...action.toJson()})).curve,
        MotionCurve.easeInOutCubic,
      );
    });
  });

  test('list stretchItems round-trips and is omitted by default', () {
    final ListViewProperties props = ListViewProperties.fromJson({
      'stretchItems': true,
      'dividerProperties': <String, dynamic>{},
    });
    expect(props.stretchItems, isTrue);
    expect(props.toJson()['stretchItems'], isTrue);
    expect(props.copyWith(stretchItems: false).stretchItems, isFalse);
    expect(props.copyWith().stretchItems, isTrue);
    expect(
      ListViewProperties().toJson().containsKey('stretchItems'),
      isFalse,
    );
  });

  test('sizeTransition round-trips on any node', () {
    final FrameNode frame = FrameNode.fromJson({
      'id': 'f',
      'name': 'f',
      'type': 'frame',
      'basicBoxLocal': [0, 0, 10, 10],
      'children': <String>[],
      'sizeTransition': {'durationMillis': 250, 'curve': 'easeOutCubic'},
    });
    expect(
      frame.sizeTransition,
      const NodeTransition(
        durationMillis: 250,
        curve: TransitionCurve.easeOutCubic,
      ),
    );
    final FrameNode copy = FrameNode.fromJson(frame.toJson());
    expect(copy.sizeTransition, frame.sizeTransition);
    final RowColumnNode column = RowColumnNode.fromJson({
      'id': 'c',
      'name': 'c',
      'type': 'column',
      'basicBoxLocal': [0, 0, 10, 10],
      'children': <String>[],
      'sizeTransition': {'durationMillis': 300},
    });
    expect(column.sizeTransition?.durationMillis, 300);
    expect(
      RowColumnNode.fromJson(column.toJson()).sizeTransition?.durationMillis,
      300,
    );
  });

  test('radial gradient centre and radius round-trip', () {
    final PaintModel paint = PaintModel.fromJson({
      'id': 'p',
      'type': 'gradientRadial',
      'gradientStops': [
        {
          'color': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
          'position': 0,
        },
        {
          'color': {'r': 0, 'g': 0, 'b': 1, 'a': 0},
          'position': 1,
        },
      ],
      'gradientCenter': [0.2, 1.4],
      'gradientRadius': 0.8,
    });
    expect(paint.gradientCenter, const AlignmentData(0.2, 1.4));
    expect(paint.gradientRadius, 0.8);
    final PaintModel copy = PaintModel.fromJson(paint.toJson());
    expect(copy.gradientCenter, paint.gradientCenter);
    expect(copy.gradientRadius, 0.8);
    expect(paint.sanitize().gradientCenter, paint.gradientCenter);
    expect(paint.copyWith(clearRadialShape: true).gradientRadius, isNull);
    expect(PaintModel.linearPaint.toJson().containsKey('gradientCenter'),
        isFalse);
  });
}
