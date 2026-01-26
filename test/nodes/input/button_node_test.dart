// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for ButtonNode serialization and behavior.
///
/// These tests verify:
/// - Round-trip serialization (toJson -> fromJson)
/// - Default value handling
/// - Property validation
/// - Field access functionality
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonNode serialization', () {
    test('round-trip preserves all values', () {
      final original = ButtonNode(
        id: 'test-button-123',
        name: 'Primary Button',
        basicBoxLocal: NodeBox(10, 20, 150, 48),
        properties: ButtonProperties(
          label: 'Click Me',
          buttonType: ButtonTypeEnum.elevated,
          buttonColor: const ColorRGBA(r: 0.2, g: 0.4, b: 0.8, a: 1.0),
          elevation: 4.0,
          enabled: true,
          labelAlignment: TextAlignHorizontalEnum.center,
          placement: IconPlacementEnum.start,
          gap: 12.0,
        ),
        horizontalFit: SizeFit.shrinkWrap,
        verticalFit: SizeFit.fixed,
      );

      final json = original.toJson();
      final restored = ButtonNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.basicBoxLocal.width, equals(150));
      expect(restored.basicBoxLocal.height, equals(48));
      expect(restored.properties.label, equals('Click Me'));
      expect(restored.properties.buttonType, equals(ButtonTypeEnum.elevated));
      expect(restored.properties.buttonColor.r, closeTo(0.2, 0.001));
      expect(restored.properties.elevation, equals(4.0));
      expect(restored.properties.enabled, isTrue);
      expect(restored.horizontalFit, equals(SizeFit.shrinkWrap));
    });

    test('default values are handled correctly', () {
      final node = ButtonNode(
        id: 'default-button',
        name: 'Default Button',
        basicBoxLocal: NodeBox(0, 0, 100, 40),
        properties: ButtonProperties(),
      );

      final json = node.toJson();
      final restored = ButtonNode.fromJson(json);

      // Verify defaults
      expect(restored.properties.buttonType, equals(ButtonTypeEnum.elevated));
      expect(restored.properties.enabled, isTrue);
      expect(restored.properties.label, equals(''));
      expect(restored.properties.gap, equals(8.0));
      expect(restored.properties.placement, equals(IconPlacementEnum.start));
      expect(
        restored.properties.labelAlignment,
        equals(TextAlignHorizontalEnum.center),
      );
    });

    test('all button types serialize correctly', () {
      for (final buttonType in ButtonTypeEnum.values) {
        final node = ButtonNode(
          id: 'button-${buttonType.name}',
          name: buttonType.prettify,
          basicBoxLocal: NodeBox(0, 0, 100, 40),
          properties: ButtonProperties(buttonType: buttonType),
        );

        final json = node.toJson();
        final restored = ButtonNode.fromJson(json);

        expect(
          restored.properties.buttonType,
          equals(buttonType),
          reason: 'Failed for buttonType: ${buttonType.name}',
        );
      }
    });

    test('icon properties serialize correctly', () {
      final node = ButtonNode(
        id: 'icon-button',
        name: 'Icon Button',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: ButtonProperties(
          buttonType: ButtonTypeEnum.icon,
          icon: const MultiSourceIconModel(
            size: 24,
            color: ColorRGBA(r: 1, g: 1, b: 1, a: 1),
          ),
        ),
      );

      final json = node.toJson();
      final restored = ButtonNode.fromJson(json);

      expect(restored.properties.icon.size, equals(24));
      expect(restored.properties.icon.color?.r, equals(1.0));
    });
  });

  group('ButtonNode behavior', () {
    test('behavesLikeAnIconButton returns true for icon type', () {
      final node = ButtonNode(
        id: 'icon-btn',
        name: 'Icon',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: ButtonProperties(buttonType: ButtonTypeEnum.icon),
      );

      expect(node.behavesLikeAnIconButton, isTrue);
    });

    test('behavesLikeAnIconButton returns true for circle with empty label',
        () {
      final node = ButtonNode(
        id: 'circle-btn',
        name: 'Circle',
        basicBoxLocal: NodeBox(0, 0, 48, 48),
        properties: ButtonProperties(
          buttonType: ButtonTypeEnum.elevated,
          shape: CShapeBorder.circle,
          label: '',
        ),
      );

      expect(node.behavesLikeAnIconButton, isTrue);
    });

    test('behavesLikeAnIconButton returns false for labeled button', () {
      final node = ButtonNode(
        id: 'labeled-btn',
        name: 'Labeled',
        basicBoxLocal: NodeBox(0, 0, 150, 48),
        properties: ButtonProperties(
          buttonType: ButtonTypeEnum.elevated,
          label: 'Click Me',
        ),
      );

      expect(node.behavesLikeAnIconButton, isFalse);
    });

    test('trigger types include click and longPress', () {
      final node = ButtonNode(
        id: 'btn',
        name: 'Button',
        basicBoxLocal: NodeBox(0, 0, 100, 40),
        properties: ButtonProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.click));
      expect(node.triggerTypes, contains(TriggerType.longPress));
    });
  });

  group('ButtonProperties', () {
    test('copyWith creates a modified copy', () {
      final original = ButtonProperties(
        label: 'Original',
        buttonType: ButtonTypeEnum.elevated,
        enabled: true,
      );

      final modified = original.copyWith(
        label: 'Modified',
        buttonType: ButtonTypeEnum.outlined,
      );

      // Original unchanged
      expect(original.label, equals('Original'));
      expect(original.buttonType, equals(ButtonTypeEnum.elevated));

      // Modified has new values
      expect(modified.label, equals('Modified'));
      expect(modified.buttonType, equals(ButtonTypeEnum.outlined));
      expect(modified.enabled, isTrue); // Preserved
    });

    test('props returns all properties for equality comparison', () {
      final props1 = ButtonProperties(label: 'Test', elevation: 4.0);
      final props2 = ButtonProperties(label: 'Test', elevation: 4.0);
      final props3 = ButtonProperties(label: 'Different', elevation: 4.0);

      expect(props1.props, equals(props2.props));
      expect(props1.props, isNot(equals(props3.props)));
    });
  });

  group('ButtonTypeEnum', () {
    test('isIconButton returns correct value', () {
      expect(ButtonTypeEnum.icon.isIconButton, isTrue);
      expect(ButtonTypeEnum.elevated.isIconButton, isFalse);
      expect(ButtonTypeEnum.text.isIconButton, isFalse);
      expect(ButtonTypeEnum.outlined.isIconButton, isFalse);
      expect(ButtonTypeEnum.filled.isIconButton, isFalse);
      expect(ButtonTypeEnum.filledTonal.isIconButton, isFalse);
    });

    test('isFilledButton returns correct value', () {
      expect(ButtonTypeEnum.filled.isFilledButton, isTrue);
      expect(ButtonTypeEnum.filledTonal.isFilledButton, isFalse);
      expect(ButtonTypeEnum.elevated.isFilledButton, isFalse);
      expect(ButtonTypeEnum.text.isFilledButton, isFalse);
    });

    test('isFilledTonalButton returns correct value', () {
      expect(ButtonTypeEnum.filledTonal.isFilledTonalButton, isTrue);
      expect(ButtonTypeEnum.filled.isFilledTonalButton, isFalse);
      expect(ButtonTypeEnum.elevated.isFilledTonalButton, isFalse);
      expect(ButtonTypeEnum.text.isFilledTonalButton, isFalse);
    });

    test('isFilledVariant returns correct value', () {
      expect(ButtonTypeEnum.filled.isFilledVariant, isTrue);
      expect(ButtonTypeEnum.filledTonal.isFilledVariant, isTrue);
      expect(ButtonTypeEnum.elevated.isFilledVariant, isFalse);
      expect(ButtonTypeEnum.text.isFilledVariant, isFalse);
      expect(ButtonTypeEnum.outlined.isFilledVariant, isFalse);
      expect(ButtonTypeEnum.icon.isFilledVariant, isFalse);
    });

    test('prettify returns human-readable names', () {
      expect(ButtonTypeEnum.elevated.prettify, equals('Elevated Button'));
      expect(ButtonTypeEnum.text.prettify, equals('Text Button'));
      expect(ButtonTypeEnum.outlined.prettify, equals('Outlined Button'));
      expect(ButtonTypeEnum.icon.prettify, equals('Icon Button'));
      expect(ButtonTypeEnum.filled.prettify, equals('Filled Button'));
      expect(ButtonTypeEnum.filledTonal.prettify, equals('Filled Tonal Button'));
    });

    test('all button types are covered', () {
      expect(
        ButtonTypeEnum.values,
        containsAll([
          ButtonTypeEnum.elevated,
          ButtonTypeEnum.text,
          ButtonTypeEnum.outlined,
          ButtonTypeEnum.icon,
          ButtonTypeEnum.filled,
          ButtonTypeEnum.filledTonal,
        ]),
      );
      expect(ButtonTypeEnum.values.length, equals(6));
    });
  });

  group('FilledButton serialization', () {
    test('filled button type serializes correctly', () {
      final node = ButtonNode(
        id: 'filled-button',
        name: 'Filled Button',
        basicBoxLocal: NodeBox(0, 0, 150, 48),
        properties: ButtonProperties(
          label: 'Primary Action',
          buttonType: ButtonTypeEnum.filled,
        ),
      );

      final json = node.toJson();
      final restored = ButtonNode.fromJson(json);

      expect(restored.properties.buttonType, equals(ButtonTypeEnum.filled));
      expect(restored.properties.label, equals('Primary Action'));
    });

    test('filled tonal button type serializes correctly', () {
      final node = ButtonNode(
        id: 'filled-tonal-button',
        name: 'Filled Tonal Button',
        basicBoxLocal: NodeBox(0, 0, 150, 48),
        properties: ButtonProperties(
          label: 'Secondary Action',
          buttonType: ButtonTypeEnum.filledTonal,
        ),
      );

      final json = node.toJson();
      final restored = ButtonNode.fromJson(json);

      expect(restored.properties.buttonType, equals(ButtonTypeEnum.filledTonal));
      expect(restored.properties.label, equals('Secondary Action'));
    });
  });
}
