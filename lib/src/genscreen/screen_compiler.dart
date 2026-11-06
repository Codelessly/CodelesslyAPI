/// Turns a validated screen plan into Codelessly node JSON: one tree per
/// breakpoint (mobile, tablet, desktop), each with content, loading
/// (skeleton), empty and error states, built only from the kit's tokens.
///
/// The trees are nested node JSON in the model's own wire form, which
/// `nodes.insertTree` / `layouts.createResponsive` accept as they are, and
/// [CompiledScreen.toLayoutNodes] flattens them into the node map the SDK
/// renders (canvas > body > responsive variance > breakpoint roots).
library;

import 'dart:convert';

import 'design_kit.dart';
import 'icon_vocabulary.dart';
import 'screen_plan.dart' show normalizePlan, planTypeAliases;

/// Breakpoints the compiler builds, with the canvas widths they are built at.
const Map<String, double> compileBreakpoints = <String, double>{
  'mobile': 390,
  'tablet': 834,
  'desktop': 1440,
};

/// Default canvas heights per breakpoint.
const Map<String, double> breakpointHeights = <String, double>{
  'mobile': 844,
  'tablet': 1112,
  'desktop': 900,
};

/// The names of the state variants, in order; `status` selects one.
const List<String> screenStates = <String>['content', 'loading', 'empty', 'error'];

/// What the compiler noticed: tokens used, wiring, fallbacks.
class CompileReport {
  /// Token references made, as `color.primary`, `text.title`, `space.md`...
  final Set<String> tokens = <String>{};

  /// Interactive elements (buttons, rows with actions, inputs, nav items).
  int interactive = 0;

  /// Interactive elements with a working reaction or binding.
  int wired = 0;

  /// Things the compiler had to work around (unknown icon, missing token).
  final List<String> warnings = <String>[];

  /// Navigation targets that aren't screens of the app (they show a toast).
  final Set<String> unresolvedScreens = <String>{};

  /// JSON form for result files.
  Map<String, Object?> toJson() => <String, Object?>{
    'tokens': tokens.toList()..sort(),
    'interactive': interactive,
    'wired': wired,
    'warnings': warnings,
    'unresolvedScreens': unresolvedScreens.toList(),
  };
}

/// A compiled screen.
class CompiledScreen {
  /// Screen title.
  final String title;

  /// Nested node JSON per breakpoint (`mobile`, `tablet`, `desktop`): the
  /// root that fills the responsive layout's variant.
  final Map<String, Map<String, dynamic>> trees;

  /// Variables the screen reads: `{name, type, value}`.
  final List<Map<String, dynamic>> variables;

  /// What the compiler noticed.
  final CompileReport report;

  /// Background color of the canvas.
  final String background;

  /// Creates a [CompiledScreen].
  const CompiledScreen({
    required this.title,
    required this.trees,
    required this.variables,
    required this.report,
    required this.background,
  });

  /// The flat node map the SDK renders: `canvas` > `body` > a responsive
  /// variance (`layout`) with one variant per breakpoint, every node keyed
  /// by id with `parentID` and child id lists.
  Map<String, Map<String, dynamic>> toLayoutNodes({
    String canvasId = 'canvas',
    double width = 390,
    double height = 844,
  }) {
    final Map<String, Map<String, dynamic>> nodes = <String, Map<String, dynamic>>{};
    String flatten(Map<String, dynamic> node, String parent) {
      final Map<String, dynamic> copy = Map<String, dynamic>.of(node);
      final List<dynamic> children = (copy.remove('children') as List?) ?? const [];
      final List<dynamic> variants = (copy['variants'] as List?) ?? const [];
      copy['parentID'] = parent;
      final String id = copy['id'] as String;
      nodes[id] = copy;
      if (copy['type'] == 'variance') {
        copy['variants'] = <Map<String, dynamic>>[
          for (final dynamic v in variants)
            <String, dynamic>{
              ...Map<String, dynamic>.of(v as Map<String, dynamic>)..remove('content'),
              'children': <String>[
                if (v['content'] != null) flatten(v['content'] as Map<String, dynamic>, id),
              ],
            },
        ];
        copy['children'] = <String>[
          for (final dynamic v in copy['variants'] as List) ...(v['children'] as List).cast<String>(),
        ];
      } else {
        copy['children'] = <String>[
          for (final dynamic child in children) flatten(child as Map<String, dynamic>, id),
        ];
      }
      return id;
    }

    final Map<String, dynamic> layout = <String, dynamic>{
      'id': '${canvasId}_layout',
      'name': 'Responsive layout',
      'type': 'variance',
      'basicBoxLocal': <num>[0, 0, width, height],
      'horizontalFit': 'expanded',
      'verticalFit': 'expanded',
      'currentVariantId': '${canvasId}_bp_mobile',
      'variants': <Map<String, dynamic>>[
        for (final MapEntry<String, Map<String, dynamic>> e in trees.entries)
          <String, dynamic>{
            'id': '${canvasId}_bp_${e.key}',
            'name': '${e.key[0].toUpperCase()}${e.key.substring(1)}',
            'breakpoint': e.key,
            'content': e.value,
          },
      ],
    };
    nodes[canvasId] = <String, dynamic>{
      'id': canvasId,
      'name': title,
      'type': 'canvas',
      'parentID': 'rootNode',
      'basicBoxLocal': <num>[0, 0, width, height],
      'scaleMode': 'responsive',
      'fills': <Map<String, dynamic>>[
        <String, dynamic>{'id': '${canvasId}_bg', 'type': 'solid', 'color': background},
      ],
      'children': <String>['${canvasId}_body'],
      'properties': <String, dynamic>{
        'bodyId': '${canvasId}_body',
        'safeArea': <String, dynamic>{'enabled': false, 'left': false, 'top': false, 'right': false, 'bottom': false},
      },
    };
    nodes['${canvasId}_body'] = <String, dynamic>{
      'id': '${canvasId}_body',
      'name': 'Body',
      'type': 'autoPlaceholder',
      'parentID': canvasId,
      'basicBoxLocal': <num>[0, 0, width, height],
      'horizontalFit': 'expanded',
      'verticalFit': 'expanded',
      'mainAxisAlignment': 'start',
      'children': <String>[layout['id'] as String],
    };
    flatten(layout, '${canvasId}_body');
    // `@key` node references (a Known button flinging the deck's card) name
    // a node of the same breakpoint tree by its key.
    Object? resolve(Object? json, Map<String, String> keys) {
      if (json is String && json.startsWith('@') && keys.containsKey(json.substring(1))) return keys[json.substring(1)];
      if (json is Map) return <String, dynamic>{for (final MapEntry<dynamic, dynamic> e in json.entries) '${e.key}': resolve(e.value, keys)};
      if (json is List) return <Object?>[for (final Object? v in json) resolve(v, keys)];
      return json;
    }

    for (final String bp in trees.keys) {
      final String prefix = bp[0];
      final Map<String, String> keys = <String, String>{
        for (final Map<String, dynamic> n in nodes.values)
          if (n['key'] is String && '${n['id']}'.startsWith('${prefix}_')) n['key'] as String: n['id'] as String,
      };
      if (keys.isEmpty) continue;
      for (final String id in nodes.keys.where((String id) => id.startsWith('${prefix}_')).toList()) {
        final Object? reactions = nodes[id]!['reactions'];
        if (reactions != null) nodes[id]!['reactions'] = resolve(reactions, keys);
      }
    }
    return nodes;
  }
}

class _Bp {
  final String name;
  final double width;
  final KitBreakpoint grid;
  const _Bp(this.name, this.width, this.grid);
  bool get mobile => name == 'mobile';
  bool get desktop => name == 'desktop';
  int get cardColumns => mobile ? 1 : desktop ? 3 : 2;
}

/// Compiles plans for one kit.
class ScreenCompiler {
  /// The design kit.
  final DesignKit kit;

  /// Screens a `navigate` action may open: name to canvas id.
  final Map<String, String> screens;

  /// Creates a [ScreenCompiler].
  ScreenCompiler(this.kit, {this.screens = const {}});

  late CompileReport _report;
  late _Bp _bp;
  late String _prefix;
  int _ids = 0;
  final Map<String, dynamic> _data = <String, dynamic>{};
  final Set<String> _deckFlipVariables = <String>{};

  /// Compiles [plan] (assumed valid; see `ScreenPlanValidator`).
  CompiledScreen compile(Map<String, dynamic> source) {
    _report = CompileReport();
    final (Map<String, dynamic> plan, Map<String, String> renames) = normalizePlan(source);
    for (final MapEntry<String, String> r in renames.entries) {
      _report.warnings.add('Renamed "${r.key}" to "${r.value}" (a runtime name).');
    }
    _deckFlipVariables.clear();
    _data
      ..clear()
      ..addAll(((plan['data'] as Map?) ?? const {}).cast<String, dynamic>());
    final Map<String, Map<String, dynamic>> trees = <String, Map<String, dynamic>>{};
    for (final MapEntry<String, double> bp in compileBreakpoints.entries) {
      _bp = _Bp(bp.key, bp.value, kit.breakpoint(bp.key));
      _prefix = bp.key[0];
      _ids = 0;
      trees[bp.key] = _screen(plan);
    }
    final List<Map<String, dynamic>> variables = <Map<String, dynamic>>[
      <String, dynamic>{'name': 'status', 'type': 'text', 'value': 'content'},
      for (final MapEntry<String, dynamic> e in _data.entries)
        <String, dynamic>{'name': e.key, 'type': _typeOf(e.value), 'value': e.value},
      for (final dynamic v in (plan['variables'] as List?) ?? const [])
        if (v is Map && !_data.containsKey(v['name']))
          <String, dynamic>{
            'name': v['name'],
            'type': planTypeAliases[v['type']] ?? v['type'] ?? _typeOf(v['value']),
            'value': v['value'] ?? _defaultFor(v['type']),
          },
      // A deck's flip state, unless the plan declared it.
      for (final String f in _deckFlipVariables)
        if (!_data.containsKey(f) && !((plan['variables'] as List?) ?? const []).any((dynamic v) => v is Map && v['name'] == f))
          <String, dynamic>{'name': f, 'type': 'boolean', 'value': false},
    ];
    // Each interactive element was counted once per breakpoint.
    _report
      ..interactive = (_report.interactive / compileBreakpoints.length).round()
      ..wired = (_report.wired / compileBreakpoints.length).round();
    return CompiledScreen(
      title: '${plan['title']}',
      trees: trees,
      variables: variables,
      report: _report,
      background: _hex('background'),
    );
  }

  // ---------------------------------------------------------------- tokens

  KitColor _color(String token) {
    _report.tokens.add('color.$token');
    final KitColor? c = kit.color(token);
    if (c != null) return c;
    const Map<String, String> fallback = <String, String>{
      'surfaceVariant': 'background',
      'onSurfaceVariant': 'onSurface',
      'outline': 'surfaceVariant',
      'secondary': 'surfaceVariant',
      'onSecondary': 'onSurface',
      'onError': 'onPrimary',
      'error': 'primary',
      'success': 'primary',
      'warning': 'primary',
      'accent': 'primary',
      'background': 'surface',
    };
    final String? next = fallback[token];
    if (next != null) return _color(next);
    _report.warnings.add('Color token "$token" is not in the kit; used onSurface.');
    return kit.color('onSurface') ?? const KitColor(0, 0, 0);
  }

  String _hex(String token) => _color(token).nodeHex;

  /// [token], or onSurfaceVariant when it can hardly be told from
  /// [background] (an off switch's track on paper).
  String _visibleOn(String token, String background) {
    final KitColor c = _color(token);
    final KitColor bg = kit.color(background) ?? const KitColor(255, 255, 255);
    final KitColor page = kit.color('background') ?? bg;
    final double ratio = c.contrastWith(bg) < c.contrastWith(page) ? c.contrastWith(bg) : c.contrastWith(page);
    return ratio >= 1.5 ? token : 'onSurfaceVariant';
  }

  /// Brand colors that text may not be readable in.
  static const Set<String> _brandTokens = <String>{'primary', 'secondary', 'accent', 'success', 'warning', 'error'};

  /// [token] for text on the page, or onSurface when a brand color is too
  /// light (or dark) to read on the kit's surfaces: yellow on cream.
  KitColor _readable(String token) {
    final KitColor c = _color(token);
    if (!_brandTokens.contains(token)) return c;
    final KitColor surface = kit.color('surface') ?? const KitColor(255, 255, 255);
    final KitColor background = kit.color('background') ?? surface;
    final double ratio = c.contrastWith(surface) < c.contrastWith(background) ? c.contrastWith(surface) : c.contrastWith(background);
    if (ratio >= 3) return c;
    _report.warnings.add('Text in "$token" fails contrast on the page (${ratio.toStringAsFixed(1)}:1); used onSurface.');
    return _color('onSurface');
  }

  double _space(String? token, [String fallback = 'md']) {
    final String t = token ?? fallback;
    final double? v = kit.space(t);
    if (v != null) {
      _report.tokens.add('space.$t');
      return v;
    }
    if (t != fallback) return _space(fallback);
    return 16;
  }

  double _radius(String? token, [String fallback = 'md']) {
    final String t = token ?? fallback;
    final double? v = kit.corner(t);
    if (v != null) {
      _report.tokens.add('radius.$t');
      return v;
    }
    if (t != fallback) return _radius(fallback);
    return 8;
  }

  KitTextStyle _type(String role) {
    final KitTextStyle? s = kit.typography[role];
    if (s != null) {
      _report.tokens.add('text.$role');
      return s;
    }
    const Map<String, String> fallback = <String, String>{
      'display': 'headline',
      'headline': 'title',
      'subtitle': 'body',
      'caption': 'label',
      'label': 'body',
    };
    return _type(fallback[role] ?? 'body');
  }

  KitGuide _comp(String name) => kit.components[name] ?? const KitGuide();

  String _prop(KitGuide guide, String key, String fallback) => guide[key] ?? fallback;

  double _num(KitGuide guide, String key, double fallback) {
    final String? v = guide[key];
    if (v == null) return fallback;
    return double.tryParse(RegExp(r'-?\d+(\.\d+)?').firstMatch(v)?[0] ?? '') ?? fallback;
  }

  /// A color property of a component: a token, or `none` (null).
  String? _colorProp(KitGuide guide, String key, String? fallback) {
    final String? v = guide[key] ?? fallback;
    if (v == null || v == 'none' || v == '-') return null;
    return v;
  }

  List<Map<String, dynamic>> _shadow(String? token) {
    if (token == null || token == 'none' || token == 'flat') return const [];
    final List<KitShadow>? shadows = kit.elevation[token];
    if (shadows == null) return const [];
    _report.tokens.add('elevation.$token');
    return <Map<String, dynamic>>[
      for (final KitShadow s in shadows)
        <String, dynamic>{
          'type': 'dropShadow',
          'offset': <num>[s.x, s.y],
          'radius': s.blur,
          'spread': s.spread,
          'color': s.color.nodeHex,
          'visible': true,
        },
    ];
  }

  // ------------------------------------------------------------- primitives

  String _id(String kind) => '${_prefix}_${kind}_${++_ids}';

  Map<String, dynamic> _paint(String token) => <String, dynamic>{
    'id': _id('paint'),
    'type': 'solid',
    'color': _color(token).rgbHex,
    if (_color(token).opacity < 1) 'opacity': _color(token).opacity,
  };

  List<num> _pad(double l, double t, double r, double b) => <num>[l, t, r, b];

  Map<String, dynamic> _box(
    String type,
    String name,
    List<Map<String, dynamic>> children, {
    String h = 'expanded',
    String v = 'shrinkWrap',
    double w = 300,
    double height = 40,
    String main = 'start',
    String cross = 'stretch',
    double gap = 0,
    String? fill,
    String? stroke,
    double strokeWeight = 1,
    double? radius,
    List<num>? padding,
    List<Map<String, dynamic>> effects = const [],
    bool scroll = false,
    bool wrap = false,
    int? flex,
    Map<String, dynamic>? extra,
  }) {
    final Map<String, dynamic> node = <String, dynamic>{
      'id': _id(type),
      'name': name,
      'type': type,
      'rowColumnType': type,
      'basicBoxLocal': <num>[0, 0, w, height],
      'horizontalFit': h,
      'verticalFit': v,
      'mainAxisAlignment': main,
      'crossAxisAlignment': cross,
      if (gap > 0) 'spacing': gap,
      if (fill != null) 'fills': <Map<String, dynamic>>[_paint(fill)],
      if (stroke != null) ...<String, dynamic>{
        'strokes': <Map<String, dynamic>>[_paint(stroke)],
        'strokeWeight': strokeWeight,
        'strokeAlign': 'inside',
      },
      if (radius != null && radius > 0) 'cornerRadius': <Object>[radius, true, 'circular'],
      if (padding != null) 'padding': padding,
      if (effects.isNotEmpty) 'effects': effects,
      if (scroll) 'isScrollable': true,
      if (wrap) 'wrap': true,
      if (flex != null) 'flex': flex,
      'children': children,
      ...?extra,
    };
    // Flutter's Container adds the border to its padding; the editor draws
    // strokes inside. Pad by the stroke so content sits where designed.
    if (stroke != null && padding != null) {
      node['padding'] = <num>[for (final num p in padding) p + strokeWeight];
    }
    return node;
  }

  Map<String, dynamic> _column(String name, List<Map<String, dynamic>> children, {
    String h = 'expanded',
    String v = 'shrinkWrap',
    String main = 'start',
    String cross = 'stretch',
    double gap = 0,
    String? fill,
    String? stroke,
    double strokeWeight = 1,
    double? radius,
    List<num>? padding,
    List<Map<String, dynamic>> effects = const [],
    bool scroll = false,
    int? flex,
    Map<String, dynamic>? extra,
  }) => _box('column', name, children, h: h, v: v, main: main, cross: cross, gap: gap,
      fill: fill, stroke: stroke, strokeWeight: strokeWeight, radius: radius, padding: padding,
      effects: effects, scroll: scroll, flex: flex, extra: extra, height: 100);

  Map<String, dynamic> _row(String name, List<Map<String, dynamic>> children, {
    String h = 'expanded',
    String v = 'shrinkWrap',
    String main = 'start',
    String cross = 'center',
    double gap = 0,
    String? fill,
    String? stroke,
    double strokeWeight = 1,
    double? radius,
    List<num>? padding,
    List<Map<String, dynamic>> effects = const [],
    bool wrap = false,
    int? flex,
    double height = 40,
    Map<String, dynamic>? extra,
  }) => _box('row', name, children, h: h, v: v, main: main, cross: cross, gap: gap,
      fill: fill, stroke: stroke, strokeWeight: strokeWeight, radius: radius, padding: padding,
      effects: effects, wrap: wrap, flex: flex, extra: extra, height: height);

  /// Fields some sample list items lack (`badge` on one plan of three).
  bool _optionalItemField(String field) {
    bool seen = false, missing = false;
    for (final Object? v in _data.values) {
      if (v is! List) continue;
      for (final Object? item in v) {
        if (item is! Map) continue;
        if (item[field] == null || item[field] == '') {
          missing = true;
        } else {
          seen = true;
        }
      }
    }
    return seen && missing;
  }

  Map<String, dynamic> _text(
    String data,
    String role, {
    String color = 'onSurface',
    String name = 'Text',
    String h = 'expanded',
    String align = 'left',
    int? maxLines,
    int? flex,
    Map<String, dynamic>? extra,
  }) {
    final KitTextStyle s = _type(role);
    final String value = s.uppercase && !data.contains(r'${') ? data.toUpperCase() : data;
    final KitColor c = _readable(color);
    // A text that is just an item field some items lack hides on those.
    final Match? only = RegExp(r'^\$\{item\.([A-Za-z0-9_]+)\}$').firstMatch(data.trim());
    if (only != null && _optionalItemField(only[1]!)) {
      extra = <String, dynamic>{
        ...?extra,
        'variables': <String, dynamic>{'visible': '\${= item.${only[1]} != null && item.${only[1]} != \'\'}'},
      };
    }
    return <String, dynamic>{
      'id': _id('text'),
      'name': name,
      'type': 'text',
      'data': value,
      'basicBoxLocal': <num>[0, 0, 200, s.size * s.lineHeight],
      'horizontalFit': h,
      'verticalFit': 'shrinkWrap',
      if (align != 'left') 'textAlignHorizontal': align,
      if (maxLines != null) ...<String, dynamic>{'maxLines': maxLines, 'overflow': 'ellipsis'},
      if (flex != null) 'flex': flex,
      'textMixedProps': <Map<String, dynamic>>[
        <String, dynamic>{
          'start': 0,
          'end': value.length,
          'fontSize': s.size,
          'fontName': <String, dynamic>{
            'family': s.family,
            'style': _styleName(s.weight),
            'weight': 'w${s.weight}',
          },
          'fills': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': _id('paint'),
              'type': 'solid',
              'color': c.rgbHex,
              if (c.opacity < 1) 'opacity': c.opacity,
            },
          ],
          'lineHeight': <String, dynamic>{'unit': 'percent', 'value': (s.lineHeight * 100).round()},
          if (s.letterSpacing != 0) 'letterSpacing': <String, dynamic>{'value': s.letterSpacing},
        },
      ],
      ...?extra,
    };
  }

  static String _styleName(int weight) => const <int, String>{
    100: 'Thin',
    200: 'ExtraLight',
    300: 'Light',
    400: 'Regular',
    500: 'Medium',
    600: 'SemiBold',
    700: 'Bold',
    800: 'ExtraBold',
    900: 'Black',
  }[weight] ?? 'Regular';

  Map<String, dynamic> _icon(String? name, {double size = 24, String color = 'onSurface'}) {
    String icon = name ?? fallbackIcon;
    String? boundName;
    if (icon.contains(r'${')) {
      // An icon named by data: drawn by name at runtime (`iconName`).
      boundName = icon;
      icon = fallbackIcon;
    } else if (!iconVocabulary.containsKey(icon)) {
      _report.warnings.add('Icon "$icon" is not in the vocabulary; drew "$fallbackIcon".');
      icon = fallbackIcon;
    }
    final String style = kit.icons['style'] ?? 'outlined';
    final bool outlined = style.contains('outline') && iconVocabulary.containsKey('${icon}_outlined');
    final String base = icon.endsWith('_outlined') ? icon.substring(0, icon.length - 9) : icon;
    final bool isOutlined = outlined || icon.endsWith('_outlined');
    return <String, dynamic>{
      'id': _id('icon'),
      'name': 'Icon $base',
      'type': 'icon',
      'basicBoxLocal': <num>[0, 0, size, size],
      'horizontalFit': 'fixed',
      'verticalFit': 'fixed',
      'properties': <String, dynamic>{
        'icon': <String, dynamic>{
          'icon': <String, dynamic>{
            'type': 'MATERIAL_ICON',
            'name': base,
            'style': isOutlined ? 'outlined' : 'filled',
            'codepoint': iconVocabulary[isOutlined ? '${base}_outlined' : base] ?? iconVocabulary[icon],
          },
          'color': _color(color).nodeHex,
          'size': size,
          'show': true,
        },
      },
      if (boundName != null) 'variables': <String, dynamic>{'iconName': boundName},
    };
  }

  Map<String, dynamic> _spacer(double size, {bool horizontal = false}) => <String, dynamic>{
    'id': _id('gap'),
    'name': 'Gap',
    'type': horizontal ? 'row' : 'column',
    'rowColumnType': horizontal ? 'row' : 'column',
    'basicBoxLocal': <num>[0, 0, horizontal ? size : 1, horizontal ? 1 : size],
    'horizontalFit': 'fixed',
    'verticalFit': 'fixed',
    'children': <Map<String, dynamic>>[],
  };

  Map<String, dynamic> _grow() => <String, dynamic>{
    'id': _id('grow'),
    'name': 'Spacer',
    'type': 'row',
    'rowColumnType': 'row',
    'basicBoxLocal': <num>[0, 0, 10, 10],
    'horizontalFit': 'expanded',
    'verticalFit': 'fixed',
    'children': <Map<String, dynamic>>[],
  };

  // ---------------------------------------------------------------- actions

  List<Map<String, dynamic>> _reactions(Object? action, {String trigger = 'click'}) {
    final List<Map<String, dynamic>> actions = _actions(action);
    return <Map<String, dynamic>>[
      for (final Map<String, dynamic> a in actions)
        <String, dynamic>{
          'id': _id('reaction'),
          'name': '${a['type']}',
          'trigger': <String, dynamic>{'type': trigger},
          'action': a,
        },
    ];
  }

  Map<String, dynamic> _var(String name, [String? type]) => <String, dynamic>{
    'id': 'var_$name',
    'name': name,
    if (type != null) 'type': type,
  };

  List<Map<String, dynamic>> _actions(Object? action) {
    if (action == null) return const [];
    if (action is List) return <Map<String, dynamic>>[for (final Object? a in action) ..._actions(a)];
    if (action is! Map) return const [];
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    switch (action['type']) {
      case 'navigate':
        final String to = '${action['to']}';
        final String? id = screens[to];
        if (id != null) {
          out.add(<String, dynamic>{
            'type': 'navigation',
            'navigationType': 'push',
            'destinationId': id,
            if (action['params'] is Map) 'params': action['params'],
          });
        } else {
          _report.unresolvedScreens.add(to);
          out.add(<String, dynamic>{'type': 'showToast', 'message': 'Opens $to'});
        }
      case 'back':
        out.add(<String, dynamic>{'type': 'navigation', 'navigationType': 'pop', 'destinationId': ''});
      case 'set':
        final Object? value = action['value'];
        out.add(<String, dynamic>{
          'type': 'setVariable',
          'variable': _var('${action['variable']}'),
          'newValue': value is String ? value : '$value',
        });
      case 'toggle':
        out.add(<String, dynamic>{
          'type': 'setVariable',
          'variable': _var('${action['variable']}', 'boolean'),
          'newValue': '\${= !${action['variable']}}',
        });
      case 'toast':
        out.add(<String, dynamic>{'type': 'showToast', 'message': '${action['message']}'});
      case 'link':
        out.add(<String, dynamic>{'type': 'link', 'url': '${action['url']}'});
      case 'submit':
        // Shows the loading state, then the result.
        out
          ..add(<String, dynamic>{'type': 'setVariable', 'variable': _var('status', 'text'), 'newValue': 'loading'})
          ..add(<String, dynamic>{'type': 'delay', 'milliseconds': 600})
          ..add(<String, dynamic>{'type': 'setVariable', 'variable': _var('status', 'text'), 'newValue': 'content'});
        if (action['message'] != null) {
          out.add(<String, dynamic>{'type': 'showToast', 'message': '${action['message']}'});
        }
      case 'retry':
        out
          ..add(<String, dynamic>{'type': 'setVariable', 'variable': _var('status', 'text'), 'newValue': 'loading'})
          ..add(<String, dynamic>{'type': 'delay', 'milliseconds': 600})
          ..add(<String, dynamic>{'type': 'setVariable', 'variable': _var('status', 'text'), 'newValue': 'content'});
      case 'speak':
        out.add(<String, dynamic>{
          'type': 'speak',
          'text': '${action['text']}',
          'language': '${action['language'] ?? 'en-US'}',
          'rate': '${action['rate'] ?? 1}',
        });
      case 'call':
        out.add(<String, dynamic>{
          'type': 'callFunction',
          'name': '${action['name']}',
          if (action['params'] is Map) 'params': action['params'],
        });
      case 'swipe':
        // The deck's top card flies off as if swiped (its swipe reactions run).
        out.add(<String, dynamic>{
          'type': 'controlDrag',
          'nodeId': '@deckcard',
          'command': 'fling',
          'direction': '${action['direction'] == 'left' ? 'left' : 'right'}',
        });
      case 'save':
        out.add(<String, dynamic>{
          'type': 'setStorage',
          'key': '${action['key']}',
          'variableType': '${action['valueType'] ?? 'text'}',
          'newValue': action['value'] is String ? action['value'] : jsonEncode(action['value']),
        });
      case 'generate':
        // The SDK's runtime generator registers `generateScreen` as an app
        // function (RuntimeScreenGenerator in codelessly_sdk).
        out.add(<String, dynamic>{
          'type': 'callFunction',
          'name': 'generateScreen',
          'params': <String, dynamic>{
            'prompt': '${action['prompt']}',
            if (action['kit'] != null) 'kit': '${action['kit']}',
          },
        });
    }
    if (action['then'] != null) out.addAll(_actions(action['then']));
    return out;
  }

  Map<String, dynamic> _wire(Map<String, dynamic> node, Object? action) {
    _report.interactive++;
    final List<Map<String, dynamic>> reactions = _reactions(action);
    if (reactions.isNotEmpty) {
      _report.wired++;
      node['reactions'] = <dynamic>[...?node['reactions'] as List?, ...reactions];
    }
    return node;
  }

  // ------------------------------------------------------------- the screen

  /// The content column's max width on this screen and breakpoint.
  double _contentMaxWidth = 1200;

  double _maxWidthFor(Map<String, dynamic> plan) {
    final String pattern = '${plan['pattern'] ?? 'custom'}';
    final bool narrowForm = const ['form', 'auth', 'onboarding'].contains(pattern) || (pattern == 'checkout' && _bp.mobile);
    if (!narrowForm || _bp.mobile) return _bp.grid.maxContent;
    final double form = double.tryParse(RegExp(r'\d+').firstMatch(kit.layout['formWidth'] ?? '')?[0] ?? '') ?? 460;
    final bool twoColumns = ((plan['sections'] as List?) ?? const []).any((dynamic s) => s is Map && s['area'] == 'aside');
    return twoColumns ? (form * 2 + _space(_bp.grid.gutter, 'lg')).clamp(0, _bp.grid.maxContent).toDouble() : form;
  }

  Map<String, dynamic> _screen(Map<String, dynamic> plan) {
    _contentMaxWidth = _maxWidthFor(plan);
    final Map<String, dynamic>? nav = plan['nav'] as Map<String, dynamic>?;
    final KitGuide navKit = _comp('navBar');
    final String desktopNav = _prop(navKit, 'desktop', 'rail');
    final String mobileNav = _prop(navKit, 'mobile', 'bottom');
    final bool sideNav = nav != null && !_bp.mobile && (desktopNav == 'rail' || desktopNav == 'sidebar');
    final bool topNav = nav != null && !_bp.mobile && desktopNav == 'top';

    final List<Map<String, dynamic>> main = <Map<String, dynamic>>[
      if (plan['appBar'] != null || topNav)
        _appBar((plan['appBar'] as Map<String, dynamic>?) ?? <String, dynamic>{'title': plan['title']}, topNav ? nav : null),
      _states(plan),
      if (nav != null && _bp.mobile && mobileNav != 'none') _bottomNav(nav),
    ];
    final Map<String, dynamic> column = _column('Screen', main, v: 'expanded', fill: 'background');
    if (!sideNav) return column;
    column['horizontalFit'] = 'expanded';
    column['flex'] = 1;
    return _row('Screen', <Map<String, dynamic>>[_sideNav(nav, desktopNav == 'sidebar' && _bp.desktop), column],
        v: 'expanded', cross: 'stretch', fill: 'background');
  }

  Map<String, dynamic> _appBar(Map<String, dynamic> bar, Map<String, dynamic>? nav) {
    final KitGuide k = _comp('appBar');
    final String fill = _colorProp(k, 'fill', 'surface') ?? 'surface';
    final String iconColor = _colorProp(k, 'iconColor', 'onSurface') ?? 'onSurface';
    final String? border = _colorProp(k, 'border', null);
    final bool centered = _prop(k, 'align', 'start') == 'center' && _bp.mobile;
    final String titleRole = _bp.mobile ? _prop(k, 'title', 'title') : (kit.typography.containsKey('headline') && nav == null ? 'title' : _prop(k, 'title', 'title'));
    final double margin = _space(_bp.grid.margin);
    final List<Map<String, dynamic>> children = <Map<String, dynamic>>[];
    final String? leading = bar['leading'] as String?;
    if (leading != null && leading != 'none') {
      final String icon = switch (leading) { 'menu' => 'menu', 'close' => 'close', _ => 'arrow_back' };
      children.add(_iconButton(<String, dynamic>{
        'icon': icon,
        'label': leading == 'back' ? 'Back' : leading,
        'action': bar['leadingAction'] ?? (leading == 'menu' ? <String, dynamic>{'type': 'toast', 'message': 'Menu'} : <String, dynamic>{'type': 'back'}),
      }, color: iconColor));
    }
    final Map<String, dynamic> title = _text('${bar['title'] ?? ''}', titleRole,
        color: _colorProp(k, 'titleColor', iconColor) ?? 'onSurface', name: 'App bar title',
        align: centered ? 'center' : 'left', maxLines: 1);
    title['flex'] = 1;
    children.add(title);
    if (nav != null) {
      for (final dynamic item in (nav['items'] as List)) {
        children.add(_topNavItem(item as Map<String, dynamic>, iconColor));
      }
    }
    for (final dynamic a in (bar['actions'] as List?) ?? const []) {
      children.add(_iconButton(a as Map<String, dynamic>, color: iconColor));
    }
    if (centered && children.length < 3) {
      // Balance the leading button so the title sits in the middle.
      if (leading != null && leading != 'none' && (bar['actions'] as List?)?.isEmpty != false) {
        children.add(_spacer(_num(_comp('button'), 'height', 48)));
      }
    }
    final List<num> padding = _pad(margin - (leading != null && leading != 'none' ? 12 : 0), 0, margin - 8, 0);
    final Map<String, dynamic>? borderExtra = border == null
        ? null
        : <String, dynamic>{
            'strokes': <Map<String, dynamic>>[_paint(border)],
            'strokeWeight': _num(k, 'borderWidth', 1),
            'strokeAlign': 'inside',
            'strokeSide': 'bottom',
          };
    if (!_bp.mobile && nav == null) {
      // The title lines up with the content column, which is centered at
      // its max width on wide screens.
      final Map<String, dynamic> inner = _row('App bar content', children,
          v: 'expanded',
          gap: _space('sm'),
          padding: padding,
          extra: <String, dynamic>{
            'constraints': <String, dynamic>{'maxWidth': _contentMaxWidth + 2 * margin},
          });
      return _row('App bar', <Map<String, dynamic>>[inner],
          v: 'fixed', height: _num(k, 'height', 64), main: 'center', cross: 'stretch', fill: fill, extra: borderExtra);
    }
    return _row('App bar', children,
        v: 'fixed',
        height: _num(k, 'height', 64),
        gap: _space('sm'),
        fill: fill,
        padding: padding,
        extra: border == null
            ? null
            : <String, dynamic>{
                'strokes': <Map<String, dynamic>>[_paint(border)],
                'strokeWeight': _num(k, 'borderWidth', 1),
                'strokeAlign': 'inside',
                'strokeSide': 'bottom',
              });
  }

  Map<String, dynamic> _topNavItem(Map<String, dynamic> item, String color) {
    final KitGuide k = _comp('navBar');
    final bool active = item['active'] == true;
    final String? indicator = _colorProp(k, 'indicator', null);
    final Map<String, dynamic> node = _row('Nav ${item['label']}', <Map<String, dynamic>>[
      _text('${item['label']}', 'label', color: active ? (_colorProp(k, 'active', 'primary') ?? 'primary') : color, h: 'shrinkWrap', name: 'Nav label'),
    ], h: 'shrinkWrap', v: 'fixed', height: 40, main: 'center', padding: _pad(_space('md'), 0, _space('md'), 0),
        radius: _radius('pill', 'md'), fill: active ? indicator : null);
    if (!active) _wire(node, item['action']);
    return node;
  }

  Map<String, dynamic> _bottomNav(Map<String, dynamic> nav) {
    final KitGuide k = _comp('navBar');
    final String activeColor = _colorProp(k, 'active', 'primary') ?? 'primary';
    final String inactive = _colorProp(k, 'inactive', 'onSurfaceVariant') ?? 'onSurfaceVariant';
    final String? indicator = _colorProp(k, 'indicator', null);
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
      for (final dynamic raw in nav['items'] as List)
        () {
          final Map<String, dynamic> item = raw as Map<String, dynamic>;
          final bool active = item['active'] == true;
          final Map<String, dynamic> iconNode = _icon('${item['icon']}', color: active ? activeColor : inactive);
          final Map<String, dynamic> cell = _column('Nav ${item['label']}', <Map<String, dynamic>>[
            if (indicator != null && active)
              _row('Indicator', <Map<String, dynamic>>[iconNode], h: 'shrinkWrap', v: 'fixed', height: 28,
                  main: 'center', padding: _pad(16, 0, 16, 0), radius: _radius('pill'), fill: indicator)
            else
              iconNode,
            _text('${item['label']}', 'caption', color: active ? activeColor : inactive, h: 'shrinkWrap', name: 'Nav label', maxLines: 1),
          ], h: 'expanded', v: 'expanded', main: 'center', cross: 'center', gap: _space('xs', 'sm'), flex: 1);
          if (!active) _wire(cell, item['action']);
          return cell;
        }(),
    ];
    return _row('Bottom nav', items,
        v: 'fixed',
        height: _num(k, 'height', 64),
        cross: 'stretch',
        fill: _colorProp(k, 'fill', 'surface'),
        extra: <String, dynamic>{
          'strokes': <Map<String, dynamic>>[_paint('outline')],
          'strokeWeight': 1,
          'strokeAlign': 'inside',
          'strokeSide': 'top',
        });
  }

  Map<String, dynamic> _sideNav(Map<String, dynamic> nav, bool sidebar) {
    final KitGuide k = _comp('navBar');
    final String activeColor = _colorProp(k, 'active', 'primary') ?? 'primary';
    final String inactive = _colorProp(k, 'inactive', 'onSurfaceVariant') ?? 'onSurfaceVariant';
    final String indicator = _colorProp(k, 'indicator', 'secondary') ?? 'secondary';
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (final dynamic raw in nav['items'] as List) {
      final Map<String, dynamic> item = raw as Map<String, dynamic>;
      final bool active = item['active'] == true;
      final String color = active ? activeColor : inactive;
      final Map<String, dynamic> cell = sidebar
          ? _row('Nav ${item['label']}', <Map<String, dynamic>>[
              _icon('${item['icon']}', color: color),
              _text('${item['label']}', 'label', color: color, name: 'Nav label', maxLines: 1, flex: 1),
            ], v: 'fixed', height: 48, gap: _space('sm'), padding: _pad(_space('md'), 0, _space('md'), 0),
              radius: _radius('pill', 'md'), fill: active ? indicator : null)
          : _column('Nav ${item['label']}', <Map<String, dynamic>>[
              _row('Indicator', <Map<String, dynamic>>[_icon('${item['icon']}', color: color)], h: 'shrinkWrap',
                  v: 'fixed', height: 32, main: 'center', padding: _pad(16, 0, 16, 0), radius: _radius('pill'),
                  fill: active ? indicator : null),
              _text('${item['label']}', 'caption', color: color, h: 'shrinkWrap', name: 'Nav label', maxLines: 1),
            ], cross: 'center', gap: _space('xs', 'sm'), padding: _pad(0, _space('xs', 'sm'), 0, _space('xs', 'sm')));
      if (!active) _wire(cell, item['action']);
      items.add(cell);
    }
    return _column(sidebar ? 'Sidebar' : 'Rail', items,
        h: 'fixed',
        v: 'expanded',
        gap: _space('sm'),
        padding: _pad(_space('sm'), _space('lg'), _space('sm'), _space('lg')),
        fill: _colorProp(k, 'fill', 'surface'),
        extra: <String, dynamic>{
          'basicBoxLocal': <num>[0, 0, sidebar ? _num(k, 'width', 240) : 88, 600],
          'strokes': <Map<String, dynamic>>[_paint('outline')],
          'strokeWeight': 1,
          'strokeAlign': 'inside',
          'strokeSide': 'right',
        });
  }

  // ----------------------------------------------------------------- states

  Map<String, dynamic> _states(Map<String, dynamic> plan) {
    final Map<String, dynamic> states = (plan['states'] as Map<String, dynamic>?) ?? const {};
    final Map<String, dynamic> content = _content(plan);
    Map<String, dynamic> message(String kind, Map<String, dynamic>? s) {
      final Map<String, dynamic> state = s ??
          <String, dynamic>{
            'title': kind == 'empty' ? 'Nothing here yet' : 'Something went wrong',
            'message': kind == 'empty' ? '' : 'Please try again.',
            if (kind == 'error') 'action': <String, dynamic>{'label': 'Try again', 'action': <String, dynamic>{'type': 'retry'}},
          };
      final double margin = _space(_bp.grid.margin);
      final Map<String, dynamic>? action = state['action'] as Map<String, dynamic>?;
      final String iconName = '${state['icon'] ?? (kind == 'empty' ? 'inbox' : 'error_outline')}';
      return _column('${kind[0].toUpperCase()}${kind.substring(1)} state', <Map<String, dynamic>>[
        _row('Icon badge', <Map<String, dynamic>>[
          _icon(iconName, size: 32, color: kind == 'error' ? 'error' : 'primary'),
        ], h: 'fixed', v: 'fixed', main: 'center', radius: _radius('pill'), fill: 'surfaceVariant',
            extra: <String, dynamic>{'basicBoxLocal': <num>[0, 0, 72, 72]}),
        _text('${state['title']}', 'title', align: 'center', name: 'State title'),
        if ((state['message'] ?? '').toString().isNotEmpty)
          _text('${state['message']}', 'body', color: 'onSurfaceVariant', align: 'center', name: 'State message'),
        if (action != null)
          _button(<String, dynamic>{
            'label': action['label'],
            'variant': action['variant'] ?? (kind == 'error' ? 'primary' : 'primary'),
            'action': action['action'],
            'fullWidth': false,
          }),
      ], v: 'expanded', main: 'center', cross: 'center', gap: _space('md'),
          padding: _pad(margin, margin, margin, margin),
          extra: <String, dynamic>{'constraints': <String, dynamic>{'maxWidth': 420}});
    }

    return <String, dynamic>{
      'id': _id('states'),
      'name': 'States',
      'type': 'variance',
      'basicBoxLocal': <num>[0, 0, _bp.width, 600],
      'horizontalFit': 'expanded',
      'verticalFit': 'expanded',
      'flex': 1,
      'currentVariantId': '${_prefix}_state_content',
      'variables': <String, dynamic>{'currentVariantId': r'${status}'},
      'variants': <Map<String, dynamic>>[
        <String, dynamic>{'id': '${_prefix}_state_content', 'name': 'content', 'content': content},
        <String, dynamic>{'id': '${_prefix}_state_loading', 'name': 'loading', 'content': _skeleton(content)},
        <String, dynamic>{'id': '${_prefix}_state_empty', 'name': 'empty', 'content': message('empty', states['empty'] as Map<String, dynamic>?)},
        <String, dynamic>{'id': '${_prefix}_state_error', 'name': 'error', 'content': message('error', states['error'] as Map<String, dynamic>?)},
      ],
    };
  }

  /// The loading state: [content]'s layout with every text, icon, image and
  /// control replaced by a quiet placeholder block, and nothing wired.
  Map<String, dynamic> _skeleton(Map<String, dynamic> content) {
    final String block = _color('surfaceVariant').rgbHex;
    final String line = _color('outline').rgbHex;
    Map<String, dynamic> bar(Map<String, dynamic> node, double w, double h, {double? radius}) => <String, dynamic>{
      'id': _id('skeleton'),
      'name': 'Skeleton',
      'type': 'row',
      'rowColumnType': 'row',
      'basicBoxLocal': <num>[0, 0, w, h],
      'horizontalFit': node['horizontalFit'] == 'expanded' ? 'expanded' : 'fixed',
      'verticalFit': node['verticalFit'] == 'expanded' ? 'expanded' : 'fixed',
      if (node['flex'] != null) 'flex': node['flex'],
      'fills': <Map<String, dynamic>>[<String, dynamic>{'id': _id('paint'), 'type': 'solid', 'color': block}],
      'cornerRadius': <Object>[radius ?? (h / 2).clamp(2, 6), true, 'circular'],
      'children': <Map<String, dynamic>>[],
    };
    Map<String, dynamic> walk(Map<String, dynamic> node, [double limit = double.infinity]) {
      final String type = '${node['type']}';
      final List<num> box = ((node['basicBoxLocal'] as List?) ?? <num>[0, 0, 100, 16]).cast<num>();
      switch (type) {
        case 'text':
          final List<dynamic> props = (node['textMixedProps'] as List?) ?? const [];
          final double size = props.isEmpty ? 14 : ((props.first as Map)['fontSize'] as num).toDouble();
          final String data = '${node['data']}';
          final bool flexible = node['horizontalFit'] == 'expanded';
          // A bar a little narrower than the text it stands for (about half
          // an em a character), so it never pushes its row wider.
          final double w = (data.contains(r'${') ? (node['horizontalFit'] == 'expanded' ? 120.0 : 40.0) : (data.length * size * 0.45).clamp(16, 240).toDouble()).clamp(4, limit).toDouble();
          final Map<String, dynamic> b = bar(node, w, (size * 0.9).roundToDouble());
          if (flexible) {
            b
              ..['horizontalFit'] = 'expanded'
              ..['constraints'] = <String, dynamic>{'maxWidth': w};
          }
          return <String, dynamic>{
            ..._row('Skeleton line', <Map<String, dynamic>>[b], v: 'fixed', height: size * 1.3,
                h: flexible ? 'expanded' : 'shrinkWrap'),
            if (node['flex'] != null) 'flex': node['flex'],
          };
        case 'icon':
          return bar(node, box[2].toDouble(), box[3].toDouble(), radius: box[2].toDouble() / 2);
        case 'textField':
        case 'switch':
        case 'checkbox':
          return bar(node, box[2].toDouble(), (box[3].toDouble()).clamp(12, 32).toDouble());
        case 'rectangle':
          return <String, dynamic>{
            ...node,
            'id': _id('skeleton'),
            'fills': <Map<String, dynamic>>[<String, dynamic>{'id': _id('paint'), 'type': 'solid', 'color': block}],
          }..remove('reactions');
      }
      final Map<String, dynamic> copy = <String, dynamic>{
        for (final MapEntry<String, dynamic> e in node.entries)
          if (!const {'reactions', 'interactionStates', 'effects', 'variables'}.contains(e.key)) e.key: e.value,
        'id': _id('skeleton'),
      };
      // Lists keep their data so the skeleton has as many rows.
      final Object? vars = node['variables'];
      if (vars is Map && vars['data'] != null) copy['variables'] = <String, dynamic>{'data': vars['data']};
      final List<dynamic>? fills = node['fills'] as List?;
      if (fills != null && fills.isNotEmpty) {
        // Brand fills (buttons, badges) turn into blocks; surfaces stay.
        final String color = '${(fills.first as Map)['color']}';
        final bool surface = color == _color('surface').rgbHex || color == _color('background').rgbHex;
        copy['fills'] = <Map<String, dynamic>>[
          <String, dynamic>{'id': _id('paint'), 'type': 'solid', 'color': surface ? color : block},
        ];
      }
      if (node['strokes'] != null) {
        copy['strokes'] = <Map<String, dynamic>>[<String, dynamic>{'id': _id('paint'), 'type': 'solid', 'color': line}];
      }
      final List<dynamic>? children = node['children'] as List?;
      if (children != null) {
        // Inside a fixed box, a bar is no wider than the box.
        final double inner = node['horizontalFit'] == 'fixed' ? box[2].toDouble() : limit;
        copy['children'] = <Map<String, dynamic>>[for (final dynamic c in children) walk(c as Map<String, dynamic>, inner)];
      }
      return copy;
    }

    final Map<String, dynamic> skeleton = walk(content)..['name'] = 'Loading skeleton';
    skeleton['variables'] = <String, dynamic>{'semanticLabel': 'Loading'};
    return skeleton;
  }

  // ---------------------------------------------------------------- content

  Map<String, dynamic> _content(Map<String, dynamic> plan) {
    final String pattern = '${plan['pattern'] ?? 'custom'}';
    final double margin = _space(_bp.grid.margin);
    final double sectionGap = _space(kit.layout['sectionGap'], 'lg');
    final List<Map<String, dynamic>> sections = <Map<String, dynamic>>[
      for (final dynamic s in (plan['sections'] as List)) s as Map<String, dynamic>,
    ];
    final bool narrowForm = const ['form', 'auth', 'onboarding'].contains(pattern) ||
        (pattern == 'checkout' && _bp.mobile);
    double maxWidth = _bp.grid.maxContent;
    if (narrowForm && !_bp.mobile) {
      final double form = double.tryParse(RegExp(r'\d+').firstMatch(kit.layout['formWidth'] ?? '')?[0] ?? '') ?? 460;
      // A form with a side column (a summary) gets room for both.
      final bool twoColumns = sections.any((Map<String, dynamic> s) => s['area'] == 'aside');
      maxWidth = twoColumns ? (form * 2 + _space(_bp.grid.gutter, 'lg')).clamp(0, _bp.grid.maxContent).toDouble() : form;
    }

    List<Map<String, dynamic>> build(Iterable<Map<String, dynamic>> list) =>
        <Map<String, dynamic>>[for (final Map<String, dynamic> s in list) _section(s)];

    final List<Map<String, dynamic>> full = sections.where((s) => s['area'] == 'full').toList();
    final List<Map<String, dynamic>> main = sections.where((s) => s['area'] == null || s['area'] == 'main').toList();
    final List<Map<String, dynamic>> aside = sections.where((s) => s['area'] == 'aside').toList();

    List<Map<String, dynamic>> body;
    if (_bp.mobile || aside.isEmpty) {
      // One column stacks the sections in plan order.
      body = build(sections);
    } else {
      final int mainFlex = _bp.desktop ? 2 : 1;
      final Map<String, dynamic> mainColumn = _column('Main', build(main), gap: sectionGap, flex: mainFlex);
      final Map<String, dynamic> asideColumn = _column('Aside', build(aside), gap: sectionGap, flex: 1);
      // The aside sits on the side it comes first on in the plan.
      final bool asideFirst = sections.indexOf(aside.first) < (main.isEmpty ? 1 << 30 : sections.indexOf(main.first));
      body = <Map<String, dynamic>>[
        ...build(full),
        _row('Split', asideFirst ? <Map<String, dynamic>>[asideColumn, mainColumn] : <Map<String, dynamic>>[mainColumn, asideColumn],
            cross: 'start', gap: _space(_bp.grid.gutter, 'lg')),
      ];
    }
    final Map<String, dynamic> inner = _column('Content', body,
        gap: sectionGap,
        extra: <String, dynamic>{'constraints': <String, dynamic>{'maxWidth': maxWidth}});
    return _column('Scroll', <Map<String, dynamic>>[inner],
        v: 'expanded',
        cross: 'center',
        scroll: true,
        main: narrowForm && !_bp.mobile ? 'center' : 'start',
        padding: _pad(margin, _bp.mobile ? margin : _space('xl', 'lg'), margin, _space('xxl', 'xl')));
  }

  Map<String, dynamic> _section(Map<String, dynamic> s) {
    final List<Map<String, dynamic>> children = <Map<String, dynamic>>[
      for (final dynamic c in s['children'] as List) c as Map<String, dynamic>,
    ];
    final String layout = '${s['layout'] ?? 'stack'}';
    final double gap = _space(s['gap'] as String?, _gapFor(layout));
    final List<Map<String, dynamic>> header = <Map<String, dynamic>>[
      if ((s['title'] ?? '').toString().isNotEmpty)
        _row('Section header', <Map<String, dynamic>>[
          _text('${s['title']}', kit.layout['sectionTitle'] ?? 'subtitle', name: 'Section title', flex: 1),
          if (s['action'] is Map)
            _linkButton(s['action'] as Map<String, dynamic>),
        ]),
    ];
    List<Map<String, dynamic>> body;
    if (layout == 'row') {
      body = <Map<String, dynamic>>[
        _row('Row', <Map<String, dynamic>>[for (final c in children) _component(c, inRow: true)],
            gap: gap, wrap: _bp.mobile && children.length > 2),
      ];
    } else if (layout == 'grid' || layout == 'cards') {
      final int columns = _columnsFor(s['columns'], layout == 'grid' ? 2 : 1);
      // A list or grid already lays out its own columns: it spans the
      // section instead of taking one cell.
      bool collection(Map<String, dynamic> c) => c['type'] == 'grid' || c['type'] == 'list';
      if (children.any(collection)) {
        body = <Map<String, dynamic>>[];
        final List<Map<String, dynamic>> run = <Map<String, dynamic>>[];
        void flush() {
          if (run.isEmpty) return;
          body.addAll(_chunked(run.map((c) => _component(c, inRow: columns > 1)).toList(), columns, gap));
          run.clear();
        }
        for (final Map<String, dynamic> c in children) {
          if (collection(c)) {
            flush();
            body.add(_component(c));
          } else {
            run.add(c);
          }
        }
        flush();
      } else {
        body = _chunked(children.map((c) => _component(c, inRow: columns > 1)).toList(), columns, gap);
      }
    } else {
      body = <Map<String, dynamic>>[for (final c in children) _component(c)];
    }
    final Map<String, dynamic> column = _column(
      'Section ${s['id'] ?? s['title'] ?? ''}'.trim(),
      <Map<String, dynamic>>[...header, ...body],
      gap: header.isEmpty ? gap : _space('md'),
    );
    if (header.isNotEmpty && body.length > 1) {
      // The header sits closer to its content than items to each other.
      column['children'] = <Map<String, dynamic>>[
        ...header,
        _column('Section body', body, gap: gap),
      ];
    }
    return column;
  }

  String _gapFor(String layout) => layout == 'stack' ? 'md' : 'md';

  int _columnsFor(Object? spec, int mobileDefault) {
    if (spec is num) return _bp.mobile ? mobileDefault : spec.toInt();
    if (spec is Map) {
      final Object? v = spec[_bp.name] ?? (_bp.name == 'tablet' ? spec['desktop'] : null) ?? spec['mobile'];
      if (v is num) {
        final int n = v.toInt();
        return _bp.name == 'tablet' && spec['tablet'] == null ? (n / 2).ceil().clamp(1, 4) : n;
      }
    }
    return _bp.mobile ? mobileDefault : _bp.desktop ? (mobileDefault + 2) : (mobileDefault + 1);
  }

  List<Map<String, dynamic>> _chunked(List<Map<String, dynamic>> items, int columns, double gap) {
    if (columns <= 1) return items;
    final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length; i += columns) {
      final List<Map<String, dynamic>> cells = <Map<String, dynamic>>[];
      for (int j = 0; j < columns; j++) {
        if (i + j < items.length) {
          final Map<String, dynamic> cell = items[i + j];
          cell['horizontalFit'] = 'expanded';
          cell['flex'] = 1;
          cells.add(cell);
        } else {
          final Map<String, dynamic> filler = _grow();
          filler['flex'] = 1;
          cells.add(filler);
        }
      }
      rows.add(_row('Grid row', cells, cross: 'stretch', gap: gap));
    }
    return rows;
  }

  // ------------------------------------------------------------- components

  Map<String, dynamic> _component(Map<String, dynamic> c, {bool inRow = false}) {
    final Map<String, dynamic> node = switch ('${c['type']}') {
      'text' => _text('${c['text']}', '${c['style'] ?? 'body'}',
          color: '${c['color'] ?? (c['style'] == 'caption' ? 'onSurfaceVariant' : 'onSurface')}',
          align: '${c['align'] ?? 'left'}', maxLines: _numOf(c['maxLines'])?.toInt()),
      'heading' => _heading(c),
      'image' => _image(c),
      'avatar' => _avatar(c),
      'icon' => _icon('${c['icon']}', size: _numOf(c['size']) ?? _num(kit.icons, 'size', 24),
          color: '${c['color'] ?? kit.icons['color'] ?? 'onSurfaceVariant'}'),
      'button' => _button(c, inRow: inRow),
      'iconButton' => _iconButton(c),
      'buttonRow' => _buttonRow(c),
      'input' => _input(c),
      'switchRow' => _switchRow(c),
      'checkbox' => _checkbox(c),
      'segmented' => _segmented(c),
      'tabs' => _segmented(<String, dynamic>{...c, 'options': c['tabs'], 'underline': true}),
      'chips' => _chips(c),
      'listRow' => _listRow(c),
      'list' => _list(c),
      'grid' => _grid(c),
      'card' => _card(c),
      'stat' => _stat(c),
      'keyValue' => _keyValue(c),
      'banner' => _banner(c),
      'badge' => _badge('${c['text']}', '${c['tone'] ?? 'info'}'),
      'divider' => _divider(),
      'progress' => _progress(c),
      'rating' => _rating(c),
      'group' => _group(c),
      'spacer' => _spacer(_space(c['size'] as String?, 'md')),
      'deck' => _deck(c),
      _ => _text('${c['text'] ?? ''}', 'body'),
    };
    if (c['visible'] is String) {
      (node['variables'] ??= <String, dynamic>{})['visible'] = c['visible'];
    }
    if (inRow && node['horizontalFit'] == 'expanded' && node['flex'] == null) node['flex'] = 1;
    return node;
  }

  Map<String, dynamic> _heading(Map<String, dynamic> c) {
    final bool big = c['size'] == 'large' || c['size'] == 'display';
    final String role = big ? (_bp.mobile ? 'headline' : 'display') : (_bp.mobile ? 'title' : 'headline');
    final String align = '${c['align'] ?? 'left'}';
    return _column('Heading', <Map<String, dynamic>>[
      if (c['eyebrow'] != null) _text('${c['eyebrow']}', 'caption', color: 'primary', name: 'Eyebrow', align: align),
      _text('${c['title']}', role, name: 'Title', align: align),
      if (c['subtitle'] != null) _text('${c['subtitle']}', 'body', color: 'onSurfaceVariant', name: 'Subtitle', align: align),
    ], gap: _space('xs', 'sm'), cross: align == 'center' ? 'center' : 'stretch');
  }

  double _aspect(Object? spec, double fallback) {
    final Match? m = RegExp(r'^(\d+(?:\.\d+)?)\s*[:/x]\s*(\d+(?:\.\d+)?)$').firstMatch('${spec ?? ''}'.trim());
    if (m == null) return fallback;
    return double.parse(m[1]!) / double.parse(m[2]!);
  }

  Map<String, dynamic> _image(Map<String, dynamic> c) {
    final String kind = '${c['kind'] ?? 'hero'}';
    final double aspect = _aspect(c['aspect'] ?? kit.imagery[kind == 'cover' ? 'coverAspect' : 'heroAspect'], kind == 'cover' ? 1 : 16 / 9);
    // A fixed height from the content width at this breakpoint keeps the
    // image's shape without an aspect-ratio box.
    final double contentWidth = (_bp.mobile ? _bp.width - 2 * _space(_bp.grid.margin) : (_bp.desktop ? 360.0 : 320.0));
    final double height = _numOf(c['height']) ??
        (kind == 'cover' ? (contentWidth.clamp(120, _bp.mobile ? 320 : 360)) / aspect : (_bp.mobile ? contentWidth : _bp.desktop ? 560.0 : 520.0) / aspect).roundToDouble();
    final String src = '${c['src'] ?? ''}';
    final bool fixedWidth = kind == 'cover' && !_bp.mobile;
    return <String, dynamic>{
      'id': _id('image'),
      'name': 'Image',
      'type': 'rectangle',
      'basicBoxLocal': <num>[0, 0, fixedWidth ? height * aspect : contentWidth, height],
      'horizontalFit': fixedWidth ? 'fixed' : 'expanded',
      'verticalFit': 'fixed',
      'cornerRadius': <Object>[_radius(c['radius'] as String? ?? kit.imagery['radius'], 'md'), true, 'circular'],
      'fills': <Map<String, dynamic>>[
        _paint(kit.imagery['placeholder'] ?? 'surfaceVariant'),
        if (src.isNotEmpty)
          <String, dynamic>{
            'id': _id('paint'),
            'type': 'image',
            'downloadUrl': src,
            'fit': 'cover',
            'sourceWidth': 800,
            'sourceHeight': (800 / aspect).round(),
          },
      ],
      'clipsContent': true,
    };
  }

  Map<String, dynamic> _avatar(Map<String, dynamic> c) {
    final KitGuide k = _comp('avatar');
    final double size = c['size'] == 'large' ? _num(k, 'size', 40) * 2 : _num(k, 'size', 40);
    final double radius = _radius(k['radius'], 'pill').clamp(0, size / 2).toDouble();
    final String src = '${c['src'] ?? ''}';
    final String initials = '${c['initials'] ?? ''}';
    return <String, dynamic>{
      ..._row('Avatar', <Map<String, dynamic>>[
        if (src.isEmpty) _text(initials.isEmpty ? '?' : initials, size > 60 ? 'title' : 'label', color: 'onSecondary', h: 'shrinkWrap'),
      ], h: 'fixed', v: 'fixed', main: 'center', fill: 'secondary', radius: radius),
      'basicBoxLocal': <num>[0, 0, size, size],
      if (src.isNotEmpty)
        'fills': <Map<String, dynamic>>[
          _paint('surfaceVariant'),
          <String, dynamic>{'id': _id('paint'), 'type': 'image', 'downloadUrl': src, 'fit': 'cover', 'sourceWidth': 200, 'sourceHeight': 200},
        ],
    };
  }

  Map<String, dynamic> _button(Map<String, dynamic> c, {bool inRow = false}) {
    final KitGuide k = _comp('button');
    final String variant = '${c['variant'] ?? 'primary'}';
    final Map<String, String> row = k.row(variant) ??
        k.row('primary') ??
        <String, String>{'fill': 'primary', 'text': 'onPrimary', 'border': 'none'};
    final String? fill = row['fill'] == null || row['fill'] == 'none' ? null : row['fill'];
    final String textColor = row['text'] ?? 'onPrimary';
    final String? border = row['border'] == null || row['border'] == 'none' ? null : row['border'];
    final double height = c['size'] == 'small' ? (_num(k, 'height', 48) * 0.75).roundToDouble() : _num(k, 'height', 48);
    // Full width on phones, except in a row or when small: there it hugs
    // its label, so it never gets squeezed below it.
    final bool full = c['fullWidth'] == true ||
        (c['fullWidth'] != false && _bp.mobile && !inRow && c['size'] != 'small' && variant != 'ghost');
    final String? shadow = variant == 'ghost' ? null : (row['shadow'] ?? k['shadow']);
    final double padX = _space(k['paddingX'], 'lg');
    final Map<String, dynamic> node = _row('Button ${c['label']}', <Map<String, dynamic>>[
      if (c['icon'] != null) _icon('${c['icon']}', size: _num(k, 'iconSize', 18), color: textColor),
      // A full-width button's label takes the room it has and ellipsizes.
      _text('${c['label']}', _prop(k, 'text', 'label'), color: textColor, h: full ? 'expanded' : 'shrinkWrap', name: 'Label', maxLines: 1,
          align: full && c['icon'] == null ? 'center' : 'left', flex: full && c['icon'] == null ? 1 : null),
    ],
        h: full ? 'expanded' : 'shrinkWrap',
        v: 'fixed',
        height: height,
        main: 'center',
        gap: _space('sm'),
        fill: fill,
        stroke: border,
        strokeWeight: _num(k, 'borderWidth', 2) > 0 && border != null ? _num(k, 'borderWidth', border == 'outline' ? 1.5 : 1.5) : 1,
        radius: _radius(k['radius'], 'md'),
        padding: _pad(padX, 0, padX, 0),
        effects: _shadow(shadow));
    node['variables'] = <String, dynamic>{'semanticLabel': '${c['label']}'};
    return _wire(node, c['action']);
  }

  Map<String, dynamic> _linkButton(Map<String, dynamic> action) => _button(<String, dynamic>{
    'label': action['label'] ?? 'See all',
    'variant': 'ghost',
    'size': 'small',
    'fullWidth': false,
    'action': action['action'] ?? action,
  })..['horizontalFit'] = 'shrinkWrap';

  Map<String, dynamic> _iconButton(Map<String, dynamic> c, {String? color}) {
    final double target = _num(kit.accessibility, 'minTouchTarget', 48);
    final String variant = '${c['variant'] ?? 'ghost'}';
    final Map<String, String>? row = variant == 'ghost' ? null : _comp('button').row(variant);
    final String iconColor = color ?? row?['text'] ?? (c['color'] as String?) ?? 'onSurface';
    final Map<String, dynamic> node = _row('Icon button ${c['label'] ?? c['icon']}', <Map<String, dynamic>>[
      _icon('${c['icon']}', color: iconColor),
    ], h: 'fixed', v: 'fixed', height: target, main: 'center', radius: _radius('pill'),
        fill: row == null || row['fill'] == 'none' ? null : row['fill'],
        extra: <String, dynamic>{'basicBoxLocal': <num>[0, 0, target, target]});
    node['variables'] = <String, dynamic>{'semanticLabel': '${c['label'] ?? c['icon']}'};
    return _wire(node, c['action']);
  }

  Map<String, dynamic> _buttonRow(Map<String, dynamic> c) {
    final List<Map<String, dynamic>> buttons = <Map<String, dynamic>>[
      for (final dynamic b in c['buttons'] as List) b as Map<String, dynamic>,
    ];
    if (_bp.mobile && buttons.length > 1 && c['stackOnMobile'] != false) {
      return _column('Buttons', <Map<String, dynamic>>[
        for (final b in buttons) _button(<String, dynamic>{...b, 'fullWidth': true}),
      ], gap: _space('sm'));
    }
    final List<Map<String, dynamic>> nodes = <Map<String, dynamic>>[
      for (final b in buttons) _button(<String, dynamic>{...b, 'fullWidth': _bp.mobile})..['flex'] = _bp.mobile ? 1 : null,
    ];
    for (final n in nodes) {
      if (n['flex'] == null) n.remove('flex');
    }
    return _row('Buttons', nodes,
        gap: _space('sm'),
        main: '${c['align'] ?? 'start'}' == 'end' ? 'end' : (c['align'] == 'center' ? 'center' : 'start'));
  }

  Map<String, dynamic> _input(Map<String, dynamic> c) {
    final KitGuide k = _comp('input');
    final String kind = '${c['kind'] ?? 'text'}';
    final KitTextStyle textStyle = _type(_prop(k, 'text', 'body'));
    final KitTextStyle hint = textStyle;
    final String bind = '${c['bind']}';
    final double padX = _space(k['paddingX'], 'md');
    final String? border = _colorProp(k, 'border', 'outline');
    Map<String, dynamic> style(KitTextStyle s, String color) => <String, dynamic>{
      'fontSize': s.size,
      'fontName': <String, dynamic>{'family': s.family, 'style': _styleName(s.weight), 'weight': 'w${s.weight}'},
      'fills': <Map<String, dynamic>>[_paint(color)],
    };
    const Map<String, dynamic> none = <String, dynamic>{
      'borderType': 'none',
      'borderSide': <String, dynamic>{'style': 'none', 'width': 0},
    };
    _report.interactive++;
    _report.wired++;
    final Map<String, dynamic> field = <String, dynamic>{
      'id': _id('field'),
      'name': 'Input $bind',
      'type': 'textField',
      'basicBoxLocal': <num>[0, 0, 240, textStyle.size * 1.4],
      'horizontalFit': 'expanded',
      'verticalFit': 'shrinkWrap',
      'flex': 1,
      'variables': <String, dynamic>{'inputValue': '\${$bind}', 'semanticLabel': '${c['label']}'},
      'reactions': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': _id('reaction'),
          'name': 'Set $bind',
          'trigger': <String, dynamic>{'type': 'changed'},
          'action': <String, dynamic>{'type': 'setVariable', 'variable': _var(bind), 'newValue': r'${value}'},
        },
      ],
      'properties': <String, dynamic>{
        'obscureText': kind == 'password',
        'keyboardType': switch (kind) { 'email' => 'emailAddress', 'number' => 'number', 'phone' => 'phone', 'multiline' => 'multiline', _ => 'text' },
        if (kind == 'multiline') 'maxLines': 4,
        'cursorColor': _hex(_prop(k, 'focusBorder', 'primary')),
        'inputStyle': style(textStyle, 'onSurface'),
        'decoration': <String, dynamic>{
          'hintText': '${c['hint'] ?? ''}',
          'hintStyle': style(hint, _prop(k, 'hintColor', 'onSurfaceVariant')),
          'isCollapsed': true,
          'border': none,
          'enabledBorder': none,
          'focusedBorder': none,
          'disabledBorder': none,
          'errorBorder': none,
          'focusedErrorBorder': none,
          'showCounter': false,
        },
      },
    };
    final Map<String, dynamic> box = _row('Field box', <Map<String, dynamic>>[
      if (c['icon'] != null || kind == 'search') _icon('${c['icon'] ?? 'search'}', size: 20, color: 'onSurfaceVariant'),
      field,
    ],
        v: kind == 'multiline' ? 'shrinkWrap' : 'fixed',
        height: _num(k, 'height', 48),
        gap: _space('sm'),
        fill: _colorProp(k, 'fill', 'surface'),
        stroke: border,
        strokeWeight: _num(k, 'borderWidth', 1),
        radius: _radius(k['radius'], 'md'),
        cross: kind == 'multiline' ? 'start' : 'center',
        padding: _pad(padX, kind == 'multiline' ? _space('sm') : 0, padX, kind == 'multiline' ? _space('sm') : 0));
    final String? focus = _colorProp(k, 'focusBorder', 'primary');
    if (focus != null) {
      box['interactionStates'] = <String, dynamic>{
        'focused': <String, dynamic>{
          box['id']: <String, dynamic>{
            'strokes': <Map<String, dynamic>>[<String, dynamic>{'type': 'solid', 'color': _color(focus).rgbHex, 'visible': true}],
            'strokeWeight': 2,
          },
        },
      };
    }
    return _column('Input ${c['label']}', <Map<String, dynamic>>[
      _text('${c['label']}', _prop(k, 'label', 'label'), color: _prop(k, 'labelColor', 'onSurface'), name: 'Field label'),
      box,
      if (c['helper'] != null) _text('${c['helper']}', 'caption', color: 'onSurfaceVariant', name: 'Helper'),
    ], gap: _space('xs', 'sm'));
  }

  Map<String, dynamic> _switchRow(Map<String, dynamic> c) {
    final KitGuide k = _comp('switch');
    final String bind = '${c['bind']}';
    _report.interactive++;
    _report.wired++;
    final Map<String, dynamic> sw = <String, dynamic>{
      'id': _id('switch'),
      'name': 'Switch $bind',
      'type': 'switch',
      'basicBoxLocal': <num>[0, 0, 52, 32],
      'horizontalFit': 'fixed',
      'verticalFit': 'fixed',
      'value': false,
      'variables': <String, dynamic>{'value': '\${$bind}'},
      'properties': <String, dynamic>{
        'activeTrackColor': _hex(_prop(k, 'active', 'primary')),
        'inactiveTrackColor': _hex(_visibleOn(_prop(k, 'inactive', 'outline'), 'surface')),
        'activeThumbColor': _hex('surface'),
        'inactiveThumbColor': _hex('surface'),
      },
      'reactions': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': _id('reaction'),
          'name': 'Set $bind',
          'trigger': <String, dynamic>{'type': 'changed'},
          'action': <String, dynamic>{'type': 'setVariable', 'variable': _var(bind, 'boolean'), 'newValue': r'${value}'},
        },
        ..._reactions(c['action'], trigger: 'changed'),
      ],
    };
    return _listRow(<String, dynamic>{
      'title': c['title'],
      'subtitle': c['subtitle'],
      'leading': c['icon'] == null ? null : <String, dynamic>{'icon': c['icon']},
      'trailingNode': sw,
      'divider': c['divider'],
    });
  }

  Map<String, dynamic> _checkbox(Map<String, dynamic> c) {
    final String bind = '${c['bind']}';
    _report.interactive++;
    _report.wired++;
    final Map<String, dynamic> box = <String, dynamic>{
      'id': _id('checkbox'),
      'name': 'Checkbox $bind',
      'type': 'checkbox',
      'basicBoxLocal': <num>[0, 0, 24, 24],
      'horizontalFit': 'fixed',
      'verticalFit': 'fixed',
      'value': false,
      'variables': <String, dynamic>{'value': '\${$bind}'},
      'properties': <String, dynamic>{
        'activeColor': _hex('primary'),
        'checkColor': _hex('onPrimary'),
      },
      'reactions': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': _id('reaction'),
          'name': 'Set $bind',
          'trigger': <String, dynamic>{'type': 'changed'},
          'action': <String, dynamic>{'type': 'setVariable', 'variable': _var(bind, 'boolean'), 'newValue': r'${value}'},
        },
      ],
    };
    return _row('Checkbox ${c['label']}', <Map<String, dynamic>>[
      box,
      _text('${c['label']}', 'body', flex: 1),
    ], gap: _space('sm'), v: 'fixed', height: _num(kit.accessibility, 'minTouchTarget', 48));
  }

  Map<String, dynamic> _segmented(Map<String, dynamic> c) {
    final KitGuide k = _comp(c['underline'] == true ? 'tabs' : 'chip');
    final String bind = '${c['bind']}';
    final List<String> options = <String>[for (final dynamic o in c['options'] as List) o is Map ? '${o['label'] ?? o['value']}' : '$o'];
    // Labels too long for equal segments read better as chips.
    final int longest = options.fold(0, (int m, String o) => o.length > m ? o.length : m);
    if (c['underline'] != true && (longest > 12 || options.length > 4)) {
      return _chips(<String, dynamic>{'items': options, 'bind': bind});
    }
    final bool underline = c['underline'] == true;
    final String selFill = _colorProp(k, 'selectedFill', underline ? null : 'secondary') ?? 'surface';
    final String selTextToken = _colorProp(k, underline ? 'active' : 'selectedText', underline ? (_comp('navBar')['active'] ?? 'primary') : 'onSecondary') ?? 'primary';
    // Active tab text is read on the page: keep it readable.
    final String selHex = underline ? _readable(selTextToken).nodeHex : _hex(selTextToken);
    final String text = _colorProp(k, underline ? 'inactive' : 'text', 'onSurfaceVariant') ?? 'onSurfaceVariant';
    final List<Map<String, dynamic>> cells = <Map<String, dynamic>>[];
    for (final String o in options) {
      final String quoted = o.replaceAll("'", r"\'");
      final String sel = '\${= $bind == \'$quoted\'}';
      final Map<String, dynamic> label = _text(o, 'label', color: text, h: 'shrinkWrap', name: 'Option', maxLines: 1);
      label['variables'] = <String, dynamic>{
        'textColor': '\${= $bind == \'$quoted\' ? \'$selHex\' : \'${_hex(text)}\'}',
      };
      final Map<String, dynamic> cell;
      if (underline) {
        final Map<String, dynamic> indicator = _row('Indicator', const <Map<String, dynamic>>[], v: 'fixed', height: 2)
          ..['fills'] = <Map<String, dynamic>>[<String, dynamic>{'id': _id('paint'), 'type': 'solid', 'color': selHex.length == 9 ? '#${selHex.substring(3)}' : selHex}]
          ..['variables'] = <String, dynamic>{'visible': sel};
        cell = _column('Tab $o', <Map<String, dynamic>>[
          _row('Tab label', <Map<String, dynamic>>[label], v: 'fixed', height: 42, main: 'center'),
          indicator,
        ], flex: 1);
      } else {
        label
          ..['horizontalFit'] = 'expanded'
          ..['textAlignHorizontal'] = 'center';
        cell = _row('Option $o', <Map<String, dynamic>>[label],
            v: 'fixed', height: 36, main: 'center',
            padding: _pad(_space('sm'), 0, _space('sm'), 0), radius: _radius('pill'),
            fill: 'surface', flex: 1);
        final String paintId = (cell['fills'] as List).first['id'] as String;
        cell['variables'] = <String, dynamic>{
          'fill-$paintId': '\${= $bind == \'$quoted\' ? \'${_hex(selFill)}\' : \'${_hex('surface')}\'}',
        };
      }
      cells.add(_wire(cell, <String, dynamic>{'type': 'set', 'variable': bind, 'value': o}));
      // A set action on a declared variable: counts as one wired control.
    }
    // On wide screens the control is as wide as its segments need, not
    // the whole column.
    final double segment = 150;
    final Map<String, dynamic>? cap = underline || _bp.mobile
        ? null
        : <String, dynamic>{'basicBoxLocal': <num>[0, 0, segment * options.length + 8, 44]};
    final String? border = underline ? null : _colorProp(k, 'border', null);
    return _row(underline ? 'Tabs' : 'Segmented', cells,
        gap: underline ? 0 : _space('xs', 'sm'),
        padding: underline ? null : _pad(4, 4, 4, 4),
        fill: underline ? null : 'surfaceVariant',
        radius: underline ? null : _radius('pill'),
        stroke: border,
        strokeWeight: _num(k, 'borderWidth', 1.5),
        h: underline || _bp.mobile ? 'expanded' : 'fixed',
        extra: underline
            ? <String, dynamic>{
                'strokes': <Map<String, dynamic>>[_paint('outline')],
                'strokeWeight': 1,
                'strokeAlign': 'inside',
                'strokeSide': 'bottom',
              }
            : cap);
  }

  Map<String, dynamic> _chip(String label, {bool selected = false, Object? action, String? icon, String? selectedWhen}) {
    final KitGuide k = _comp('chip');
    final String fill = selected ? (_colorProp(k, 'selectedFill', 'secondary') ?? 'secondary') : (_colorProp(k, 'fill', 'surfaceVariant') ?? 'surfaceVariant');
    final String text = selected ? (_colorProp(k, 'selectedText', 'onSecondary') ?? 'onSecondary') : (_colorProp(k, 'text', 'onSurface') ?? 'onSurface');
    final Map<String, dynamic> node = _row('Chip $label', <Map<String, dynamic>>[
      if (icon != null) _icon(icon, size: 16, color: text),
      _text(label, _prop(k, 'textStyle', 'label'), color: text, h: 'shrinkWrap', name: 'Chip label', maxLines: 1),
    ], h: 'shrinkWrap', v: 'fixed', height: _num(k, 'height', 32), main: 'center', gap: _space('xs', 'sm'),
        padding: _pad(_space('md'), 0, _space('md'), 0), radius: _radius(k['radius'], 'pill'), fill: fill,
        stroke: _colorProp(k, 'border', null), strokeWeight: _num(k, 'borderWidth', 1.5));
    if (selectedWhen != null) {
      // Selected while the formula holds: fill and label colors follow it.
      final String on = _hex(_colorProp(k, 'selectedFill', 'secondary') ?? 'secondary');
      final String off = _hex(_colorProp(k, 'fill', 'surfaceVariant') ?? 'surfaceVariant');
      final String onText = _hex(_colorProp(k, 'selectedText', 'onSecondary') ?? 'onSecondary');
      final String offText = _hex(_colorProp(k, 'text', 'onSurface') ?? 'onSurface');
      final String paintId = '${((node['fills'] as List).first as Map)['id']}';
      node['variables'] = <String, dynamic>{'fill-$paintId': '\${= $selectedWhen ? \'$on\' : \'$off\'}'};
      final Map<String, dynamic> labelNode = (node['children'] as List).last as Map<String, dynamic>;
      labelNode['variables'] = <String, dynamic>{...?labelNode['variables'] as Map<String, dynamic>?, 'textColor': '\${= $selectedWhen ? \'$onText\' : \'$offText\'}'};
    }
    if (action != null) _wire(node, action);
    return node;
  }

  Map<String, dynamic> _chips(Map<String, dynamic> c) {
    final Object? items = c['items'];
    final String? bind = c['bind'] as String?;
    if (items is String) {
      final Map<String, dynamic> chip = _chip(r'${item}', selectedWhen: bind == null ? null : '$bind == item');
      if (bind != null) _wire(chip, <String, dynamic>{'type': 'set', 'variable': bind, 'value': r'${item}'});
      return _list(<String, dynamic>{'items': items, 'wrap': true, 'itemNode': chip});
    }
    final List<Map<String, dynamic>> chips = <Map<String, dynamic>>[
      for (final dynamic raw in items as List)
        () {
          final String label = raw is Map ? '${raw['label']}' : '$raw';
          final bool selected = raw is Map && raw['selected'] == true;
          final Object? action = raw is Map && raw['action'] != null
              ? raw['action']
              : bind != null
              ? <String, dynamic>{'type': 'set', 'variable': bind, 'value': label}
              : null;
          final String quoted = label.replaceAll("'", r"\'");
          return _chip(label,
              selected: selected,
              action: action,
              icon: raw is Map ? raw['icon'] as String? : null,
              selectedWhen: bind == null ? null : "$bind == '$quoted'");
        }(),
    ];
    return _row('Chips', chips, gap: _space('sm'), wrap: true,
        extra: <String, dynamic>{'runSpacing': _space('sm')});
  }

  Map<String, dynamic> _leading(Object? spec, double size) {
    final KitGuide k = _comp('listRow');
    if (spec is! Map) return _icon('$spec', color: _prop(k, 'iconColor', 'onSurfaceVariant'));
    if (spec['image'] != null) {
      return <String, dynamic>{
        'id': _id('thumb'),
        'name': 'Thumbnail',
        'type': 'rectangle',
        'basicBoxLocal': <num>[0, 0, size, size],
        'horizontalFit': 'fixed',
        'verticalFit': 'fixed',
        'cornerRadius': <Object>[_radius(kit.imagery['radius'], 'sm').clamp(0, size / 2), true, 'circular'],
        'fills': <Map<String, dynamic>>[
          _paint('surfaceVariant'),
          <String, dynamic>{'id': _id('paint'), 'type': 'image', 'downloadUrl': '${spec['image']}', 'fit': 'cover', 'sourceWidth': 200, 'sourceHeight': 200},
        ],
      };
    }
    if (spec['avatar'] != null || spec['initials'] != null) {
      return _avatar(<String, dynamic>{'src': spec['avatar'], 'initials': spec['initials']});
    }
    if (spec['text'] != null) {
      return _row('Leading', <Map<String, dynamic>>[
        _text('${spec['text']}', 'label', color: 'onSurfaceVariant', h: 'shrinkWrap', align: 'center'),
      ], h: 'fixed', v: 'fixed', main: 'center', extra: <String, dynamic>{'basicBoxLocal': <num>[0, 0, 28, 28]});
    }
    return _row('Leading', <Map<String, dynamic>>[
      _icon('${spec['icon']}', size: 22, color: spec['color'] as String? ?? _prop(k, 'iconColor', 'onSurfaceVariant')),
    ], h: 'fixed', v: 'fixed', main: 'center', radius: _radius('md'), fill: spec['tone'] == 'plain' ? null : 'surfaceVariant',
        extra: <String, dynamic>{'basicBoxLocal': <num>[0, 0, size, size]});
  }

  Map<String, dynamic> _listRow(Map<String, dynamic> c) {
    final KitGuide k = _comp('listRow');
    final double padX = _space(k['paddingX'], 'md');
    final double padY = _space(k['paddingY'], 'sm');
    final Object? trailing = c['trailing'];
    final List<Map<String, dynamic>> trailingNodes = <Map<String, dynamic>>[];
    if (c['trailingNode'] is Map<String, dynamic>) {
      trailingNodes.add(c['trailingNode'] as Map<String, dynamic>);
    } else if (trailing == 'chevron' || (trailing == null && c['action'] != null)) {
      trailingNodes.add(_icon('chevron_right', color: 'onSurfaceVariant'));
    } else if (trailing is Map) {
      if (trailing['text'] != null) {
        trailingNodes.add(_text('${trailing['text']}', trailing['style'] as String? ?? 'label',
            color: trailing['color'] as String? ?? 'onSurfaceVariant', h: 'shrinkWrap', name: 'Trailing', maxLines: 1));
      }
      if (trailing['badge'] != null) trailingNodes.add(_badge('${trailing['badge']}', '${trailing['tone'] ?? 'info'}'));
      if (trailing['icon'] != null) {
        trailingNodes.add(trailing['action'] != null
            ? _iconButton(<String, dynamic>{'icon': trailing['icon'], 'label': trailing['label'], 'action': trailing['action']})
            : _icon('${trailing['icon']}', color: 'onSurfaceVariant'));
      }
      if (trailing['chevron'] == true) trailingNodes.add(_icon('chevron_right', color: 'onSurfaceVariant'));
    } else if (trailing is String && trailing != 'none') {
      trailingNodes.add(_text(trailing, 'label', color: 'onSurfaceVariant', h: 'shrinkWrap', name: 'Trailing', maxLines: 1));
    }
    final Map<String, dynamic> texts = _column('Texts', <Map<String, dynamic>>[
      _text('${c['title']}', _prop(k, 'title', 'subtitle'), name: 'Title', maxLines: 1),
      if (c['subtitle'] != null)
        _text('${c['subtitle']}', _prop(k, 'subtitle', 'caption'), color: 'onSurfaceVariant', name: 'Subtitle', maxLines: 2),
    ], gap: 2, flex: 1);
    final Map<String, dynamic> row = _row('Row ${c['title']}', <Map<String, dynamic>>[
      if (c['leading'] != null) _leading(c['leading'], _num(k, 'leadingSize', 40)),
      texts,
      ...trailingNodes,
    ],
        v: 'shrinkWrap',
        gap: _space(k['gap'], 'md'),
        padding: _pad(padX, padY, padX, padY),
        extra: <String, dynamic>{'constraints': <String, dynamic>{'minHeight': _num(k, 'minHeight', 56)}});
    final bool divider = (c['divider'] ?? (_prop(k, 'divider', 'yes') == 'yes')) == true;
    if (divider) {
      row['strokes'] = <Map<String, dynamic>>[_paint(_prop(_comp('divider'), 'color', 'outline'))];
      row['strokeWeight'] = _num(_comp('divider'), 'thickness', 1);
      row['strokeAlign'] = 'inside';
      row['strokeSide'] = 'bottom';
    }
    if (c['action'] != null) _wire(row, c['action']);
    return row;
  }

  Map<String, dynamic> _list(Map<String, dynamic> c) {
    final Object? items = c['items'];
    Map<String, dynamic> itemNode(Map<String, dynamic> spec) => c['itemNode'] as Map<String, dynamic>? ?? _component(spec);
    if (items is List) {
      // A static list: one node per item, with ${item.x} resolved.
      final Map<String, dynamic> template = (c['item'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{'type': 'listRow', 'title': r'${item}'};
      final List<Map<String, dynamic>> nodes = <Map<String, dynamic>>[
        for (final dynamic item in items) _component(_substitute(template, item) as Map<String, dynamic>),
      ];
      return _column('List', nodes, gap: _space(c['gap'] as String?, 'xs'));
    }
    final bool wrap = c['wrap'] == true;
    Map<String, dynamic> itemSpec = (c['item'] as Map?)?.cast<String, dynamic>() ?? const {};
    final (String filtered, Map<String, dynamic> spec) = _filterItems('$items', itemSpec);
    itemSpec = spec;
    final Map<String, dynamic> template = itemNode(itemSpec);
    if (!wrap) template['horizontalFit'] = 'expanded';
    final double gap = c['gap'] == null ? (wrap ? _space('sm') : 0) : _space(c['gap'] as String?);
    return <String, dynamic>{
      'id': _id('list'),
      'name': 'List',
      'type': 'listView',
      'basicBoxLocal': <num>[0, 0, 300, 200],
      'horizontalFit': 'expanded',
      'verticalFit': 'shrinkWrap',
      'isScrollable': false,
      if (wrap) 'scrollDirection': 'horizontal',
      'variables': <String, dynamic>{'data': filtered},
      'properties': <String, dynamic>{
        'separator': 'space',
        'separatorSpacing': gap,
        'hasSeparator': gap > 0,
        // The intrinsic wrap (no scrolling): spacing from the separator,
        // runs apart by runSpacing.
        if (wrap) ...<String, dynamic>{'wrap': true, 'runSpacing': gap},
      },
      'children': <Map<String, dynamic>>[template],
    };
  }

  /// An item `visible` formula on a bound list becomes a filter of the
  /// list's data, so hidden items take no room: `${packs}` with items
  /// visible when `item.kind == 'ladder'` lists
  /// `${= filter(packs, item => item.kind == 'ladder')}`.
  (String, Map<String, dynamic>) _filterItems(String items, Map<String, dynamic> spec) {
    final Match? list = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_.]*)\}$').firstMatch(items.trim());
    final Match? visible = RegExp(r'^\$\{=\s*(.+)\}$').firstMatch('${spec['visible'] ?? ''}'.trim());
    if (list == null || visible == null || !visible[1]!.contains('item')) return (items, spec);
    return (
      '\${= filter(${list[1]}, item => ${visible[1]})}',
      <String, dynamic>{...spec}..remove('visible'),
    );
  }

  /// Replaces `${item}` and `${item.x}` in [spec]'s strings with [item]'s
  /// values (static lists).
  Object? _substitute(Object? spec, Object? item) {
    if (spec is String) {
      return spec.replaceAllMapped(RegExp(r'\$\{item(?:\.([A-Za-z0-9_.]+))?\}'), (Match m) {
        Object? v = item;
        for (final String key in (m[1] ?? '').split('.').where((String k) => k.isNotEmpty)) {
          v = v is Map ? v[key] : null;
        }
        return v == null ? '' : '$v';
      });
    }
    if (spec is Map) return <String, dynamic>{for (final e in spec.entries) '${e.key}': _substitute(e.value, item)};
    if (spec is List) return <Object?>[for (final Object? v in spec) _substitute(v, item)];
    return spec;
  }

  Map<String, dynamic> _grid(Map<String, dynamic> c) {
    final Object? items = c['items'];
    final int columns = _columnsFor(c['columns'], 2);
    final double gap = _space(c['gap'] as String?, 'md');
    final Map<String, dynamic> spec = (c['item'] as Map?)?.cast<String, dynamic>() ?? const {};
    if (items is List) {
      return _column('Grid', _chunked(<Map<String, dynamic>>[
        for (final dynamic item in items) _component(_substitute(spec, item) as Map<String, dynamic>, inRow: columns > 1),
      ], columns, gap), gap: gap);
    }
    final (String filtered, Map<String, dynamic> itemSpec) = _filterItems('$items', spec);
    final Map<String, dynamic> template = _component(itemSpec);
    template['horizontalFit'] = 'expanded';
    template['verticalFit'] = 'expanded';
    final double extent = _numOf(c['itemHeight']) ?? _estimateHeight(spec, columns);
    return <String, dynamic>{
      'id': _id('grid'),
      'name': 'Grid',
      'type': 'gridView',
      'basicBoxLocal': <num>[0, 0, 600, 400],
      'horizontalFit': 'expanded',
      'verticalFit': 'shrinkWrap',
      'isScrollable': false,
      'allowedTypes': <String>[],
      'deniedTypes': <String>['gridView'],
      'useFlutterListView': false,
      'variables': <String, dynamic>{'data': filtered},
      'properties': <String, dynamic>{
        'gridDelegate': <String, dynamic>{
          'type': 'fixedCrossAxisCount',
          'crossAxisCount': columns,
          'mainAxisSpacing': gap,
          'crossAxisSpacing': gap,
          'mainAxisExtent': extent,
        },
      },
      'children': <Map<String, dynamic>>[template],
    };
  }

  /// The height of a grid cell: image + texts + padding, at this width.
  double _estimateHeight(Map<String, dynamic> spec, int columns) {
    final double content = _bp.mobile ? _bp.width - 2 * _space(_bp.grid.margin) : _bp.grid.maxContent.clamp(0, _bp.width - 2 * _space(_bp.grid.margin)).toDouble();
    final double cell = (content - (columns - 1) * _space('md')) / columns;
    double h = 0;
    final KitGuide card = _comp('card');
    final double pad = _space(card['padding'], 'md');
    if (spec['image'] != null) h += cell / _aspect(spec['aspect'] ?? kit.imagery['coverAspect'], 1);
    h += pad * 2;
    final double inner = cell - pad * 2;
    if (spec['title'] != null) h += _estimateChild(<String, dynamic>{'type': 'text', 'style': 'subtitle', 'text': _sample(spec['title'])}, inner) + 4;
    if (spec['subtitle'] != null) h += _estimateChild(<String, dynamic>{'type': 'text', 'style': 'caption', 'text': _sample(spec['subtitle'])}, inner) + 4;
    if (spec['meta'] != null || spec['price'] != null) h += _type('label').size * 1.4 + 4;
    if (spec['button'] != null) h += _num(_comp('button'), 'height', 48) * 0.75 + 8;
    if (spec['eyebrow'] != null) h += _type('caption').size * 1.4 + 4;
    if (spec['body'] != null) h += _estimateChild(<String, dynamic>{'type': 'text', 'style': 'body', 'text': _sample(spec['body'])}, inner) + 4;
    // Children (a price, a feature list...): their own estimate each.
    for (final dynamic child in (spec['children'] as List?) ?? const []) {
      h += _estimateChild(child, cell - pad * 2) + _space(_comp('card')['gap'], 'sm');
    }
    // Text wraps differently by font: leave room rather than clip.
    return (h * 1.25).clamp(80, 960).roundToDouble();
  }

  /// [text] with `${item.x}` replaced by the longest sample value of x in
  /// the plan's data lists (estimates size bound items by their content).
  String _sample(Object? text) => '$text'.replaceAllMapped(RegExp(r'\$\{item\.([A-Za-z0-9_]+)\}'), (Match m) {
    String longest = '';
    for (final Object? v in _data.values) {
      if (v is! List) continue;
      for (final Object? item in v) {
        final Object? field = item is Map ? item[m[1]] : null;
        final String value = field is List ? field.join(', ') : '${field ?? ''}';
        if (field != null && value.length > longest.length) longest = value;
      }
    }
    return longest.isEmpty ? 'Sample text value' : longest;
  });

  /// The rough height of a plan component laid out [width] wide.
  double _estimateChild(Object? c, double width) {
    if (c is! Map) return 0;
    double lines(String role, String text) {
      final KitTextStyle s = _type(role);
      final double perLine = (width / (s.size * 0.56)).clamp(8, 400);
      return s.size * s.lineHeight * (text.length / perLine).ceil().clamp(1, 8);
    }

    switch ('${c['type']}') {
      case 'text':
        return lines('${c['style'] ?? 'body'}', '${c['text']}');
      case 'heading':
        return lines(_bp.mobile ? 'title' : 'headline', '${c['title']}') + (c['subtitle'] == null ? 0 : lines('body', '${c['subtitle']}'));
      case 'button':
        return _num(_comp('button'), 'height', 48);
      case 'buttonRow':
        return _num(_comp('button'), 'height', 48) * (_bp.mobile ? ((c['buttons'] as List?)?.length ?? 1) : 1);
      case 'listRow':
        return _num(_comp('listRow'), 'minHeight', 56);
      case 'list':
        final Object? items = c['items'];
        final int n = items is List ? items.length : 4;
        return n * (_num(_comp('listRow'), 'minHeight', 56) * 0.8);
      case 'divider':
        return 1;
      case 'badge':
      case 'chips':
        return 32;
      case 'keyValue':
        return _type('body').size * 1.6 + 8;
      case 'group':
        final List<dynamic> kids = (c['children'] as List?) ?? const [];
        if (c['direction'] == 'row') {
          return kids.fold<double>(0, (double m, dynamic k) => _estimateChild(k, width / kids.length).clamp(m, double.infinity));
        }
        return kids.fold<double>(0, (double sum, dynamic k) => sum + _estimateChild(k, width) + _space('sm'));
      default:
        return 40;
    }
  }

  Map<String, dynamic> _card(Map<String, dynamic> c) {
    final KitGuide k = _comp('card');
    final double pad = _space(k['padding'], 'md');
    final List<Map<String, dynamic>> inner = <Map<String, dynamic>>[
      if (c['eyebrow'] != null) _text('${c['eyebrow']}', 'caption', color: 'primary', name: 'Eyebrow', maxLines: 1),
      if (c['title'] != null) _text('${c['title']}', c['titleStyle'] as String? ?? 'subtitle', name: 'Card title', maxLines: 2),
      if (c['subtitle'] != null) _text('${c['subtitle']}', 'caption', color: 'onSurfaceVariant', name: 'Card subtitle', maxLines: 2),
      if (c['body'] != null) _text('${c['body']}', 'body', color: 'onSurfaceVariant', name: 'Card body'),
      for (final dynamic child in (c['children'] as List?) ?? const []) _component(child as Map<String, dynamic>),
      if (c['meta'] != null || c['price'] != null)
        _row('Meta', <Map<String, dynamic>>[
          if (c['price'] != null) _text('${c['price']}', 'subtitle', color: 'onSurface', h: 'shrinkWrap', name: 'Price'),
          if (c['meta'] != null) _text('${c['meta']}', 'caption', color: 'onSurfaceVariant', name: 'Meta', maxLines: 1, flex: 1),
        ], gap: _space('sm')),
      if (c['button'] != null)
        _button(<String, dynamic>{...(c['button'] as Map).cast<String, dynamic>(), 'fullWidth': true, 'size': 'small'}),
    ];
    final bool hasImage = c['image'] != null;
    final Map<String, dynamic> body = _column('Card body', inner,
        gap: _space(k['gap'], 'sm'), padding: _pad(pad, pad, pad, pad));
    final double imageHeight = hasImage
        ? ((_bp.mobile ? 200.0 : 180.0) / _aspect(c['aspect'] ?? kit.imagery['coverAspect'], 1.5) * 1.5).clamp(120, 260).roundToDouble()
        : 0;
    final String? border = _colorProp(k, 'border', null);
    final Map<String, dynamic> card = _column('Card ${c['title'] ?? ''}'.trim(), <Map<String, dynamic>>[
      if (hasImage)
        <String, dynamic>{
          'id': _id('image'),
          'name': 'Card image',
          'type': 'rectangle',
          'basicBoxLocal': <num>[0, 0, 300, imageHeight],
          'horizontalFit': 'expanded',
          'verticalFit': c['verticalFit'] == 'expanded' ? 'expanded' : 'fixed',
          if (c['verticalFit'] == 'expanded') 'flex': 1,
          'fills': <Map<String, dynamic>>[
            _paint(kit.imagery['placeholder'] ?? 'surfaceVariant'),
            <String, dynamic>{'id': _id('paint'), 'type': 'image', 'downloadUrl': '${c['image']}', 'fit': 'cover', 'sourceWidth': 600, 'sourceHeight': 400},
          ],
        },
      if (inner.isNotEmpty) body,
    ],
        fill: _colorProp(k, 'fill', 'surface'),
        stroke: border,
        strokeWeight: _num(k, 'borderWidth', 1),
        radius: _radius(k['radius'], 'lg'),
        effects: _shadow(k['shadow']),
        extra: <String, dynamic>{'clipsContent': true});
    if (c['action'] != null) _wire(card, c['action']);
    return card;
  }

  Map<String, dynamic> _stat(Map<String, dynamic> c) {
    final String tone = '${c['tone'] ?? (('${c['delta'] ?? ''}').startsWith('-') ? 'error' : 'success')}';
    return _card(<String, dynamic>{
      'children': <Map<String, dynamic>>[
        <String, dynamic>{'type': 'text', 'text': c['label'], 'style': 'caption', 'color': 'onSurfaceVariant'},
        <String, dynamic>{'type': 'text', 'text': c['value'], 'style': _bp.mobile ? 'title' : 'headline'},
        if (c['delta'] != null)
          <String, dynamic>{'type': 'text', 'text': c['delta'], 'style': 'caption', 'color': tone == 'neutral' ? 'onSurfaceVariant' : tone},
      ],
      if (c['action'] != null) 'action': c['action'],
    });
  }

  Map<String, dynamic> _keyValue(Map<String, dynamic> c) {
    final bool strong = c['emphasis'] == true;
    return _row('Key value', <Map<String, dynamic>>[
      _text('${c['label']}', strong ? 'subtitle' : 'body', color: strong ? 'onSurface' : 'onSurfaceVariant', flex: 1, name: 'Key'),
      _text('${c['value']}', strong ? 'subtitle' : 'body', h: 'shrinkWrap', name: 'Value', align: 'right'),
    ], gap: _space('md'), padding: _pad(0, _space('xs', 'sm'), 0, _space('xs', 'sm')));
  }

  Map<String, dynamic> _banner(Map<String, dynamic> c) {
    final KitGuide k = _comp('banner');
    final String tone = '${c['tone'] ?? 'info'}';
    final Map<String, String>? row = k.row(tone == 'neutral' ? 'info' : tone);
    final String fill = row?['fill'] ?? (tone == 'info' || tone == 'neutral' ? 'secondary' : tone);
    final String text = row?['text'] ?? 'onSecondary';
    final double pad = _space(k['padding'], 'md');
    final String icon = '${c['icon'] ?? switch (tone) { 'success' => 'check_circle', 'warning' => 'warning', 'error' => 'error_outline', _ => 'info' }}';
    final Map<String, dynamic> node = _row('Banner', <Map<String, dynamic>>[
      _icon(icon, color: text),
      _column('Banner texts', <Map<String, dynamic>>[
        _text('${c['title']}', 'subtitle', color: text, name: 'Banner title'),
        if (c['message'] != null) _text('${c['message']}', 'body', color: text, name: 'Banner message'),
      ], gap: 2, flex: 1),
      if (c['action'] is Map)
        _button(<String, dynamic>{
          'label': (c['action'] as Map)['label'] ?? 'View',
          'variant': 'outline',
          'size': 'small',
          'fullWidth': false,
          'action': (c['action'] as Map)['action'] ?? c['action'],
        }),
    ], cross: 'start', gap: _space('sm'), fill: fill, radius: _radius(k['radius'], 'md'), padding: _pad(pad, pad, pad, pad));
    return node;
  }

  Map<String, dynamic> _badge(String text, String tone) {
    final Match? bound = RegExp(r'^\$\{=?\s*([^}]+)\}$').firstMatch(tone.trim());
    if (bound != null) return _boundBadge(text, bound[1]!.trim());
    final KitGuide k = _comp('badge');
    final String fill = tone == 'info' || tone == 'neutral' ? (_colorProp(k, 'fill', 'secondary') ?? 'secondary') : tone;
    final String color = tone == 'info' || tone == 'neutral' ? (_colorProp(k, 'text', 'onSecondary') ?? 'onSecondary') : (tone == 'error' ? 'onError' : 'onPrimary');
    return _row('Badge', <Map<String, dynamic>>[
      _text(text, _prop(k, 'textStyle', 'caption'), color: color, h: 'shrinkWrap', name: 'Badge text', maxLines: 1),
    ], h: 'shrinkWrap', v: 'shrinkWrap', main: 'center', padding: _pad(_space('sm'), 2, _space('sm'), 2),
        radius: _radius(k['radius'], 'pill'), fill: fill);
  }

  /// A badge whose tone comes from data (`${item.tone}`): fill and text
  /// colors picked by a formula among the kit's tone colors.
  Map<String, dynamic> _boundBadge(String text, String expr) {
    const List<String> tones = <String>['success', 'warning', 'error', 'info'];
    final Map<String, Map<String, dynamic>> byTone = <String, Map<String, dynamic>>{
      for (final String t in tones) t: _badge(text, t),
    };
    String pick(String Function(Map<String, dynamic> badge) hexOf) {
      final StringBuffer f = StringBuffer(r'${= ');
      for (final String t in tones.take(3)) {
        f.write("$expr == '$t' ? '${hexOf(byTone[t]!)}' : ");
      }
      f.write("'${hexOf(byTone['info']!)}'}");
      return f.toString();
    }

    String fillOf(Map<String, dynamic> b) => '${((b['fills'] as List).first as Map)['color']}';
    String textOf(Map<String, dynamic> b) {
      final Map<String, dynamic> label = (b['children'] as List).first as Map<String, dynamic>;
      return '${(((label['textMixedProps'] as List).first as Map)['fills'] as List).first['color']}';
    }

    final Map<String, dynamic> badge = byTone['info']!;
    final Map<String, dynamic> label = (badge['children'] as List).first as Map<String, dynamic>;
    final String paintId = '${((badge['fills'] as List).first as Map)['id']}';
    badge['variables'] = <String, dynamic>{'fill-$paintId': pick(fillOf)};
    label['variables'] = <String, dynamic>{...?label['variables'] as Map<String, dynamic>?, 'textColor': pick(textOf)};
    return badge;
  }

  /// A swipeable, flippable stack of cards over a list binding: the top
  /// card follows the finger, springs back or flies off left/right (running
  /// swipeLeft/swipeRight), and a tap flips it in 3D to its back.
  Map<String, dynamic> _deck(Map<String, dynamic> c) {
    final KitGuide k = _comp('card');
    final String flipped = '${c['flipVariable'] ?? 'flipped'}';
    _deckFlipVariables.add(flipped);
    final double w = _bp.mobile ? (_bp.width - 2 * _space(_bp.grid.margin)).clamp(200, 360).toDouble() : 400;
    final double h = (_numOf(c['height']) ?? (_bp.mobile ? 420 : 460)).toDouble();
    final double pad = _space(k['padding'], 'lg');
    final String? border = _colorProp(k, 'border', null);
    final Map<String, dynamic> flipAction = <String, dynamic>{'type': 'toggle', 'variable': flipped};
    Map<String, dynamic> face(String name, List<dynamic> children, {required bool back}) {
      final Map<String, dynamic> node = _column(name, <Map<String, dynamic>>[
        for (final dynamic child in children) _component(child as Map<String, dynamic>),
      ],
          h: 'expanded',
          v: 'expanded',
          main: 'center',
          cross: 'stretch',
          gap: _space('md'),
          fill: back ? (_colorProp(k, 'backFill', 'surfaceVariant') ?? 'surfaceVariant') : (_colorProp(k, 'fill', 'surface') ?? 'surface'),
          stroke: border,
          strokeWeight: _num(k, 'borderWidth', 1),
          radius: _radius(k['radius'], 'lg'),
          padding: _pad(pad, pad, pad, pad),
          effects: _shadow(k['shadow'] ?? 'medium'),
          extra: <String, dynamic>{
            'positioningMode': 'align',
            'alignment': <String, dynamic>{'data': <String, dynamic>{'x': 0, 'y': 0}},
            'motion': <String, dynamic>{if (back) 'rotateY': 180, 'backfaceHidden': true},
          });
      return _wire(node, flipAction);
    }

    Map<String, dynamic> frame(String name, List<Map<String, dynamic>> children, {Map<String, dynamic>? extra}) => <String, dynamic>{
      'id': _id('frame'),
      'name': name,
      'type': 'frame',
      'basicBoxLocal': <num>[0, 0, w, h],
      'horizontalFit': 'expanded',
      'verticalFit': 'expanded',
      'clipsContent': false,
      'children': children,
      ...?extra,
    };

    Map<String, dynamic> stamp(String label, String tone, String direction, double angle) {
      final String toneColor = tone;
      final Map<String, dynamic> node = _row('Stamp $label', <Map<String, dynamic>>[
        _text(label, 'title', color: toneColor, h: 'shrinkWrap', name: 'Stamp label'),
      ], h: 'shrinkWrap', v: 'shrinkWrap', padding: _pad(_space('md'), _space('xs', 'sm'), _space('md'), _space('xs', 'sm')),
          stroke: toneColor, strokeWeight: 3, radius: _radius('md'), fill: 'surface');
      final String amount = "(index == 0 && drag.direction == '$direction' ? min(1, drag.$direction) : 0)";
      node['positioningMode'] = 'pin';
      node['edgePins'] = direction == 'right' ? <String, num>{'left': pad, 'top': pad} : <String, num>{'right': pad, 'top': pad};
      node['motion'] = <String, dynamic>{'rotate': angle, 'opacity': 0};
      node['variables'] = <String, dynamic>{'motion.opacity': '\${= $amount}'};
      return node;
    }

    final Map<String, dynamic> labels = (c['labels'] as Map?)?.cast<String, dynamic>() ?? const {'right': 'Known', 'left': 'Review'};
    final Map<String, dynamic> flip = frame('Flip', <Map<String, dynamic>>[
      face('Front', (c['front'] as List?) ?? const [], back: false),
      if (c['back'] is List) face('Back', c['back'] as List, back: true),
    ], extra: <String, dynamic>{
      'positioningMode': 'align',
      'alignment': <String, dynamic>{'data': <String, dynamic>{'x': 0, 'y': 0}},
      'motion': <String, dynamic>{
        'perspective': 1.25,
        'durationMs': kit.motion['emphasized']?.durationMs ?? 420,
        'curve': 'easeInOut',
        'keyframes': <Map<String, num>>[<String, num>{'t': 0.5, 'scale': 1.05}],
      },
      'variables': <String, dynamic>{'motion.rotateY': '\${= index == 0 && $flipped ? 180 : 0}'},
    });
    final Map<String, dynamic> card = frame('Deck card', <Map<String, dynamic>>[
      flip,
      if (labels['right'] != null) stamp('${labels['right']}', 'success', 'right', -12),
      if (labels['left'] != null) stamp('${labels['left']}', 'error', 'left', 12),
    ], extra: <String, dynamic>{
      'drag': <String, dynamic>{
        'axis': 'free',
        'release': 'dismiss',
        'directions': <String>['left', 'right'],
        'distanceThreshold': 0.35,
        'velocityThreshold': 800,
        'rotateFactor': 15,
        'originX': 0,
        'originY': 1.5,
        'resistance': 0,
        'snapBackMs': 520,
        'snapCurve': 'spring',
        'flyOutMs': 380,
        'flyOutRotate': 20,
      },
      // Cards behind the top one sit lower and smaller, and rise when it
      // leaves (the list keys items by id, so they animate).
      'motion': <String, dynamic>{'originY': 1, 'durationMs': 340, 'curve': 'easeOutBack'},
      'variables': <String, dynamic>{
        'drag.enabled': r'${= index == 0}',
        'motion.translateY': r'${= min(index, 3) * 14}',
        'motion.scale': r'${= 1 - min(index, 3) * 0.05}',
      },
    });
    _report.interactive++;
    card
      ..['id'] = '${_prefix}_deck_card'
      ..['key'] = 'deckcard';
    // Bound to a variable, the deck advances itself: right drops the top
    // card, left sends it to the back of the queue.
    final String? queue = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$').firstMatch('${c['items']}'.trim())?[1];
    final bool advance = queue != null && c['advance'] != false;
    final List<Map<String, dynamic>> reactions = <Map<String, dynamic>>[
      for (final (String side, String trigger) in const <(String, String)>[('swipeRight', 'swipeRight'), ('swipeLeft', 'swipeLeft')])
        ..._reactions(<Object?>[
          <String, dynamic>{'type': 'set', 'variable': flipped, 'value': 'false'},
          if (c[side] != null) c[side],
          if (advance)
            <String, dynamic>{
              'type': 'set',
              'variable': queue,
              'value': side == 'swipeRight' ? '\${= slice($queue, 1)}' : '\${= append(slice($queue, 1), $queue[0])}',
            },
        ], trigger: trigger),
    ];
    if (c['swipeRight'] != null || c['swipeLeft'] != null) _report.wired++;
    card['reactions'] = reactions;
    final Map<String, dynamic> list = <String, dynamic>{
      'id': _id('deck'),
      'name': 'Deck',
      'type': 'listView',
      'basicBoxLocal': <num>[0, 0, w, h],
      'horizontalFit': 'fixed',
      'verticalFit': 'fixed',
      'isScrollable': false,
      'clipsContent': false,
      'variables': <String, dynamic>{'data': '${c['items']}'},
      'properties': <String, dynamic>{'stacked': true},
      'children': <Map<String, dynamic>>[card],
    };
    return _column('Deck area', <Map<String, dynamic>>[list],
        cross: 'center', padding: _pad(0, _space('sm'), 0, 3 * 14 + _space('sm')));
  }

  Map<String, dynamic> _divider() => _row('Divider', const <Map<String, dynamic>>[],
      v: 'fixed', height: _num(_comp('divider'), 'thickness', 1), fill: _prop(_comp('divider'), 'color', 'outline'));

  Map<String, dynamic> _progress(Map<String, dynamic> c) {
    final Object? value = c['value'];
    final Map<String, dynamic> bar = _row('Progress value', const <Map<String, dynamic>>[],
        v: 'fixed', height: 8, fill: '${c['color'] ?? 'primary'}', radius: _radius('pill'));
    bar['motion'] = <String, dynamic>{'scaleX': value is num ? value.toDouble().clamp(0, 1) : 0.5, 'originX': -1, 'durationMs': kit.motion['standard']?.durationMs ?? 250};
    if (value is String) bar['variables'] = <String, dynamic>{'motion.scaleX': value};
    return _column('Progress', <Map<String, dynamic>>[
      if (c['label'] != null)
        _row('Progress labels', <Map<String, dynamic>>[
          _text('${c['label']}', 'label', flex: 1, name: 'Progress label'),
          if (c['caption'] != null) _text('${c['caption']}', 'caption', color: 'onSurfaceVariant', h: 'shrinkWrap', name: 'Progress caption'),
        ]),
      _row('Track', <Map<String, dynamic>>[bar], v: 'fixed', height: 8, fill: 'surfaceVariant', radius: _radius('pill'), extra: <String, dynamic>{'clipsContent': true}),
    ], gap: _space('xs', 'sm'));
  }

  Map<String, dynamic> _rating(Map<String, dynamic> c) {
    final Object? value = c['value'];
    final int max = _numOf(c['max'])?.toInt() ?? 5;
    final String color = kit.colors.containsKey('accent') ? 'accent' : 'warning';
    final List<Map<String, dynamic>> stars = <Map<String, dynamic>>[];
    for (int i = 1; i <= max; i++) {
      if (value is num) {
        stars.add(_icon(value >= i - 0.25 ? 'star' : value >= i - 0.75 ? 'star_half' : 'star_border', size: 18, color: color));
        continue;
      }
      final Map<String, dynamic> star = _icon('star', size: 18, color: color);
      if (value is String) {
        // Full, half or empty by the bound value.
        final String expr = value.replaceAll(RegExp(r'^\$\{=?\s*|\}$'), '');
        star['variables'] = <String, dynamic>{
          'iconName': '\${= ($expr) >= ${i - 0.25} ? \'star\' : ($expr) >= ${i - 0.75} ? \'star_half\' : \'star_border\'}',
        };
      }
      stars.add(star);
    }
    return _row('Rating', <Map<String, dynamic>>[
      ...stars,
      if (c['label'] != null) _text('${c['label']}', 'caption', color: 'onSurfaceVariant', h: 'shrinkWrap', name: 'Rating label'),
    ], h: 'shrinkWrap', gap: 2);
  }

  Map<String, dynamic> _group(Map<String, dynamic> c) {
    final bool row = c['direction'] == 'row';
    final List<Map<String, dynamic>> children = <Map<String, dynamic>>[
      for (final dynamic child in c['children'] as List) _component(child as Map<String, dynamic>, inRow: row),
    ];
    final String align = '${c['align'] ?? (row ? 'center' : 'stretch')}';
    // A row of fixed-width things (buttons, chips) wraps on a phone rather
    // than run off the edge.
    final bool rigid = children.every((Map<String, dynamic> n) => n['flex'] == null && n['horizontalFit'] != 'expanded');
    final Map<String, dynamic> node = row
        ? _row('Group', children, gap: _space(c['gap'] as String?, 'sm'), cross: align == 'stretch' ? 'center' : align,
            main: '${c['justify'] ?? 'start'}', wrap: c['wrap'] == true || (!_bp.desktop && rigid && children.length > 1))
        : _column('Group', children, gap: _space(c['gap'] as String?, 'sm'), cross: align);
    if (c['surface'] == true) {
      final KitGuide k = _comp('card');
      final double pad = _space(k['padding'], 'md');
      node['fills'] = <Map<String, dynamic>>[_paint(_colorProp(k, 'fill', 'surface') ?? 'surface')];
      node['cornerRadius'] = <Object>[_radius(k['radius'], 'lg'), true, 'circular'];
      node['padding'] = _pad(pad, pad, pad, pad);
    }
    if (c['action'] != null) _wire(node, c['action']);
    return node;
  }

  /// A number from a plan field that may be a number, a numeric string or
  /// a word (`"large"`): null unless it reads as a number.
  static double? _numOf(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };

  static String _typeOf(Object? value) => switch (value) {
    bool() => 'boolean',
    int() => 'integer',
    double() => 'decimal',
    List() => 'list',
    Map() => 'map',
    _ => 'text',
  };

  static Object? _defaultFor(Object? type) => switch (type) {
    'boolean' => false,
    'integer' => 0,
    'decimal' => 0.0,
    'list' => <Object?>[],
    'map' => <String, Object?>{},
    _ => '',
  };
}
