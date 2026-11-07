// Builds a v1 publish (what the editor's publish flow writes for SDK 8.x)
// from stored v1 page documents, migrates it to a v2 publish bundle, and
// writes the bundle (gzipped JSON). The SDK's tests and example run it.
//
//   dart run bin/publish_fixture.dart <out.json.gz> <page.json.gz>...
//
// Canvases named `<Screen> · M`, `· T` and `· D` on one page form one
// layout with mobile, tablet and desktop breakpoints (0, 600, 1024), as the
// editor's layout groups do; every other canvas is a layout of its own. The
// first layout is the entry screen. The largest layout's canvases are
// stored compressed, as the v1 publisher stores layouts too large for one
// document.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_migrate/codelessly_migrate.dart';

const Map<String, num> _breakpoints = {'M': 0, 'T': 600, 'D': 1024};

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('usage: publish_fixture <out.json.gz> <page.json.gz>...');
    exit(64);
  }
  final pages = args.skip(1).map(File.new).toList();
  final project = pages.first.uri.pathSegments.last.split('__').first.replaceAll('.json.gz', '');

  final layouts = <String, Json>{};
  final layoutFonts = <String, List<String>>{};
  final fonts = <String, Json>{};
  final pageIds = <String>[];

  for (final f in pages) {
    final json = jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync()))) as Map<String, dynamic>;
    final doc = ((json['document'] as Map?) ?? json).cast<String, Object?>();
    final name = f.uri.pathSegments.last.replaceAll('.json.gz', '');
    final pageId = name.contains('__') ? name.split('__').last : name;
    pageIds.add(pageId);

    final canvasIds = readStrings((doc['rootNode'] as Map?)?['children']).where((c) => doc[c] is Map).toList();
    // Layout groups: canvases sharing a name before ` · M/T/D`.
    final groups = <String, List<(String, num)>>{};
    for (final c in canvasIds) {
      final canvasName = '${(doc[c] as Map)['name'] ?? ''}';
      final m = RegExp(r'^(.*) · ([MTD])$').firstMatch(canvasName);
      final key = m == null ? c : '${m.group(1)}';
      groups.putIfAbsent(key, () => []).add((c, m == null ? 0 : _breakpoints[m.group(2)]!));
    }
    for (final group in groups.values) {
      group.sort((a, b) => a.$2.compareTo(b.$2));
      final layoutId = 'L${group.first.$1}';
      final canvases = <String, Object?>{
        for (final (c, _) in group) c: _nodesOf(doc, c),
      };
      layouts[layoutId] = {
        'id': layoutId,
        'pageId': pageId,
        'projectId': project,
        'canvases': canvases,
        'breakpoints': group.length < 2
            ? [
                {'nodeId': group.first.$1},
              ]
            : [
                for (var i = 0; i < group.length; i++)
                  {
                    'nodeId': group[i].$1,
                    'lowerBound': group[i].$2,
                    if (i + 1 < group.length) 'upperBound': group[i + 1].$2 - 1,
                  },
              ],
        'lastUpdated': 1793000000000,
        'canvasIds': [for (final (c, _) in group) c],
      };
      final used = <String>{};
      for (final nodes in canvases.values) {
        for (final n in (nodes as Map).values) {
          for (final run in ((n as Map)['textMixedProps'] as List?) ?? const []) {
            final font = (run as Map)['fontName'];
            if (font is! Map || font['family'] is! String) continue;
            final weight = font['weight'] is String ? font['weight'] as String : 'w400';
            final italic = '${font['style']}'.toLowerCase().contains('italic');
            final id = base64Encode(utf8.encode('${font['family']} $weight${italic ? ' Italic' : ''}'));
            fonts[id] = {'id': id, 'family': font['family'], 'weight': weight, if (italic) 'style': 'Italic', 'url': ''};
            used.add(id);
          }
        }
      }
      layoutFonts[layoutId] = [...used];
    }
  }

  // The largest layout is stored compressed.
  final largest = layouts.entries.reduce((a, b) => jsonEncode(a.value).length >= jsonEncode(b.value).length ? a : b);
  layouts[largest.key] = compressCanvases(largest.value);

  final v1Model = <String, Object?>{
    'projectId': project,
    'pages': pageIds,
    'layoutIDMap': <String, Object?>{},
    'disabledLayouts': <Object?>[],
    'entryLayoutId': layouts.keys.first,
    'entryPageId': pageIds.first,
    'lastUpdated': 1793000000000,
    'fonts': fonts,
    'layouts': layouts,
    'updates': {
      'layouts': {for (final id in layouts.keys) id: 1793000000000},
      'layoutFonts': layoutFonts,
      'layoutCanvases': {
        for (final e in layouts.entries) e.key: e.value['canvasIds'],
      },
    },
    'owner': 'fixture',
    'teams': <Object?>[],
    'users': <Object?>[],
    'roles': <String, Object?>{},
    'public': true,
  };

  final report = MigrationReport();
  final bundle = migratePublishModel(v1Model, report: report);
  final out = File(args.first)..parent.createSync(recursive: true);
  out.writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode(bundle))));
  stdout.writeln('${layouts.length} layouts, ${report.nodes} nodes, ${fonts.length} fonts → ${out.path} '
      '(${out.lengthSync() ~/ 1024} KiB); unported types: ${report.unportedTypes}');
}

/// The nodes of canvas [canvasId] in stored page [doc]: the canvas and its
/// descendants (children, variant children and the body).
Map<String, Object?> _nodesOf(Map<String, Object?> doc, String canvasId) {
  final out = <String, Object?>{};
  void visit(String id) {
    final n = doc[id];
    if (n is! Map || out.containsKey(id)) return;
    out[id] = n;
    for (final c in readStrings(n['children'])) {
      visit(c);
    }
    for (final v in (n['variants'] as List?) ?? const []) {
      if (v is Map) readStrings(v['children']).forEach(visit);
    }
    final body = (n['properties'] as Map?)?['bodyId'];
    if (body is String) visit(body);
  }

  visit(canvasId);
  return out;
}
