/// The screen plan: the JSON an LLM writes for a one-line prompt, which the
/// [ScreenCompiler] turns into Codelessly node trees. A plan names sections,
/// components, data bindings, actions and the loading, empty and error
/// states, and refers to the design kit only by token names, never by raw
/// colors or sizes, so every compiled screen is on-brand by construction.
library;

import 'design_kit.dart';

/// Component types a plan may use, with their required fields.
const Map<String, List<String>> planComponents = <String, List<String>>{
  'text': ['text'],
  'heading': ['title'],
  'image': [],
  'avatar': [],
  'icon': ['icon'],
  'button': ['label', 'action'],
  'iconButton': ['icon', 'action'],
  'buttonRow': ['buttons'],
  'input': ['label'],
  'switchRow': ['title'],
  'checkbox': ['label'],
  'segmented': ['options'],
  'chips': ['items'],
  'listRow': ['title'],
  'list': ['items', 'item'],
  'grid': ['items', 'item'],
  'card': [],
  'stat': ['label', 'value'],
  'keyValue': ['label', 'value'],
  'banner': ['title'],
  'badge': ['text'],
  'divider': [],
  'progress': ['value'],
  'rating': ['value'],
  'tabs': ['tabs'],
  'group': ['children'],
  'spacer': [],
  'deck': ['items', 'front'],
};

/// Action types a plan may use.
const Map<String, List<String>> planActions = <String, List<String>>{
  'navigate': ['to'],
  'back': [],
  'set': ['variable', 'value'],
  'toggle': ['variable'],
  'toast': ['message'],
  'link': ['url'],
  'submit': [],
  'retry': [],
  'speak': ['text'],
  'call': ['name'],
  'generate': ['prompt'],
  'save': ['key', 'value'],
  'swipe': ['direction'],
};

/// Screen-level patterns; they pick the desktop arrangement.
const List<String> planPatterns = <String>[
  'detail',
  'list',
  'form',
  'auth',
  'settings',
  'dashboard',
  'onboarding',
  'checkout',
  'search',
  'profile',
  'feed',
  'gallery',
  'custom',
];

/// Variable types a plan may declare.
const List<String> planVariableTypes = <String>[
  'text',
  'integer',
  'decimal',
  'boolean',
  'list',
  'map',
];

/// Variable type words models use for the plan's types.
const Map<String, String> planTypeAliases = <String, String>{
  'number': 'decimal',
  'double': 'decimal',
  'float': 'decimal',
  'int': 'integer',
  'bool': 'boolean',
  'string': 'text',
  'array': 'list',
  'object': 'map',
};

/// Text roles (type tokens) a plan may name.
const List<String> planTextRoles = <String>[
  'display',
  'headline',
  'title',
  'subtitle',
  'body',
  'label',
  'caption',
];

/// Variable names the Codelessly runtime defines itself (the SDK's
/// predefined variables): a plan's data key or variable with one of these
/// names would be shadowed, so [normalizePlan] renames it.
const Set<String> reservedPlanNames = <String>{
  'data', 'product', 'paywall', 'entitlements', 'index', 'value', 'item',
  'parent', 'storage', 'route', 'auth', 'result', 'screen', 'hold', 'drag',
  'track', 'speech', 'initial', 'status',
};

/// [plan] with its data keys and variables renamed where they clash with a
/// runtime name (`product` → `productInfo`), every binding, `bind` and
/// action variable rewritten to match; integral `number` variables become
/// integers. Returns the plan and the renames made.
(Map<String, dynamic>, Map<String, String>) normalizePlan(Map<String, dynamic> plan) {
  final Set<String> declared = <String>{
    if (plan['data'] is Map) ...(plan['data'] as Map).keys.map((Object? k) => '$k'),
    if (plan['variables'] is List)
      for (final Object? v in plan['variables'] as List)
        if (v is Map && v['name'] != null) '${v['name']}',
  };
  final Map<String, String> renames = <String, String>{
    for (final String name in declared)
      if (reservedPlanNames.contains(name)) name: '${name}Info',
  };
  final RegExp expr = RegExp(r'\$\{[^}]*\}');
  String rewrite(String text) {
    if (renames.isEmpty || !text.contains(r'${')) return text;
    return text.replaceAllMapped(expr, (Match m) {
      String e = m[0]!;
      for (final MapEntry<String, String> r in renames.entries) {
        e = e.replaceAllMapped(
          RegExp('(?<![A-Za-z0-9_.])${r.key}(?![A-Za-z0-9_])'),
          (Match _) => r.value,
        );
      }
      return e;
    });
  }

  Object? walk(Object? node, [String? key]) {
    if (node is String) {
      if ((key == 'bind' || key == 'variable') && renames.containsKey(node)) return renames[node];
      return rewrite(node);
    }
    if (node is Map) {
      return <String, dynamic>{for (final MapEntry<Object?, Object?> e in node.entries) '${e.key}': walk(e.value, '${e.key}')};
    }
    if (node is List) return <Object?>[for (final Object? v in node) walk(v, key)];
    return node;
  }

  final Map<String, dynamic> out = walk(plan) as Map<String, dynamic>;
  if (out['data'] is Map) {
    out['data'] = <String, dynamic>{
      for (final MapEntry<String, dynamic> e in (out['data'] as Map<String, dynamic>).entries)
        renames[e.key] ?? e.key: e.value,
    };
  }
  if (out['variables'] is List) {
    out['variables'] = <Object?>[
      for (final Object? v in out['variables'] as List)
        if (v is Map)
          <String, dynamic>{
            ...v.cast<String, dynamic>(),
            if (renames.containsKey(v['name'])) 'name': renames[v['name']],
            if (v['type'] == 'number') 'type': v['value'] is int || (v['value'] is double && (v['value'] as double) % 1 == 0) ? 'integer' : 'decimal',
          }
        else
          v,
    ];
  }
  return (out, renames);
}

/// How serious a [PlanIssue] is.
enum PlanSeverity {
  /// The plan can't compile, or would compile off-brand.
  error,

  /// It compiles, but something is dropped or questionable.
  warning,
}

/// A problem in a plan, at a JSON path such as `sections[1].children[0]`.
class PlanIssue {
  /// Where in the plan.
  final String path;

  /// How serious it is.
  final PlanSeverity severity;

  /// What is wrong, phrased so the model can fix it.
  final String message;

  /// Creates a [PlanIssue].
  const PlanIssue(this.path, this.severity, this.message);

  @override
  String toString() => '${severity.name} at $path: $message';
}

/// Checks a plan against the schema and the kit. Raw hex colors, pixel
/// sizes and unknown tokens are errors: plans may only name tokens.
class ScreenPlanValidator {
  /// The kit the plan must use.
  final DesignKit kit;

  /// Screens a `navigate` action may reach, when known; otherwise any.
  final Set<String>? screens;

  /// Creates a [ScreenPlanValidator].
  const ScreenPlanValidator(this.kit, {this.screens});

  /// Every issue in [plan].
  List<PlanIssue> validate(Object? plan) {
    // ignore: parameter_assignments
    final List<PlanIssue> issues = <PlanIssue>[];
    void error(String path, String message) =>
        issues.add(PlanIssue(path, PlanSeverity.error, message));
    void warn(String path, String message) =>
        issues.add(PlanIssue(path, PlanSeverity.warning, message));

    if (plan is! Map) {
      error(r'$', 'The plan must be a JSON object.');
      return issues;
    }
    final (Map<String, dynamic> normalized, Map<String, String> renames) = normalizePlan(plan.cast<String, dynamic>());
    for (final MapEntry<String, String> r in renames.entries) {
      warn('data.${r.key}', '"${r.key}" is a runtime name; renamed to "${r.value}".');
    }
    plan = normalized;
    if ((plan['title'] ?? '').toString().trim().isEmpty) {
      error('title', 'Give the screen a title.');
    }
    final Object? pattern = plan['pattern'];
    if (pattern != null && !planPatterns.contains(pattern)) {
      warn('pattern', 'Unknown pattern "$pattern"; one of $planPatterns.');
    }
    // Runtime names a plan may read or write without declaring them.
    final Set<String> variables = <String>{'status', 'item', 'index', 'flipped', 'speech', 'storage'};
    final Object? data = plan['data'];
    if (data != null && data is! Map) {
      error('data', '"data" must be an object of sample values.');
    } else if (data is Map) {
      variables.addAll(data.keys.map((Object? k) => '$k'));
    }
    final Object? vars = plan['variables'];
    if (vars != null) {
      if (vars is! List) {
        error('variables', '"variables" must be a list.');
      } else {
        for (int i = 0; i < vars.length; i++) {
          final Object? v = vars[i];
          final String path = 'variables[$i]';
          if (v is! Map || (v['name'] ?? '').toString().isEmpty) {
            error(path, 'A variable needs a "name".');
            continue;
          }
          final String name = v['name'].toString();
          if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name)) {
            error(path, 'Variable name "$name" must be an identifier.');
          }
          final Object? type = planTypeAliases[v['type']] ?? v['type'];
          if (type != null && !planVariableTypes.contains(type)) {
            error(path, 'Variable type "$type" must be one of $planVariableTypes.');
          }
          variables.add(name);
        }
      }
    }

    final Object? appBar = plan['appBar'];
    if (appBar is Map) {
      final Object? actions = appBar['actions'];
      if (actions is List) {
        for (int i = 0; i < actions.length; i++) {
          final Object? a = actions[i];
          final String path = 'appBar.actions[$i]';
          if (a is! Map || a['icon'] == null) {
            error(path, 'An app bar action needs an "icon".');
            continue;
          }
          _action(a['action'], '$path.action', error, warn, variables, required: true);
        }
      }
      final Object? leading = appBar['leading'];
      if (leading != null && !const ['back', 'menu', 'close', 'none'].contains(leading)) {
        warn('appBar.leading', 'leading is back, menu, close or none.');
      }
    } else if (appBar != null) {
      error('appBar', '"appBar" must be an object.');
    }

    final Object? nav = plan['nav'];
    if (nav is Map) {
      final Object? items = nav['items'];
      if (items is! List || items.length < 2 || items.length > 6) {
        error('nav.items', 'Navigation needs 2 to 6 items.');
      } else {
        for (int i = 0; i < items.length; i++) {
          final Object? item = items[i];
          if (item is! Map || item['icon'] == null || item['label'] == null) {
            error('nav.items[$i]', 'A nav item needs "icon" and "label".');
            continue;
          }
          if (item['active'] != true) {
            _action(item['action'], 'nav.items[$i].action', error, warn, variables, required: true);
          }
        }
        if (items.whereType<Map>().where((Map m) => m['active'] == true).length != 1) {
          warn('nav.items', 'Mark exactly one nav item "active": true.');
        }
      }
    }

    final Object? sections = plan['sections'];
    if (sections is! List || sections.isEmpty) {
      error('sections', 'A plan needs at least one section.');
    } else {
      final Set<String> ids = <String>{};
      for (int i = 0; i < sections.length; i++) {
        final Object? s = sections[i];
        final String path = 'sections[$i]';
        if (s is! Map) {
          error(path, 'A section must be an object.');
          continue;
        }
        final String id = (s['id'] ?? '').toString();
        if (id.isNotEmpty && !ids.add(id)) error(path, 'Duplicate section id "$id".');
        final Object? area = s['area'];
        if (area != null && !const ['main', 'aside', 'full'].contains(area)) {
          error('$path.area', 'area is main, aside or full.');
        }
        final Object? layout = s['layout'];
        if (layout != null && !const ['stack', 'row', 'grid', 'cards'].contains(layout)) {
          error('$path.layout', 'layout is stack, row, grid or cards.');
        }
        final Object? children = s['children'];
        if (children is! List || children.isEmpty) {
          error('$path.children', 'A section needs components in "children".');
          continue;
        }
        for (int j = 0; j < children.length; j++) {
          _component(children[j], '$path.children[$j]', error, warn, variables, 0);
        }
      }
    }

    final Object? states = plan['states'];
    final bool hasCollection = _hasCollection(plan['sections']);
    if (states is! Map) {
      error('states', 'Give "states" with loading, error (and empty for screens with lists).');
    } else {
      for (final String state in <String>['loading', 'error', if (hasCollection) 'empty']) {
        if (states[state] == null) {
          error('states.$state', 'Missing the $state state.');
        }
      }
      for (final String state in <String>['empty', 'error']) {
        final Object? s = states[state];
        if (s == null) continue;
        if (s is! Map || (s['title'] ?? '').toString().isEmpty) {
          error('states.$state', 'The $state state needs a "title" (and a "message").');
          continue;
        }
        if (s['icon'] != null) _icon(s['icon'], 'states.$state.icon', warn);
        final Object? action = s['action'];
        if (action != null) {
          if (action is! Map || action['label'] == null) {
            error('states.$state.action', 'A state action needs "label" and "action".');
          } else {
            _action(action['action'], 'states.$state.action.action', error, warn, variables, required: true);
          }
        }
      }
    }
    _scanRaw(plan, r'$', error);
    return issues;
  }

  bool _hasCollection(Object? node) {
    if (node is Map) {
      if (node['type'] == 'list' || node['type'] == 'grid') return true;
      return node.values.any(_hasCollection);
    }
    if (node is List) return node.any(_hasCollection);
    return false;
  }

  /// Raw colors and pixel sizes anywhere are off-brand.
  void _scanRaw(Object? node, String path, void Function(String, String) error) {
    if (node is Map) {
      for (final MapEntry<Object?, Object?> e in node.entries) {
        final String key = '${e.key}';
        if (key == 'data' && path == r'$') continue; // sample data may be anything
        final Object? value = e.value;
        if (value is String &&
            RegExp(r'^#[0-9a-fA-F]{3,8}$').hasMatch(value.trim())) {
          error('$path.$key', 'Raw color "$value": name a color token instead.');
        }
        if (value is String &&
            RegExp(r'^\d+(\.\d+)?px$').hasMatch(value.trim())) {
          error('$path.$key', 'Raw size "$value": name a spacing or radius token instead.');
        }
        _scanRaw(value, path == r'$' ? key : '$path.$key', error);
      }
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        _scanRaw(node[i], '$path[$i]', error);
      }
    }
  }

  void _icon(Object? icon, String path, void Function(String, String) warn) {
    if (icon is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(icon)) {
      warn(path, 'Icons are Material icon names in snake_case ("arrow_back").');
    }
  }

  void _token(
    Object? value,
    String path,
    Iterable<String> tokens,
    String kind,
    void Function(String, String) error,
  ) {
    if (value == null) return;
    if (value is! String || !tokens.contains(value)) {
      error(path, 'Unknown $kind token "$value"; use one of ${tokens.toList()}.');
    }
  }

  void _component(
    Object? c,
    String path,
    void Function(String, String) error,
    void Function(String, String) warn,
    Set<String> variables,
    int depth,
  ) {
    if (depth > 8) {
      error(path, 'Nested too deep (more than 8 levels).');
      return;
    }
    if (c is! Map) {
      error(path, 'A component must be an object with a "type".');
      return;
    }
    final String type = (c['type'] ?? '').toString();
    final List<String>? required = planComponents[type];
    if (required == null) {
      error(path, 'Unknown component type "$type"; use one of ${planComponents.keys.toList()}.');
      return;
    }
    for (final String field in required) {
      if (c[field] == null || c[field] == '') {
        error(path, '$type needs "$field".');
      }
    }
    _token(c['style'], '$path.style', planTextRoles, 'text style', error);
    _token(c['color'], '$path.color', kit.colors.keys, 'color', error);
    _token(c['gap'], '$path.gap', kit.spacing.keys, 'spacing', error);
    _token(c['radius'], '$path.radius', kit.radius.keys, 'radius', error);
    if (c['icon'] != null) _icon(c['icon'], '$path.icon', warn);
    if (c['variant'] != null && (type == 'button' || type == 'iconButton')) {
      final Object? row = kit.components['button']?.row('${c['variant']}');
      if (row == null && !const ['primary', 'secondary', 'outline', 'ghost', 'destructive'].contains(c['variant'])) {
        error('$path.variant', 'Unknown button variant "${c['variant']}".');
      }
    }
    if (c['tone'] != null && !const ['info', 'success', 'warning', 'error', 'neutral'].contains(c['tone'])) {
      error('$path.tone', 'tone is info, success, warning, error or neutral.');
    }
    // Interactive components must do something.
    switch (type) {
      case 'button':
      case 'iconButton':
        _action(c['action'], '$path.action', error, warn, variables, required: true);
      case 'listRow':
      case 'card':
        if (c['action'] != null) {
          _action(c['action'], '$path.action', error, warn, variables, required: false);
        }
      case 'input':
      case 'switchRow':
      case 'checkbox':
      case 'segmented':
      case 'tabs':
        if (c['bind'] == null) {
          error(path, '$type needs "bind": the variable it writes.');
        } else if (!variables.contains(c['bind'])) {
          error('$path.bind', 'bind "${c['bind']}" is not a declared variable; add it to "variables".');
        }
        if (type == 'input' &&
            c['kind'] != null &&
            !const ['text', 'email', 'password', 'number', 'phone', 'search', 'multiline'].contains(c['kind'])) {
          error('$path.kind', 'Input kind is text, email, password, number, phone, search or multiline.');
        }
      case 'list':
      case 'grid':
        final Object? items = c['items'];
        if (items is String) {
          final Match? m = RegExp(r'^\$\{([A-Za-z_][A-Za-z0-9_]*)').firstMatch(items);
          if (m == null || !variables.contains(m[1])) {
            error('$path.items', 'items "$items" must bind a list in "data" or "variables" (e.g. "\${tracks}").');
          }
        } else if (items is! List) {
          error('$path.items', 'items is a binding such as "\${tracks}" or a list.');
        }
        _component(c['item'], '$path.item', error, warn, variables, depth + 1);
    }
    if (type == 'deck') {
      for (final String side in <String>['swipeRight', 'swipeLeft']) {
        if (c[side] != null) _action(c[side], '$path.$side', error, warn, variables, required: false);
      }
      if (c['back'] == null) warn(path, 'A deck without "back" can\'t flip.');
    }
    for (final String key in <String>['children', 'buttons', 'front', 'back']) {
      final Object? children = c[key];
      if (children == null) continue;
      if (children is! List) {
        error('$path.$key', '"$key" must be a list of components.');
        continue;
      }
      for (int i = 0; i < children.length; i++) {
        _component(children[i], '$path.$key[$i]', error, warn, variables, depth + 1);
      }
    }
    for (final String key in <String>['leading', 'trailing']) {
      final Object? slot = c[key];
      if (slot is Map && slot['action'] != null) {
        _action(slot['action'], '$path.$key.action', error, warn, variables, required: false);
      }
    }
  }

  void _action(
    Object? a,
    String path,
    void Function(String, String) error,
    void Function(String, String) warn,
    Set<String> variables, {
    required bool required,
  }) {
    if (a == null) {
      if (required) error(path, 'Missing "action": interactive elements must be wired.');
      return;
    }
    if (a is List) {
      for (int i = 0; i < a.length; i++) {
        _action(a[i], '$path[$i]', error, warn, variables, required: true);
      }
      return;
    }
    if (a is! Map) {
      error(path, 'An action is an object with a "type".');
      return;
    }
    final String type = (a['type'] ?? '').toString();
    final List<String>? fields = planActions[type];
    if (fields == null) {
      error(path, 'Unknown action "$type"; use one of ${planActions.keys.toList()}.');
      return;
    }
    for (final String field in fields) {
      if (a[field] == null) error(path, '$type action needs "$field".');
    }
    if ((type == 'set' || type == 'toggle') &&
        a['variable'] != null &&
        !variables.contains(a['variable'])) {
      error('$path.variable', 'Variable "${a['variable']}" is not declared.');
    }
    if (type == 'navigate' &&
        screens != null &&
        a['to'] != null &&
        !screens!.contains(a['to'])) {
      warn('$path.to', 'Screen "${a['to']}" is not in this app; it will show a toast.');
    }
    if (a['then'] != null) {
      _action(a['then'], '$path.then', error, warn, variables, required: false);
    }
  }
}

/// The JSON Schema of a plan, for structured output and tool definitions.
/// Kept loose on component fields (the validator checks them by type) so a
/// model is never forced into an invalid shape by the schema itself.
Map<String, Object?> screenPlanJsonSchema() {
  final Map<String, Object?> action = <String, Object?>{
    'type': 'object',
    'properties': <String, Object?>{
      'type': <String, Object?>{'type': 'string', 'enum': planActions.keys.toList()},
    },
    'required': <String>['type'],
  };
  final Map<String, Object?> component = <String, Object?>{
    'type': 'object',
    'properties': <String, Object?>{
      'type': <String, Object?>{'type': 'string', 'enum': planComponents.keys.toList()},
      'action': action,
    },
    'required': <String>['type'],
  };
  final Map<String, Object?> state = <String, Object?>{
    'type': 'object',
    'properties': <String, Object?>{
      'icon': <String, Object?>{'type': 'string'},
      'title': <String, Object?>{'type': 'string'},
      'message': <String, Object?>{'type': 'string'},
      'action': <String, Object?>{'type': 'object'},
    },
  };
  return <String, Object?>{
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    'title': 'Codelessly screen plan',
    'type': 'object',
    'properties': <String, Object?>{
      'title': <String, Object?>{'type': 'string'},
      'summary': <String, Object?>{'type': 'string'},
      'pattern': <String, Object?>{'type': 'string', 'enum': planPatterns},
      'appBar': <String, Object?>{'type': 'object'},
      'nav': <String, Object?>{'type': 'object'},
      'data': <String, Object?>{'type': 'object'},
      'variables': <String, Object?>{
        'type': 'array',
        'items': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'name': <String, Object?>{'type': 'string'},
            'type': <String, Object?>{'type': 'string', 'enum': planVariableTypes},
            'value': <String, Object?>{},
          },
          'required': <String>['name'],
        },
      },
      'sections': <String, Object?>{
        'type': 'array',
        'minItems': 1,
        'items': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'id': <String, Object?>{'type': 'string'},
            'title': <String, Object?>{'type': 'string'},
            'area': <String, Object?>{'type': 'string', 'enum': <String>['main', 'aside', 'full']},
            'layout': <String, Object?>{'type': 'string', 'enum': <String>['stack', 'row', 'grid', 'cards']},
            'children': <String, Object?>{'type': 'array', 'items': component},
          },
          'required': <String>['children'],
        },
      },
      'states': <String, Object?>{
        'type': 'object',
        'properties': <String, Object?>{
          'loading': <String, Object?>{'type': 'object'},
          'empty': state,
          'error': state,
        },
        'required': <String>['loading', 'error'],
      },
    },
    'required': <String>['title', 'sections', 'states'],
  };
}
