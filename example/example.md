### Creating a new node

```dart
import 'package:codelessly_api/codelessly_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_node.g.dart';

/// An example of how to create a new node.
@JsonSerializable()
class MyNode extends BaseNode {
  @override
  final String type = 'myNode';

  MyNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
  });

  factory MyNode.fromJson(Map json) => _$MyNodeFromJson(json);

  @override
  Map toJson() => _$MyNodeToJson(this);
}

```