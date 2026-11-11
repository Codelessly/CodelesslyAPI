// How a node sizes itself and sits in its parent: intent, in Flutter's terms.
// Nothing here is a layout result; the renderer computes those.
import 'package:meta/meta.dart';

import 'json.dart';
import 'values/geometry.dart';

/// How a node sizes along one axis.
enum SizeFit {
  /// The design size, exactly (`SizedBox`).
  fixed,

  /// Takes all the space its parent gives (`Expanded` in a row/column on the
  /// main axis, stretch on the cross axis or in a stack).
  fill,

  /// Up to its design size, less if the parent has less (`Flexible`, loose).
  flexible,

  /// Sizes to its content (`MainAxisSize.min`, intrinsic text size).
  hug,
}

/// Sizing along one axis. [value] is the design size: the size for
/// [SizeFit.fixed], and the fallback whenever a mode can't apply. JSON: a
/// number (fixed) or `{"fill"|"flexible"|"hug": value}`.
@immutable
final class AxisSize {
  const AxisSize(this.fit, this.value);
  const AxisSize.fixed(this.value) : fit = SizeFit.fixed;
  const AxisSize.fill(this.value) : fit = SizeFit.fill;
  const AxisSize.hug(this.value) : fit = SizeFit.hug;

  final SizeFit fit;
  final double value;

  bool get isFixed => fit == SizeFit.fixed;
  bool get isFill => fit == SizeFit.fill;
  bool get isHug => fit == SizeFit.hug;
  bool get isFlexible => fit == SizeFit.flexible;

  /// Takes part in flex distribution (fill or flexible).
  bool get isFlex => fit == SizeFit.fill || fit == SizeFit.flexible;

  AxisSize withValue(double v) => AxisSize(fit, v);
  AxisSize withFit(SizeFit f) => AxisSize(f, value);

  static AxisSize fromJson(Object? json, {double fallback = 0}) {
    if (readDouble(json) case final double v) return AxisSize.fixed(v < 0 ? 0 : v);
    final m = readMap(json);
    if (m != null && m.length == 1) {
      final e = m.entries.first;
      final fit = readEnum(SizeFit.values, e.key, SizeFit.fixed);
      final v = readDouble(e.value) ?? fallback;
      return AxisSize(fit, v < 0 ? 0 : v);
    }
    return AxisSize.fixed(fallback);
  }

  Object toJson() => fit == SizeFit.fixed ? writeDouble(value) : {fit.name: writeDouble(value)};

  @override
  bool operator ==(Object other) => other is AxisSize && other.fit == fit && other.value == value;

  @override
  int get hashCode => Object.hash(fit, value);

  @override
  String toString() => '${fit.name}($value)';
}

/// Where a child of a freeform (stack) parent sits on one axis, as
/// Flutter's `Positioned` or `Align`, in the parent's padded box:
///
/// * `{"start": d}`: d from the start edge;
/// * `{"end": d}`: d from the end edge;
/// * `{"start": a, "end": b}`: stretched between the two;
/// * `{"align": t}`: aligned like `Align`, -1 (start) to 1 (end), by its
///   laid-out size;
/// * `{"relative": d}`: d from the start at design size, keeping its share
///   of the free space (measured with the design sizes) as the parent
///   resizes. A text that lays out wider than designed stays where it was
///   put, which `align` wouldn't do.
@immutable
final class AxisPosition {
  const AxisPosition.start(double this.start)
      : end = null,
        align = null,
        relative = null;
  const AxisPosition.end(double this.end)
      : start = null,
        align = null,
        relative = null;
  const AxisPosition.stretch(double this.start, double this.end)
      : align = null,
        relative = null;
  const AxisPosition.align(double this.align)
      : start = null,
        end = null,
        relative = null;
  const AxisPosition.relative(double this.relative)
      : start = null,
        end = null,
        align = null;

  static const AxisPosition zero = AxisPosition.start(0);

  final double? start;
  final double? end;
  final double? align;
  final double? relative;

  bool get isStretch => start != null && end != null;

  static AxisPosition fromJson(Object? json) {
    // A number is the distance from the start (DESIGN.md: "distance from the
    // start, or a position map"), as a binding of `layout.x` gives it.
    if (readDouble(json) case final double d when json is! Map) return AxisPosition.start(d);
    final m = readMap(json);
    if (m == null) return zero;
    if (readDouble(m['align']) case final double a) return AxisPosition.align(a);
    if (readDouble(m['relative']) case final double r) return AxisPosition.relative(r);
    final s = readDouble(m['start']), e = readDouble(m['end']);
    if (s != null && e != null) return AxisPosition.stretch(s, e);
    if (e != null) return AxisPosition.end(e);
    return AxisPosition.start(s ?? 0);
  }

  Json toJson() => {
        if (start != null) 'start': writeDouble(start!),
        if (end != null) 'end': writeDouble(end!),
        if (align != null) 'align': writeDouble(align!),
        if (relative != null) 'relative': writeDouble(relative!),
      };

  @override
  bool operator ==(Object other) =>
      other is AxisPosition &&
      other.start == start &&
      other.end == end &&
      other.align == align &&
      other.relative == relative;

  @override
  int get hashCode => Object.hash(start, end, align, relative);

  @override
  String toString() => 'AxisPosition${toJson()}';
}

/// A node's layout.
@immutable
final class Layout {
  const Layout({
    this.width = const AxisSize.fixed(0),
    this.height = const AxisSize.fixed(0),
    this.flex = 1,
    this.squeezable = false,
    this.constraints = BoxConstraints.none,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.x = AxisPosition.zero,
    this.y = AxisPosition.zero,
    this.align,
    this.rotation = 0,
    this.aspectRatio,
    this.widthFactor,
    this.heightFactor,
  });

  final AxisSize width;
  final AxisSize height;

  /// Share of a row/column's free space (fill and flexible children).
  final int flex;

  /// A hugging child of a row/column that may shrink below its content
  /// size when the row/column runs out of space (`Flexible`, loose).
  final bool squeezable;
  final BoxConstraints constraints;

  /// Space around the node, outside its box.
  final EdgeInsets margin;

  /// Space between the node's box and its content.
  final EdgeInsets padding;

  /// Position under a freeform parent.
  final AxisPosition x, y;

  /// Alignment in its slot under a row/column parent (`Align`).
  final Alignment? align;

  /// Degrees, clockwise, about the center.
  final double rotation;

  /// Width / height the node keeps when its parent resizes it.
  final double? aspectRatio;

  /// A share (0–1 and up) of the room its parent gives it on that axis
  /// (`FractionallySizedBox`): a progress bar's fill is `widthFactor: 0.6` of
  /// its track. Null: sized by [width] / [height]. Bindable (`layout.widthFactor`).
  final double? widthFactor, heightFactor;

  AxisSize along(bool horizontal) => horizontal ? width : height;

  Layout copyWith({
    AxisSize? width,
    AxisSize? height,
    int? flex,
    bool? squeezable,
    BoxConstraints? constraints,
    EdgeInsets? margin,
    EdgeInsets? padding,
    AxisPosition? x,
    AxisPosition? y,
    Alignment? Function()? align,
    double? rotation,
    double? Function()? aspectRatio,
    double? Function()? widthFactor,
    double? Function()? heightFactor,
  }) =>
      Layout(
        width: width ?? this.width,
        height: height ?? this.height,
        flex: flex ?? this.flex,
        squeezable: squeezable ?? this.squeezable,
        constraints: constraints ?? this.constraints,
        margin: margin ?? this.margin,
        padding: padding ?? this.padding,
        x: x ?? this.x,
        y: y ?? this.y,
        align: align == null ? this.align : align(),
        rotation: rotation ?? this.rotation,
        aspectRatio: aspectRatio == null ? this.aspectRatio : aspectRatio(),
        widthFactor: widthFactor == null ? this.widthFactor : widthFactor(),
        heightFactor: heightFactor == null ? this.heightFactor : heightFactor(),
      );

  static Layout fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return const Layout();
    final ratio = readDouble(m['aspectRatio']);
    return Layout(
      width: AxisSize.fromJson(m['width']),
      height: AxisSize.fromJson(m['height']),
      flex: (readInt(m['flex']) ?? 1).clamp(0, 1 << 20),
      squeezable: readBool(m['squeezable']) ?? false,
      constraints: BoxConstraints.fromJson(m['constraints']),
      margin: EdgeInsets.fromJson(m['margin']),
      padding: EdgeInsets.fromJson(m['padding']),
      x: AxisPosition.fromJson(m['x']),
      y: AxisPosition.fromJson(m['y']),
      align: Alignment.fromJson(m['align']),
      rotation: readDouble(m['rotation']) ?? 0,
      aspectRatio: ratio != null && ratio > 0 ? ratio : null,
      widthFactor: _factor(m['widthFactor']),
      heightFactor: _factor(m['heightFactor']),
    );
  }

  static double? _factor(Object? v) {
    final f = readDouble(v);
    return f == null || !f.isFinite ? null : (f < 0 ? 0 : f);
  }

  Json toJson() {
    final j = <String, Object?>{
      'width': width.toJson(),
      'height': height.toJson(),
    };
    if (flex != 1) j['flex'] = flex;
    if (squeezable) j['squeezable'] = true;
    if (!constraints.isEmpty) j['constraints'] = constraints.toJson();
    if (!margin.isZero) j['margin'] = margin.toJson();
    if (!padding.isZero) j['padding'] = padding.toJson();
    if (x != AxisPosition.zero) j['x'] = x.toJson();
    if (y != AxisPosition.zero) j['y'] = y.toJson();
    if (align != null) j['align'] = align!.toJson();
    if (rotation != 0) j['rotation'] = writeDouble(rotation);
    if (aspectRatio != null) j['aspectRatio'] = writeRatio(aspectRatio!);
    if (widthFactor != null) j['widthFactor'] = writeDouble(widthFactor!);
    if (heightFactor != null) j['heightFactor'] = writeDouble(heightFactor!);
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Layout &&
      other.width == width &&
      other.height == height &&
      other.flex == flex &&
      other.squeezable == squeezable &&
      other.constraints == constraints &&
      other.margin == margin &&
      other.padding == padding &&
      other.x == x &&
      other.y == y &&
      other.align == align &&
      other.rotation == rotation &&
      other.aspectRatio == aspectRatio &&
      other.widthFactor == widthFactor &&
      other.heightFactor == heightFactor;

  @override
  int get hashCode =>
      Object.hash(width, height, flex, squeezable, constraints, margin, padding, x, y, align, rotation, aspectRatio, widthFactor, heightFactor);
}
