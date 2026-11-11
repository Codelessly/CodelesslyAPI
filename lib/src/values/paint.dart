import 'package:meta/meta.dart';

import '../json.dart';
import 'color.dart';
import 'enums.dart';
import 'geometry.dart';

enum PaintType { solid, linear, radial, sweep, diamond, image }

/// One gradient stop.
@immutable
final class ColorStop {
  const ColorStop(this.position, this.color);
  final double position;
  final Color color;

  static ColorStop? fromJson(Object? json) {
    final m = readMap(json);
    final c = Color.fromJson(m?['color']);
    return c == null ? null : ColorStop(readDouble(m!['position']) ?? 0, c);
  }

  Json toJson() => {'position': writeDouble(position), 'color': color.toJson()};

  @override
  bool operator ==(Object other) => other is ColorStop && other.position == position && other.color == color;

  @override
  int get hashCode => Object.hash(position, color);
}

/// An image source and how it fills its box (Flutter's `DecorationImage`).
@immutable
final class ImagePaint {
  const ImagePaint({
    this.url,
    this.assetId,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.scale = 1,
    this.tint,
    this.flipX = false,
    this.flipY = false,
    this.saturation = 1,
    this.rect,
    this.extra = const {},
  });

  final String? url;
  final String? assetId;
  final BoxFit fit;
  final Alignment alignment;
  final ImageRepeat repeat;

  /// The image's pixel scale (`Image.scale`): 2 draws it at half its size.
  final double scale;

  /// Draws every pixel in this color, keeping its alpha
  /// (`ColorFilter.mode(tint, BlendMode.srcIn)`).
  final Color? tint;

  /// Mirrors the image horizontally / vertically.
  final bool flipX, flipY;

  /// Color saturation: 1 keeps the colors, 0 is grayscale.
  final double saturation;

  /// Where the image is drawn, `[left, top, width, height]` in the box at
  /// its design size, instead of by [fit] and [alignment] (an image placed
  /// by hand). Null: placed by [fit] and [alignment].
  final List<double>? rect;

  /// Image settings for editors (crop, source size, names), round-tripped.
  final Json extra;

  static const _keys = {
    'url', 'assetId', 'fit', 'alignment', 'repeat', 'scale', 'tint', 'flipX', 'flipY', 'saturation', 'rect', //
  };

  static ImagePaint fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    final rect = readList(m['rect'])?.map(readDouble).toList();
    return ImagePaint(
      url: readString(m['url']),
      assetId: readString(m['assetId']),
      fit: readEnum(BoxFit.values, m['fit'], BoxFit.cover),
      alignment: Alignment.fromJson(m['alignment']) ?? Alignment.center,
      repeat: readEnum(ImageRepeat.values, m['repeat'], ImageRepeat.noRepeat),
      scale: (readDouble(m['scale']) ?? 1).abs(),
      tint: Color.fromJson(m['tint']),
      flipX: readBool(m['flipX']) ?? false,
      flipY: readBool(m['flipY']) ?? false,
      saturation: (readDouble(m['saturation']) ?? 1).clamp(0, double.infinity).toDouble(),
      rect: rect != null && rect.length == 4 && rect.every((v) => v != null) ? rect.cast<double>() : null,
      extra: {for (final e in m.entries) if (!_keys.contains(e.key)) e.key: e.value},
    );
  }

  Json toJson() {
    final j = <String, Object?>{...extra};
    put(j, 'url', url);
    put(j, 'assetId', assetId);
    put(j, 'fit', fit.name, BoxFit.cover.name);
    put(j, 'alignment', alignment == Alignment.center ? null : alignment.toJson());
    put(j, 'repeat', repeat.name, ImageRepeat.noRepeat.name);
    put(j, 'scale', writeDouble(scale), 1);
    put(j, 'tint', tint?.toJson());
    put(j, 'flipX', flipX, false);
    put(j, 'flipY', flipY, false);
    put(j, 'saturation', writeDouble(saturation), 1);
    put(j, 'rect', rect?.map(writeDouble).toList());
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is ImagePaint &&
      other.url == url &&
      other.assetId == assetId &&
      other.fit == fit &&
      other.alignment == alignment &&
      other.repeat == repeat &&
      other.scale == scale &&
      other.tint == tint &&
      other.flipX == flipX &&
      other.flipY == flipY &&
      other.saturation == saturation &&
      _listEq(other.rect, rect) &&
      jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(url, assetId, fit, alignment, repeat, scale, tint, flipX, flipY, saturation);
}

/// A fill or stroke paint: a solid color, a gradient or an image. Several
/// paints stack, first at the bottom.
@immutable
final class Paint {
  const Paint({
    this.type = PaintType.solid,
    this.id,
    this.visible = true,
    this.opacity = 1,
    this.blendMode = BlendMode.srcOver,
    this.color,
    this.stops = const [],
    this.transform,
    this.tileMode = TileMode.clamp,
    this.image,
    this.gradientPerSubpath = false,
    this.radius,
  });

  const Paint.solid(Color this.color, {this.id, this.opacity = 1})
      : type = PaintType.solid,
        visible = true,
        blendMode = BlendMode.srcOver,
        stops = const [],
        transform = null,
        tileMode = TileMode.clamp,
        image = null,
        gradientPerSubpath = false,
        radius = null;

  final PaintType type;

  /// Stable id, so a binding can target one paint (`fill-<id>`).
  final String? id;
  final bool visible;
  final double opacity;
  final BlendMode blendMode;

  /// Solid color (type `solid`).
  final Color? color;

  /// Gradient stops (gradient types).
  final List<ColorStop> stops;

  /// Gradient transform: a 2×3 affine matrix `[a, b, tx, c, d, ty]` mapping
  /// the unit square onto the box (Figma's gradient transform).
  final List<double>? transform;
  final TileMode tileMode;

  /// Image (type `image`).
  final ImagePaint? image;

  /// A gradient laid out in each shape of a path (every closed subpath,
  /// with the holes inside it) instead of across the box: one path of many
  /// cells shades each alike. Only paths paint per shape. JSON also reads
  /// SVG's `gradientUnits: "subpath"`.
  final bool gradientPerSubpath;

  /// A radial gradient's radius as a share of the box's shortest side,
  /// centered (Flutter's `RadialGradient(radius:)`), in place of the one
  /// [transform] gives (which reaches the box's edge across its width).
  /// Null: the transform's.
  final double? radius;

  bool get isGradient => type != PaintType.solid && type != PaintType.image;

  /// The solid color with the paint's opacity applied.
  Color? get effectiveColor => color?.multiplyOpacity(opacity);

  /// The [transform] of a linear gradient from [begin] to [end], as
  /// Flutter's `LinearGradient(begin, end)` draws it: the gradient's axis
  /// runs from the point [begin] names to the point [end] names. JSON may
  /// give `begin` and `end` (alignments: `[x, y]` in -1..1, or names such as
  /// `"topCenter"`) instead of a transform; they are read into one.
  static List<double>? linearTransform(Alignment? begin, Alignment? end) {
    if (begin == null && end == null) return null;
    final b = begin ?? Alignment.centerLeft, e = end ?? Alignment.centerRight;
    // Box unit square coordinates of the two points.
    final p0x = (b.x + 1) / 2, p0y = (b.y + 1) / 2;
    final dx = (e.x + 1) / 2 - p0x, dy = (e.y + 1) / 2 - p0y;
    final l2 = dx * dx + dy * dy;
    if (l2 == 0) return null;
    // u runs 0 → 1 from begin to end; v is 0.5 on the axis.
    return [
      dx / l2, dy / l2, -(p0x * dx + p0y * dy) / l2,
      -dy / l2, dx / l2, 0.5 - (-dy * p0x + dx * p0y) / l2,
    ].map((v) => v == 0 ? 0.0 : v).toList();
  }

  static Paint? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    // Without a type, a paint is what its keys say: an `image` paints the
    // image, gradient `stops` a linear gradient, anything else a color.
    final type = m['type'] == null
        ? (readMap(m['image']) != null
              ? PaintType.image
              : (readList(m['stops'])?.isNotEmpty ?? false)
              ? PaintType.linear
              : PaintType.solid)
        : readEnum(PaintType.values, m['type'], PaintType.solid);
    // An image's settings may also sit beside it (`{"image": {"url"}, "fit": "cover"}`).
    final imageJson = type == PaintType.image
        ? {
            for (final k in const ['fit', 'alignment', 'repeat', 'scale', 'tint', 'flipX', 'flipY'])
              if (m.containsKey(k)) k: m[k],
            ...?readMap(m['image']),
          }
        : null;
    return Paint(
      type: type,
      id: readString(m['id']),
      visible: readBool(m['visible']) ?? true,
      opacity: (readDouble(m['opacity']) ?? 1).clamp(0, 1).toDouble(),
      blendMode: readEnum(BlendMode.values, m['blendMode'], BlendMode.srcOver),
      color: Color.fromJson(m['color']),
      stops: [...?readList(m['stops'])?.map(ColorStop.fromJson).nonNulls],
      transform: readList(m['transform'])?.map((v) => readDouble(v) ?? 0).toList() ??
          (type == PaintType.linear ? linearTransform(Alignment.fromJson(m['begin']), Alignment.fromJson(m['end'])) : null),
      tileMode: readEnum(TileMode.values, m['tileMode'], TileMode.clamp),
      image: type == PaintType.image ? ImagePaint.fromJson(imageJson) : null,
      gradientPerSubpath: readBool(m['gradientPerSubpath']) ??
          (m['gradientUnits'] is String && (m['gradientUnits'] as String).toLowerCase() == 'subpath'),
      radius: switch (readDouble(m['radius'])) { final double r when r > 0 && r.isFinite => r, _ => null },
    );
  }

  static List<Paint> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() {
    final j = <String, Object?>{};
    put(j, 'type', type.name, PaintType.solid.name);
    put(j, 'id', id);
    put(j, 'visible', visible, true);
    put(j, 'opacity', writeDouble(opacity), 1);
    put(j, 'blendMode', blendMode.name, BlendMode.srcOver.name);
    put(j, 'color', color?.toJson());
    if (stops.isNotEmpty) j['stops'] = [for (final s in stops) s.toJson()];
    put(j, 'transform', transform?.map(writeDouble).toList());
    put(j, 'tileMode', tileMode.name, TileMode.clamp.name);
    put(j, 'image', image?.toJson());
    put(j, 'gradientPerSubpath', gradientPerSubpath, false);
    put(j, 'radius', radius == null ? null : writeDouble(radius!));
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Paint &&
      other.type == type &&
      other.id == id &&
      other.visible == visible &&
      other.opacity == opacity &&
      other.blendMode == blendMode &&
      other.color == color &&
      _listEq(other.stops, stops) &&
      _listEq(other.transform, transform) &&
      other.tileMode == tileMode &&
      other.image == image &&
      other.gradientPerSubpath == gradientPerSubpath &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(type, id, visible, opacity, blendMode, color, Object.hashAll(stops), tileMode, image, gradientPerSubpath, radius);
}

enum EffectType { dropShadow, innerShadow, layerBlur, backgroundBlur }

/// A shadow or blur (Flutter's `BoxShadow`, `ImageFilter.blur`).
@immutable
final class Effect {
  const Effect({
    required this.type,
    this.id,
    this.visible = true,
    this.color = const Color(0x40000000),
    this.offset = Offset.zero,
    this.blurRadius = 0,
    this.spreadRadius = 0,
    this.blendMode = BlendMode.srcOver,
  });

  final EffectType type;
  final String? id;
  final bool visible;
  final Color color;
  final Offset offset;
  final double blurRadius;
  final double spreadRadius;
  final BlendMode blendMode;

  bool get isShadow => type == EffectType.dropShadow || type == EffectType.innerShadow;

  static Effect? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null || m['type'] is! String) return null;
    final type = readEnum(EffectType.values, m['type'], EffectType.dropShadow);
    if (type.name != m['type']) return null;
    return Effect(
      type: type,
      id: readString(m['id']),
      visible: readBool(m['visible']) ?? true,
      color: Color.fromJson(m['color']) ?? const Color(0x40000000),
      offset: Offset.fromJson(m['offset']),
      blurRadius: readDouble(m['blurRadius']) ?? 0,
      spreadRadius: readDouble(m['spreadRadius']) ?? 0,
      blendMode: readEnum(BlendMode.values, m['blendMode'], BlendMode.srcOver),
    );
  }

  static List<Effect> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  Json toJson() {
    final j = <String, Object?>{'type': type.name};
    put(j, 'id', id);
    put(j, 'visible', visible, true);
    if (isShadow) {
      j['color'] = color.toJson();
      if (offset != Offset.zero) j['offset'] = offset.toJson();
      put(j, 'spreadRadius', writeDouble(spreadRadius), 0);
    }
    put(j, 'blurRadius', writeDouble(blurRadius), 0);
    put(j, 'blendMode', blendMode.name, BlendMode.srcOver.name);
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Effect &&
      other.type == type &&
      other.id == id &&
      other.visible == visible &&
      other.color == color &&
      other.offset == offset &&
      other.blurRadius == blurRadius &&
      other.spreadRadius == spreadRadius &&
      other.blendMode == blendMode;

  @override
  int get hashCode => Object.hash(type, id, visible, color, offset, blurRadius, spreadRadius, blendMode);
}

bool _listEq<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Element-wise list equality.
bool listEquals<T>(List<T>? a, List<T>? b) => _listEq(a, b);
