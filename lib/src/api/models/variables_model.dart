import 'dart:convert';

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'variables_model.g.dart';

/// Type of a variable.
enum VariableType {
  /// Integer type. Represents a whole number.
  integer,

  /// Text type. Represents a string.
  text,

  /// Decimal type. Represents a decimal number.
  decimal,

  /// Boolean type. Represents a boolean value.
  boolean,

  /// Color type. Represents a color.
  color,

  /// List type. Represents a list of values.
  list,

  /// Map type. Represents a map.
  map,

  /// Image type. Represents an image URL.
  image;

  /// Returns a string representation of the variable type.
  String get label => switch (this) {
        VariableType.integer => 'Integer',
        VariableType.text => 'Text',
        VariableType.decimal => 'Decimal',
        VariableType.boolean => 'Boolean',
        VariableType.color => 'Color',
        VariableType.list => 'List',
        VariableType.map => 'Map',
        VariableType.image => 'Image',
      };

  factory VariableType.fromObjectType(Object obj) {
    return switch (obj) {
      int() => VariableType.integer,
      double() => VariableType.decimal,
      bool() => VariableType.boolean,
      ColorRGBA() => VariableType.color,
      ColorRGB() => VariableType.color,
      List() => VariableType.list,
      Map() => VariableType.map,
      String() => VariableType.text,
      _ => throw UnsupportedError(
          'object type ${obj.runtimeType} is not supported. Cannot determine variable type'),
    };
  }

  /// Whether the variable type is [VariableType.map].
  bool get isMap => this == VariableType.map;

  /// Whether the variable type is [VariableType.list].
  bool get isList => this == VariableType.list;

  /// Whether the variable type is [VariableType.color].
  bool get isColor => this == VariableType.color;

  /// Whether the variable type is [VariableType.boolean].
  bool get isBoolean => this == VariableType.boolean;

  /// Whether the variable type is [VariableType.decimal].
  bool get isDecimal => this == VariableType.decimal;

  /// Whether the variable type is [VariableType.integer].
  bool get isInteger => this == VariableType.integer;

  /// Whether the variable type is [VariableType.text].
  bool get isText => this == VariableType.text;

  /// Whether the variable type is [VariableType.text].
  bool get isImage => this == VariableType.image;
}

/// Store information of a variable. [id] must not be empty when creating a
/// new variable.
/// Comparable allows to compare variables by name. It is helpful in sorting.
@JsonSerializable()
class VariableData
    with EquatableMixin, SerializableMixin
    implements Comparable<VariableData> {
  /// This is generated by [AutoID.autoID] for a unique ID.
  final String id;

  /// Name of the variable. This must be unique within a scope.
  final String name;

  /// Default value this variable. This can be an empty string if no value is
  /// explicitly provided by the user.
  final String value;

  /// Whether the variable has a value or not.
  bool get hasValue => value.isNotEmpty;

  /// Type of the variable. This is used to determine how to parse the value.
  @JsonKey(unknownEnumValue: VariableType.text)
  final VariableType type;

  /// Extra information that can be stored with the variable. This can be
  /// metadata or any other information that is not part of the core variable.
  final Map<String, dynamic> extra;

  /// Creates a new [VariableData].
  VariableData({
    required this.id,
    required this.name,
    Object? value = '',
    this.type = VariableType.text,
    Map<String, dynamic>? extra,
  })  : value = sanitizeValueForVariableType(value, type).toString(),
        extra = extra ?? {};

  /// Duplicate a [VariableData] with the given parameters.
  VariableData copyWith({
    String? id,
    String? name,
    Object? value,
    VariableType? type,
    bool? isUsed,
    Set<String>? nodes,
    Map<String, dynamic>? extra,
  }) {
    final String? sanitizedValue = value == null
        ? null
        : sanitizeValueForVariableType(value, type ?? this.type);
    return VariableData(
      id: id ?? this.id,
      name: name ?? this.name,
      value: sanitizedValue ?? this.value,
      type: type ?? this.type,
      extra: extra ?? this.extra,
    );
  }

  @override
  List<Object?> get props => [id, name, value, type];

  @override
  int compareTo(VariableData other) => name.compareTo(other.name);

  /// Creates a new [VariableData] from a JSON map.
  factory VariableData.fromJson(Map<String, dynamic> json) =>
      _$VariableDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VariableDataToJson(this);

  /// Allows to convert a [VariableData] into [CanvasVariableData] with the
  /// given [canvasId].
  CanvasVariableData withCanvas(String canvasId) => CanvasVariableData(
        id: id,
        canvasId: canvasId,
        name: name,
        value: value,
        type: type,
      );

  /// Returns the value converted to the appropriate type according to [type].
  Object? getValue() => switch (type) {
        VariableType.text => value.isEmpty ? null : value,
        VariableType.image => value.isEmpty ? null : value,
        VariableType.integer => num.tryParse(value).toInt(),
        VariableType.decimal => num.tryParse(value).toDouble(),
        VariableType.boolean => bool.tryParse(value, caseSensitive: false),
        VariableType.color => ColorRGBA.fromHex(value),
        VariableType.map => tryJsonDecode(value),
        VariableType.list => value.toList(),
      };
}

/// Returns the value converted to the appropriate type according to [type].
/// Supported color values:
/// - ColorRGBA
/// - ColorRGB
/// - Hex color string
/// - Flutter Color object
String? sanitizeValueForVariableType(Object? value, VariableType type) {
  if (value == null) return null;
  // if (value.isEmpty) return '';
  // Do not sanitize if the value contains a variable path.
  if (value.toString().contains(variablePathPattern)) return value.toString();
  switch (type) {
    case VariableType.text:
    case VariableType.image:
      return value.toString();
    case VariableType.integer:
      return num.tryParse(value.toString()).toInt()?.toString();
    case VariableType.decimal:
      return num.tryParse(value.toString()).toDouble()?.toString();
    case VariableType.boolean:
      return bool.tryParse(value.toString(), caseSensitive: false)?.toString();
    case VariableType.color:
      if (value is ColorRGBA) return value.toHex();
      if (value is ColorRGB) return value.toColorRGBA()!.toHex();
      final colorMatch = flutterColorRegex.firstMatch(value.toString());
      if (colorMatch != null) {
        return ColorRGBA.fromHex(colorMatch.namedGroup('hex')!)?.toHex();
      }
      final hexMatch = hexColorRegex.firstMatch(value.toString());
      if (hexMatch != null) return value.toString().toUpperCase();
      return null;
    // This could be a bit expensive. Maybe enable only when required!
    case VariableType.map:
      if (value is Map) return jsonEncode(value);
      final map = value.toMap();
      return map != null ? jsonEncode(map) : null;
    case VariableType.list:
      if (value is List) return jsonEncode(value);
      final list = value.toList();
      return list != null ? jsonEncode(list) : null;
  }
}

/// A variable that is scoped to a canvas.
@JsonSerializable()
class CanvasVariableData extends VariableData {
  /// ID of the canvas this variable belongs to.
  final String canvasId;

  /// Creates a new [CanvasVariableData].
  CanvasVariableData({
    required super.id,
    required this.canvasId,
    required super.name,
    super.type,
    super.value,
    super.extra,
  });

  @override
  CanvasVariableData copyWith({
    String? name,
    Object? value,
    VariableType? type,
    String? id,
    bool? isUsed,
    String? canvasId,
    Set<String>? nodes,
    Map<String, dynamic>? extra,
  }) {
    final String? sanitizedValue = value == null
        ? null
        : sanitizeValueForVariableType(value, type ?? this.type);
    return CanvasVariableData(
      name: name ?? this.name,
      value: sanitizedValue ?? this.value,
      type: type ?? this.type,
      id: id ?? this.id,
      canvasId: canvasId ?? this.canvasId,
      extra: extra ?? this.extra,
    );
  }

  @override
  List<Object?> get props => [...super.props, canvasId];

  /// Creates a new [CanvasVariableData] from a JSON map.
  factory CanvasVariableData.fromJson(Map<String, dynamic> json) =>
      _$CanvasVariableDataFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$CanvasVariableDataToJson(this)..remove('canvasId');
}

/// A variable class that represents creation of a variable from given name.
class PredefinedVariableData extends VariableData {
  /// Creates a new [PredefinedVariableData].
  PredefinedVariableData({
    required super.name,
    super.value = '',
    super.type = VariableType.text,
  }) : super(id: generateId());
}

/// A variable class that represents variables that are created at runtime.
class RuntimeVariableData extends VariableData {
  /// Creates a new [PredefinedVariableData].
  RuntimeVariableData({
    String? id,
    required super.name,
    super.value = '',
    super.type = VariableType.text,
    super.extra,
  }) : super(id: id ?? generateId());

  @override
  RuntimeVariableData copyWith({
    String? id,
    String? name,
    Object? value,
    VariableType? type,
    bool? isUsed,
    Set<String>? nodes,
    Map<String, dynamic>? extra,
  }) {
    final String? sanitizedValue = value == null
        ? null
        : sanitizeValueForVariableType(value, type ?? this.type);
    return RuntimeVariableData(
      id: id ?? this.id,
      name: name ?? this.name,
      value: sanitizedValue ?? this.value,
      type: type ?? this.type,
      extra: extra ?? this.extra,
    );
  }
}

/// A type that defines a callback to get the value of an accessor.
typedef GetValueCallback = Object? Function(Object? value);

/// Defines an accessor for a variable.
class Accessor with EquatableMixin {
  /// Name of the accessor.
  final String name;

  /// Type of the accessor.
  final VariableType type;

  /// Defines a callback that can be used to get the value of the accessor.
  final GetValueCallback? _getValue;

  /// Creates a new [Accessor].
  const Accessor({
    required this.name,
    required this.type,
    GetValueCallback? getValue,
  }) : _getValue = getValue;

  @override
  List<Object?> get props => [name, type];

  /// Returns the value of the accessor for the given [value].
  Object? getValue(Object? value) => _getValue?.call(value);

  /// Converts this accessor to a leaf accessor.
  LeafAccessor toLeaf() => LeafAccessor.from(this);
}

/// Defines an accessor for a variable that is a leaf node. Meaning it does not
/// have any children.
class LeafAccessor extends Accessor {
  /// Creates a new [LeafAccessor].
  const LeafAccessor({
    required super.name,
    required super.type,
    super.getValue,
  });

  /// Creates a new [LeafAccessor] from an [Accessor].
  LeafAccessor.from(Accessor accessor)
      : super(
            name: accessor.name,
            type: accessor.type,
            getValue: accessor.getValue);
}
