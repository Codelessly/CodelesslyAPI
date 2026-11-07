// v1 → v2 migrations: collections widgets. See TypeMigration in ../migrate.dart.
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';

import '../migrate.dart';

/// By v1 node type.
final Map<String, TypeMigration> collectionsMigrations = {
  'listView': TypeMigration(type: (_) => 'listView', props: _listView),
  'gridView': TypeMigration(type: (_) => 'gridView', props: _gridView),
  'pageView': TypeMigration(type: (_) => 'pageView', props: _pageView),
  'tabs': TypeMigration(type: (_) => 'tabs', props: _tabs),
  'tabBar': TypeMigration(type: (_) => 'tabBar', props: _tabBar),
  'accordion': TypeMigration(type: (_) => 'accordion', props: _accordion),
  'expansionTile': TypeMigration(
    type: (_) => 'expansionTile',
    props: _expansionTile,
    children: (m) {
      final n = m.n as ExpansionTileNode;
      return [
        for (final c in n.children)
          if (c != n.listTileChild) c,
      ];
    },
    slots: (m) {
      final tile = (m.n as ExpansionTileNode).listTileChild;
      return {if (tile != null && m.nodes.containsKey(tile)) 'tile': tile};
    },
  ),
};

/// Editor metadata: what may be dropped into the node.
const _editorKeys = ['allowedTypes', 'deniedTypes', 'useFlutterListView', 'ephemeral'];

void _takeAll(V1Node m, List<String> keys) {
  for (final k in keys) {
    m.take(k);
  }
}

num _r(num v) => roundNum(v);

String? _physics(ScrollPhysicsC p) => switch (p) {
  ScrollPhysicsC.bouncingScrollPhysics => 'bouncing',
  ScrollPhysicsC.clampingScrollPhysics => 'clamping',
  ScrollPhysicsC.neverScrollableScrollPhysics => 'never',
  ScrollPhysicsC.rangeMaintainingScrollPhysics => 'rangeMaintaining',
  _ => null,
};

/// The ScrollView parameters every scrolling collection shares.
Json _scroll(V1Node m, ScrollableMixin s, {required bool clips}) {
  _takeAll(m, const [
    'isScrollable', 'scrollDirection', 'reverse', 'physics', 'primary', 'keyboardDismissBehavior', //
    'shouldAlwaysScroll', 'clipsContent', 'shrinkWrap',
  ]);
  _takeAll(m, _editorKeys);
  return {
    if (s.scrollDirection != AxisC.vertical) 'scrollDirection': s.scrollDirection.name,
    if (s.reverse) 'reverse': true,
    if (_physics(s.physics) case final String p) 'physics': p,
    if (!s.shouldAlwaysScroll) 'alwaysScroll': false,
    if (s.primary) 'primary': true,
    if (s.keyboardDismissBehavior == ScrollViewKeyboardDismissBehaviorC.onDrag) 'keyboardDismissBehavior': 'onDrag',
    if (!clips) 'clipBehavior': 'none',
  };
}

/// A cloud query (runtime only), kept whole.
Json _query(V1Node m, QueryableMixin q, VariableData? status) {
  _takeAll(m, const [
    'useCloudDatabase', 'collectionPath', 'limit', 'whereFilters', 'orderByFilters', 'paging', 'loadRelated', //
    'statusVariable',
  ]);
  if (!q.useCloudDatabase && (q.collectionPath ?? '').isEmpty) return {};
  final raw = m.raw;
  return {
    'query': {
      if (q.useCloudDatabase) 'enabled': true,
      for (final k in const ['collectionPath', 'limit', 'whereFilters', 'orderByFilters', 'paging', 'loadRelated'])
        if (raw[k] != null) k: raw[k],
      if (status != null) 'statusVariable': status.toJson(),
    },
  };
}

/// Whether a v1 list knows its item count (a set count or bound data, and no
/// cloud query): SDK 8.x's `listHasKnownItemCount`.
bool _knownCount(ListViewNode n) =>
    !n.useCloudDatabase && (n.variables['data'] != null || n.properties.itemCount != null);

Json _listView(V1Node m) {
  final n = m.n as ListViewNode;
  final p = n.properties;
  m.take('properties');
  final out = <String, Object?>{..._scroll(m, n, clips: n.clipsContent), ..._query(m, n, n.statusVariable)};
  if (!n.isScrollable) out['scrollable'] = false;
  if (p.itemCount != null) out['itemCount'] = p.itemCount;
  if (p.itemExtent != null) out['itemExtent'] = _r(p.itemExtent!);
  if (p.cacheExtent != null) out['cacheExtent'] = _r(p.cacheExtent!);

  // SDK 8.x has two wrapping layouts. With a wrap or run spacing of its own,
  // the list always wraps (no items while its count is unknown); otherwise
  // it wraps only when its count is known, spaced by its separator.
  final isWrapping = p.wrap && !p.stacked && p.layout == ListLayout.list;
  final ownSpacing = isWrapping && (p.wrapSpacing != 0 || p.wrapRunSpacing != 0);
  final wraps = ownSpacing || (isWrapping && _knownCount(n));
  if (wraps) {
    out['wrap'] = true;
    final spacing = ownSpacing ? p.wrapSpacing : (p.hasSeparator ? math.max(0.0, p.separatorSpacing) : 0.0);
    final run = ownSpacing ? p.wrapRunSpacing : math.max(0.0, p.runSpacing);
    if (spacing != 0) out['wrapSpacing'] = _r(spacing);
    if (run != 0) out['runSpacing'] = _r(run);
    if (p.wrapAlignment != MainAxisAlignmentC.start) out['wrapAlignment'] = p.wrapAlignment.name;
    if (ownSpacing && p.wrapCrossAlignment != CrossAxisAlignmentC.start) {
      out['wrapCrossAlignment'] = p.wrapCrossAlignment == CrossAxisAlignmentC.end ? 'end' : 'center';
    }
  } else if (p.hasSeparator) {
    out['separator'] = p.separator.name;
    if (p.separatorSpacing != 0) out['spacing'] = _r(p.separatorSpacing);
  }
  if (!wraps && p.hasSeparator && p.separator == ListItemSeparator.divider) {
    final d = p.dividerProperties;
    if (d.thickness != 1) out['dividerThickness'] = _r(d.thickness);
    final color = V1Node.rgba(d.color);
    if (color != '#FF000000') out['dividerColor'] = color;
    if (d.indent != 0) out['dividerIndent'] = _r(d.indent);
    if (d.endIndent != 0) out['dividerEndIndent'] = _r(d.endIndent);
  }
  if (p.stacked) {
    out['layout'] = 'deck';
  } else if (p.layout == ListLayout.stack) {
    out['layout'] = 'stack';
    final item = n.children.isEmpty ? null : m.nodes[n.children.first];
    if (item != null) {
      final inner = n.innerBoxLocal;
      out['itemPosition'] = [_r(item.outerBoxLocal.x - inner.edgeLeft), _r(item.outerBoxLocal.y - inner.edgeTop)];
    }
  }
  if (p.reversePaintOrder) out['reversePaintOrder'] = true;
  if (p.stretchItems && !p.stacked && p.layout == ListLayout.list) out['stretchItems'] = true;
  return out;
}

Json _gridView(V1Node m) {
  final n = m.n as GridViewNode;
  final p = n.properties;
  m.take('properties');
  final d = p.gridDelegate;
  return {
    ..._scroll(m, n, clips: n.clipsContent),
    ..._query(m, n, n.statusVariable),
    if (p.itemCount != null) 'itemCount': p.itemCount,
    if (p.cacheExtent != null) 'cacheExtent': _r(p.cacheExtent!),
    ...switch (d) {
      FixedCrossAxisCountGridDelegateProperties(:final crossAxisCount) when crossAxisCount != 2 => {
        'crossAxisCount': math.max(1, crossAxisCount),
      },
      MaxCrossAxisExtentGridDelegateProperties(:final maxCrossAxisExtent) => {
        'maxCrossAxisExtent': _r(maxCrossAxisExtent),
      },
      _ => const <String, Object?>{},
    },
    if (d.mainAxisSpacing != 0) 'mainAxisSpacing': _r(d.mainAxisSpacing),
    if (d.crossAxisSpacing != 0) 'crossAxisSpacing': _r(d.crossAxisSpacing),
    if (d.childAspectRatio != 1) 'childAspectRatio': d.childAspectRatio,
    if (d.mainAxisExtent != null) 'mainAxisExtent': _r(d.mainAxisExtent!),
    if (d.shrinkWrapRows) 'shrinkWrapRows': true,
  };
}

Json _pageView(V1Node m) {
  final n = m.n as PageViewNode;
  final p = n.properties;
  m.take('properties');
  final scroll = _scroll(m, n, clips: n.clipsContent)
    ..remove('primary')
    ..remove('keyboardDismissBehavior');
  return {
    ...scroll,
    if (p.itemCount != null) 'itemCount': p.itemCount,
    if (!p.pageSnapping) 'pageSnapping': false,
    if (!p.padEnds) 'padEnds': false,
    if (!p.keepPage) 'keepPage': false,
    if (p.initialPage != 0) 'initialPage': math.max(0, p.initialPage),
    if (p.viewportFraction != 1) 'viewportFraction': p.viewportFraction,
    if (p.allowImplicitScrolling) 'allowImplicitScrolling': true,
    if (p.animationDurationMs != 0) 'animationDuration': p.animationDurationMs,
    if (p.animationCurve.name != 'easeOutCubic') 'animationCurve': p.animationCurve.name,
  };
}

Json _tabs(V1Node m) {
  final n = m.n as TabsNode;
  m.take('tabs');
  // Written at their defaults by TabsNode.toJson (a tab container is always
  // enabled; the aspect lock is editor state).
  m.take('enabled');
  m.take('aspectRatioLock');
  return {
    'titles': [for (final t in n.tabs) t.title],
  };
}

Json _icon(MultiSourceIconModel icon) => {
  'source': icon.type.name,
  if (icon.icon?.toJson() case final Map j) ...j.cast<String, Object?>(),
  if (icon.iconImage != null) 'image': icon.iconImage,
  if (!icon.show) 'show': false,
  if (icon.size != null) 'size': icon.size,
  if (icon.color case final ColorRGBA c) 'color': V1Node.rgba(c),
};

Json _tabBar(V1Node m) {
  final n = m.n as TabBarNode;
  final p = n.properties;
  _takeAll(m, const [
    'properties', 'initialIndex', 'isScrollable', 'scrollDirection', 'reverse', 'physics', 'primary', //
    'keyboardDismissBehavior', 'shouldAlwaysScroll', 'shrinkWrap', 'useFlutterListView',
  ]);
  String? color(ColorRGBA? c) => c == null ? null : V1Node.rgba(c);
  Object insets(EdgeInsetsModel e) => V1Node.insets(e);
  final r = p.indicatorCornerRadius;
  return {
    'tabs': [
      for (final t in p.tabs) {'id': t.id, 'label': t.label, 'icon': _icon(t.icon)},
    ],
    if (n.initialIndex != 0) 'initialIndex': math.max(0, n.initialIndex),
    if (n.isScrollable) 'isScrollable': true,
    if (_physics(n.physics) case final String ph) 'physics': ph,
    if (color(p.indicatorColor) != '#FF000000') 'indicatorColor': color(p.indicatorColor),
    if (p.indicatorWeight != 2) 'indicatorWeight': _r(p.indicatorWeight),
    if (p.indicatorSize.name != 'label') 'indicatorSize': p.indicatorSize.name,
    if (p.indicatorPadding != EdgeInsetsModel.zero) 'indicatorPadding': insets(p.indicatorPadding),
    if (p.indicatorStyle.name != 'underline') 'indicatorStyle': p.indicatorStyle.name,
    if (p.indicatorShape.name != 'roundedRectangle') 'indicatorShape': p.indicatorShape.name,
    if (r.tl.x != 0 || r.tr.x != 0 || r.br.x != 0 || r.bl.x != 0)
      'indicatorRadius': [_r(r.tl.x), _r(r.tr.x), _r(r.br.x), _r(r.bl.x)],
    if (color(p.labelColor) != '#FF000000') 'labelColor': color(p.labelColor),
    if (color(p.unselectedLabelColor) != '#FF000000') 'unselectedLabelColor': color(p.unselectedLabelColor),
    'labelStyle': V1Node.textStyle(p.labelStyle),
    'unselectedLabelStyle': V1Node.textStyle(p.unselectedLabelStyle),
    if (p.labelPadding != EdgeInsetsModel.zero) 'labelPadding': insets(p.labelPadding),
    if (color(p.overlayColor) case final String c) 'overlayColor': c,
    // A hidden divider is a transparent one of no height.
    if (!p.showDivider) ...{
      'dividerColor': '#00000000',
      'dividerHeight': 0,
    } else ...{
      if (color(p.dividerColor) != '#FF000000') 'dividerColor': color(p.dividerColor),
      if (p.dividerHeight != null) 'dividerHeight': _r(p.dividerHeight!),
    },
    if (p.tabAlignment != null) 'tabAlignment': p.tabAlignment!.name,
    if (p.contentType != TabBarContentType.labelAndIcon) 'content': p.contentType.name,
    if (p.tabItemDirection != AxisC.horizontal) 'iconDirection': p.tabItemDirection.name,
    if (p.gap != 10) 'gap': _r(p.gap),
  };
}

Json _rowColumn(V1Node m) {
  final rc = m.n as RowColumnMixin;
  _takeAll(m, const ['rowColumnType', 'mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'wrap', 'runSpacing']);
  return {
    if (rc.mainAxisAlignment != MainAxisAlignmentC.start) 'mainAxisAlignment': rc.mainAxisAlignment.name,
    if (rc.crossAxisAlignment != CrossAxisAlignmentC.center) 'crossAxisAlignment': rc.crossAxisAlignment.name,
  };
}

Json _accordion(V1Node m) {
  final n = m.n as AccordionNode;
  m.take('properties');
  m.take('isExpanded');
  return {..._rowColumn(m), if (!n.properties.isExpanded) 'expanded': false};
}

Json _expansionTile(V1Node m) {
  final n = m.n as ExpansionTileNode;
  final p = n.properties;
  _takeAll(m, const ['properties', 'isExpanded', 'listTileChild']);
  _rowColumn(m);
  String? color(ColorRGBA? c) => c == null ? null : V1Node.rgba(c);
  final r = p.cornerRadius;
  final align = p.expandedAlignment.data;
  return {
    if (p.initiallyExpanded) 'initiallyExpanded': true,
    if (p.maintainState) 'maintainState': true,
    if (color(p.backgroundColor) case final String c) 'backgroundColor': c,
    if (color(p.collapsedBackgroundColor) case final String c) 'collapsedBackgroundColor': c,
    if (p.tilePadding case final EdgeInsetsModel e) 'tilePadding': V1Node.insets(e),
    if (p.childrenPadding case final EdgeInsetsModel e) 'childrenPadding': V1Node.insets(e),
    if (align != null) 'expandedAlignment': [_r(align.x), _r(align.y)],
    'expandedCrossAxisAlignment': p.expandedCrossAxisAlignment.name,
    if (color(p.iconColor) case final String c) 'iconColor': c,
    if (color(p.collapsedIconColor) case final String c) 'collapsedIconColor': c,
    if (color(p.textColor) case final String c) 'textColor': c,
    if (color(p.collapsedTextColor) case final String c) 'collapsedTextColor': c,
    if (p.controlAffinity != null) 'controlAffinity': p.controlAffinity!.name,
    if (p.visualDensity.horizontal != 0 || p.visualDensity.vertical != 0)
      'visualDensity': [p.visualDensity.horizontal, p.visualDensity.vertical],
    if (!p.showDividers) 'showDividers': false,
    if (!p.showTrailingIcon) 'showTrailingIcon': false,
    if (p.shape != null) 'shape': p.shape!.name,
    if (p.collapsedShape != null) 'collapsedShape': p.collapsedShape!.name,
    if (!isSquare(r)) 'radius': radiusJson(r),
  };
}
