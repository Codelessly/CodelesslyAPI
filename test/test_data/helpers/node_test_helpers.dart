// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Comprehensive test helpers for CodelesslyAPI node testing.
library;

import 'dart:convert';
import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base class for node test helpers providing common testing utilities.
class NodeTestHelper {
  /// Verifies that a node round-trips through JSON correctly.
  ///
  /// This performs a complete serialization cycle:
  /// 1. Serialize node to JSON
  /// 2. Deserialize JSON back to node
  /// 3. Serialize again to JSON
  /// 4. Compare both JSON representations
  static void verifyRoundTrip<T extends BaseNode>(
    T node,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // First serialization
    final json1 = node.toJson();

    // Deserialize
    final restoredNode = fromJson(json1);

    // Second serialization
    final json2 = restoredNode.toJson();

    // Compare JSON strings (order-independent)
    expect(
      jsonEncode(json1),
      equals(jsonEncode(json2)),
      reason: 'JSON round-trip should preserve all properties',
    );

    // Verify critical properties
    expect(restoredNode.id, equals(node.id));
    expect(restoredNode.name, equals(node.name));
    expect(restoredNode.type, equals(node.type));
  }

  /// Verifies that required fields throw errors when missing.
  static void verifyRequiredFields<T extends BaseNode>(
    Map<String, dynamic> baseJson,
    List<String> requiredFields,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    for (final field in requiredFields) {
      final jsonWithoutField = Map<String, dynamic>.from(baseJson);
      jsonWithoutField.remove(field);

      expect(
        () => fromJson(jsonWithoutField),
        throwsA(anything),
        reason: 'Missing required field "$field" should throw',
      );
    }
  }

  /// Verifies that optional fields have correct defaults.
  static void verifyOptionalDefaults<T extends BaseNode>(
    Map<String, dynamic> baseJson,
    Map<String, dynamic> expectedDefaults,
    T Function(Map<String, dynamic>) fromJson,
    dynamic Function(T, String) getProperty,
  ) {
    final node = fromJson(baseJson);

    for (final entry in expectedDefaults.entries) {
      final actualValue = getProperty(node, entry.key);
      expect(
        actualValue,
        equals(entry.value),
        reason: 'Field "${entry.key}" should have default value "${entry.value}"',
      );
    }
  }

  /// Verifies node type string.
  static void verifyNodeType(BaseNode node, String expectedType) {
    expect(
      node.type,
      equals(expectedType),
      reason: 'Node type should be "$expectedType"',
    );
  }

  /// Verifies that null values are handled correctly.
  static void verifyNullSafety<T extends BaseNode>(
    Map<String, dynamic> baseJson,
    List<String> nullableFields,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    for (final field in nullableFields) {
      final jsonWithNull = Map<String, dynamic>.from(baseJson);
      jsonWithNull[field] = null;

      // Should not throw
      expect(
        () => fromJson(jsonWithNull),
        returnsNormally,
        reason: 'Field "$field" should accept null',
      );
    }
  }

  /// Loads and parses a JSON test file.
  static Map<String, dynamic> loadJsonTestFile(String filePath) {
    // This would load from file system in actual tests
    // For now, this is a placeholder that can be implemented
    throw UnimplementedError('File loading to be implemented');
  }

  /// Creates a minimal valid JSON for a node type.
  static Map<String, dynamic> createMinimalJson({
    required String type,
    String? id,
    String? name,
  }) {
    return {
      'id': id ?? 'test-${type}-${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test $type',
      'type': type,
      'basicBoxLocal': {
        'x': 0.0,
        'y': 0.0,
        'width': 100.0,
        'height': 100.0,
      },
      'visible': true,
      'children': [],
    };
  }

  /// Verifies visual properties are preserved.
  static void verifyVisualProperties(BaseNode node) {
    expect(node.basicBoxLocal, isNotNull, reason: 'basicBoxLocal should not be null');
    expect(node.visible, isA<bool>(), reason: 'visible should be a bool');
  }

  /// Verifies that two nodes are deeply equal.
  static void verifyNodesEqual<T extends BaseNode>(T node1, T node2) {
    final json1 = node1.toJson();
    final json2 = node2.toJson();

    expect(
      jsonEncode(json1),
      equals(jsonEncode(json2)),
      reason: 'Nodes should be deeply equal',
    );
  }
}

/// Helper for creating test node instances.
class NodeBuilder {
  /// Creates a test ButtonNode with configurable properties.
  static ButtonNode button({
    String? id,
    String? name,
    String label = 'Button',
    ButtonTypeEnum buttonType = ButtonTypeEnum.elevated,
    double width = 100,
    double height = 40,
    bool visible = true,
  }) {
    return ButtonNode(
      id: id ?? 'button-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Button',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      properties: ButtonProperties(
        label: label,
        buttonType: buttonType,
      ),
    );
  }

  /// Creates a test TextNode with configurable properties.
  static TextNode text({
    String? id,
    String? name,
    String characters = 'Text',
    double width = 100,
    double height = 30,
    bool visible = true,
  }) {
    return TextNode(
      id: id ?? 'text-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Text',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      characters: characters,
    );
  }

  /// Creates a test RectangleNode with configurable properties.
  static RectangleNode rectangle({
    String? id,
    String? name,
    double width = 100,
    double height = 100,
    bool visible = true,
  }) {
    return RectangleNode(
      id: id ?? 'rect-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Rectangle',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
    );
  }

  /// Creates a test CanvasNode with configurable properties.
  static CanvasNode canvas({
    String? id,
    String? name,
    List<String> children = const [],
    double width = 400,
    double height = 600,
    bool visible = true,
  }) {
    return CanvasNode(
      id: id ?? 'canvas-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Canvas',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      children: children,
    );
  }

  /// Creates a test FrameNode with configurable properties.
  static FrameNode frame({
    String? id,
    String? name,
    List<String> children = const [],
    double width = 300,
    double height = 400,
    bool visible = true,
  }) {
    return FrameNode(
      id: id ?? 'frame-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Frame',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      children: children,
    );
  }

  /// Creates a test RowColumnNode (row) with configurable properties.
  static RowColumnNode row({
    String? id,
    String? name,
    List<String> children = const [],
    double width = 200,
    double height = 100,
    bool visible = true,
  }) {
    return RowColumnNode(
      id: id ?? 'row-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Row',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      rowColumnType: RowColumnType.row,
      children: children,
    );
  }

  /// Creates a test RowColumnNode (column) with configurable properties.
  static RowColumnNode column({
    String? id,
    String? name,
    List<String> children = const [],
    double width = 100,
    double height = 200,
    bool visible = true,
  }) {
    return RowColumnNode(
      id: id ?? 'column-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Column',
      basicBoxLocal: NodeBox(0, 0, width, height),
      visible: visible,
      rowColumnType: RowColumnType.column,
      children: children,
    );
  }

  /// Creates a test IconNode with configurable properties.
  static IconNode icon({
    String? id,
    String? name,
    IconModel? iconModel,
    double size = 24,
    bool visible = true,
  }) {
    return IconNode(
      id: id ?? 'icon-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Icon',
      basicBoxLocal: NodeBox(0, 0, size, size),
      visible: visible,
      icon: iconModel ?? defaultIcon,
    );
  }

  /// Creates a test CheckboxNode with configurable properties.
  static CheckboxNode checkbox({
    String? id,
    String? name,
    bool value = false,
    double size = 24,
    bool visible = true,
  }) {
    return CheckboxNode(
      id: id ?? 'checkbox-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Checkbox',
      basicBoxLocal: NodeBox(0, 0, size, size),
      visible: visible,
      value: value,
      properties: CheckboxProperties(),
    );
  }
}

/// Custom matchers for node testing.
class NodeMatchers {
  /// Matcher for verifying a node has a specific type.
  static Matcher hasNodeType(String type) {
    return predicate<BaseNode>(
      (node) => node.type == type,
      'has node type "$type"',
    );
  }

  /// Matcher for verifying a node is visible.
  static final Matcher isVisible = predicate<BaseNode>(
    (node) => node.visible,
    'is visible',
  );

  /// Matcher for verifying a node has children.
  static final Matcher hasChildren = predicate<BaseNode>(
    (node) {
      if (node is CanvasNode) return node.children.isNotEmpty;
      if (node is FrameNode) return node.children.isNotEmpty;
      if (node is RowColumnNode) return node.children.isNotEmpty;
      return false;
    },
    'has children',
  );

  /// Matcher for verifying a node has a specific number of children.
  static Matcher hasChildCount(int count) {
    return predicate<BaseNode>(
      (node) {
        if (node is CanvasNode) return node.children.length == count;
        if (node is FrameNode) return node.children.length == count;
        if (node is RowColumnNode) return node.children.length == count;
        return false;
      },
      'has $count children',
    );
  }

  /// Matcher for verifying node dimensions.
  static Matcher hasDimensions(double width, double height) {
    return predicate<BaseNode>(
      (node) =>
          node.basicBoxLocal.width == width &&
          node.basicBoxLocal.height == height,
      'has dimensions $width x $height',
    );
  }

  /// Matcher for verifying node ID.
  static Matcher hasId(String id) {
    return predicate<BaseNode>(
      (node) => node.id == id,
      'has id "$id"',
    );
  }
}

/// Test data generators for various scenarios.
class TestDataGenerator {
  /// Generates a variety of button configurations for testing.
  static List<Map<String, dynamic>> generateButtonVariants() {
    return [
      // Elevated button
      {
        'id': 'button-elevated',
        'name': 'Elevated Button',
        'type': 'button',
        'basicBoxLocal': {'x': 0.0, 'y': 0.0, 'width': 120.0, 'height': 48.0},
        'visible': true,
        'properties': {
          'label': 'Elevated',
          'buttonType': 'elevated',
        },
      },
      // Outlined button
      {
        'id': 'button-outlined',
        'name': 'Outlined Button',
        'type': 'button',
        'basicBoxLocal': {'x': 0.0, 'y': 0.0, 'width': 120.0, 'height': 48.0},
        'visible': true,
        'properties': {
          'label': 'Outlined',
          'buttonType': 'outlined',
        },
      },
      // Text button
      {
        'id': 'button-text',
        'name': 'Text Button',
        'type': 'button',
        'basicBoxLocal': {'x': 0.0, 'y': 0.0, 'width': 100.0, 'height': 40.0},
        'visible': true,
        'properties': {
          'label': 'Text',
          'buttonType': 'text',
        },
      },
    ];
  }

  /// Generates edge case test data.
  static Map<String, dynamic> generateEdgeCase(String caseType) {
    switch (caseType) {
      case 'empty_dimensions':
        return NodeTestHelper.createMinimalJson(type: 'rectangle')
          ..['basicBoxLocal'] = {'x': 0.0, 'y': 0.0, 'width': 0.0, 'height': 0.0};

      case 'large_dimensions':
        return NodeTestHelper.createMinimalJson(type: 'rectangle')
          ..['basicBoxLocal'] = {
            'x': 0.0,
            'y': 0.0,
            'width': 10000.0,
            'height': 10000.0
          };

      case 'negative_position':
        return NodeTestHelper.createMinimalJson(type: 'rectangle')
          ..['basicBoxLocal'] = {
            'x': -100.0,
            'y': -100.0,
            'width': 100.0,
            'height': 100.0
          };

      default:
        return NodeTestHelper.createMinimalJson(type: 'rectangle');
    }
  }
}
