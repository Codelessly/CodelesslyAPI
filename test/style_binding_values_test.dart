import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('toCornerRadius', () {
    test('a number rounds every corner', () {
      expect(
        12.toCornerRadius(),
        const CornerRadius.all(RadiusModel.circular(12)),
      );
      expect(
        '12'.toCornerRadius(),
        const CornerRadius.all(RadiusModel.circular(12)),
      );
      expect(
        [8].toCornerRadius(),
        const CornerRadius.all(RadiusModel.circular(8)),
      );
    });

    test(
      'a list of four is top-left, top-right, bottom-right, bottom-left',
      () {
        const expected = CornerRadius.only(
          tl: RadiusModel.circular(18),
          tr: RadiusModel.circular(18),
          br: RadiusModel.circular(0),
          bl: RadiusModel.circular(0),
        );
        expect([18, 18, 0, 0].toCornerRadius(), expected);
        expect('[18, 18, 0, 0]'.toCornerRadius(), expected);
        expect([18, 18, 0, 0].typedValue<CornerRadius>(), expected);
      },
    );

    test("a CornerRadius's JSON still parses", () {
      const radius = CornerRadius.only(
        tl: RadiusModel.circular(4),
        tr: RadiusModel.circular(6),
        bl: RadiusModel.circular(8),
        br: RadiusModel.circular(10),
      );
      expect((radius.toJson() as Object?).toCornerRadius(), radius);
      expect(radius.toCornerRadius(), radius);
    });

    test('anything else is null', () {
      expect(null.toCornerRadius(), isNull);
      expect('big'.toCornerRadius(), isNull);
      expect([1, 2, 3].toCornerRadius(), isNull);
      expect({'a': 1}.toCornerRadius(), isNull);
    });
  });

  group('toEdgeInsetsModel', () {
    test('numbers, lists and text', () {
      expect(12.toEdgeInsetsModel(), const EdgeInsetsModel.all(12));
      expect('12'.toEdgeInsetsModel(), const EdgeInsetsModel.all(12));
      expect([12].toEdgeInsetsModel(), const EdgeInsetsModel.all(12));
      expect(
        [16, 8].toEdgeInsetsModel(),
        const EdgeInsetsModel.symmetric(horizontal: 16, vertical: 8),
      );
      expect(
        '[1, 2, 3, 4]'.toEdgeInsetsModel(),
        const EdgeInsetsModel.only(left: 1, top: 2, right: 3, bottom: 4),
      );
      expect('wide'.toEdgeInsetsModel(), isNull);
      expect('"wide"'.toEdgeInsetsModel(), isNull);
    });
  });
}
