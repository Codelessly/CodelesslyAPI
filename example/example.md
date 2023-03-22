### Creating a new node

```dart
import 'package:codelessly_api/codelessly_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_cool_node.g.dart';

/// At it's core, this is the most basic example of how to create a complete
/// [BaseNode].
@JsonSerializable()
class MyCoolNode extends BaseNode {
  @override
  final String type = 'myCoolNode';

  MyCoolNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
  });

  factory MyCoolNode.fromJson(Map json) => _$MyCoolNodeFromJson(json);

  @override
  Map toJson() => _$MyCoolNodeToJson(this);
}

```