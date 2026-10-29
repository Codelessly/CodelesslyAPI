import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// Layout and widget nodes parse from JSON that leaves out the base node fields
/// (positioning mode, aspect ratio lock, reactions, fits, pins, ...), as
/// tools and older documents write it. Only what the type itself needs is
/// given: its properties, a text's characters, a container's children, a
/// row or column's direction.
const List<String> _types = [
  'frame',
  'text',
  'rectangle',
  'spacer',
  'row',
  'column',
  'autoPlaceholder',
  'freeformPlaceholder',
  'elevatedButton',
  'textButton',
  'outlinedButton',
  'iconButton',
  'filledButton',
  'textField',
  'checkbox',
  'switch',
  'radio',
  'accordion',
  'listTile',
  'divider',
  'progressBar',
  'badge',
  'chip',
  'segmentedButton',
  'floatingActionButton',
  'external',
];

void main() {
  for (final String type in _types) {
    test('$type parses without base node fields', () {
      final BaseNode? node = NodeJsonConverter().fromJson({
        'id': 'n',
        'name': type,
        'type': type,
        'basicBoxLocal': [0, 0, 10, 10],
        'properties': <String, dynamic>{
          if (type.endsWith('Button'))
            'buttonType': type == 'filledButton' ? 'filled' :
                type.substring(0, type.length - 'Button'.length),
        },
        'characters': '',
        'children': <String>[],
        if (type == 'row' || type == 'column') 'rowColumnType': type,
      });
      expect(node?.type, type);
      expect(node!.positioningMode, isNotNull);
      // And what it writes back parses the same way.
      expect(NodeJsonConverter().fromJson(node.toJson())?.type, type);
    });
  }
}
