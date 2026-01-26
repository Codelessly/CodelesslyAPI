// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for CheckboxNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckboxNode serialization', () {
    test('round-trip preserves all values', () {
      final original = CheckboxNode(
        id: 'checkbox-123',
        name: 'Accept Terms',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        value: true,
        properties: CheckboxProperties(
          activeColor: const ColorRGBA(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
          checkColor: const ColorRGBA(r: 1.0, g: 1.0, b: 1.0, a: 1.0),
          tristate: false,
        ),
      );

      final json = original.toJson();
      final restored = CheckboxNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals('Accept Terms'));
      expect(restored.value, isTrue);
      expect(restored.properties.tristate, isFalse);
    });

    test('null value (tristate) serializes correctly', () {
      final node = CheckboxNode(
        id: 'tristate-checkbox',
        name: 'Tristate',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        value: null,
        properties: CheckboxProperties(tristate: true),
      );

      final json = node.toJson();
      final restored = CheckboxNode.fromJson(json);

      expect(restored.value, isNull);
      expect(restored.properties.tristate, isTrue);
    });

    test('default values are handled correctly', () {
      final node = CheckboxNode(
        id: 'default-checkbox',
        name: 'Checkbox',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        properties: CheckboxProperties(),
      );

      // When tristate is false (default), value defaults to false, not null
      expect(node.value, isFalse);
      expect(node.properties.tristate, isFalse);
    });
  });

  group('CheckboxNode behavior', () {
    test('type is correct', () {
      final node = CheckboxNode(
        id: 'checkbox',
        name: 'Checkbox',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        properties: CheckboxProperties(),
      );

      expect(node.type, equals('checkbox'));
    });

    test('default size constants are correct', () {
      expect(kCheckboxDefaultSize, equals(40));
    });

    test('defaultWidth and defaultHeight match constant', () {
      final node = CheckboxNode(
        id: 'checkbox',
        name: 'Checkbox',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        properties: CheckboxProperties(),
      );

      expect(node.defaultWidth, equals(kCheckboxDefaultSize));
      expect(node.defaultHeight, equals(kCheckboxDefaultSize));
    });

    test('triggerTypes includes changed', () {
      final node = CheckboxNode(
        id: 'checkbox',
        name: 'Checkbox',
        basicBoxLocal: NodeBox(0, 0, 40, 40),
        properties: CheckboxProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.changed));
    });

    test('empty constructor creates valid node', () {
      final node = CheckboxNode.empty();

      expect(node.id, equals('checkBox'));
      expect(node.name, equals('Checkbox'));
      expect(node.basicBoxLocal.width, equals(kCheckboxDefaultSize));
      expect(node.basicBoxLocal.height, equals(kCheckboxDefaultSize));
    });
  });

  group('CheckboxProperties', () {
    test('copyWith creates a modified copy', () {
      final original = CheckboxProperties(
        tristate: false,
        activeColor: const ColorRGBA(r: 0.0, g: 0.0, b: 1.0, a: 1.0),
      );

      final modified = original.copyWith(
        tristate: true,
      );

      // Original unchanged
      expect(original.tristate, isFalse);

      // Modified has new values
      expect(modified.tristate, isTrue);
      expect(modified.activeColor, equals(original.activeColor)); // Preserved
    });
  });
}
