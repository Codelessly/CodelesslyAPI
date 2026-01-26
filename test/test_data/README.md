# CodelesslyAPI Test Data

This directory contains test data and helpers for testing the CodelesslyAPI package.

## Directory Structure

```
test_data/
├── json/                    # JSON test files for node serialization
│   ├── layout/             # Layout node JSON files
│   ├── display/            # Display node JSON files
│   ├── input/              # Input/interactive node JSON files
│   ├── navigation/         # Navigation node JSON files
│   ├── advanced/           # Advanced feature node JSON files
│   ├── placeholder/        # Placeholder node JSON files
│   ├── component/          # Component node JSON files
│   └── edge_cases/         # Edge case scenarios
└── helpers/                # Test helper utilities
    └── node_test_helpers.dart
```

## JSON Test Files

### Naming Convention

JSON files follow this naming pattern:
```
{node_type}_{number}_{description}.json
```

Examples:
- `button_01_elevated.json` - Elevated button configuration
- `checkbox_02_checked.json` - Checked checkbox state
- `text_01_basic.json` - Basic text node

### File Organization

Files are organized by node category:

- **layout/** - Canvas, Frame, RowColumn, GridView, ListView, PageView, Scene
- **display/** - Text, Icon, Rectangle, Badge, Divider, Spacer, LoadingIndicator, ProgressBar
- **input/** - Button, TextField, Checkbox, Radio, Switch, Slider, Dropdown, etc.
- **navigation/** - AppBar, NavigationBar, TabBar, ListTile
- **advanced/** - WebView, EmbeddedVideo, Accordion, ExpansionTile
- **placeholder/** - Placeholder variations
- **component/** - ExternalComponent references
- **edge_cases/** - Unusual configurations, extreme values, null handling

## Test Helpers

### NodeTestHelper

Provides utilities for node testing:

```dart
// Round-trip JSON serialization test
NodeTestHelper.verifyRoundTrip(node, NodeType.fromJson);

// Required field validation
NodeTestHelper.verifyRequiredFields(
  baseJson,
  ['id', 'name', 'type'],
  NodeType.fromJson,
);

// Null safety testing
NodeTestHelper.verifyNullSafety(
  baseJson,
  ['optional_field_1', 'optional_field_2'],
  NodeType.fromJson,
);
```

### NodeBuilder

Factory methods for creating test nodes:

```dart
// Create test nodes quickly
final button = NodeBuilder.button(label: 'Click Me');
final text = NodeBuilder.text(characters: 'Hello');
final row = NodeBuilder.row(children: ['child1', 'child2']);
final canvas = NodeBuilder.canvas(width: 400, height: 600);
```

### NodeMatchers

Custom matchers for test assertions:

```dart
// Use custom matchers in tests
expect(node, NodeMatchers.hasNodeType('button'));
expect(node, NodeMatchers.isVisible);
expect(node, NodeMatchers.hasChildCount(3));
expect(node, NodeMatchers.hasDimensions(100, 50));
```

### TestDataGenerator

Generates test data for various scenarios:

```dart
// Generate button variants
final variants = TestDataGenerator.generateButtonVariants();

// Generate edge cases
final edgeCase = TestDataGenerator.generateEdgeCase('empty_dimensions');
```

## Usage Examples

### Basic Serialization Test

```dart
import 'dart:convert';
import 'dart:io';
import 'package:codelessly_api/codelessly_api.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_data/helpers/node_test_helpers.dart';

void main() {
  group('Button Node JSON Tests', () {
    test('loads and deserializes button_01_elevated.json', () {
      final jsonFile = File('test/test_data/json/input/button_01_elevated.json');
      final jsonString = jsonFile.readAsStringSync();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final node = ButtonNode.fromJson(json);

      expect(node.id, equals('button-elevated-1'));
      expect(node.name, equals('Elevated Button'));
      expect(node.type, equals('button'));
      expect(node.properties.label, equals('Elevated'));
    });

    test('button node round-trips through JSON correctly', () {
      final button = NodeBuilder.button(
        label: 'Test Button',
        buttonType: ButtonTypeEnum.elevated,
      );

      NodeTestHelper.verifyRoundTrip(button, ButtonNode.fromJson);
    });
  });
}
```

### Property Testing

```dart
test('button has all expected properties', () {
  final button = NodeBuilder.button(
    label: 'Click Me',
    buttonType: ButtonTypeEnum.outlined,
  );

  expect(button, NodeMatchers.hasNodeType('button'));
  expect(button, NodeMatchers.isVisible);
  expect(button.properties.label, equals('Click Me'));
  expect(button.properties.buttonType, equals(ButtonTypeEnum.outlined));
});
```

### Bulk Testing with JSON Files

```dart
group('All Button Variants', () {
  final buttonJsonDir = Directory('test/test_data/json/input');
  final buttonFiles = buttonJsonDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.contains('button_'));

  for (final file in buttonFiles) {
    test('deserializes ${file.path.split('/').last}', () {
      final jsonString = file.readAsStringSync();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(() => ButtonNode.fromJson(json), returnsNormally);

      final node = ButtonNode.fromJson(json);
      expect(node.type, equals('button'));
      expect(node, NodeMatchers.isVisible);
    });
  }
});
```

## Current Coverage

### Implemented JSON Files (10 files)

#### Input Nodes (5 files)
- ✅ button_01_elevated.json
- ✅ button_02_outlined.json
- ✅ button_03_text.json
- ✅ checkbox_01_basic.json
- ✅ checkbox_02_checked.json

#### Display Nodes (3 files)
- ✅ text_01_basic.json
- ✅ text_02_multiline.json
- ✅ rectangle_01_basic.json

#### Layout Nodes (2 files)
- ✅ row_column_01_basic_row.json
- ✅ row_column_02_basic_column.json

### Next Steps

1. Add more JSON configurations for existing nodes
2. Create JSON files for remaining 31 node types
3. Add complex nested layout scenarios
4. Create edge case test files
5. Integrate with CI/CD for automated testing

## Contributing

When adding new test data:

1. Follow the naming convention
2. Place files in the appropriate category directory
3. Include all required fields for the node type
4. Add at least 3 variations per node type (basic, advanced, edge case)
5. Update this README with new files
6. Consider adding helper methods if needed

## Related Documentation

- [Project Organization Plan](../../../docs/upgrade/10-PROJECT-ORGANIZATION-PLAN.md)
- [API Node Inventory](../../../docs/upgrade/11-CODELESSLY-API-NODE-INVENTORY.md)
- [CodelesslyAPI Package](../../lib/codelessly_api.dart)
