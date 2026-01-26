// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Common test utilities for CodelesslyAPI tests.
library;

import 'package:codelessly_api/codelessly_api.dart';

/// Creates a minimal ButtonNode for testing.
ButtonNode createTestButtonNode({
  String id = 'test-button',
  String name = 'Test Button',
  String label = 'Click',
  ButtonTypeEnum buttonType = ButtonTypeEnum.elevated,
  double width = 100,
  double height = 40,
}) {
  return ButtonNode(
    id: id,
    name: name,
    basicBoxLocal: NodeBox(0, 0, width, height),
    properties: ButtonProperties(
      label: label,
      buttonType: buttonType,
    ),
  );
}

/// Creates a minimal TextNode for testing.
TextNode createTestTextNode({
  String id = 'test-text',
  String name = 'Test Text',
  String characters = 'Hello',
  double width = 100,
  double height = 30,
}) {
  return TextNode(
    id: id,
    name: name,
    basicBoxLocal: NodeBox(0, 0, width, height),
    characters: characters,
  );
}

/// Creates a minimal RowColumnNode for testing.
RowColumnNode createTestRowNode({
  String id = 'test-row',
  String name = 'Test Row',
  List<String> children = const [],
  double width = 200,
  double height = 100,
}) {
  return RowColumnNode(
    id: id,
    name: name,
    basicBoxLocal: NodeBox(0, 0, width, height),
    rowColumnType: RowColumnType.row,
    children: children,
  );
}

/// Creates a minimal RowColumnNode (column) for testing.
RowColumnNode createTestColumnNode({
  String id = 'test-column',
  String name = 'Test Column',
  List<String> children = const [],
  double width = 100,
  double height = 200,
}) {
  return RowColumnNode(
    id: id,
    name: name,
    basicBoxLocal: NodeBox(0, 0, width, height),
    rowColumnType: RowColumnType.column,
    children: children,
  );
}

/// Creates a minimal RectangleNode for testing.
RectangleNode createTestRectangleNode({
  String id = 'test-rect',
  String name = 'Test Rectangle',
  double width = 100,
  double height = 100,
}) {
  return RectangleNode(
    id: id,
    name: name,
    basicBoxLocal: NodeBox(0, 0, width, height),
  );
}

/// Verifies that a node round-trips through JSON correctly.
///
/// Returns true if the round-trip preserves the id.
bool verifyNodeRoundTrip<T extends BaseNode>(
  T node,
  T Function(Map<String, dynamic>) fromJson,
) {
  final json = node.toJson();
  final restored = fromJson(json);
  return restored.id == node.id;
}

/// Test helper for verifying node type string is correct.
void verifyNodeType(BaseNode node, String expectedType) {
  if (node.type != expectedType) {
    throw Exception(
      'Node type mismatch: expected "$expectedType", got "${node.type}"',
    );
  }
}
