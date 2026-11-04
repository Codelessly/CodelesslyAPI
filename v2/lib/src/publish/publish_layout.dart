import 'package:meta/meta.dart';

import '../document.dart';
import '../conditions.dart';
import '../json.dart';
import '../logic.dart';
import '../variables.dart';
import 'theme.dart';

/// The width range a canvas of a layout shows at. A layout with several
/// canvases (one per screen size) picks the one whose breakpoint covers the
/// width it's shown at (see [BreakpointsForWidth.forWidth]).
@immutable
final class Breakpoint {
  const Breakpoint({required this.canvasId, this.minWidth = 0, this.maxWidth});

  /// The canvas shown in this range.
  final String canvasId;

  /// The narrowest width, inclusive.
  final double minWidth;

  /// The widest width, inclusive; null: no limit.
  final double? maxWidth;

  bool covers(double width) => width >= minWidth && (maxWidth == null || width <= maxWidth!);

  static Breakpoint? fromJson(Object? json) {
    final m = readMap(json);
    final canvas = readString(m?['canvas']);
    if (m == null || canvas == null) return null;
    return Breakpoint(canvasId: canvas, minWidth: readDouble(m['minWidth']) ?? 0, maxWidth: readDouble(m['maxWidth']));
  }

  Json toJson() {
    final j = <String, Object?>{'canvas': canvasId};
    put(j, 'minWidth', writeDouble(minWidth), 0);
    put(j, 'maxWidth', maxWidth?.let(writeDouble));
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Breakpoint && other.canvasId == canvasId && other.minWidth == minWidth && other.maxWidth == maxWidth;

  @override
  int get hashCode => Object.hash(canvasId, minWidth, maxWidth);

  @override
  String toString() => 'Breakpoint($canvasId, $minWidth..${maxWidth ?? '∞'})';
}

extension BreakpointsForWidth on Iterable<Breakpoint> {
  /// The breakpoint for [width]: the one with the highest [Breakpoint.minWidth]
  /// at or below it. A gap between ranges (an upper bound of 599 and a lower
  /// bound of 600) belongs to the narrower one, and a width below every range
  /// gets the narrowest. Null when there are none.
  Breakpoint? forWidth(double width) {
    if (isEmpty) return null;
    final sorted = [...this]..sort((a, b) => a.minWidth.compareTo(b.minWidth));
    Breakpoint? best;
    for (final b in sorted) {
      if (width >= b.minWidth) best = b;
    }
    return best ?? sorted.first;
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

  /// Which canvas shows at which width; empty for a layout of one canvas.
  final List<Breakpoint> breakpoints;

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
  /// else the one whose breakpoint covers [width]. Null for a layout with no
  /// canvas.
  String? canvasForWidth(double width) {
    if (canvasIds.isEmpty) return null;
    if (canvasIds.length == 1) return canvasIds.first;
    final picked = breakpoints.where((b) => canvasIds.contains(b.canvasId)).forWidth(width);
    return picked?.canvasId ?? canvasIds.first;
  }

  /// The breakpoint of [canvasId], if it has one.
  Breakpoint? breakpointOf(String canvasId) {
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

  /// Decodes a published layout of any v2 schema. Never throws.
  static PublishLayout fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    final document = LayoutDocument.fromJson({
      for (final e in m.entries)
        if (!_ownKeys.contains(e.key)) e.key: e.value,
    });
    final docExtra = document.extra;
    return PublishLayout(
      // The layout's keys the document doesn't know go in [extra], not the
      // document's.
      document: document.copyWith(extra: const {}),
      pageId: readString(m['pageId']) ?? '',
      projectId: readString(m['projectId']) ?? '',
      breakpoints: [...?readList(m['breakpoints'])?.map(Breakpoint.fromJson).nonNulls],
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
      extra: docExtra,
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
    List<Breakpoint>? breakpoints,
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
