// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for SliderNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SliderNode serialization', () {
    test('round-trip preserves all values', () {
      final original = SliderNode(
        id: 'slider-123',
        name: 'Volume',
        basicBoxLocal: NodeBox(0, 0, 300, 48),
        value: 0.75,
        properties: SliderProperties(
          min: 0.0,
          max: 1.0,
          divisions: 10,
          activeTrackColor: const ColorRGBA(r: 0.2, g: 0.6, b: 1.0, a: 1.0),
        ),
      );

      final json = original.toJson();
      final restored = SliderNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals('Volume'));
      expect(restored.value, equals(0.75));
      expect(restored.properties.min, equals(0.0));
      expect(restored.properties.max, equals(1.0));
      expect(restored.properties.divisions, equals(10));
    });

    test('default values are handled correctly', () {
      final node = SliderNode(
        id: 'default-slider',
        name: 'Slider',
        basicBoxLocal: NodeBox(0, 0, 300, 48),
        value: 0.5,
        properties: SliderProperties(),
      );

      expect(node.value, equals(0.5));
      expect(node.properties.min, equals(0.0));
      expect(node.properties.max, equals(100.0)); // Default max is 100
    });

    test('custom range serializes correctly', () {
      final node = SliderNode(
        id: 'range-slider',
        name: 'Temperature',
        basicBoxLocal: NodeBox(0, 0, 300, 48),
        value: 72.0,
        properties: SliderProperties(
          min: 60.0,
          max: 90.0,
          divisions: 30,
        ),
      );

      final json = node.toJson();
      final restored = SliderNode.fromJson(json);

      expect(restored.value, equals(72.0));
      expect(restored.properties.min, equals(60.0));
      expect(restored.properties.max, equals(90.0));
      expect(restored.properties.divisions, equals(30));
    });
  });

  group('SliderNode behavior', () {
    test('type is correct', () {
      final node = SliderNode(
        id: 'slider',
        name: 'Slider',
        basicBoxLocal: NodeBox(0, 0, 300, 48),
        value: 0.5,
        properties: SliderProperties(),
      );

      expect(node.type, equals('slider'));
    });

    test('default size constants are correct', () {
      expect(kSliderDefaultWidth, equals(300));
      expect(kSliderDefaultHeight, equals(48));
      expect(kSliderDefaultTrackHeight, equals(4));
      expect(kSliderDefaultThumbRadius, equals(10));
    });

    test('triggerTypes includes changed', () {
      final node = SliderNode(
        id: 'slider',
        name: 'Slider',
        basicBoxLocal: NodeBox(0, 0, 300, 48),
        value: 0.5,
        properties: SliderProperties(),
      );

      expect(node.triggerTypes, contains(TriggerType.changed));
    });

    test('empty constructor creates valid node', () {
      final node = SliderNode.empty();

      expect(node.id, equals('slider'));
      expect(node.name, equals('Slider'));
      expect(node.value, equals(0));
      expect(node.basicBoxLocal.width, equals(kSliderDefaultWidth));
      expect(node.basicBoxLocal.height, equals(kSliderDefaultHeight));
    });
  });

  group('SliderProperties', () {
    test('copyWith creates a modified copy', () {
      final original = SliderProperties(
        min: 0.0,
        max: 100.0,
        divisions: 10,
      );

      final modified = original.copyWith(
        max: 200.0,
        divisions: 20,
      );

      // Original unchanged
      expect(original.max, equals(100.0));
      expect(original.divisions, equals(10));

      // Modified has new values
      expect(modified.max, equals(200.0));
      expect(modified.divisions, equals(20));
      expect(modified.min, equals(0.0)); // Preserved
    });
  });
}
