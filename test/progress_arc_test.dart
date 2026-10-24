import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('arc gauge properties survive JSON', () {
    final props = ProgressBarProperties(
      shape: ProgressBarShape.arc,
      arcStrokeWidth: 14,
      needleColor: ColorRGBA.black,
      tickCount: 10,
      bands: const [
        ProgressBand(
          start: 0,
          end: 0.9,
          color: ColorRGBA(r: 0, g: 1, b: 0, a: 1),
        ),
        ProgressBand(
          start: 0.9,
          end: 1,
          color: ColorRGBA(r: 1, g: 0, b: 0, a: 1),
        ),
      ],
    );
    final decoded = ProgressBarProperties.fromJson(props.toJson());
    expect(decoded, props);
    expect(decoded.bands.last.start, 0.9);
    expect(decoded.copyWith(clearNeedle: true).needleColor, isNull);
  });

  test('a plain bar keeps its old JSON', () {
    final json = ProgressBarProperties().toJson();
    expect(json.containsKey('shape'), isFalse);
    expect(json.containsKey('bands'), isFalse);
    expect(
      ProgressBarProperties.fromJson(const {}).shape,
      ProgressBarShape.bar,
    );
  });
}
