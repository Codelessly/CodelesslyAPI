// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for TextNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNode serialization', () {
    test('round-trip preserves text content', () {
      final original = TextNode(
        id: 'text-123',
        name: 'Heading',
        basicBoxLocal: NodeBox(0, 0, 200, 50),
        characters: 'Hello, World!',
        textAlignHorizontal: TextAlignHorizontalEnum.center,
        textAlignVertical: TextAlignVerticalEnum.center,
      );

      final json = original.toJson();
      final restored = TextNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.characters, equals('Hello, World!'));
      expect(
        restored.textAlignHorizontal,
        equals(TextAlignHorizontalEnum.center),
      );
      expect(restored.textAlignVertical, equals(TextAlignVerticalEnum.center));
    });

    test('text mixed props serialize correctly', () {
      final original = TextNode(
        id: 'rich-text',
        name: 'Rich Text',
        basicBoxLocal: NodeBox(0, 0, 300, 100),
        characters: 'Bold and italic text',
        textMixedProps: [
          StartEndProp(
            start: 0,
            end: 4,
            fontSize: 16,
          ),
        ],
      );

      final json = original.toJson();
      final restored = TextNode.fromJson(json);

      expect(restored.textMixedProps.length, equals(1));
      expect(restored.textMixedProps.first.start, equals(0));
      expect(restored.textMixedProps.first.end, equals(4));
    });

    test('default values are handled correctly', () {
      final node = TextNode(
        id: 'default-text',
        name: 'Text',
        basicBoxLocal: NodeBox(0, 0, 100, 30),
        characters: '',
      );

      expect(node.characters, equals(''));
      expect(node.textAlignHorizontal, equals(TextAlignHorizontalEnum.left));
      expect(node.textAlignVertical, equals(TextAlignVerticalEnum.top));
    });

    test('max lines and overflow serialize correctly', () {
      final node = TextNode(
        id: 'truncated-text',
        name: 'Truncated',
        basicBoxLocal: NodeBox(0, 0, 200, 50),
        characters: 'This is a long text that should be truncated',
        maxLines: 2,
        overflow: TextOverflowC.ellipsis,
      );

      final json = node.toJson();
      final restored = TextNode.fromJson(json);

      expect(restored.maxLines, equals(2));
      expect(restored.overflow, equals(TextOverflowC.ellipsis));
    });
  });

  group('TextNode behavior', () {
    test('type is correct', () {
      final node = TextNode(
        id: 'text',
        name: 'Text',
        basicBoxLocal: NodeBox(0, 0, 100, 30),
        characters: 'Test',
      );

      expect(node.type, equals('text'));
    });

    test('supportsPadding is false', () {
      final node = TextNode(
        id: 'text',
        name: 'Text',
        basicBoxLocal: NodeBox(0, 0, 100, 30),
        characters: 'Test',
      );

      expect(node.supportsPadding, isFalse);
    });

    test('triggerTypes includes click', () {
      final node = TextNode(
        id: 'text',
        name: 'Text',
        basicBoxLocal: NodeBox(0, 0, 100, 30),
        characters: 'Test',
      );

      expect(node.triggerTypes, contains(TriggerType.click));
    });
  });

  group('Text alignment enums', () {
    test('horizontal alignment values', () {
      expect(TextAlignHorizontalEnum.values.length, greaterThanOrEqualTo(3));
      expect(
        TextAlignHorizontalEnum.values,
        containsAll([
          TextAlignHorizontalEnum.left,
          TextAlignHorizontalEnum.center,
          TextAlignHorizontalEnum.right,
        ]),
      );
    });

    test('vertical alignment values', () {
      expect(TextAlignVerticalEnum.values.length, greaterThanOrEqualTo(3));
      expect(
        TextAlignVerticalEnum.values,
        containsAll([
          TextAlignVerticalEnum.top,
          TextAlignVerticalEnum.center,
          TextAlignVerticalEnum.bottom,
        ]),
      );
    });
  });

  group('TextOverflowC', () {
    test('all overflow values exist', () {
      expect(
        TextOverflowC.values,
        containsAll([
          TextOverflowC.clip,
          TextOverflowC.ellipsis,
          TextOverflowC.fade,
          TextOverflowC.visible,
        ]),
      );
    });
  });
}
