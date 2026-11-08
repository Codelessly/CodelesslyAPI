// v1 breakpoints → v2's project breakpoints (CodelesslyAPI/v2/DESIGN.md §5.3).
//
// v1 has no project set: the screen size classes were the fixed
// `ScreenBreakpoint`s (mobile, tablet, desktop at 0, 600, 1024), which are
// v2's default project breakpoints, with the same ids. So a v1 project gets
// the defaults, and what v1 set locally stays local: a responsive node's own
// switch widths become its `minWidths`, and a layout group's canvas ranges
// become each canvas's breakpoint (the one its lower bound falls in) and,
// when its lower bound isn't that breakpoint's, its own switch point.
import 'package:codelessly_api/codelessly_api.dart' show ScreenBreakpoint;

typedef _Json = Map<String, Object?>;

/// A responsive variance's v1 `tabletMinWidth` / `desktopMinWidth` as v2
/// `minWidths` (breakpoint id → width); empty when it has none.
Map<String, num> varianceMinWidths({double? tabletMinWidth, double? desktopMinWidth}) => {
      if (tabletMinWidth != null && tabletMinWidth != ScreenBreakpoint.tablet.minWidth)
        ScreenBreakpoint.tablet.name: _round(tabletMinWidth),
      if (desktopMinWidth != null && desktopMinWidth != ScreenBreakpoint.desktop.minWidth)
        ScreenBreakpoint.desktop.name: _round(desktopMinWidth),
    };

/// The v2 breakpoint entry of a canvas whose v1 range starts at [lowerBound]:
/// `{canvas, breakpoint, minWidth?}` (`minWidth` when it isn't the
/// breakpoint's).
_Json canvasBreakpoint(String canvasId, num lowerBound) {
  final bp = ScreenBreakpoint.forWidth(lowerBound.toDouble());
  return {
    'canvas': canvasId,
    'breakpoint': bp.name,
    if (lowerBound != bp.minWidth) 'minWidth': _round(lowerBound),
  };
}

/// Gives the canvases of each v1 layout group in v2 document [doc] (its
/// `nodes`) their breakpoint and screen: [groups] is v1's page metadata
/// `breakpoints` (group id → `[{nodeId, lowerBound, upperBound}]`). A group
/// of one canvas is a screen of its own and gets nothing. Returns each
/// group's entries, narrowest first, as a published layout lists them.
Map<String, List<_Json>> migrateLayoutGroups(_Json doc, Object? groups) {
  final nodes = doc['nodes'];
  final out = <String, List<_Json>>{};
  if (nodes is! Map || groups is! Map) return out;
  for (final g in groups.entries) {
    final entries = [
      for (final b in (g.value is List ? g.value as List : const []))
        if (b is Map && b['nodeId'] is String && nodes[b['nodeId']] is Map) b,
    ]..sort((a, b) => _num(a['lowerBound']).compareTo(_num(b['lowerBound'])));
    if (entries.length < 2) continue;
    final list = <_Json>[];
    for (final b in entries) {
      final id = b['nodeId'] as String;
      final e = canvasBreakpoint(id, _num(b['lowerBound']));
      list.add(e);
      final node = (nodes[id] as Map).cast<String, Object?>();
      final props = {...?(node['props'] as Map?)?.cast<String, Object?>()};
      props['breakpoint'] = e['breakpoint'];
      props['screen'] = '${g.key}';
      if (e['minWidth'] != null) props['breakpointMinWidth'] = e['minWidth'];
      nodes[id] = {...node, 'props': props};
    }
    out['${g.key}'] = list;
  }
  return out;
}

num _num(Object? v) => v is num && v.isFinite ? v : 0;

num _round(num v) {
  final r = (v * 10000).roundToDouble() / 10000;
  return r == r.roundToDouble() ? r.toInt() : r;
}
