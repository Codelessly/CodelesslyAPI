// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for CanvasNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CanvasNode serialization', () {
    test('basic canvas round-trip preserves all values', () {
      final original = CanvasNode(
        id: 'canvas-123',
        name: 'Main Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: ['child-1', 'child-2'],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      final json = original.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.type, equals('canvas'));
      expect(restored.children, equals(['child-1', 'child-2']));
      expect(restored.basicBoxLocal.width, equals(400));
      expect(restored.basicBoxLocal.height, equals(600));
    });

    test('canvas with scale mode serializes correctly', () {
      final node = CanvasNode(
        id: 'canvas-scale',
        name: 'Auto Scale Canvas',
        basicBoxLocal: NodeBox(0, 0, 375, 812),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
        scaleMode: ScaleMode.autoScale,
      );

      final json = node.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.scaleMode, equals(ScaleMode.autoScale));
    });

    test('scrollable canvas serializes correctly', () {
      final node = CanvasNode(
        id: 'canvas-scroll',
        name: 'Scrollable Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
        isScrollable: true,
        scrollDirection: AxisC.vertical,
        physics: ScrollPhysicsC.bouncingScrollPhysics,
      );

      final json = node.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.isScrollable, isTrue);
      expect(restored.scrollDirection, equals(AxisC.vertical));
      expect(restored.physics, equals(ScrollPhysicsC.bouncingScrollPhysics));
    });

    test('canvas with row column properties serializes correctly', () {
      final node = CanvasNode(
        id: 'canvas-flex',
        name: 'Flex Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: ['item-1', 'item-2', 'item-3'],
        properties: CanvasProperties(bodyId: 'body-1'),
        rowColumnType: RowColumnType.column,
        mainAxisAlignment: MainAxisAlignmentC.spaceBetween,
        crossAxisAlignment: CrossAxisAlignmentC.stretch,
      );

      final json = node.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.rowColumnType, equals(RowColumnType.column));
      expect(restored.mainAxisAlignment, equals(MainAxisAlignmentC.spaceBetween));
      expect(restored.crossAxisAlignment, equals(CrossAxisAlignmentC.stretch));
    });

    test('canvas with fills serializes correctly', () {
      final fill = PaintModel.solid(
        id: 'paint-1',
        visible: true,
        opacity: 1.0,
        color: ColorRGBA(r: 1, g: 0, b: 0, a: 1),
      );
      final node = CanvasNode(
        id: 'canvas-color',
        name: 'Colored Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
        fills: [fill],
      );

      final json = node.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.fills.isNotEmpty, isTrue);
      expect(restored.fills.first, isA<PaintModel>());
    });

    test('timestamp is serialized and deserialized correctly', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final node = CanvasNode(
        id: 'canvas-time',
        name: 'Timestamped Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
        createdTimestamp: timestamp,
      );

      final json = node.toJson();
      final restored = CanvasNode.fromJson(json);

      expect(restored.createdTimestamp.year, equals(2024));
      expect(restored.createdTimestamp.month, equals(1));
      expect(restored.createdTimestamp.day, equals(1));
    });

    test('default values are handled correctly', () {
      final node = CanvasNode(
        id: 'canvas-default',
        name: 'Default Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.scaleMode, equals(ScaleMode.autoScale));
      expect(node.rowColumnType, equals(RowColumnType.column));
      expect(node.mainAxisAlignment, equals(MainAxisAlignmentC.center));
      expect(node.crossAxisAlignment, equals(CrossAxisAlignmentC.center));
      expect(node.isScrollable, isFalse);
      expect(node.fills.isNotEmpty, isTrue); // Default white paint
    });
  });

  group('CanvasNode behavior', () {
    test('type is correct', () {
      final node = CanvasNode(
        id: 'canvas',
        name: 'Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.type, equals('canvas'));
    });

    test('supportsPadding is true', () {
      final node = CanvasNode(
        id: 'canvas',
        name: 'Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.supportsPadding, isTrue);
    });

    test('supportsMargin is false', () {
      final node = CanvasNode(
        id: 'canvas',
        name: 'Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.supportsMargin, isFalse);
    });

    test('supportsRotation is false', () {
      final node = CanvasNode(
        id: 'canvas',
        name: 'Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.supportsRotation, isFalse);
    });

    test('triggerTypes includes load', () {
      final node = CanvasNode(
        id: 'canvas',
        name: 'Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: CanvasProperties(bodyId: 'body-1'),
      );

      expect(node.triggerTypes, contains(TriggerType.load));
    });

    test('isAScaffold reflects properties', () {
      final properties = CanvasProperties(
        bodyId: 'body-1',
        navigationBarPlaceholderId: 'nav-bar-1',
      );
      final node = CanvasNode(
        id: 'canvas',
        name: 'Scaffold Canvas',
        basicBoxLocal: NodeBox(0, 0, 400, 600),
        children: [],
        properties: properties,
      );

      expect(node.isAScaffold, isTrue);
    });
  });

  group('ScaleMode', () {
    test('autoScale mode exists', () {
      expect(ScaleMode.values, contains(ScaleMode.autoScale));
    });
  });

  group('CanvasProperties', () {
    test('default properties are created correctly', () {
      final properties = CanvasProperties(bodyId: 'body-1');

      expect(properties.bodyId, equals('body-1'));
      expect(properties.isAScaffold, isFalse);
    });

    test('properties with navigation bar serialize correctly', () {
      final properties = CanvasProperties(
        bodyId: 'body-1',
        navigationBarPlaceholderId: 'nav-1',
      );

      final json = properties.toJson();
      final restored = CanvasProperties.fromJson(json);

      expect(restored.navigationBarPlaceholderId, equals('nav-1'));
      expect(restored.isAScaffold, isTrue);
    });
  });
}
