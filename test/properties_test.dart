import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('empty constructors initialize every field', () {
    test('ListTileNode', () {
      expect(ListTileNode.empty().toJson(), containsPair('type', 'listTile'));
      expect(
        ListTileNode.fromProperties(ListTileProperties()).children,
        isEmpty,
      );
    });

    test('ExpansionTileNode', () {
      final node = ExpansionTileNode.empty();
      expect(node.id, 'expansion_tile');
      expect(node.children, isEmpty);
      expect(node.isExpanded, node.properties.initiallyExpanded);
      expect(node.toJson(), containsPair('type', 'expansionTile'));
    });

    test('FloatingActionButtonNode is sized like a regular FAB', () {
      final box = FloatingActionButtonNode.empty().basicBoxLocal;
      expect(box.width, FloatingActionButtonType.regular.size);
      expect(box.height, FloatingActionButtonType.regular.size);
    });
  });

  group('copyWith keeps every field', () {
    test('DividerProperties', () {
      final copy = DividerProperties(thickness: 3).copyWith(indent: 2);
      expect(copy.thickness, 3);
    });

    test('DropdownProperties', () {
      final copy = DropdownProperties(
        items: const ['a'],
        enabled: false,
        dense: true,
        expanded: true,
        autoFocus: true,
        enableFeedback: false,
      ).copyWith(hint: 'x');
      expect(copy.enabled, isFalse);
      expect(copy.dense, isTrue);
      expect(copy.expanded, isTrue);
      expect(copy.autoFocus, isTrue);
      expect(copy.enableFeedback, isFalse);
      expect(copy.hint, 'x');
    });

    test('FloatingActionButtonProperties', () {
      final copy = FloatingActionButtonProperties(
        location: FABLocation.centerDocked,
      ).copyWith(elevation: 2);
      expect(copy.location, FABLocation.centerDocked);
    });

    test('M2NavigationBarProperties', () {
      final copy = M2NavigationBarProperties(items: const [])
          .copyWith(makeNotched: true, notchMargin: 6);
      expect(copy.makeNotched, isTrue);
      expect(copy.notchMargin, 6);
    });
  });

  group('equality covers every serialized field', () {
    test('DividerProperties.thickness', () {
      expect(
        DividerProperties(thickness: 1),
        isNot(DividerProperties(thickness: 2)),
      );
    });

    test('ExpansionTileProperties', () {
      expect(
        ExpansionTileProperties(initiallyExpanded: true),
        isNot(ExpansionTileProperties(initiallyExpanded: false)),
      );
    });

    test('GridDelegateProperties spacing', () {
      expect(
        FixedCrossAxisCountGridDelegateProperties(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
        ),
        isNot(
          FixedCrossAxisCountGridDelegateProperties(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
          ),
        ),
      );
    });

    test('WebViewProperties base fields', () {
      expect(
        WebPageWebViewProperties(
          pageSourceType: WebViewWebpageSourceType.url,
          input: 'https://example.com',
          backgroundColor: ColorRGBA.white,
        ),
        isNot(
          WebPageWebViewProperties(
            pageSourceType: WebViewWebpageSourceType.url,
            input: 'https://example.com',
            backgroundColor: ColorRGBA.black,
          ),
        ),
      );
    });
  });
}
