// Saved prompt -> plan -> tree snapshots. Plans are real generator answers
// (eval/plans in codelessly_genscreen); each compiles to the same trees as
// when the snapshot was taken. After an intended compiler change, review
// the diff and update with:  UPDATE_SNAPSHOTS=1 dart test test/genscreen/regression_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/genscreen.dart';
import 'package:test/test.dart';

/// The outline of a tree, one line per node: depth, type, name and fits.
String outline(Map<String, dynamic> node, [int depth = 0]) {
  final StringBuffer out = StringBuffer()
    ..writeln('${'  ' * depth}${node['type']} "${node['name']}" ${node['horizontalFit'] ?? ''}/${node['verticalFit'] ?? ''}');
  for (final dynamic c in (node['children'] as List?) ?? const []) {
    out.write(outline(c as Map<String, dynamic>, depth + 1));
  }
  for (final dynamic v in (node['variants'] as List?) ?? const []) {
    out.writeln('${'  ' * (depth + 1)}variant ${v['name']}');
    if (v['content'] != null) out.write(outline(v['content'] as Map<String, dynamic>, depth + 2));
  }
  return out.toString();
}

void main() {
  final bool update = Platform.environment['UPDATE_SNAPSHOTS'] == '1';
  for (final Directory dir in Directory('test/genscreen/regression').listSync().whereType<Directory>()) {
    final String kitName = dir.uri.pathSegments[dir.uri.pathSegments.length - 2];
    final DesignKit kit = const DesignMdParser()
        .parse(File('test/genscreen/fixtures/$kitName.design.md').readAsStringSync())
        .kit;
    for (final File planFile in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.plan.json'))) {
      final String slug = planFile.uri.pathSegments.last.replaceAll('.plan.json', '');
      test('$kitName/$slug compiles to its snapshot', () {
        final Map<String, dynamic> plan = jsonDecode(planFile.readAsStringSync()) as Map<String, dynamic>;
        expect(
          ScreenPlanValidator(kit).validate(plan).where((i) => i.severity == PlanSeverity.error),
          isEmpty,
        );
        final CompiledScreen screen = ScreenCompiler(kit).compile(plan);
        expect(checkOnBrand(screen, kit).passed, isTrue);
        expect(screen.report.wired, screen.report.interactive);
        final String snapshot = <String>[
          for (final MapEntry<String, Map<String, dynamic>> e in screen.trees.entries)
            '# ${e.key} ${fnvHex(jsonEncode(e.value))}\n${outline(e.value)}',
        ].join('\n');
        final File file = File('${dir.path}/$slug.snapshot.txt');
        if (update || !file.existsSync()) file.writeAsStringSync(snapshot);
        expect(snapshot, file.readAsStringSync());
      });
    }
  }
}
