import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A typed `[]` segment traverses one real serialized list item, never a
/// guessed position or an unvalidated free-form dictionary key.
Object? resolveSerializedPath(Map json, String path) {
  Object? current = json;
  for (final part in path.split('.')) {
    if (part.endsWith('[]')) {
      final name = part.substring(0, part.length - 2);
      if (current is! Map || current[name] is! List) return null;
      final items = current[name] as List;
      if (items.isEmpty) return null;
      current = items.first;
    } else {
      if (current is! Map || !current.containsKey(part)) return null;
      current = current[part];
    }
  }
  return current;
}

void main() {
  test('every generated indexed path resolves on a real serialized node', () {
    final all =
        (jsonDecode(
              File('lib/src/schema/generated/dpp_descriptors.json')
                  .readAsStringSync(),
            ) as Map)['descriptors']
            as List;
    final indexed = {
      for (final entry in all.cast<Map>())
        if ((entry['fieldPath'] as String).contains('[]'))
          entry['fieldPath'] as String,
    };
    expect(indexed, isNotEmpty);
    expect(
      indexed.every(
        (path) => RegExp(r'^[A-Za-z]\w*\[\]\.[A-Za-z]\w*$').hasMatch(path),
      ),
      isTrue,
    );

    final image = PaintModel.image(
      id: 'image',
      downloadUrl: 'https://example.com/image.png',
      fit: Fit.cover,
      imageTransform: [
        [1, 0, 4],
        [0, 1, 5],
      ],
      alignment: AlignmentModel.center,
      scaleX: 2,
      scaleY: -2,
      cropData: CropData(x: 1, y: 2, width: 80, height: 70),
      imageRepeat: ImageRepeatEnum.repeatX,
      sourceWidth: 100,
      sourceHeight: 100,
    );
    final frame = FrameNode(
      id: 'frame',
      name: 'Frame',
      basicBoxLocal: NodeBox(0, 0, 100, 100),
      children: [],
      fills: [image],
      rotationDegrees: 35,
      edgePins: const EdgePinsModel(left: 1, top: 2, right: 3, bottom: 4),
    );
    final text = TextNode(
      id: 'text',
      name: 'Text',
      basicBoxLocal: NodeBox(0, 0, 100, 40),
      data: 'Hello',
      textMixedProps: [
        StartEndProp(
          start: 0,
          end: 4,
          fontSize: 23,
          fontName: const FontName(family: 'Inter', weight: null),
          letterSpacing: const LetterSpacing.pixels(2),
          lineHeight: const LineHeight.pixels(24),
          textDecoration: TextDecorationEnum.underline,
          link: 'https://example.com',
        ),
      ],
    );
    final frameJson = frame.toJson();
    final textJson = text.toJson();
    expect(resolveSerializedPath(frameJson, 'rotation'), 35);
    expect(resolveSerializedPath(frameJson, 'rotationDegrees'), isNull);
    for (final path in const [
      'edgePins.left',
      'edgePins.top',
      'edgePins.right',
      'edgePins.bottom',
    ]) {
      expect(resolveSerializedPath(frameJson, path), isNotNull, reason: path);
    }
    for (final path in indexed) {
      final json = path.startsWith('fills[]') ? frameJson : textJson;
      expect(resolveSerializedPath(json, path), isNotNull, reason: path);
    }
    expect(
      resolveSerializedPath(textJson, 'textMixedProps[].props.fontSize'),
      isNull,
    );
    expect(resolveSerializedPath(frameJson, 'fills.imageTransform'), isNull);
  });
}
