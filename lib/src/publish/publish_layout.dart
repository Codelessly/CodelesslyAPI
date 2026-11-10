import 'package:meta/meta.dart';

import '../document.dart';
import '../conditions.dart';
import '../json.dart';
import '../logic.dart';
import '../scripts.dart';
import '../variables.dart';
import 'breakpoints.dart';
import 'theme.dart';

/// Which project breakpoint a canvas of a layout is the design for
/// (DESIGN.md §5.3). A layout with several canvases (one screen, one canvas
/// per breakpoint) shows the one whose switch point is the highest at or
/// below the width it's shown at (see [CanvasBreakpointsForWidth.forWidth]).
@immutable
final class CanvasBreakpoint {
  const CanvasBreakpoint({required this.canvasId, this.breakpointId, this.minWidth});

  /// The canvas.
  final String canvasId;

  /// The project breakpoint ([Breakpoint.id]) it is the design for; null
  /// when it names none (its [minWidth] alone places it).
  final String? breakpointId;

  /// Where this canvas starts showing when not at its breakpoint's min width:
  /// its own switch point.
  final double? minWidth;

  /// The width this canvas starts showing at, by the project's [breakpoints].
  double minWidthIn(Breakpoints breakpoints) => minWidth ?? breakpoints.byId(breakpointId)?.minWidth ?? 0;

  static CanvasBreakpoint? fromJson(Object? json) {
    final m = readMap(json);
    final canvas = readString(m?['canvas']);
    if (m == null || canvas == null) return null;
    final id = readString(m['breakpoint']);
    final min = readDouble(m['minWidth']);
    return CanvasBreakpoint(
      canvasId: canvas,
      breakpointId: id == null || id.isEmpty ? null : id,
      // Without a breakpoint, the range's start is the switch point (0 too).
      minWidth: min ?? (id == null || id.isEmpty ? 0 : null),
    );
  }

  Json toJson() => {
        'canvas': canvasId,
        'breakpoint': ?breakpointId,
        if (minWidth case final double w when breakpointId != null || w != 0) 'minWidth': writeDouble(w),
      };

  @override
  bool operator ==(Object other) =>
      other is CanvasBreakpoint && other.canvasId == canvasId && other.breakpointId == breakpointId && other.minWidth == minWidth;

  @override
  int get hashCode => Object.hash(canvasId, breakpointId, minWidth);

  @override
  String toString() => 'CanvasBreakpoint($canvasId, ${breakpointId ?? '-'}${minWidth == null ? '' : ' ≥$minWidth'})';
}

extension CanvasBreakpointsForWidth on Iterable<CanvasBreakpoint> {
  /// The entry for [width]: the one whose switch point (by [breakpoints]) is
  /// the highest at or below it, else the narrowest. Null when there are
  /// none.
  CanvasBreakpoint? forWidth(double width, Breakpoints breakpoints) {
    if (isEmpty) return null;
    CanvasBreakpoint? best, narrowest;
    double bestMin = double.negativeInfinity, narrowestMin = double.infinity;
    for (final c in this) {
      final min = c.minWidthIn(breakpoints);
      if (min < narrowestMin) {
        narrowest = c;
        narrowestMin = min;
      }
      if (width >= min && min > bestMin) {
        best = c;
        bestMin = min;
      }
    }
    return best ?? narrowest;
  }
}

/// One published layout: a [LayoutDocument] whose roots are its canvases
/// (one per screen size, picked by [breakpoints]), and what the runtime needs
/// to run it.
///
/// Its JSON is the document's (`schema`, `id`, `roots`, `nodes`) with the
/// layout's own keys beside them, so a published layout decodes as a
/// [LayoutDocument] too.
@immutable
final class PublishLayout {
  PublishLayout({
    required this.document,
    this.pageId = '',
    this.projectId = '',
    this.breakpoints = const [],
    this.paths = const {},
    this.variables = const {},
    this.conditions = const {},
    this.fonts = const [],
    this.apis = const [],
    this.theme,
    this.lastUpdated,
    this.hidden = false,
    this.extra = const {},
  });

  /// The layout's id (the document's).
  String get id => document.id;

  /// The canvases, in order (the document's roots).
  List<String> get canvasIds => document.roots;

  final LayoutDocument document;

  /// The editor page the layout was published from.
  final String pageId;
  final String projectId;

  /// The project breakpoint each canvas is the design for; empty for a
  /// layout of one canvas.
  final List<CanvasBreakpoint> breakpoints;

  /// The URL path pattern of each canvas that has one (`guide/:id`): canvas
  /// id → path.
  final Map<String, String> paths;

  /// The variables its canvases declare, as published: canvas id → variable
  /// id → variable. Read by the runtime's value scope.
  final Json variables;

  /// The conditions its canvases use, as published: canvas id → condition
  /// id → condition. Read by the runtime's expression engine.
  final Json conditions;

  /// Ids of the fonts its text uses ([PublishModel.fonts]).
  final List<String> fonts;

  /// Ids of the APIs its actions call ([PublishModel.apis]).
  final List<String> apis;

  /// The project's theme when the layout was published; null to use the
  /// project's ([PublishModel.theme]).
  final ThemeTokens? theme;

  /// When it was last published: a cached copy older than the model's entry
  /// for it is stale.
  final DateTime? lastUpdated;

  /// Hidden from the published layouts dashboard.
  final bool hidden;

  /// Keys this version doesn't model, kept.
  final Json extra;

  static const Set<String> _ownKeys = {
    'pageId', 'projectId', 'breakpoints', 'paths', 'variables', 'conditions', 'fonts', 'apis', 'theme', //
    'lastUpdated', 'hidden',
  };

  /// The canvas shown at [width]: the only canvas of a single-canvas layout,
  /// else the one for [width] by the project's [breakpoints] (default:
  /// [Breakpoints.defaults]). Null for a layout with no canvas.
  String? canvasForWidth(double width, [Breakpoints? breakpoints]) {
    if (canvasIds.isEmpty) return null;
    if (canvasIds.length == 1) return canvasIds.first;
    final picked = this.breakpoints.where((b) => canvasIds.contains(b.canvasId)).forWidth(width, breakpoints ?? Breakpoints.defaults);
    return picked?.canvasId ?? canvasIds.first;
  }

  /// The breakpoint entry of [canvasId], if it has one.
  CanvasBreakpoint? breakpointOf(String canvasId) {
    for (final b in breakpoints) {
      if (b.canvasId == canvasId) return b;
    }
    return null;
  }

  /// Its variables and conditions, per canvas (the `variables` and
  /// `conditions` keys, DESIGN.md §5.1).
  LayoutLogic get logic => LayoutLogic.fromJson({LayoutLogic.variablesKey: variables, LayoutLogic.conditionsKey: conditions});

  /// The variables of canvas [canvasId].
  List<Variable> variablesOf(String canvasId) => logic.variablesOf(canvasId);

  /// The conditions of canvas [canvasId].
  List<Condition> conditionsOf(String canvasId) => logic.conditionsOf(canvasId);

  /// Decodes a published layout of any schema. Never throws.
  static PublishLayout fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    final document = LayoutDocument.fromJson({
      for (final e in m.entries)
        if (!_ownKeys.contains(e.key)) e.key: e.value,
    });
    final docExtra = document.extra;
    return PublishLayout(
      // The layout's keys the document doesn't know go in [extra], not the
      // document's; its `scripts` stay the document's
      // ([LayoutDocumentScripts]).
      document: document.copyWith(extra: {
        for (final e in docExtra.entries)
          if (e.key == LayoutDocumentScripts.key) e.key: e.value,
      }),
      pageId: readString(m['pageId']) ?? '',
      projectId: readString(m['projectId']) ?? '',
      breakpoints: [...?readList(m['breakpoints'])?.map(CanvasBreakpoint.fromJson).nonNulls],
      paths: {
        for (final e in (readMap(m['paths']) ?? const {}).entries)
          if (e.value case final String p when p.isNotEmpty) e.key: p,
      },
      variables: readMap(m['variables']) ?? const {},
      conditions: readMap(m['conditions']) ?? const {},
      fonts: readStrings(m['fonts']),
      apis: readStrings(m['apis']),
      theme: m['theme'] == null ? null : ThemeTokens.fromJson(m['theme']),
      lastUpdated: readTimestamp(m['lastUpdated']),
      hidden: readBool(m['hidden']) ?? false,
      extra: {
        for (final e in docExtra.entries)
          if (e.key != LayoutDocumentScripts.key) e.key: e.value,
      },
    );
  }

  Json toJson() {
    final j = document.toJson();
    if (pageId.isNotEmpty) j['pageId'] = pageId;
    if (projectId.isNotEmpty) j['projectId'] = projectId;
    if (breakpoints.isNotEmpty) j['breakpoints'] = [for (final b in breakpoints) b.toJson()];
    if (paths.isNotEmpty) j['paths'] = paths;
    if (variables.isNotEmpty) j['variables'] = variables;
    if (conditions.isNotEmpty) j['conditions'] = conditions;
    if (fonts.isNotEmpty) j['fonts'] = fonts;
    if (apis.isNotEmpty) j['apis'] = apis;
    if (theme != null) j['theme'] = theme!.toJson();
    put(j, 'lastUpdated', lastUpdated?.let(writeTimestamp));
    if (hidden) j['hidden'] = true;
    j.addAll(extra);
    return j;
  }

  PublishLayout copyWith({
    LayoutDocument? document,
    String? pageId,
    String? projectId,
    List<CanvasBreakpoint>? breakpoints,
    Map<String, String>? paths,
    Json? variables,
    Json? conditions,
    List<String>? fonts,
    List<String>? apis,
    ThemeTokens? theme,
    DateTime? lastUpdated,
    bool? hidden,
    Json? extra,
  }) =>
      PublishLayout(
        document: document ?? this.document,
        pageId: pageId ?? this.pageId,
        projectId: projectId ?? this.projectId,
        breakpoints: breakpoints ?? this.breakpoints,
        paths: paths ?? this.paths,
        variables: variables ?? this.variables,
        conditions: conditions ?? this.conditions,
        fonts: fonts ?? this.fonts,
        apis: apis ?? this.apis,
        theme: theme ?? this.theme,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        hidden: hidden ?? this.hidden,
        extra: extra ?? this.extra,
      );
}

/// [v] (milliseconds since the epoch, UTC; or an ISO 8601 string) as a
/// time, or null.
DateTime? readTimestamp(Object? v) => switch (v) {
      final num n when n.isFinite => DateTime.fromMillisecondsSinceEpoch(n.round(), isUtc: true),
      final String s => DateTime.tryParse(s)?.toUtc(),
      _ => null,
    };

/// [t] as stored: milliseconds since the epoch.
int writeTimestamp(DateTime t) => t.millisecondsSinceEpoch;
