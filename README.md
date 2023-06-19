**This is a lower-level package for constructing an abstract, universal data representation of UI. If you're looking for the developer SDK, use the [Codelessly Cloud UI SDK](https://pub.dev/packages/codelessly_sdk).**

# Codelessly API

> Flutter's layouts and widgets represented as models and JSON data. 

This package is used by the Codelessly Editor and CloudUI SDK to render Flutter Widgets. These APIs enable developers to interact with and manipulate user interfaces in a structured manner. It can be used to define components, layouts, interactions, and styles, among other things, programmatically.

## About

> User Interfaces (UI) as data.

This lower-level package establishes a foundation for an abstract, universally interpretable data representation of UI. The API is language-agnostic, written in pure Dart with no Flutter dependencies. 

This universal approach allows for broad, diverse applications across different programming languages.  The result is a library that supports the construction of complex UI structures, regardless of the programming language or development environment.

For example, we've translated this library to Javascript and Typescript and created a prototype SDK for building native web UIs. We were able to deploy the same UI to Flutter and HTML simultaneously.

Our goal is to continuously build a set of fundamental UI constructs that can express UI in HTML, SwiftUI, Android Compose, and eventually AI.

## Quick Start

This package contains tools to create custom `BaseNodes`. To convert a custom `BaseNode` into UI, see the language specific Flutter implementation in the [Codelessly Cloud UI SDK](https://pub.dev/packages/codelessly_sdk) package.

This is how you can create a custom `BaseNode`:

```dart
import 'package:codelessly_api/codelessly_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_node.g.dart';

@JsonSerializable()
class CustomNode extends BaseNode {
  @override
  final String type = 'custom_node';

  MyCoolNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
  });

  factory CustomNode.fromJson(Map json) => _$CustomNodeFromJson(json);

  @override
  Map toJson() => _$CustomNodeToJson(this);
}
```

All nodes must extend `BaseNode`. Please refer to the documentation inside `BaseNode` for more information. 

Then, register your node with the `NodeJsonConverter` so that it can be properly deserialized from json. The NodeJsonConverter will deserialize any registered nodes into their proper types.

```
NodeJsonConverter.registerNode('custom_node', CustomNode.fromJson);
```

For more examples, see [`codelessly_api/lib/api/nodes`](https://github.com/Codelessly/CodelesslyAPI/tree/main/lib/src/api/nodes)

## Key Concepts

### Base Classes

The base classes provided by the CodelesslyAPI include `Vec`, `RectC`, `SizeC`, `AlignC`, and others. They mirror Flutter's own models and offer functionalities that represent essential building blocks for Flutter widgets. 

These classes encapsulate key properties and behaviors needed for vector representations (`Vec`), rectangular shapes (`RectC`), sizes (`SizeC`), and alignment specifications (`AlignC`). Each class is equipped with serialization and deserialization capabilities, allowing them to be conveniently converted to and from JSON format. These classes collectively provide a foundation for defining and manipulating UI elements in Flutter applications.

Classes that mirror Flutter tend to be suffixed with a `C` for `Codelessly` or `Model` to
differentiate them from their Flutter counterparts like `RectC`.

- **Vec**: This class represents a two-dimensional vector with x and y coordinates.
- **RectC**: This class represents a rectangle with a top-left position and a size. The position is represented as a `Vec` object, while the size is represented as a `SizeC` object.

### Components

Components represent the building blocks of the user interface. They can be anything from a single button to a complex form or even an entire webpage.

- `ComponentModel`: A single component that holds properties of the component (`type`), its unique identifier (`id`), and actions associated with it (`action`).

### Actions

Actions define what should happen when a user interacts with a component in a certain way (for example, clicking a button or submitting a form).

- `ActionModel`: Holds information about an action to perform on a user interaction. It defines the type of the action (`type`), which can be things like navigating to a page, opening a link, submitting a form, etc.

### Paint

The `PaintModel` is used to define styles that can be applied to components. It can represent a solid color, gradient, or image texture.

- `PaintModel`: Defines the style properties such as the type of paint (`type`), its visibility (`visible`), and its opacity (`opacity`), among others. Depending on the type of paint, it might have properties like color (`color`), gradient transform (`gradientTransform`), gradient stops (`gradientStops`), or image transform (`imageTransform`).

## Contributing

Contributions are welcome! Please open an issue to start a discussion.

## Acknowledgments

Special thanks to the Flutter community for providing the inspiration and foundation for this project.

## Contact Us

You can contact us on our [website](https://codelessly.com/) or join us on
our [Discord Server](https://discord.gg/Bzaz7zmY6q).