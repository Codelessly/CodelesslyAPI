// The reference pages, rendered from the catalog (catalog.dart) and the
// guide templates (tool/reference/templates). Tables come only from the
// catalog; prose only from templates.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart'
    show Catalog, EditCodes, EditOp, Json, LayoutDocument, TrustProfile, applyOps, opsFromDocument, uiTools;
import 'package:codelessly_api/validate.dart' show valueForms;

/// How links are written: across page files, or within one file.
enum LinkMode { pages, single }

final class Pages {
  Pages(this.catalog, this.root, {this.mode = LinkMode.pages, this.compact = false});

  /// The catalog (catalog.dart), read dynamically.
  final Map<String, dynamic> catalog;
  final String root;
  final LinkMode mode;

  /// Terse tables without long docs (API_REFERENCE.compact.md).
  final bool compact;

  String get _templates => '$root/tool/reference/templates';

  /// The pages, by file name, in reading order.
  static const order = [
    'index.md', 'nodes.md', 'layout.md', 'decoration.md', 'values.md', 'behaviors.md', 'triggers.md', 'actions.md', //
    'bindings.md', 'formulas.md', 'variables-conditions-scripts.md',
  ];

  Map<String, String> render() => {
        'index.md': index(),
        'nodes.md': nodes(),
        'layout.md': layout(),
        'decoration.md': decoration(),
        'values.md': values(),
        'behaviors.md': behaviors(),
        'triggers.md': triggers(),
        'actions.md': actions(),
        'bindings.md': bindings(),
        'formulas.md': formulas(),
        'variables-conditions-scripts.md': variablesConditionsScripts(),
        'STARTER.md': starter(),
      };

  // --- links ------------------------------------------------------------------

  String link(String page, String anchor, String text) =>
      mode == LinkMode.single ? '[$text](#$anchor)' : '[$text]($page#$anchor)';
  String pageLink(String page, String text) =>
      mode == LinkMode.single ? '[$text](#page-${page.replaceAll('.md', '')})' : '[$text]($page)';
  static String anchor(String id) => '<a id="$id"></a>';

  // --- shared pieces ------------------------------------------------------------

  String template(String name, [Map<String, String Function()> fills = const {}]) {
    var text = File('$_templates/$name').readAsStringSync();
    text = text.replaceAllMapped(RegExp(r'\{\{example:([\w/-]+)\}\}'), (m) => '```json\n${_example(m[1]!)}\n```');
    text = text.replaceAllMapped(RegExp(r'\{\{link:([\w.-]+)#([\w.-]+)\|([^}]+)\}\}'), (m) => link(m[1]!, m[2]!, m[3]!));
    text = text.replaceAllMapped(RegExp(r'\{\{page:([\w.-]+)\|([^}]+)\}\}'), (m) => pageLink(m[1]!, m[2]!));
    text = text.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (m) {
      final f = fills[m[1]] ?? _fills[m[1]];
      if (f == null) throw StateError('Template $name: no fill for {{${m[1]}}}');
      return f();
    });
    return text.trimRight();
  }

  late final Map<String, String Function()> _fills = {
    'version': () => '${catalog['version']}',
    'nodeTypeList': () => [
          for (final e in (catalog['nodeTypes'] as Map).entries)
            link('nodes.md', 'node-${e.key}', '`${e.key}`'),
        ].join(', '),
    'nodeTypeSummary': () => _nodeTypeSummary(),
    'breakpointDefaults': () => _breakpointDefaults(),
    'scopes': () => [for (final s in catalog['scopes'] as List) '`$s`'].join(', '),
    'diagnosticCodes': () => _table(['Code', 'Severity', 'Meaning'], [
          for (final d in catalog['diagnostics'] as List) ['`${d['code']}`', '${d['severity']}', '${d['meaning']}'],
        ]),
    'childFits': () => _childFits(),
    'triggerTypeList': () => [for (final t in catalog['triggers']['types'] as List) '`${t['type']}`'].join(', '),
    'actionTypeList': () => [
          for (final e in (catalog['actions']['types'] as Map).entries) link('actions.md', 'action-${e.key}', '`${e.key}`'),
        ].join(', '),
    'behaviorKeyList': () => [
          for (final f in catalog['behaviors']['fields'] as List) link('behaviors.md', 'behavior-${f['key']}', '`${f['key']}`'),
        ].join(', '),
    'valueForms': () => _table(['Type', 'JSON forms'], [
          for (final e in (catalog['valueTypes'] as Map).entries) [link('values.md', 'type-${e.key}', e.key), '${e.value['forms']}'],
        ]),
    'documentKeys': () => _table(['Key', 'Meaning'], [
          for (final k in catalog['document']['keys'] as List) ['`${k['key']}`', '${k['doc']}'],
        ]),
    'nodeKeys': () => _table(['Key', 'Type', 'Meaning'], [
          for (final k in catalog['node']['structural'] as List) ['`${k['key']}`', '`${k['type']}`', _cell('${k['doc']}')],
          for (final f in catalog['node']['fields'] as List)
            ['`${f['key']}`', _type(f), 'Default ${_default(f)}. ${_cell('${f['doc']}')}'],
          [
            'behaviors',
            '',
            'Flat keys for what a node does beyond layout and paint: ${[for (final f in catalog['behaviors']['fields'] as List) '`${f['key']}`'].join(', ')} (${pageLink('behaviors.md', 'behaviors')}).',
          ],
        ]),
    'layoutFields': () => _fieldTable(catalog['layout']['fields'] as List, long: true),
    'conditionOps': () => _table(['op', 'Reads right', 'Meaning'], [
          for (final o in catalog['conditions']['ops'] as List) ['`${o['op']}`', o['takesRight'] == true ? 'yes' : 'no', _cell('${o['doc']}')],
        ]),
    'variableTypes': () => _enumTable('VariableType'),
    // The edit layer, from its declarations.
    'editOps': () => _table(['Op', 'Fields', 'Means', 'Example'], [
          for (final o in EditOp.specs)
            [
              '`${o.op}`',
              [for (final f in o.fields) if (f.key != 'op') '`${f.key}`${f.required ? ' (required)' : ''}'].join(', '),
              o.doc,
              '`${jsonEncode(o.example)}`',
            ],
        ]),
    'editCodes': () => _table(['Code', 'Rejects the op', 'Meaning'], [
          for (final c in EditCodes.all) ['`${c.name}`', c.error ? 'yes' : 'no (a warning)', c.meaning],
        ]),
    'uiTools': () => '```json\n${prettyJson(uiTools(TrustProfile.agent.restrict(Catalog.core)).map((t) => {...t, 'input_schema': '(see ui_tools.json)'}).toList())}\n```',
    'editRejected': () => _editRejected(),
    'editBuild': () => '```json\n${prettyJson({'ops': [for (final o in opsFromDocument(LayoutDocument.fromJson(jsonDecode(File('$root/tool/reference/examples/minimal.json').readAsStringSync()), catalog: Catalog.core))) o.toJson()]})}\n```',
  };

  /// A batch with a rejected op, applied for real: the tool result a model
  /// reads.
  String _editRejected() {
    final doc = LayoutDocument.fromJson(jsonDecode(File('$root/tool/reference/examples/minimal.json').readAsStringSync()),
        catalog: Catalog.core);
    final title = doc.nodes.values.firstWhere((n) => n.type == 'text').id;
    final ops = {
      'ops': [
        {'op': 'patch', 'id': title, 'patch': {'props': {'text': 'Welcome back'}}},
        {'op': 'patch', 'id': title, 'patch': {'decoration': {'fill': [{'color': '#FFF1F5F9'}]}}},
      ],
    };
    final r = applyOps(doc, ops, catalog: Catalog.core);
    return '```json\n${prettyJson(ops)}\n```\n\nThe result (`EditResult.toModelJson()`, the tool result):\n\n```json\n${prettyJson(r.toModelJson())}\n```';
  }

  String _example(String name) {
    final f = File('$root/tool/reference/examples/$name.json');
    return prettyJson(jsonDecode(f.readAsStringSync()));
  }

  String _cell(String s) => s.replaceAll('|', r'\|').replaceAll('\n\n', '<br><br>').replaceAll('\n', ' ');

  String _table(List<String> head, List<List<String>> rows) {
    final b = StringBuffer()
      ..writeln('| ${head.join(' | ')} |')
      ..writeln('|${head.map((_) => '---').join('|')}|');
    for (final r in rows) {
      b.writeln('| ${r.map(_cell).join(' | ')} |');
    }
    return b.toString().trimRight();
  }

  String _jsonInline(Object? v) {
    final s = jsonEncode(v);
    return s.length > 60 ? '${s.substring(0, 57)}...' : s;
  }

  String _default(Json f) {
    if (f['default'] == null) return 'unset';
    final d = f['default'];
    if (d is List && d.isEmpty) return '`[]`';
    if (d is Map && d.isEmpty) return '`{}`';
    return '`${_jsonInline(d)}`';
  }

  /// A field's type, linked to where its type is described.
  String _type(Json f) {
    final kind = f['kind'];
    String one(String name, String k, Json info) => switch (k) {
          'object' => link('values.md', 'type-$name', name),
          'value' => link('values.md', 'type-$name', name),
          'enumeration' => link('values.md', 'enum-$name', name),
          _ => name,
        };
    if (kind == 'list') {
      final item = '${f['item']}';
      final inner = one(item, '${f['itemKind']}', f);
      return 'List<$inner>';
    }
    return one('${f['type']}', '$kind', f);
  }

  /// Allowed values / bounds for a field.
  String _allowed(Json f) {
    final parts = <String>[];
    final values = (f['values'] ?? f['item_values']) as List?;
    if (values != null) parts.add(values.map((v) => '`$v`').join(', '));
    if (f['min'] != null || f['max'] != null) {
      parts.add('${f['min'] == null ? '' : '≥ ${_num(f['min'])}'}${f['min'] != null && f['max'] != null ? ', ' : ''}${f['max'] == null ? '' : '≤ ${_num(f['max'])}'}');
    }
    return parts.join('; ');
  }

  static String _num(Object? n) => n is double && n == n.roundToDouble() ? '${n.toInt()}' : '$n';

  String _fieldTable(List fields, {bool long = false}) {
    if (fields.isEmpty) return '_No fields._';
    if (compact) {
      return [
        for (final f in fields.cast<Json>())
          '- `${f['key']}`: ${_type(f)} = ${_default(f)}${_allowed(f).isEmpty ? '' : ' (${_allowed(f)})'}',
      ].join('\n');
    }
    return _table(['Key', 'Type', 'Default', 'Allowed', 'Description'], [
      for (final f in fields.cast<Json>()) ['`${f['key']}`', _type(f), _default(f), _allowed(f), '${f['doc']}'],
    ]);
  }

  String _nodeTypeSummary() => _table(['Type', 'Flutter', 'Children', 'Decoration'], [
        for (final e in (catalog['nodeTypes'] as Map).entries)
          [
            link('nodes.md', 'node-${e.key}', '`${e.key}`'),
            e.value['flutter'] == null ? '' : '`${e.value['flutter']}`',
            _childrenRule(e.value as Json),
            e.value['decorated'] == true ? 'yes' : 'blurs only',
          ],
      ]);

  String _childrenRule(Json t) => switch (t['children']) {
        'list' => '`children`',
        'slots' => 'slots: ${[for (final s in t['slots'] as List) '`$s`'].join(', ')}',
        _ => (t['slots'] as List).isEmpty ? 'none' : 'slots: ${[for (final s in t['slots'] as List) '`$s`'].join(', ')}',
      } +
      ((t['children'] == 'list' && (t['slots'] as List).isNotEmpty) ? ' and slots: ${[for (final s in t['slots'] as List) '`$s`'].join(', ')}' : '');

  String _breakpointDefaults() => _table(['id', 'name', 'minWidth', 'design width × height'], [
        for (final b in catalog['breakpoints']['defaults'] as List)
          ['`${b['id']}`', '${b['name'] ?? ''}', '${b['minWidth'] ?? 0}', '${b['width']} × ${b['height']}'],
      ]);

  String _childFits() {
    String describe(Map axis) {
      final allowed = [
        for (final e in axis.entries)
          if (e.value == null)
            e.key
          // Allowed on a condition the rule names (a wrapping row's child
          // fills its line's share when it sets a basis).
          else if (e.key == 'fill' && '${e.value}'.contains('basis'))
            'fill (with `basis`)',
      ];
      return allowed.join(', ');
    }

    return _table(['Parent', 'Width may be', 'Height may be'], [
      for (final p in catalog['layout']['childFits'] as List)
        [
          '`${p['parent']}`${(p['props'] as Map).isEmpty ? '' : ' with ${jsonEncode(p['props'])}'}',
          describe(p['width'] as Map),
          describe(p['height'] as Map),
        ],
    ]);
  }

  String _enumTable(String name) {
    final values = (catalog['enums'] as Map)[name] as List?;
    if (values == null) return '';
    final documented = values.any((v) => (v['doc'] as String).isNotEmpty);
    if (!documented || compact) return values.map((v) => '`${v['value']}`').join(', ');
    return _table(['Value', 'Meaning'], [
      for (final v in values) ['`${v['value']}`', '${v['doc']}'],
    ]);
  }

  String _header(String title, String intro) => '${anchor('page-$title')}\n'
      '# ${_titles[title]}\n\n$intro\n';

  static const _titles = {
    'index': 'Codelessly layout documents: a guide for authors',
    'nodes': 'Node types',
    'layout': 'Layout',
    'decoration': 'Decoration',
    'values': 'Value types, models and enums',
    'behaviors': 'Behaviors',
    'triggers': 'Triggers',
    'actions': 'Actions',
    'bindings': 'Bindings and expressions',
    'formulas': 'Formula functions',
    'variables-conditions-scripts': 'Variables, conditions and scripts',
  };

  String _generatedNote() => '<!-- Generated by tool/reference/generate.dart from the declarations of codelessly_api '
      '${catalog['version']}. Do not edit: edit the declarations or tool/reference/templates. -->';

  // --- pages ----------------------------------------------------------------------

  String index() => '${[_generatedNote(), anchor('page-index'), _only(template('index.md'), keep: 'guide-only', drop: 'starter-only')].join('\n')}\n';

  /// [text] without its `<!-- drop -->...<!-- /drop -->` parts and the
  /// markers of its [keep] parts.
  static String _only(String text, {required String keep, required String drop}) => text
      .replaceAll(RegExp('<!-- $drop -->.*?<!-- /$drop -->\\n?', dotAll: true), '')
      .replaceAll(RegExp('<!-- /?$keep -->\\n?'), '');

  String nodes() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('nodes', template('nodes.md')))
      ..writeln(_nodeTypeSummary())
      ..writeln();
    for (final e in (catalog['nodeTypes'] as Map).entries) {
      b.write(_nodeSection(e.key as String, e.value as Json));
    }
    return b.toString();
  }

  /// The core node types the starter covers, in its order.
  static const starterTypes = ['canvas', 'row', 'column', 'flex', 'stack', 'box', 'text', 'icon', 'spacer'];

  /// The starter: the document, the core node types, layout, decoration,
  /// text, responsive design, variables, checking and the pitfalls, from the
  /// guide and the declarations (docs/reference/STARTER.md).
  String starter() {
    final guide = _only(template('index.md'), keep: 'starter-only', drop: 'guide-only');
    final included = <String>{};
    String section(String id) {
      final start = guide.indexOf('<a id="$id"></a>');
      if (start < 0) throw StateError('STARTER.md: no guide section $id');
      final next = guide.indexOf('<a id="guide-', start + 10);
      included.add(id);
      return guide.substring(start, next < 0 ? guide.length : next).trimRight();
    }

    var text = template('STARTER.md', {
      'starterFiles': () => _table(['You need', 'Read'], [
            ['Several screens and links between them; a canvas per breakpoint', '`index.md` section 6, and 7 for when to use one'],
            ['Conditions; every binding path', '`index.md` section 9, `bindings.md`, `variables-conditions-scripts.md`'],
            ['Every formula function (filter, sum, money, dates...)', '`formulas.md`'],
            ['Taps and other triggers, and what they run (set a variable, navigate, open a modal, show a toast)', '`index.md` section 10, `triggers.md`, `actions.md`'],
            ['Hover and pressed styles', '`index.md` section 11'],
            ['Scrolling, lists, grids and repeated data', '`index.md` sections 12 and 13'],
            ['Buttons, text fields, checkboxes, switches, sliders, dropdowns, tabs, tables, charts and every other node type', '`nodes.md` (one section per type), `index.md` section 14'],
            ['Modals and toasts; images, icons and fonts', '`index.md` sections 15 and 16'],
            ['Every layout and decoration field; every value type (colors, paints, gradients, text styles, borders)', '`layout.md`, `decoration.md`, `values.md`'],
            ['Animation, gestures, sticky and floating nodes, drag and drop, custom drawing', '`behaviors.md`'],
            ['The whole reference as one file, or as data', '`API_REFERENCE.md`, `catalog.json`, `document.schema.json`'],
          ]),
      'coreNodes': () => [
            for (final type in starterTypes)
              if ((catalog['nodeTypes'] as Map)[type] case final Json t) _nodeSection(type, t, heading: '##'),
          ].join(),
    });
    text = text.replaceAllMapped(RegExp(r'\{\{guide:([\w-]+)\}\}'), (m) => section(m[1]!));
    // Links to guide sections the starter leaves out go to the guide; node
    // sections it leaves out, to nodes.md.
    text = text.replaceAllMapped(RegExp(r'\]\(#(guide-[\w-]+)\)'), (m) => included.contains(m[1]) ? m[0]! : '](index.md#${m[1]})');
    text = text.replaceAllMapped(RegExp(r'\]\(nodes\.md#node-([\w-]+)\)'), (m) => starterTypes.contains(m[1]) ? '](#node-${m[1]})' : m[0]!);
    return '${[_generatedNote(), text].join('\n')}\n';
  }

  String _nodeSection(String type, Json t, {String heading = '##'}) {
    final b = StringBuffer();
    final e = (key: type, value: t);
    {
      b
        ..writeln(anchor('node-${e.key}'))
        ..writeln('## `${e.key}`')
        ..writeln();
      if (!compact && '${t['doc']}'.isNotEmpty) b..writeln(t['doc'])..writeln();
      if (compact && t['flutter'] != null) b..writeln('Flutter `${t['flutter']}`.')..writeln();
      b.writeln('- Children: ${_childrenRule(t)}.');
      b.writeln('- Decoration: ${t['decorated'] == true ? 'box decoration (fills, strokes, radius, shadows, clip)' : 'none: only blur effects in `decoration.effects` apply'}.');
      final childFields = t['childFields'] as List;
      if (childFields.isNotEmpty) {
        b.writeln('- Reads from each child\'s layout: ${[for (final f in childFields) link('layout.md', 'layout-$f', '`$f`')].join(', ')}.');
      }
      b.writeln();
      b
        ..writeln((t['props'] as List).isEmpty ? '_No props._' : _fieldTable(t['props'] as List))
        ..writeln();
    }
    return b.toString();
  }

  String layout() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('layout', template('layout.md')));
    b
      ..writeln('## Fields')
      ..writeln();
    for (final f in (catalog['layout']['fields'] as List).cast<Json>()) {
      b.writeln(anchor('layout-${f['key']}'));
    }
    b
      ..writeln(_fieldTable(catalog['layout']['fields'] as List))
      ..writeln()
      ..writeln('Read by decoding but not declared as fields: ${[for (final k in catalog['layout']['undeclared'] as List) '`$k`'].join(', ')}. '
          '${catalog['layout']['undeclaredDoc']}')
      ..writeln()
      ..writeln('## Which sizing modes each parent allows')
      ..writeln()
      ..writeln(_childFits())
      ..writeln()
      ..writeln('Why a mode is not allowed, as the declarations say it:')
      ..writeln();
    final reasons = <String>{};
    for (final p in catalog['layout']['childFits'] as List) {
      for (final axis in const ['width', 'height']) {
        for (final r in (p[axis] as Map).values) {
          if (r != null) reasons.add('$r');
        }
      }
    }
    for (final r in reasons) {
      b.writeln('- $r');
    }
    return b.toString();
  }

  String decoration() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('decoration', template('decoration.md')))
      ..writeln('## Fields')
      ..writeln()
      ..writeln(_fieldTable(catalog['decoration']['fields'] as List))
      ..writeln();
    for (final t in const ['Paint', 'ColorStop', 'ImagePaint', 'Effect']) {
      b.writeln(_objectSection(t, level: 2));
    }
    for (final e in const ['PaintType', 'EffectType', 'StrokeSides', 'StrokeAlign', 'DecorationShape', 'Clip']) {
      b
        ..writeln('### $e')
        ..writeln()
        ..writeln(_enumTable(e))
        ..writeln();
    }
    return b.toString();
  }

  String _objectSection(String name, {int level = 2}) {
    final t = (catalog['objectTypes'] as Map)[name] as Json?;
    if (t == null) return '';
    final b = StringBuffer()
      ..writeln('${'#' * level} $name')
      ..writeln();
    if (!compact && '${t['doc']}'.isNotEmpty) b..writeln(t['doc'])..writeln();
    b
      ..writeln(_fieldTable(t['fields'] as List))
      ..writeln();
    return b.toString();
  }

  String values() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('values', template('values.md')))
      ..writeln('## Value types')
      ..writeln();
    for (final e in (catalog['valueTypes'] as Map).entries) {
      b
        ..writeln(anchor('type-${e.key}'))
        ..writeln('### ${e.key}')
        ..writeln()
        ..writeln('JSON: ${e.value['forms']}.')
        ..writeln();
      if (!compact && '${e.value['doc']}'.isNotEmpty) b..writeln(e.value['doc'])..writeln();
    }
    b
      ..writeln('## Models')
      ..writeln()
      ..writeln('Objects with declared fields. Keys not listed are reported by validation (`unknown_field`).')
      ..writeln();
    for (final name in (catalog['objectTypes'] as Map).keys) {
      b
        ..writeln(anchor('type-$name'))
        ..write(_objectSection('$name', level: 3));
    }
    b
      ..writeln('## Enums')
      ..writeln()
      ..writeln('Written as the value\'s name, a JSON string (`"center"`).')
      ..writeln();
    for (final name in (catalog['enums'] as Map).keys) {
      b
        ..writeln(anchor('enum-$name'))
        ..writeln('### $name')
        ..writeln()
        ..writeln(_enumTable('$name'))
        ..writeln();
    }
    return b.toString();
  }

  String behaviors() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('behaviors', template('behaviors.md')))
      ..writeln('## Keys')
      ..writeln();
    for (final f in (catalog['behaviors']['fields'] as List).cast<Json>()) {
      b.writeln(anchor('behavior-${f['key']}'));
    }
    b
      ..writeln(_fieldTable(catalog['behaviors']['fields'] as List))
      ..writeln()
      ..writeln('The models these keys hold (and the models inside them) are in ${pageLink('values.md', 'Value types, models and enums')}: '
          '${{for (final f in (catalog['behaviors']['fields'] as List).cast<Json>()) if (f['object'] != null || f['item_object'] != null) link('values.md', 'type-${f['object'] ?? f['item_object']}', '${f['object'] ?? f['item_object']}')}.join(', ')}.')
      ..writeln();
    return b.toString();
  }

  String triggers() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('triggers', template('triggers.md')))
      ..writeln('## Trigger types')
      ..writeln();
    final groups = <String, String>{'pointer': 'On a node: pointer', 'input': 'On an input', 'screen': 'On a screen (fire while it shows, wherever they are set)', 'other': 'Scrolling, viewport, images, drag and drop, lists'};
    for (final g in groups.entries) {
      b
        ..writeln('### ${g.value}')
        ..writeln();
      final rows = [
        for (final t in (catalog['triggers']['types'] as List).cast<Json>())
          if (t['group'] == g.key) ['${anchor('trigger-${t['type']}')}`${t['type']}`', compact ? '' : '${t['doc']}'],
      ];
      b
        ..writeln(_table(['type', 'When'], rows))
        ..writeln();
    }
    b
      ..writeln('## Trigger fields')
      ..writeln()
      ..writeln('A trigger is `{"type": "<type>", ...these}`, or just the type as a string (`"click"`).')
      ..writeln()
      ..writeln(_fieldTable(catalog['triggers']['fields'] as List));
    return b.toString();
  }

  String actions() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('actions', template('actions.md')))
      ..writeln('## Fields every action has')
      ..writeln()
      ..writeln(_fieldTable(catalog['actions']['common'] as List))
      ..writeln()
      ..writeln('Fields holding nested action chains (a list of actions): ${[for (final k in catalog['actions']['nestedChainKeys'] as List) '`$k`'].join(', ')}.')
      ..writeln();
    for (final e in (catalog['actions']['types'] as Map).entries) {
      final a = e.value as Json;
      b
        ..writeln(anchor('action-${e.key}'))
        ..writeln('## `${e.key}`: ${a['label']}')
        ..writeln();
      if (!compact && '${a['doc']}'.isNotEmpty) b..writeln(a['doc'])..writeln();
      b
        ..writeln(_fieldTable(a['fields'] as List))
        ..writeln();
    }
    return b.toString();
  }

  String bindings() {
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('bindings', template('bindings.md')))
      ..writeln('## Named paths')
      ..writeln()
      ..writeln(_table(['Path', 'Meaning'], [
        for (final c in (catalog['bindings']['constants'] as List).cast<Json>()) ['`${c['path']}`', '${c['doc']}'],
      ]))
      ..writeln()
      ..writeln('## What each path expects')
      ..writeln()
      ..writeln('A formula gives the value as the field is written in JSON: a number, `true`/`false`, a name for an enum, '
          'a list or an object for the fields written that way. A value of another shape is not read and the field keeps its value.')
      ..writeln()
      ..writeln(_table(['Path', 'Type', 'A formula gives'], [
        for (final (path, type, kind) in [
          ('visible', 'bool', 'boolean'), ('opacity', 'double', 'number'), ('selected', 'bool', 'boolean'),
          ('disabled', 'bool', 'boolean'), ('data', 'List', 'list'),
          for (final f in (catalog['layout']['fields'] as List).cast<Json>()) ('layout.${f['key']}', '${f['type']}', '${f['kind']}'),
          for (final f in (catalog['decoration']['fields'] as List).cast<Json>()) ('decoration.${f['key']}', '${f['type']}', '${f['kind']}'),
        ])
          ['`$path`', '`$type`', _bindForm(type, kind)],
      ]))
      ..writeln()
      ..writeln('`props.<prop>` takes what the prop\'s type is written as ([node types](nodes.md), [value types](values.md)): '
          '`"\${= open ? \'vertical\' : \'horizontal\'}"` for `props.direction`, a TextStyle object or a theme style\'s name for `props.style`. '
          'A theme color\'s name is not read from a formula: give `\${theme.colors.ember}` (its value).')
      ..writeln()
      ..writeln('## Every bindable field')
      ..writeln()
      ..writeln('- `layout.<field>`: ${[for (final f in catalog['layout']['fields'] as List) '`${f['key']}`'].join(', ')}, and `widthFactor`, `heightFactor`.')
      ..writeln('- `decoration.<field>`: ${[for (final f in catalog['decoration']['fields'] as List) '`${f['key']}`'].join(', ')}. '
          'Inside `fills`, `strokes`, `foregroundFills` and `effects`, select an item by `[index]`, by its `id`, or every item by `*`, then a field of '
          '${link('values.md', 'type-Paint', 'Paint')} or ${link('values.md', 'type-Effect', 'Effect')} (`decoration.fills[0].color`, `decoration.effects.*.color`, `.offset.dx`).')
      ..writeln('- `props.<prop>`: any prop of the node\'s type (${pageLink('nodes.md', 'node types')}), and `props.<prop>.<field>` for a field of a model prop.')
      ..writeln('- `<behavior>` and `<behavior>.<field>`: ${[for (final f in catalog['behaviors']['fields'] as List) '`${f['key']}`'].join(', ')}.')
      ..writeln()
      ..writeln('## Scopes')
      ..writeln()
      ..writeln('Names an expression may start with besides the screen\'s variables: ${[for (final s in catalog['scopes'] as List) '`$s`'].join(', ')}.')
      ..writeln();
    return b.toString();
  }

  /// How a formula writes a value of [type] (its JSON form).
  String _bindForm(String type, String kind) {
    final forms = valueForms[type];
    if (forms != null) return forms;
    if (type.startsWith('List<')) return 'a list of ${type.substring(5, type.length - 1)} objects';
    return switch (kind) {
      'boolean' => '`true` or `false`',
      'integer' => 'a whole number',
      'number' => 'a number',
      'string' => 'text',
      'enumeration' => 'one of its names (${link('values.md', 'enum-$type', type)})',
      'list' => 'a list',
      'object' => 'a $type object',
      _ => type,
    };
  }

  String formulas() {
    final f = catalog['formulas'] as Json;
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('formulas', template('formulas.md')))
      ..writeln('Source: ${f['source'] ?? 'tool/reference/data/formulas.json'}.')
      ..writeln()
      ..writeln(_table(['Function', 'Signature', 'Example'], [
        for (final fn in (f['functions'] as List).cast<Json>()) ['`${fn['name']}`', '`${fn['signature']}`', '`${fn['example']}`'],
      ]))
      ..writeln();
    final undocumented = f['undocumented'] as List? ?? const [];
    if (undocumented.isNotEmpty) {
      b.writeln('Functions without an entry in the table: ${undocumented.map((u) => '`$u`').join(', ')}.');
    }
    return b.toString();
  }

  String variablesConditionsScripts() {
    final c = catalog['conditions'] as Json;
    final b = StringBuffer()
      ..writeln(_generatedNote())
      ..writeln(_header('variables-conditions-scripts', template('variables-conditions-scripts.md')))
      ..writeln('## Variable fields')
      ..writeln()
      ..writeln(_table(['Key', 'Example', 'Meaning'], [
        for (final v in (catalog['variables']['fields'] as List).cast<Json>()) ['`${v['key']}`', '`${jsonEncode(v['example'])}`', '${v['doc']}'],
      ]))
      ..writeln()
      ..writeln('### Variable types')
      ..writeln()
      ..writeln(_enumTable('VariableType'))
      ..writeln()
      ..writeln('## Conditions')
      ..writeln()
      ..writeln(c['conditionDoc'])
      ..writeln()
      ..writeln('- Branch: ${c['branchDoc']}')
      ..writeln('- Set entry: ${c['setDoc']}')
      ..writeln('- Comparison: ${c['comparisonDoc']}')
      ..writeln('- Junction: ${c['junctionDoc']}')
      ..writeln('- Operand: ${c['operandDoc']}')
      ..writeln()
      ..writeln('### Comparison ops')
      ..writeln()
      ..writeln(_table(['op', 'Reads right', 'Meaning'], [
        for (final o in (c['ops'] as List).cast<Json>()) ['`${o['op']}`', o['takesRight'] == true ? 'yes' : 'no', '${o['doc']}'],
      ]))
      ..writeln()
      ..writeln('## Scripts')
      ..writeln()
      ..writeln(_fieldTable(catalog['scripts']['fields'] as List))
      ..writeln()
      ..writeln('## Breakpoints')
      ..writeln()
      ..writeln(_fieldTable(catalog['breakpoints']['fields'] as List))
      ..writeln()
      ..writeln('Defaults:')
      ..writeln()
      ..writeln(_breakpointDefaults());
    return b.toString();
  }
}

/// JSON with small objects and lists on one line, for examples.
String prettyJson(Object? v, [String indent = '']) {
  final flat = flatJson(v);
  if (flat.length + indent.length <= 110 || (v is! Map && v is! List)) return flat;
  final inner = '$indent  ';
  if (v is List) {
    return '[\n${[for (final x in v) '$inner${prettyJson(x, inner)}'].join(',\n')}\n$indent]';
  }
  final m = v as Map;
  return '{\n${[for (final e in m.entries) '$inner${jsonEncode(e.key)}: ${prettyJson(e.value, inner)}'].join(',\n')}\n$indent}';
}

/// JSON on one line with a space after each `:` and `,`.
String flatJson(Object? v) {
  if (v is Map) return '{${[for (final e in v.entries) '${jsonEncode(e.key)}: ${flatJson(e.value)}'].join(', ')}}';
  if (v is List) return '[${v.map(flatJson).join(', ')}]';
  return jsonEncode(v);
}
