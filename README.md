## Codelessly API

This package provides a set of APIs for creating "Nodes" in Codelessly,
a design-to-code tool that helps users import designs from Figma and convert
them into working apps and websites. With these APIs, you can programmatically
create your own nodes.

## Features

This package contains tools to extend the default Codelessly api to create custom
`BaseNode`s only. If you wish to create and register your nodes, along with their
respective transformers to convert your custom `BaseNode`s into Flutter widgets
you will need to use the `codelessly_sdk` package.

This package is built with pure Dart, not relying on Flutter.
It is meant specifically for defining `BaseNode`s and nothing else, as it does not
contain any tools for converting Nodes into Flutter widgets or for interacting
with the Codelessly editor. It is intended to be used in conjunction with
the `codelessly_sdk` package for those purposes.

In light of that, and to enable complete serialization of all nodes, this package
contains a custom set of base classes that mirror Flutter's own models. Some of those
include `Vec`, `RectC`, `SizeC`, `AlignC`, as well as most properties you would find
in a given Flutter widget.

Classes that mirror Flutter tend to be suffixed with a `C` for `Codelessly` or `Model` to
differentiate them from their Flutter counterparts like `AlignmentModel`

## Usage

Here is a minimal example of how to use this package to create a custom `BaseNode`:

Please read the code inside `BaseNode` to better understand what each property does, and
refer to one of the many nodes under `codelessly_api/lib/api/nodes` for additional
examples.

```dart
import 'package:codelessly_api/codelessly_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_cool_node.g.dart';

/// At it's core, this is the most basic example of how to create a complete
/// [BaseNode].
@JsonSerializable()
class MyCoolNode extends BaseNode {
  @override
  final String type = 'my_cool_node';

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

Make sure to register your node with the `NodeJsonConverter` so that it can be
properly deserialized from json. The NodeJsonConverter will deserialize any
registered nodes into their proper types.

```
NodeJsonConverter.registerNode('my_cool_node', MyCoolNode.fromJson);
```

## Additional information

If you have any questions or run into any issues, you can file a support ticket through the Codelessly website or
contact the Codelessly team directly. We welcome contributions to this package and encourage you to submit any issues or
pull requests through the
GitHub repository.

You can contact us on our [Website](https://codelessly.com/) or join us on
our [Discord Server](https://discord.gg/Bzaz7zmY6q).