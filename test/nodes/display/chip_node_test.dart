// Copyright (c) 2026, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for ChipNode serialization and behavior.
///
/// These tests verify:
/// - Round-trip serialization (toJson -> fromJson)
/// - Default value handling
/// - Property validation
/// - Field access functionality
/// - All chip type handling
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChipNode serialization', () {
    test('round-trip preserves all values', () {
      final original = ChipNode(
        id: 'test-chip-123',
        name: 'Action Chip',
        basicBoxLocal: NodeBox(10, 20, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.action,
          label: 'Save',
          backgroundColor: const ColorRGBA(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
          borderColor: const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 1.0),
          borderWidth: 1.5,
          cornerRadius: 16,
          elevation: 2,
          shadowColor: const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.3),
        ),
        horizontalFit: SizeFit.shrinkWrap,
        verticalFit: SizeFit.shrinkWrap,
      );

      final json = original.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.basicBoxLocal.width, equals(100));
      expect(restored.basicBoxLocal.height, equals(32));
      expect(restored.properties.chipType, equals(ChipType.action));
      expect(restored.properties.label, equals('Save'));
      expect(restored.properties.backgroundColor?.r, closeTo(0.2, 0.01));
      expect(restored.properties.borderColor?.r, closeTo(0.0, 0.01));
      expect(restored.properties.borderWidth, equals(1.5));
      expect(restored.properties.cornerRadius, equals(16));
      expect(restored.properties.elevation, equals(2));
      expect(restored.properties.shadowColor?.a, closeTo(0.3, 0.01));
      expect(restored.horizontalFit, equals(SizeFit.shrinkWrap));
    });

    test('default values are handled correctly', () {
      final node = ChipNode(
        id: 'default-chip',
        name: 'Default Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      // Verify defaults
      expect(restored.properties.chipType, equals(ChipType.action));
      expect(restored.properties.label, equals('Chip'));
      expect(restored.properties.selected, isFalse);
      expect(restored.properties.backgroundColor, isNull);
      expect(restored.properties.borderWidth, equals(1.0));
      expect(restored.properties.cornerRadius, equals(8.0));
      expect(restored.properties.elevation, equals(0));
      expect(restored.properties.autofocus, isFalse);
      expect(restored.properties.padding.horizontal, equals(24));
      expect(restored.properties.labelPadding.horizontal, equals(16));
    });

    test('basic chip type serializes correctly', () {
      final node = ChipNode(
        id: 'basic-chip',
        name: 'Basic Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.basic,
          label: 'Info',
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.chipType, equals(ChipType.basic));
      expect(restored.properties.label, equals('Info'));
    });

    test('action chip type serializes correctly', () {
      final node = ChipNode(
        id: 'action-chip',
        name: 'Action Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.action,
          label: 'Delete',
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.chipType, equals(ChipType.action));
      expect(restored.properties.label, equals('Delete'));
    });

    test('choice chip type serializes correctly', () {
      final node = ChipNode(
        id: 'choice-chip',
        name: 'Choice Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.choice,
          label: 'Option A',
          selected: true,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.chipType, equals(ChipType.choice));
      expect(restored.properties.label, equals('Option A'));
      expect(restored.properties.selected, isTrue);
    });

    test('filter chip type serializes correctly', () {
      final node = ChipNode(
        id: 'filter-chip',
        name: 'Filter Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.filter,
          label: 'Category',
          selected: false,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.chipType, equals(ChipType.filter));
      expect(restored.properties.label, equals('Category'));
      expect(restored.properties.selected, isFalse);
    });

    test('input chip type serializes correctly', () {
      final node = ChipNode(
        id: 'input-chip',
        name: 'Input Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.input,
          label: 'user@example.com',
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.chipType, equals(ChipType.input));
      expect(restored.properties.label, equals('user@example.com'));
    });

    test('icon serializes correctly', () {
      final node = ChipNode(
        id: 'chip-with-icon',
        name: 'Chip With Icon',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          icon: const MultiSourceIconModel(size: 20, show: true),
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.icon?.size, equals(20));
      expect(restored.properties.icon?.show, isTrue);
    });

    test('avatar serializes correctly', () {
      final node = ChipNode(
        id: 'chip-with-avatar',
        name: 'Chip With Avatar',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          avatar: 'https://example.com/avatar.png',
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.avatar, equals('https://example.com/avatar.png'));
    });

    test('deleteIcon serializes correctly', () {
      final node = ChipNode(
        id: 'chip-with-delete',
        name: 'Chip With Delete Icon',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.input,
          deleteIcon: const MultiSourceIconModel(size: 18, show: true),
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.deleteIcon?.size, equals(18));
      expect(restored.properties.deleteIcon?.show, isTrue);
    });

    test('colors serialize correctly', () {
      final node = ChipNode(
        id: 'colored-chip',
        name: 'Colored Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          backgroundColor: const ColorRGBA(r: 0.9, g: 0.9, b: 0.9, a: 1.0),
          selectedColor: const ColorRGBA(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
          borderColor: const ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
          shadowColor: const ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.2),
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.backgroundColor?.r, closeTo(0.9, 0.01));
      expect(restored.properties.selectedColor?.r, closeTo(0.2, 0.01));
      expect(restored.properties.borderColor?.r, closeTo(0.5, 0.01));
      expect(restored.properties.shadowColor?.a, closeTo(0.2, 0.01));
    });

    test('padding serializes correctly', () {
      final node = ChipNode(
        id: 'padded-chip',
        name: 'Padded Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          padding: const EdgeInsetsModel.all(16),
          labelPadding: const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 8),
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.padding.l, equals(16));
      expect(restored.properties.padding.t, equals(16));
      expect(restored.properties.padding.r, equals(16));
      expect(restored.properties.padding.b, equals(16));
      expect(restored.properties.labelPadding.horizontal, equals(24));
      expect(restored.properties.labelPadding.vertical, equals(16));
    });
  });

  group('ChipNode behavior', () {
    test('trigger types include click', () {
      final node = ChipNode(
        id: 'chip',
        name: 'Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.click));
    });

    test('type is correct', () {
      final node = ChipNode(
        id: 'chip',
        name: 'Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(),
      );

      expect(node.type, equals('chip'));
    });

    test('supportsPadding is true', () {
      final node = ChipNode(
        id: 'chip',
        name: 'Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(),
      );

      expect(node.supportsPadding, isTrue);
    });

    test('propertyVariables includes selected for choice chip', () {
      final node = ChipNode(
        id: 'choice-chip',
        name: 'Choice Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.choice,
          selected: true,
        ),
      );

      final selectedVariable = node.propertyVariables.firstWhere(
        (v) => v.name == 'selected',
        orElse: () => BoolValue(name: 'notfound', value: false),
      );

      expect(selectedVariable.name, equals('selected'));
      expect(selectedVariable.value, isTrue);
    });

    test('propertyVariables includes selected for filter chip', () {
      final node = ChipNode(
        id: 'filter-chip',
        name: 'Filter Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.filter,
          selected: false,
        ),
      );

      final selectedVariable = node.propertyVariables.firstWhere(
        (v) => v.name == 'selected',
        orElse: () => BoolValue(name: 'notfound', value: true),
      );

      expect(selectedVariable.name, equals('selected'));
      expect(selectedVariable.value, isFalse);
    });

    test('propertyVariables does not include selected for basic chip', () {
      final node = ChipNode(
        id: 'basic-chip',
        name: 'Basic Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          chipType: ChipType.basic,
        ),
      );

      final hasSelected = node.propertyVariables.any((v) => v.name == 'selected');
      expect(hasSelected, isFalse);
    });
  });

  group('ChipProperties', () {
    test('copyWith creates a modified copy', () {
      final original = ChipProperties(
        chipType: ChipType.action,
        label: 'Original',
        selected: false,
        borderWidth: 1.0,
      );

      final modified = original.copyWith(
        chipType: ChipType.choice,
        label: 'Modified',
        selected: true,
        borderWidth: 2.0,
      );

      // Original unchanged
      expect(original.chipType, equals(ChipType.action));
      expect(original.label, equals('Original'));
      expect(original.selected, isFalse);
      expect(original.borderWidth, equals(1.0));

      // Modified has new values
      expect(modified.chipType, equals(ChipType.choice));
      expect(modified.label, equals('Modified'));
      expect(modified.selected, isTrue);
      expect(modified.borderWidth, equals(2.0));
    });

    test('props returns all properties for equality comparison', () {
      final props1 = ChipProperties(
        chipType: ChipType.action,
        label: 'Test',
        selected: false,
      );
      final props2 = ChipProperties(
        chipType: ChipType.action,
        label: 'Test',
        selected: false,
      );
      final props3 = ChipProperties(
        chipType: ChipType.filter,
        label: 'Test',
        selected: false,
      );

      expect(props1.props.length, equals(props2.props.length));
      expect(props1.props[0], equals(props2.props[0])); // chipType
      expect(props1.props[0], isNot(equals(props3.props[0])));
    });
  });

  group('ChipType enum', () {
    test('prettify returns human-readable names', () {
      expect(ChipType.basic.prettify, equals('Chip'));
      expect(ChipType.action.prettify, equals('Action Chip'));
      expect(ChipType.choice.prettify, equals('Choice Chip'));
      expect(ChipType.filter.prettify, equals('Filter Chip'));
      expect(ChipType.input.prettify, equals('Input Chip'));
    });

    test('all chip types are covered', () {
      expect(ChipType.values.length, equals(5));
      expect(ChipType.values, contains(ChipType.basic));
      expect(ChipType.values, contains(ChipType.action));
      expect(ChipType.values, contains(ChipType.choice));
      expect(ChipType.values, contains(ChipType.filter));
      expect(ChipType.values, contains(ChipType.input));
    });

    test('supportsSelection returns correct values', () {
      expect(ChipType.basic.supportsSelection, isFalse);
      expect(ChipType.action.supportsSelection, isFalse);
      expect(ChipType.choice.supportsSelection, isTrue);
      expect(ChipType.filter.supportsSelection, isTrue);
      expect(ChipType.input.supportsSelection, isFalse);
    });

    test('supportsDeletion returns correct values', () {
      expect(ChipType.basic.supportsDeletion, isFalse);
      expect(ChipType.action.supportsDeletion, isFalse);
      expect(ChipType.choice.supportsDeletion, isFalse);
      expect(ChipType.filter.supportsDeletion, isFalse);
      expect(ChipType.input.supportsDeletion, isTrue);
    });

    test('supportsPress returns correct values', () {
      expect(ChipType.basic.supportsPress, isFalse);
      expect(ChipType.action.supportsPress, isTrue);
      expect(ChipType.choice.supportsPress, isTrue);
      expect(ChipType.filter.supportsPress, isTrue);
      expect(ChipType.input.supportsPress, isFalse);
    });
  });

  group('ChipNode edge cases', () {
    test('handles null colors', () {
      final node = ChipNode(
        id: 'no-colors',
        name: 'No Colors',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          backgroundColor: null,
          selectedColor: null,
          borderColor: null,
          shadowColor: null,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.backgroundColor, isNull);
      expect(restored.properties.selectedColor, isNull);
      expect(restored.properties.borderColor, isNull);
      expect(restored.properties.shadowColor, isNull);
    });

    test('handles null icon', () {
      final node = ChipNode(
        id: 'no-icon',
        name: 'No Icon',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          icon: null,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.icon, isNull);
    });

    test('handles null avatar', () {
      final node = ChipNode(
        id: 'no-avatar',
        name: 'No Avatar',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          avatar: null,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.avatar, isNull);
    });

    test('handles null deleteIcon', () {
      final node = ChipNode(
        id: 'no-delete',
        name: 'No Delete Icon',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          deleteIcon: null,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.deleteIcon, isNull);
    });

    test('handles empty label', () {
      final node = ChipNode(
        id: 'empty-label',
        name: 'Empty Label',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          label: '',
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.label, isEmpty);
    });

    test('handles zero elevation', () {
      final node = ChipNode(
        id: 'flat-chip',
        name: 'Flat Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          elevation: 0,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.elevation, equals(0));
    });

    test('handles large elevation', () {
      final node = ChipNode(
        id: 'elevated-chip',
        name: 'Elevated Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          elevation: 12,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.elevation, equals(12));
    });

    test('handles zero borderWidth', () {
      final node = ChipNode(
        id: 'no-border',
        name: 'No Border',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          borderWidth: 0,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.borderWidth, equals(0));
    });

    test('handles large cornerRadius', () {
      final node = ChipNode(
        id: 'round-chip',
        name: 'Round Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          cornerRadius: 50,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.cornerRadius, equals(50));
    });

    test('handles autofocus enabled', () {
      final node = ChipNode(
        id: 'autofocus-chip',
        name: 'Autofocus Chip',
        basicBoxLocal: NodeBox(0, 0, 100, 32),
        properties: ChipProperties(
          autofocus: true,
        ),
      );

      final json = node.toJson();
      final restored = ChipNode.fromJson(json);

      expect(restored.properties.autofocus, isTrue);
    });
  });
}
