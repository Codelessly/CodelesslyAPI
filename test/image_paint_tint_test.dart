import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

// An image paint can be tinted: imageColor combined with the image by
// imageColorBlendMode (srcIn by default), like ColorFilter.mode.
void main() {
  PaintModel texture({ColorRGBA? tint, BlendModeC? mode}) => PaintModel.image(
    id: 'texture',
    downloadUrl: 'https://example.com/topo.png',
    fit: Fit.cover,
    sourceWidth: 10,
    sourceHeight: 10,
    imageColor: tint,
    imageColorBlendMode: mode ?? BlendModeC.srcIn,
  );

  test('an untinted image writes no tint fields', () {
    final Map json = texture().toJson();
    expect(json.containsKey('imageColor'), isFalse);
    expect(json.containsKey('imageColorBlendMode'), isFalse);
    expect(PaintModel.fromJson(json).imageColor, isNull);
    expect(PaintModel.fromJson(json).imageColorBlendMode, BlendModeC.srcIn);
  });

  test('a tint round-trips through JSON', () {
    final PaintModel tinted = texture(
      tint: ColorRGBA.red,
      mode: BlendModeC.modulate,
    );
    final PaintModel read = PaintModel.fromJson(tinted.toJson());
    expect(read.imageColor, ColorRGBA.red);
    expect(read.imageColorBlendMode, BlendModeC.modulate);
    expect(read, tinted);
  });

  test('the blend mode defaults to srcIn and a hex tint reads', () {
    final PaintModel read = PaintModel.fromJson({
      'id': 'texture',
      'type': 'image',
      'downloadUrl': 'https://example.com/topo.png',
      'fit': 'cover',
      'imageColor': '#FFFFFF',
    });
    expect(read.imageColor, ColorRGBA.white);
    expect(read.imageColorBlendMode, BlendModeC.srcIn);
  });

  test('copyWith, sanitize and equivalence keep the tint', () {
    final PaintModel tinted = texture(tint: ColorRGBA.red);
    expect(tinted.sanitize().imageColor, ColorRGBA.red);
    expect(tinted.copyWith(opacity: 0.5).imageColor, ColorRGBA.red);
    expect(tinted.copyWith(clearImageColor: true).imageColor, isNull);
    expect(tinted.isEquivalentTo(texture()), isFalse);
    expect(tinted.isEquivalentTo(texture(tint: ColorRGBA.red)), isTrue);
  });
}
