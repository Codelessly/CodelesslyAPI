import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// What a page document pays per node, and that none of it is a default:
/// a key whose removal reads back as the same node is a value `toJson`
/// should have left out (see `tool/json_defaults_builder`). Typical nodes of
/// a built screen, as the editor stores them.
void main() {
  test('stored node JSON is small and carries no default values', () {
    final box = NodeBox(16, 120, 358, 48);
    final nodes = <BaseNode>[
      RowColumnNode(
        id: 'ZPcdmSV2nPmmNYlEbP5a',
        name: 'Rig card',
        basicBoxLocal: box,
        children: ['a1b2c3d4e5f6g7h8i9j0'],
        rowColumnType: RowColumnType.row,
        mainAxisAlignment: MainAxisAlignmentC.start,
        padding: const EdgeInsetsModel.all(16),
        horizontalFit: SizeFit.expanded,
        verticalFit: SizeFit.shrinkWrap,
        fills: [PaintModel.solid(color: ColorRGB(r: 1, g: 1, b: 1), id: 'p1')],
        strokes: [
          PaintModel.solid(color: ColorRGB(r: 0.9, g: 0.9, b: 0.9), id: 'p4'),
        ],
        strokeWeight: 1,
        cornerRadius: CornerRadius.all(RadiusModel.circular(12)),
        reactions: [
          Reaction(
            trigger: TriggerModel(type: TriggerType.click),
            action: NavigationAction(destinationId: 'abcdefghij0123456789'),
          ),
        ],
      ),
      TextNode(
        id: 'a1b2c3d4e5f6g7h8i9j0',
        name: 'Title',
        basicBoxLocal: box,
        characters: r'Unit ${vehicle.unit}',
        horizontalFit: SizeFit.shrinkWrap,
        verticalFit: SizeFit.shrinkWrap,
        textMixedProps: [
          StartEndProp(
            start: 0,
            end: 20,
            fontSize: 16,
            lineHeight: LineHeight.auto,
            letterSpacing: LetterSpacing.zero,
            fontName: FontName(
              family: 'Inter',
              style: 'Bold',
              weight: FontWeightNumeric.w700,
            ),
            fills: [
              PaintModel.solid(
                color: ColorRGB(r: 0.1, g: 0.1, b: 0.1),
                id: 'p2',
              ),
            ],
          ),
        ],
      ),
      RectangleNode(
        id: 'b1b2c3d4e5f6g7h8i9j0',
        name: 'Divider',
        basicBoxLocal: box,
        fills: [
          PaintModel.solid(color: ColorRGB(r: 0.9, g: 0.9, b: 0.9), id: 'p3'),
        ],
      ),
    ];
    const maxBytes = {'rowColumn': 600, 'text': 380, 'rectangle': 160};
    for (final node in nodes) {
      final json =
          jsonDecode(jsonEncode(node.toJson())) as Map<String, dynamic>;
      final int bytes = utf8.encode(jsonEncode(json)).length;
      print('${node.type}: $bytes bytes ${jsonEncode(json)}');
      expect(bytes, lessThanOrEqualTo(maxBytes[node.type]!), reason: node.type);
      // Reads back the same.
      expect(
        jsonEncode(NodeJsonConverter.instance.fromJson(json)!.toJson()),
        jsonEncode(json),
      );
      for (final key in json.keys) {
        if (key == 'type' || key == 'id') continue;
        final without = Map<String, dynamic>.from(json)..remove(key);
        Object? back;
        try {
          back = jsonEncode(
            NodeJsonConverter.instance.fromJson(without)!.toJson(),
          );
        } catch (_) {
          continue; // A required key.
        }
        expect(back, isNot(jsonEncode(json)), reason: '${node.type}.$key');
      }
    }
  });
}
