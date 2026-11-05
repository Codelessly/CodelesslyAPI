/// Writes a [DesignKit] as DESIGN.md text that [DesignMdParser] reads back
/// to the same kit.
library;

import 'design_kit.dart';

/// `lineHeight` → `Line height`.
String sentenceCase(String camel) {
  if (camel.isEmpty) return camel;
  final String spaced = camel.replaceAllMapped(
    RegExp('(?<=[a-z0-9])([A-Z])'),
    (Match m) => ' ${m[1]!.toLowerCase()}',
  );
  return spaced[0].toUpperCase() + spaced.substring(1);
}

/// Writes DESIGN.md text.
class DesignMdWriter {
  /// Creates a [DesignMdWriter].
  const DesignMdWriter();

  /// The DESIGN.md text of [kit].
  String write(DesignKit kit) {
    final StringBuffer out = StringBuffer()
      ..writeln('---')
      ..writeln('name: ${kit.name}')
      ..writeln('version: ${kit.version}');
    if (kit.description.isNotEmpty) {
      out.writeln('description: ${kit.description}');
    }
    out
      ..writeln('---')
      ..writeln()
      ..writeln('# ${kit.name} design kit')
      ..writeln();

    _section(out, 'Brand', kit.brand);

    out
      ..writeln('## Colors')
      ..writeln()
      ..writeln('| Token | Light | Dark | Usage |')
      ..writeln('|---|---|---|---|');
    for (final KitColorToken t in kit.colors.values) {
      out.writeln(
        '| ${t.name} | ${t.light.designMd} | ${t.dark?.designMd ?? '-'} | ${_cell(t.usage)} |',
      );
    }
    out
      ..writeln()
      ..writeln('## Typography')
      ..writeln()
      ..writeln(
        '| Token | Family | Size | Weight | Line height | Letter spacing | Case | Usage |',
      )
      ..writeln('|---|---|---|---|---|---|---|---|');
    for (final KitTextStyle t in kit.typography.values) {
      out.writeln(
        '| ${t.name} | ${t.family} | ${kitNum(t.size)} | ${t.weight} | '
        '${kitNum(t.lineHeight)} | ${kitNum(t.letterSpacing)} | '
        '${t.uppercase ? 'upper' : '-'} | ${_cell(t.usage)} |',
      );
    }
    _scale(out, 'Spacing', kit.spacing);
    _scale(out, 'Radius', kit.radius);
    out
      ..writeln('## Elevation')
      ..writeln()
      ..writeln('| Token | Shadow |')
      ..writeln('|---|---|');
    for (final MapEntry<String, List<KitShadow>> e in kit.elevation.entries) {
      out.writeln(
        '| ${e.key} | ${e.value.isEmpty ? 'none' : e.value.map((KitShadow s) => s.designMd).join(', ')} |',
      );
    }
    out.writeln();

    if (kit.components.isNotEmpty) {
      out
        ..writeln('## Components')
        ..writeln();
      for (final MapEntry<String, KitGuide> c in kit.components.entries) {
        out
          ..writeln('### ${sentenceCase(c.key)}')
          ..writeln();
        _guide(out, c.value);
      }
    }

    out
      ..writeln('## Layout')
      ..writeln();
    if (kit.breakpoints.isNotEmpty) {
      out
        ..writeln(
          '| Breakpoint | Min width | Columns | Margin | Gutter | Max content |',
        )
        ..writeln('|---|---|---|---|---|---|');
      for (final KitBreakpoint b in kit.breakpoints) {
        out.writeln(
          '| ${b.name} | ${kitNum(b.minWidth)} | ${b.columns} | ${b.margin} | '
          '${b.gutter} | ${kitNum(b.maxContent)} |',
        );
      }
      out.writeln();
    }
    _guide(out, kit.layout);

    out
      ..writeln('## Motion')
      ..writeln();
    if (kit.motion.isNotEmpty) {
      out
        ..writeln('| Token | Duration | Curve | Usage |')
        ..writeln('|---|---|---|---|');
      for (final KitMotion m in kit.motion.values) {
        out.writeln(
          '| ${m.name} | ${m.durationMs}ms | ${m.curve} | ${_cell(m.usage)} |',
        );
      }
      out.writeln();
    }
    _guide(out, kit.motionGuide);

    _section(out, 'Imagery', kit.imagery);
    _section(out, 'Iconography', kit.icons);
    _section(out, 'Accessibility', kit.accessibility);
    for (final MapEntry<String, String> e in kit.extra.entries) {
      out
        ..writeln('## ${e.key}')
        ..writeln()
        ..writeln(e.value)
        ..writeln();
    }
    return '${out.toString().trimRight()}\n';
  }

  void _section(StringBuffer out, String title, KitGuide guide) {
    out
      ..writeln('## $title')
      ..writeln();
    _guide(out, guide);
  }

  void _scale(StringBuffer out, String title, Map<String, double> scale) {
    out
      ..writeln()
      ..writeln('## $title')
      ..writeln()
      ..writeln('| Token | Value |')
      ..writeln('|---|---|');
    for (final MapEntry<String, double> e in scale.entries) {
      out.writeln('| ${e.key} | ${kitNum(e.value)} |');
    }
    out.writeln();
  }

  void _guide(StringBuffer out, KitGuide guide) {
    for (final MapEntry<String, String> p in guide.props.entries) {
      out.writeln('${sentenceCase(p.key)}: ${p.value}');
    }
    if (guide.props.isNotEmpty) out.writeln();
    if (guide.notes.isNotEmpty) {
      out
        ..writeln(guide.notes)
        ..writeln();
    }
    if (guide.table.isNotEmpty) {
      final List<String> headers = guide.table.first.keys.toList();
      out
        ..writeln('| ${headers.map(sentenceCase).join(' | ')} |')
        ..writeln('|${List<String>.filled(headers.length, '---').join('|')}|');
      for (final Map<String, String> row in guide.table) {
        out.writeln(
          '| ${headers.map((String h) => _cell(row[h] ?? '')).join(' | ')} |',
        );
      }
      out.writeln();
    }
    void list(String label, List<String> items) {
      if (items.isEmpty) return;
      out.writeln('$label:');
      for (final String item in items) {
        out.writeln('- $item');
      }
      out.writeln();
    }

    list('Rules', guide.rules);
    list('Do', guide.dos);
    list("Don't", guide.donts);
  }

  String _cell(String text) => text.replaceAll('|', '/').replaceAll('\n', ' ');
}
