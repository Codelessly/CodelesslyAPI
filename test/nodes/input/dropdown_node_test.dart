// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for DropdownNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropdownNode serialization', () {
    test('round-trip preserves all values', () {
      final original = DropdownNode(
        id: 'dropdown-123',
        name: 'Country Selector',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        value: 'USA',
        properties: DropdownProperties(
          items: ['USA', 'Canada', 'Mexico'],
          enabled: true,
          dense: false,
          expanded: true,
        ),
      );

      final json = original.toJson();
      final restored = DropdownNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals('Country Selector'));
      expect(restored.value, equals('USA'));
      expect(restored.properties.items, equals(['USA', 'Canada', 'Mexico']));
      expect(restored.properties.expanded, isTrue);
    });

    test('null value serializes correctly', () {
      final node = DropdownNode(
        id: 'empty-dropdown',
        name: 'Select Option',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        value: null,
        properties: DropdownProperties(
          items: ['Option 1', 'Option 2'],
        ),
      );

      final json = node.toJson();
      final restored = DropdownNode.fromJson(json);

      expect(restored.value, isNull);
    });

    test('default values are handled correctly', () {
      final node = DropdownNode(
        id: 'default-dropdown',
        name: 'Dropdown',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        properties: DropdownProperties(items: []),
      );

      expect(node.value, isNull);
      expect(node.properties.enabled, isTrue);
      expect(node.properties.dense, isFalse);
      expect(node.properties.expanded, isFalse);
      expect(node.properties.items, isEmpty);
    });

    test('items list serializes correctly', () {
      final node = DropdownNode(
        id: 'items-dropdown',
        name: 'Size',
        basicBoxLocal: NodeBox(0, 0, 150, 48),
        properties: DropdownProperties(
          items: ['Small', 'Medium', 'Large', 'Extra Large'],
        ),
      );

      final json = node.toJson();
      final restored = DropdownNode.fromJson(json);

      expect(restored.properties.items.length, equals(4));
      expect(restored.properties.items, contains('Medium'));
      expect(restored.properties.items, contains('Extra Large'));
    });
  });

  group('DropdownNode behavior', () {
    test('type is correct', () {
      final node = DropdownNode(
        id: 'dropdown',
        name: 'Dropdown',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        properties: DropdownProperties(items: []),
      );

      expect(node.type, equals('dropdown'));
    });

    test('supportsPadding is true', () {
      final node = DropdownNode(
        id: 'dropdown',
        name: 'Dropdown',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        properties: DropdownProperties(items: []),
      );

      expect(node.supportsPadding, isTrue);
    });

    test('triggerTypes includes click and changed', () {
      final node = DropdownNode(
        id: 'dropdown',
        name: 'Dropdown',
        basicBoxLocal: NodeBox(0, 0, 200, 48),
        properties: DropdownProperties(items: []),
      );

      expect(node.triggerTypes, contains(TriggerType.click));
      expect(node.triggerTypes, contains(TriggerType.changed));
    });
  });

  group('DropdownProperties', () {
    test('copyWith creates a modified copy', () {
      final original = DropdownProperties(
        items: ['A', 'B', 'C'],
        hint: 'Select one',
        iconSize: 24,
      );

      final modified = original.copyWith(
        items: ['X', 'Y', 'Z'],
        hint: 'Choose option',
      );

      // Original unchanged
      expect(original.items, equals(['A', 'B', 'C']));
      expect(original.hint, equals('Select one'));

      // Modified has new values
      expect(modified.items, equals(['X', 'Y', 'Z']));
      expect(modified.hint, equals('Choose option'));
      expect(modified.iconSize, equals(24)); // Preserved
    });

    test('items property is accessible', () {
      final props1 = DropdownProperties(items: ['A', 'B']);
      final props2 = DropdownProperties(items: ['X', 'Y']);

      // Items are stored correctly
      expect(props1.items, equals(['A', 'B']));
      expect(props2.items, equals(['X', 'Y']));
      expect(props1.items, isNot(equals(props2.items)));
    });
  });
}
