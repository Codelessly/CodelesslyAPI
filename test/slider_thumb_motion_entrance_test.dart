import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('Slider thumb shape', () {
    test('defaults to a circle and omits the rectangle settings', () {
      final SliderProperties properties = SliderProperties();
      expect(properties.thumbShape, SliderThumbShapeEnum.circle);
      expect(properties.thumbWidth, kSliderDefaultThumbSize);
      expect(properties.thumbHeight, kSliderDefaultThumbSize);
      expect(properties.thumbCornerRadius, kSliderDefaultThumbCornerRadius);
      final Map<String, dynamic> json = properties.toJson();
      for (final String key in [
        'thumbShape',
        'thumbWidth',
        'thumbHeight',
        'thumbCornerRadius',
      ]) {
        expect(json.containsKey(key), isFalse, reason: key);
      }
    });

    test('a rounded rectangle thumb round-trips', () {
      final SliderProperties properties = SliderProperties.fromJson({
        'thumbShape': 'roundedRect',
        'thumbWidth': 44,
        'thumbHeight': 14,
        'thumbCornerRadius': 2,
      });
      expect(properties.thumbShape, SliderThumbShapeEnum.roundedRect);
      expect(properties.toJson(), {
        'thumbShape': 'roundedRect',
        'thumbWidth': 44.0,
        'thumbHeight': 14.0,
        'thumbCornerRadius': 2.0,
      });
      expect(SliderProperties.fromJson(properties.toJson()), properties);
      expect(
        properties.copyWith(thumbShape: SliderThumbShapeEnum.circle).thumbWidth,
        44,
      );
    });

    test('padding 0 is kept; no padding stays null', () {
      expect(SliderProperties.fromJson({}).padding, isNull);
      final SliderProperties zero = SliderProperties.fromJson({'padding': 0});
      expect(zero.padding, EdgeInsetsModel.zero);
      expect(zero.toJson(), {'padding': 0});
    });
  });

  group('Motion entrance', () {
    test('enterFrom implies an entrance that starts from its values', () {
      const MotionModel motion = MotionModel(
        opacity: 0.8,
        durationMs: 300,
        enterFrom: MotionModel(scale: 1.15, opacity: 0),
      );
      expect(motion.hasEntrance, isTrue);
      expect(MotionModel.none.hasEntrance, isFalse);
      expect(const MotionModel(enter: true).hasEntrance, isTrue);
      final MotionModel start = motion.entranceStart;
      expect(start.scale, 1.15);
      expect(start.opacity, 0);
      expect(start.durationMs, 300);
      expect(const MotionModel(scale: 2).entranceStart.scale, 1);
    });

    test('enterFrom and replayKey round-trip and clear', () {
      const MotionModel motion = MotionModel(
        enterFrom: MotionModel(translateY: 12),
        replayKey: 'side-a',
      );
      expect(motion.toJson(), {
        'enterFrom': {'translateY': 12.0},
        'replayKey': 'side-a',
      });
      expect(MotionModel.fromJson(motion.toJson()), motion);
      expect(
        motion.copyWith(clearEnterFrom: true, clearReplayKey: true),
        MotionModel.none,
      );
      expect(
        MotionModel.variableKey(MotionModel.replayKeyProperty),
        'motion.replayKey',
      );
    });
  });

  test('variable syntax matches keep a formula with object literals whole', () {
    const String formula =
        r'${= map(records, r => r.id == x ? merge(r, {plays: r.plays + 1}) : r)}';
    expect(
      [
        for (final m in variableSyntaxIdentifierRegex.allMatches(
          'a $formula b \${c.d} \${= {k: {v: 1}}.k.v}',
        ))
          m[0],
      ],
      [formula, r'${c.d}', r'${= {k: {v: 1}}.k.v}'],
    );
    // Renaming a variable leaves formulas as they are and renames paths.
    expect(
      'x $formula \${records}'.replaceVariableName('records', 'crate'),
      'x $formula \${crate}',
    );
  });
}
