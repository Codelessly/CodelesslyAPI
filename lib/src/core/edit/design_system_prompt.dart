// What a model is told about the design system its UI is made with: the
// section the runtime base gains ([designSystemSection]) and the ui_docs
// topics that answer the rest ([designSystemTopic]). Generated from the
// design system's own data, so the prompt and the system never disagree.
import 'dart:convert';

import '../design_system.dart';
import '../props.dart';
import '../sections.dart';
import '../theme.dart';
import 'starter.dart' show propTypeLabel;

/// The section of the base for [ds]: its principles in brief, its tokens by
/// name, its components (each with its purpose, parameters, slots, events
/// and a minimal call) and its patterns in brief.
String designSystemSection(DesignSystem ds, {bool docsTool = true}) {
  final b = StringBuffer()
    ..writeln('## The design system: ${ds.name}')
    ..writeln()
    ..writeln('Every UI you make is in ${ds.name}${ds.manifest.description.isEmpty ? '' : ': ${ds.manifest.description.replaceFirst(RegExp(r'[.\s]+$'), '')}'}. '
        'Compose it from its components (below) and the layout nodes (`column`, `row`, `stack`, `text`, `icon`, `box`); '
        'style it with its tokens by name. Its components carry its look: do not restyle them, and do not draw a control '
        'yourself when a component is one.')
    ..writeln();
  final principles = _brief(ds.design);
  if (principles.isNotEmpty) {
    b
      ..writeln('### Principles')
      ..writeln()
      ..writeln(principles)
      ..writeln();
  }
  b
    ..writeln('### Tokens')
    ..writeln()
    ..writeln(_tokens(ds.tokens))
    ..writeln()
    ..writeln('### Components')
    ..writeln()
    ..writeln('Call one with a node whose `type` is its name: its parameters in `props` (or bound, `"bind": {"props.label": '
        '"\${item.name}"}`), slot content by id in `slots`, the call\'s `layout` sizing it (a call takes no `decoration`). '
        'Its events are handled by reactions on the call, `{"trigger": {"type": "event", "event": "onPressed"}, "actions": '
        '[...]}`, the value in `\${result}`. A `variable` parameter takes the name of one of your variables and keeps it '
        'in step (two-way).')
    ..writeln();
  for (final c in ds.list) {
    b.writeln(_component(c));
  }
  final patterns = _brief(ds.patterns);
  if (patterns.isNotEmpty) {
    b
      ..writeln()
      ..writeln('### Patterns')
      ..writeln()
      ..writeln(patterns);
  }
  if (docsTool) {
    b
      ..writeln()
      ..writeln('More: ui_docs "design" (the principles in full), "patterns" (every pattern), or a component\'s name (all its '
          'parameters).');
  }
  return b.toString().trimRight();
}

/// The `ui_docs` answer for [topic] from [ds]: `design` (DESIGN.md),
/// `patterns` (PATTERNS.md), `tokens`, or a component's name (its whole
/// declaration). Null when [topic] is none of them.
String? designSystemTopic(DesignSystem ds, String topic) {
  final t = topic.trim();
  final lower = t.toLowerCase();
  if (lower == 'design' || lower == 'design.md' || lower == 'principles') return ds.design.isEmpty ? null : ds.design;
  if (lower == 'patterns' || lower == 'patterns.md') return ds.patterns.isEmpty ? null : ds.patterns;
  if (lower == 'tokens' || lower == 'design-system') return '# ${ds.name}: tokens\n\n${_tokens(ds.tokens)}';
  for (final c in ds.list) {
    if (c.type == t || c.type.toLowerCase() == lower) return _componentInFull(c);
  }
  return null;
}

/// The section of [text] headed "In brief" (to the next heading of its
/// level or higher), else [text] whole when it is short, else its first
/// paragraphs up to about 2,400 characters.
String _brief(String text) {
  final t = text.replaceFirst(RegExp(r'^---\n.*?\n---\n', dotAll: true), '').trim();
  if (t.isEmpty) return '';
  final m = RegExp(r'^(#{2,3}) In brief\s*$', multiLine: true).firstMatch(t);
  if (m != null) {
    final level = m[1]!.length;
    final rest = t.substring(m.end);
    final next = RegExp('^#{1,$level} ', multiLine: true).firstMatch(rest);
    return (next == null ? rest : rest.substring(0, next.start)).trim();
  }
  if (t.length <= 2400) return t;
  final out = StringBuffer();
  for (final p in t.split(RegExp(r'\n\s*\n'))) {
    if (out.length + p.length > 2400) break;
    out
      ..writeln(p)
      ..writeln();
  }
  return out.toString().trim();
}

String _num(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';

String _tokens(ThemeTokens t) {
  final lines = <String>[];
  final roles = [
    for (final r in const ['primary', 'onPrimary', 'surface', 'onSurface', 'error', 'success', 'warning'])
      if (t.color(r) != null) r,
  ];
  if (roles.isNotEmpty || t.colors.isNotEmpty) {
    lines.add('- **Colors** (write the name wherever a color goes, `"color": "${t.colors.keys.firstOrNull ?? roles.first}"`; '
        'each has a dark value): ${[...roles, ...t.colors.keys].map((n) => '`$n`').join(', ')}.');
  }
  if (t.textStyles.isNotEmpty) {
    final styles = [
      for (final e in t.textStyles.entries)
        if (t.textStyle(e.key) case final s?)
          '`${e.key}` ${[if (s.fontSize != null) _num(s.fontSize!), if (s.fontWeight != null) '${s.fontWeight!}'].join('/')}',
    ];
    lines.add('- **Text styles** (`"style": "${t.textStyles.keys.first}"`, or `{"from": "${t.textStyles.keys.first}", '
        '"color": ...}`): ${styles.join(', ')}.');
  }
  // A step is read in a binding, never written as a value: the field (a
  // number) takes the binding's result. Shown as the binding to write, as
  // models wrote `"radius": "\${theme.radii.panel}"` from the bare form.
  void scale(String key, String label, Map<String, Object> values, String unit, {String? field}) {
    if (values.isEmpty) return;
    final read = '\${theme.$key.${values.keys.first}}';
    lines.add('- **$label** (${field == null ? '`$read` in a binding' : 'bound, not written: `"bind": {"$field": "$read"}`'}): '
        '${[for (final e in values.entries) '`${e.key}` ${e.value is double ? _num(e.value as double) : e.value}$unit'].join(', ')}.');
  }

  scale('spacing', 'Spacing', t.spacing, '', field: 'layout.padding');
  scale('radii', 'Radii', t.radii, '', field: 'decoration.radius');
  scale('sizes', 'Sizes', t.sizes, '', field: 'layout.height');
  if (t.shadows.isNotEmpty) {
    lines.add('- **Shadows** (`"bind": {"decoration.effects": "\${theme.shadows.${t.shadows.keys.first}}"}`): '
        '${t.shadows.keys.map((n) => '`$n`').join(', ')}.');
  }
  scale('durations', 'Durations', t.durations, ' ms');
  scale('curves', 'Curves', t.curves, '');
  return lines.join('\n');
}

String _param(PropDef<Object?> p) {
  // A variable parameter takes the name of one of the caller's variables.
  if (p.type.isVariable) return '`${p.key}` the name of your ${propTypeLabel(p.type.variableOf!)} variable';
  final def = p.required ? 'required' : '= ${jsonEncode(p.encode(p.defaultValue))}';
  return '`${p.key}` ${propTypeLabel(p.type)} $def';
}

String _component(DesignSystemComponent c) {
  final s = c.spec;
  final parts = <String>[
    if (s.props.isNotEmpty) s.props.map(_param).join(', '),
    if (s.children.name == 'list') 'children',
    if (s.slots.isNotEmpty) 'slots ${s.slots.map((x) => '`$x`').join(', ')}',
    if (s.events.isNotEmpty) 'events ${s.events.map((e) => '`${e.key}`').join(', ')}',
  ];
  return '- **`${c.type}`**: ${c.purpose} ${parts.join('; ')}.\n  `${jsonEncode(c.example)}`';
}

String _componentInFull(DesignSystemComponent c) {
  final s = c.spec;
  final b = StringBuffer('# `${c.type}`\n\n${s.doc}\n\n')
    ..writeln('| parameter | type | default | |')
    ..writeln('|---|---|---|---|');
  for (final p in s.props) {
    final type = p.type.isVariable ? 'the name of your ${propTypeLabel(p.type.variableOf!)} variable' : propTypeLabel(p.type);
    final def = p.type.isVariable ? '' : (p.required ? 'required' : '`${jsonEncode(p.encode(p.defaultValue))}`');
    b.writeln('| `${p.key}` | $type | $def | ${p.doc} |');
  }
  if (s.slots.isNotEmpty) b.writeln('\nSlots: ${s.slots.map((x) => '`$x`').join(', ')}.');
  if (s.events.isNotEmpty) {
    b.writeln('\nEvents: ${[for (final e in s.events) '`${e.key}`${e.doc.isEmpty ? '' : ' (${e.doc})'}'].join(', ')}.');
  }
  b
    ..writeln()
    ..writeln('A call:')
    ..writeln()
    ..writeln('```json')
    ..writeln(jsonEncode(c.example))
    ..writeln('```');
  for (final p in c.document.previews.skip(1).take(3)) {
    b.writeln('\n${p.name}: `${jsonEncode({'type': c.type, 'props': p.props})}`');
  }
  return b.toString().trimRight();
}
