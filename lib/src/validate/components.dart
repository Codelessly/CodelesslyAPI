// Strict validation of component definitions and the calls to them
// (docs/design/06-sections-and-components.md §8.3): a call against the
// component's declaration (required parameters, `variable` parameters, its
// events, the fields the definition owns), a definition against itself
// (its slots, the events it fires, a root that binds its placement), and a
// project's library (types, file names, duplicates, cycles).
part of 'validator.dart';

/// The definitions among [documents] (with [given] under them) as a
/// library, and what is wrong with them as a library.
(ComponentLibrary, List<Diagnostic>) _componentLibrary(Map<String, Object?> documents, ComponentLibrary? given) {
  final out = <Diagnostic>[];
  final defs = <String, LayoutDocument>{...?given?.definitions};
  final fileOf = <String, String>{};
  void add(DiagnosticCode code, String file, String path, String message, {String? suggestion}) =>
      out.add(Diagnostic(code, path, message, suggestion: suggestion, file: file));
  for (final e in documents.entries) {
    final m = readMap(e.value);
    if (m == null || !m.containsKey(kWidgetKey)) continue;
    final w = readMap(m[kWidgetKey]);
    final type = readString(w?['type']);
    if (w == null || type == null || type.isEmpty) {
      add(
        Codes.invalidComponent,
        e.key,
        '/widget',
        'A component declares itself as "widget": {"type": "PlanCard", "props": [...], "events": [...]}.',
      );
      continue;
    }
    if (!isComponentTypeName(type)) {
      final camel = type.isEmpty
          ? type
          : type[0].toUpperCase() + type.substring(1).replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      add(
        Codes.invalidComponent,
        e.key,
        '/widget/type',
        'A component type is UpperCamelCase, like a Dart class ("PlanCard"); "$type" is not.',
        suggestion: camel,
      );
    }
    final roots = readList(m['roots']);
    if (roots == null || roots.length != 1) {
      add(
        Codes.invalidComponent,
        e.key,
        '/roots',
        'A component has exactly one root (its widget\'s top node, not a canvas); it has ${roots?.length ?? 0}.',
      );
    }
    final stem = _stem(e.key);
    if (stem != null && stem != type) {
      add(
        Codes.componentIdMismatch,
        e.key,
        '/widget/type',
        'File "${e.key}" holds component "$type": name the file $type.json, or the type "$stem".',
        suggestion: stem,
      );
    }
    final id = m['id'];
    if (id is String && id.isNotEmpty && id != type) {
      add(
        Codes.componentIdMismatch,
        e.key,
        '/id',
        'A component document\'s "id" is its type, "$type"; it is "$id".',
        suggestion: type,
      );
    }
    if (standardCatalog.widget(type) != null) {
      add(
        Codes.duplicateComponent,
        e.key,
        '/widget/type',
        '"$type" is already a node type of the catalog: name the component otherwise.',
      );
    }
    final before = fileOf[type];
    if (before != null || (given?.definitions.containsKey(type) ?? false)) {
      add(
        Codes.duplicateComponent,
        e.key,
        '/widget/type',
        'Component "$type" is also declared ${before == null ? 'by the project' : 'in $before'}: one definition per type.',
      );
    }
    defs[type] = LayoutDocument.fromJson(m, catalog: standardCatalog);
    fileOf[type] = e.key;
  }
  final library = ComponentLibrary(defs);
  for (final cycle in library.cycles) {
    for (var i = 0; i < cycle.length - 1; i++) {
      final from = cycle[i], to = cycle[i + 1];
      for (final n in defs[from]!.nodes.values.where((n) => n.type == to)) {
        out.add(
          Diagnostic(
            Codes.componentCycle,
            pointer(pointer('/nodes', n.id), 'type'),
            'Component cycle ${cycle.join(' → ')}: "${n.id}" in $from calls $to${cycle.length == 2 ? ' (itself)' : ''}, so it never finishes rendering.',
            nodeId: n.id,
            file: fileOf[from],
          ),
        );
      }
    }
  }
  return (library, out);
}

/// [file]'s name without directories and extension; null when it has none.
String? _stem(String file) {
  final name = file.split(RegExp(r'[/\\]')).last;
  if (!name.endsWith('.json')) return null;
  final stem = name.substring(0, name.length - 5);
  return stem.isEmpty ? null : stem;
}

/// Variables of [documents] named like a project variable of [manifest]:
/// one name, one variable (`duplicate_variable`).
List<Diagnostic> _projectVariableCollisions(Map<String, Object?> documents, SiteManifest manifest) {
  final names = {for (final v in manifest.variables) v.name};
  final out = <Diagnostic>[];
  for (final e in documents.entries) {
    final scopes = readMap(readMap(e.value)?['variables']) ?? const {};
    for (final s in scopes.entries) {
      final list = readList(s.value) ?? const [];
      for (var i = 0; i < list.length; i++) {
        final name = readMap(list[i])?['name'];
        if (name is String && names.contains(name)) {
          out.add(
            Diagnostic(
              Codes.duplicateVariable,
              pointer(pointer(pointer('/variables', s.key), i), 'name'),
              'Variable "$name" is also a project variable (site.json): rename one, or use the project\'s.',
              file: e.key,
            ),
          );
        }
      }
    }
  }
  return out;
}

extension on _Validator {
  /// The checks of calls, slots and component events in this document.
  void _components(Json m, List<String> roots) {
    final library = options.components;
    final own = definitionRoot == null ? null : widgetSpecFromJson(m[kWidgetKey]);
    final types = <String, String>{
      for (final scope in (readMap(m[LayoutLogic.variablesKey]) ?? const {}).values)
        for (final v in readList(scope) ?? const [])
          if (readMap(v) case final Json j when j['name'] is String) j['name'] as String: '${j['type'] ?? 'text'}',
    };
    for (final e in nodesJson.entries) {
      final n = nodes[e.key];
      if (n == null) continue;
      final raw = readMap(e.value)!;
      final at = pointer('/nodes', e.key);
      r.node = e.key;
      currentCanvas = canvasOf[e.key];
      final call = library?.definitions[n.type]?.widget;
      if (call != null) _call(n, raw, call, at, types);
      _eventReactions(raw['actions'], pointer(at, 'actions'), call, n.type);
      if (n.type == SlotProps.spec.type) _slotNode(n, at, own);
      _componentEvents(raw['actions'], pointer(at, 'actions'), own);
    }
    final root = definitionRoot;
    if (root != null) {
      final bind = readMap(readMap(nodesJson[root])?['bind']) ?? const {};
      for (final k in bind.keys) {
        final parts = k.split('.');
        if (parts.length >= 2 && parts.first == 'layout' && callLayoutKeys.contains(parts[1].split('[').first)) {
          r.node = root;
          r.add(
            Codes.rootPlacementBound,
            pointer(pointer(pointer('/nodes', root), 'bind'), k),
            'The root of a component is sized and placed by its call: "$k" is dropped. Bind it on the call instead (or make it a parameter).',
          );
        }
      }
    }
    r.node = null;
    currentCanvas = null;
  }

  void _call(Node n, Json raw, WidgetSpec spec, String at, Map<String, String> variableTypes) {
    final props = readMap(raw['props']) ?? const {};
    final bind = readMap(raw['bind']) ?? const {};
    for (final p in spec.props) {
      if (p.required && !props.containsKey(p.key) && !bind.containsKey('props.${p.key}')) {
        r.add(
          Codes.missingProp,
          pointer(at, 'props'),
          '${spec.type} needs "${p.key}" (${p.type.typeName}): set "props": {"${p.key}": ...} or bind "props.${p.key}".',
          suggestion: p.key,
        );
      }
      if (!p.type.isVariable || !props.containsKey(p.key)) continue;
      final v = props[p.key];
      final pp = pointer(pointer(at, 'props'), p.key);
      if (v is! String || v.trim().isEmpty || v.contains(r'${')) {
        r.add(
          Codes.wrongType,
          pp,
          '"${p.key}" is a variable parameter: it takes the name of a variable of this scope ("${p.key}"), not ${describe(v)}.',
        );
        continue;
      }
      final name = rootName(v.trim());
      if (name == null) continue;
      final declared = _declared(currentCanvas);
      if (!declared.contains(name)) {
        r.add(
          Codes.unknownVariable,
          pp,
          'No variable "$name" to pass as "${p.key}": declare it in this document (or the project).',
          suggestion: nearest(name, declared),
        );
        continue;
      }
      final t = variableTypes[name];
      final of = p.type.variableOf!;
      if (t != null && v.trim() == name && !_holds(t, of)) {
        r.add(Codes.wrongType, pp, '"${p.key}" takes a ${of.typeName} variable; "$name" is a $t variable.');
      }
    }
    if (raw.containsKey('decoration')) {
      r.add(
        Codes.callFieldNotAllowed,
        pointer(at, 'decoration'),
        'A call to ${spec.type} has no decoration: the definition draws itself. Add a parameter for what should change.',
      );
    }
    if (readMap(raw['layout'])?.containsKey('padding') ?? false) {
      r.add(
        Codes.callFieldNotAllowed,
        pointer(pointer(at, 'layout'), 'padding'),
        'A call gives its component size and placement, not padding: the inside is the definition\'s.',
      );
    }
    for (final k in bind.keys) {
      if (k.startsWith('decoration') || k == 'layout.padding' || k.startsWith('layout.padding')) {
        r.add(
          Codes.callFieldNotAllowed,
          pointer(pointer(at, 'bind'), k),
          'A call cannot bind "$k": the inside is the definition\'s.',
        );
      }
    }
  }

  /// Whether a variable of type [variableType] can be a [type] parameter.
  static bool _holds(String variableType, PropType type) => switch (type.kind) {
    PropKind.boolean => variableType == 'boolean',
    PropKind.integer => variableType == 'integer',
    PropKind.number => variableType == 'integer' || variableType == 'decimal',
    PropKind.string || PropKind.enumeration => const {'text', 'image', 'choice', 'color'}.contains(variableType),
    PropKind.list => variableType == 'list',
    PropKind.object => variableType == 'map',
    PropKind.value => variableType != 'list' && variableType != 'map',
    PropKind.json => true,
  };

  /// `event` reactions: only on a call, naming one of its events.
  void _eventReactions(Object? json, String at, WidgetSpec? call, String type) {
    final list = readList(json) ?? const [];
    for (var i = 0; i < list.length; i++) {
      final trigger = readMap(readMap(list[i])?['trigger']);
      if (trigger == null || trigger['type'] != TriggerType.event.name) continue;
      final p = pointer(pointer(at, i), 'trigger');
      final key = trigger['event'];
      if (call == null) {
        r.add(Codes.unknownEvent, p, 'An event reaction goes on a component call; a $type fires no component events.');
      } else if (key is! String || key.isEmpty) {
        r.add(
          Codes.unknownEvent,
          pointer(p, 'event'),
          'An event reaction names the event it handles: "event": one of ${call.events.isEmpty ? '(none: ${call.type} declares no events)' : call.events.map((e) => e.key).join(', ')}.',
        );
      } else if (call.event(key) == null) {
        final keys = call.events.map((e) => e.key);
        r.add(
          Codes.unknownEvent,
          pointer(p, 'event'),
          '${call.type} declares no event "$key"${keys.isEmpty ? '' : '. Its events: ${keys.join(', ')}'}.',
          suggestion: nearest(key, keys),
        );
      }
    }
  }

  /// `componentEvent` actions (anywhere in [json]): inside a component,
  /// naming one of its events.
  void _componentEvents(Object? json, String at, WidgetSpec? own) {
    if (json is List) {
      for (var i = 0; i < json.length; i++) {
        _componentEvents(json[i], pointer(at, i), own);
      }
      return;
    }
    final m = readMap(json);
    if (m == null) return;
    if (m['type'] == ComponentEventAction.typeName) {
      final key = m['event'];
      if (own == null) {
        r.add(
          Codes.unknownEvent,
          pointer(at, 'type'),
          'componentEvent fires an event of the component it is in; this document is not a component (it has no "widget").',
        );
      } else if (key is! String || own.event(key) == null) {
        final keys = own.events.map((e) => e.key);
        r.add(
          Codes.unknownEvent,
          pointer(at, 'event'),
          '${own.type} declares no event ${describe(key)}: add it to "widget": {"events": [{"key": ...}]}${keys.isEmpty ? '' : ', or fire one of ${keys.join(', ')}'}.',
          suggestion: key is String ? nearest(key, keys) : null,
        );
      }
    }
    for (final e in m.entries) {
      if (e.value is List || e.value is Map) _componentEvents(e.value, pointer(at, e.key), own);
    }
  }

  void _slotNode(Node n, String at, WidgetSpec? own) {
    final name = n.prop(SlotProps.name);
    if (own == null) {
      r.add(
        Codes.slotOutsideComponent,
        pointer(at, 'type'),
        'A slot is where a component places what its call passes; in a page nothing fills it (its own children show).',
      );
      return;
    }
    final known = [if (own.children == ChildModel.list) kChildrenSlot, ...own.slots];
    if (!known.contains(name)) {
      r.add(
        Codes.unknownSlot,
        pointer(pointer(at, 'props'), 'name'),
        '${own.type} declares no slot "$name"${known.isEmpty ? ' (declare "slots": [...] or "children": "list" in its widget)' : '. Its slots: ${known.join(', ')}'}.',
        suggestion: nearest(name, known),
      );
    }
  }
}
