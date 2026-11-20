import 'package:meta/meta.dart';

import 'json.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/paint.dart';

/// Which sides a box's stroke runs along: every side (rounded with the
/// corners), one side, a pair of opposite sides (a ruled band), two sides
/// meeting at a corner (`topRight`: the top and right sides, as a table's
/// header corner), every side but one (`noTop`), or none, as Flutter's
/// `Border` takes any of its sides. `start`, `end`, `noStart` and `noEnd`
/// follow the text direction, as Flutter's `BorderDirectional`: the start
/// side is the left under left to right and the right under right to left
/// (see [resolve]).
enum StrokeSides {
  all,
  left,
  top,
  right,
  bottom,
  topBottom,
  leftRight,
  topRight,
  bottomRight,
  bottomLeft,
  topLeft,
  noTop,
  noRight,
  noBottom,
  noLeft,

  /// No side: Flutter's `Border()` (every side `BorderSide.none`), CSS
  /// `border-style: none`; for a stroke bound or patched off.
  none,

  /// The start side: Flutter's `BorderDirectional(start: ...)` (a sidebar's
  /// rule against the content, in a layout that can mirror).
  start,

  /// The end side: Flutter's `BorderDirectional(end: ...)`.
  end,

  /// Every side but the start.
  noStart,

  /// Every side but the end.
  noEnd;

  /// Whether its sides follow the text direction ([resolve] places them).
  bool get directional => this == start || this == end || this == noStart || this == noEnd;

  /// The physical sides under a right-to-left ([rtl]) or left-to-right text
  /// direction: [start] is [left] left to right and [right] right to left.
  /// Physical values are themselves.
  StrokeSides resolve({required bool rtl}) => switch (this) {
        start => rtl ? right : left,
        end => rtl ? left : right,
        noStart => rtl ? noRight : noLeft,
        noEnd => rtl ? noLeft : noRight,
        _ => this,
      };

  /// The sides it strokes, of `top`, `right`, `bottom` and `left`.
  Set<String> get sides => switch (this) {
        all => const {'top', 'right', 'bottom', 'left'},
        left => const {'left'},
        top => const {'top'},
        right => const {'right'},
        bottom => const {'bottom'},
        topBottom => const {'top', 'bottom'},
        leftRight => const {'left', 'right'},
        topRight => const {'top', 'right'},
        bottomRight => const {'right', 'bottom'},
        bottomLeft => const {'bottom', 'left'},
        topLeft => const {'top', 'left'},
        noTop => const {'right', 'bottom', 'left'},
        noRight => const {'top', 'bottom', 'left'},
        noBottom => const {'top', 'right', 'left'},
        noLeft => const {'top', 'right', 'bottom'},
        none => const {},
        // Directional sides as left to right; a renderer resolves them first.
        start || end || noStart || noEnd => resolve(rtl: false).sides,
      };
}

/// The shape a [Decoration] paints: Flutter's `BoxShape`.
enum DecorationShape {
  /// The box, its corners rounded by [Decoration.radius].
  rectangle,

  /// A circle the box's shortest side across, in its middle: painted (fill
  /// and stroke) as circles, as Flutter's `BoxShape.circle`.
  circle,
}

/// A box's paint: Flutter's `BoxDecoration`, with stacked paints as in a
/// design tool (fills bottom to top, then strokes).
@immutable
final class Decoration {
  const Decoration({
    this.fills = const [],
    this.foregroundFills = const [],
    this.strokes = const [],
    this.strokeWidth = 1,
    this.strokeAlign = StrokeAlign.inside,
    this.strokeSides = StrokeSides.all,
    this.strokeCap = StrokeCap.butt,
    this.dashPattern = const [],
    this.radius = BorderRadius.zero,
    this.effects = const [],
    this.clip = Clip.none,
    this.blendMode = BlendMode.srcOver,
    this.shape = DecorationShape.rectangle,
    this.clipPath,
  });

  static const Decoration none = Decoration();

  final List<Paint> fills;

  /// Fills painted over the content.
  final List<Paint> foregroundFills;
  final List<Paint> strokes;
  final double strokeWidth;
  final StrokeAlign strokeAlign;
  final StrokeSides strokeSides;
  final StrokeCap strokeCap;

  /// Dash and gap lengths, alternating; empty is a solid stroke.
  final List<double> dashPattern;
  final BorderRadius radius;
  final List<Effect> effects;

  /// Clips the content to the box (rounded by [radius]).
  final Clip clip;
  final BlendMode blendMode;

  /// A rectangle (rounded by [radius]) or a circle.
  final DecorationShape shape;

  /// The node cut to a path, as CSS `clip-path: path(…)` and Flutter's
  /// `ClipPath`: SVG path data in the box's own unit square (0 to 1 across
  /// and down, whatever its size), so the same curve fits the box at every
  /// width (a header's wave, a ticket's notches). Everything the node draws
  /// is cut to it: its fills, border, shadows and children, and a pointer
  /// outside it passes through to what is under. Null: no path.
  final String? clipPath;

  bool get isNone => this == none;
  Iterable<Paint> get visibleFills => fills.where((p) => p.visible);
  Iterable<Paint> get visibleStrokes => strokeWidth <= 0 ? const [] : strokes.where((p) => p.visible);

  Decoration copyWith({
    List<Paint>? fills,
    List<Paint>? foregroundFills,
    List<Paint>? strokes,
    double? strokeWidth,
    StrokeAlign? strokeAlign,
    StrokeSides? strokeSides,
    StrokeCap? strokeCap,
    List<double>? dashPattern,
    BorderRadius? radius,
    List<Effect>? effects,
    Clip? clip,
    BlendMode? blendMode,
    DecorationShape? shape,
    String? clipPath,
  }) =>
      Decoration(
        fills: fills ?? this.fills,
        foregroundFills: foregroundFills ?? this.foregroundFills,
        strokes: strokes ?? this.strokes,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        strokeAlign: strokeAlign ?? this.strokeAlign,
        strokeSides: strokeSides ?? this.strokeSides,
        strokeCap: strokeCap ?? this.strokeCap,
        dashPattern: dashPattern ?? this.dashPattern,
        radius: radius ?? this.radius,
        effects: effects ?? this.effects,
        clip: clip ?? this.clip,
        blendMode: blendMode ?? this.blendMode,
        shape: shape ?? this.shape,
        clipPath: clipPath ?? this.clipPath,
      );

  static Decoration fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return none;
    return Decoration(
      fills: Paint.listFromJson(m['fills']),
      foregroundFills: Paint.listFromJson(m['foregroundFills']),
      strokes: Paint.listFromJson(m['strokes']),
      strokeWidth: (readDouble(m['strokeWidth']) ?? 1).clamp(0, double.infinity).toDouble(),
      strokeAlign: readEnum(StrokeAlign.values, m['strokeAlign'], StrokeAlign.inside),
      strokeSides: readEnum(StrokeSides.values, m['strokeSides'], StrokeSides.all),
      strokeCap: readEnum(StrokeCap.values, m['strokeCap'], StrokeCap.butt),
      dashPattern: [...?readList(m['dashPattern'])?.map(readDouble).nonNulls.where((v) => v >= 0)],
      radius: BorderRadius.fromJson(m['radius']),
      effects: Effect.listFromJson(m['effects']),
      clip: readEnum(Clip.values, m['clip'], Clip.none),
      blendMode: readEnum(BlendMode.values, m['blendMode'], BlendMode.srcOver),
      shape: readEnum(DecorationShape.values, m['shape'], DecorationShape.rectangle),
      clipPath: switch (readString(m['clipPath'])?.trim()) { final String p when p.isNotEmpty => p, _ => null },
    );
  }

  Json toJson() {
    final j = <String, Object?>{};
    if (fills.isNotEmpty) j['fills'] = [for (final p in fills) p.toJson()];
    if (foregroundFills.isNotEmpty) j['foregroundFills'] = [for (final p in foregroundFills) p.toJson()];
    if (strokes.isNotEmpty) {
      j['strokes'] = [for (final p in strokes) p.toJson()];
      put(j, 'strokeWidth', writeDouble(strokeWidth), 1);
      put(j, 'strokeAlign', strokeAlign.name, StrokeAlign.inside.name);
      put(j, 'strokeSides', strokeSides.name, StrokeSides.all.name);
      put(j, 'strokeCap', strokeCap.name, StrokeCap.butt.name);
      if (dashPattern.isNotEmpty) j['dashPattern'] = dashPattern.map(writeDouble).toList();
    }
    if (!radius.isZero) j['radius'] = radius.toJson();
    if (effects.isNotEmpty) j['effects'] = [for (final e in effects) e.toJson()];
    put(j, 'clip', clip.name, Clip.none.name);
    put(j, 'blendMode', blendMode.name, BlendMode.srcOver.name);
    put(j, 'shape', shape.name, DecorationShape.rectangle.name);
    put(j, 'clipPath', clipPath);
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Decoration &&
      listEquals(other.fills, fills) &&
      listEquals(other.foregroundFills, foregroundFills) &&
      listEquals(other.strokes, strokes) &&
      other.strokeWidth == strokeWidth &&
      other.strokeAlign == strokeAlign &&
      other.strokeSides == strokeSides &&
      other.strokeCap == strokeCap &&
      listEquals(other.dashPattern, dashPattern) &&
      other.radius == radius &&
      listEquals(other.effects, effects) &&
      other.clip == clip &&
      other.blendMode == blendMode &&
      other.shape == shape &&
      other.clipPath == clipPath;

  @override
  int get hashCode => Object.hash(Object.hashAll(fills), Object.hashAll(strokes), strokeWidth, strokeAlign,
      strokeSides, radius, Object.hashAll(effects), clip, blendMode, shape, clipPath);
}
