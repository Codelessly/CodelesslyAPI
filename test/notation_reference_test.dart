// The notation reference (docs/reference/notation) is what the generator
// makes of the declarations today, and every ```notation block in it reads
// with no issue and prints back as written. Files are read with their line
// endings normalised, so the test holds on a Windows checkout too.
@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

import '../tool/reference/src/notation_reference.dart';

void main() {
  final root = Directory.current.path;
  final dir = Directory('$root/$notationDir');
  final pages = {
    for (final f in dir.listSync().whereType<File>())
      if (f.path.endsWith('.md')) f.uri.pathSegments.last: readLf(f.path),
  };

  test('docs/reference/notation is up to date (dart run tool/reference/generate.dart --notation)', () {
    final files = buildNotationReference(root);
    final stale = [
      for (final e in files.entries)
        if (!File('$root/${e.key}').existsSync() || readLf('$root/${e.key}') != e.value) e.key,
    ];
    expect(stale, isEmpty, reason: 'Regenerate: dart run tool/reference/generate.dart --notation');
    final generated = {for (final k in files.keys) k.substring('$notationDir/'.length)};
    final lingering = [for (final f in dir.listSync().whereType<File>()) if (!generated.contains(f.uri.pathSegments.last)) f.uri.pathSegments.last];
    expect(lingering, isEmpty, reason: 'Files the generator no longer writes');
  });

  test('every notation block parses with no issue', () {
    final problems = <String>[];
    var blocks = 0;
    for (final e in pages.entries) {
      for (final b in notationBlocks(e.value)) {
        // A print the parser says something about is a printer bug, listed in _tails.md.
        if (b.unchecked) continue;
        blocks++;
        final problem = notationBlockProblem(b.text, width: b.width, define: true, catalog: b.components ? notationComponentsCatalog(root) : null);
        if (problem != null) problems.add('${e.key}:${b.line}: $problem');
      }
    }
    expect(blocks, greaterThan(60));
    expect(problems, isEmpty);
  });

  test('every notation block prints back as written', () {
    final problems = <String>[];
    for (final e in pages.entries) {
      for (final b in notationBlocks(e.value)) {
        if (b.define || b.unchecked) continue;
        final problem = notationBlockProblem(b.text, width: b.width, catalog: b.components ? notationComponentsCatalog(root) : null);
        if (problem != null) problems.add('${e.key}:${b.line}: ${b.text}\n$problem');
      }
    }
    expect(problems, isEmpty);
  });

  test('every link and anchor of the folder resolves', () {
    final anchors = {
      for (final e in pages.entries) e.key: {for (final m in RegExp(r'<a id="([^"]+)"></a>').allMatches(e.value)) m[1]!},
    };
    final broken = <String>[];
    for (final e in pages.entries) {
      final text = e.value.replaceAll(RegExp(r'```.*?```', dotAll: true), '').replaceAll(RegExp(r'`[^`\n]*`'), '');
      for (final m in RegExp(r'\]\(([^)\s]+)\)').allMatches(text)) {
        final target = m[1]!;
        if (target.startsWith('http') || target.startsWith('../')) continue;
        final hash = target.indexOf('#');
        final file = hash < 0 ? target : target.substring(0, hash);
        final resolved = file.isEmpty ? e.key : file;
        if (!File('${dir.path}/$resolved').existsSync()) {
          broken.add('${e.key} → $target (no file)');
        } else if (hash >= 0 && !(anchors[resolved] ?? const {}).contains(target.substring(hash + 1))) {
          broken.add('${e.key} → $target (no anchor)');
        }
      }
    }
    expect(broken, isEmpty);
  });
}
