// Copyright (c) 2026, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for BadgeNode serialization and behavior.
///
/// These tests verify:
/// - Round-trip serialization (toJson -> fromJson)
/// - Default value handling
/// - Property validation
/// - Field access functionality
/// - Badge type handling
/// - Alignment and offset handling
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BadgeNode serialization', () {
    test('round-trip preserves all values', () {
      final original = BadgeNode(
        id: 'test-badge-123',
        name: 'Notification Badge',
        basicBoxLocal: NodeBox(10, 20, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.count,
          label: '5',
          backgroundColor: const ColorRGBA(r: 1.0, g: 0.0, b: 0.0, a: 1.0),
          alignment: BadgeAlignment.topRight,
          offsetX: 10,
          offsetY: -5,
          isLabelVisible: true,
          dotSize: 8,
          padding: const EdgeInsetsModel.symmetric(horizontal: 6, vertical: 3),
        ),
        childID: 'child-icon-node',
        horizontalFit: SizeFit.shrinkWrap,
        verticalFit: SizeFit.shrinkWrap,
      );

      final json = original.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.basicBoxLocal.width, equals(48));
      expect(restored.basicBoxLocal.height, equals(48));
      expect(restored.properties.badgeType, equals(BadgeType.count));
      expect(restored.properties.label, equals('5'));
      expect(restored.properties.backgroundColor?.r, equals(1.0));
      expect(restored.properties.backgroundColor?.g, equals(0.0));
      expect(restored.properties.backgroundColor?.b, equals(0.0));
      expect(restored.properties.alignment, equals(BadgeAlignment.topRight));
      expect(restored.properties.offsetX, equals(10));
      expect(restored.properties.offsetY, equals(-5));
      expect(restored.properties.isLabelVisible, isTrue);
      expect(restored.properties.dotSize, equals(8));
      expect(restored.properties.padding.horizontal, equals(12));
      expect(restored.childID, equals('child-icon-node'));
      expect(restored.horizontalFit, equals(SizeFit.shrinkWrap));
    });

    test('default values are handled correctly', () {
      final node = BadgeNode(
        id: 'default-badge',
        name: 'Default Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      // Verify defaults
      expect(restored.properties.badgeType, equals(BadgeType.count));
      expect(restored.properties.label, isEmpty);
      expect(restored.properties.backgroundColor, isNull);
      expect(restored.properties.alignment, equals(BadgeAlignment.topRight));
      expect(restored.properties.offsetX, equals(0));
      expect(restored.properties.offsetY, equals(0));
      expect(restored.properties.isLabelVisible, isTrue);
      expect(restored.properties.dotSize, equals(6));
      expect(restored.properties.padding.horizontal, equals(8));
      expect(restored.properties.padding.vertical, equals(0));
    });

    test('dot badge type serializes correctly', () {
      final node = BadgeNode(
        id: 'dot-badge',
        name: 'Dot Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.dot,
          dotSize: 10,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.badgeType, equals(BadgeType.dot));
      expect(restored.properties.dotSize, equals(10));
    });

    test('label badge type serializes correctly', () {
      final node = BadgeNode(
        id: 'label-badge',
        name: 'Label Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.label,
          label: 'NEW',
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.badgeType, equals(BadgeType.label));
      expect(restored.properties.label, equals('NEW'));
    });

    test('count badge type serializes correctly', () {
      final node = BadgeNode(
        id: 'count-badge',
        name: 'Count Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.count,
          label: '99+',
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.badgeType, equals(BadgeType.count));
      expect(restored.properties.label, equals('99+'));
    });

    test('topRight alignment serializes correctly', () {
      final node = BadgeNode(
        id: 'topright',
        name: 'Top Right',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(alignment: BadgeAlignment.topRight),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.alignment, equals(BadgeAlignment.topRight));
    });

    test('topLeft alignment serializes correctly', () {
      final node = BadgeNode(
        id: 'topleft',
        name: 'Top Left',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(alignment: BadgeAlignment.topLeft),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.alignment, equals(BadgeAlignment.topLeft));
    });

    test('bottomRight alignment serializes correctly', () {
      final node = BadgeNode(
        id: 'bottomright',
        name: 'Bottom Right',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(alignment: BadgeAlignment.bottomRight),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.alignment, equals(BadgeAlignment.bottomRight));
    });

    test('bottomLeft alignment serializes correctly', () {
      final node = BadgeNode(
        id: 'bottomleft',
        name: 'Bottom Left',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(alignment: BadgeAlignment.bottomLeft),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.alignment, equals(BadgeAlignment.bottomLeft));
    });

    test('offsets serialize correctly', () {
      final node = BadgeNode(
        id: 'offset-badge',
        name: 'Offset Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          offsetX: 15.5,
          offsetY: -20.3,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.offsetX, closeTo(15.5, 0.01));
      expect(restored.properties.offsetY, closeTo(-20.3, 0.01));
    });

    test('custom colors serialize correctly', () {
      final node = BadgeNode(
        id: 'colored',
        name: 'Colored',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          backgroundColor: const ColorRGBA(r: 0.2, g: 0.8, b: 0.4, a: 1.0),
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.backgroundColor?.r, closeTo(0.2, 0.01));
      expect(restored.properties.backgroundColor?.g, closeTo(0.8, 0.01));
      expect(restored.properties.backgroundColor?.b, closeTo(0.4, 0.01));
      expect(restored.properties.backgroundColor?.a, closeTo(1.0, 0.01));
    });

    test('childID serializes correctly', () {
      final node = BadgeNode(
        id: 'badge-with-child',
        name: 'Badge With Child',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
        childID: 'icon-123',
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.childID, equals('icon-123'));
    });

    test('null childID serializes correctly', () {
      final node = BadgeNode(
        id: 'badge-no-child',
        name: 'Badge No Child',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
        childID: null,
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.childID, isNull);
    });
  });

  group('BadgeNode behavior', () {
    test('trigger types include click', () {
      final node = BadgeNode(
        id: 'badge',
        name: 'Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.click));
    });

    test('type is correct', () {
      final node = BadgeNode(
        id: 'badge',
        name: 'Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
      );

      expect(node.type, equals('badge'));
    });

    test('supportsPadding is true', () {
      final node = BadgeNode(
        id: 'badge',
        name: 'Badge',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(),
      );

      expect(node.supportsPadding, isTrue);
    });
  });

  group('BadgeProperties', () {
    test('copyWith creates a modified copy', () {
      final original = BadgeProperties(
        badgeType: BadgeType.count,
        label: '5',
        alignment: BadgeAlignment.topRight,
        offsetX: 0,
        offsetY: 0,
      );

      final modified = original.copyWith(
        badgeType: BadgeType.dot,
        label: 'NEW',
        alignment: BadgeAlignment.bottomLeft,
        offsetX: 10,
        offsetY: -5,
      );

      // Original unchanged
      expect(original.badgeType, equals(BadgeType.count));
      expect(original.label, equals('5'));
      expect(original.alignment, equals(BadgeAlignment.topRight));
      expect(original.offsetX, equals(0));
      expect(original.offsetY, equals(0));

      // Modified has new values
      expect(modified.badgeType, equals(BadgeType.dot));
      expect(modified.label, equals('NEW'));
      expect(modified.alignment, equals(BadgeAlignment.bottomLeft));
      expect(modified.offsetX, equals(10));
      expect(modified.offsetY, equals(-5));
    });

    test('props returns all properties for equality comparison', () {
      final props1 = BadgeProperties(
        badgeType: BadgeType.count,
        label: '5',
        offsetX: 10,
      );
      final props2 = BadgeProperties(
        badgeType: BadgeType.count,
        label: '5',
        offsetX: 10,
      );
      final props3 = BadgeProperties(
        badgeType: BadgeType.dot,
        label: '5',
        offsetX: 10,
      );

      expect(props1.props.length, equals(props2.props.length));
      expect(props1.props[0], equals(props2.props[0])); // badgeType
      expect(props1.props[0], isNot(equals(props3.props[0])));
    });
  });

  group('BadgeType enum', () {
    test('prettify returns human-readable names', () {
      expect(BadgeType.dot.prettify, equals('Dot Badge'));
      expect(BadgeType.label.prettify, equals('Label Badge'));
      expect(BadgeType.count.prettify, equals('Count Badge'));
    });

    test('all badge types are covered', () {
      expect(BadgeType.values.length, equals(3));
      expect(BadgeType.values, contains(BadgeType.dot));
      expect(BadgeType.values, contains(BadgeType.label));
      expect(BadgeType.values, contains(BadgeType.count));
    });
  });

  group('BadgeAlignment enum', () {
    test('prettify returns human-readable names', () {
      expect(BadgeAlignment.topRight.prettify, equals('Top Right'));
      expect(BadgeAlignment.topLeft.prettify, equals('Top Left'));
      expect(BadgeAlignment.bottomRight.prettify, equals('Bottom Right'));
      expect(BadgeAlignment.bottomLeft.prettify, equals('Bottom Left'));
    });

    test('all alignments are covered', () {
      expect(BadgeAlignment.values.length, equals(4));
      expect(BadgeAlignment.values, contains(BadgeAlignment.topRight));
      expect(BadgeAlignment.values, contains(BadgeAlignment.topLeft));
      expect(BadgeAlignment.values, contains(BadgeAlignment.bottomRight));
      expect(BadgeAlignment.values, contains(BadgeAlignment.bottomLeft));
    });
  });

  group('BadgeNode edge cases', () {
    test('handles zero offsets', () {
      final node = BadgeNode(
        id: 'zero-offset',
        name: 'Zero Offset',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          offsetX: 0,
          offsetY: 0,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.offsetX, equals(0));
      expect(restored.properties.offsetY, equals(0));
    });

    test('handles negative offsets', () {
      final node = BadgeNode(
        id: 'negative-offset',
        name: 'Negative Offset',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          offsetX: -10,
          offsetY: -15,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.offsetX, equals(-10));
      expect(restored.properties.offsetY, equals(-15));
    });

    test('handles large offsets', () {
      final node = BadgeNode(
        id: 'large-offset',
        name: 'Large Offset',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          offsetX: 100,
          offsetY: 200,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.offsetX, equals(100));
      expect(restored.properties.offsetY, equals(200));
    });

    test('handles hidden badge', () {
      final node = BadgeNode(
        id: 'hidden',
        name: 'Hidden',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          isLabelVisible: false,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.isLabelVisible, isFalse);
    });

    test('handles null background color', () {
      final node = BadgeNode(
        id: 'no-bg',
        name: 'No Background',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          backgroundColor: null,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.backgroundColor, isNull);
    });

    test('handles empty label', () {
      final node = BadgeNode(
        id: 'empty-label',
        name: 'Empty Label',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.label,
          label: '',
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.label, isEmpty);
    });

    test('handles very small dot size', () {
      final node = BadgeNode(
        id: 'tiny-dot',
        name: 'Tiny Dot',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.dot,
          dotSize: 2,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.dotSize, equals(2));
    });

    test('handles large dot size', () {
      final node = BadgeNode(
        id: 'large-dot',
        name: 'Large Dot',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          badgeType: BadgeType.dot,
          dotSize: 20,
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.dotSize, equals(20));
    });

    test('handles custom padding', () {
      final node = BadgeNode(
        id: 'custom-padding',
        name: 'Custom Padding',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: BadgeProperties(
          padding: const EdgeInsetsModel.all(8),
        ),
      );

      final json = node.toJson();
      final restored = BadgeNode.fromJson(json);

      expect(restored.properties.padding.l, equals(8));
      expect(restored.properties.padding.t, equals(8));
      expect(restored.properties.padding.r, equals(8));
      expect(restored.properties.padding.b, equals(8));
    });
  });
}
