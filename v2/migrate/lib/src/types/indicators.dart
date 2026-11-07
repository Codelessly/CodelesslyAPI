// v1 → v2 migrations: indicators widgets. See TypeMigration in ../migrate.dart.
//
// The v1 nodes keep their settings in a `properties` object. Its JSON is
// sparse (v1 omits defaults), so a key is written to v2 when v1 stored it;
// where v2's default differs from v1's (Flutter's defaults, empty lists in
// place of v1's sample content) the decoded value is written always.
// Property keys no handler reads are reported as `type.properties.key`.
import 'package:codelessly_api/codelessly_api.dart';

import '../migrate.dart';

/// Reads one v1 `properties` object into v2 props.
class _Props {
  _Props(this.m, this.label, Map json) : present = {for (final k in json.keys) '$k'};

  final V1Node m;
  final String label;
  final Set<String> present;
  final Set<String> used = {};
  final Json out = {};

  /// Writes [value] as [v2] (default [v1]) when v1 stored [v1].
  void put(String v1, Object? value, [String? v2]) {
    used.add(v1);
    if (present.contains(v1) && value != null) out[v2 ?? v1] = value;
  }

  /// Writes [value] whether v1 stored it or not (its default differs in v2).
  void always(String v1, Object? value, [String? v2]) {
    used.add(v1);
    if (value != null) out[v2 ?? v1] = value;
  }

  /// [v1] has no v2 counterpart (v1 ignored it too).
  void drop(String v1) => used.add(v1);

  Json done() {
    for (final k in present.difference(used)) {
      m.report.unmapped.update('$label.properties.$k', (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }
}

num _n(num v) => roundNum(v);
num? _on(num? v) => v == null ? null : roundNum(v);
String _c(ColorRGBA c) => V1Node.rgba(c);
String? _oc(ColorRGBA? c) => c == null ? null : V1Node.rgba(c);

Object _radius(CornerRadius r) => radiusJson(r);

/// Node-level fields a type keeps outside `properties`.
void _takeNodeKeys(V1Node m, Json p, Map<String, String> keys) {
  for (final e in keys.entries) {
    final v = m.take(e.key);
    if (v != null) p[e.value] = v is num ? _n(v) : v;
  }
}

// --- loading indicator ----------------------------------------------------------

Json _loadingIndicator(V1Node m) {
  final n = m.n as LoadingIndicatorNode;
  final props = n.properties;
  final p = _Props(m, n.type, props.toJson());
  p.drop('type');
  if (props is MaterialLoadingIndicatorProperties) {
    p.always('color', _c(props.color));
    // v1 passed its transparent default; v2's null is the theme's track.
    p.always('backgroundColor', _c(props.backgroundColor));
    p.put('strokeWidth', _n(props.strokeWidth));
    p.put('value', _on(props.value));
    p.always('strokeCap', props.strokeCap == StrokeCapEnum.none ? 'butt' : props.strokeCap.name);
    p.put('strokeAlign', _on(props.strokeAlign));
    p.put('trackGap', _on(props.trackGap));
    p.put('startAngle', _n(props.startAngle));
    p.put('sweepAngle', _n(props.sweepAngle));
  } else if (props is CupertinoLoadingIndicatorProperties) {
    p.always('color', _c(props.color));
    // SDK 8.x drew it with half the node's width as its radius.
    p.drop('radius');
    p.out['radius'] = _n((n.basicBoxLocal.width ~/ 2).toDouble());
  }
  return p.done();
}

String _loadingType(BaseNode n) => (n as LoadingIndicatorNode).properties is CupertinoLoadingIndicatorProperties
    ? 'activityIndicator'
    : 'circularProgressIndicator';

// --- progress bar ---------------------------------------------------------------

Json _progressBar(V1Node m) {
  final n = m.n as ProgressBarNode;
  final out = <String, Object?>{};
  _takeNodeKeys(m, out, {'currentValue': 'value'});
  final props = n.properties;
  final p = _Props(m, n.type, props.toJson());
  p.put('maxValue', _n(props.maxValue), 'max');
  p.put('backgroundColor', _c(props.backgroundColor));
  p.put('progressColor', _c(props.progressColor), 'color');
  p.put('isVertical', props.isVertical ? 'vertical' : null, 'direction');
  p.put('cornerRadius', _radius(props.cornerRadius), 'borderRadius');
  p.put('animate', props.animate);
  p.put('animationDurationInMillis', props.animationDurationInMillis, 'animationDuration');
  p.put('shape', props.shape.name);
  p.put('arcStartAngle', _n(props.arcStartAngle));
  p.put('arcSweepAngle', _n(props.arcSweepAngle));
  p.put('arcStrokeWidth', _n(props.arcStrokeWidth));
  p.put('needleColor', _oc(props.needleColor));
  p.put('tickCount', props.tickCount);
  p.put('tickColor', _c(props.tickColor));
  p.put('bands', [
    for (final b in props.bands) {'start': _n(b.start), 'end': _n(b.end), 'color': _c(b.color)},
  ]);
  p.put('arcFit', props.arcFit.name);
  p.put('arcRoundCaps', props.arcRoundCaps);
  p.put('progressEndColor', _oc(props.progressEndColor));
  p.put('arcGlow', _n(props.arcGlow));
  p.put('arcHeadDot', props.arcHeadDot);
  return {...out, ...p.done()};
}

// --- gauges ---------------------------------------------------------------------

String _gaugeType(BaseNode n) => n is GaugeNode ? 'radialGauge' : 'gaugeMeter';

Json _gauge(V1Node m) {
  m.take('gaugeKind');
  final out = <String, Object?>{};
  if (m.n case final GaugeNode n) {
    _takeNodeKeys(m, out, {'value': 'value'});
    final g = n.properties;
    final p = _Props(m, 'gauge', g.toJson());
    p.put('min', _n(g.min));
    p.put('max', _n(g.max));
    p.put('startAngle', _n(g.startAngle));
    p.put('sweepAngle', _n(g.sweepAngle));
    p.put('thickness', _n(g.thickness));
    p.put('trackColor', _c(g.trackColor));
    p.put('valueColor', _c(g.valueColor));
    p.put('colorByZone', g.colorByZone);
    p.put('segments', g.segments);
    p.put('segmentGap', _n(g.segmentGap));
    // v1's default zones are content; v2's default is none.
    p.always('zones', [
      for (final z in g.zones) {'from': _n(z.from), 'to': _n(z.to), 'color': _c(z.color)},
    ]);
    if ((p.out['zones'] as List).isEmpty) p.out.remove('zones');
    p.put('zoneThickness', _n(g.zoneThickness));
    p.put('zoneOpacity', _n(g.zoneOpacity));
    p.put('majorTicks', g.majorTicks);
    p.put('minorTicks', g.minorTicks);
    p.put('tickColor', _c(g.tickColor));
    p.put('labels', [for (final l in g.labels) _n(l)]);
    p.put('labelColor', _c(g.labelColor));
    p.put('labelFontSize', _n(g.labelFontSize));
    p.put('labelFontFamily', g.labelFontFamily);
    p.put('showTarget', g.showTarget);
    p.put('target', _n(g.target));
    p.put('targetColor', _c(g.targetColor));
    p.put('showNeedle', g.showNeedle);
    p.put('needleColor', _c(g.needleColor));
    p.put('needleClearance', _n(g.needleClearance));
    p.put('animate', g.animate);
    p.put('animationDurationInMillis', g.animationDurationInMillis, 'animationDuration');
    return {...out, ...p.done()};
  }
  final n = m.n as GaugeMeterNode;
  _takeNodeKeys(m, out, {'value': 'value', 'limit': 'limit'});
  final g = n.properties;
  final p = _Props(m, 'gauge', g.toJson());
  p.put('shape', g.shape.name);
  p.put('min', _n(g.min));
  p.put('max', _n(g.max));
  p.put('color', _c(g.color));
  p.put('trackColor', _c(g.trackColor));
  p.put('fillStartOpacity', _n(g.fillStartOpacity));
  p.put('segments', g.segments);
  p.put('segmentGap', _n(g.segmentGap));
  p.put('thickness', _n(g.thickness));
  p.put('startAngle', _n(g.startAngle));
  p.put('sweepAngle', _n(g.sweepAngle));
  p.put('cornerRadius', _n(g.cornerRadius));
  p.put('backgroundColor', _c(g.backgroundColor));
  p.put('borderColor', _c(g.borderColor));
  p.put('inset', _n(g.inset));
  p.put('edgeWidth', _n(g.edgeWidth));
  p.put('edgeColor', _c(g.edgeColor));
  p.put('ticks', g.ticks);
  p.put('majorTickEvery', g.majorTickEvery);
  p.put('tickColor', _c(g.tickColor));
  p.put('limitColor', _c(g.limitColor));
  p.put('limitWidth', _n(g.limitWidth));
  p.put('limitStyle', g.limitStyle.name);
  p.put('limitPointer', g.limitPointer);
  p.put('animate', g.animate);
  p.put('animationDurationInMillis', g.animationDurationInMillis, 'animationDuration');
  return {...out, ...p.done()};
}

// --- charts ---------------------------------------------------------------------

String _chartType(BaseNode n) => n is PlotChartNode ? 'plotChart' : 'chart';

Json _series(ChartSeries s) => {
      'field': s.field,
      if (s.name.isNotEmpty) 'name': s.name,
      if (s.kind != ChartSeriesKind.bar) 'kind': s.kind.name,
      'color': _c(s.color),
      if (s.colorField != null) 'colorField': s.colorField,
      if (s.stack != null) 'stack': s.stack,
      if (s.dashed) 'dashed': true,
      if (s.strokeWidth != 2) 'strokeWidth': _n(s.strokeWidth),
      if (s.endDot) 'endDot': true,
      if (s.endDotHaloColor != null) 'endDotHaloColor': _c(s.endDotHaloColor!),
      if (s.curved) 'curved': true,
      if (s.fillTo != null) 'fillTo': s.fillTo,
      if (s.fillOpacity != 0.25) 'fillOpacity': _n(s.fillOpacity),
    };

/// A plot chart text style as a v2 `TextStyle`.
Json _plotStyle(PlotChartTextStyle s) => {
      'fontSize': _n(s.fontSize),
      'color': _c(s.color),
      if (s.fontFamily != null) 'fontFamily': s.fontFamily,
      'fontWeight': s.fontWeight,
      if (s.height != null) 'height': _n(s.height!),
    };

Json _chart(V1Node m) {
  m.take('chartKind');
  final out = <String, Object?>{};
  if (m.n case final PlotChartNode n) {
    _takeNodeKeys(m, out, {'selectedX': 'selectedX'});
    final c = n.properties;
    final p = _Props(m, 'chart', c.toJson());
    p.put('points', [for (final v in c.points) _n(v)]);
    p.put('xMin', _n(c.xMin));
    p.put('xMax', _n(c.xMax));
    p.put('yMin', _on(c.yMin));
    p.put('yMax', _on(c.yMax));
    p.put('plotInset', _n(c.plotInset));
    p.put('lineColor', _c(c.lineColor));
    p.put('lineWidth', _n(c.lineWidth));
    p.put('fillColor', _oc(c.fillColor));
    p.put('smooth', c.smooth);
    p.put('gridStepX', _on(c.gridStepX));
    p.put('gridColor', _c(c.gridColor));
    p.put('axisColor', _oc(c.axisColor));
    p.put('xLabels', [for (final l in c.xLabels) {'x': _n(l.x), 'label': l.label}]);
    p.put('gridLabels', c.gridLabels);
    p.always('labelStyle', _plotStyle(c.labelStyle));
    p.put('labelHeight', _n(c.labelHeight));
    p.put('ranges', [
      for (final r in c.ranges) {'from': _n(r.from), 'to': _n(r.to), 'color': _c(r.color)},
    ]);
    p.put('markers', [
      for (final mk in c.markers)
        {
          'x': _n(mk.x),
          if (mk.y != null) 'y': _n(mk.y!),
          if (mk.label.isNotEmpty) 'label': mk.label,
          'color': _c(mk.color),
          if (mk.position != PlotChartMarkerPosition.above) 'position': mk.position.name,
        },
    ]);
    p.put('markerRadius', _n(c.markerRadius));
    p.always('markerLabelStyle', _plotStyle(c.markerLabelStyle));
    p.put('referenceX', _on(c.referenceX));
    p.put('referenceColor', _c(c.referenceColor));
    p.put('referenceWidth', _n(c.referenceWidth));
    p.put('referenceDashed', c.referenceDashed);
    p.put('selectable', c.selectable);
    p.put('selectionStep', _n(c.selectionStep));
    p.put('selectionMin', _on(c.selectionMin));
    p.put('selectionMax', _on(c.selectionMax));
    p.put('selectionColor', _c(c.selectionColor));
    p.put('selectionLineColor', _c(c.selectionLineColor));
    p.put('selectionLineWidth', _n(c.selectionLineWidth));
    p.put('selectionDotRadius', _n(c.selectionDotRadius));
    p.put('selectionDotColor', _c(c.selectionDotColor));
    p.put('selectionDotStrokeColor', _c(c.selectionDotStrokeColor));
    p.put('selectionDotStrokeWidth', _n(c.selectionDotStrokeWidth));
    return {...out, ...p.done()};
  }
  final n = m.n as ChartNode;
  _takeNodeKeys(m, out, {'selectedIndex': 'selectedIndex'});
  final c = n.properties;
  final p = _Props(m, 'chart', c.toJson());
  p.put('chartType', c.chartType.name);
  // v1's default series and rows are sample content; v2's default is none.
  p.always('series', [for (final s in c.series) _series(s)]);
  p.put('labelField', c.labelField);
  p.always('sampleData', [for (final row in c.sampleData) {...row}], 'data');
  for (final k in const ['series', 'data']) {
    if ((p.out[k] as List?)?.isEmpty ?? false) p.out.remove(k);
  }
  p.put('minY', _on(c.minY));
  p.put('maxY', _on(c.maxY));
  p.put('gridLines', c.gridLines);
  p.put('gridColor', _c(c.gridColor));
  p.put('showYAxis', c.showYAxis);
  p.put('yAxisWidth', _n(c.yAxisWidth));
  p.put('showXAxis', c.showXAxis);
  p.put('xLabelEvery', c.xLabelEvery);
  p.put('axisLabelColor', _c(c.axisLabelColor));
  p.put('axisFontSize', _n(c.axisFontSize));
  p.put('axisFontFamily', c.axisFontFamily);
  p.put('referenceLines', [
    for (final r in c.referenceLines)
      {
        'value': _n(r.value),
        'color': _c(r.color),
        if (!r.dashed) 'dashed': false,
        if (r.strokeWidth != 1.5) 'strokeWidth': _n(r.strokeWidth),
      },
  ]);
  p.put('barWidthFraction', _n(c.barWidthFraction));
  p.put('maxBarWidth', _n(c.maxBarWidth));
  p.put('barGap', _n(c.barGap));
  p.put('barRadius', _n(c.barRadius));
  p.put('dashEmpty', c.dashEmpty);
  p.put('selectionColor', _c(c.selectionColor));
  p.put('xSlots', c.xSlots);
  p.put('startField', c.startField);
  p.put('endField', c.endField);
  p.put('segmentColorField', c.segmentColorField);
  p.put('domainMin', _n(c.domainMin));
  p.put('domainMax', _n(c.domainMax));
  p.put('nowValue', _on(c.nowValue));
  p.put('nowColor', _oc(c.nowColor));
  p.put('trackColor', _c(c.trackColor));
  p.put('divisions', c.divisions);
  p.put('donutThickness', _n(c.donutThickness));
  p.put('sliceGap', _n(c.sliceGap));
  p.put('startAngle', _n(c.startAngle));
  p.put('selectOnHover', c.selectOnHover);
  p.put('plotInset', _on(c.plotInset));
  p.put('fitMinY', c.fitMinY);
  p.put('yLabelPrefix', c.yLabelPrefix);
  p.put('yLabelSuffix', c.yLabelSuffix);
  p.put('yAxisFontFamily', c.yAxisFontFamily);
  return {...out, ...p.done()};
}

Json _barChart(V1Node m) {
  final n = m.n as BarChartNode;
  for (final k in const ['values', 'labels', 'highlight']) {
    m.take(k);
  }
  final out = <String, Object?>{
    if (n.values.isNotEmpty) 'values': [for (final v in n.values) _on(v)],
    if (n.labels.isNotEmpty) 'labels': n.labels,
    if (n.highlight != null) 'highlight': n.highlight,
  };
  final b = n.properties;
  final p = _Props(m, n.type, b.toJson());
  p.put('max', _n(b.max));
  p.put('color', _c(b.color));
  p.put('dimmedOpacity', _n(b.dimmedOpacity));
  p.put('barGap', _n(b.barGap));
  p.put('barRadius', _n(b.barRadius));
  p.put('emptyColor', _c(b.emptyColor));
  p.put('emptyHeight', _n(b.emptyHeight));
  p.put('gridLines', b.gridLines);
  p.put('gridColor', _c(b.gridColor));
  p.put('gridLabels', b.gridLabels);
  p.put('gridLabelWidth', _n(b.gridLabelWidth));
  p.put('baselineColor', _c(b.baselineColor));
  p.put('labelFontFamily', b.labelFontFamily);
  p.put('labelFontSize', _n(b.labelFontSize));
  p.put('labelColor', _c(b.labelColor));
  p.put('highlightLabelColor', _c(b.highlightLabelColor));
  p.put('labelGap', _n(b.labelGap));
  p.put('animate', b.animate);
  p.put('animationDurationInMillis', b.animationDurationInMillis, 'animationDuration');
  return {...out, ...p.done()};
}

Json _lineChart(V1Node m) {
  final n = m.n as LineChartNode;
  final l = n.properties;
  final p = _Props(m, n.type, l.toJson());
  p.put('xField', l.xField);
  p.put('yField', l.yField);
  p.put('xMin', _on(l.xMin));
  p.put('xMax', _on(l.xMax));
  p.put('yMin', _on(l.yMin));
  p.put('yMax', _on(l.yMax));
  for (final k in const ['padLeft', 'padTop', 'padRight', 'padBottom']) {
    p.drop(k);
  }
  if (l.padLeft != 44 || l.padTop != 30 || l.padRight != 14 || l.padBottom != 30) {
    p.out['plotPadding'] = [_n(l.padLeft), _n(l.padTop), _n(l.padRight), _n(l.padBottom)];
  }
  p.put('smooth', l.smooth);
  p.put('lineColor', _c(l.lineColor));
  p.put('lineWidth', _n(l.lineWidth));
  p.put('areaTopColor', _c(l.areaTopColor));
  p.put('areaBottomColor', _c(l.areaBottomColor));
  p.put('gridColor', _c(l.gridColor));
  p.put('zeroLineColor', _c(l.zeroLineColor));
  p.put('axisColor', _c(l.axisColor));
  p.put('markerHollowColor', _c(l.markerHollowColor));
  p.put('tagBackground', _c(l.tagBackground));
  p.put('cursorColor', _c(l.cursorColor));
  p.put('cursorRingFill', _c(l.cursorRingFill));
  p.put('tooltipBackground', _c(l.tooltipBackground));
  p.put('tooltipShadowColor', _c(l.tooltipShadowColor));
  p.put('yAxisTitle', l.yAxisTitle);
  p.always('axisLabelStyle', V1Node.textStyle(l.axisLabelStyle));
  p.always('axisTitleStyle', V1Node.textStyle(l.axisTitleStyle));
  p.always('markerLabelStyle', V1Node.textStyle(l.markerLabelStyle));
  p.always('tagTextStyle', V1Node.textStyle(l.tagTextStyle));
  p.always('tooltipLabelStyle', V1Node.textStyle(l.tooltipLabelStyle));
  p.always('tooltipValueStyle', V1Node.textStyle(l.tooltipValueStyle));
  p.put('scrubEnabled', l.scrubEnabled);
  p.put('scrubStep', _n(l.scrubStep));
  p.put('tooltipXFormat', l.tooltipXFormat);
  p.put('tooltipYScale', _n(l.tooltipYScale));
  p.put('tooltipYDecimals', l.tooltipYDecimals);
  p.put('tooltipYSuffix', l.tooltipYSuffix);
  p.put('tooltipTrend', l.tooltipTrend);
  p.put('semanticLabel', l.semanticLabel);
  return p.done();
}

Json _barcode(V1Node m) {
  final n = m.n as BarcodeNode;
  m.take('data');
  // Blend settings at their defaults carry nothing; others stay reported.
  if (n.blendMode == BlendModeC.srcOver) m.take('blendMode');
  if (!n.isMask) m.take('isMask');
  if (n.effects.isEmpty) m.take('effects');
  final out = <String, Object?>{if (n.data.isNotEmpty) 'data': n.data};
  final b = n.properties;
  final p = _Props(m, n.type, b.toJson());
  p.put('symbology', b.symbology.name);
  p.put('color', _c(b.color));
  p.put('backgroundColor', _oc(b.backgroundColor));
  p.put('errorCorrection', b.errorCorrection.name);
  p.put('drawText', b.drawText);
  return {...out, ...p.done()};
}

/// Takes `properties` and runs [props].
Json Function(V1Node) _withProperties(Json Function(V1Node) props) => (m) {
      m.take('properties');
      return props(m);
    };

/// By v1 node type.
final Map<String, TypeMigration> indicatorsMigrations = {
  'loadingIndicator': TypeMigration(type: _loadingType, props: _withProperties(_loadingIndicator)),
  'progressBar': TypeMigration(type: (_) => 'progressBar', props: _withProperties(_progressBar)),
  'gauge': TypeMigration(type: _gaugeType, props: _withProperties(_gauge)),
  'chart': TypeMigration(type: _chartType, props: _withProperties(_chart)),
  'barChart': TypeMigration(type: (_) => 'barChart', props: _withProperties(_barChart)),
  'lineChart': TypeMigration(type: (_) => 'lineChart', props: _withProperties(_lineChart)),
  'barcode': TypeMigration(type: (_) => 'barcode', props: _withProperties(_barcode)),
};
