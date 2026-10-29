/// The canonical Flutter widget represented by one node.
class FlutterNode {
  /// Flutter widget class name.
  final String widget;
  /// Source widget library family.
  final String family;
  /// The node wire type emitted in serialized JSON.
  final String nodeType;
  /// Identifies the Flutter widget that this node models.
  const FlutterNode(this.widget, {required this.family, required this.nodeType});
}

/// A Flutter constructor parameter's Codelessly wire metadata.
/// `field` is explicit for mixin and nested property storage.
class FlutterProp {
  /// Constructor parameter name.
  final String name;
  /// JSON Schema type.
  final String type;
  /// DPP grouping.
  final String group;
  /// Editor control kind.
  final String control;
  /// Actual field path in the node.
  final String? field;
  /// Flutter constructor default expression, not an evaluated value.
  final String? defaultSource;
  /// Whether the corresponding Flutter parameter is required.
  final bool required;
  /// Whether a data binding is permitted.
  final bool bindable;
  /// Declares one Flutter parameter and its generated projections.
  const FlutterProp(this.name, {required this.type, required this.group,
    required this.control, this.field, this.defaultSource,
    this.required = false, this.bindable = false});
}
