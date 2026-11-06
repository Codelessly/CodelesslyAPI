import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';
import 'models.dart';

part 'color_stop.g.dart';

/// A position color pair representing a gradient stop.
///
/// A stop's color can be bound to a variable path or formula through its
/// node's `variables`, under [bindingKey]: the binding key of the stop's
/// paint (`fill-<paint id>`, `stroke-paint-<paint id>` or
/// `foreground-<paint id>`) followed by `-stop-<index>`, e.g.
/// `"fill-g1-stop-0": "${pal.bg}"`. [color] is then what shows until the
/// binding gives a color. Its [position] binds the same way, under
/// [positionBindingKey] (`-stop-position-<index>`).
@JsonSerializable()
class ColorStop extends Equatable with SerializableMixin {
  /// The key of a node's `variables` that binds the color of stop [index]
  /// of the gradient paint whose own binding key is [paintKey].
  static String bindingKey(String paintKey, int index) =>
      '$paintKey-stop-$index';

  /// The key of a node's `variables` that binds the [position] (0 to 1) of
  /// stop [index] of the gradient paint whose own binding key is
  /// [paintKey], e.g. `"fill-g1-stop-position-1": "${= share}"`.
  static String positionBindingKey(String paintKey, int index) =>
      '$paintKey-stop-position-$index';

  /// Value between 0 and 1 representing position along gradient axis.
  final double position;

  /// Color attached to the corresponding position.
  final ColorRGBA color;

  /// Default constructor for creating a new instance.
  const ColorStop({required this.position, required this.color});

  @override
  List<Object> get props => [position, color];

  /// Duplicates this instance with the given value overrides.
  ColorStop copyWith({double? position, ColorRGBA? color}) => ColorStop(
    position: position ?? this.position,
    color: color ?? this.color,
  );

  /// Factory constructor for creating a new [ColorStop] instance.
  factory ColorStop.fromJson(Map json) => _$ColorStopFromJson(json);

  @override
  Map toJson() => _$ColorStopOmitDefaults(this, _$ColorStopToJson(this));
}
