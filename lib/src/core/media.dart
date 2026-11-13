// Media rules: a node's own fields changed by the screen's size, shaped like
// CSS media queries.
//
// `"media": [{"maxWidth": 599, "patch": {"props": {"direction": "vertical"}}}]`
// is `@media (max-width: 599px) { ... }` for this node: while the screen
// meets every condition of a rule, its patch (a JSON merge patch over the
// node, as an interaction state's) applies. Rules apply in order, a later
// one winning where two set the same field, as later CSS rules do. Widths
// are numbers (px) or the name of a project breakpoint (`"tablet"`):
// `minWidth: "tablet"` holds from tablet's min width up, `maxWidth: "tablet"`
// up to the last width before the next breakpoint (tablet and narrower).
import 'package:meta/meta.dart';

import 'breakpoints.dart';
import 'json.dart';

/// CSS `orientation`: portrait when the screen is at least as tall as wide.
enum MediaOrientation { portrait, landscape }

/// One media rule of a node: [patch] applies while the screen meets every
/// condition given ([minWidth], [maxWidth], [orientation]).
@immutable
final class MediaRule {
  const MediaRule({this.minWidth, this.maxWidth, this.orientation, this.patch = const {}});

  /// CSS `min-width`: a width in px (inclusive), or a breakpoint name (from
  /// its min width).
  final Object? minWidth;

  /// CSS `max-width`: a width in px (inclusive), or a breakpoint name (up to
  /// the next breakpoint's min width, exclusive).
  final Object? maxWidth;

  /// CSS `orientation`.
  final MediaOrientation? orientation;

  /// A JSON merge patch over the node (maps merge, `null` removes, anything
  /// else replaces): `props`, `layout`, `decoration`, `visible`, `opacity`.
  final Json patch;

  /// The keys a patch may set.
  static const patchKeys = {'props', 'layout', 'decoration', 'visible', 'opacity'};

  /// The condition keys a rule may have (at least one).
  static const conditionKeys = {'minWidth', 'maxWidth', 'orientation'};

  /// The lowest width [minWidth] admits, or null (no bound, or a name that
  /// isn't a breakpoint: see [unknownNames]).
  double? lowest(Breakpoints breakpoints) => switch (minWidth) {
        final num n => n.toDouble(),
        final String s => breakpoints.find(s)?.minWidth,
        _ => null,
      };

  /// The width [maxWidth] admits widths below (exclusive), or null: a
  /// number n admits up to n inclusive; a breakpoint name, up to the next
  /// breakpoint's min width.
  double? below(Breakpoints breakpoints) {
    switch (maxWidth) {
      case final num n:
        return n.toDouble();
      case final String s:
        final b = breakpoints.find(s);
        if (b == null) return null;
        final i = breakpoints.indexOf(b.id);
        return i + 1 < breakpoints.list.length ? breakpoints.list[i + 1].minWidth : double.infinity;
    }
    return null;
  }

  /// The breakpoint names this rule uses that [breakpoints] doesn't have.
  List<String> unknownNames(Breakpoints breakpoints) => [
        for (final v in [minWidth, maxWidth])
          if (v is String && breakpoints.find(v) == null) v,
      ];

  /// Whether the rule holds on a screen [width] × [height] (a rule naming
  /// an unknown breakpoint never holds).
  bool holds(double width, double? height, Breakpoints breakpoints) {
    if (unknownNames(breakpoints).isNotEmpty) return false;
    final lo = lowest(breakpoints);
    if (lo != null && width < lo) return false;
    if (maxWidth is num) {
      if (width > (maxWidth as num)) return false;
    } else if (below(breakpoints) case final double hi when width >= hi) {
      return false;
    }
    if (orientation != null) {
      if (height == null) return false;
      final o = height >= width ? MediaOrientation.portrait : MediaOrientation.landscape;
      if (o != orientation) return false;
    }
    return minWidth != null || maxWidth != null || orientation != null;
  }

  /// The condition as CSS (`(min-width: tablet) and (orientation: portrait)`).
  String get conditionText => [
        if (minWidth != null) '(min-width: $minWidth)',
        if (maxWidth != null) '(max-width: $maxWidth)',
        if (orientation != null) '(orientation: ${orientation!.name})',
      ].join(' and ');

  static Object? _width(Object? v) => v is num ? v.toDouble() : (v is String && v.isNotEmpty ? v : null);

  static MediaRule? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return MediaRule(
      minWidth: _width(m['minWidth']),
      maxWidth: _width(m['maxWidth']),
      orientation: MediaOrientation.values.where((o) => o.name == m['orientation']).firstOrNull,
      patch: readMap(m['patch']) ?? const {},
    );
  }

  static List<MediaRule> listFromJson(Object? json) => [
        for (final e in readList(json) ?? const []) ?MediaRule.fromJson(e),
      ];

  Json toJson() => {
        if (minWidth != null) 'minWidth': minWidth is double ? writeDouble(minWidth as double) : minWidth,
        if (maxWidth != null) 'maxWidth': maxWidth is double ? writeDouble(maxWidth as double) : maxWidth,
        if (orientation != null) 'orientation': orientation!.name,
        'patch': patch,
      };

  @override
  bool operator ==(Object other) =>
      other is MediaRule &&
      other.minWidth == minWidth &&
      other.maxWidth == maxWidth &&
      other.orientation == orientation &&
      jsonEquality.equals(other.patch, patch);

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, orientation, jsonEquality.hash(patch));
}

/// The merged patch of the [rules] that hold on a screen [width] ×
/// [height]: in order, a later one winning where two set the same field;
/// keys outside [MediaRule.patchKeys] left out. Null when none holds.
Json? mediaPatchAt(List<MediaRule> rules, double width, double? height, Breakpoints breakpoints) {
  Json? out;
  for (final r in rules) {
    if (!r.holds(width, height, breakpoints)) continue;
    final own = {for (final e in r.patch.entries) if (MediaRule.patchKeys.contains(e.key)) e.key: e.value};
    if (own.isEmpty) continue;
    out = out == null ? own : _merge(out, own);
  }
  return out;
}

Json _merge(Json a, Json b) {
  final out = <String, Object?>{...a};
  for (final e in b.entries) {
    final cur = out[e.key];
    out[e.key] = e.value is Map && cur is Map ? _merge(cur.cast<String, Object?>(), (e.value as Map).cast<String, Object?>()) : e.value;
  }
  return out;
}
