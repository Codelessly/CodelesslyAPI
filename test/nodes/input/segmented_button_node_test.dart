// Copyright (c) 2026, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for SegmentedButtonNode serialization and behavior.
///
/// These tests verify:
/// - Round-trip serialization (toJson -> fromJson)
/// - Default value handling
/// - Property validation
/// - Field access functionality
/// - Segment handling
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SegmentedButtonNode serialization', () {
    test('round-trip preserves all values', () {
      final original = SegmentedButtonNode(
        id: 'test-segmented-button-123',
        name: 'View Selector',
        basicBoxLocal: NodeBox(10, 20, 300, 40),
        properties: SegmentedButtonProperties(
          segments: const [
            ButtonSegment(value: 'day', label: 'Day'),
            ButtonSegment(value: 'week', label: 'Week'),
            ButtonSegment(value: 'month', label: 'Month'),
          ],
          selectedSegments: const ['day'],
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
          borderColor: const ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
          borderWidth: 1.5,
        ),
        horizontalFit: SizeFit.shrinkWrap,
        verticalFit: SizeFit.fixed,
      );

      final json = original.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.basicBoxLocal.width, equals(300));
      expect(restored.basicBoxLocal.height, equals(40));
      expect(restored.properties.segments.length, equals(3));
      expect(restored.properties.segments[0].value, equals('day'));
      expect(restored.properties.segments[0].label, equals('Day'));
      expect(restored.properties.selectedSegments, equals(['day']));
      expect(restored.properties.multiSelectionEnabled, isFalse);
      expect(restored.properties.emptySelectionAllowed, isFalse);
      expect(restored.properties.borderWidth, equals(1.5));
      expect(restored.horizontalFit, equals(SizeFit.shrinkWrap));
    });

    test('default values are handled correctly', () {
      final node = SegmentedButtonNode(
        id: 'default-segmented-button',
        name: 'Default Segmented Button',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(),
      );

      final json = node.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      // Verify defaults
      expect(restored.properties.segments.length, equals(3));
      expect(restored.properties.segments[0].value, equals('option1'));
      expect(restored.properties.segments[0].label, equals('Option 1'));
      expect(restored.properties.selectedSegments, isEmpty);
      expect(restored.properties.multiSelectionEnabled, isFalse);
      expect(restored.properties.emptySelectionAllowed, isFalse);
      expect(restored.properties.borderWidth, equals(1.0));
    });

    test('segments serialize correctly', () {
      final segment = const ButtonSegment(
        value: 'test',
        label: 'Test Label',
        icon: MultiSourceIconModel(size: 20),
        tooltip: 'Test tooltip',
        enabled: true,
      );

      final json = segment.toJson();
      final restored = ButtonSegment.fromJson(json);

      expect(restored.value, equals('test'));
      expect(restored.label, equals('Test Label'));
      expect(restored.icon?.size, equals(20));
      expect(restored.tooltip, equals('Test tooltip'));
      expect(restored.enabled, isTrue);
    });

    test('multi-selection mode serializes correctly', () {
      final node = SegmentedButtonNode(
        id: 'multi-select',
        name: 'Multi Select',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(
          multiSelectionEnabled: true,
          selectedSegments: const ['option1', 'option2'],
        ),
      );

      final json = node.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      expect(restored.properties.multiSelectionEnabled, isTrue);
      expect(restored.properties.selectedSegments.length, equals(2));
      expect(restored.properties.selectedSegments, contains('option1'));
      expect(restored.properties.selectedSegments, contains('option2'));
    });

    test('empty selection allowed serializes correctly', () {
      final node = SegmentedButtonNode(
        id: 'empty-allowed',
        name: 'Empty Allowed',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(
          emptySelectionAllowed: true,
          selectedSegments: const [],
        ),
      );

      final json = node.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      expect(restored.properties.emptySelectionAllowed, isTrue);
      expect(restored.properties.selectedSegments, isEmpty);
    });

    test('custom colors serialize correctly', () {
      final node = SegmentedButtonNode(
        id: 'colored',
        name: 'Colored',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(
          selectedColor: const ColorRGBA(r: 0.2, g: 0.4, b: 0.8, a: 1.0),
          unselectedColor: const ColorRGBA(r: 0.9, g: 0.9, b: 0.9, a: 1.0),
          borderColor: const ColorRGBA(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
        ),
      );

      final json = node.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      expect(restored.properties.selectedColor?.r, closeTo(0.2, 0.01));
      expect(restored.properties.unselectedColor?.r, closeTo(0.9, 0.01));
      expect(restored.properties.borderColor?.r, closeTo(0.5, 0.01));
    });
  });

  group('SegmentedButtonNode behavior', () {
    test('trigger types include changed', () {
      final node = SegmentedButtonNode(
        id: 'btn',
        name: 'Button',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.changed));
    });

    test('propertyVariables includes selected', () {
      final node = SegmentedButtonNode(
        id: 'btn',
        name: 'Button',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(
          selectedSegments: const ['option1'],
        ),
      );

      final selectedVariable = node.propertyVariables.firstWhere(
        (v) => v.name == 'selected',
      );

      expect(selectedVariable, isNotNull);
      expect(selectedVariable.value, equals(['option1']));
    });
  });

  group('SegmentedButtonProperties', () {
    test('copyWith creates a modified copy', () {
      final original = SegmentedButtonProperties(
        segments: const [
          ButtonSegment(value: 'a', label: 'A'),
        ],
        selectedSegments: const ['a'],
        multiSelectionEnabled: false,
      );

      final modified = original.copyWith(
        selectedSegments: const ['b'],
        multiSelectionEnabled: true,
      );

      // Original unchanged
      expect(original.selectedSegments, equals(['a']));
      expect(original.multiSelectionEnabled, isFalse);

      // Modified has new values
      expect(modified.selectedSegments, equals(['b']));
      expect(modified.multiSelectionEnabled, isTrue);
      expect(modified.segments.length, equals(1)); // Preserved
    });

    test('props returns all properties for equality comparison', () {
      final props1 = SegmentedButtonProperties(
        selectedSegments: const ['option1'],
        borderWidth: 1.0,
      );
      final props2 = SegmentedButtonProperties(
        selectedSegments: const ['option1'],
        borderWidth: 1.0,
      );
      final props3 = SegmentedButtonProperties(
        selectedSegments: const ['option2'],
        borderWidth: 1.0,
      );

      expect(props1.props.length, equals(props2.props.length));
      expect(props1.props[1], equals(props2.props[1])); // selectedSegments
      expect(props1.props[1], isNot(equals(props3.props[1])));
    });
  });

  group('ButtonSegment', () {
    test('copyWith creates a modified copy', () {
      const original = ButtonSegment(
        value: 'original',
        label: 'Original',
        enabled: true,
      );

      final modified = original.copyWith(
        label: 'Modified',
        enabled: false,
      );

      // Original unchanged
      expect(original.label, equals('Original'));
      expect(original.enabled, isTrue);

      // Modified has new values
      expect(modified.label, equals('Modified'));
      expect(modified.enabled, isFalse);
      expect(modified.value, equals('original')); // Preserved
    });

    test('default values work correctly', () {
      const segment = ButtonSegment(value: 'test');

      expect(segment.label, isEmpty);
      expect(segment.icon, isNull);
      expect(segment.tooltip, isNull);
      expect(segment.enabled, isTrue);
    });

    test('props returns all properties', () {
      const segment1 = ButtonSegment(value: 'a', label: 'A');
      const segment2 = ButtonSegment(value: 'a', label: 'A');
      const segment3 = ButtonSegment(value: 'b', label: 'B');

      expect(segment1.props, equals(segment2.props));
      expect(segment1.props, isNot(equals(segment3.props)));
    });
  });

  group('SegmentedButtonNode edge cases', () {
    test('handles empty segments list', () {
      final node = SegmentedButtonNode(
        id: 'empty',
        name: 'Empty',
        basicBoxLocal: NodeBox(0, 0, 300, 40),
        properties: SegmentedButtonProperties(segments: const []),
      );

      final json = node.toJson();
      final restored = SegmentedButtonNode.fromJson(json);

      expect(restored.properties.segments, isEmpty);
    });

    test('handles segment with icon only', () {
      const segment = ButtonSegment(
        value: 'icon-only',
        icon: MultiSourceIconModel(size: 24),
      );

      final json = segment.toJson();
      final restored = ButtonSegment.fromJson(json);

      expect(restored.value, equals('icon-only'));
      expect(restored.label, isEmpty);
      expect(restored.icon?.size, equals(24));
    });

    test('handles disabled segments', () {
      const segment = ButtonSegment(
        value: 'disabled',
        label: 'Disabled',
        enabled: false,
      );

      final json = segment.toJson();
      final restored = ButtonSegment.fromJson(json);

      expect(restored.enabled, isFalse);
    });
  });
}
