import 'package:meta/meta.dart';

import 'json.dart';
import 'values/enums.dart';
import 'values/geometry.dart';
import 'values/paint.dart';

/// Which sides a stroke draws.
/// Which sides a box's stroke runs along: every side (rounded with the
/// corners), one side, or a pair of opposite sides (a ruled band).
enum StrokeSides { all, left, top, right, bottom, topBottom, leftRight }

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
      other.blendMode == blendMode;

  @override
  int get hashCode => Object.hash(Object.hashAll(fills), Object.hashAll(strokes), strokeWidth, strokeAlign,
      strokeSides, radius, Object.hashAll(effects), clip, blendMode);
}
