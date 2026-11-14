// The reference pages, rendered from the catalog (catalog.dart), the page
// assignment (areas.dart) and the templates (tool/reference/templates).
// Tables come only from the catalog; prose only from templates.
//
// Template syntax:
// * `{{name}}` a generated table or list (the fills below);
// * `{{example:path}}` an example document (tool/reference/examples/<path>.json),
//   verified by test/reference_test.dart;
// * `[text](@anchor)` a link to the page that defines `anchor`, wherever it is;
// * every `#`, `##` and `###` heading gets a stable anchor: `page-<page>` for
//   the title, `<page>-<slug of the heading>` for the others, unless an
//   `<a id>` line already precedes it.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart'
    show Catalog, EditCodes, EditOp, Json, LayoutDocument, TrustProfile, applyOps, opsFromDocument, uiTools;
import 'package:codelessly_api/validate.dart' show valueForms;

import 'areas.dart';
import 'introspect.dart';

/// How links are written: across page files, or within one file
/// (API_REFERENCE.md).
enum LinkMode { pages, single }

final class Renderer {
  Renderer(this.catalog, this.root, this.assignment);

  /// The catalog (catalog.dart), read dynamically.
  final Map<String, dynamic> catalog;
  final String root;
  final Assignment assignment;

  String get _templates => '$root/tool/reference/templates';

  /// Every anchor, by the file that defines it (filled as pages render).
  final Map<String, String> anchors = {};

  // --- templates ------------------------------------------------------------------

  /// Template [name] with its fills and examples applied; fills named in
  /// [keep] are left for a later step.
  String template(String name, {Map<String, String Function()> fills = const {}, Set<String> keep = const {}}) {
    // `\{{` is a literal `{{`.
    var text = File('$_templates/$name').readAsStringSync().replaceAll(r'\{{', '\u0000');
    text = text.replaceAllMapped(RegExp(r'\{\{example:([\w/-]+)\}\}'), (m) => '```json\n${example(m[1]!)}\n```');
    text = text.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (m) {
      if (keep.contains(m[1])) return m[0]!;
      final f = fills[m[1]] ?? _fills[m[1]];
      if (f == null) throw StateError('Template $name: no fill for {{${m[1]}}}');
      return f();
    });
    return text.replaceAll('\u0000', '{{').trimRight();
  }

  String example(String name) => prettyJson(jsonDecode(File('$root/tool/reference/examples/$name.json').readAsStringSync()));

  /// [text] with an anchor before every heading: `page-[page]` for the
  /// title, `[prefix]-<slug>` for the others.
  static String anchorHeadings(String text, String page, {String? prefix}) {
    final lines = text.split('\n');
    final out = <String>[];
    final seen = <String>{};
    var fence = false;
    for (final l in lines) {
      if (l.startsWith('```')) fence = !fence;
      final m = fence ? null : RegExp(r'^(#{1,4}) (.+)$').firstMatch(l);
      if (m != null && !(out.isNotEmpty && out.last.startsWith('<a id='))) {
        final id = m[1] == '#' ? 'page-$page' : '${prefix ?? page}-${slug(m[2]!)}';
        if (!seen.add(id)) throw StateError('$page: two headings make the anchor $id');
        out.add('<a id="$id"></a>');
      }
      out.add(l);
    }
    return out.join('\n');
  }

  /// A heading's anchor slug: lower case, words joined by `-`.
  static String slug(String heading) => heading
      .replaceAll(RegExp(r'\[([^\]]*)\]\([^)]*\)'), r'$1')
      .replaceAll(RegExp(r'[`*]'), '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  /// Records the anchors [file] defines.
  void collect(String file, String text) {
    for (final m in RegExp(r'<a id="([^"]+)"></a>').allMatches(text)) {
      final had = anchors[m[1]!];
      if (had != null && had != file) throw StateError('anchor ${m[1]} defined in $had and $file');
      anchors[m[1]!] = file;
    }
  }

  /// [text] with `(@anchor)` links resolved to the file defining the anchor.
  String resolve(String text, String self) {
    final unknown = <String>{};
    final out = text.replaceAllMapped(RegExp(r'\]\(@([\w.-]+)\)'), (m) {
      final file = anchors[m[1]!];
      if (file == null) {
        unknown.add(m[1]!);
        return m[0]!;
      }
      return file == self ? '](#${m[1]})' : ']($file#${m[1]})';
    });
    if (unknown.isNotEmpty) throw StateError('$self: links to unknown anchors: ${unknown.join(', ')}');
    return out;
  }

  /// [text] (a page of the folder) with its links made to work inside one
  /// file holding every page.
  static String singleFile(String text) => text
      .replaceAllMapped(RegExp(r'\]\((?:[\w-]+|STARTER|RUNTIME_STARTER)\.md#([\w.-]+)\)'), (m) => '](#${m[1]})')
      .replaceAllMapped(RegExp(r'\]\(([\w-]+)\.md\)'), (m) => switch (m[1]) {
            'STARTER' => '](#page-base)',
            'RUNTIME_STARTER' || 'README' => m[0]!,
            _ => '](#page-${m[1]})',
          });

  // --- links ------------------------------------------------------------------------

  String pageOf(ItemKind kind, String name) => assignment[kind]![name] ?? valuesPage;

  String itemLink(ItemKind kind, String name, [String? text]) =>
      '[${text ?? '`$name`'}](${pageOf(kind, name)}.md#${kind.anchor(name)})';

  /// A field's type, linked to where its type is described.
  String _type(Json f) {
    String one(String name, String k) => switch (k) {
          'object' => itemLink(ItemKind.model, name, name),
          'value' => itemLink(ItemKind.valueType, name, name),
          'enumeration' => itemLink(ItemKind.enumeration, name, name),
          _ => name,
        };
    if (f['kind'] == 'list') return 'List<${one('${f['item']}', '${f['itemKind']}')}>';
    return one('${f['type']}', '${f['kind']}');
  }

  // --- tables -------------------------------------------------------------------------

  static String cell(String s) => s.replaceAll('|', r'\|').replaceAll('\n\n', '<br><br>').replaceAll('\n', ' ');

  static String table(List<String> head, List<List<String>> rows) {
    final b = StringBuffer()
      ..writeln('| ${head.join(' | ')} |')
      ..writeln('|${head.map((_) => '---').join('|')}|');
    for (final r in rows) {
      b.writeln('| ${r.map(cell).join(' | ')} |');
    }
    return b.toString().trimRight();
  }

  static String _jsonInline(Object? v) {
    final s = jsonEncode(v);
    return s.length > 60 ? '${s.substring(0, 57)}...' : s;
  }

  static String _default(Json f) {
    final d = f['default'];
    if (d == null) return 'unset';
    if (d is List && d.isEmpty) return '`[]`';
    if (d is Map && d.isEmpty) return '`{}`';
    return '`${_jsonInline(d)}`';
  }

  static String _num(Object? n) => n is double && n == n.roundToDouble() ? '${n.toInt()}' : '$n';

  /// Allowed values / bounds for a field.
  static String _allowed(Json f) {
    final parts = <String>[];
    final values = (f['values'] ?? f['item_values']) as List?;
    if (values != null) parts.add(values.map((v) => '`$v`').join(', '));
    if (f['min'] != null || f['max'] != null) {
      parts.add('${f['min'] == null ? '' : '≥ ${_num(f['min'])}'}${f['min'] != null && f['max'] != null ? ', ' : ''}'
          '${f['max'] == null ? '' : '≤ ${_num(f['max'])}'}');
    }
    return parts.join('; ');
  }

  String fieldTable(List fields) {
    if (fields.isEmpty) return '_No fields._';
    return table(['Key', 'Type', 'Default', 'Allowed', 'Description'], [
      for (final f in fields.cast<Json>()) ['`${f['key']}`', _type(f), _default(f), _allowed(f), '${f['doc']}'],
    ]);
  }

  String enumTable(String name) {
    final values = (catalog['enums'] as Map)[name] as List?;
    if (values == null) return '';
    final documented = values.any((v) => (v['doc'] as String).isNotEmpty);
    if (!documented) return values.map((v) => '`${v['value']}`').join(', ');
    return table(['Value', 'Meaning'], [for (final v in values) ['`${v['value']}`', '${v['doc']}']]);
  }

  String _childrenRule(Json t) {
    final slots = [for (final s in t['slots'] as List) '`$s`'].join(', ');
    return switch (t['children']) {
      'list' => (t['slots'] as List).isEmpty ? '`children`' : '`children` and slots: $slots',
      'slots' => 'slots: $slots',
      _ => 'none',
    };
  }

  String breakpointDefaults() => table(['id', 'name', 'minWidth', 'design width × height'], [
        for (final b in catalog['breakpoints']['defaults'] as List)
          ['`${b['id']}`', '${b['name'] ?? ''}', '${b['minWidth'] ?? 0}', '${b['width']} × ${b['height']}'],
      ]);

  String _childFits() {
    String describe(Map axis) => [
          for (final e in axis.entries)
            if (e.value == null)
              e.key
            else if (e.key == 'fill' && '${e.value}'.contains('basis'))
              'fill (with `basis`)',
        ].join(', ');
    return table(['Parent', 'Width may be', 'Height may be'], [
      for (final p in catalog['layout']['childFits'] as List)
        [
          '`${p['parent']}`${(p['props'] as Map).isEmpty ? '' : ' with ${jsonEncode(p['props'])}'}',
          describe(p['width'] as Map),
          describe(p['height'] as Map),
        ],
    ]);
  }

  String _childFitReasons() {
    final reasons = <String>{};
    for (final p in catalog['layout']['childFits'] as List) {
      for (final axis in const ['width', 'height']) {
        for (final r in (p[axis] as Map).values) {
          if (r != null) reasons.add('$r');
        }
      }
    }
    return [for (final r in reasons) '- $r'].join('\n');
  }

  /// A class's documented fields (no PropDefs), for models read by their
  /// class: `| key | meaning |`.
  String _classFields(String cls, List<String> keys) {
    final docs = DocIndex.instance.fieldDocs[cls] ?? const {};
    return table(['Key', 'Meaning'], [for (final k in keys) ['`$k`', docs[k] ?? '']]);
  }

  // --- reference sections of items --------------------------------------------------------

  final Set<String> _modelsShown = {};

  String nodeSection(String type) {
    final t = (catalog['nodeTypes'] as Map)[type] as Json;
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.node.anchor(type)}"></a>')
      ..writeln('### `$type`')
      ..writeln();
    if ('${t['doc']}'.isNotEmpty) b..writeln(t['doc'])..writeln();
    b.writeln('- Children: ${_childrenRule(t)}.');
    b.writeln('- Decoration: ${t['decorated'] == true ? 'box decoration (fills, strokes, radius, shadows, clip)' : 'none: only blur effects in `decoration.effects` apply'}.');
    final childFields = t['childFields'] as List;
    if (childFields.isNotEmpty) {
      b.writeln('- Reads from each child\'s layout: ${[for (final f in childFields) '[`$f`](layout.md#layout-$f)'].join(', ')}.');
    }
    b
      ..writeln()
      ..writeln((t['props'] as List).isEmpty ? '_No props._' : fieldTable(t['props'] as List))
      ..writeln();
    return b.toString();
  }

  String modelSection(String name, {String level = '###'}) {
    final t = (catalog['objectTypes'] as Map)[name] as Json?;
    if (t == null || !_modelsShown.add(name)) return '';
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.model.anchor(name)}"></a>')
      ..writeln('$level $name')
      ..writeln();
    if ('${t['doc']}'.isNotEmpty) b..writeln(t['doc'])..writeln();
    b
      ..writeln(fieldTable(t['fields'] as List))
      ..writeln();
    return b.toString();
  }

  String behaviorSection(String key) {
    final f = (catalog['behaviors']['fields'] as List).cast<Json>().firstWhere((f) => f['key'] == key);
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.behavior.anchor(key)}"></a>')
      ..writeln('### `$key` (behavior)')
      ..writeln()
      ..writeln('A node key (beside `layout` and `props`). Type: ${_type(f)}. Default: ${_default(f)}.${_allowed(f).isEmpty ? '' : ' Allowed: ${_allowed(f)}.'}')
      ..writeln();
    if ('${f['doc']}'.isNotEmpty) b..writeln(f['doc'])..writeln();
    final model = (f['object'] ?? f['item_object']) as String?;
    if (model != null && pageOf(ItemKind.model, model) == pageOf(ItemKind.behavior, key)) {
      b.write(modelSection(model, level: '####'));
    }
    return b.toString();
  }

  String triggerTable(List<String> types) {
    final all = {for (final t in (catalog['triggers']['types'] as List).cast<Json>()) t['type'] as String: t};
    return table(['Trigger', 'When it fires'], [
      for (final t in types) ['<a id="${ItemKind.trigger.anchor(t)}"></a>`$t`', '${all[t]!['doc']}'],
    ]);
  }

  String actionSection(String type) {
    final a = (catalog['actions']['types'] as Map)[type] as Json;
    final b = StringBuffer()
      ..writeln('<a id="${ItemKind.action.anchor(type)}"></a>')
      ..writeln('### `$type` (action): ${a['label']}')
      ..writeln();
    if ('${a['doc']}'.isNotEmpty) b..writeln(a['doc'])..writeln();
    b
      ..writeln(fieldTable(a['fields'] as List))
      ..writeln();
    return b.toString();
  }

  /// The Reference section's items for page [p]: node types, behaviors,
  /// triggers, actions and the models the page claims, in that order.
  String reference(PageDef p) {
    final nodes = [
      ...p.nodes,
      if (p.library case final lib?) for (final w in lib.widgets) w.type,
    ];
    final actions = [
      ...p.actions,
      if (p.library case final lib?) for (final a in lib.actions) a.type,
    ];
    final b = StringBuffer();
    for (final n in nodes) {
      b.write(nodeSection(n));
    }
    for (final k in p.behaviors) {
      b.write(behaviorSection(k));
    }
    if (p.triggers.isNotEmpty) {
      b
        ..writeln('<a id="${p.id}-triggers"></a>')
        ..writeln('### Triggers')
        ..writeln()
        ..writeln('Written as `"trigger": {"type": "<trigger>", ...}` in a reaction ([trigger fields](interaction.md#interaction-trigger-fields)).')
        ..writeln()
        ..writeln(triggerTable(p.triggers))
        ..writeln();
    }
    for (final a in actions) {
      b.write(actionSection(a));
    }
    for (final e in assignment[ItemKind.model]!.entries) {
      if (e.value == p.id && p.models.contains(e.key)) b.write(modelSection(e.key));
    }
    return b.toString().trimRight();
  }

  // --- the fills ----------------------------------------------------------------------------

  late final Map<String, String Function()> _fills = {
    'version': () => '${catalog['version']}',
    'documentKeys': () => table(['Key', 'Meaning'], [
          for (final k in catalog['document']['keys'] as List) ['`${k['key']}`', '${k['doc']}'],
        ]),
    'nodeKeys': () => table(['Key', 'Type', 'Meaning'], [
          for (final k in catalog['node']['structural'] as List) ['`${k['key']}`', '`${k['type']}`', '${k['doc']}'],
          for (final f in catalog['node']['fields'] as List) ['`${f['key']}`', _type(f), 'Default ${_default(f)}. ${f['doc']}'],
          ['behavior keys', '', 'What a node does beyond layout and paint (`states`, `motion`, `sticky`...): the [A–Z](index.md#index-a-z) lists each.'],
        ]),
    'breakpointDefaults': breakpointDefaults,
    'breakpointFields': () => fieldTable(catalog['breakpoints']['fields'] as List),
    'childFits': _childFits,
    'childFitReasons': _childFitReasons,
    'layoutFields': () => [
          for (final f in (catalog['layout']['fields'] as List).cast<Json>()) '<a id="layout-${f['key']}"></a>',
          fieldTable(catalog['layout']['fields'] as List),
          '',
          'Read by decoding but not declared as fields: ${[for (final k in catalog['layout']['undeclared'] as List) '`$k`'].join(', ')}. '
              '${catalog['layout']['undeclaredDoc']}',
        ].join('\n'),
    'mediaRuleFields': () => _classFields('MediaRule', const ['minWidth', 'maxWidth', 'orientation', 'patch']),
    'themeKeys': () => _classFields('ThemeTokens', const [
          'colors', 'textStyles', 'dark', 'media', 'primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning', //
          'fontFamily', 'titleFontFamily', 'radius', 'buttonRadius', 'spacing', 'radii', 'sizes', 'shadows', 'durations', 'curves',
        ]),
    'decorationFields': () => fieldTable(catalog['decoration']['fields'] as List),
    'variableFields': () => table(['Key', 'Example', 'Meaning'], [
          for (final v in (catalog['variables']['fields'] as List).cast<Json>()) ['`${v['key']}`', '`${jsonEncode(v['example'])}`', '${v['doc']}'],
        ]),
    'variableTypes': () => enumTable('VariableType'),
    'scopes': () => [for (final s in catalog['scopes'] as List) '`$s`'].join(', '),
    'conditionOps': () => table(['op', 'Reads right', 'Meaning'], [
          for (final o in catalog['conditions']['ops'] as List) ['`${o['op']}`', o['takesRight'] == true ? 'yes' : 'no', '${o['doc']}'],
        ]),
    'conditionParts': () {
      final c = catalog['conditions'] as Json;
      return [
        '${c['conditionDoc']}',
        '',
        '- Branch: ${c['branchDoc']}',
        '- Set entry: ${c['setDoc']}',
        '- Comparison: ${c['comparisonDoc']}',
        '- Junction: ${c['junctionDoc']}',
        '- Operand: ${c['operandDoc']}',
      ].join('\n');
    },
    'scriptFields': () => fieldTable(catalog['scripts']['fields'] as List),
    'bindingPaths': _bindingPaths,
    'bindableFields': _bindableFields,
    'namedPaths': () => table(['Path', 'Meaning'], [
          for (final c in (catalog['bindings']['constants'] as List).cast<Json>()) ['`${c['path']}`', '${c['doc']}'],
        ]),
    'formulaFunctions': _formulaFunctions,
    'triggerFields': () => fieldTable(catalog['triggers']['fields'] as List),
    'actionCommonFields': () => [
          fieldTable(catalog['actions']['common'] as List),
          '',
          'Fields holding nested action chains (a list of actions): ${[for (final k in catalog['actions']['nestedChainKeys'] as List) '`$k`'].join(', ')}.',
        ].join('\n'),
    'diagnosticCodes': () => table(['Code', 'Severity', 'Meaning'], [
          for (final d in catalog['diagnostics'] as List) ['`${d['code']}`', '${d['severity']}', '${d['meaning']}'],
        ]),
    'editOps': () => table(['Op', 'Fields', 'Means', 'Example'], [
          for (final o in EditOp.specs)
            [
              '`${o.op}`',
              [for (final f in o.fields) if (f.key != 'op') '`${f.key}`${f.required ? ' (required)' : ''}'].join(', '),
              o.doc,
              '`${jsonEncode(o.example)}`',
            ],
        ]),
    'editCodes': () => table(['Code', 'Rejects the op', 'Meaning'], [
          for (final c in EditCodes.all) ['`${c.name}`', c.error ? 'yes' : 'no (a warning)', c.meaning],
        ]),
    'uiTools': () => '```json\n${prettyJson(uiTools(TrustProfile.agent.restrict(Catalog.core)).map((t) => {...t, 'input_schema': '(see ui_tools.json)'}).toList())}\n```',
    'editRejected': _editRejected,
    'editBuild': () => '```json\n${prettyJson({'ops': [for (final o in opsFromDocument(_minimal())) o.toJson()]})}\n```',
    'publishClasses': () => table(['Class', 'What it is'], [
          for (final c in const [
            'PublishModel', 'PublishLayout', 'PublishComponent', 'PublishComponentInfo', 'AppIdentity', 'PageIdentity', //
            'StyleSheet', 'NamedTextStyle', 'CanvasBreakpoint', 'PluginRef', 'Automation',
          ])
            ['`$c`', DocIndex.instance.classDocs[c] ?? ''],
        ]),
  };

  LayoutDocument _minimal() =>
      LayoutDocument.fromJson(jsonDecode(File('$root/tool/reference/examples/minimal.json').readAsStringSync()), catalog: Catalog.core);

  /// A batch with a rejected op, applied for real: the tool result a model
  /// reads.
  String _editRejected() {
    final doc = _minimal();
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

  /// The value each binding path expects.
  String _bindingPaths() => table(['Path', 'Type', 'A formula gives'], [
        for (final (path, type, kind) in [
          ('visible', 'bool', 'boolean'), ('opacity', 'double', 'number'), ('selected', 'bool', 'boolean'),
          ('disabled', 'bool', 'boolean'), ('data', 'List', 'list'),
          for (final f in (catalog['layout']['fields'] as List).cast<Json>()) ('layout.${f['key']}', '${f['type']}', '${f['kind']}'),
          for (final f in (catalog['decoration']['fields'] as List).cast<Json>()) ('decoration.${f['key']}', '${f['type']}', '${f['kind']}'),
        ])
          ['`$path`', '`$type`', _bindForm(type, kind)],
      ]);

  String _bindableFields() => [
        '- `layout.<field>`: ${[for (final f in catalog['layout']['fields'] as List) '`${f['key']}`'].join(', ')}, and `widthFactor`, `heightFactor`.',
        '- `decoration.<field>`: ${[for (final f in catalog['decoration']['fields'] as List) '`${f['key']}`'].join(', ')}. '
            'Inside `fills`, `strokes`, `foregroundFills` and `effects`, select an item by `[index]`, by its `id`, or every item by `*`, then a field of '
            '${itemLink(ItemKind.model, 'Paint', 'Paint')} or ${itemLink(ItemKind.model, 'Effect', 'Effect')} (`decoration.fills[0].color`, `decoration.effects.*.color`, `.offset.dx`).',
        '- `props.<prop>`: any prop of the node\'s type, and `props.<prop>.<field>` for a field of a model prop.',
        '- `<behavior>` and `<behavior>.<field>`: ${[for (final f in catalog['behaviors']['fields'] as List) itemLink(ItemKind.behavior, '${f['key']}')].join(', ')}.',
      ].join('\n');

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
      'enumeration' => 'one of its names (${itemLink(ItemKind.enumeration, type, type)})',
      'list' => 'a list',
      'object' => 'a $type object',
      _ => type,
    };
  }

  String _formulaFunctions() {
    final fns = (catalog['formulas']['functions'] as List).cast<Json>();
    final b = StringBuffer();
    final anchored = <String>{};
    for (final g in formulaGroups.entries) {
      b
        ..writeln('#### ${g.key}')
        ..writeln()
        ..writeln(table(['Function', 'Signature', 'Example'], [
          for (final name in g.value)
            for (final fn in fns.where((f) => f['name'] == name))
              ['${anchored.add(name) ? '<a id="${ItemKind.function.anchor(name)}"></a>' : ''}`$name`', '`${fn['signature']}`', '`${fn['example']}`'],
        ]))
        ..writeln();
    }
    final undocumented = catalog['formulas']['undocumented'] as List? ?? const [];
    if (undocumented.isNotEmpty) b.writeln('Functions without an entry in the table: ${undocumented.map((u) => '`$u`').join(', ')}.');
    return b.toString().trimRight();
  }

  // --- pages ---------------------------------------------------------------------------------

  String generatedNote() => '<!-- Generated by tool/reference/generate.dart from the declarations of codelessly_api '
      '${catalog['version']}. Do not edit: edit the declarations or tool/reference/templates. -->';

  /// A feature page, links unresolved.
  String featurePage(PageDef p) {
    final text = template('pages/${p.id}.md', fills: {'reference': () => reference(p)});
    return '${generatedNote()}\n${anchorHeadings(text, p.id)}\n';
  }

  /// values.md: value types, enums and the models no page claims.
  String valuesPageText() {
    final text = template('pages/values.md', fills: {
      'valueTypes': () => [
            for (final e in (catalog['valueTypes'] as Map).entries)
              '<a id="${ItemKind.valueType.anchor(e.key)}"></a>\n### ${e.key}\n\nJSON: ${e.value['forms']}.'
                  '${'${e.value['doc']}'.isEmpty ? '' : '\n\n${e.value['doc']}'}\n',
          ].join('\n'),
      'models': () => [
            for (final e in assignment[ItemKind.model]!.entries)
              if (e.value == valuesPage) modelSection(e.key),
          ].join(),
      'enums': () => [
            for (final name in (catalog['enums'] as Map).keys) '<a id="${ItemKind.enumeration.anchor(name)}"></a>\n### $name\n\n${enumTable('$name')}\n',
          ].join('\n'),
    });
    return '${generatedNote()}\n${anchorHeadings(text, valuesPage)}\n';
  }

  /// The A–Z of every item and the page that documents it.
  String az() {
    final entries = <(String, String)>[];
    for (final kind in ItemKind.values) {
      for (final e in assignment[kind]!.entries) {
        final label = switch (kind) {
          ItemKind.node => 'node type',
          ItemKind.behavior => 'behavior',
          ItemKind.trigger => 'trigger',
          ItemKind.action => 'action',
          ItemKind.valueType => 'value type',
          ItemKind.model => 'model',
          ItemKind.enumeration => 'enum',
          ItemKind.function => 'formula function',
        };
        entries.add((e.key, '[`${e.key}`](${e.value}.md#${kind.anchor(e.key)}) $label'));
      }
    }
    entries.sort((a, b) {
      final c = a.$1.toLowerCase().compareTo(b.$1.toLowerCase());
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
    final b = StringBuffer();
    String? letter;
    final line = <String>[];
    void flush() {
      if (letter != null) b.writeln('**$letter** · ${line.join(' · ')}\n');
      line.clear();
    }

    for (final (name, link) in entries) {
      final l = name[0].toUpperCase();
      if (l != letter) {
        flush();
        letter = l;
      }
      line.add(link);
    }
    flush();
    return b.toString().trimRight();
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
