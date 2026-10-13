### Creating a new node

```dart
import 'package:codelessly_api/codelessly_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_node.g.dart';

/// An example of how to create a new node.
@JsonSerializable()
class CustomNode extends BaseNode {
  @override
  final String type = 'custom_node';

  CustomNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
  });

  factory CustomNode.fromJson(Map json) => _$CustomNodeFromJson(json);

  @override
  Map toJson() => _$CustomNodeToJson(this);
}
```