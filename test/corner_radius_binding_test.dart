import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('CornerRadius from a binding value', () {
    test('a number rounds every corner', () {
      final CornerRadius radius = 6.typedValue<CornerRadius>()!;
      expect(radius, const CornerRadius.all(RadiusModel.circular(6)));
    });

    test(
      'four numbers round top-left, top-right, bottom-right, bottom-left',
      () {
        final CornerRadius radius = <num>[
          6,
          6,
          0,
          0,
        ].typedValue<CornerRadius>()!;
        expect(radius.tl, const RadiusModel.circular(6));
        expect(radius.tr, const RadiusModel.circular(6));
        expect(radius.br, RadiusModel.zero);
        expect(radius.bl, RadiusModel.zero);
        expect(radius.linked, isFalse);
      },
    );

    test('the forms toJson writes still read back', () {
      for (final CornerRadius radius in <CornerRadius>[
        const CornerRadius.all(RadiusModel.circular(12)),
        const CornerRadius(
          tl: RadiusModel.circular(1),
          tr: RadiusModel.circular(2),
          br: RadiusModel.circular(3),
          bl: RadiusModel.circular(4),
        ),
        const CornerRadius.all(
          RadiusModel.elliptical(4, 8),
          type: RadiusType.elliptical,
        ),
      ]) {
        expect(CornerRadius.fromJson(radius.toJson()), radius);
      }
    });
  });
}
