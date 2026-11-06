/// Checks a compiled screen against its kit: whether every color, font and
/// corner radius in the node trees comes from the kit's tokens.
library;

import 'design_kit.dart';
import 'screen_compiler.dart';

/// The result of [checkOnBrand].
class BrandCheck {
  /// Values checked, per kind (`color`, `type`, `radius`).
  final Map<String, int> checked;

  /// Values that are not kit tokens, with where they are.
  final List<String> offBrand;

  /// Creates a [BrandCheck].
  const BrandCheck(this.checked, this.offBrand);

  /// Share of values that are kit tokens, 0-1.
  double get score {
    final int total = checked.values.fold(0, (int a, int b) => a + b);
    return total == 0 ? 1 : (total - offBrand.length) / total;
  }

  /// Whether everything is on-brand.
  bool get passed => offBrand.isEmpty;

  Map<String, Object> toJson() => {
    'score': double.parse(score.toStringAsFixed(4)),
    'checked': checked,
    'offBrand': offBrand.take(20).toList(),
  };
}

/// Walks every breakpoint tree of [screen] and checks colors (fills,
/// strokes, text, icons, shadows, colors inside bindings), text styles
/// (family, size and weight together) and corner radii against [kit].
BrandCheck checkOnBrand(CompiledScreen screen, DesignKit kit) {
  final Set<String> palette = <String>{
    for (final KitColor c in kit.palette) ...<String>[c.rgbHex, c.nodeHex],
    '#00000000',
  };
  final Set<String> type = <String>{
    for (final KitTextStyle t in kit.typography.values) '${t.family}/${kitNum(t.size)}/w${t.weight}',
  };
  final Set<double> radii = <double>{...kit.radius.values, 0};
  final double pill = kit.radius.values.fold(0, (double a, double b) => a > b ? a : b);
  final Map<String, int> checked = <String, int>{'color': 0, 'type': 0, 'radius': 0};
  final List<String> off = <String>[];

  void color(Object? value, String where) {
    if (value is! String || !value.startsWith('#')) return;
    checked['color'] = checked['color']! + 1;
    if (!palette.contains(value.toUpperCase())) off.add('color $value at $where');
  }

  void paints(Object? list, String where) {
    if (list is! List) return;
    for (final Object? p in list) {
      if (p is Map && p['type'] == 'solid') color(p['color'], where);
    }
  }

  void walk(Object? node, String where) {
    if (node is Map) {
      final String name = '$where/${node['name'] ?? node['type'] ?? ''}';
      paints(node['fills'], name);
      paints(node['strokes'], name);
      final Object? effects = node['effects'];
      if (effects is List) {
        for (final Object? e in effects) {
          if (e is Map) color(e['color'], name);
        }
      }
      final Object? props = node['textMixedProps'];
      if (props is List) {
        for (final Object? p in props) {
          if (p is! Map) continue;
          paints(p['fills'], name);
          final Object? font = p['fontName'];
          if (font is Map) {
            checked['type'] = checked['type']! + 1;
            final String key = '${font['family']}/${kitNum(p['fontSize'] as num)}/${font['weight']}';
            if (!type.contains(key)) off.add('type $key at $name');
          }
        }
      }
      final Object? icon = node['properties'] is Map ? (node['properties'] as Map)['icon'] : null;
      if (icon is Map) color(icon['color'], name);
      final Object? radius = node['cornerRadius'];
      if (radius is List && radius.isNotEmpty && radius.first is num) {
        final double r = (radius.first as num).toDouble();
        checked['radius'] = checked['radius']! + 1;
        final List<dynamic> box = (node['basicBoxLocal'] as List?) ?? const [];
        final double half = box.length == 4 ? ((box[2] as num) < (box[3] as num) ? box[2] as num : box[3] as num) / 2 : 0;
        // A pill clamped to a small box is still the pill token.
        final bool clampedPill = pill >= 999 && (r - half).abs() < 0.5;
        if (!radii.contains(r) && !clampedPill && name.contains('Skeleton') == false) {
          off.add('radius $r at $name');
        }
      }
      // Colors chosen by a formula are kit colors too.
      final Object? vars = node['variables'];
      if (vars is Map) {
        for (final Object? v in vars.values) {
          if (v is String) {
            for (final Match m in RegExp('#[0-9A-Fa-f]{6,8}').allMatches(v)) {
              color(m[0], '$name (binding)');
            }
          }
        }
      }
      for (final MapEntry<dynamic, dynamic> e in node.entries) {
        if (e.key == 'children' || e.key == 'content') walk(e.value, name);
        if (e.key == 'variants') walk(e.value, name);
      }
    } else if (node is List) {
      for (final Object? n in node) {
        walk(n, where);
      }
    }
  }

  for (final MapEntry<String, Map<String, dynamic>> tree in screen.trees.entries) {
    walk(tree.value, tree.key);
  }
  return BrandCheck(checked, off);
}
