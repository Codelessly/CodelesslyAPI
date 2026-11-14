// What a schema migration did to the documents it was given: every rewrite,
// every value it could not convert mechanically, and every behavior that
// renders differently after it. Nothing a migration changes is silent: this
// is where it is said.
import 'dart:convert' show JsonEncoder;

import '../json.dart';

/// What kind of thing a [MigrationEntry] records.
enum MigrationEntryKind {
  /// A value was rewritten into its current form (same behavior).
  rewrite,

  /// A value has no current form: it is kept under the node's
  /// `legacy.<name>` key and no longer read; [MigrationEntry.instead] says
  /// what an author should write.
  unconvertible,

  /// The document behaves or renders differently after the migration.
  behaviorChange,
}

/// One thing a migration step did.
final class MigrationEntry {
  const MigrationEntry({
    required this.kind,
    required this.step,
    this.document = '',
    this.node = '',
    this.path = '',
    this.old,
    this.value,
    this.message = '',
    this.instead = '',
  });

  final MigrationEntryKind kind;

  /// The step's id ([MigrationStep.id]).
  final String step;

  /// The document it happened in (a file name or a layout id, as the caller
  /// named it; empty when unnamed).
  final String document;

  /// The node's id; empty for something outside a node.
  final String node;

  /// Where in the node (or the document): a JSON pointer such as `/drag` or
  /// `/actions/0/actions/1`.
  final String path;

  /// The value before and after (null when there was none).
  final Object? old, value;

  /// What happened, in a sentence.
  final String message;

  /// For an unconvertible value or a behavior change: what to write
  /// instead.
  final String instead;

  Json toJson() => {
        'kind': kind.name,
        'step': step,
        if (document.isNotEmpty) 'document': document,
        if (node.isNotEmpty) 'node': node,
        if (path.isNotEmpty) 'path': path,
        if (old != null) 'old': old,
        if (value != null) 'new': value,
        if (message.isNotEmpty) 'message': message,
        if (instead.isNotEmpty) 'instead': instead,
      };

  static MigrationEntry? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return MigrationEntry(
      kind: readEnum(MigrationEntryKind.values, m['kind'], MigrationEntryKind.rewrite),
      step: readString(m['step']) ?? '',
      document: readString(m['document']) ?? '',
      node: readString(m['node']) ?? '',
      path: readString(m['path']) ?? '',
      old: m['old'],
      value: m['new'],
      message: readString(m['message']) ?? '',
      instead: readString(m['instead']) ?? '',
    );
  }

  @override
  String toString() => '${kind.name} [$step] $document${node.isEmpty ? '' : ' $node'}$path: $message';
}

/// The entries of one or more migrations, in the order they happened.
/// Pass one to `migrate2to3` (and the other migrations) to collect them;
/// [document] names the document the next entries belong to.
final class MigrationReport {
  MigrationReport({this.document = ''});

  /// The document entries are recorded against until it is changed.
  String document;

  final List<MigrationEntry> entries = [];

  /// The documents the report has seen (migrated, with or without entries).
  final List<String> documents = [];

  Iterable<MigrationEntry> get rewrites => entries.where((e) => e.kind == MigrationEntryKind.rewrite);
  Iterable<MigrationEntry> get unconvertible => entries.where((e) => e.kind == MigrationEntryKind.unconvertible);
  Iterable<MigrationEntry> get behaviorChanges => entries.where((e) => e.kind == MigrationEntryKind.behaviorChange);

  bool get isEmpty => entries.isEmpty;

  void add(MigrationEntry e) => entries.add(e);

  /// The number of entries per step id, for each kind.
  Map<String, Map<MigrationEntryKind, int>> get countsByStep {
    final out = <String, Map<MigrationEntryKind, int>>{};
    for (final e in entries) {
      final m = out.putIfAbsent(e.step, () => {});
      m[e.kind] = (m[e.kind] ?? 0) + 1;
    }
    return out;
  }

  Json toJson() => {
        'documents': documents,
        'entries': [for (final e in entries) e.toJson()],
      };

  static MigrationReport fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return MigrationReport()
      ..documents.addAll(readStrings(m['documents']))
      ..entries.addAll([...?readList(m['entries'])?.map(MigrationEntry.fromJson).nonNulls]);
  }
}

/// [report] as Markdown: the counts per step, every unconvertible value with
/// the documents it was in, and every behavior change, grouped by what was
/// said.
String migrationReportMarkdown(MigrationReport report, {String title = 'Schema 2 → 3 migration report'}) {
  final b = StringBuffer('# $title\n\n');
  final docs = report.documents.toSet();
  b.writeln('${docs.length} documents migrated; ${report.rewrites.length} rewrites, '
      '${report.unconvertible.length} unconvertible values, ${report.behaviorChanges.length} behavior changes.\n');
  b.writeln('## Entries per step\n');
  b.writeln('| Step | Rewrites | Unconvertible | Behavior changes | Documents |');
  b.writeln('|---|---|---|---|---|');
  final byStep = <String, List<MigrationEntry>>{};
  for (final e in report.entries) {
    byStep.putIfAbsent(e.step, () => []).add(e);
  }
  for (final s in byStep.keys.toList()..sort()) {
    final es = byStep[s]!;
    int n(MigrationEntryKind k) => es.where((e) => e.kind == k).length;
    b.writeln('| `$s` | ${n(MigrationEntryKind.rewrite)} | ${n(MigrationEntryKind.unconvertible)} | '
        '${n(MigrationEntryKind.behaviorChange)} | ${es.map((e) => e.document).toSet().length} |');
  }
  void grouped(String heading, Iterable<MigrationEntry> entries) {
    b.writeln('\n## $heading\n');
    if (entries.isEmpty) {
      b.writeln('None.');
      return;
    }
    final groups = <String, List<MigrationEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent('${e.step}\u0000${e.message}\u0000${e.instead}', () => []).add(e);
    }
    for (final g in groups.values) {
      final e = g.first;
      b.writeln('- **`${e.step}`**: ${e.message}${e.instead.isEmpty ? '' : ' Instead: ${e.instead}'}');
      final where = <String, List<String>>{};
      for (final x in g) {
        where.putIfAbsent(x.document, () => []).add('${x.node}${x.path}${x.old == null ? '' : ' = `${_short(x.old)}`'}');
      }
      for (final w in where.entries) {
        b.writeln('  - ${w.key.isEmpty ? '(unnamed)' : '`${w.key}`'}: ${w.value.take(8).join('; ')}${w.value.length > 8 ? ' (+${w.value.length - 8} more)' : ''}');
      }
    }
  }

  grouped('Unconvertible values (kept as `legacy.<name>`)', report.unconvertible);
  grouped('Behavior changes', report.behaviorChanges);
  return b.toString();
}

String _short(Object? v) {
  final s = v is String ? v : jsonEncodeShort(v);
  return s.length > 80 ? '${s.substring(0, 77)}...' : s;
}

String jsonEncodeShort(Object? v) {
  try {
    return const JsonEncoder().convert(v);
  } catch (_) {
    return '$v';
  }
}
