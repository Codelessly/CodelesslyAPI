import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'safe_area.g.dart';

/// Represents a safe area.
@JsonSerializable(useDynamics: true, createToJson: false)
class SafeAreaModel with EquatableMixin {
  /// Whether to apply safe area to the top side of the widget.
  final bool top;

  /// Whether to apply safe area to the bottom side of the widget.
  final bool bottom;

  /// Whether to apply safe area to the left side of the widget.
  final bool left;

  /// Whether to apply safe area to the right side of the widget.
  final bool right;

  /// Whether to apply safe area to the widget.
  final bool enabled;

  /// Creates a new [SafeAreaModel] instance.
  const SafeAreaModel({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.enabled,
  });

  /// Creates a new [SafeAreaModel] instance with all sides set to [value].
  const SafeAreaModel.all(bool value)
      : this(
          top: value,
          bottom: value,
          left: value,
          right: value,
          enabled: value,
        );

  /// Creates a new [SafeAreaModel] instance with overridden values.
  SafeAreaModel copyWith({
    bool? top,
    bool? bottom,
    bool? left,
    bool? right,
    bool? enabled,
  }) {
    return SafeAreaModel(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      right: right ?? this.right,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [
        top,
        bottom,
        left,
        right,
        enabled,
      ];

  /// Creates a new [SafeAreaModel] from a JSON data.
  factory SafeAreaModel.fromJson(dynamic json) {
    if (json case bool value) {
      return SafeAreaModel(
        top: value,
        bottom: value,
        left: value,
        right: value,
        enabled: value,
      );
    }
    if (json case [bool horizontal, bool vertical, bool enabled]) {
      return SafeAreaModel(
        top: vertical,
        bottom: vertical,
        left: horizontal,
        right: horizontal,
        enabled: enabled,
      );
    }
    if (json
        case [bool left, bool top, bool right, bool bottom, bool enabled]) {
      return SafeAreaModel(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        enabled: enabled,
      );
    }
    return _$SafeAreaModelFromJson(json);
  }

  /// Converts this [SafeAreaModel] to JSON.
  dynamic toJson() {
    if (left == top && top == right && right == bottom && bottom == enabled) {
      return enabled;
    }
    if (left == right && top == bottom && left != top) {
      return [left, top, enabled];
    }
    return [left, top, right, bottom, enabled];
  }
}
