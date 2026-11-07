import 'package:meta/meta.dart';

import '../json.dart';
import 'color.dart';
import 'enums.dart';

/// Flutter's `BorderStyle`.
enum BorderStyle { none, solid }

/// Flutter's `BorderSide`. A null [color] is unset: the widget's theme
/// default where it has one, else Flutter's black.
@immutable
final class BorderSide {
  const BorderSide({this.color, this.width = 1, this.style = BorderStyle.solid, this.strokeAlign = StrokeAlign.inside});

  static const BorderSide standard = BorderSide();
  static const BorderSide none = BorderSide(width: 0);

  final Color? color;
  final double width;
  final BorderStyle style;
  final StrokeAlign strokeAlign;

  BorderSide copyWith({Color? color, double? width, BorderStyle? style, StrokeAlign? strokeAlign}) => BorderSide(
        color: color ?? this.color,
        width: width ?? this.width,
        style: style ?? this.style,
        strokeAlign: strokeAlign ?? this.strokeAlign,
      );

  static BorderSide? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return BorderSide(
      color: Color.fromJson(m['color']),
      width: (readDouble(m['width']) ?? 1).clamp(0, double.infinity).toDouble(),
      style: readEnum(BorderStyle.values, m['style'], BorderStyle.solid),
      strokeAlign: readEnum(StrokeAlign.values, m['strokeAlign'], StrokeAlign.inside),
    );
  }

  Json toJson() => {
        if (color != null) 'color': color!.toJson(),
        if (width != 1) 'width': writeDouble(width),
        if (style != BorderStyle.solid) 'style': style.name,
        if (strokeAlign != StrokeAlign.inside) 'strokeAlign': strokeAlign.name,
      };

  @override
  bool operator ==(Object other) =>
      other is BorderSide &&
      other.color == color &&
      other.width == width &&
      other.style == style &&
      other.strokeAlign == strokeAlign;

  @override
  int get hashCode => Object.hash(color, width, style, strokeAlign);

  @override
  String toString() => 'BorderSide(${toJson()})';
}
