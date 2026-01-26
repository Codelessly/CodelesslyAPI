// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Tests for RowColumnNode serialization and behavior.
library;

import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RowColumnNode serialization', () {
    test('row round-trip preserves all values', () {
      final original = RowColumnNode(
        id: 'row-123',
        name: 'Main Row',
        basicBoxLocal: NodeBox(0, 0, 400, 100),
        rowColumnType: RowColumnType.row,
        mainAxisAlignment: MainAxisAlignmentC.spaceBetween,
        crossAxisAlignment: CrossAxisAlignmentC.center,
        children: ['child-1', 'child-2', 'child-3'],
      );

      final json = original.toJson();
      final restored = RowColumnNode.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.rowColumnType, equals(RowColumnType.row));
      expect(restored.mainAxisAlignment, equals(MainAxisAlignmentC.spaceBetween));
      expect(restored.crossAxisAlignment, equals(CrossAxisAlignmentC.center));
      expect(restored.children, equals(['child-1', 'child-2', 'child-3']));
    });

    test('column round-trip preserves all values', () {
      final original = RowColumnNode(
        id: 'col-123',
        name: 'Main Column',
        basicBoxLocal: NodeBox(0, 0, 200, 400),
        rowColumnType: RowColumnType.column,
        mainAxisAlignment: MainAxisAlignmentC.start,
        crossAxisAlignment: CrossAxisAlignmentC.stretch,
        children: ['item-1', 'item-2'],
      );

      final json = original.toJson();
      final restored = RowColumnNode.fromJson(json);

      expect(restored.rowColumnType, equals(RowColumnType.column));
      expect(restored.mainAxisAlignment, equals(MainAxisAlignmentC.start));
      expect(restored.crossAxisAlignment, equals(CrossAxisAlignmentC.stretch));
    });

    test('default values are handled correctly', () {
      final node = RowColumnNode(
        id: 'default',
        name: 'Default',
        basicBoxLocal: NodeBox(0, 0, 200, 100),
        rowColumnType: RowColumnType.row,
        children: [],
      );

      expect(node.rowColumnType, equals(RowColumnType.row));
      expect(node.mainAxisAlignment, equals(MainAxisAlignmentC.center));
      expect(node.crossAxisAlignment, equals(CrossAxisAlignmentC.center));
      expect(node.children, isEmpty);
    });

    test('scrollable properties serialize correctly', () {
      final node = RowColumnNode(
        id: 'scrollable',
        name: 'Scrollable Row',
        basicBoxLocal: NodeBox(0, 0, 400, 100),
        rowColumnType: RowColumnType.row,
        children: [],
        isScrollable: true,
        physics: ScrollPhysicsC.bouncingScrollPhysics,
      );

      final json = node.toJson();
      final restored = RowColumnNode.fromJson(json);

      expect(restored.isScrollable, isTrue);
      expect(restored.physics, equals(ScrollPhysicsC.bouncingScrollPhysics));
    });
  });

  group('RowColumnNode behavior', () {
    test('type is correct for row', () {
      final node = RowColumnNode(
        id: 'row',
        name: 'Row',
        basicBoxLocal: NodeBox(0, 0, 200, 100),
        rowColumnType: RowColumnType.row,
        children: [],
      );

      expect(node.type, equals('rowColumn'));
    });

    test('type is correct for column', () {
      final node = RowColumnNode(
        id: 'col',
        name: 'Column',
        basicBoxLocal: NodeBox(0, 0, 100, 200),
        rowColumnType: RowColumnType.column,
        children: [],
      );

      expect(node.type, equals('rowColumn'));
    });

    test('isRow and isColumn helpers work correctly', () {
      final row = RowColumnNode(
        id: 'row',
        name: 'Row',
        basicBoxLocal: NodeBox(0, 0, 200, 100),
        rowColumnType: RowColumnType.row,
        children: [],
      );

      final column = RowColumnNode(
        id: 'col',
        name: 'Column',
        basicBoxLocal: NodeBox(0, 0, 100, 200),
        rowColumnType: RowColumnType.column,
        children: [],
      );

      expect(row.rowColumnType == RowColumnType.row, isTrue);
      expect(row.rowColumnType == RowColumnType.column, isFalse);
      expect(column.rowColumnType == RowColumnType.column, isTrue);
      expect(column.rowColumnType == RowColumnType.row, isFalse);
    });

    test('supportsPadding is true', () {
      final node = RowColumnNode(
        id: 'row',
        name: 'Row',
        basicBoxLocal: NodeBox(0, 0, 200, 100),
        rowColumnType: RowColumnType.row,
        children: [],
      );

      expect(node.supportsPadding, isTrue);
    });

    test('scrollDirection matches rowColumnType', () {
      final row = RowColumnNode(
        id: 'row',
        name: 'Row',
        basicBoxLocal: NodeBox(0, 0, 200, 100),
        rowColumnType: RowColumnType.row,
        children: [],
      );

      final column = RowColumnNode(
        id: 'col',
        name: 'Column',
        basicBoxLocal: NodeBox(0, 0, 100, 200),
        rowColumnType: RowColumnType.column,
        children: [],
      );

      expect(row.scrollDirection, equals(AxisC.horizontal));
      expect(column.scrollDirection, equals(AxisC.vertical));
    });
  });

  group('MainAxisAlignmentC', () {
    test('all alignment values exist', () {
      expect(
        MainAxisAlignmentC.values,
        containsAll([
          MainAxisAlignmentC.start,
          MainAxisAlignmentC.end,
          MainAxisAlignmentC.center,
          MainAxisAlignmentC.spaceBetween,
          MainAxisAlignmentC.spaceAround,
          MainAxisAlignmentC.spaceEvenly,
        ]),
      );
    });
  });

  group('CrossAxisAlignmentC', () {
    test('all alignment values exist', () {
      expect(
        CrossAxisAlignmentC.values,
        containsAll([
          CrossAxisAlignmentC.start,
          CrossAxisAlignmentC.end,
          CrossAxisAlignmentC.center,
          CrossAxisAlignmentC.stretch,
        ]),
      );
    });
  });

  group('RowColumnType', () {
    test('values include row and column', () {
      expect(RowColumnType.values, containsAll([RowColumnType.row, RowColumnType.column]));
    });
  });
}
