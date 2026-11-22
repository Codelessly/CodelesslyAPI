// Generates docs/reference from the declarations of codelessly_api.
//
//   dart run tool/reference/generate.dart             # write the files
//   dart run tool/reference/generate.dart --check     # exit 1 if any is stale
//   dart run tool/reference/generate.dart --notation  # the notation reference only
//                                                     # (docs/reference/notation; with --check too)
//
// Inputs: the package's declarations (read with dart:mirrors, doc comments
// from the sources), the guide templates in tool/reference/templates, the
// examples in tool/reference/examples, and the SDK's formula table in
// tool/reference/data/formulas.json (regenerate it with the SDK's
// tool/reference/extract_formulas.sh). Run from the package root.
import 'dart:io';

import 'src/notation_reference.dart';
import 'src/reference.dart';

void main(List<String> args) {
  final root = Directory.current.path;
  final notationOnly = args.contains('--notation');
  final files = {
    if (!notationOnly) ...buildReference(root),
    ...buildNotationReference(root),
  };
  final check = args.contains('--check');
  final stale = <String>[];
  for (final e in files.entries) {
    final f = File('$root/${e.key}');
    var current = f.existsSync() ? f.readAsStringSync() : null;
    // A file is compared by its content and written in the line endings the
    // checkout has (CRLF on a Windows one with core.autocrlf).
    final crlf = current?.contains('\r\n') ?? false;
    current = current?.replaceAll('\r\n', '\n');
    if (current == e.value) continue;
    stale.add(e.key);
    if (!check) {
      f.parent.createSync(recursive: true);
      f.writeAsStringSync(crlf ? e.value.replaceAll('\n', '\r\n') : e.value);
    }
  }
  final what = notationOnly ? notationDir : 'docs/reference';
  if (check) {
    if (stale.isEmpty) {
      stdout.writeln('$what is up to date.');
    } else {
      stderr.writeln('Stale: ${stale.join(', ')}. Run: dart run tool/reference/generate.dart${notationOnly ? ' --notation' : ''}');
      exitCode = 1;
    }
  } else {
    stdout.writeln(stale.isEmpty ? '$what: no changes.' : 'Wrote ${stale.join(', ')}.');
  }
}
