// Generates docs/reference from the declarations of codelessly_api.
//
//   dart run tool/reference/generate.dart          # write the files
//   dart run tool/reference/generate.dart --check  # exit 1 if any is stale
//
// Inputs: the package's declarations (read with dart:mirrors, doc comments
// from the sources), the guide templates in tool/reference/templates, the
// examples in tool/reference/examples, and the SDK's formula table in
// tool/reference/data/formulas.json (regenerate it with the SDK's
// tool/reference/extract_formulas.sh). Run from the package root.
import 'dart:io';

import 'src/reference.dart';

void main(List<String> args) {
  final root = Directory.current.path;
  final files = buildReference(root);
  final check = args.contains('--check');
  final stale = <String>[];
  for (final e in files.entries) {
    final f = File('$root/${e.key}');
    final current = f.existsSync() ? f.readAsStringSync() : null;
    if (current == e.value) continue;
    stale.add(e.key);
    if (!check) {
      f.parent.createSync(recursive: true);
      f.writeAsStringSync(e.value);
    }
  }
  if (check) {
    if (stale.isEmpty) {
      stdout.writeln('docs/reference is up to date.');
    } else {
      stderr.writeln('Stale: ${stale.join(', ')}. Run: dart run tool/reference/generate.dart');
      exitCode = 1;
    }
  } else {
    stdout.writeln(stale.isEmpty ? 'docs/reference: no changes.' : 'Wrote ${stale.join(', ')}.');
  }
}
